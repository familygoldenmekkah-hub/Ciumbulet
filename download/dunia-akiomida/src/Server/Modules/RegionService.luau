local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Remotes = require(ReplicatedStorage.Remotes)
local Balance = require(ReplicatedStorage.Shared.Balance)
local Util = require(ReplicatedStorage.Shared.Util)

local RegionService = {}

local DataService
local FarmService
local PersonalWorldBuilder

local worldFolder: Folder? = nil
local homeTaken: { [number]: Player } = {}

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

local PORTAL_COLORS = {
        home = Color3.fromRGB(120, 220, 160),
        pusat = Color3.fromRGB(255, 209, 102),
        padang = Color3.fromRGB(240, 130, 90),
        hutan = Color3.fromRGB(130, 200, 235),
        baja = Color3.fromRGB(190, 120, 255),
}

local GATE_LABEL = {
        padang = "PADANG LIAR (MONSTER)",
        hutan = "HUTAN BAYANG (MONSTER)",
        baja = "NEGERI BAJA & KRISTAL (MONSTER)",
}

local function buildGate(pos: Vector3, nX: number, nZ: number, destId: string, label: string)
        local color = PORTAL_COLORS[destId] or Color3.fromRGB(200, 200, 210)
        local len = math.sqrt(nX * nX + nZ * nZ)
        if len < 0.001 then
                nX, nZ = 0, -1
                len = 1
        end
        local base = CFrame.lookAt(pos, pos + Vector3.new(nX / len, 0, nZ / len))

        part({
                Name = "PortalLantai",
                Size = Vector3.new(8, 0.3, 10),
                CFrame = base * CFrame.new(0, 0.15, 0),
                Color = Color3.fromRGB(198, 190, 178),
                Material = Enum.Material.Granite,
        })
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
                        CanCollide = false,
                })
        end
        part({
                Name = "PortalPalang",
                Size = Vector3.new(11, 2, 2.2),
                CFrame = base * CFrame.new(0, 13.4, 0),
                Color = Color3.fromRGB(44, 48, 62),
                Material = Enum.Material.SmoothPlastic,
        })
        local plane = part({
                Name = "PortalCahaya",
                Size = Vector3.new(7.6, 10.6, 0.4),
                CFrame = base * CFrame.new(0, 5.5, 0),
                Color = color,
                Material = Enum.Material.Neon,
                Transparency = 0.55,
                CanCollide = false,
        })
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
end

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
                regionId == "pusat" and "Selamat datang di Pusat Kota - TOKO BENIH ada di sini!"
                        or "Kau memasuki " .. (region and region.name or regionId) .. ".")
end

local function landSpawnLocation(index: number): SpawnLocation?
        local folder = world():FindFirstChild("Lahan" .. index)
        if not folder then
                return nil
        end
        return folder:FindFirstChild("SpawnLahan" .. index) :: SpawnLocation?
end

local function goToOwnLahan(player: Player): boolean
        local homeId = DataService.getHomeId(player)
        if homeId < 1 then
                return false
        end
        local spawnLoc = landSpawnLocation(homeId)
        local character = player.Character
        if not character then
                return true
        end
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then
                return true
        end
        if spawnLoc then
                player.RespawnLocation = spawnLoc
                character:PivotTo(spawnLoc.CFrame + Vector3.new(0, 4, 0))
        else
                local sx, sz = Balance.landSpawn(homeId)
                character:PivotTo(CFrame.new(sx, 4, sz))
        end
        Util.burst(root, Color3.fromRGB(150, 240, 180), 14, 8)
        return true
end

local function claimLahan(player: Player): number
        local homeId = DataService.getHomeId(player)
        if homeId >= 1 then
                return homeId
        end
        local taken = {}
        for idx, owner in homeTaken do
                if owner ~= player and owner.Parent then
                        taken[idx] = true
                end
        end
        local idx = Balance.nextFreeHome(taken)
        if idx < 1 then
                return 0
        end
        DataService.setHomeId(player, idx)
        homeTaken[idx] = player
        local koperasiName = DataService.ensureKoperasiName(player)
        PersonalWorldBuilder.buildFull(idx, { Farm = FarmService, Gather = require(script.Parent.GatherService) }, koperasiName)
        FarmService.claimFieldFor(player, idx)
        return idx
end

local function travelHome(player: Player)
        local idx = claimLahan(player)
        if idx < 1 then
                Remotes.get("Notify"):FireClient(player, "Lahan Penuh",
                        "Semua lahan sudah dimiliki pemain lain. Coba lagi nanti!")
                return
        end
        if goToOwnLahan(player) then
                Remotes.get("Notify"):FireClient(player, "LAHANMU!",
                        "Selamat datang di lahanmu sendiri: rumah 3 lantai + rooftop, kebun 500 petak, kolam air, ruang Bedah/Sains/Startopia/Pancing & koperasimu.")
        end
        local landName = DataService.getLandName(player)
        if landName == "" then
                task.delay(1.2, function()
                        if player.Parent then
                                Remotes.get("OpenLandBoard"):FireClient(player)
                        end
                end)
        end
end

function RegionService.travel(player: Player, destId: string)
        if not DataService.has(player) then
                return
        end
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

function RegionService.onPlayerAdded(player: Player)
        local homeId = claimLahan(player)
        if homeId >= 1 then
                homeTaken[homeId] = player
                task.delay(2.5, function()
                        if not player.Parent then
                                return
                        end
                        goToOwnLahan(player)
                        local landName = DataService.getLandName(player)
                        if landName == "" then
                                Remotes.get("Notify"):FireClient(player, "PAPAN NAMA",
                                        "Isi papan nama lahanku supaya pengunjung tahu siapa pemiliknya!")
                                Remotes.get("OpenLandBoard"):FireClient(player)
                        end
                end)
        end
end

function RegionService.onCharacterAdded(player: Player)
        local homeId = DataService.getHomeId(player)
        if homeId < 1 then
                return
        end
        local spawnLoc = landSpawnLocation(homeId)
        if spawnLoc then
                player.RespawnLocation = spawnLoc
        end
end

function RegionService.onPlayerRemoving(player: Player)
        for idx, owner in homeTaken do
                if owner == player then
                        homeTaken[idx] = nil
                end
        end
end

local function handleLandBoard(player: Player, text: any)
        local cleaned = Balance.sanitizeLandName(text)
        if not cleaned then
                return false, "Nama lahan harus 3-20 huruf/angka (spasi, titik, minus, apostrof diperbolehkan)."
        end
        DataService.setLandName(player, cleaned)
        local homeId = DataService.getHomeId(player)
        if homeId >= 1 then
                PersonalWorldBuilder.setNameBoard(homeId, cleaned)
        end
        return true, "Papan nama lahanmu kini: " .. cleaned
end

function RegionService.init(svc)
        DataService = svc.Data
        FarmService = svc.Farm
        PersonalWorldBuilder = require(script.Parent.PersonalWorldBuilder)

        for _, region in ipairs(Balance.Regions) do
                for _, gate in ipairs(region.gates) do
                        local label = GATE_LABEL[gate.dest]
                        if gate.dest == "home" then
                                label = "LAHANMU (RUMAH & KEBUN)"
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

        Remotes.get("LandBoard").OnServerInvoke = handleLandBoard

        Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function()
                        RegionService.onCharacterAdded(player)
                end)
                if player.Character then
                        RegionService.onCharacterAdded(player)
                end
        end)

        print("[AKIOMIDA] RegionService: " .. #Balance.Regions .. " wilayah & gerbang portal dibangun.")
end

return RegionService
