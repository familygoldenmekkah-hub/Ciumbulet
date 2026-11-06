local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Layout = require(ReplicatedStorage.Shared.Layout)
local BuildingKit = require(script.Parent.BuildingKit)

local WorldBuilder = {}

local GRASS = Color3.fromRGB(106, 148, 79)
local PATH = Color3.fromRGB(168, 162, 150)
local MARKER_A = Color3.fromRGB(120, 180, 220)
local MARKER_B = Color3.fromRGB(220, 170, 90)
local BUNGA = {
        Color3.fromRGB(232, 96, 84),
        Color3.fromRGB(240, 190, 70),
        Color3.fromRGB(150, 190, 240),
        Color3.fromRGB(226, 120, 200),
        Color3.fromRGB(240, 240, 240),
}

local function groundTop(): number
        return 1
end

local function ensureRoot(): Folder
        local f = Workspace:FindFirstChild("Dunia")
        if not f then
                f = Instance.new("Folder")
                f.Name = "Dunia"
                f.Parent = Workspace
        end
        return f :: Folder
end

local function spawnPad(parent: Instance, pos: Vector3): SpawnLocation
        local spawn = Instance.new("SpawnLocation")
        spawn.Anchored = true
        spawn.Size = Vector3.new(12, 1, 12)
        spawn.Position = pos
        spawn.Color = Color3.fromRGB(235, 200, 110)
        spawn.Material = Enum.Material.SmoothPlastic
        spawn.TopSurface = Enum.SurfaceType.Smooth
        spawn.Duration = 0
        spawn.Enabled = true
        spawn.Parent = parent
        return spawn
end

local function archGate(parent: Instance, x: number, z: number, gt: number, action: string, object: string, onTrigger)
        BuildingKit.part(parent, Vector3.new(2, 10, 2), CFrame.new(x - 12, gt + 5, z), BuildingKit.DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(parent, Vector3.new(2, 10, 2), CFrame.new(x + 12, gt + 5, z), BuildingKit.DARKWOOD, Enum.Material.Wood)
        local beam = BuildingKit.part(parent, Vector3.new(26, 2, 2), CFrame.new(x, gt + 11, z), BuildingKit.DARKWOOD, Enum.Material.Wood)
        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = action
        prompt.ObjectText = object
        prompt.HoldDuration = 0.4
        prompt.MaxActivationDistance = 14
        prompt.RequiresLineOfSight = false
        prompt.Parent = beam
        prompt.Triggered:Connect(function(player)
                onTrigger(player)
        end)
end

local function signBoard(parent: Instance, x: number, z: number, gt: number, text: string)
        BuildingKit.part(parent, Vector3.new(1, 8, 1), CFrame.new(x, gt + 4, z), BuildingKit.DARKWOOD, Enum.Material.Wood)
        local board = BuildingKit.part(parent, Vector3.new(8, 4, 0.5), CFrame.new(x, gt + 10, z), BuildingKit.DARKWOOD, Enum.Material.Wood)
        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Front
        gui.CanvasSize = Vector2.new(400, 200)
        local label = Instance.new("TextLabel")
        label.Name = "NamaLahan"
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 240, 200)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = gui
        gui.Parent = board
        return board
end

local function bedBunga(folder: Instance, x: number, z: number, gt: number, w: number, d: number, bibit: number)
        for _, sx in ipairs({ -1, 1 }) do
                local tepi1 = BuildingKit.part(folder, Vector3.new(w + 0.8, 0.9, 0.5), CFrame.new(x, gt + 0.45, z + sx * d / 2), Color3.fromRGB(168, 160, 148), Enum.Material.Concrete)
                tepi1.CanCollide = false
                local tepi2 = BuildingKit.part(folder, Vector3.new(0.5, 0.9, d + 0.8), CFrame.new(x + sx * w / 2, gt + 0.45, z), Color3.fromRGB(168, 160, 148), Enum.Material.Concrete)
                tepi2.CanCollide = false
        end
        BuildingKit.part(folder, Vector3.new(w, 0.5, d), CFrame.new(x, gt + 0.55, z), Color3.fromRGB(84, 62, 44), Enum.Material.Ground).CanCollide = false
        for i = 0, bibit - 1 do
                local fx = x - w / 2 + (w / bibit) * (i + 0.5)
                local fz = z + (((i % 2) == 0) and -d / 4 or d / 4)
                BuildingKit.part(folder, Vector3.new(0.16, 0.6, 0.16), CFrame.new(fx, gt + 1.05, fz), Color3.fromRGB(74, 128, 60), Enum.Material.Grass).CanCollide = false
                local b = BuildingKit.part(folder, Vector3.new(0.55, 0.55, 0.55), CFrame.new(fx, gt + 1.45, fz), BUNGA[(i + math.floor(x) + math.floor(z)) % #BUNGA + 1], Enum.Material.SmoothPlastic)
                b.Shape = Enum.PartType.Ball
                b.CanCollide = false
        end
end

local function pohonHias(folder: Instance, x: number, z: number, gt: number)
        BuildingKit.part(folder, Vector3.new(1.6, 7, 1.6), CFrame.new(x, gt + 3.5, z), Color3.fromRGB(112, 80, 52), Enum.Material.Wood)
        local a = BuildingKit.part(folder, Vector3.new(6.4, 6.4, 6.4), CFrame.new(x, gt + 8.6, z), Color3.fromRGB(66, 118, 58), Enum.Material.Grass)
        a.Shape = Enum.PartType.Ball
        a.CanCollide = false
        local b = BuildingKit.part(folder, Vector3.new(4.2, 4.2, 4.2), CFrame.new(x + 1.7, gt + 10.4, z + 1.1), Color3.fromRGB(84, 140, 70), Enum.Material.Grass)
        b.Shape = Enum.PartType.Ball
        b.CanCollide = false
        local c = BuildingKit.part(folder, Vector3.new(3.4, 3.4, 3.4), CFrame.new(x - 1.8, gt + 9.9, z - 1.2), Color3.fromRGB(92, 150, 76), Enum.Material.Grass)
        c.Shape = Enum.PartType.Ball
        c.CanCollide = false
end

local function bangkuTaman(folder: Instance, x: number, z: number, gt: number, yaw: number)
        local cf = CFrame.new(x, gt, z) * CFrame.Angles(0, yaw, 0)
        BuildingKit.part(folder, Vector3.new(4.4, 0.4, 1.6), cf * CFrame.new(0, 1.5, 0), BuildingKit.FLOORWOOD, Enum.Material.WoodPlanks)
        BuildingKit.part(folder, Vector3.new(4.4, 1.5, 0.3), cf * CFrame.new(0, 2.4, -0.65), BuildingKit.FLOORWOOD, Enum.Material.WoodPlanks)
        BuildingKit.part(folder, Vector3.new(0.4, 1.5, 1.4), cf * CFrame.new(-1.8, 0.75, 0), BuildingKit.DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(folder, Vector3.new(0.4, 1.5, 1.4), cf * CFrame.new(1.8, 0.75, 0), BuildingKit.DARKWOOD, Enum.Material.Wood)
end

local function tiangBendera(folder: Instance, x: number, z: number, gt: number, arah: number, warnaBendera: Color3)
        BuildingKit.part(folder, Vector3.new(0.4, 9, 0.4), CFrame.new(x, gt + 4.5, z), BuildingKit.DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(folder, Vector3.new(2.2, 1.1, 0.14), CFrame.new(x + arah * 1.3, gt + 8.2, z), warnaBendera, Enum.Material.SmoothPlastic).CanCollide = false
        BuildingKit.part(folder, Vector3.new(1.2, 0.7, 0.14), CFrame.new(x + arah * 1.75, gt + 7.2, z), warnaBendera, Enum.Material.SmoothPlastic).CanCollide = false
end

local function lampuTaman(folder: Instance, x: number, z: number, gt: number)
        BuildingKit.part(folder, Vector3.new(0.5, 3.2, 0.5), CFrame.new(x, gt + 1.6, z), BuildingKit.DARKWOOD, Enum.Material.Wood)
        local kepala = BuildingKit.part(folder, Vector3.new(0.8, 0.8, 0.8), CFrame.new(x, gt + 3.6, z), Color3.fromRGB(255, 224, 178), Enum.Material.Neon)
        kepala.Shape = Enum.PartType.Ball
        kepala.CanCollide = false
        local cahaya = Instance.new("PointLight")
        cahaya.Range = 12
        cahaya.Brightness = 0.45
        cahaya.Color = Color3.fromRGB(255, 224, 178)
        cahaya.Parent = kepala
end

local function lindung(folder: Instance, x: number, z: number, gt: number, panjang: number, yaw: number)
        local cf = CFrame.new(x, gt, z) * CFrame.Angles(0, yaw, 0)
        BuildingKit.part(folder, Vector3.new(panjang, 2.2, 1.6), cf * CFrame.new(0, 1.5, 0), Color3.fromRGB(74, 122, 62), Enum.Material.Grass).CanCollide = false
        BuildingKit.part(folder, Vector3.new(panjang, 0.5, 1.7), cf * CFrame.new(0, 2.75, 0), Color3.fromRGB(88, 140, 72), Enum.Material.Grass).CanCollide = false
end

local function gerbangRambate(folder: Instance, x: number, z: number, gt: number)
        BuildingKit.part(folder, Vector3.new(0.8, 8, 0.8), CFrame.new(x - 6.5, gt + 4, z), BuildingKit.DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(folder, Vector3.new(0.8, 8, 0.8), CFrame.new(x + 6.5, gt + 4, z), BuildingKit.DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(folder, Vector3.new(14.5, 0.8, 1.2), CFrame.new(x, gt + 8.2, z), BuildingKit.DARKWOOD, Enum.Material.Wood)
        for i = -1, 1 do
                local bx = x + i * 4.2
                BuildingKit.part(folder, Vector3.new(0.12, 1.4, 0.12), CFrame.new(bx, gt + 7.1, z), BuildingKit.DARKWOOD, Enum.Material.Wood).CanCollide = false
                local pot = BuildingKit.part(folder, Vector3.new(1.2, 1, 1.2), CFrame.new(bx, gt + 5.9, z), Color3.fromRGB(172, 96, 66), Enum.Material.SmoothPlastic)
                pot.CanCollide = false
                local bunga = BuildingKit.part(folder, Vector3.new(0.9, 0.9, 0.9), CFrame.new(bx, gt + 6.65, z), BUNGA[i + 2], Enum.Material.SmoothPlastic)
                bunga.Shape = Enum.PartType.Ball
                bunga.CanCollide = false
        end
end

local function buildPapan(folder: Instance, x: number, z: number, gt: number, index: number, hooks)
        local pad = BuildingKit.part(folder, Vector3.new(14, 0.2, 3), CFrame.new(x, gt + 0.12, z - 2.5), Color3.fromRGB(235, 200, 110), Enum.Material.SmoothPlastic, 0.25)
        pad.CanCollide = false
        for sx = -1, 1, 2 do
                BuildingKit.part(folder, Vector3.new(1, 9, 1), CFrame.new(x + sx * 6, gt + 4.5, z), BuildingKit.DARKWOOD, Enum.Material.Wood)
        end
        local panel = BuildingKit.part(folder, Vector3.new(14, 5, 0.8), CFrame.new(x, gt + 9.5, z), BuildingKit.DARKWOOD, Enum.Material.Wood)
        local labels = {}
        for _, face in ipairs({ Enum.NormalId.Front, Enum.NormalId.Back }) do
                local gui = Instance.new("SurfaceGui")
                gui.Face = face
                gui.CanvasSize = Vector2.new(560, 200)
                local l = Instance.new("TextLabel")
                l.Size = UDim2.new(1, -16, 0.86, 0)
                l.Position = UDim2.new(0, 8, 0.07, 0)
                l.BackgroundTransparency = 1
                l.Text = "TERTANAM 0/500"
                l.TextColor3 = Color3.fromRGB(255, 226, 140)
                l.TextScaled = true
                l.Font = Enum.Font.GothamBlack
                l.Parent = gui
                gui.Parent = panel
                table.insert(labels, l)
        end
        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Mulai Tanam"
        prompt.ObjectText = "Papan Tanam"
        prompt.HoldDuration = 0.3
        prompt.MaxActivationDistance = 13
        prompt.RequiresLineOfSight = false
        prompt.Parent = panel
        prompt.Triggered:Connect(function(player: Player)
                if hooks and hooks.onPapanPrompt then
                        hooks.onPapanPrompt(player, index)
                end
        end)
        return labels
end

local function buildGudang(folder: Instance, x: number, z: number, gt: number, index: number, hooks)
        local w, d = 22, 18
        local h = 12
        local model = Instance.new("Model")
        model.Name = "GudangPanen_" .. index
        BuildingKit.part(model, Vector3.new(w + 2, 1, d + 2), CFrame.new(0, 0.5, 0), BuildingKit.STONE, Enum.Material.Slate)
        BuildingKit.part(model, Vector3.new(w - 2, 1, d - 2), CFrame.new(0, 1.5, 0), BuildingKit.FLOORWOOD, Enum.Material.WoodPlanks)
        BuildingKit.part(model, Vector3.new(w, h, 1), CFrame.new(0, h / 2 + 1, d / 2 - 0.5), BuildingKit.CREAM)
        BuildingKit.part(model, Vector3.new(1, h, d - 2), CFrame.new(-(w / 2 - 0.5), h / 2 + 1, 0), BuildingKit.CREAM)
        BuildingKit.part(model, Vector3.new(1, h, d - 2), CFrame.new(w / 2 - 0.5, h / 2 + 1, 0), BuildingKit.CREAM)
        local fz = -(d / 2 - 0.5)
        BuildingKit.part(model, Vector3.new(6, h, 1), CFrame.new(-(w / 2 - 3.5), h / 2 + 1, fz), BuildingKit.CREAM)
        BuildingKit.part(model, Vector3.new(6, h, 1), CFrame.new(w / 2 - 3.5, h / 2 + 1, fz), BuildingKit.CREAM)
        BuildingKit.part(model, Vector3.new(10, 4, 1), CFrame.new(0, h - 1, fz), BuildingKit.CREAM)
        for sx = -1, 1, 2 do
                BuildingKit.part(model, Vector3.new(2, h, 2), CFrame.new(sx * (w / 2 - 1), h / 2 + 1, sx * (d / 2 - 1)), BuildingKit.DARKWOOD, Enum.Material.Wood)
        end
        for _, yy in ipairs({ 1.5, h + 0.5 }) do
                BuildingKit.part(model, Vector3.new(w + 2, 1, 0.5), CFrame.new(0, yy, -(d / 2 + 0.75)), BuildingKit.DARKWOOD, Enum.Material.Wood)
                BuildingKit.part(model, Vector3.new(w + 2, 1, 0.5), CFrame.new(0, yy, d / 2 + 0.75), BuildingKit.DARKWOOD, Enum.Material.Wood)
                BuildingKit.part(model, Vector3.new(0.5, 1, d + 2), CFrame.new(-(w / 2 + 0.75), yy, 0), BuildingKit.DARKWOOD, Enum.Material.Wood)
                BuildingKit.part(model, Vector3.new(0.5, 1, d + 2), CFrame.new(w / 2 + 0.75, yy, 0), BuildingKit.DARKWOOD, Enum.Material.Wood)
        end
        BuildingKit.gableRoof(model, w, d, 3, h + 1, BuildingKit.BRICKRED)
        local counter = BuildingKit.part(model, Vector3.new(10, 4, 2), CFrame.new(0, 4, -(d / 2 - 5)), BuildingKit.DARKWOOD, Enum.Material.Wood)
        counter:SetAttribute("MejaGudang", true)
        for sx = -1, 1, 2 do
                local rack = BuildingKit.part(model, Vector3.new(2, 8, 8), CFrame.new(sx * (w / 2 - 4), 6, 2), BuildingKit.DARKWOOD, Enum.Material.Wood)
                rack:SetAttribute("GudangRak", true)
                BuildingKit.part(model, Vector3.new(5.6, 0.3, 7), CFrame.new(sx * (w / 2 - 4), 4.2, 2), BuildingKit.FLOORWOOD, Enum.Material.WoodPlanks).CanCollide = false
                BuildingKit.part(model, Vector3.new(5.6, 0.3, 7), CFrame.new(sx * (w / 2 - 4), 7, 2), BuildingKit.FLOORWOOD, Enum.Material.WoodPlanks).CanCollide = false
                for i = 0, 3 do
                        BuildingKit.part(model, Vector3.new(1.8, 1.5, 1.8), CFrame.new(sx * (w / 2 - 4) - 1.2 + i * 0.9, 5.05, 0.8 + (i % 2)), Color3.fromRGB(150, 116, 74), Enum.Material.WoodPlanks)
                        BuildingKit.part(model, Vector3.new(1.6, 1.3, 1.6), CFrame.new(sx * (w / 2 - 4) - 1 + i * 0.85, 7.8, 1.4 + (i % 2)), Color3.fromRGB(196, 168, 120), Enum.Material.WoodPlanks)
                end
                BuildingKit.part(model, Vector3.new(2.4, 2.4, 2.4), CFrame.new(sx * (w / 2 - 4), 9.6, 2), Color3.fromRGB(150, 116, 74), Enum.Material.WoodPlanks)
        end
        BuildingKit.part(model, Vector3.new(2.4, 2.4, 2.4), CFrame.new(3.6, 3.1, -4.5), Color3.fromRGB(150, 116, 74), Enum.Material.WoodPlanks)
        BuildingKit.part(model, Vector3.new(2.4, 2.4, 2.4), CFrame.new(5.9, 3.1, -4.2), Color3.fromRGB(170, 132, 84), Enum.Material.WoodPlanks)
        BuildingKit.part(model, Vector3.new(2.2, 1.8, 2.2), CFrame.new(4.7, 5.3, -4.4), Color3.fromRGB(196, 168, 120), Enum.Material.WoodPlanks)
        local sackRow = { Color3.fromRGB(150, 108, 62), Color3.fromRGB(96, 128, 72), Color3.fromRGB(196, 168, 120) }
        for i = 0, 2 do
                BuildingKit.part(model, Vector3.new(2.2, 2.4, 1.6), CFrame.new(-4.2 - i * 2.4, 3.2, -4.6), sackRow[i + 1], Enum.Material.Fabric)
        end
        BuildingKit.part(model, Vector3.new(2.4, 3.2, 2.4), CFrame.new(-w / 2 + 3.2, 2.6, -d / 2 + 2.6), Color3.fromRGB(122, 96, 58), Enum.Material.WoodPlanks)
        BuildingKit.part(model, Vector3.new(2.5, 0.3, 2.5), CFrame.new(-w / 2 + 3.2, 4.3, -d / 2 + 2.6), BuildingKit.FLOORWOOD, Enum.Material.WoodPlanks).CanCollide = false
        local papan = BuildingKit.part(model, Vector3.new(14, 3, 0.5), CFrame.new(0, h + 3, -(d / 2 + 0.4)), BuildingKit.DARKWOOD, Enum.Material.Wood)
        local guiPapan = Instance.new("SurfaceGui")
        guiPapan.Face = Enum.NormalId.Front
        guiPapan.CanvasSize = Vector2.new(400, 90)
        local labelPapan = Instance.new("TextLabel")
        labelPapan.Size = UDim2.fromScale(1, 1)
        labelPapan.BackgroundTransparency = 1
        labelPapan.Text = "GUDANG HASIL PANEN"
        labelPapan.TextColor3 = Color3.fromRGB(255, 232, 180)
        labelPapan.TextScaled = true
        labelPapan.Font = Enum.Font.GothamBold
        labelPapan.Parent = guiPapan
        guiPapan.Parent = papan
        BuildingKit.lamp(model, 0, h + 1, 0)
        BuildingKit.lamp(model, -6, h + 1, 4)
        BuildingKit.lamp(model, 6, h + 1, 4)
        model.WorldPivot = CFrame.new(0, 0, 0)
        model:PivotTo(CFrame.new(x, gt, z))
        model.Parent = folder
        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Buka Gudang"
        prompt.ObjectText = "Meja Gudang"
        prompt.HoldDuration = 0.3
        prompt.MaxActivationDistance = 12
        prompt.RequiresLineOfSight = false
        prompt.Parent = counter
        prompt.Triggered:Connect(function(player: Player)
                if hooks and hooks.onGudangPrompt then
                        hooks.onGudangPrompt(player, index)
                end
        end)
        if hooks and hooks.setGudangPoint then
                hooks.setGudangPoint(index, (model:GetPivot() * CFrame.new(0, 0, -(d / 2 - 5))).Position + Vector3.new(0, 3, 0))
        end
        return model
end

function WorldBuilder.buildHub(hooks)
        local root = ensureRoot()
        local gt = 0

        BuildingKit.part(root, Vector3.new(400, 1, 400), CFrame.new(0, -0.5, 0), GRASS, Enum.Material.Grass)
        BuildingKit.part(root, Vector3.new(10, 0.2, 90), CFrame.new(0, gt + 0.1, 10), PATH, Enum.Material.Concrete)

        local spawn = spawnPad(root, Vector3.new(0, gt + 0.5, 44))
        if hooks and hooks.registerKota then
                hooks.registerKota(spawn)
        end
        if hooks and hooks.registerUmum then
                hooks.registerUmum(spawn)
        end

        archGate(root, 0, 20, gt, "Dunia-ku", "Gerbang Dunia", function(player: Player)
                if hooks and hooks.onGerbangDunia then
                        hooks.onGerbangDunia(player)
                end
        end)

        signBoard(root, -30, 6, gt, "PUSAT KOTA")

        local toko = BuildingKit.buildToko(root)
        toko:PivotTo(CFrame.new(0, gt, -60) * CFrame.Angles(0, math.rad(180), 0))
        for _, p in ipairs(toko:GetDescendants()) do
                if p:IsA("BasePart") and p.Size == Vector3.new(12, 4, 3) then
                        if hooks and hooks.setShopPoint then
                                hooks.setShopPoint(p.Position)
                        end
                        if hooks and hooks.onShopPrompt then
                                local prompt = Instance.new("ProximityPrompt")
                                prompt.ActionText = "Toko Benih"
                                prompt.ObjectText = "Kasir"
                                prompt.HoldDuration = 0.3
                                prompt.MaxActivationDistance = 12
                                prompt.RequiresLineOfSight = false
                                prompt.Parent = p
                                prompt.Triggered:Connect(function(player: Player)
                                        hooks.onShopPrompt(player)
                                end)
                        end
                elseif p:IsA("BasePart") and p:GetAttribute("Rak") == true then
                        if hooks and hooks.onShopPrompt then
                                local prompt = Instance.new("ProximityPrompt")
                                prompt.ActionText = "Beli Benih"
                                prompt.ObjectText = "Rak Benih"
                                prompt.HoldDuration = 0.3
                                prompt.MaxActivationDistance = 10
                                prompt.RequiresLineOfSight = false
                                prompt.Parent = p
                                prompt.Triggered:Connect(function(player: Player)
                                        hooks.onShopPrompt(player)
                                end)
                        end
                end
        end

        BuildingKit.streetLamp(root, 8, gt, 32)
        BuildingKit.streetLamp(root, -8, gt, 32)
        BuildingKit.streetLamp(root, 8, gt, -30)
        BuildingKit.streetLamp(root, -8, gt, -30)

        for _, sx in ipairs({ -1, 1 }) do
                lindung(root, sx * 7.4, 48, gt, 5, math.pi / 2)
                lindung(root, sx * 7.4, 44, gt, 5, math.pi / 2)
                lindung(root, sx * 7.4, 20, gt, 5, math.pi / 2)
                lindung(root, sx * 7.4, 16, gt, 5, math.pi / 2)
                lindung(root, sx * 7.4, -6, gt, 5, math.pi / 2)
                lindung(root, sx * 7.4, -10, gt, 5, math.pi / 2)
                lindung(root, sx * 7.4, -26, gt, 5, math.pi / 2)
                lindung(root, sx * 7.4, -35, gt, 5, math.pi / 2)
        end
        bedBunga(root, -8, 40, gt, 5, 2.4, 4)
        bedBunga(root, 8, 24, gt, 5, 2.4, 4)
        bedBunga(root, -8, 12, gt, 5, 2.4, 5)
        bedBunga(root, 8, 0, gt, 5, 2.4, 4)
        bedBunga(root, -8, -14, gt, 5, 2.4, 5)
        bedBunga(root, 8, -24, gt, 5, 2.4, 4)
        pohonHias(root, -13, 36, gt)
        pohonHias(root, 13, 36, gt)
        pohonHias(root, -13, -12, gt)
        pohonHias(root, 13, -12, gt)
        bangkuTaman(root, -7.5, -40, gt, math.pi / 2)
        bangkuTaman(root, 7.5, -40, gt, -math.pi / 2)
        tiangBendera(root, -5.5, -43, gt, -1, MARKER_A)
        tiangBendera(root, 5.5, -43, gt, 1, MARKER_B)
        lampuTaman(root, -9.5, 46, gt)
        lampuTaman(root, 9.5, 46, gt)
        lampuTaman(root, -9.5, -20, gt)
        lampuTaman(root, 9.5, -20, gt)
        gerbangRambate(root, 0, -38, gt)

        return root
end

function WorldBuilder.buildLahan(hooks, index: number, namaPemilik: string): Model
        local root = ensureRoot()
        local model = Instance.new("Model")
        model.Name = "Zona_" .. index
        local folder = Instance.new("Folder")
        folder.Name = "Isi_" .. index
        folder.Parent = model
        local ox, oz = Layout.cellOrigin(index)
        local dX = Layout.duniaOffsetX()
        local gt = groundTop()

        BuildingKit.part(folder, Vector3.new(Layout.SizeX, 1, Layout.SizeZ), CFrame.new(dX + ox + Layout.SizeX / 2, gt - 0.5, oz + Layout.SizeZ / 2), GRASS, Enum.Material.Grass)

        BuildingKit.part(folder, Vector3.new(Layout.SizeX, 0.2, 10), CFrame.new(dX + ox + Layout.SizeX / 2, gt + 0.1, oz + 25), PATH, Enum.Material.Concrete)
        BuildingKit.part(folder, Vector3.new(Layout.SizeX, 0.2, 10), CFrame.new(dX + ox + Layout.SizeX / 2, gt + 0.1, oz + 155), PATH, Enum.Material.Concrete)
        BuildingKit.part(folder, Vector3.new(10, 0.2, 120), CFrame.new(dX + ox + 165, gt + 0.1, oz + 90), PATH, Enum.Material.Concrete)
        BuildingKit.part(folder, Vector3.new(10, 0.2, 20), CFrame.new(dX + ox + 120, gt + 0.1, oz + 10), PATH, Enum.Material.Concrete)

        BuildingKit.fenceLine(folder, dX + ox, oz, dX + ox, oz + Layout.SizeZ, gt)
        BuildingKit.fenceLine(folder, dX + ox + Layout.SizeX, oz, dX + ox + Layout.SizeX, oz + Layout.SizeZ, gt)
        BuildingKit.fenceLine(folder, dX + ox, oz + Layout.SizeZ, dX + ox + Layout.SizeX, oz + Layout.SizeZ, gt)
        BuildingKit.fenceLine(folder, dX + ox, oz, dX + ox + 108, oz, gt)
        BuildingKit.fenceLine(folder, dX + ox + 132, oz, dX + ox + Layout.SizeX, oz, gt)

        archGate(folder, dX + ox + 120, oz, gt, "Pulang ke Kota", "Gerbang Dunia", function(player: Player)
                if hooks and hooks.onPulang then
                        hooks.onPulang(player)
                end
        end)

        signBoard(folder, dX + ox + 96, oz + 8, gt, "Dunia " .. (namaPemilik or "Petani"))

        BuildingKit.streetLamp(folder, dX + ox + 104, gt, oz + 24)
        BuildingKit.streetLamp(folder, dX + ox + 166, gt, oz + 156)
        BuildingKit.streetLamp(folder, dX + ox + 40, gt, oz + 210)

        local mesin = BuildingKit.buildMesinSemai(folder, index, hooks)
        mesin:PivotTo(CFrame.new(dX + ox + 185, gt, oz + 50))
        if hooks and hooks.registerMesin then
                hooks.registerMesin(index, mesin)
        end

        BuildingKit.marker(folder, dX + ox + 185, oz + 85, gt, 30, 30, MARKER_A)
        BuildingKit.marker(folder, dX + ox + 195, oz + 125, gt, 50, 30, MARKER_A)
        BuildingKit.marker(folder, dX + ox + 40, oz + 185, gt, 40, 40, MARKER_B)
        BuildingKit.marker(folder, dX + ox + 82, oz + 177, gt, 24, 24, MARKER_B)
        BuildingKit.marker(folder, dX + ox + 112, oz + 177, gt, 24, 24, MARKER_B)
        BuildingKit.marker(folder, dX + ox + 142, oz + 177, gt, 24, 24, MARKER_B)
        BuildingKit.marker(folder, dX + ox + 172, oz + 177, gt, 24, 24, MARKER_B)

        local labelPapan = buildPapan(folder, dX + ox + 85, oz + 18, gt, index, hooks)
        if hooks and hooks.registerBoard then
                hooks.registerBoard(index, labelPapan, Vector3.new(dX + ox + 85, gt + 6, oz + 18))
        end
        buildGudang(folder, dX + ox + 205, oz + 185, gt, index, hooks)

        model.Parent = root
        return model
end

return WorldBuilder
