--!nonstrict
--[[
        RegionService.luau - v21 SISTEM WILAYAH (arsitektur MMO)
        Dunia terbagi pulau-pulau wilayah (lihat Balance.Regions):
          Pusat Kota (hub) <-> Pulau Panen (civil) <-> pulau monster (combat)
          + Pulau Rumah pribadi tiap pemain (home).
        Setiap gerbang = portal bercahaya + ProximityPrompt "Masuki Portal".
        Teleport server-side (aman), titik muncul dari Balance.gateArrival.

        KLAIM PULAU RUMAH (syariah: lunas di muka, tanpa bunga):
          - Pulau 1 GRATIS untuk pemain pertama yang mengklaim.
          - Pulau 2..6 dibeli LUNAS dengan Micda (harga = Balance.LandPrices).
          - Kepemilikan PERSISTEN (Data.HomeId di DataService).
          - Pulau ini berisi: rumah, ladang pribadi, kolam air sungguhan,
            ruang Bedah/Sains/Startopia, gerbang balik ke Pusat Kota.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Remotes)
local Balance = require(ReplicatedStorage.Shared.Balance)
local Util = require(ReplicatedStorage.Shared.Util)

local RegionService = {}

local DataService -- diisi saat init (hindari siklus require)
local FarmService

local worldFolder: Folder? = nil
local homeTaken: { [number]: Player } = {} -- pulau rumah -> pemilik online

local function world(): Folder
        local f = worldFolder
        if not f then
                f = workspace:FindFirstChild("AKM_Dunia") :: Folder?
                if not f then
                        f = Instance.new("Folder")
                        f.Name = "AKM_Dunia"
                        f.Parent = workspace
                end
                worldFolder = f
        end
        return f :: Folder
end

local function part(props): Part
        local p = Instance.new("Part")
        p.Anchored = true
        p.TopSurface = Enum.SurfaceType.Smooth
        p.BottomSurface = Enum.SurfaceType.Smooth
        for k, v in props do
                (p :: any)[k] = v
        end
        p.Parent = world()
        return p
end

--------------------------------------------------------------------
-- GERBANG PORTAL
--------------------------------------------------------------------

-- warna portal per jenis tujuan (konsisten antar wilayah)
local PORTAL_COLORS = {
        home = Color3.fromRGB(120, 220, 160),
        pusat = Color3.fromRGB(255, 209, 102),
        panen = Color3.fromRGB(140, 220, 120),
        padang = Color3.fromRGB(240, 130, 90),
        hutan = Color3.fromRGB(130, 200, 235),
        baja = Color3.fromRGB(190, 120, 255),
}

local GATE_LABEL = {
        panen = "PULAU PANEN",
        padang = "PADANG LIAR (MONSTER)",
        hutan = "HUTAN BAYANG (MONSTER)",
        baja = "NEGERI BAJA & KRISTAL (MONSTER)",
}

--- Bangun satu gerbang portal: pos = tepi pulau, n = arah normal ke dalam
--- pulau (bidang portal menghadap pemain yang datang dari dalam).
local function buildGate(pos: Vector3, nX: number, nZ: number, destId: string, label: string)
        local color = PORTAL_COLORS[destId] or Color3.fromRGB(200, 200, 210)
        local len = math.sqrt(nX * nX + nZ * nZ)
        if len < 0.001 then
                nX, nZ = 0, -1
                len = 1
        end
        local base = CFrame.lookAt(pos, pos + Vector3.new(nX / len, 0, nZ / len))

        -- lantai gerbang
        part({
                Name = "PortalLantai",
                Size = Vector3.new(8, 0.3, 10),
                CFrame = base * CFrame.new(0, 0.15, 0),
                Color = Color3.fromRGB(198, 190, 178),
                Material = Enum.Material.Granite,
        })
        -- dua pilar di sisi kiri-kanan bidang
        for _, side in { -1, 1 } do
                part({
                        Name = "PortalPilar",
                        Size = Vector3.new(2, 12, 2),
                        CFrame = base * CFrame.new(side * 4.4, 6, 0),
                        Color = Color3.fromRGB(72, 76, 92),
                        Material = Enum.Material.SmoothPlastic,
                })
                part({
                        Name = "PortalPilarOrnamen",
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(1.6, 1.6, 1.6),
                        CFrame = base * CFrame.new(side * 4.4, 12.6, 0),
                        Color = color,
                        Material = Enum.Material.Neon,
                })
        end
        -- palang atas
        part({
                Name = "PortalPalang",
                Size = Vector3.new(11, 2, 2.2),
                CFrame = base * CFrame.new(0, 13.4, 0),
                Color = Color3.fromRGB(44, 48, 62),
                Material = Enum.Material.SmoothPlastic,
        })
        -- bidang portal bercahaya (tembus, tanpa tabrakan)
        local plane = part({
                Name = "PortalCahaya",
                Size = Vector3.new(7.6, 10.6, 0.4),
                CFrame = base * CFrame.new(0, 5.5, 0),
                Color = color,
                Material = Enum.Material.Neon,
                Transparency = 0.55,
                CanCollide = false,
        })
        -- papan nama gerbang (terbaca dari dalam pulau)
        local board = part({
                Name = "PortalPapan",
                Size = Vector3.new(10.5, 2.6, 0.6),
                CFrame = base * CFrame.new(0, 15.4, 0),
                Color = Color3.fromRGB(30, 34, 46),
                Material = Enum.Material.SmoothPlastic,
        })
        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Front
        gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        gui.PixelsPerStud = 48
        gui.Parent = board
        Util.create("TextLabel", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = color:Lerp(Color3.new(1, 1, 1), 0.35),
                Text = label,
        }, board)

        -- prompt teleport
        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Masuki Portal"
        prompt.ObjectText = label
        prompt.MaxActivationDistance = 10
        prompt.HoldDuration = 0.35
        prompt.RequiresLineOfSight = false
        prompt.Parent = plane
        prompt.Triggered:Connect(function(player: Player)
                RegionService.travel(player, destId)
        end)
        return plane
end

--------------------------------------------------------------------
-- TELEPORT & KLAIM
--------------------------------------------------------------------

local function teleportTo(player: Player, regionId: string, fromRegionId: string)
        local ax, az = Balance.gateArrival(regionId, fromRegionId)
        if not ax then
                local r = Balance.regionById(regionId)
                ax, az = r and r.center[1] or 0, r and r.center[2] or 0
        end
        local character = player.Character
        if not character then
                return
        end
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
                root.Anchored = false
                character:PivotTo(CFrame.new(ax, 4, az) * CFrame.Angles(0, math.rad(Balance.regionById(regionId).kind == "hub" and 180 or 0), 0))
                Util.burst(root, Color3.fromRGB(255, 236, 170), 14, 8)
        end
        local region = Balance.regionById(regionId)
        Remotes.get("Notify"):FireClient(player, "-> " .. (region and region.name or regionId),
                regionId == "pusat" and "Selamat datang kembali di Pusat Kota."
                        or "Kau memasuki " .. (region and region.name or regionId) .. ".")
end

--- Menuju pulau rumah pemain: klaim bila belum punya.
local function travelHome(player: Player)
        local homeId = DataService.getHomeId(player)
        if homeId < 1 then
                -- cari pulau kosong (di antara pemain yang sedang online)
                local taken = {}
                for idx, owner in homeTaken do
                        if owner ~= player and owner.Parent then
                                taken[idx] = true
                        end
                end
                local idx = Balance.nextFreeHome(taken)
                if idx < 1 then
                        Remotes.get("Notify"):FireClient(player, "Pulau Penuh",
                                "Semua pulau rumah sudah dimiliki. Coba lagi nanti!")
                        return
                end
                -- syariah: pulau 1 gratis; pulau lain DIBELI LUNAS (tanpa bunga/cicilan)
                local price = Balance.LandPrices[idx] or 0
                if price > 0 then
                        local data = DataService.get(player)
                        if data.Coins < price then
                                Remotes.get("Notify"):FireClient(player, "Micda Kurang",
                                        "Pulau Rumah " .. idx .. " dijual " .. price .. " Micda (bayar penuh, milik permanen). Micdamu: " .. data.Coins .. ".")
                                return
                        end
                        DataService.addCoins(player, -price, false)
                end
                DataService.setHomeId(player, idx)
                homeTaken[idx] = player
                FarmService.claimPlotFor(player, idx)
                Remotes.get("Notify"):FireClient(player, "PULAU RUMAHMU!",
                        (price > 0 and ("Pulau Rumah " .. idx .. " kini MILIKMU (dibeli " .. price .. " Micda, lunas & permanen)!")
                                or ("Pulau Rumah 1 kini MILIKMU (GRATIS & permanen)!"))
                                .. " Ada rumah, ladang pribadi, kolam air sungguhan, ruang Bedah/Sains/Startopia.")
        end
        teleportTo(player, "rumah" .. homeId, "pusat")
end

function RegionService.travel(player: Player, destId: string)
        if not DataService.has(player) then
                return
        end
        -- dari wilayah asal mana? (dari posisi karakter)
        local character = player.Character
        local fromId = "pusat"
        if character then
                local root = character:FindFirstChild("HumanoidRootPart")
                if root then
                        local p = root.Position
                        for _, r in ipairs(Balance.Regions) do
                                if math.abs(p.X - r.center[1]) <= r.half[1] and math.abs(p.Z - r.center[2]) <= r.half[2] then
                                        fromId = r.id
                                        break
                                end
                        end
                end
        end
        if destId == "home" then
                travelHome(player)
                return
        end
        if Balance.regionById(destId) then
                teleportTo(player, destId, fromId)
        end
end

--------------------------------------------------------------------
-- PEMAIN
--------------------------------------------------------------------

function RegionService.onPlayerAdded(player: Player)
        local homeId = DataService.getHomeId(player)
        if homeId >= 1 then
                homeTaken[homeId] = player
                -- klaim ulang ladang di pulau sendiri (kepemilikan pulau persisten)
                task.delay(2, function()
                        if not player.Parent then
                                return
                        end
                        local ok = FarmService.claimPlotFor(player, homeId)
                        if not ok then
                                local plot = FarmService.getPlot(homeId)
                                if plot and plot.owner and plot.owner ~= player then
                                        Remotes.get("Notify"):FireClient(player, "Pulau Ditempati",
                                                "Ladang di Pulau Rumahmu sedang dipakai pemain lain pada sesi ini. Kamu tetap pemilik pulau.")
                                end
                        end
                end)
        end
end

function RegionService.onPlayerRemoving(player: Player)
        for idx, owner in homeTaken do
                if owner == player then
                        homeTaken[idx] = nil
                end
        end
end

--------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------

function RegionService.init(svc)
        DataService = svc.Data
        FarmService = svc.Farm

        -- bangun semua gerbang dari data wilayah (bidang tegak lurus tepi pulau)
        for _, region in ipairs(Balance.Regions) do
                for _, gate in ipairs(region.gates) do
                        local label = GATE_LABEL[gate.dest]
                        if gate.dest == "home" then
                                label = "PULAU RUMAHKU"
                        elseif gate.dest == "pusat" then
                                label = "PUSAT KOTA"
                        elseif not label then
                                local r = Balance.regionById(gate.dest)
                                label = r and string.upper(r.name) or string.upper(gate.dest)
                        end
                        local nX = region.center[1] - gate.pos[1]
                        local nZ = region.center[2] - gate.pos[2]
                        buildGate(Vector3.new(gate.pos[1], 0, gate.pos[2]), nX, nZ, gate.dest, label)
                end
        end

        print("[AKIOMIDA] RegionService: " .. #Balance.Regions .. " wilayah & gerbang portal dibangun.")
end

return RegionService
