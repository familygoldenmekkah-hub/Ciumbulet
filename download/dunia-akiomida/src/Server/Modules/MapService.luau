local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Remotes)
local Util = require(ReplicatedStorage.Shared.Util)
local Balance = require(ReplicatedStorage.Shared.Balance)
local CropConfig = require(ReplicatedStorage.Shared.CropConfig)
local DoorKit = require(script.Parent.DoorKit)

local MapService = {}

local folder = Instance.new("Folder")
folder.Name = "AKM_Dunia"

local function part(props): Part
        local p = Instance.new("Part")
        p.Anchored = true
        p.TopSurface = Enum.SurfaceType.Smooth
        p.BottomSurface = Enum.SurfaceType.Smooth
        for k, v in props do
                (p :: any)[k] = v
        end
        p.Parent = folder
        return p
end

local function surfaceText(board: Part, title: string, sub: string?, color: Color3)
        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Front
        gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        gui.PixelsPerStud = 50
        gui.Parent = board
        Util.create("TextLabel", {
                Size = sub and UDim2.fromScale(1, 0.62) or UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = color,
                Text = title,
        }, gui)
        if sub then
                Util.create("TextLabel", {
                        Position = UDim2.fromScale(0, 0.62),
                        Size = UDim2.fromScale(1, 0.38),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.Gotham,
                        TextScaled = true,
                        TextColor3 = Color3.fromRGB(214, 218, 228),
                        Text = sub,
                }, gui)
        end
end

local function buildLamp(position: Vector3)
        part({
                Name = "LampuTiang",
                Size = Vector3.new(0.7, 7, 0.7),
                CFrame = CFrame.new(position + Vector3.new(0, 3.5, 0)),
                Color = Color3.fromRGB(58, 62, 74),
                Material = Enum.Material.Metal,
        })
        part({
                Name = "LampuKepala",
                Shape = Enum.PartType.Ball,
                Size = Vector3.new(1.7, 1.7, 1.7),
                CFrame = CFrame.new(position + Vector3.new(0, 7.4, 0)),
                Color = Color3.fromRGB(255, 226, 160),
                Material = Enum.Material.Neon,
                CanCollide = false,
        })
end

local function buildTerrain()
        local terrain = workspace.Terrain
        terrain.WaterWaveSize = 0.16
        terrain.WaterWaveSpeed = 16
        terrain.WaterReflectance = 0.4
        terrain.WaterTransparency = 0.6

        terrain:FillBlock(CFrame.new(260, -7, 0), Vector3.new(3400, 12, 3000), Enum.Material.Water)

        for _, r in ipairs(Balance.Regions) do
                local cx, cz = r.center[1], r.center[2]
                local hx, hz = r.half[1], r.half[2]
                terrain:FillBlock(CFrame.new(cx, -5.1, cz), Vector3.new(hx * 2 + 14, 9.5, hz * 2 + 14), Enum.Material.Sand)
                terrain:FillBlock(CFrame.new(cx, -5, cz), Vector3.new(hx * 2, 10, hz * 2), Enum.Material.Grass)
        end
end

local function seedPacketRow(center: Vector3, yawDeg: number, count: number, palette: { Color3 }, rng)
        local base = CFrame.new(center) * CFrame.Angles(0, math.rad(yawDeg), 0)
        for i = 1, count do
                local c = palette[(i - 1) % #palette + 1]
                part({
                        Name = "KemasanBenih",
                        Size = Vector3.new(0.85, 1.25, 0.22),
                        CFrame = base * CFrame.new((i - (count + 1) / 2) * 1.15, 0.62, 0) * CFrame.Angles(rng:NextNumber(-0.12, 0.12), 0, rng:NextNumber(-0.08, 0.08)),
                        Color = c,
                        Material = Enum.Material.SmoothPlastic,
                        CanCollide = false,
                })
                part({
                        Name = "KemasanLipatan",
                        Size = Vector3.new(0.85, 0.16, 0.24),
                        CFrame = base * CFrame.new((i - (count + 1) / 2) * 1.15, 1.32, 0),
                        Color = c:Lerp(Color3.new(0, 0, 0), 0.25),
                        Material = Enum.Material.SmoothPlastic,
                        CanCollide = false,
                })
        end
end

local function displayPlanter(center: Vector3, cropId: string)
        local crop = CropConfig.byId(cropId)
        local color = crop and Color3.fromRGB(crop.color[1], crop.color[2], crop.color[3]) or Color3.fromRGB(120, 200, 90)
        part({
                Name = "PlanterKotak",
                Size = Vector3.new(4.4, 1.4, 2.2),
                CFrame = CFrame.new(center + Vector3.new(0, 0.7, 0)),
                Color = Color3.fromRGB(134, 100, 66),
                Material = Enum.Material.Wood,
        })
        part({
                Name = "PlanterTanah",
                Size = Vector3.new(4, 0.3, 1.8),
                CFrame = CFrame.new(center + Vector3.new(0, 1.5, 0)),
                Color = Color3.fromRGB(96, 72, 50),
                Material = Enum.Material.Ground,
        })
        for i = 1, 3 do
                part({
                        Name = "PlanterTanaman" .. i,
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(1.5, 1.8, 1.5),
                        CFrame = CFrame.new(center + Vector3.new(-1.3 + (i - 1) * 1.3, 2.3, 0)),
                        Color = color,
                        Material = Enum.Material.Grass,
                        CanCollide = false,
                })
                part({
                        Name = "PlanterBuah" .. i,
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(0.7, 0.7, 0.7),
                        CFrame = CFrame.new(center + Vector3.new(-1.3 + (i - 1) * 1.3, 3.3, 0.3)),
                        Color = color:Lerp(Color3.new(1, 1, 1), 0.2),
                        Material = Enum.Material.SmoothPlastic,
                        CanCollide = false,
                })
        end
end

local function buildTokoBenih(svc)
        local X, Z = -60, -28
        local wallC = Color3.fromRGB(236, 226, 204)
        local woodC = Color3.fromRGB(120, 88, 56)
        local roofC = Color3.fromRGB(88, 122, 74)

        part({ Name = "TokoLantai", Size = Vector3.new(28, 0.5, 24), CFrame = CFrame.new(X, 0.25, Z), Color = Color3.fromRGB(178, 138, 92), Material = Enum.Material.WoodPlanks })
        part({ Name = "TokoDindingB", Size = Vector3.new(1, 20, 24), CFrame = CFrame.new(X - 14, 10, Z), Color = wallC, Material = Enum.Material.WoodPlanks })
        part({ Name = "TokoDindingU", Size = Vector3.new(28, 20, 1), CFrame = CFrame.new(X, 10, Z - 12), Color = wallC, Material = Enum.Material.WoodPlanks })
        part({ Name = "TokoDindingS", Size = Vector3.new(28, 20, 1), CFrame = CFrame.new(X, 10, Z + 12), Color = wallC, Material = Enum.Material.WoodPlanks })
        part({ Name = "TokoDindingDU", Size = Vector3.new(1, 20, 9.2), CFrame = CFrame.new(X + 14, 10, Z - 7.4), Color = wallC, Material = Enum.Material.WoodPlanks })
        part({ Name = "TokoDindingDS", Size = Vector3.new(1, 20, 9.2), CFrame = CFrame.new(X + 14, 10, Z + 7.4), Color = wallC, Material = Enum.Material.WoodPlanks })
        part({ Name = "TokoPalangPintu", Size = Vector3.new(1, 10, 4.6), CFrame = CFrame.new(X + 14, 15, Z), Color = wallC, Material = Enum.Material.WoodPlanks })
        DoorKit.frame(Vector3.new(X + 14, 0, Z), 90, folder, DoorKit.DOOR_WIDTH, DoorKit.DOOR_HEIGHT)
        DoorKit.hinged(Vector3.new(X + 14, 0, Z), 90, folder, DoorKit.DOOR_WIDTH, DoorKit.DOOR_HEIGHT, Color3.fromRGB(104, 140, 78))

        for _, side in { -1, 1 } do
                part({
                        Name = "TokoJendela" .. side,
                        Size = Vector3.new(9, 6, 0.5),
                        CFrame = CFrame.new(X - 5, 12, Z + side * 11.6),
                        Color = Color3.fromRGB(172, 216, 236),
                        Material = Enum.Material.Glass,
                        Transparency = 0.45,
                })
                part({
                        Name = "TokoJendelaDepan" .. side,
                        Size = Vector3.new(0.5, 6, 8),
                        CFrame = CFrame.new(X + 13.6, 12, Z + side * 7.4),
                        Color = Color3.fromRGB(172, 216, 236),
                        Material = Enum.Material.Glass,
                        Transparency = 0.45,
                })
        end

        part({ Name = "TokoAtap", Size = Vector3.new(31, 1.4, 27), CFrame = CFrame.new(X, 20.7, Z), Color = roofC, Material = Enum.Material.Slate })
        part({ Name = "TokoAtapKedua", Size = Vector3.new(24, 1.2, 20), CFrame = CFrame.new(X, 22, Z), Color = roofC:Lerp(Color3.new(1, 1, 1), 0.1), Material = Enum.Material.Slate })
        part({ Name = "TokoLengkungDepan", Size = Vector3.new(18, 0.8, 6), CFrame = CFrame.new(X + 14, 4.6, Z) * CFrame.Angles(0, 0, math.rad(10)), Color = roofC, Material = Enum.Material.Fabric, CanCollide = false })
        part({ Name = "TokoGagangLengkung1", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.4, 7, 0.4), CFrame = CFrame.new(X + 17.5, 2.2, Z - 2.4) * CFrame.Angles(math.rad(90), 0, 0), Color = woodC, Material = Enum.Material.Wood })
        part({ Name = "TokoGagangLengkung2", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.4, 7, 0.4), CFrame = CFrame.new(X + 17.5, 2.2, Z + 2.4) * CFrame.Angles(math.rad(90), 0, 0), Color = woodC, Material = Enum.Material.Wood })

        local sign = part({
                Name = "TokoPapanNama",
                Size = Vector3.new(14, 3.4, 0.7),
                CFrame = CFrame.new(X + 14.6, 17.4, Z) * CFrame.Angles(0, math.rad(90), 0),
                Color = Color3.fromRGB(52, 64, 44),
                Material = Enum.Material.Wood,
        })
        surfaceText(sign, "TOKO BENIH", "Bibit berkualitas untuk kebunmu", Color3.fromRGB(190, 236, 150))

        part({ Name = "TokoKonter", Size = Vector3.new(12, 3.4, 2.4), CFrame = CFrame.new(X + 8, 2.2, Z + 3), Color = Color3.fromRGB(150, 108, 66), Material = Enum.Material.WoodPlanks })
        part({ Name = "TokoKonterAtas", Size = Vector3.new(13, 0.4, 3), CFrame = CFrame.new(X + 8, 4.1, Z + 3), Color = Color3.fromRGB(70, 72, 80), Material = Enum.Material.Slate })
        part({ Name = "TokoKasir", Size = Vector3.new(1.8, 1.2, 1.4), CFrame = CFrame.new(X + 11.4, 4.9, Z + 3), Color = Color3.fromRGB(60, 64, 76), Material = Enum.Material.Metal })
        part({ Name = "TokoKasirLayar", Size = Vector3.new(1.4, 1, 0.2), CFrame = CFrame.new(X + 11.4, 5.9, Z + 3.4) * CFrame.Angles(math.rad(-18), 0, 0), Color = Color3.fromRGB(140, 220, 170), Material = Enum.Material.Neon, CanCollide = false })
        part({ Name = "TokoTimbangan", Size = Vector3.new(1, 0.9, 1), CFrame = CFrame.new(X + 4.8, 4.8, Z + 3), Color = Color3.fromRGB(220, 224, 228), Material = Enum.Material.Metal })

        local rng = Random.new(4242)
        local palettes = {
                { Color3.fromRGB(178, 182, 190), Color3.fromRGB(150, 156, 168), Color3.fromRGB(200, 204, 212) },
                { Color3.fromRGB(104, 172, 242), Color3.fromRGB(140, 196, 250), Color3.fromRGB(90, 150, 220) },
                { Color3.fromRGB(188, 124, 246), Color3.fromRGB(210, 160, 250), Color3.fromRGB(160, 100, 220) },
        }
        local shelfX = { X - 10.5, X - 4.5, X + 1.5 }
        local rarityNames = { "COMMON", "RARE", "EPIC" }
        for i = 1, 3 do
                local sx = shelfX[i]
                part({ Name = "RakBenihDudukan" .. i, Size = Vector3.new(9, 0.5, 2.2), CFrame = CFrame.new(sx, 3.6, Z - 8.6), Color = woodC, Material = Enum.Material.Wood })
                part({ Name = "RakBenihDinding" .. i, Size = Vector3.new(9, 0.5, 2.2), CFrame = CFrame.new(sx, 7.4, Z - 8.6), Color = woodC, Material = Enum.Material.Wood })
                part({ Name = "RakBenihPunggung" .. i, Size = Vector3.new(9, 9, 0.4), CFrame = CFrame.new(sx, 5.6, Z - 9.7), Color = woodC:Lerp(Color3.new(0, 0, 0), 0.2), Material = Enum.Material.Wood })
                seedPacketRow(Vector3.new(sx, 3.85, Z - 8.6), 0, 6, palettes[i], rng)
                seedPacketRow(Vector3.new(sx, 7.65, Z - 8.6), 0, 6, palettes[i], rng)
                local tag = part({
                        Name = "RakLabel" .. i,
                        Size = Vector3.new(2.6, 1, 0.3),
                        CFrame = CFrame.new(sx, 9.4, Z - 9.3),
                        Color = Color3.fromRGB(34, 38, 46),
                        Material = Enum.Material.SmoothPlastic,
                        CanCollide = false,
                })
                surfaceText(tag, rarityNames[i], nil, Color3.fromRGB(255, 226, 150))
        end

        part({ Name = "RakPotDudukan", Size = Vector3.new(8, 0.5, 2), CFrame = CFrame.new(X - 8, 3.2, Z + 8.4), Color = woodC, Material = Enum.Material.Wood })
        for i = 1, 4 do
                part({
                        Name = "PotTanah" .. i,
                        Shape = Enum.PartType.Cylinder,
                        Size = Vector3.new(1.1, 1.5, 1.5),
                        CFrame = CFrame.new(X - 10.5 + (i - 1) * 1.7, 4, Z + 8.4) * CFrame.Angles(0, 0, math.rad(90)),
                        Color = Color3.fromRGB(160, 116, 76),
                        Material = Enum.Material.SmoothPlastic,
                })
        end

        displayPlanter(Vector3.new(X - 11, 0, Z + 1), "wortel")
        displayPlanter(Vector3.new(X - 11, 0, Z - 3), "jeruk_mandarin")
        displayPlanter(Vector3.new(X - 6.5, 0, Z + 1), "tangelo")

        for i = 1, 3 do
                part({
                        Name = "TokoLampuGantungTali" .. i,
                        Size = Vector3.new(0.15, 2, 0.15),
                        CFrame = CFrame.new(X - 6 + (i - 1) * 7, 17.6, Z),
                        Color = Color3.fromRGB(70, 70, 76),
                        Material = Enum.Material.Metal,
                        CanCollide = false,
                })
                part({
                        Name = "TokoLampuGantung" .. i,
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(1.5, 1.5, 1.5),
                        CFrame = CFrame.new(X - 6 + (i - 1) * 7, 16.4, Z),
                        Color = Color3.fromRGB(255, 226, 160),
                        Material = Enum.Material.Neon,
                        CanCollide = false,
                })
        end

        local priceBoard = part({
                Name = "TokoPapanHarga",
                Size = Vector3.new(11, 7, 0.4),
                CFrame = CFrame.new(X - 13.6, 12, Z - 5) * CFrame.Angles(0, math.rad(90), 0),
                Color = Color3.fromRGB(44, 40, 34),
                Material = Enum.Material.Wood,
        })
        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Front
        gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        gui.PixelsPerStud = 42
        gui.Parent = priceBoard
        Util.create("TextLabel", {
                Size = UDim2.fromScale(1, 0.24),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = Color3.fromRGB(255, 226, 150),
                Text = "HARGA PACK (3 BENIH ACAK)",
        }, gui)
        local rows = {
                { "PACK COMMON - 400 MICDA", Color3.fromRGB(178, 182, 190) },
                { "PACK RARE - 1.500 MICDA", Color3.fromRGB(104, 172, 242) },
                { "PACK EPIC - 3.500 MICDA", Color3.fromRGB(188, 124, 246) },
        }
        for i, row in ipairs(rows) do
                Util.create("TextLabel", {
                        Position = UDim2.fromScale(0, 0.24 + (i - 1) * 0.25),
                        Size = UDim2.fromScale(1, 0.25),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextScaled = true,
                        TextColor3 = row[2],
                        Text = row[1],
                }, gui)
        end

        local counterPromptPart = part({
                Name = "TokoBantuBelanja",
                Shape = Enum.PartType.Ball,
                Size = Vector3.new(1.6, 1.6, 1.6),
                CFrame = CFrame.new(X + 9.6, 5.4, Z + 3),
                Color = Color3.fromRGB(150, 220, 130),
                Material = Enum.Material.SmoothPlastic,
        })
        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Belanja Benih"
        prompt.ObjectText = "Toko Benih"
        prompt.MaxActivationDistance = 11
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.Parent = counterPromptPart
        prompt.Triggered:Connect(function(player: Player)
                Remotes.get("OpenToko"):FireClient(player)
        end)
end

local function warningSign(pos: Vector3, text: string)
        local board = part({
                Name = "PapanPeringatan",
                Size = Vector3.new(9, 2.6, 0.5),
                CFrame = CFrame.new(pos + Vector3.new(0, 3.6, 0)) * CFrame.Angles(0, math.rad(90), 0),
                Color = Color3.fromRGB(96, 66, 38),
                Material = Enum.Material.WoodPlanks,
        })
        part({
                Name = "PapanPeringatanTiang",
                Size = Vector3.new(0.6, 2.6, 0.6),
                CFrame = CFrame.new(pos + Vector3.new(0, 1.3, 0)),
                Color = Color3.fromRGB(96, 66, 38),
                Material = Enum.Material.WoodPlanks,
        })
        surfaceText(board, text, nil, Color3.fromRGB(255, 160, 140))
end

local function buildStation(pos: Vector3, yawDeg: number, station: string, svc, label: string)
        local base = CFrame.new(pos) * CFrame.Angles(0, math.rad(yawDeg), 0)
        if station == "tempa" then
                part({ Name = "TempaLandasan", Size = Vector3.new(10, 0.5, 8), CFrame = base * CFrame.new(0, 0.25, 0), Color = Color3.fromRGB(88, 90, 98), Material = Enum.Material.Slate })
                part({ Name = "TempaAnvil", Size = Vector3.new(3, 1.6, 1.6), CFrame = base * CFrame.new(0, 1.8, 0), Color = Color3.fromRGB(52, 54, 62), Material = Enum.Material.Metal })
                part({ Name = "TempaAnvilTunggal", Shape = Enum.PartType.Cylinder, Size = Vector3.new(1.6, 1, 1), CFrame = base * CFrame.new(1.8, 1.8, 0) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(52, 54, 62), Material = Enum.Material.Metal })
                part({ Name = "TempaTungku", Size = Vector3.new(2.6, 3, 2.6), CFrame = base * CFrame.new(-3.4, 2, -1.4), Color = Color3.fromRGB(64, 56, 52), Material = Enum.Material.Rock })
                part({ Name = "TempaApi", Shape = Enum.PartType.Ball, Size = Vector3.new(1.8, 2.2, 1.8), CFrame = base * CFrame.new(-3.4, 4, -1.4), Color = Color3.fromRGB(255, 150, 70), Material = Enum.Material.Neon, CanCollide = false })
        else
                part({ Name = "DapurLandasan", Size = Vector3.new(10, 0.5, 8), CFrame = base * CFrame.new(0, 0.25, 0), Color = Color3.fromRGB(126, 100, 70), Material = Enum.Material.Ground })
                for i = -1, 1 do
                        part({ Name = "DapurKayuApi" .. i, Size = Vector3.new(3.4, 0.7, 0.9), CFrame = base * CFrame.new(0, 0.8 + i * 0.55, 0) * CFrame.Angles(0, math.rad(i * 55), 0), Color = Color3.fromRGB(104, 78, 52), Material = Enum.Material.Wood })
                end
                part({ Name = "DapurApi", Shape = Enum.PartType.Ball, Size = Vector3.new(2.2, 2.6, 2.2), CFrame = base * CFrame.new(0, 1.8, 0), Color = Color3.fromRGB(255, 150, 70), Material = Enum.Material.Neon, CanCollide = false })
                part({ Name = "DapurPanci", Shape = Enum.PartType.Cylinder, Size = Vector3.new(1.6, 3, 3), CFrame = base * CFrame.new(0, 3.4, 0) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(70, 74, 84), Material = Enum.Material.Metal })
        end
        local sign = part({
                Name = "StasiunPapan",
                Size = Vector3.new(8, 2.4, 0.5),
                CFrame = base * CFrame.new(0, 6.4, -4.2),
                Color = Color3.fromRGB(52, 44, 36),
                Material = Enum.Material.Wood,
        })
        surfaceText(sign, label, nil, Color3.fromRGB(255, 200, 140))
        local prompt = Instance.new("ProximityPrompt")
        prompt.MaxActivationDistance = 11
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.Parent = sign
        svc.Craft.bindStation(prompt, station)
end

local function buildMonsterIslands(svc)
        local P = Vector3.new(640, 0, -320)
        buildStation(P + Vector3.new(30, 0, 66), 180, "dapur", svc, "DAPUR ALAM - BU MASAK")
        warningSign(P + Vector3.new(-96, 0, 0), "PADANG LIAR - MONSTER LV 1-3")
        local rng = Random.new(911)
        for i = 1, 6 do
                part({
                        Name = "PadangBatu",
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(1, 1, 1) * rng:NextNumber(2.4, 4.6),
                        CFrame = CFrame.new(P + Vector3.new(rng:NextNumber(-100, 100), 0.6, rng:NextNumber(-100, 100))),
                        Color = Color3.fromRGB(128, 126, 122),
                        Material = Enum.Material.Slate,
                })
        end
        for i = 1, 4 do
                part({
                        Name = "PadangPohonBatang",
                        Size = Vector3.new(1.2, rng:NextNumber(7, 10), 1.2),
                        CFrame = CFrame.new(P + Vector3.new(rng:NextNumber(-110, 110), 4.4, rng:NextNumber(-110, 110))),
                        Color = Color3.fromRGB(112, 88, 60),
                        Material = Enum.Material.Wood,
                })
        end

        local H = Vector3.new(640, 0, 60)
        warningSign(H + Vector3.new(-96, 0, 0), "HUTAN BAYANG - MONSTER LV 3-5")
        for i = 1, 10 do
                local ang = (i / 10) * math.pi * 2
                local d = 62 + (i % 3) * 24
                part({
                        Name = "BayangBatang",
                        Size = Vector3.new(1.6, 11, 1.6),
                        CFrame = CFrame.new(H + Vector3.new(math.cos(ang) * d, 5.5, math.sin(ang) * d)),
                        Color = Color3.fromRGB(70, 60, 66),
                        Material = Enum.Material.Wood,
                })
                part({
                        Name = "BayangDedaun",
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(9, 7, 9),
                        CFrame = CFrame.new(H + Vector3.new(math.cos(ang) * d, 12.5, math.sin(ang) * d)),
                        Color = Color3.fromRGB(52, 84, 62),
                        Material = Enum.Material.Grass,
                })
        end

        local B = Vector3.new(760, 0, 560)
        buildStation(Vector3.new(605, 0, 466), 0, "tempa", svc, "PANDAI BESI - PAK TEMPA")
        warningSign(B + Vector3.new(-196, 0, 0), "NEGERI BAJA & KRISTAL - MONSTER LV 5+")
        part({
                Name = "BajaLantai",
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(0.25, 60, 60),
                CFrame = CFrame.new(605, 0.14, 430) * CFrame.Angles(0, 0, math.rad(90)),
                Color = Color3.fromRGB(96, 98, 106),
                Material = Enum.Material.Slate,
        })
        for i = 1, 4 do
                part({
                        Name = "BajaBatuBesar",
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(1, 1, 1) * (5 + i),
                        CFrame = CFrame.new(605 + (i % 2 == 0 and 18 or -20), 2 + i * 0.4, 430 + (i < 3 and 20 or -18)),
                        Color = Color3.fromRGB(118, 120, 128),
                        Material = Enum.Material.Rock,
                })
        end
        local gx, gz = 920, 430
        part({
                Name = "GuaLantai",
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(0.25, 64, 64),
                CFrame = CFrame.new(gx, 0.14, gz) * CFrame.Angles(0, 0, math.rad(90)),
                Color = Color3.fromRGB(58, 62, 78),
                Material = Enum.Material.Slate,
        })
        for i = 1, 10 do
                local ang = (i / 10) * math.pi * 2
                local diff = math.abs(math.atan2(math.sin(ang - math.pi), math.cos(ang - math.pi)))
                if diff > math.pi / 10 then
                        part({
                                Name = "GuaDinding",
                                Size = Vector3.new(22, 11, 3),
                                CFrame = CFrame.new(gx + math.cos(ang) * 32, 5.5, gz + math.sin(ang) * 32)
                                        * CFrame.Angles(0, -math.deg(ang) + 90, 0),
                                Color = Color3.fromRGB(66, 68, 84),
                                Material = Enum.Material.Rock,
                        })
                end
        end
        local rngK = Random.new(55)
        for i = 1, 8 do
                local ang = (i / 8) * math.pi * 2 + rngK:NextNumber(-0.2, 0.2)
                local d = rngK:NextNumber(8, 18)
                local h = rngK:NextNumber(4, 9)
                part({
                        Name = "GuaKristal",
                        Size = Vector3.new(2.4, h, 2.4),
                        CFrame = CFrame.new(gx + math.cos(ang) * d, h / 2, gz + math.sin(ang) * d)
                                * CFrame.Angles(rngK:NextNumber(-0.3, 0.3), 0, rngK:NextNumber(-0.3, 0.3)),
                        Color = Color3.fromRGB(190, 120, 255),
                        Material = Enum.Material.Neon,
                        Transparency = 0.25,
                        CanCollide = false,
                })
        end
        local ax, az = 760, 650
        part({
                Name = "ArenaLantai",
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(0.3, 76, 76),
                CFrame = CFrame.new(ax, 0.16, az) * CFrame.Angles(0, 0, math.rad(90)),
                Color = Color3.fromRGB(196, 176, 150),
                Material = Enum.Material.Sand,
        })
        for i = 1, 12 do
                local ang = ((i - 0.5) / 12) * math.pi * 2
                local diffU = math.abs(math.atan2(math.sin(ang + math.pi / 2), math.cos(ang + math.pi / 2)))
                local diffS = math.abs(math.atan2(math.sin(ang - math.pi / 2), math.cos(ang - math.pi / 2)))
                if diffU > math.pi / 12 and diffS > math.pi / 12 then
                        part({
                                Name = "ArenaDinding",
                                Size = Vector3.new(20, 9, 2.6),
                                CFrame = CFrame.new(ax + math.cos(ang) * 38, 4.5, az + math.sin(ang) * 38)
                                        * CFrame.Angles(0, -math.deg(ang) + 90, 0),
                                Color = Color3.fromRGB(150, 132, 110),
                                Material = Enum.Material.Slate,
                        })
                end
        end
        for i = 1, 6 do
                local ang = (i / 6) * math.pi * 2
                part({
                        Name = "ArenaObor",
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(1.6, 1.6, 1.6),
                        CFrame = CFrame.new(ax + math.cos(ang) * 32, 8.6, az + math.sin(ang) * 32),
                        Color = Color3.fromRGB(255, 140, 70),
                        Material = Enum.Material.Neon,
                        CanCollide = false,
                })
        end
end

local function buildPusatKota(svc)
        part({
                Name = "PlazaPusat",
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(0.3, 34, 34),
                CFrame = CFrame.new(0, 0.16, 0) * CFrame.Angles(0, 0, math.rad(90)),
                Color = Color3.fromRGB(196, 188, 176),
                Material = Enum.Material.Granite,
        })
        part({
                Name = "AirMancurDasar",
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(0.5, 10, 10),
                CFrame = CFrame.new(0, 0.4, 0) * CFrame.Angles(0, 0, math.rad(90)),
                Color = Color3.fromRGB(170, 176, 186),
                Material = Enum.Material.Concrete,
        })
        part({
                Name = "AirMancurAir",
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(0.3, 9, 9),
                CFrame = CFrame.new(0, 0.55, 0) * CFrame.Angles(0, 0, math.rad(90)),
                Color = Color3.fromRGB(120, 190, 235),
                Material = Enum.Material.Glass,
                Transparency = 0.25,
        })
        part({
                Name = "AirMancurTiang",
                Size = Vector3.new(1, 5, 1),
                CFrame = CFrame.new(0, 3, 0),
                Color = Color3.fromRGB(170, 176, 186),
                Material = Enum.Material.Concrete,
        })
        part({
                Name = "AirMancurBola",
                Shape = Enum.PartType.Ball,
                Size = Vector3.new(2.4, 2.4, 2.4),
                CFrame = CFrame.new(0, 6, 0),
                Color = Color3.fromRGB(255, 226, 160),
                Material = Enum.Material.Neon,
                CanCollide = false,
        })

        for _, pos in {
                Vector3.new(-14, 0, 14), Vector3.new(14, 0, 14), Vector3.new(-14, 0, -14), Vector3.new(14, 0, -14),
                Vector3.new(120, 0, -60), Vector3.new(120, 0, 40), Vector3.new(120, 0, 130), Vector3.new(0, 0, 118),
        } do
                buildLamp(pos)
        end

        local sign = part({
                Name = "PapanPusatKota",
                Size = Vector3.new(13, 3, 0.7),
                CFrame = CFrame.new(0, 5.2, 126) * CFrame.Angles(0, math.rad(180), 0),
                Color = Color3.fromRGB(52, 64, 44),
                Material = Enum.Material.Wood,
        })
        surfaceText(sign, "PUSAT KOTA", "Toko Benih di sebelah barat - gerbang lahanmu di utara!", Color3.fromRGB(190, 236, 150))

        buildTokoBenih(svc)

        local spawnLoc = Instance.new("SpawnLocation")
        spawnLoc.Name = "SpawnPusat"
        spawnLoc.Size = Vector3.new(10, 0.4, 10)
        spawnLoc.CFrame = CFrame.new(0, 0.4, 22)
        spawnLoc.Anchored = true
        spawnLoc.Transparency = 0.35
        spawnLoc.Color = Color3.fromRGB(240, 220, 150)
        spawnLoc.Material = Enum.Material.Neon
        spawnLoc.Neutral = true
        spawnLoc.Duration = 0
        spawnLoc.Parent = folder
end

function MapService.init(svc)
        folder.Parent = workspace

        local atmo = Instance.new("Atmosphere")
        atmo.Density = 0.14
        atmo.Offset = 0.2
        atmo.Color = Color3.fromRGB(205, 215, 235)
        atmo.Glare = 0.15
        atmo.Haze = 0.8
        atmo.Parent = game:GetService("Lighting")

        local rngAwan = Random.new(77)
        for i = 1, 6 do
                part({
                        Name = "Awan",
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(1, 1, 1) * rngAwan:NextNumber(28, 56),
                        CFrame = CFrame.new(rngAwan:NextNumber(-400, 400), rngAwan:NextNumber(85, 125), rngAwan:NextNumber(-500, 500)),
                        Color = Color3.new(1, 1, 1),
                        Material = Enum.Material.SmoothPlastic,
                        Transparency = 0.35,
                        CanCollide = false,
                })
        end

        buildTerrain()
        buildPusatKota(svc)
        buildMonsterIslands(svc)

        local PersonalWorldBuilder = require(script.Parent.PersonalWorldBuilder)
        for i = 1, Balance.HOME_COUNT do
                PersonalWorldBuilder.buildShell(i)
        end

        print("[AKIOMIDA] Dunia v7 siap: Pusat Kota (Toko Benih), 3 pulau monster, "
                .. Balance.HOME_COUNT .. " lahan pribadi (rumah 3 lantai + rooftop, kebun 500 petak, "
                .. "kolam air sungguhan, ruang Bedah/Sains/Startopia/Pancing, koperasi).")
end

return MapService
