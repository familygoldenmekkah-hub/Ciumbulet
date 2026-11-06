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

function WorldBuilder.build(hooks)
        local root = Instance.new("Folder")
        root.Name = "Dunia"
        root.Parent = Workspace

        local lahanArea = BuildingKit.part(root, Vector3.new(1440, 1, 560), CFrame.new(680, -0.5, 250), GRASS, Enum.Material.Grass)
        lahanArea.Name = "TanahLahan"

        for i = 1, Layout.LahanCount do
                WorldBuilder.buildLahan(root, i, hooks)
        end

        local umum = Instance.new("SpawnLocation")
        umum.Anchored = true
        umum.Size = Vector3.new(12, 1, 12)
        umum.Position = Vector3.new(-60, 0.5, 110)
        umum.Color = Color3.fromRGB(190, 190, 196)
        umum.Material = Enum.Material.SmoothPlastic
        umum.TopSurface = Enum.SurfaceType.Smooth
        umum.Duration = 0
        umum.Enabled = true
        umum.Parent = root
        if hooks and hooks.registerUmum then
                hooks.registerUmum(umum)
        end

        WorldBuilder.buildKota(root, hooks)
        return root
end

function WorldBuilder.buildLahan(root: Folder, index: number, hooks)
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

        local postL = BuildingKit.part(folder, Vector3.new(2, 10, 2), CFrame.new(ox + 108, gt + 5, oz), BuildingKit.DARKWOOD, Enum.Material.Wood)
        local postR = BuildingKit.part(folder, Vector3.new(2, 10, 2), CFrame.new(ox + 132, gt + 5, oz), BuildingKit.DARKWOOD, Enum.Material.Wood)
        local beam = BuildingKit.part(folder, Vector3.new(26, 2, 2), CFrame.new(ox + 120, gt + 11, oz), BuildingKit.DARKWOOD, Enum.Material.Wood)
        if hooks and hooks.onGate then
                local prompt = Instance.new("ProximityPrompt")
                prompt.ActionText = "Pusat Kota"
                prompt.ObjectText = "Gerbang"
                prompt.HoldDuration = 0.4
                prompt.MaxActivationDistance = 14
                prompt.RequiresLineOfSight = false
                prompt.Parent = beam
                prompt.Triggered:Connect(function(player)
                        hooks.onGate(player, "kota")
                end)
        end
        local _unusedL = postL
        local _unusedR = postR

        local _signPost = BuildingKit.part(folder, Vector3.new(1, 8, 1), CFrame.new(ox + 96, gt + 4, oz + 8), BuildingKit.DARKWOOD, Enum.Material.Wood)
        local board = BuildingKit.part(folder, Vector3.new(8, 4, 0.5), CFrame.new(ox + 96, gt + 10, oz + 8), BuildingKit.DARKWOOD, Enum.Material.Wood)
        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Front
        gui.CanvasSize = Vector2.new(400, 200)
        local label = Instance.new("TextLabel")
        label.Name = "NamaLahan"
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Text = ""
        label.TextColor3 = Color3.fromRGB(255, 240, 200)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = gui
        gui.Parent = board
        board:SetAttribute("LahanIdx", index)
        folder:SetAttribute("PapanNama", true)

        local spawn = Instance.new("SpawnLocation")
        spawn.Anchored = true
        spawn.Size = Vector3.new(12, 1, 12)
        spawn.Position = Vector3.new(ox + 120, gt + 0.5, oz + 12)
        spawn.Color = Color3.fromRGB(235, 200, 110)
        spawn.Material = Enum.Material.SmoothPlastic
        spawn.TopSurface = Enum.SurfaceType.Smooth
        spawn.Duration = 0
        spawn.Enabled = false
        spawn.Parent = folder

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
                        prompt.Triggered:Connect(function(player)
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

function WorldBuilder.buildKota(root: Folder, hooks)
        local kox = Layout.kotaOffsetX()
        local folder = Instance.new("Folder")
        folder.Name = "PusatKota"
        folder.Parent = root
        local gt = 0

        BuildingKit.part(folder, Vector3.new(400, 1, 400), CFrame.new(kox, -0.5, 0), GRASS, Enum.Material.Grass)
        BuildingKit.part(folder, Vector3.new(10, 0.2, 90), CFrame.new(kox, gt + 0.1, -1), PATH, Enum.Material.Concrete)

        local spawn = Instance.new("SpawnLocation")
        spawn.Anchored = true
        spawn.Size = Vector3.new(12, 1, 12)
        spawn.Position = Vector3.new(kox, gt + 0.5, 44)
        spawn.Color = Color3.fromRGB(235, 200, 110)
        spawn.Material = Enum.Material.SmoothPlastic
        spawn.TopSurface = Enum.SurfaceType.Smooth
        spawn.Duration = 0
        spawn.Enabled = true
        spawn.Parent = folder

        BuildingKit.part(folder, Vector3.new(2, 10, 2), CFrame.new(kox - 11, gt + 5, 20), BuildingKit.DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(folder, Vector3.new(2, 10, 2), CFrame.new(kox + 11, gt + 5, 20), BuildingKit.DARKWOOD, Enum.Material.Wood)
        local beamKota = BuildingKit.part(folder, Vector3.new(26, 2, 2), CFrame.new(kox, gt + 11, 20), BuildingKit.DARKWOOD, Enum.Material.Wood)
        if hooks and hooks.onGate then
                local prompt = Instance.new("ProximityPrompt")
                prompt.ActionText = "Lahan"
                prompt.ObjectText = "Gerbang"
                prompt.HoldDuration = 0.4
                prompt.MaxActivationDistance = 14
                prompt.RequiresLineOfSight = false
                prompt.Parent = beamKota
                prompt.Triggered:Connect(function(player)
                        hooks.onGate(player, "lahan")
                end)
        end

        local toko = BuildingKit.buildToko(folder)
        toko:PivotTo(CFrame.new(kox, gt, -60) * CFrame.Angles(0, math.rad(180), 0))
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
                        prompt.Triggered:Connect(function(player)
                                hooks.onShopPrompt(player)
                        end)
                end
        end

        BuildingKit.streetLamp(folder, kox + 8, gt, 32)
        BuildingKit.streetLamp(folder, kox - 8, gt, 32)
        BuildingKit.streetLamp(folder, kox + 8, gt, -30)
        BuildingKit.streetLamp(folder, kox - 8, gt, -30)

        return folder
end

return WorldBuilder
