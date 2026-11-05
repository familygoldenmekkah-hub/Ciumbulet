local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Remotes)
local Util = require(ReplicatedStorage.Shared.Util)
local Balance = require(ReplicatedStorage.Shared.Balance)
local DoorKit = require(script.Parent.DoorKit)

local PersonalWorldBuilder = {}

local STORY = DoorKit.CHAR_HEIGHT * 4
local DOOR_H = DoorKit.CHAR_HEIGHT * 2
local DOOR_W = DoorKit.DOOR_WIDTH

local worldFolder: Folder? = nil
local nameBoards: { [number]: TextLabel } = {}
local built: { [number]: boolean } = {}

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

local function lahanFolder(index: number): Folder
        local name = "Lahan" .. index
        local f = world():FindFirstChild(name) :: Folder?
        if not f then
                f = Instance.new("Folder")
                f.Name = name
                f.Parent = world()
        end
        return f
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

local function lamp(position: Vector3, parent)
        part({
                Name = "LampuTiang",
                Size = Vector3.new(0.6, 7.4, 0.6),
                CFrame = CFrame.new(position + Vector3.new(0, 3.7, 0)),
                Color = Color3.fromRGB(58, 62, 74),
                Material = Enum.Material.Metal,
        }, parent)
        part({
                Name = "LampuKepala",
                Shape = Enum.PartType.Ball,
                Size = Vector3.new(1.5, 1.5, 1.5),
                CFrame = CFrame.new(position + Vector3.new(0, 7.7, 0)),
                Color = Color3.fromRGB(255, 226, 160),
                Material = Enum.Material.Neon,
                CanCollide = false,
        }, parent)
end

local function surfaceText(board: Part, text: string, sub: string?, color: Color3)
        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Front
        gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        gui.PixelsPerStud = 50
        gui.Parent = board
        local title = Util.create("TextLabel", {
                Size = sub and UDim2.fromScale(1, 0.6) or UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = color,
                Text = text,
        }, gui)
        if sub then
                Util.create("TextLabel", {
                        Position = UDim2.fromScale(0, 0.6),
                        Size = UDim2.fromScale(1, 0.4),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.Gotham,
                        TextScaled = true,
                        TextColor3 = Color3.fromRGB(210, 214, 224),
                        Text = sub,
                }, gui)
        end
        return title
end

local function signBoard(name: string, pos: Vector3, yawDeg: number, title: string, sub: string?, color: Color3, parent): Part
        local board = part({
                Name = name,
                Size = Vector3.new(9, 3.2, 0.6),
                CFrame = CFrame.new(pos + Vector3.new(0, 4.4, 0)) * CFrame.Angles(0, math.rad(yawDeg), 0),
                Color = Color3.fromRGB(84, 62, 40),
                Material = Enum.Material.WoodPlanks,
        }, parent)
        part({
                Name = name .. "Tiang",
                Size = Vector3.new(0.6, 3, 0.6),
                CFrame = CFrame.new(pos + Vector3.new(0, 1.5, 0)),
                Color = Color3.fromRGB(84, 62, 40),
                Material = Enum.Material.WoodPlanks,
        }, parent)
        surfaceText(board, title, sub, color)
        return board
end

local function nameBoard(index: number, pos: Vector3, yawDeg: number, parent)
        local board = part({
                Name = "PapanNama" .. index,
                Size = Vector3.new(11, 3.6, 0.7),
                CFrame = CFrame.new(pos + Vector3.new(0, 5.2, 0)) * CFrame.Angles(0, math.rad(yawDeg), 0),
                Color = Color3.fromRGB(58, 44, 30),
                Material = Enum.Material.Wood,
        }, parent)
        part({
                Name = "PapanNamaTiang1",
                Size = Vector3.new(0.7, 4, 0.7),
                CFrame = CFrame.new(pos + Vector3.new(-4, 2, 0)),
                Color = Color3.fromRGB(84, 62, 40),
                Material = Enum.Material.Wood,
        }, parent)
        part({
                Name = "PapanNamaTiang2",
                Size = Vector3.new(0.7, 4, 0.7),
                CFrame = CFrame.new(pos + Vector3.new(4, 2, 0)),
                Color = Color3.fromRGB(84, 62, 40),
                Material = Enum.Material.Wood,
        }, parent)
        local label = surfaceText(board, "PAPAN NAMA BELUM DIISI", "Dekati & isi namamu!", Color3.fromRGB(255, 226, 150))
        nameBoards[index] = label

        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Isi Papan Nama"
        prompt.ObjectText = "Papan Nama Lahan"
        prompt.MaxActivationDistance = 9
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.Parent = board
        prompt.Triggered:Connect(function(player: Player)
                Remotes.get("OpenLandBoard"):FireClient(player)
        end)
end

function PersonalWorldBuilder.setNameBoard(index: number, name: string)
        local label = nameBoards[index]
        if label then
                label.Text = name
        end
end

local function decorativeTree(pos: Vector3, seed: number, parent)
        local rng = Random.new(seed or 1)
        part({
                Name = "PohonBatang",
                Size = Vector3.new(1.4, 7 + rng:NextNumber(0, 2.4), 1.4),
                CFrame = CFrame.new(pos + Vector3.new(0, 3.8, 0)),
                Color = Color3.fromRGB(112, 88, 60),
                Material = Enum.Material.Wood,
        }, parent)
        part({
                Name = "PohonDedaun",
                Shape = Enum.PartType.Ball,
                Size = Vector3.new(8, 6.4, 8),
                CFrame = CFrame.new(pos + Vector3.new(0, 9.4, 0)),
                Color = Color3.fromRGB(72, 138, 70),
                Material = Enum.Material.Grass,
        }, parent)
        part({
                Name = "PohonDedaunAtas",
                Shape = Enum.PartType.Ball,
                Size = Vector3.new(5.4, 4.4, 5.4),
                CFrame = CFrame.new(pos + Vector3.new(0, 12.4, 0)),
                Color = Color3.fromRGB(88, 158, 82),
                Material = Enum.Material.Grass,
                CanCollide = false,
        }, parent)
end

local function stairs(x: number, z: number, y0: number, parent, color: Color3)
        for i = 1, 10 do
                part({
                        Name = "Tangga" .. i,
                        Size = Vector3.new(4, 2, 2.2),
                        CFrame = CFrame.new(x, y0 + i * 1 - 1, z + (i - 1) * 2.2),
                        Color = color,
                        Material = Enum.Material.WoodPlanks,
                }, parent)
        end
end

local function buildHouse(center: Vector3, parent)
        local hx, hz = center.X, center.Z
        local wall = Color3.fromRGB(234, 222, 200)
        local wood = Color3.fromRGB(150, 108, 66)
        local roof = Color3.fromRGB(148, 66, 54)
        local halfW, halfD = 13.5, 10.5

        for story = 0, 2 do
                local y = story * STORY
                local wallMat = Enum.Material.WoodPlanks
                part({ Name = "RumahDindingB" .. story, Size = Vector3.new(1, STORY, 21), CFrame = CFrame.new(hx - halfW, y + STORY / 2, hz), Color = wall, Material = wallMat }, parent)
                part({ Name = "RumahDindingU" .. story, Size = Vector3.new(27, STORY, 1), CFrame = CFrame.new(hx, y + STORY / 2, hz - halfD), Color = wall, Material = wallMat }, parent)
                part({ Name = "RumahDindingS" .. story, Size = Vector3.new(27, STORY, 1), CFrame = CFrame.new(hx, y + STORY / 2, hz + halfD), Color = wall, Material = wallMat }, parent)
                if story == 0 then
                        part({ Name = "RumahDindingDU", Size = Vector3.new(1, STORY, 7.6), CFrame = CFrame.new(hx + halfW, STORY / 2, hz - 6.7), Color = wall, Material = wallMat }, parent)
                        part({ Name = "RumahDindingDS", Size = Vector3.new(1, STORY, 7.6), CFrame = CFrame.new(hx + halfW, STORY / 2, hz + 6.7), Color = wall, Material = wallMat }, parent)
                        part({ Name = "RumahPalangPintu", Size = Vector3.new(1, STORY - DOOR_H, 4.6), CFrame = CFrame.new(hx + halfW, DOOR_H + (STORY - DOOR_H) / 2, hz), Color = wall, Material = wallMat }, parent)
                        DoorKit.frame(Vector3.new(hx + halfW, 0, hz), 90, parent, DOOR_W, DOOR_H)
                        DoorKit.hinged(Vector3.new(hx + halfW, 0, hz), 90, parent, DOOR_W, DOOR_H, Color3.fromRGB(130, 92, 58))
                else
                        part({ Name = "RumahDindingD" .. story, Size = Vector3.new(1, STORY, 21), CFrame = CFrame.new(hx + halfW, y + STORY / 2, hz), Color = wall, Material = wallMat }, parent)
                end
                for _, side in { -1, 1 } do
                        part({
                                Name = "RumahJendela" .. story .. side,
                                Size = Vector3.new(5.4, 5, 0.5),
                                CFrame = CFrame.new(hx - 4, y + STORY * 0.55, hz + side * (halfD - 0.3)),
                                Color = Color3.fromRGB(172, 216, 236),
                                Material = Enum.Material.Glass,
                                Transparency = 0.45,
                        }, parent)
                end
                part({
                        Name = "RumahJendelaD" .. story,
                        Size = Vector3.new(0.5, 5, 7),
                        CFrame = CFrame.new(hx + halfW - 0.3, y + STORY * 0.55, hz - 5.6),
                        Color = Color3.fromRGB(172, 216, 236),
                        Material = Enum.Material.Glass,
                        Transparency = 0.45,
                }, parent)
        end

        part({ Name = "RumahLantai0", Size = Vector3.new(27, 0.5, 21), CFrame = CFrame.new(hx, 0.25, hz), Color = Color3.fromRGB(172, 130, 84), Material = Enum.Material.WoodPlanks }, parent)
        part({ Name = "RumahLantai1", Size = Vector3.new(27, 0.5, 12.5), CFrame = CFrame.new(hx, STORY + 0.25, hz + 4), Color = Color3.fromRGB(172, 130, 84), Material = Enum.Material.WoodPlanks }, parent)
        part({ Name = "RumahLantai1T", Size = Vector3.new(8.6, 0.5, 8.6), CFrame = CFrame.new(hx + 9.2, STORY + 0.25, hz - 6.2), Color = Color3.fromRGB(172, 130, 84), Material = Enum.Material.WoodPlanks }, parent)
        part({ Name = "RumahLantai2", Size = Vector3.new(27, 0.5, 12.5), CFrame = CFrame.new(hx, STORY * 2 + 0.25, hz + 4), Color = Color3.fromRGB(172, 130, 84), Material = Enum.Material.WoodPlanks }, parent)
        part({ Name = "RumahLantai2T", Size = Vector3.new(8.6, 0.5, 8.6), CFrame = CFrame.new(hx + 9.2, STORY * 2 + 0.25, hz - 6.2), Color = Color3.fromRGB(172, 130, 84), Material = Enum.Material.WoodPlanks }, parent)

        stairs(hx - 11, hz - 8.8, 0, parent, wood)
        stairs(hx - 11, hz - 8.8, STORY, parent, wood)
        stairs(hx - 11, hz - 8.8, STORY * 2, parent, wood)

        for story = 1, 2 do
                local y = story * STORY
                part({ Name = "RumahRelKiri" .. story, Size = Vector3.new(0.4, 3.4, 0.4), CFrame = CFrame.new(hx + 8.4, y + 1.7, hz - 8.8), Color = wood, Material = Enum.Material.Wood }, parent)
                part({ Name = "RumahRelKanan" .. story, Size = Vector3.new(0.4, 3.4, 0.4), CFrame = CFrame.new(hx + 8.4, y + 1.7, hz - 4.4), Color = wood, Material = Enum.Material.Wood }, parent)
                part({ Name = "RumahRelAtas" .. story, Size = Vector3.new(0.3, 0.3, 4.8), CFrame = CFrame.new(hx + 8.4, y + 3.4, hz - 6.6), Color = wood, Material = Enum.Material.Wood }, parent)
        end

        part({ Name = "RumahAtapDasar", Size = Vector3.new(29, 1.2, 23), CFrame = CFrame.new(hx, STORY * 3 + 0.6, hz), Color = roof, Material = Enum.Material.Slate }, parent)
        local parapetC = Color3.fromRGB(196, 188, 176)
        part({ Name = "RooftopParapetU", Size = Vector3.new(27, 3, 1), CFrame = CFrame.new(hx, STORY * 3 + 2.1, hz - 10), Color = parapetC, Material = Enum.Material.Concrete }, parent)
        part({ Name = "RooftopParapetS", Size = Vector3.new(27, 3, 1), CFrame = CFrame.new(hx, STORY * 3 + 2.1, hz + 10), Color = parapetC, Material = Enum.Material.Concrete }, parent)
        part({ Name = "RooftopParapetB", Size = Vector3.new(1, 3, 21), CFrame = CFrame.new(hx - 13, STORY * 3 + 2.1, hz), Color = parapetC, Material = Enum.Material.Concrete }, parent)
        part({ Name = "RooftopParapetT", Size = Vector3.new(1, 3, 21), CFrame = CFrame.new(hx + 13, STORY * 3 + 2.1, hz), Color = parapetC, Material = Enum.Material.Concrete }, parent)
        local roofY = STORY * 3
        for _, px in { -10, 10 } do
                for _, pz in { -6, 6 } do
                        part({ Name = "PergolaTiang", Size = Vector3.new(0.9, 8, 0.9), CFrame = CFrame.new(hx + px, roofY + 4, hz + pz), Color = wood, Material = Enum.Material.Wood }, parent)
                end
        end
        part({ Name = "PergolaBalok1", Size = Vector3.new(21, 0.7, 1), CFrame = CFrame.new(hx, roofY + 8.2, hz - 6), Color = wood, Material = Enum.Material.Wood }, parent)
        part({ Name = "PergolaBalok2", Size = Vector3.new(21, 0.7, 1), CFrame = CFrame.new(hx, roofY + 8.2, hz + 6), Color = wood, Material = Enum.Material.Wood }, parent)
        part({ Name = "PergolaAtap", Size = Vector3.new(23, 0.6, 15), CFrame = CFrame.new(hx, roofY + 8.8, hz), Color = roof:Lerp(Color3.new(1, 1, 1), 0.1), Material = Enum.Material.Slate }, parent)
        for i = 1, 2 do
                part({ Name = "RooftopPlanter" .. i, Size = Vector3.new(5, 1.2, 2), CFrame = CFrame.new(hx - 7 + (i - 1) * 14, roofY + 1.2, hz + 7.6), Color = Color3.fromRGB(150, 108, 66), Material = Enum.Material.Wood }, parent)
                for f = 1, 3 do
                        part({
                                Name = "RooftopBunga" .. i .. f,
                                Shape = Enum.PartType.Ball,
                                Size = Vector3.new(1, 1, 1) * 0.9,
                                CFrame = CFrame.new(hx - 8.6 + (i - 1) * 14 + f * 1.6, roofY + 2.2, hz + 7.6),
                                Color = Color3.fromHSV((f + i) / 5, 0.6, 0.95),
                                Material = Enum.Material.Grass,
                                CanCollide = false,
                        }, parent)
                end
        end
        part({ Name = "RooftopBangku", Size = Vector3.new(6, 0.7, 2), CFrame = CFrame.new(hx + 8, roofY + 0.95, hz - 6), Color = wood, Material = Enum.Material.WoodPlanks }, parent)
        part({ Name = "RooftopPayungTiang", Size = Vector3.new(0.4, 7, 0.4), CFrame = CFrame.new(hx + 8, roofY + 4.1, hz + 2), Color = wood, Material = Enum.Material.Wood }, parent)
        part({ Name = "RooftopPayungAtap", Shape = Enum.PartType.Ball, Size = Vector3.new(6.4, 2.4, 6.4), CFrame = CFrame.new(hx + 8, roofY + 7.6, hz + 2), Color = Color3.fromRGB(240, 170, 90), Material = Enum.Material.Fabric, CanCollide = false }, parent)

        part({ Name = "RumahTeras", Size = Vector3.new(8, 0.4, 11), CFrame = CFrame.new(hx + 17.5, 0.2, hz), Color = parapetC, Material = Enum.Material.Concrete }, parent)
        for _, side in { -1, 1 } do
                part({ Name = "RumahPilarTeras" .. side, Size = Vector3.new(1, 6.4, 1), CFrame = CFrame.new(hx + 21, 3.2, hz + side * 4.6), Color = wood, Material = Enum.Material.Wood }, parent)
        end
        part({ Name = "RumahPalangTeras", Size = Vector3.new(1, 1, 10.4), CFrame = CFrame.new(hx + 21, 6.6, hz), Color = wood, Material = Enum.Material.Wood }, parent)

        part({ Name = "RumahKarpet", Size = Vector3.new(14, 0.12, 10), CFrame = CFrame.new(hx - 4, 0.56, hz + 2), Color = Color3.fromRGB(158, 76, 66), Material = Enum.Material.Fabric }, parent)
        part({ Name = "RumahSofaDuduk", Size = Vector3.new(9, 1.4, 3.4), CFrame = CFrame.new(hx - 7, 1.3, hz + 6.4), Color = Color3.fromRGB(120, 132, 158), Material = Enum.Material.Fabric }, parent)
        part({ Name = "RumahSofaPunggung", Size = Vector3.new(9, 2.6, 1), CFrame = CFrame.new(hx - 7, 2.4, hz + 8.2), Color = Color3.fromRGB(120, 132, 158), Material = Enum.Material.Fabric }, parent)
        for _, side in { -1, 1 } do
                part({ Name = "RumahSofaArm" .. side, Size = Vector3.new(1, 2, 3.4), CFrame = CFrame.new(hx - 7 + side * 5, 1.6, hz + 6.4), Color = Color3.fromRGB(120, 132, 158), Material = Enum.Material.Fabric }, parent)
        end
        part({ Name = "RumahMejaKecilKaki", Size = Vector3.new(3.4, 0.9, 2), CFrame = CFrame.new(hx - 7, 1.05, hz + 2.4), Color = wood, Material = Enum.Material.WoodPlanks }, parent)
        part({ Name = "RumahTVLayar", Size = Vector3.new(8.4, 5, 0.5), CFrame = CFrame.new(hx - 12.4, 5.4, hz + 2), Color = Color3.fromRGB(24, 26, 34), Material = Enum.Material.SmoothPlastic }, parent)
        part({ Name = "RumahTVKaca", Size = Vector3.new(7.4, 4, 0.3), CFrame = CFrame.new(hx - 12, 5.4, hz + 2) * CFrame.Angles(0, math.rad(-90), 0), Color = Color3.fromRGB(120, 180, 255), Material = Enum.Material.Neon, CanCollide = false }, parent)
        part({ Name = "RumahTVRak", Size = Vector3.new(2.4, 1, 6), CFrame = CFrame.new(hx - 11.6, 1.1, hz + 2), Color = wood, Material = Enum.Material.Wood }, parent)
        part({ Name = "RumahRakDinding", Size = Vector3.new(0.7, 0.5, 7), CFrame = CFrame.new(hx - 3, 6.6, hz - 8.6), Color = wood, Material = Enum.Material.Wood }, parent)
        for i = 1, 3 do
                part({
                        Name = "RumahHiasan" .. i,
                        Size = Vector3.new(0.9, 1.1, 0.9),
                        CFrame = CFrame.new(hx - 3, 7.4, hz - 10.6 + i * 2),
                        Color = Color3.fromRGB(255, 209, 102):Lerp(Color3.fromRGB(120, 200, 235), (i - 1) / 2),
                        Material = Enum.Material.SmoothPlastic,
                        CanCollide = false,
                }, parent)
        end
        local bulb1 = part({ Name = "RumahLampuGantung1", Shape = Enum.PartType.Ball, Size = Vector3.new(1.3, 1.3, 1.3), CFrame = CFrame.new(hx - 2, 7.6, hz + 2), Color = Color3.fromRGB(255, 226, 160), Material = Enum.Material.Neon, CanCollide = false }, parent)
        local light1 = Instance.new("PointLight")
        light1.Color = Color3.fromRGB(255, 226, 160)
        light1.Range = 22
        light1.Brightness = 0.9
        light1.Shadows = false
        light1.Parent = bulb1

        local y2 = STORY
        part({ Name = "RumahKarpet2", Size = Vector3.new(13, 0.12, 9), CFrame = CFrame.new(hx - 2, y2 + 0.56, hz + 3), Color = Color3.fromRGB(96, 130, 96), Material = Enum.Material.Fabric }, parent)
        part({ Name = "RumahCounterL1", Size = Vector3.new(9, 3, 2.2), CFrame = CFrame.new(hx - 8, y2 + 1.9, hz - 8.4), Color = Color3.fromRGB(210, 208, 200), Material = Enum.Material.SmoothPlastic }, parent)
        part({ Name = "RumahCounterL2", Size = Vector3.new(2.2, 3, 7), CFrame = CFrame.new(hx - 12.3, y2 + 1.9, hz - 4), Color = Color3.fromRGB(210, 208, 200), Material = Enum.Material.SmoothPlastic }, parent)
        part({ Name = "RumahCounterTop", Size = Vector3.new(9.6, 0.4, 2.8), CFrame = CFrame.new(hx - 8, y2 + 3.5, hz - 8.3), Color = Color3.fromRGB(60, 62, 70), Material = Enum.Material.Slate }, parent)
        part({ Name = "RumahSink", Size = Vector3.new(2.4, 0.5, 1.6), CFrame = CFrame.new(hx - 6, y2 + 3.5, hz - 8.3), Color = Color3.fromRGB(190, 196, 205), Material = Enum.Material.Metal }, parent)
        part({ Name = "RumahKran", Size = Vector3.new(0.35, 1.4, 0.35), CFrame = CFrame.new(hx - 6, y2 + 4.4, hz - 9), Color = Color3.fromRGB(180, 186, 195), Material = Enum.Material.Metal }, parent)
        for i = 1, 4 do
                part({
                        Name = "RumahTungku" .. i,
                        Shape = Enum.PartType.Cylinder,
                        Size = Vector3.new(0.3, 1.3, 1.3),
                        CFrame = CFrame.new(hx - 10.4 + i * 1.4, y2 + 3.8, hz - 8.3) * CFrame.Angles(0, 0, math.rad(90)),
                        Color = Color3.fromRGB(40, 40, 48),
                        Material = Enum.Material.SmoothPlastic,
                }, parent)
        end
        part({ Name = "RumahKulkas", Size = Vector3.new(3.2, 7.4, 2.8), CFrame = CFrame.new(hx + 11, y2 + 4.1, hz - 8.4), Color = Color3.fromRGB(226, 230, 234), Material = Enum.Material.SmoothPlastic }, parent)
        part({ Name = "RumahKulkasGagang", Size = Vector3.new(0.3, 3.4, 0.3), CFrame = CFrame.new(hx + 9.3, y2 + 4.4, hz - 7), Color = Color3.fromRGB(170, 176, 186), Material = Enum.Material.Metal }, parent)
        part({ Name = "RumahLemariAtas1", Size = Vector3.new(8, 3, 1.6), CFrame = CFrame.new(hx - 8, y2 + 6.6, hz - 9.4), Color = Color3.fromRGB(176, 140, 96), Material = Enum.Material.WoodPlanks }, parent)
        part({ Name = "RumahLemariAtas2", Size = Vector3.new(4.4, 3, 1.6), CFrame = CFrame.new(hx + 4.4, y2 + 6.6, hz - 9.4), Color = Color3.fromRGB(176, 140, 96), Material = Enum.Material.WoodPlanks }, parent)
        part({ Name = "RumahMejaMakan", Size = Vector3.new(6, 0.5, 3.4), CFrame = CFrame.new(hx + 2, y2 + 2, hz + 3), Color = wood, Material = Enum.Material.WoodPlanks }, parent)
        for _, leg in { { -2.6, -1.3 }, { 2.6, -1.3 }, { -2.6, 1.3 }, { 2.6, 1.3 } } do
                part({ Name = "RumahMejaKaki", Size = Vector3.new(0.5, 1.8, 0.5), CFrame = CFrame.new(hx + 2 + leg[1], y2 + 0.9, hz + 3 + leg[2]), Color = wood, Material = Enum.Material.Wood }, parent)
        end
        for _, seat in { { 0, -2.8, 0 }, { 0, 2.8, 180 }, { -3.8, 0, 90 }, { 3.8, 0, -90 } } do
                part({ Name = "RumahKursiMakan", Size = Vector3.new(1.7, 0.6, 1.7), CFrame = CFrame.new(hx + 2 + seat[1], y2 + 0.9, hz + 3 + seat[2]), Color = wood, Material = Enum.Material.WoodPlanks }, parent)
                part({ Name = "RumahKursiSandal", Size = Vector3.new(1.7, 2, 0.4), CFrame = CFrame.new(hx + 2 + seat[1] + math.sin(math.rad(seat[3])) * 0.7, y2 + 1.6, hz + 3 + seat[2] + math.cos(math.rad(seat[3])) * 0.7) * CFrame.Angles(0, math.rad(seat[3]), 0), Color = wood, Material = Enum.Material.WoodPlanks }, parent)
        end
        part({ Name = "RumahBuahMangkuk", Shape = Enum.PartType.Ball, Size = Vector3.new(1.4, 0.8, 1.4), CFrame = CFrame.new(hx + 2, y2 + 2.6, hz + 3), Color = Color3.fromRGB(255, 150, 90), Material = Enum.Material.SmoothPlastic, CanCollide = false }, parent)

        local y3 = STORY * 2
        part({ Name = "RumahKarpet3", Size = Vector3.new(12, 0.12, 9), CFrame = CFrame.new(hx + 2, y3 + 0.56, hz + 3), Color = Color3.fromRGB(146, 108, 158), Material = Enum.Material.Fabric }, parent)
        part({ Name = "RumahRanjang", Size = Vector3.new(4.4, 1.1, 7.4), CFrame = CFrame.new(hx + 9.5, y3 + 1.15, hz - 4.6), Color = wood, Material = Enum.Material.WoodPlanks }, parent)
        part({ Name = "RumahKasur", Size = Vector3.new(4.2, 0.7, 7), CFrame = CFrame.new(hx + 9.5, y3 + 2, hz - 4.6), Color = Color3.fromRGB(240, 238, 232), Material = Enum.Material.Fabric }, parent)
        part({ Name = "RumahBantal", Size = Vector3.new(3.4, 0.9, 1.8), CFrame = CFrame.new(hx + 9.5, y3 + 2.5, hz - 7.2), Color = Color3.fromRGB(255, 255, 250), Material = Enum.Material.Fabric }, parent)
        part({ Name = "RumahSelimut", Size = Vector3.new(4.3, 0.5, 4.4), CFrame = CFrame.new(hx + 9.5, y3 + 2.4, hz - 2.6), Color = Color3.fromRGB(96, 130, 170), Material = Enum.Material.Fabric }, parent)
        part({ Name = "RumahLemariBadan", Size = Vector3.new(1.4, 9, 6.4), CFrame = CFrame.new(hx - 12.3, y3 + 4.9, hz - 4), Color = Color3.fromRGB(134, 100, 66), Material = Enum.Material.Wood }, parent)
        for _, side in { -1, 1 } do
                part({ Name = "RumahLemariPintu" .. side, Size = Vector3.new(0.25, 8.2, 2.9), CFrame = CFrame.new(hx - 11.5, y3 + 4.9, hz - 4 + side * 1.55), Color = Color3.fromRGB(150, 116, 78), Material = Enum.Material.WoodPlanks }, parent)
                part({ Name = "RumahLemariGagang" .. side, Size = Vector3.new(0.3, 1.6, 0.3), CFrame = CFrame.new(hx - 11.3, y3 + 4.9, hz - 4 + side * 0.4), Color = Color3.fromRGB(240, 204, 108), Material = Enum.Material.Metal }, parent)
        end
        part({ Name = "RumahMejaKerja", Size = Vector3.new(5, 0.4, 2.4), CFrame = CFrame.new(hx - 8, y3 + 2.1, hz + 7.4), Color = wood, Material = Enum.Material.WoodPlanks }, parent)
        for _, leg in { { -2.2, -0.9 }, { 2.2, -0.9 }, { -2.2, 0.9 }, { 2.2, 0.9 } } do
                part({ Name = "RumahMejaKerjaKaki", Size = Vector3.new(0.4, 2, 0.4), CFrame = CFrame.new(hx - 8 + leg[1], y3 + 1, hz + 7.4 + leg[2]), Color = wood, Material = Enum.Material.Wood }, parent)
        end
        part({ Name = "RumahKursiKerja", Size = Vector3.new(1.8, 0.6, 1.8), CFrame = CFrame.new(hx - 8, y3 + 0.9, hz + 5.6), Color = wood, Material = Enum.Material.WoodPlanks }, parent)
        part({ Name = "RumahLampuTidur", Shape = Enum.PartType.Ball, Size = Vector3.new(1.1, 1.1, 1.1), CFrame = CFrame.new(hx + 12.4, y3 + 3.2, hz - 8.4), Color = Color3.fromRGB(255, 226, 160), Material = Enum.Material.Neon, CanCollide = false }, parent)
end

local function roomShell(center: Vector3, judul: string, floorC: Color3, wallC: Color3, roofC: Color3, parent)
        local x, z = center.X, center.Z
        part({ Name = judul .. "Lantai", Size = Vector3.new(20, 0.4, 16), CFrame = CFrame.new(x, 0.2, z), Color = floorC, Material = Enum.Material.Concrete }, parent)
        part({ Name = judul .. "DindingSel", Size = Vector3.new(20, STORY, 1), CFrame = CFrame.new(x, STORY / 2, z + 8), Color = wallC, Material = Enum.Material.SmoothPlastic }, parent)
        part({ Name = judul .. "DindingBar", Size = Vector3.new(1, STORY, 16), CFrame = CFrame.new(x - 10, STORY / 2, z), Color = wallC, Material = Enum.Material.SmoothPlastic }, parent)
        part({ Name = judul .. "DindingTim", Size = Vector3.new(1, STORY, 16), CFrame = CFrame.new(x + 10, STORY / 2, z), Color = wallC, Material = Enum.Material.SmoothPlastic }, parent)
        part({ Name = judul .. "DindingDepU", Size = Vector3.new(7.7, STORY, 1), CFrame = CFrame.new(x - 6.15, STORY / 2, z - 8), Color = wallC, Material = Enum.Material.SmoothPlastic }, parent)
        part({ Name = judul .. "DindingDepS", Size = Vector3.new(7.7, STORY, 1), CFrame = CFrame.new(x + 6.15, STORY / 2, z - 8), Color = wallC, Material = Enum.Material.SmoothPlastic }, parent)
        part({ Name = judul .. "PalangPintu", Size = Vector3.new(20, STORY - DOOR_H, 1), CFrame = CFrame.new(x, DOOR_H + (STORY - DOOR_H) / 2, z - 8), Color = wallC, Material = Enum.Material.SmoothPlastic }, parent)
        part({ Name = judul .. "Atap", Size = Vector3.new(22, 1.2, 18), CFrame = CFrame.new(x, STORY + 0.6, z), Color = roofC, Material = Enum.Material.Slate }, parent)
        DoorKit.frame(Vector3.new(x, 0, z - 8), 0, parent, DOOR_W, DOOR_H)
        DoorKit.hinged(Vector3.new(x, 0, z - 8), 0, parent, DOOR_W, DOOR_H, wallC:Lerp(Color3.new(0, 0, 0), 0.25))
        local board = part({
                Name = judul .. "Papan",
                Size = Vector3.new(8.5, 2.2, 0.5),
                CFrame = CFrame.new(x, DOOR_H + 2.6, z - 8.8) * CFrame.Angles(0, math.rad(180), 0),
                Color = Color3.fromRGB(34, 38, 52),
                Material = Enum.Material.SmoothPlastic,
                CanCollide = false,
        }, parent)
        surfaceText(board, judul, nil, Color3.fromRGB(255, 226, 150))
        return board
end

local function infoPrompt(parentPart: Part, title: string, body: string)
        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Baca Info"
        prompt.ObjectText = title
        prompt.MaxActivationDistance = 9
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.Parent = parentPart
        prompt.Triggered:Connect(function(player: Player)
                Remotes.get("Notify"):FireClient(player, title, body)
        end)
end

local function buildSurgeryRoom(center: Vector3, parent)
        local board = roomShell(center, "RUANG BEDAH", Color3.fromRGB(226, 229, 234), Color3.fromRGB(238, 240, 244), Color3.fromRGB(168, 62, 58), parent)
        local x, z = center.X, center.Z
        part({ Name = "BedahSalang1", Size = Vector3.new(5.4, 0.7, 0.7), CFrame = CFrame.new(x, STORY + 1.6, z) * CFrame.Angles(0, math.rad(45), 0), Color = Color3.fromRGB(235, 62, 56), Material = Enum.Material.Neon, CanCollide = false }, parent)
        part({ Name = "BedahSalang2", Size = Vector3.new(5.4, 0.7, 0.7), CFrame = CFrame.new(x, STORY + 1.6, z) * CFrame.Angles(0, math.rad(-45), 0), Color = Color3.fromRGB(235, 62, 56), Material = Enum.Material.Neon, CanCollide = false }, parent)
        part({ Name = "BedahRanjang", Size = Vector3.new(7.6, 1.2, 4), CFrame = CFrame.new(x - 2, 1.3, z + 1), Color = Color3.fromRGB(245, 246, 248), Material = Enum.Material.SmoothPlastic }, parent)
        part({ Name = "BedahBantal", Size = Vector3.new(2.2, 0.8, 3.2), CFrame = CFrame.new(x - 5, 2.2, z + 1), Color = Color3.fromRGB(220, 230, 240), Material = Enum.Material.Fabric }, parent)
        part({ Name = "BedahTiangLampu", Size = Vector3.new(0.4, 8, 0.4), CFrame = CFrame.new(x - 2, 5, z + 4.4), Color = Color3.fromRGB(120, 126, 138), Material = Enum.Material.Metal }, parent)
        part({ Name = "BedahLampu", Shape = Enum.PartType.Ball, Size = Vector3.new(2.4, 2.4, 2.4), CFrame = CFrame.new(x - 2, 9.4, z + 1), Color = Color3.fromRGB(250, 252, 255), Material = Enum.Material.Neon, CanCollide = false }, parent)
        part({ Name = "BedahLemari", Size = Vector3.new(2.2, 8, 3.6), CFrame = CFrame.new(x + 8.4, 4.4, z + 5.4), Color = Color3.fromRGB(150, 156, 168), Material = Enum.Material.Metal }, parent)
        part({ Name = "BedahTroli", Size = Vector3.new(3, 0.3, 2), CFrame = CFrame.new(x + 4, 2.2, z + 5.6), Color = Color3.fromRGB(170, 176, 186), Material = Enum.Material.Metal }, parent)
        part({ Name = "BedahKotakAlat", Size = Vector3.new(1.4, 0.8, 1.2), CFrame = CFrame.new(x + 4, 2.8, z + 5.6), Color = Color3.fromRGB(90, 160, 210), Material = Enum.Material.SmoothPlastic }, parent)
        part({ Name = "BedahMejaMonitor", Size = Vector3.new(4, 0.3, 1.8), CFrame = CFrame.new(x + 6, 3, z - 5), Color = Color3.fromRGB(170, 176, 186), Material = Enum.Material.Metal }, parent)
        part({ Name = "BedahMonitor", Size = Vector3.new(3, 2, 0.3), CFrame = CFrame.new(x + 6, 4.6, z - 5.4), Color = Color3.fromRGB(90, 220, 180), Material = Enum.Material.Neon, CanCollide = false }, parent)
        infoPrompt(board, "RUANG BEDAH", "Ruang operasi pribadimu - lengkap dengan meja operasi, lampu bedah & monitor. Fitur bedah darurat menyusul di ruangan ini.")
end

local function buildScienceRoom(center: Vector3, parent)
        local board = roomShell(center, "RUANG SAINS", Color3.fromRGB(62, 92, 98), Color3.fromRGB(74, 142, 150), Color3.fromRGB(54, 68, 76), parent)
        local x, z = center.X, center.Z
        local tubeColors = {
                Color3.fromRGB(120, 230, 140),
                Color3.fromRGB(100, 180, 240),
                Color3.fromRGB(190, 120, 255),
        }
        for i = 0, 2 do
                local sx = x - 6 + i * 6
                part({ Name = "SainsMeja" .. i, Size = Vector3.new(4, 3, 2.6), CFrame = CFrame.new(sx, 1.9, z + 3.6), Color = Color3.fromRGB(150, 156, 168), Material = Enum.Material.Metal }, parent)
                part({ Name = "SainsTabung" .. i, Shape = Enum.PartType.Cylinder, Size = Vector3.new(2.8, 1.3, 1.3), CFrame = CFrame.new(sx, 4.4, z + 3.6) * CFrame.Angles(0, 0, math.rad(90)), Color = tubeColors[i + 1], Material = Enum.Material.Neon, Transparency = 0.15 }, parent)
        end
        part({ Name = "SainsRak", Size = Vector3.new(6, 0.5, 1.4), CFrame = CFrame.new(x - 4, 6.4, z - 7.2), Color = Color3.fromRGB(104, 90, 70), Material = Enum.Material.Wood }, parent)
        for i = 1, 5 do
                part({
                        Name = "SainsBotol" .. i,
                        Size = Vector3.new(0.7, 1.2, 0.7),
                        CFrame = CFrame.new(x - 6.4 + i * 1.1, 7.2, z - 7.2),
                        Color = Color3.fromHSV((i - 1) / 5, 0.65, 0.95),
                        Material = Enum.Material.SmoothPlastic,
                        CanCollide = false,
                }, parent)
        end
        part({ Name = "SainsLemariBahan", Size = Vector3.new(3, 8, 2.4), CFrame = CFrame.new(x + 8, 4.4, z + 6), Color = Color3.fromRGB(96, 140, 148), Material = Enum.Material.Metal }, parent)
        infoPrompt(board, "RUANG SAINS", "Lab pribadimu - tiga stasiun eksperimen, rak botol bahan & lemari kimia. Riset campuran akan aktif di sini!")
end

local function buildStartopiaRoom(center: Vector3, parent)
        local board = roomShell(center, "RUANG STARTOPIA", Color3.fromRGB(32, 38, 62), Color3.fromRGB(46, 58, 98), Color3.fromRGB(26, 30, 50), parent)
        local x, z = center.X, center.Z
        part({ Name = "StarTiang", Size = Vector3.new(1, 3.2, 1), CFrame = CFrame.new(x - 5, 1.6, z + 3), Color = Color3.fromRGB(120, 126, 140), Material = Enum.Material.Metal }, parent)
        part({
                Name = "StarTeleskop",
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(6.5, 1, 1),
                CFrame = CFrame.new(x - 5, 4.4, z + 3) * CFrame.Angles(0, 0, math.rad(50)),
                Color = Color3.fromRGB(196, 202, 216),
                Material = Enum.Material.Metal,
        }, parent)
        part({ Name = "StarKonsol", Size = Vector3.new(5, 1.2, 2.2), CFrame = CFrame.new(x + 5, 0.6, z + 4), Color = Color3.fromRGB(38, 44, 66), Material = Enum.Material.Metal }, parent)
        part({ Name = "StarLayar", Size = Vector3.new(4.6, 2.6, 0.3), CFrame = CFrame.new(x + 5, 2.6, z + 4.6), Color = Color3.fromRGB(90, 160, 255), Material = Enum.Material.Neon, CanCollide = false }, parent)
        part({ Name = "StarTombol", Size = Vector3.new(3, 0.3, 1), CFrame = CFrame.new(x + 5, 1.35, z + 3.4), Color = Color3.fromRGB(255, 190, 90), Material = Enum.Material.Neon }, parent)
        part({ Name = "StarPot", Shape = Enum.PartType.Cylinder, Size = Vector3.new(1.4, 1.8, 1.8), CFrame = CFrame.new(x + 1, 0.7, z - 6) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(150, 96, 62), Material = Enum.Material.SmoothPlastic }, parent)
        part({ Name = "StarAlien", Shape = Enum.PartType.Ball, Size = Vector3.new(2.4, 2.4, 2.4), CFrame = CFrame.new(x + 1, 2.6, z - 6), Color = Color3.fromRGB(180, 100, 235), Material = Enum.Material.Grass }, parent)
        part({ Name = "StarAlienDaun", Shape = Enum.PartType.Ball, Size = Vector3.new(1.3, 1.3, 1.3), CFrame = CFrame.new(x + 2.1, 3.4, z - 6), Color = Color3.fromRGB(120, 230, 150), Material = Enum.Material.Grass, CanCollide = false }, parent)
        local rng = Random.new(777)
        for i = 1, 6 do
                part({
                        Name = "StarBintang" .. i,
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(0.5, 0.5, 0.5),
                        CFrame = CFrame.new(x - 8 + i * 2.6, 8 + rng:NextNumber(-2, 2), z + 8.2),
                        Color = Color3.fromRGB(255, 240, 180),
                        Material = Enum.Material.Neon,
                        CanCollide = false,
                }, parent)
        end
        part({ Name = "StarRoket", Size = Vector3.new(2.6, 9, 2.6), CFrame = CFrame.new(x - 7.4, 4.5, z - 5) * CFrame.Angles(0, 0, math.rad(8)), Color = Color3.fromRGB(220, 224, 232), Material = Enum.Material.Metal }, parent)
        part({ Name = "StarRoketHidung", Shape = Enum.PartType.Ball, Size = Vector3.new(2.6, 3.4, 2.6), CFrame = CFrame.new(x - 7, 9.6, z - 5), Color = Color3.fromRGB(255, 110, 90), Material = Enum.Material.SmoothPlastic, CanCollide = false }, parent)
        infoPrompt(board, "RUANG STARTOPIA", "Basis antariksa pribadimu - teleskop bintang, konsol galaksi & roket riset. Portal eksplorasi galaksi akan dibuka dari sini!")
end

local function buildFishingRoom(center: Vector3, parent)
        local board = roomShell(center, "RUANG PANCING", Color3.fromRGB(84, 118, 132), Color3.fromRGB(96, 136, 150), Color3.fromRGB(60, 82, 96), parent)
        local x, z = center.X, center.Z
        part({ Name = "PancingRakRel", Size = Vector3.new(0.4, 0.4, 9), CFrame = CFrame.new(x - 9.4, 5.4, z + 1), Color = Color3.fromRGB(104, 90, 70), Material = Enum.Material.Wood }, parent)
        for i = 1, 3 do
                part({
                        Name = "PancingJoran" .. i,
                        Shape = Enum.PartType.Cylinder,
                        Size = Vector3.new(8.4, 0.28, 0.28),
                        CFrame = CFrame.new(x - 9.2, 5.4 + (i - 1) * 0.5, z - 2.4 + i * 2.4) * CFrame.Angles(0, 0, math.rad(90)),
                        Color = Color3.fromRGB(196, 150, 96),
                        Material = Enum.Material.Wood,
                        CanCollide = false,
                }, parent)
        end
        part({ Name = "PancingMeja", Size = Vector3.new(6, 0.4, 3), CFrame = CFrame.new(x + 3, 2.2, z + 5.4), Color = Color3.fromRGB(150, 108, 66), Material = Enum.Material.WoodPlanks }, parent)
        for _, leg in { { -2.6, -1.2 }, { 2.6, -1.2 }, { -2.6, 1.2 }, { 2.6, 1.2 } } do
                part({ Name = "PancingMejaKaki", Size = Vector3.new(0.4, 2.1, 0.4), CFrame = CFrame.new(x + 3 + leg[1], 1.05, z + 5.4 + leg[2]), Color = Color3.fromRGB(150, 108, 66), Material = Enum.Material.Wood }, parent)
        end
        for i = 1, 3 do
                part({
                        Name = "PancingKotakUmpan" .. i,
                        Size = Vector3.new(1.6, 1, 1.2),
                        CFrame = CFrame.new(x + 1.4 + (i - 1) * 1.7, 2.9, z + 5.4),
                        Color = Color3.fromRGB(150 + i * 20, 170, 200),
                        Material = Enum.Material.SmoothPlastic,
                }, parent)
        end
        part({ Name = "PancingAkuariumKaca", Size = Vector3.new(9, 5, 3), CFrame = CFrame.new(x - 3, 6.5, z - 6.4), Color = Color3.fromRGB(180, 220, 240), Material = Enum.Material.Glass, Transparency = 0.55 }, parent)
        part({ Name = "PancingAkuariumAir", Size = Vector3.new(8.4, 4.2, 2.5), CFrame = CFrame.new(x - 3, 6.3, z - 6.4), Color = Color3.fromRGB(70, 150, 210), Material = Enum.Material.Glass, Transparency = 0.35, CanCollide = false }, parent)
        for i = 1, 3 do
                part({
                        Name = "PancingIkanHias" .. i,
                        Size = Vector3.new(1.2, 0.8, 0.5),
                        CFrame = CFrame.new(x - 6 + i * 2.4, 5.8 + (i % 2) * 1.2, z - 6.4) * CFrame.Angles(0, math.rad(i * 70), 0),
                        Color = Color3.fromHSV(i / 3, 0.7, 0.95),
                        Material = Enum.Material.SmoothPlastic,
                        CanCollide = false,
                }, parent)
        end
        part({ Name = "PancingTrofiRak", Size = Vector3.new(4.4, 0.4, 1.2), CFrame = CFrame.new(x + 6.4, 6.8, z + 1), Color = Color3.fromRGB(104, 90, 70), Material = Enum.Material.Wood }, parent)
        for i = 1, 2 do
                part({
                        Name = "PancingTrofi" .. i,
                        Size = Vector3.new(1.4, 0.9, 0.6),
                        CFrame = CFrame.new(x + 5.4 + i * 1.9, 7.5, z + 1) * CFrame.Angles(0, math.rad(i * 40 - 20), 0),
                        Color = Color3.fromRGB(240, 204, 108),
                        Material = Enum.Material.Metal,
                        CanCollide = false,
                }, parent)
        end
        infoPrompt(board, "RUANG PANCING", "Gudang pancing pribadimu - rak joran, meja umpan & akuarium ikan hias. Isi ruangan ini akan terus bertambah!")
end

local function buildKoperasi(index: number, center: Vector3, yawDeg: number, koperasiName: string, parent)
        local base = CFrame.new(center) * CFrame.Angles(0, math.rad(yawDeg), 0)
        part({ Name = "KoperasiLantai", Size = Vector3.new(14, 0.5, 12), CFrame = base * CFrame.new(0, 0.25, 0), Color = Color3.fromRGB(196, 188, 176), Material = Enum.Material.Concrete }, parent)
        for _, px in { -6, 6 } do
                for _, pz in { -5, 5 } do
                        part({ Name = "KoperasiTiang", Size = Vector3.new(0.8, 9, 0.8), CFrame = base * CFrame.new(px, 4.9, pz), Color = Color3.fromRGB(150, 108, 66), Material = Enum.Material.Wood }, parent)
                end
        end
        part({ Name = "KoperasiAtap", Size = Vector3.new(16, 1, 14), CFrame = base * CFrame.new(0, 10, 0), Color = Color3.fromRGB(178, 74, 60), Material = Enum.Material.Slate }, parent)
        part({ Name = "KoperasiKonter", Size = Vector3.new(9, 3.4, 2), CFrame = base * CFrame.new(0, 2.2, -3), Color = Color3.fromRGB(150, 108, 66), Material = Enum.Material.WoodPlanks }, parent)
        part({ Name = "KoperasiKonterAtas", Size = Vector3.new(10, 0.4, 2.6), CFrame = base * CFrame.new(0, 4.1, -3), Color = Color3.fromRGB(104, 78, 50), Material = Enum.Material.Wood }, parent)
        for i = 1, 2 do
                part({ Name = "KoperasiRak" .. i, Size = Vector3.new(2.6, 2, 1.2), CFrame = base * CFrame.new(-4 + (i - 1) * 8, 1.4, 3.6), Color = Color3.fromRGB(120, 92, 60), Material = Enum.Material.Wood }, parent)
                for g = 1, 3 do
                        part({
                                Name = "KoperasiBarang" .. i .. g,
                                Size = Vector3.new(0.9, 0.9, 0.9),
                                CFrame = base * CFrame.new(-4.8 + (i - 1) * 8 + g * 0.9, 2.4, 3.6),
                                Color = Color3.fromHSV((g + i) / 6, 0.55, 0.95),
                                Material = Enum.Material.SmoothPlastic,
                                CanCollide = false,
                        }, parent)
                end
        end
        local sign = part({
                Name = "KoperasiPapan",
                Size = Vector3.new(12, 3, 0.6),
                CFrame = base * CFrame.new(0, 12, -5.6),
                Color = Color3.fromRGB(34, 38, 52),
                Material = Enum.Material.SmoothPlastic,
        }, parent)
        surfaceText(sign, "KOPERASI", koperasiName, Color3.fromRGB(255, 209, 102))
        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Buka Koperasi"
        prompt.ObjectText = "Koperasi " .. koperasiName
        prompt.MaxActivationDistance = 10
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.Parent = sign
        prompt.Triggered:Connect(function(player: Player)
                Remotes.get("OpenKoperasi"):FireClient(player, koperasiName)
        end)
end

local function buildPond(center: Vector3, svc, parent)
        local terrain = workspace.Terrain
        terrain.WaterWaveSize = 0.14
        terrain.WaterWaveSpeed = 14
        terrain.WaterReflectance = 0.35
        terrain.WaterTransparency = 0.55
        terrain:FillBlock(CFrame.new(center.X, -3.6, center.Z), Vector3.new(44, 10, 36), Enum.Material.Air)
        terrain:FillBlock(CFrame.new(center.X, -5.1, center.Z), Vector3.new(50, 9.5, 42), Enum.Material.Sand)
        terrain:FillBlock(CFrame.new(center.X, -5.05, center.Z), Vector3.new(40, 9, 32), Enum.Material.Water)
        svc.Gather.buildPier(center + Vector3.new(14, 0, 0), Vector3.new(-1, 0, 0))
        local rng = Random.new(101 + math.floor(center.X))
        for i = 1, 4 do
                local ang = (i / 4) * math.pi * 2 + rng:NextNumber(-0.3, 0.3)
                local bx = center.X + math.cos(ang) * 21
                local bz = center.Z + math.sin(ang) * 17
                for s = -1, 1, 2 do
                        part({
                                Name = "Alang" .. i .. s,
                                Size = Vector3.new(0.24, 3.2, 0.24),
                                CFrame = CFrame.new(bx + s * 0.5, 1.4, bz),
                                Color = Color3.fromRGB(112, 156, 82),
                                Material = Enum.Material.Grass,
                                CanCollide = false,
                        }, parent)
                end
                part({
                        Name = "AlangKepala" .. i,
                        Size = Vector3.new(0.5, 1, 0.5),
                        CFrame = CFrame.new(bx, 3, bz),
                        Color = Color3.fromRGB(150, 116, 70),
                        Material = Enum.Material.SmoothPlastic,
                        CanCollide = false,
                }, parent)
        end
end

function PersonalWorldBuilder.buildShell(index: number)
        if built[index] then
                return
        end
        local hx, hz = Balance.homeCenter(index)
        local folder = lahanFolder(index)
        part({ Name = "LahanPlaza" .. index, Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.3, 26, 26), CFrame = CFrame.new(hx + 70, 0.16, hz) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(196, 188, 176), Material = Enum.Material.Granite }, folder)
        part({ Name = "LahanJalan" .. index, Size = Vector3.new(120, 0.24, 7), CFrame = CFrame.new(hx + 27, 0.12, hz), Color = Color3.fromRGB(186, 180, 170), Material = Enum.Material.Concrete }, folder)
        part({ Name = "LahanPagarU" .. index, Size = Vector3.new(196, 3, 2), CFrame = CFrame.new(hx, 1.5, hz - 89), Color = Color3.fromRGB(66, 122, 66), Material = Enum.Material.Grass }, folder)
        part({ Name = "LahanPagarS" .. index, Size = Vector3.new(196, 3, 2), CFrame = CFrame.new(hx, 1.5, hz + 89), Color = Color3.fromRGB(66, 122, 66), Material = Enum.Material.Grass }, folder)
        part({ Name = "LahanPagarB" .. index, Size = Vector3.new(2, 3, 180), CFrame = CFrame.new(hx - 99, 1.5, hz), Color = Color3.fromRGB(66, 122, 66), Material = Enum.Material.Grass }, folder)
        part({ Name = "LahanPagarT1" .. index, Size = Vector3.new(2, 3, 56), CFrame = CFrame.new(hx + 99, 1.5, hz - 61), Color = Color3.fromRGB(66, 122, 66), Material = Enum.Material.Grass }, folder)
        part({ Name = "LahanPagarT2" .. index, Size = Vector3.new(2, 3, 56), CFrame = CFrame.new(hx + 99, 1.5, hz + 61), Color = Color3.fromRGB(66, 122, 66), Material = Enum.Material.Grass }, folder)
        signBoard("LahanPapanInfo" .. index, Vector3.new(hx + 86, 0, hz + 14), 90, "LAHAN " .. index, "Belum dimiliki - masuk lewat gerbang!", Color3.fromRGB(96, 66, 38), folder)
        built[index] = false
end

function PersonalWorldBuilder.buildFull(index: number, svc, koperasiName: string): boolean
        if built[index] then
                return false
        end
        PersonalWorldBuilder.buildShell(index)
        built[index] = true
        local hx, hz = Balance.homeCenter(index)
        local C = Vector3.new(hx, 0, hz)
        local folder = lahanFolder(index)
        local at = function(dx: number, dy: number, dz: number)
                return C + Vector3.new(dx, dy, dz)
        end

        part({ Name = "LahanJalanCabangRumah", Size = Vector3.new(6, 0.24, 34), CFrame = at(-32, 0.12, -18), Color = Color3.fromRGB(186, 180, 170), Material = Enum.Material.Concrete }, folder)
        part({ Name = "LahanJalanCabangKebun", Size = Vector3.new(6, 0.24, 9), CFrame = at(-48, 0.12, 8.75), Color = Color3.fromRGB(186, 180, 170), Material = Enum.Material.Concrete }, folder)
        part({ Name = "LahanJalanRuangan", Size = Vector3.new(84, 0.24, 6), CFrame = at(34, 0.12, 46), Color = Color3.fromRGB(186, 180, 170), Material = Enum.Material.Concrete }, folder)

        buildHouse(at(-52, 0, -38), folder)
        svc.Farm.buildField(index, at(-48, 0.4, 48))
        buildPond(at(40, 0, -50), svc, folder)

        buildSurgeryRoom(at(6, 0, 62), folder)
        buildScienceRoom(at(34, 0, 62), folder)
        buildStartopiaRoom(at(62, 0, 62), folder)
        buildFishingRoom(at(88, 0, 62), folder)

        buildKoperasi(index, at(74, 0, -24), 90, koperasiName, folder)

        nameBoard(index, at(88, 0, 16), 90, folder)
        for _, pos in { at(84, 0, 11), at(84, 0, -11), at(-14, 0, 9), at(-45, 0, 26), at(37, 0, 44), at(45, 0, -27), at(62, 0, -12) } do
                lamp(pos, folder)
        end
        decorativeTree(at(0, 0, -78), 300 + index * 2, folder)
        decorativeTree(at(80, 0, -64), 300 + index * 2 + 1, folder)
        decorativeTree(at(-84, 0, -6), 307 + index * 2, folder)

        local rng = Random.new(500 + index)
        local flowerColors = {
                Color3.fromRGB(255, 120, 150), Color3.fromRGB(255, 210, 90),
                Color3.fromRGB(150, 200, 255), Color3.fromRGB(200, 140, 255),
        }
        local function blocked(fx: number, fz: number): boolean
                if math.abs(fz) < 7 then return true end
                if fx > -70 and fx < -34 and fz > -54 and fz < -22 then return true end
                if fx > -95 and fx < -1 and fz > 10 and fz < 86 then return true end
                if fx > -8 and fx < 100 and fz > 50 and fz < 74 then return true end
                if fx > 12 and fx < 66 and fz > -72 and fz < -28 then return true end
                if math.abs(fx - 70) < 17 and math.abs(fz) < 17 then return true end
                if math.abs(fz + 24) < 9 and fx > 64 and fx < 86 then return true end
                return false
        end
        for i = 1, 10 do
                local fx = rng:NextNumber(-92, 92)
                local fz = rng:NextNumber(-82, 82)
                if not blocked(fx, fz) then
                        part({
                                Name = "LahanBunga" .. i,
                                Shape = Enum.PartType.Ball,
                                Size = Vector3.new(1, 1, 1) * rng:NextNumber(0.8, 1.4),
                                CFrame = at(fx, 0.55, fz),
                                Color = flowerColors[rng:NextInteger(1, #flowerColors)],
                                Material = Enum.Material.Grass,
                                CanCollide = false,
                        }, folder)
                end
        end

        local sx, sz = Balance.landSpawn(index)
        local spawn = Instance.new("SpawnLocation")
        spawn.Name = "SpawnLahan" .. index
        spawn.Size = Vector3.new(6, 0.4, 6)
        spawn.CFrame = CFrame.new(sx, 0.4, sz)
        spawn.Anchored = true
        spawn.Transparency = 1
        spawn.CanCollide = false
        spawn.Neutral = true
        spawn.Duration = 0
        spawn.Parent = folder
        return true
end

function PersonalWorldBuilder.isBuilt(index: number): boolean
        return built[index] == true
end

return PersonalWorldBuilder
