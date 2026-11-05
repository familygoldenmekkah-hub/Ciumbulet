--!nonstrict
--[[
        FarmService.luau - jantung ekonomi: ladang pribadi pemain.
        Alur Grow a Garden ala Dunia Akiomida:
          klaim ladang -> beli bibit -> tanam -> (siram) -> tumbuh (nyata waktu,
          tetap tumbuh saat pemain menjelajah) -> panen -> jual di pasar.
        Server-authoritative: semua waktu & validasi di server.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Remotes)
local Util = require(ReplicatedStorage.Shared.Util)

local DataService = require(script.Parent.DataService)
local QuestService = require(script.Parent.QuestService)

local Balance = require(ReplicatedStorage.Shared.Balance)

local FarmService = {}

local PLOT_COUNT = 6
local GRID = 4 -- petak 4x4
local TILE_SIZE = 5
local FENCE_HALF = 13

local cropById: { [string]: any } = {}
for _, crop in ipairs(Config.Crops) do
        cropById[crop.id] = crop
end

local plots: { [number]: any } = {}
local worldFolder: Folder? = nil

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
-- VISUAL TANAMAN (3 tahap + siap panen)
--------------------------------------------------------------------

local function destroyPlant(tile)
        if tile.plant then
                tile.plant:Destroy()
                tile.plant = nil
        end
end

--- bucket: 0 = biji, 1 = kecambah, 2 = tumbuh, 3 = siap panen
local function buildPlantVisual(tile, bucket: number)
        destroyPlant(tile)
        local crop = cropById[tile.seed]
        if not crop then
                return
        end
        local base = tile.part.Position
        local ground = base + Vector3.new(0, tile.part.Size.Y / 2, 0)
        local model = Instance.new("Model")
        model.Name = "Tanaman_" .. tile.seed

        local fruitColor = Color3.fromRGB(crop.color[1], crop.color[2], crop.color[3])

        if bucket == 0 then
                part({
                        Name = "Biji",
                        Size = Vector3.new(1.4, 0.5, 1.4),
                        CFrame = CFrame.new(ground + Vector3.new(0, 0.25, 0)),
                        Color = Color3.fromRGB(122, 88, 56),
                        Material = Enum.Material.Ground,
                        CanCollide = false,
                }).Parent = model
        elseif bucket == 1 then
                part({
                        Name = "Kecambah",
                        Size = Vector3.new(0.5, 1.6, 0.5),
                        CFrame = CFrame.new(ground + Vector3.new(0, 0.8, 0)),
                        Color = Color3.fromRGB(120, 200, 90),
                        Material = Enum.Material.Grass,
                        CanCollide = false,
                }).Parent = model
        elseif bucket == 2 then
                part({
                        Name = "Batang",
                        Size = Vector3.new(0.6, 2.6, 0.6),
                        CFrame = CFrame.new(ground + Vector3.new(0, 1.3, 0)),
                        Color = Color3.fromRGB(96, 170, 80),
                        Material = Enum.Material.Grass,
                        CanCollide = false,
                }).Parent = model
                part({
                        Name = "Daun1",
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(1.8, 1.1, 1.8),
                        CFrame = CFrame.new(ground + Vector3.new(0.7, 2.0, 0.2)),
                        Color = Color3.fromRGB(110, 195, 90),
                        Material = Enum.Material.Grass,
                        CanCollide = false,
                }).Parent = model
                part({
                        Name = "Daun2",
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(1.6, 1.0, 1.6),
                        CFrame = CFrame.new(ground + Vector3.new(-0.7, 1.7, -0.2)),
                        Color = Color3.fromRGB(110, 195, 90),
                        Material = Enum.Material.Grass,
                        CanCollide = false,
                }).Parent = model
        else
                local scale = 1
                if tile.seed == "labu" or tile.seed == "bintang" then
                        scale = 1.5
                end
                part({
                        Name = "Batang",
                        Size = Vector3.new(0.7, 3.2, 0.7),
                        CFrame = CFrame.new(ground + Vector3.new(0, 1.6, 0)),
                        Color = Color3.fromRGB(90, 160, 75),
                        Material = Enum.Material.Grass,
                        CanCollide = false,
                }).Parent = model
                part({
                        Name = "Buah",
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(2.4, 2.4, 2.4) * scale,
                        CFrame = CFrame.new(ground + Vector3.new(0, 2.6 + scale * 0.4, 0)),
                        Color = fruitColor,
                        Material = Enum.Material.SmoothPlastic,
                        CanCollide = false,
                }).Parent = model
                local glow = Instance.new("PointLight")
                glow.Color = fruitColor
                glow.Range = 8
                glow.Brightness = 1.2
                glow.Parent = model.Buah
        end

        model.Parent = tile.part
        tile.plant = model
end

--------------------------------------------------------------------
-- PROMPT & STATE PETAK
--------------------------------------------------------------------

local function updateTilePrompt(tile)
        local prompt = tile.prompt
        if not prompt then
                return
        end
        local plot = plots[tile.plotIndex]
        local owner = plot and plot.owner

        if not owner then
                prompt.Enabled = false
                return
        end

        if tile.state == "empty" then
                prompt.ActionText = "Tanam Bibit"
                prompt.ObjectText = "Petak Ladang"
                prompt.HoldDuration = 0
                prompt.Enabled = true
        elseif tile.state == "growing" then
                local data = DataService.get(owner)
                local canWater = data.Tools.can and not tile.watered
                if canWater then
                        prompt.ActionText = "Siram"
                        prompt.ObjectText = tile.seed .. " tumbuh"
                        prompt.HoldDuration = 0.4
                        prompt.Enabled = true
                else
                        prompt.Enabled = false
                end
        elseif tile.state == "ready" then
                prompt.ActionText = "Panen"
                prompt.ObjectText = cropById[tile.seed] and cropById[tile.seed].name or "Hasil"
                prompt.HoldDuration = 0
                prompt.Enabled = true
        end
end

local function onTileTriggered(player: Player, tile)
        local plot = plots[tile.plotIndex]
        if not plot or plot.owner ~= player or not DataService.has(player) then
                return
        end

        if tile.state == "empty" then
                Remotes.get("OpenPlant"):FireClient(player, tile.plotIndex, tile.tileIndex)
        elseif tile.state == "growing" then
                local data = DataService.get(player)
                if not data.Tools.can then
                        Remotes.get("Notify"):FireClient(player, "Butuh Alat", "Kamu butuh Kaleng Siram - beli di Toko Alat.")
                        return
                end
                if tile.watered then
                        return
                end
                tile.watered = true
                tile.plantedAt -= tile.growTime * Config.Economy.WaterBoost
                Remotes.get("Notify"):FireClient(player, "Disiram!", "Tanamanmu tumbuh 25% lebih cepat.")
                DataService.addXP(player, 2)
                DataService.push(player)
        elseif tile.state == "ready" then
                local crop = cropById[tile.seed]
                if not crop then
                        return
                end
                -- v20: percikan panen (sekali pakai, ringan untuk mobile)
                Util.burst(tile.part, Color3.fromRGB(crop.color[1], crop.color[2], crop.color[3]), 10, 6)
                DataService.giveItem(player, "crop", crop.id, 1)
                DataService.addXP(player, 4)
                QuestService.progress(player, "harvest", 1)
                tile.state = "empty"
                tile.seed = nil
                tile.plantedAt = 0
                tile.growTime = 0
                tile.watered = false
                tile.bucket = -1
                destroyPlant(tile)
                updateTilePrompt(tile)
                DataService.push(player)
        end
end

--------------------------------------------------------------------
-- KLAIM LADANG
--------------------------------------------------------------------

local function priceOfPlot(index: number): number
        return Balance.LandPrices[index] or 0
end

local function updateSign(plot)
        local signText = plot.signText
        if not signText then
                return
        end
        if plot.owner then
                signText.Text = "LADANG " .. plot.index .. " - MILIK " .. string.upper(plot.owner.DisplayName)
                plot.claimPrompt.Enabled = false
        else
                local price = priceOfPlot(plot.index)
                signText.Text = price <= 0
                        and "LADANG " .. plot.index .. " - AMBIL ALIH (GRATIS)"
                        or "LADANG " .. plot.index .. " - BELI " .. price .. " MICDA"
                plot.claimPrompt.Enabled = true
        end
end

local function onClaimTriggered(player: Player, plot)
        if plot.owner then
                if plot.owner == player then
                        Remotes.get("Notify"):FireClient(player, "Ladangmu", "Ini sudah ladang milikmu. Tanami bibit di petak!")
                end
                return
        end
        -- v4 EKONOMI SYARIAH: ladang 1 GRATIS; ladang lain DIBELI dengan Micda
        -- (bayar penuh di muka - tanpa cicilan, tanpa bunga, tanpa riba)
        local price = priceOfPlot(plot.index)
        if price > 0 then
                local data = DataService.get(player)
                if data.Coins < price then
                        Remotes.get("Notify"):FireClient(player, "Micda Kurang",
                                "Ladang " .. plot.index .. " dijual " .. price .. " Micda (bayar penuh, tanpa bunga). Micdamu: " .. data.Coins .. ".")
                        return
                end
                DataService.addCoins(player, -price, false)
        end
        plot.owner = player
        updateSign(plot)
        for _, tile in plot.tiles do
                updateTilePrompt(tile)
        end
        local msg = price > 0
                and "Ladang " .. plot.index .. " kini milikmu (dibeli " .. price .. " Micda, lunas)! Beli bibit di Toko Bibit, lalu dekati petak tanah untuk menanam."
                or "Ladang " .. plot.index .. " kini milikmu (GRATIS)! Beli bibit di Toko Bibit (Pasar Timur), lalu dekati petak tanah untuk menanam."
        Remotes.get("Notify"):FireClient(player, "Ladang Baru!", msg)
        DataService.push(player)
end

-- v21: klaim langsung oleh sistem (portal Pulau Rumah) tanpa biaya -
-- biaya pulau ditangani RegionService sekali di muka (persisten).
function FarmService.claimPlotFor(player: Player, index: number): boolean
        local plot = plots[index]
        if not plot or plot.owner then
                return false
        end
        plot.owner = player
        updateSign(plot)
        for _, tile in plot.tiles do
                updateTilePrompt(tile)
        end
        return true
end

--------------------------------------------------------------------
-- BANGUN LADANG (dipanggil MapService)
--------------------------------------------------------------------

function FarmService.buildPlot(index: number, center: Vector3)
        local plot = {
                index = index,
                center = center,
                owner = nil,
                tiles = {},
        }

        part({
                Name = "LadangDasar_" .. index,
                Size = Vector3.new(26, 1, 26),
                CFrame = CFrame.new(center),
                Color = Color3.fromRGB(124, 94, 62),
                Material = Enum.Material.Ground,
        })

        -- pagar: 4 tiang + 4 palang
        local offsets = { Vector3.new(FENCE_HALF, 0, FENCE_HALF), Vector3.new(-FENCE_HALF, 0, FENCE_HALF),
                Vector3.new(FENCE_HALF, 0, -FENCE_HALF), Vector3.new(-FENCE_HALF, 0, -FENCE_HALF) }
        for i, off in offsets do
                part({
                        Name = "PagarTiang_" .. index .. "_" .. i,
                        Size = Vector3.new(1.1, 3.4, 1.1),
                        CFrame = CFrame.new(center + off + Vector3.new(0, 1.7, 0)),
                        Color = Color3.fromRGB(140, 100, 62),
                        Material = Enum.Material.WoodPlanks,
                })
        end
        -- palang utara-selatan & timur-barat sederhana
        for _, cfg in {
                { off = Vector3.new(FENCE_HALF, 0, 0), size = Vector3.new(0.7, 0.7, FENCE_HALF * 2) },
                { off = Vector3.new(-FENCE_HALF, 0, 0), size = Vector3.new(0.7, 0.7, FENCE_HALF * 2) },
                { off = Vector3.new(0, 0, FENCE_HALF), size = Vector3.new(FENCE_HALF * 2, 0.7, 0.7) },
                { off = Vector3.new(0, 0, -FENCE_HALF), size = Vector3.new(FENCE_HALF * 2, 0.7, 0.7) },
        } do
                part({
                        Name = "PagarPalang_" .. index,
                        Size = cfg.size,
                        CFrame = CFrame.new(center + cfg.off + Vector3.new(0, 1.9, 0)),
                        Color = Color3.fromRGB(140, 100, 62),
                        Material = Enum.Material.WoodPlanks,
                })
        end

        -- papan klaim
        local board = part({
                Name = "LadangPapan_" .. index,
                Size = Vector3.new(11, 2.6, 0.5),
                CFrame = CFrame.new(center + Vector3.new(0, 3.4, FENCE_HALF + 1)) * CFrame.Angles(0, math.rad(180), 0),
                Color = Color3.fromRGB(92, 62, 38),
                Material = Enum.Material.WoodPlanks,
        })
        part({
                Name = "LadangPapanTiang_" .. index,
                Size = Vector3.new(0.6, 3.4, 0.6),
                CFrame = CFrame.new(center + Vector3.new(0, 1.7, FENCE_HALF + 1)),
                Color = Color3.fromRGB(92, 62, 38),
                Material = Enum.Material.WoodPlanks,
        })

        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Front
        gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        gui.PixelsPerStud = 50
        gui.Parent = board
        local signText = Util.create("TextLabel", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = Color3.fromRGB(255, 209, 102),
                Text = "LADANG " .. index,
        }, gui)

        local claimPrompt = Instance.new("ProximityPrompt")
        claimPrompt.ActionText = priceOfPlot(index) > 0 and "Beli Ladang (Micda)" or "Ambil Alih Ladang"
        claimPrompt.ObjectText = priceOfPlot(index) > 0
                and ("Ladang " .. index .. " - " .. priceOfPlot(index) .. " Micda (lunas di muka)")
                or ("Ladang " .. index .. " (gratis)")
        claimPrompt.MaxActivationDistance = 12
        claimPrompt.HoldDuration = 0.3
        claimPrompt.Parent = board
        claimPrompt.Triggered:Connect(function(player)
                onClaimTriggered(player, plot)
        end)

        -- 4x4 petak tanah
        local tiles = {}
        for row = 1, GRID do
                for col = 1, GRID do
                        local tileIndex = (row - 1) * GRID + col
                        local ox = -(GRID - 1) * TILE_SIZE / 2 + (col - 1) * TILE_SIZE
                        local oz = -(GRID - 1) * TILE_SIZE / 2 + (row - 1) * TILE_SIZE
                        local tilePart = part({
                                Name = "Petak_" .. index .. "_" .. tileIndex,
                                Size = Vector3.new(4.4, 0.5, 4.4),
                                CFrame = CFrame.new(center + Vector3.new(ox, 0.75, oz)),
                                Color = Color3.fromRGB(96, 66, 42),
                                Material = Enum.Material.Ground,
                        })

                        local prompt = Instance.new("ProximityPrompt")
                        prompt.ActionText = "Tanam Bibit"
                        prompt.ObjectText = "Petak Ladang"
                        prompt.MaxActivationDistance = 8
                        prompt.HoldDuration = 0
                        prompt.Enabled = false
                        prompt.RequiresLineOfSight = false
                        prompt.Parent = tilePart

                        local tile = {
                                part = tilePart,
                                prompt = prompt,
                                plotIndex = index,
                                tileIndex = tileIndex,
                                state = "empty",
                                seed = nil,
                                plantedAt = 0,
                                growTime = 0,
                                watered = false,
                                bucket = -1,
                                plant = nil,
                        }
                        prompt.Triggered:Connect(function(player)
                                onTileTriggered(player, tile)
                        end)
                        tiles[tileIndex] = tile
                end
        end

        plot.tiles = tiles
        plot.signText = signText
        plot.claimPrompt = claimPrompt

        -- v20 PAD KIOS: spot stand jualan milik pemilik di pojok ladang
        local pad = part({
                Name = "PadKios_" .. index,
                Size = Vector3.new(4, 0.5, 4),
                CFrame = CFrame.new(center + Vector3.new(-11, 0.75, 10.5)),
                Color = Color3.fromRGB(70, 60, 52),
                Material = Enum.Material.Concrete,
        })
        local kiosPrompt = Instance.new("ProximityPrompt")
        kiosPrompt.ActionText = "Kios Jual"
        kiosPrompt.ObjectText = "Pad Kios Pemain"
        kiosPrompt.MaxActivationDistance = 8
        kiosPrompt.HoldDuration = 0
        kiosPrompt.RequiresLineOfSight = false
        kiosPrompt.Parent = pad

        plot.kiosPad = pad
        plot.kiosPrompt = kiosPrompt

        plots[index] = plot
        updateSign(plot)
        return plot
end

--------------------------------------------------------------------
-- AKSES PLOT (dipakai KiosService; tanpa siklus require)
--------------------------------------------------------------------

function FarmService.getPlot(index: number)
        return plots[index]
end

function FarmService.plotCount(): number
        return PLOT_COUNT
end

--------------------------------------------------------------------
-- TANAM (RemoteFunction dari panel pilih bibit)
--------------------------------------------------------------------

local function onPlantSeed(player: Player, plotIndex: any, tileIndex: any, seedId: any)
        if not DataService.has(player) then
                return { ok = false, msg = "Data belum siap." }
        end
        if type(plotIndex) ~= "number" or type(tileIndex) ~= "number" or type(seedId) ~= "string" then
                return { ok = false, msg = "Permintaan tidak valid." }
        end
        local plot = plots[math.floor(plotIndex)]
        local tile = plot and plot.tiles[math.floor(tileIndex)]
        if not plot or not tile or plot.owner ~= player then
                return { ok = false, msg = "Petak tidak tersedia." }
        end
        if tile.state ~= "empty" then
                return { ok = false, msg = "Petak sudah ditanami." }
        end
        local crop = cropById[seedId]
        if not crop then
                return { ok = false, msg = "Bibit tidak dikenal." }
        end
        if DataService.levelOf(player) < crop.level then
                return { ok = false, msg = "Butuh level " .. crop.level .. " untuk bibit ini." }
        end
        if not DataService.takeItem(player, "seed", seedId, 1) then
                return { ok = false, msg = "Bibit habis. Beli lagi di Toko Bibit!" }
        end

        tile.state = "growing"
        tile.seed = seedId
        tile.plantedAt = time()
        tile.growTime = crop.grow
        tile.watered = false
        tile.bucket = 0
        buildPlantVisual(tile, 0)
        updateTilePrompt(tile)
        DataService.addXP(player, 2)
        DataService.push(player)
        return { ok = true, msg = crop.name .. " ditanam! Kembali setelah ±" .. crop.grow .. " detik." }
end

--------------------------------------------------------------------
-- LOOP PERTUMBUHAN
--------------------------------------------------------------------

function FarmService.startLoop()
        task.spawn(function()
                while true do
                        task.wait(2)
                        for _, plot in plots do
                                if not plot.owner then
                                        continue
                                end
                                for _, tile in plot.tiles do
                                        if tile.state ~= "growing" then
                                                continue
                                        end
                                        local progress = (time() - tile.plantedAt) / math.max(1, tile.growTime)
                                        if progress >= 1 then
                                                tile.state = "ready"
                                                buildPlantVisual(tile, 3)
                                                updateTilePrompt(tile)
                                        else
                                                local bucket = math.floor(progress * 3) -- 0..2
                                                if bucket ~= tile.bucket then
                                                        tile.bucket = bucket
                                                        buildPlantVisual(tile, bucket)
                                                end
                                                local prompt = tile.prompt
                                                if prompt and not prompt.Enabled then
                                                        updateTilePrompt(tile) -- misal pemain baru saja beli kaleng siram
                                                end
                                        end
                                end
                        end
                end
        end)
end

--------------------------------------------------------------------
-- STATE & PEMBERSIHAN
--------------------------------------------------------------------

function FarmService.getPlotState(player: Player)
        for _, plot in plots do
                if plot.owner == player then
                        local tilesOut = {}
                        for i, tile in plot.tiles do
                                local entry: any = { state = tile.state }
                                if tile.state ~= "empty" then
                                        entry.seed = tile.seed
                                        entry.watered = tile.watered
                                        if tile.state == "growing" then
                                                entry.remain = math.max(0, math.ceil(tile.growTime - (time() - tile.plantedAt)))
                                        end
                                end
                                tilesOut[i] = entry
                        end
                        return { claimed = true, index = plot.index, tiles = tilesOut }
                end
        end
        return { claimed = false, tiles = {} }
end

--- Pemain keluar: hasil siap panen otomatis masuk tas,
--- tanaman yang masih tumbuh hangus (ladang dibebaskan).
function FarmService.releasePlot(player: Player)
        for _, plot in plots do
                if plot.owner == player then
                        local harvested = 0
                        for _, tile in plot.tiles do
                                if tile.state == "ready" and tile.seed then
                                        DataService.giveItem(player, "crop", tile.seed, 1)
                                        harvested += 1
                                end
                                tile.state = "empty"
                                tile.seed = nil
                                tile.plantedAt = 0
                                tile.growTime = 0
                                tile.watered = false
                                tile.bucket = -1
                                destroyPlant(tile)
                                updateTilePrompt(tile)
                        end
                        if harvested > 0 then
                                Remotes.get("Notify"):FireClient(player, "Panen Otomatis",
                                        harvested .. " hasil siap panen otomatis masuk tas sebelum kamu pergi.")
                        end
                        plot.owner = nil
                        updateSign(plot)
                end
        end
end

--------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------

function FarmService.init()
        Remotes.get("PlantSeed").OnServerInvoke = onPlantSeed
        -- daftarkan snapshot ladang ke DataService (tanpa siklus require)
        DataService.registerProvider("plot", function(p)
                return FarmService.getPlotState(p)
        end)
end

return FarmService
