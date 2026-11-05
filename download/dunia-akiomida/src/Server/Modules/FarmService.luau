local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Remotes)
local Util = require(ReplicatedStorage.Shared.Util)
local CropConfig = require(ReplicatedStorage.Shared.CropConfig)
local TasLogic = require(ReplicatedStorage.Shared.TasLogic)

local DataService = require(script.Parent.DataService)

local FarmService = {}

local COLS = 25
local ROWS = 20
local PLOT_COUNT = COLS * ROWS
local PLOT_SIZE = 3.4
local GROW = CropConfig.GrowTime

local fields: { [number]: any } = {}
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

local function part(props, parent): Part
        local p = Instance.new("Part")
        p.Anchored = true
        p.TopSurface = Enum.SurfaceType.Smooth
        p.BottomSurface = Enum.SurfaceType.Smooth
        for k, v in props do
                (p :: any)[k] = v
        end
        p.Parent = parent or world()
        return p
end

local function fieldFolder(index: number): Folder
        local f = world():FindFirstChild("Kebun" .. index) :: Folder?
        if not f then
                f = Instance.new("Folder")
                f.Name = "Kebun" .. index
                f.Parent = world()
        end
        return f
end

function FarmService.plotCount(): number
        return PLOT_COUNT
end

function FarmService.getField(index: number)
        return fields[index]
end

function FarmService.isOwner(player: Player, index: number): boolean
        local field = fields[index]
        return field ~= nil and field.owner == player
end

local function plotCenter(field, plotNo: number): Vector3
        local col = (plotNo - 1) % COLS
        local row = math.floor((plotNo - 1) / COLS)
        return field.origin + Vector3.new(col * PLOT_SIZE, 0, row * PLOT_SIZE)
end

local function plotState(state: { crop: string?, at: number? }): number
        if not state or not state.crop then
                return 0
        end
        if os.clock() - (state.at or 0) >= GROW then
                return 2
        end
        return 1
end

local function refreshPlot(field, plotNo: number)
        local partPlot = field.parts[plotNo]
        if not partPlot then
                return
        end
        local st = field.plots[plotNo]
        local state = plotState(st)
        partPlot:SetAttribute("State", state)
        partPlot:SetAttribute("Crop", st and st.crop or "")
        local model = field.plants[plotNo]
        if state == 0 then
                if model then
                        model:Destroy()
                        field.plants[plotNo] = nil
                end
                return
        end
        local crop = CropConfig.byId(st.crop or "")
        local color = crop and Color3.fromRGB(crop.color[1], crop.color[2], crop.color[3]) or Color3.fromRGB(120, 180, 90)
        if not model then
                model = Instance.new("Part")
                model.Name = "Tanaman" .. plotNo
                model.Anchored = true
                model.CanCollide = false
                model.CanTouch = false
                model.CastShadow = false
                model.Shape = Enum.PartType.Ball
                model.Material = Enum.Material.Grass
                model.Parent = field.folder
                field.plants[plotNo] = model
        end
        local size = state == 2 and 1.9 or 1.1
        model.Size = Vector3.new(size, size * 1.25, size)
        model.Color = color
        model.CFrame = CFrame.new(plotCenter(field, plotNo) + Vector3.new(0, (state == 2 and 1.35 or 0.8), 0))
end

function FarmService.buildField(index: number, center: Vector3)
        local folder = fieldFolder(index)
        local field = fields[index]
        if field then
                return field
        end
        field = {
                index = index,
                owner = nil,
                origin = center - Vector3.new((COLS - 1) * PLOT_SIZE / 2, 0, (ROWS - 1) * PLOT_SIZE / 2),
                plots = {},
                parts = {},
                plants = {},
                folder = folder,
        }
        fields[index] = field

        part({
                Name = "KebunDasar" .. index,
                Size = Vector3.new(COLS * PLOT_SIZE + 4, 0.3, ROWS * PLOT_SIZE + 4),
                CFrame = CFrame.new(center.X, 0.15, center.Z),
                Color = Color3.fromRGB(122, 94, 66),
                Material = Enum.Material.Ground,
        }, folder)

        for plotNo = 1, PLOT_COUNT do
                local pos = plotCenter(field, plotNo)
                local soil = part({
                        Name = "Petak" .. plotNo,
                        Size = Vector3.new(PLOT_SIZE - 0.5, 0.36, PLOT_SIZE - 0.5),
                        CFrame = CFrame.new(pos.X, 0.42, pos.Z),
                        Color = Color3.fromRGB(96, 72, 50),
                        Material = Enum.Material.Ground,
                }, folder)
                field.parts[plotNo] = soil
        end

        local boardPos = center + Vector3.new(COLS * PLOT_SIZE / 2 + 4, 0, -ROWS * PLOT_SIZE / 2 + 8)
        part({
                Name = "KebunPapanTiang",
                Size = Vector3.new(0.7, 3.2, 0.7),
                CFrame = CFrame.new(boardPos + Vector3.new(0, 1.6, 0)) * CFrame.Angles(0, math.rad(90), 0),
                Color = Color3.fromRGB(96, 66, 38),
                Material = Enum.Material.WoodPlanks,
        }, folder)
        local board = part({
                Name = "KebunPapan",
                Size = Vector3.new(10, 2.8, 0.5),
                CFrame = CFrame.new(boardPos + Vector3.new(0, 4.6, 0)) * CFrame.Angles(0, math.rad(90), 0),
                Color = Color3.fromRGB(96, 66, 38),
                Material = Enum.Material.WoodPlanks,
        }, folder)
        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Front
        gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        gui.PixelsPerStud = 50
        gui.Parent = board
        Util.create("TextLabel", {
                Size = UDim2.fromScale(1, 0.6),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = Color3.fromRGB(255, 226, 150),
                Text = "KEBUN " .. PLOT_COUNT .. " PETAK",
        }, gui)
        Util.create("TextLabel", {
                Position = UDim2.fromScale(0, 0.6),
                Size = UDim2.fromScale(1, 0.4),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                TextScaled = true,
                TextColor3 = Color3.fromRGB(210, 214, 224),
                Text = "Tanam & panen di sini",
        }, gui)
        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Buka Kebun"
        prompt.ObjectText = "Kebun " .. PLOT_COUNT .. " Petak"
        prompt.MaxActivationDistance = 10
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.Parent = board
        prompt.Triggered:Connect(function(player: Player)
                if FarmService.isOwner(player, index) then
                        Remotes.get("OpenFarm"):FireClient(player, index)
                else
                        Remotes.get("Notify"):FireClient(player, "Kebun Orang Lain", "Kebun ini bukan milikmu. Setiap pemain punya satu lahan sendiri!")
                end
        end)

        for plotNo = 1, PLOT_COUNT do
                refreshPlot(field, plotNo)
        end
        return field
end

function FarmService.claimFieldFor(player: Player, index: number)
        local field = fields[index]
        if not field then
                return false
        end
        field.owner = player
        for plotNo = 1, PLOT_COUNT do
                field.plots[plotNo] = nil
                refreshPlot(field, plotNo)
        end
        return true
end

local function counts(field)
        local kosong, tumbuh, siap = 0, 0, 0
        for plotNo = 1, PLOT_COUNT do
                local st = plotState(field.plots[plotNo])
                if st == 0 then
                        kosong += 1
                elseif st == 1 then
                        tumbuh += 1
                else
                        siap += 1
                end
        end
        return kosong, tumbuh, siap
end

local function statesArray(field): { number }
        local out = table.create(PLOT_COUNT)
        for plotNo = 1, PLOT_COUNT do
                out[plotNo] = plotState(field.plots[plotNo])
        end
        return out
end

local function snapshot(player: Player, index: number)
        local field = fields[index]
        if not field or field.owner ~= player then
                return nil
        end
        local kosong, tumbuh, siap = counts(field)
        return {
                lahan = index,
                total = PLOT_COUNT,
                kosong = kosong,
                tumbuh = tumbuh,
                siap = siap,
                states = statesArray(field),
        }
end

local function actionPlant(player: Player, index: number, plotNo: number, seedId: string)
        local field = fields[index]
        if not field or field.owner ~= player then
                return { ok = false, msg = "Kebun ini bukan milikmu." }
        end
        if not CropConfig.byId(seedId) then
                return { ok = false, msg = "Benih tidak dikenal." }
        end
        if field.plots[plotNo] and field.plots[plotNo].crop then
                return { ok = false, msg = "Petak itu masih tertanam." }
        end
        if DataService.countItem(player, "seed", seedId) < 1 then
                return { ok = false, msg = "Benih " .. CropConfig.nameOf(seedId) .. " habis di tas." }
        end
        DataService.takeItem(player, "seed", seedId, 1)
        field.plots[plotNo] = { crop = seedId, at = os.clock() }
        refreshPlot(field, plotNo)
        DataService.push(player)
        return { ok = true, msg = CropConfig.nameOf(seedId) .. " ditanam di petak " .. plotNo .. "! Tumbuh dalam " .. GROW .. " detik." }
end

local function actionPlantAll(player: Player, index: number, seedId: string)
        local field = fields[index]
        if not field or field.owner ~= player then
                return { ok = false, msg = "Kebun ini bukan milikmu." }
        end
        if not CropConfig.byId(seedId) then
                return { ok = false, msg = "Benih tidak dikenal." }
        end
        local stock = DataService.countItem(player, "seed", seedId)
        if stock < 1 then
                return { ok = false, msg = "Benih " .. CropConfig.nameOf(seedId) .. " habis di tas." }
        end
        local planted = 0
        for plotNo = 1, PLOT_COUNT do
                if planted >= stock then
                        break
                end
                local st = field.plots[plotNo]
                if not st or not st.crop then
                        field.plots[plotNo] = { crop = seedId, at = os.clock() }
                        refreshPlot(field, plotNo)
                        planted += 1
                end
        end
        if planted == 0 then
                return { ok = false, msg = "Semua petak masih tertanam." }
        end
        DataService.takeItem(player, "seed", seedId, planted)
        DataService.push(player)
        return { ok = true, msg = planted .. " benih " .. CropConfig.nameOf(seedId) .. " ditanam sekaligus!" }
end

local function actionHarvest(player: Player, index: number, plotNo: number)
        local field = fields[index]
        if not field or field.owner ~= player then
                return { ok = false, msg = "Kebun ini bukan milikmu." }
        end
        local st = field.plots[plotNo]
        if not st or not st.crop then
                return { ok = false, msg = "Petak itu kosong." }
        end
        if plotState(st) ~= 2 then
                return { ok = false, msg = "Belum siap panen! Tunggu " .. GROW .. " detik." }
        end
        local yield = math.random(CropConfig.YieldMin, CropConfig.YieldMax)
        local seeds, crops = DataService.tasTables(player)
        local room = TasLogic.roomFor(seeds, crops, "crop", st.crop, yield)
        if room <= 0 then
                return { ok = false, msg = "TAS PENUH! Jual hasil panenmu di Koperasi dulu." }
        end
        DataService.giveItem(player, "crop", st.crop, room)
        field.plots[plotNo] = nil
        refreshPlot(field, plotNo)
        DataService.push(player)
        return { ok = true, msg = "Panen " .. room .. "x " .. CropConfig.nameOf(st.crop) .. "!" }
end

local function actionHarvestAll(player: Player, index: number)
        local field = fields[index]
        if not field or field.owner ~= player then
                return { ok = false, msg = "Kebun ini bukan milikmu." }
        end
        local totals: { [string]: number } = {}
        local fullBag = false
        for plotNo = 1, PLOT_COUNT do
                local st = field.plots[plotNo]
                if st and st.crop and plotState(st) == 2 then
                        local yield = math.random(CropConfig.YieldMin, CropConfig.YieldMax)
                        local seeds, crops = DataService.tasTables(player)
                        local room = TasLogic.roomFor(seeds, crops, "crop", st.crop, yield)
                        if room <= 0 then
                                fullBag = true
                                continue
                        end
                        DataService.giveItem(player, "crop", st.crop, room)
                        totals[st.crop] = (totals[st.crop] or 0) + room
                        field.plots[plotNo] = nil
                        refreshPlot(field, plotNo)
                end
        end
        local parts = {}
        local totalItems = 0
        for id, n in pairs(totals) do
                table.insert(parts, n .. "x " .. CropConfig.nameOf(id))
                totalItems += n
        end
        table.sort(parts)
        DataService.push(player)
        if totalItems == 0 then
                if fullBag then
                        return { ok = false, msg = "TAS PENUH! Jual hasil panenmu di Koperasi dulu." }
                end
                return { ok = false, msg = "Belum ada tanaman yang siap panen." }
        end
        local msg = "Panen raya: " .. table.concat(parts, ", ")
        if fullBag then
                msg ..= " (tas penuh, sebagian petak tersisa)"
        end
        return { ok = true, msg = msg }
end

function FarmService.init()
        Remotes.get("FarmAct").OnServerInvoke = function(player, payload)
                if not DataService.has(player) or type(payload) ~= "table" then
                        return { ok = false, msg = "Permintaan tidak valid." }
                end
                local index = tonumber(payload.lahan) or 0
                local action = payload.action
                if action == "info" then
                        local snap = snapshot(player, index)
                        if not snap then
                                return { ok = false, msg = "Kebun ini bukan milikmu." }
                        end
                        return { ok = true, farm = snap }
                elseif action == "plant" then
                        return actionPlant(player, index, tonumber(payload.plot) or 0, tostring(payload.seed or ""))
                elseif action == "plantAll" then
                        return actionPlantAll(player, index, tostring(payload.seed or ""))
                elseif action == "harvest" then
                        return actionHarvest(player, index, tonumber(payload.plot) or 0)
                elseif action == "harvestAll" then
                        return actionHarvestAll(player, index)
                end
                return { ok = false, msg = "Aksi tidak dikenal." }
        end
        DataService.registerProvider("farm", function(player: Player)
                local homeId = DataService.getHomeId(player)
                if homeId < 1 then
                        return { lahan = 0 }
                end
                local snap = snapshot(player, homeId)
                if not snap then
                        return { lahan = homeId, total = PLOT_COUNT, kosong = PLOT_COUNT, tumbuh = 0, siap = 0, states = {} }
                end
                return snap
        end)
end

function FarmService.startLoop()
        task.spawn(function()
                while true do
                        task.wait(1)
                        for _, field in pairs(fields) do
                                for plotNo = 1, PLOT_COUNT do
                                        local st = field.plots[plotNo]
                                        if st and st.crop then
                                                local attr = field.parts[plotNo] and field.parts[plotNo]:GetAttribute("State")
                                                if attr ~= plotState(st) then
                                                        refreshPlot(field, plotNo)
                                                end
                                        end
                                end
                        end
                end
        end)
end

return FarmService
