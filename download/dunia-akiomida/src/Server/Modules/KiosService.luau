--!nonstrict
--[[
        KiosService.luau - v20 "KIOS VENDING PEMAIN" (ala stand jualan dunia terbuka):
          - Pemilik lahan memasang SATU kios di ladangnya (bayar lunas di muka).
          - Isi barang dari tas + tentukan harga per unit (Micda).
          - Pemain lain mendekati kios, melihat barang + harga + jasa secara
            TRANSPARAN, lalu membeli langsung - hasil bersih langsung ke pemilik.
          - Kios hanya hidup selama pemilik online (lahan otomatis dibebaskan,
            konsisten dengan FarmService) -> tidak ada escrow, tanpa riba.
          - Jasa layanan 2% (min 1 Micda) tampil sebelum konfirmasi (ujr).
          - Tanpa undian, tanpa spekulasi tersembunyi -> syariah-safe.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Remotes = require(ReplicatedStorage.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)
local Balance = require(ReplicatedStorage.Shared.Balance)
local Util = require(ReplicatedStorage.Shared.Util)

local DataService = require(script.Parent.DataService)
local FarmService = require(script.Parent.FarmService)

local KiosService = {}

local kiosFolder: Folder? = nil
local kiosByPlot: { [number]: any } = {} -- plotIndex -> record
local kiosByOwner: { [number]: any } = {} -- userId -> record

local VALID: { [string]: { [string]: boolean } } = {}

local function buildValid()
        local function set(kind: string, ids: { string })
                VALID[kind] = {}
                for _, id in ids do
                        VALID[kind][id] = true
                end
        end
        local cropIds = {}
        for _, c in ipairs(Config.Crops) do
                table.insert(cropIds, c.id)
        end
        set("seed", cropIds)
        set("crop", cropIds)
        local bagIds = {}
        for _, r in ipairs(Config.Resources) do
                table.insert(bagIds, r.id)
        end
        set("bag", bagIds)
        local fishIds = {}
        for _, f in ipairs(Config.Fish) do
                table.insert(fishIds, f.id)
        end
        set("fish", fishIds)
        local equipIds, useIds = {}, {}
        for _, e in ipairs(Balance.Equipment) do
                table.insert(equipIds, e.id)
        end
        set("equip", equipIds)
        for _, u in ipairs(Balance.Usables) do
                table.insert(useIds, u.id)
        end
        set("use", useIds)
end

--------------------------------------------------------------------
-- MODEL KIOS (karya original, 5 part saja - ringan untuk mobile)
--------------------------------------------------------------------

local function part(props): Part
        local p = Instance.new("Part")
        p.Anchored = true
        p.TopSurface = Enum.SurfaceType.Smooth
        p.BottomSurface = Enum.SurfaceType.Smooth
        for k, v in props do
                (p :: any)[k] = v
        end
        p.Parent = kiosFolder
        return p
end

local function buildKiosModel(position: Vector3, ownerName: string): Model
        local model = Instance.new("Model")
        model.Name = "Kios_" .. ownerName
        local base = position -- tepat di atas pad ladang

        local badan = part({
                Name = "Badan",
                Size = Vector3.new(3.2, 2.4, 1.2),
                CFrame = CFrame.new(base + Vector3.new(0, 1.2, 0)),
                Color = Color3.fromRGB(96, 66, 42),
                Material = Enum.Material.WoodPlanks,
        })
        badan.Parent = model
        model.PrimaryPart = badan

        part({
                Name = "Meja",
                Size = Vector3.new(3.6, 0.35, 1.7),
                CFrame = CFrame.new(base + Vector3.new(0, 0.45, 0.35)),
                Color = Color3.fromRGB(140, 100, 62),
                Material = Enum.Material.WoodPlanks,
        }).Parent = model

        for side = -1, 1, 2 do
                part({
                        Name = "Kaki" .. side,
                        Size = Vector3.new(0.4, 3.1, 0.4),
                        CFrame = CFrame.new(base + Vector3.new(side * 1.4, 1.55, -0.4)),
                        Color = Color3.fromRGB(92, 62, 38),
                        Material = Enum.Material.Wood,
                }).Parent = model
        end

        local atap = part({
                Name = "Atap",
                Size = Vector3.new(3.8, 0.35, 2.0),
                CFrame = CFrame.new(base + Vector3.new(0, 3.3, 0)) * CFrame.Angles(math.rad(-6), 0, 0),
                Color = Color3.fromRGB(233, 196, 106),
                Material = Enum.Material.SmoothPlastic,
        })
        atap.Parent = model

        -- papan nama pemilik (SurfaceGui di muka depan atap)
        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Front
        gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        gui.PixelsPerStud = 40
        gui.Parent = atap
        Util.create("TextLabel", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = Color3.fromRGB(40, 30, 10),
                Text = "KIOS " .. string.upper(ownerName),
        }, gui)

        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Kios Jual"
        prompt.ObjectText = "Kios " .. ownerName
        prompt.MaxActivationDistance = 9
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.Parent = badan

        model.Parent = kiosFolder
        return model
end

--------------------------------------------------------------------
-- SNAPSHOT
--------------------------------------------------------------------

local function slotsOut(record: any): { any }
        local out = {}
        for i, s in ipairs(record.slots) do
                table.insert(out, {
                        slot = i, kind = s.kind, id = s.id,
                        qty = s.qty, price = s.price,
                })
        end
        return out
end

local function pushSnap(player: Player, mode: string, snap: any)
        Remotes.get("KiosSync"):FireClient(player, mode, snap)
end

local function ownerSnap(record: any): any
        return {
                plot = record.plotIndex,
                ownerName = record.ownerName,
                slots = slotsOut(record),
                feeRate = Balance.Kios.feeRate,
                feeMin = Balance.Kios.feeMin,
                price = Balance.Kios.price,
                placed = true,
        }
end

local function browseSnap(record: any): any
        return {
                plot = record.plotIndex,
                ownerName = record.ownerName,
                slots = slotsOut(record),
                feeRate = Balance.Kios.feeRate,
                feeMin = Balance.Kios.feeMin,
        }
end

--------------------------------------------------------------------
-- PASANG / BONGKAR
--------------------------------------------------------------------

local function dismantle(record: any, reason: string)
        if kiosByPlot[record.plotIndex] ~= record then
                return
        end
        kiosByPlot[record.plotIndex] = nil
        if record.model and record.model.Parent then
                -- percikan perpisahan + hapus model
                if record.model.PrimaryPart then
                        Util.burst(record.model.PrimaryPart, Color3.fromRGB(233, 196, 106), 10, 5)
                end
                record.model:Destroy()
        end
        local owner = Players:GetPlayerByUserId(record.ownerId)
        if owner and DataService.has(owner) then
                -- stok pulang ke tas (tidak ada barang hilang)
                for _, s in ipairs(record.slots) do
                        DataService.giveItem(owner, s.kind, s.id, s.qty)
                end
                if #record.slots > 0 then
                        Remotes.get("Notify"):FireClient(owner, "Kios Dibongkar",
                                "Semua sisa barang kembali ke tasmu. " .. reason)
                        DataService.push(owner)
                end
        end
        kiosByOwner[record.ownerId] = nil
end

local function onPlace(player: Player)
        if kiosByOwner[player.UserId] then
                return { ok = false, msg = "Kamu sudah punya kios." }
        end
        local targetPlot = nil
        for index = 1, FarmService.plotCount() do
                local plot = FarmService.getPlot(index)
                if plot and plot.owner == player and not kiosByPlot[index] then
                        targetPlot = plot
                        break
                end
        end
        if not targetPlot then
                return { ok = false, msg = "Klaim ladang dulu - kios dipasang di ladangmu sendiri." }
        end
        local data = DataService.get(player)
        if data.Coins < Balance.Kios.price then
                return { ok = false, msg = "Butuh " .. Balance.Kios.price .. " Micda untuk memasang kios (lunas). Micdamu: " .. data.Coins .. "." }
        end
        DataService.addCoins(player, -Balance.Kios.price, false)

        local record = {
                plotIndex = targetPlot.index,
                ownerId = player.UserId,
                ownerName = player.DisplayName,
                slots = {},
                model = nil,
        }
        record.model = buildKiosModel(targetPlot.kiosPad.Position + Vector3.new(0, targetPlot.kiosPad.Size.Y / 2, 0), player.DisplayName)
        local prompt = record.model.PrimaryPart:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
                prompt.Triggered:Connect(function(who)
                        KiosService.onPadTriggered(who, record.plotIndex)
                end)
        end

        kiosByPlot[record.plotIndex] = record
        kiosByOwner[player.UserId] = record
        pushSnap(player, "kelola", ownerSnap(record))
        DataService.push(player)
        return { ok = true, msg = "Kios terpasang! Isi barang dari tasmu, tentukan harga, lalu biarkan pemain lain belanja." }
end

--------------------------------------------------------------------
-- AKSI PEMILIK
--------------------------------------------------------------------

local function onStock(player: Player, record: any, payload: any)
        local kind = tostring(payload.kind or "")
        local id = tostring(payload.id or "")
        local qty = math.floor(tonumber(payload.qty) or 0)
        local price = math.floor(tonumber(payload.price) or 0)
        if not VALID[kind] or not VALID[kind][id] then
                return { ok = false, msg = "Barang tidak dikenal." }
        end
        if qty < 1 then
                return { ok = false, msg = "Jumlah minimal 1." }
        end
        if price < 1 or price > Balance.Kios.maxPrice then
                return { ok = false, msg = "Harga harus 1 - " .. Balance.Kios.maxPrice .. " Micda." }
        end
        if DataService.countItem(player, kind, id) < qty then
                return { ok = false, msg = "Stok di tas tidak cukup." }
        end
        -- cari slot yang sama (jenis + barang)
        local target = nil
        for _, s in ipairs(record.slots) do
                if s.kind == kind and s.id == id then
                        target = s
                        break
                end
        end
        if not target then
                if #record.slots >= Balance.Kios.maxSlots then
                        return { ok = false, msg = "Kios penuh (maks " .. Balance.Kios.maxSlots .. " jenis barang)." }
                end
                target = { kind = kind, id = id, qty = 0, price = price }
                table.insert(record.slots, target)
        end
        if target.qty + qty > Balance.Kios.maxStock then
                return { ok = false, msg = "Stok slot maksimal " .. Balance.Kios.maxStock .. "." }
        end
        DataService.takeItem(player, kind, id, qty)
        target.qty += qty
        target.price = price
        DataService.push(player)
        pushSnap(player, "kelola", ownerSnap(record))
        return { ok = true, msg = qty .. "x barang dipajang @ " .. price .. " Micda/unit." }
end

local function onTake(player: Player, record: any, payload: any)
        local slotIndex = math.floor(tonumber(payload.slot) or 0)
        local qty = math.floor(tonumber(payload.qty) or 0)
        local s = record.slots[slotIndex]
        if not s then
                return { ok = false, msg = "Slot tidak ada." }
        end
        if qty < 1 then
                qty = s.qty
        end
        qty = math.min(qty, s.qty)
        s.qty -= qty
        if s.qty <= 0 then
                table.remove(record.slots, slotIndex)
        end
        DataService.giveItem(player, s.kind, s.id, qty)
        DataService.push(player)
        pushSnap(player, "kelola", ownerSnap(record))
        return { ok = true, msg = qty .. "x barang ditarik ke tas." }
end

local function onPrice(player: Player, record: any, payload: any)
        local slotIndex = math.floor(tonumber(payload.slot) or 0)
        local price = math.floor(tonumber(payload.price) or 0)
        local s = record.slots[slotIndex]
        if not s then
                return { ok = false, msg = "Slot tidak ada." }
        end
        if price < 1 or price > Balance.Kios.maxPrice then
                return { ok = false, msg = "Harga harus 1 - " .. Balance.Kios.maxPrice .. " Micda." }
        end
        s.price = price
        pushSnap(player, "kelola", ownerSnap(record))
        return { ok = true, msg = "Harga diubah jadi " .. price .. " Micda/unit." }
end

--------------------------------------------------------------------
-- AKSI PEMBELI
--------------------------------------------------------------------

local function onBuy(player: Player, record: any, payload: any)
        if record.ownerId == player.UserId then
                return { ok = false, msg = "Itu kiosmu sendiri." }
        end
        local slotIndex = math.floor(tonumber(payload.slot) or 0)
        local qty = math.floor(tonumber(payload.qty) or 0)
        local s = record.slots[slotIndex]
        if not s or s.qty <= 0 then
                return { ok = false, msg = "Stok habis." }
        end
        if qty < 1 then
                return { ok = false, msg = "Jumlah minimal 1." }
        end
        qty = math.min(qty, s.qty)
        local total = qty * s.price
        local data = DataService.get(player)
        if data.Coins < total then
                return { ok = false, msg = "Micda tidak cukup (butuh " .. total .. ")." }
        end
        -- transaksi atomik: bayar penuh sekali, barang langsung pindah
        DataService.addCoins(player, -total, false)
        DataService.giveItem(player, s.kind, s.id, qty)
        s.qty -= qty
        if s.qty <= 0 then
                table.remove(record.slots, slotIndex)
        end
        -- hasil bersih (total - jasa transparan) langsung ke pemilik
        local proceeds = Balance.kiosProceeds(total)
        local owner = Players:GetPlayerByUserId(record.ownerId)
        if owner and DataService.has(owner) then
                DataService.addCoins(owner, proceeds, false)
                DataService.push(owner)
                Remotes.get("Notify"):FireClient(owner, "Kios Terjual!",
                        player.DisplayName .. " membeli " .. qty .. "x barang (+" .. proceeds .. " Micda bersih).")
        end
        -- efek jual: percikan emas + nada di kios
        if record.model and record.model.PrimaryPart then
                Util.burst(record.model.PrimaryPart, Color3.fromRGB(233, 196, 106), 12, 7)
                local ding = Instance.new("Sound")
                ding.SoundId = "rbxasset://sounds/electronicpingshort.wav"
                ding.Volume = 0.5
                ding.PlaybackSpeed = 1.25
                ding.Parent = record.model.PrimaryPart
                ding:Play()
                task.delay(2, function()
                        if ding.Parent then
                                ding:Destroy()
                        end
                end)
        end
        DataService.push(player)
        pushSnap(player, "belanja", browseSnap(record))
        return { ok = true, msg = "Membeli " .. qty .. "x seharga " .. total .. " Micda. Cek tasmu!" }
end

--------------------------------------------------------------------
-- PROMPT PAD & REMOTE
--------------------------------------------------------------------

function KiosService.onPadTriggered(player: Player, plotIndex: number)
        if not DataService.has(player) then
                return
        end
        local plot = FarmService.getPlot(plotIndex)
        if not plot then
                return
        end
        if not plot.owner then
                Remotes.get("Notify"):FireClient(player, "Pad Kios",
                        "Klaim ladang ini dulu, lalu pasang kiosmu di sini (" .. Balance.Kios.price .. " Micda, lunas).")
                return
        end
        local record = kiosByPlot[plotIndex]
        if plot.owner == player then
                if record then
                        pushSnap(player, "kelola", ownerSnap(record))
                else
                        pushSnap(player, "kelola", {
                                plot = plotIndex, ownerName = player.DisplayName, slots = {},
                                feeRate = Balance.Kios.feeRate, feeMin = Balance.Kios.feeMin, price = Balance.Kios.price,
                                placed = false,
                        })
                end
                Remotes.get("OpenKios"):FireClient(player, "kelola")
                return
        end
        if not record then
                Remotes.get("Notify"):FireClient(player, "Kios Pemain",
                        plot.owner.DisplayName .. " belum memasang kios di ladangnya.")
                return
        end
        pushSnap(player, "belanja", browseSnap(record))
        Remotes.get("OpenKios"):FireClient(player, "belanja")
end

local function onKiosAction(player: Player, payload: any)
        if not DataService.has(player) or type(payload) ~= "table" or type(payload.action) ~= "string" then
                return { ok = false, msg = "Permintaan tidak valid." }
        end
        local action = payload.action

        if action == "place" then
                return onPlace(player)
        end

        if action == "browse" then
                local plotIndex = math.floor(tonumber(payload.plot) or 0)
                local record = kiosByPlot[plotIndex]
                if not record then
                        return { ok = false, msg = "Kios tidak ada." }
                end
                return { ok = true, snap = browseSnap(record) }
        end

        local record = kiosByOwner[player.UserId]
        if action == "buy" then
                local plotIndex = math.floor(tonumber(payload.plot) or 0)
                record = kiosByPlot[plotIndex]
                if not record then
                        return { ok = false, msg = "Kios tidak ada." }
                end
                return onBuy(player, record, payload)
        end

        if not record then
                return { ok = false, msg = "Kamu belum memasang kios." }
        end
        if action == "stock" then
                return onStock(player, record, payload)
        end
        if action == "take" then
                return onTake(player, record, payload)
        end
        if action == "price" then
                return onPrice(player, record, payload)
        end
        if action == "close" then
                dismantle(record, "Sampai jumpa lagi!")
                return { ok = true, msg = "Kios dibongkar. Sisa barang kembali ke tas." }
        end

        return { ok = false, msg = "Aksi tidak dikenal." }
end

--------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------

function KiosService.init()
        buildValid()
        local folder = Instance.new("Folder")
        folder.Name = "AKM_Kios"
        folder.Parent = Workspace
        kiosFolder = folder

        Remotes.get("KiosAction").OnServerInvoke = onKiosAction

        -- pemain keluar: bongkar kios SEBELUM data disimpan (stok kembali ke tas)
        Players.PlayerRemoving:Connect(function(player)
                local record = kiosByOwner[player.UserId]
                if record then
                        dismantle(record, "Kamu keluar game.")
                end
        end)

        -- ikat prompt pad kios di semua ladang (dibangun FarmService)
        task.defer(function()
                for index = 1, FarmService.plotCount() do
                        local plot = FarmService.getPlot(index)
                        if plot and plot.kiosPrompt then
                                plot.kiosPrompt.Triggered:Connect(function(player)
                                        KiosService.onPadTriggered(player, index)
                                end)
                        end
                end
        end)

        print("[AKIOMIDA] Kios vending pemain siap (maks " .. Balance.Kios.maxSlots .. " slot, jasa " .. math.floor(Balance.Kios.feeRate * 100) .. "%).")
end

return KiosService
