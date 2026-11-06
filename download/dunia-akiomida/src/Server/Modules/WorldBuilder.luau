local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Layout = require(ReplicatedStorage.Shared.Layout)
local BuildingKit = require(script.Parent.BuildingKit)

local WorldBuilder = {}

local GRASS = Color3.fromRGB(106, 148, 79)
local PATH = Color3.fromRGB(168, 162, 150)
local MARKER_A = Color3.fromRGB(120, 180, 220)
local MARKER_B = Color3.fromRGB(220, 170, 90)

local function groundTop(): number
        return 1
end

local function spawnPad(parent: Instance, pos: Vector3, enabled: boolean): SpawnLocation
        local spawn = Instance.new("SpawnLocation")
        spawn.Anchored = true
        spawn.Size = Vector3.new(12, 1, 12)
        spawn.Position = pos
        spawn.Color = Color3.fromRGB(235, 200, 110)
        spawn.Material = Enum.Material.SmoothPlastic
        spawn.TopSurface = Enum.SurfaceType.Smooth
        spawn.Duration = 0
        spawn.Enabled = enabled
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

function WorldBuilder.buildHub(hooks)
        local root = Instance.new("Folder")
        root.Name = "Dunia"
        root.Parent = Workspace
        local gt = 0

        BuildingKit.part(root, Vector3.new(400, 1, 400), CFrame.new(0, -0.5, 0), GRASS, Enum.Material.Grass)
        BuildingKit.part(root, Vector3.new(10, 0.2, 90), CFrame.new(0, gt + 0.1, 10), PATH, Enum.Material.Concrete)

        local spawn = spawnPad(root, Vector3.new(0, gt + 0.5, 44), true)
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
        local kasir
        for _, p in ipairs(toko:GetDescendants()) do
                if p:IsA("BasePart") and p.Size == Vector3.new(12, 4, 3) then
                        kasir = p
                        break
                end
        end
        if kasir then
                if hooks and hooks.setShopPoint then
                        hooks.setShopPoint(kasir.Position)
                end
                if hooks and hooks.onShopPrompt then
                        local prompt = Instance.new("ProximityPrompt")
                        prompt.ActionText = "Toko Benih"
                        prompt.ObjectText = "Kasir"
                        prompt.HoldDuration = 0.3
                        prompt.MaxActivationDistance = 12
                        prompt.RequiresLineOfSight = false
                        prompt.Parent = kasir
                        prompt.Triggered:Connect(function(player: Player)
                                hooks.onShopPrompt(player)
                        end)
                end
        end

        local meja = BuildingKit.buildSemai(root)
        meja:PivotTo(CFrame.new(56, gt, 20))
        local tablePart
        for _, p in ipairs(meja:GetDescendants()) do
                if p:IsA("BasePart") and p.Size == Vector3.new(12, 4, 4) then
                        tablePart = p
                        break
                end
        end
        if tablePart then
                if hooks and hooks.setCombinePoint then
                        hooks.setCombinePoint(tablePart.Position + Vector3.new(0, 2, 0))
                end
                if hooks and hooks.onGabung then
                        local prompt = Instance.new("ProximityPrompt")
                        prompt.ActionText = "Gabung Benih"
                        prompt.ObjectText = "Meja Gabung"
                        prompt.HoldDuration = 0.3
                        prompt.MaxActivationDistance = 12
                        prompt.RequiresLineOfSight = false
                        prompt.Parent = tablePart
                        prompt.Triggered:Connect(function(player: Player)
                                hooks.onGabung(player)
                        end)
                end
        end

        BuildingKit.streetLamp(root, 8, gt, 32)
        BuildingKit.streetLamp(root, -8, gt, 32)
        BuildingKit.streetLamp(root, 8, gt, -30)
        BuildingKit.streetLamp(root, -8, gt, -30)

        return root
end

function WorldBuilder.buildDunia(hooks, namaPemilik: string)
        local root = Instance.new("Folder")
        root.Name = "Dunia"
        root.Parent = Workspace

        local lahanArea = BuildingKit.part(root, Vector3.new(1440, 1, 560), CFrame.new(680, -0.5, 250), GRASS, Enum.Material.Grass)
        lahanArea.Name = "TanahLahan"

        WorldBuilder.buildLahan(root, 1, hooks, namaPemilik)
        return root
end

function WorldBuilder.buildLahan(root: Folder, index: number, hooks, namaPemilik: string?)
        local ox, oz = Layout.cellOrigin(index)
        local folder = Instance.new("Folder")
        folder.Name = "Lahan_" .. index
        folder.Parent = root
        local gt = groundTop()

        BuildingKit.part(folder, Vector3.new(Layout.SizeX, 1, Layout.SizeZ), CFrame.new(ox + Layout.SizeX / 2, gt - 0.5, oz + Layout.SizeZ / 2), GRASS, Enum.Material.Grass)

        BuildingKit.part(folder, Vector3.new(Layout.SizeX, 0.2, 10), CFrame.new(ox + Layout.SizeX / 2, gt + 0.1, oz + 25), PATH, Enum.Material.Concrete)
        BuildingKit.part(folder, Vector3.new(Layout.SizeX, 0.2, 10), CFrame.new(ox + Layout.SizeX / 2, gt + 0.1, oz + 155), PATH, Enum.Material.Concrete)
        BuildingKit.part(folder, Vector3.new(10, 0.2, 120), CFrame.new(ox + 165, gt + 0.1, oz + 90), PATH, Enum.Material.Concrete)
        BuildingKit.part(folder, Vector3.new(10, 0.2, 20), CFrame.new(ox + 120, gt + 0.1, oz + 10), PATH, Enum.Material.Concrete)

        BuildingKit.fenceLine(folder, ox, oz, ox, oz + Layout.SizeZ, gt)
        BuildingKit.fenceLine(folder, ox + Layout.SizeX, oz, ox + Layout.SizeX, oz + Layout.SizeZ, gt)
        BuildingKit.fenceLine(folder, ox, oz + Layout.SizeZ, ox + Layout.SizeX, oz + Layout.SizeZ, gt)
        BuildingKit.fenceLine(folder, ox, oz, ox + 108, oz, gt)
        BuildingKit.fenceLine(folder, ox + 132, oz, ox + Layout.SizeX, oz, gt)

        archGate(folder, ox + 120, oz, gt, "Pulang ke Kota", "Gerbang Dunia", function(player: Player)
                if hooks and hooks.onPulang then
                        hooks.onPulang(player)
                end
        end)

        signBoard(folder, ox + 96, oz + 8, gt, "Dunia " .. (namaPemilik or "Petani"))

        local spawn = spawnPad(folder, Vector3.new(ox + 120, gt + 0.5, oz + 12), false)
        if hooks and hooks.registerSpawn then
                hooks.registerSpawn(index, spawn)
        end
        if hooks and hooks.registerUmum then
                hooks.registerUmum(spawn)
        end

        BuildingKit.streetLamp(folder, ox + 104, gt, oz + 24)
        BuildingKit.streetLamp(folder, ox + 166, gt, oz + 156)
        BuildingKit.streetLamp(folder, ox + 40, gt, oz + 210)

        local semai = BuildingKit.buildSemai(folder)
        semai:PivotTo(CFrame.new(ox + 185, gt, oz + 50))
        local tablePart
        for _, p in ipairs(semai:GetDescendants()) do
                if p:IsA("BasePart") and p.Size == Vector3.new(12, 4, 4) then
                        tablePart = p
                        break
                end
        end
        if tablePart then
                if hooks and hooks.registerTable then
                        hooks.registerTable(index, tablePart.Position + Vector3.new(0, 2, 0))
                end
                if hooks and hooks.onSemaiPrompt then
                        local prompt = Instance.new("ProximityPrompt")
                        prompt.ActionText = "Semai Panen"
                        prompt.ObjectText = "Meja Hasil"
                        prompt.HoldDuration = 0.3
                        prompt.MaxActivationDistance = 12
                        prompt.RequiresLineOfSight = false
                        prompt.Parent = tablePart
                        tablePart:SetAttribute("LahanIdx", index)
                        prompt.Triggered:Connect(function(player: Player)
                                hooks.onSemaiPrompt(player, index)
                        end)
                end
        end

        BuildingKit.marker(folder, ox + 185, oz + 85, gt, 30, 30, MARKER_A)
        BuildingKit.marker(folder, ox + 195, oz + 125, gt, 50, 30, MARKER_A)
        BuildingKit.marker(folder, ox + 40, oz + 185, gt, 40, 40, MARKER_B)
        BuildingKit.marker(folder, ox + 82, oz + 177, gt, 24, 24, MARKER_B)
        BuildingKit.marker(folder, ox + 112, oz + 177, gt, 24, 24, MARKER_B)
        BuildingKit.marker(folder, ox + 142, oz + 177, gt, 24, 24, MARKER_B)
        BuildingKit.marker(folder, ox + 172, oz + 177, gt, 24, 24, MARKER_B)

        return folder
end

return WorldBuilder
