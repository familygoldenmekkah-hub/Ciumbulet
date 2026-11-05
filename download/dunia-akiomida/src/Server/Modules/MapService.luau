--!nonstrict
--[[
        MapService.luau - DUNIA AKIOMIDA v2 (dunia petualangan ekonomi)
        Tata kota pulau 640x640, semuanya original & prosedural:
          Alun-alun pusat : air mancur, gerbang judul, papan juara, Kak Pintar
          Pasar Timur     : Toko Bibit, Pasar Pengepul, Toko Alat, Toko Peliharaan
          Ladang Utara    : 6 ladang pribadi 4x4 petak (klaim gratis)
          Hutan Barat     : pohon bisa ditebang (kayu, apel)
          Tambang Selatan : batu / besi / kristal (butuh belik makin bagus)
          Danau Tenang    : dermaga memancing
        Jalan penghubung, lampu jalan, bangku, bunga, awan, perbukitan.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)

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

--------------------------------------------------------------------
-- DEKORASI DASAR
--------------------------------------------------------------------

local function buildLamp(position: Vector3)
        part({
                Name = "LampuTiang",
                Size = Vector3.new(0.7, 9, 0.7),
                CFrame = CFrame.new(position + Vector3.new(0, 4.5, 0)),
                Color = Color3.fromRGB(52, 56, 70),
                Material = Enum.Material.Metal,
        })
        local head = part({
                Name = "LampuKepala",
                Shape = Enum.PartType.Ball,
                Size = Vector3.new(1.7, 1.7, 1.7),
                CFrame = CFrame.new(position + Vector3.new(0, 9.4, 0)),
                Color = Color3.fromRGB(255, 226, 160),
                Material = Enum.Material.Neon,
        })
        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(255, 214, 150)
        light.Range = 20
        light.Brightness = 1.1
        light.Parent = head
end

local function buildSign(text: string, position: Vector3, yawDeg: number, color: Color3?)
        local c = color or Color3.fromRGB(92, 62, 38)
        part({
                Name = "PapanTiang",
                Size = Vector3.new(0.7, 4.4, 0.7),
                CFrame = CFrame.new(position + Vector3.new(0, 2.2, 0)),
                Color = c,
                Material = Enum.Material.WoodPlanks,
        })
        local board = part({
                Name = "PapanTulisan",
                Size = Vector3.new(10, 2.6, 0.6),
                CFrame = CFrame.new(position + Vector3.new(0, 5.2, 0)) * CFrame.Angles(0, math.rad(yawDeg), 0),
                Color = c,
                Material = Enum.Material.WoodPlanks,
        })
        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Front
        gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        gui.PixelsPerStud = 50
        gui.Parent = board
        Util.create("TextLabel", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = Color3.fromRGB(255, 226, 150),
                Text = text,
        }, board)
        return board
end

local function buildBench(position: Vector3, yawDeg: number)
        local base = CFrame.new(position) * CFrame.Angles(0, math.rad(yawDeg), 0)
        part({
                Name = "BangkuDuduk",
                Size = Vector3.new(4.4, 0.8, 1.8),
                CFrame = base * CFrame.new(0, 1.1, 0),
                Color = Color3.fromRGB(150, 108, 66),
                Material = Enum.Material.WoodPlanks,
        })
        part({
                Name = "BangkuSandaran",
                Size = Vector3.new(4.4, 1.6, 0.5),
                CFrame = base * CFrame.new(0, 2.2, -0.7),
                Color = Color3.fromRGB(150, 108, 66),
                Material = Enum.Material.WoodPlanks,
        })
end

--------------------------------------------------------------------
-- NPC (karya original: tubuh kotak + kepala bulat + topi)
--------------------------------------------------------------------

local function buildNPC(name: string, position: Vector3, color: Color3): ProximityPrompt
        part({
                Name = "NPC_Badan_" .. name,
                Size = Vector3.new(2.4, 3.2, 1.7),
                CFrame = CFrame.new(position + Vector3.new(0, 1.9, 0)),
                Color = color,
                Material = Enum.Material.SmoothPlastic,
        })
        local head = part({
                Name = "NPC_Kepala_" .. name,
                Shape = Enum.PartType.Ball,
                Size = Vector3.new(2, 2, 2),
                CFrame = CFrame.new(position + Vector3.new(0, 4.5, 0)),
                Color = Color3.fromRGB(255, 224, 189),
                Material = Enum.Material.SmoothPlastic,
        })
        part({
                Name = "NPC_Topi_" .. name,
                Size = Vector3.new(2.6, 0.7, 2.6),
                CFrame = CFrame.new(position + Vector3.new(0, 5.7, 0)),
                Color = color:Lerp(Color3.new(0, 0, 0), 0.3),
                Material = Enum.Material.SmoothPlastic,
        })

        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 160, 0, 36)
        billboard.StudsOffset = Vector3.new(0, 1.4, 0)
        billboard.AlwaysOnTop = true
        billboard.MaxDistance = 70
        billboard.Parent = head
        Util.create("TextLabel", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = color,
                TextStrokeTransparency = 0.4,
                Text = name,
        }, billboard)

        local prompt = Instance.new("ProximityPrompt")
        prompt.MaxActivationDistance = 11
        prompt.HoldDuration = 0
        prompt.Parent = head
        return prompt
end

--------------------------------------------------------------------
-- GEDUNG TOKO (pasar timur, menghadap barat ke alun-alun)
--------------------------------------------------------------------

local function buildShop(position: Vector3, wallColor: Color3, roofColor: Color3, title: string)
        local x, y, z = position.X, position.Y, position.Z
        -- bangunan utama
        part({
                Name = "Toko_Badan",
                Size = Vector3.new(14, 9, 13),
                CFrame = CFrame.new(x, y + 4.5, z),
                Color = wallColor,
                Material = Enum.Material.Brick,
        })
        -- atap
        part({
                Name = "Toko_Atap",
                Size = Vector3.new(16.5, 1.3, 15.5),
                CFrame = CFrame.new(x, y + 9.6, z),
                Color = roofColor,
                Material = Enum.Material.Slate,
        })
        -- papan nama (menghadap barat)
        local sign = part({
                Name = "Toko_PapanNama",
                Size = Vector3.new(0.5, 2.6, 11),
                CFrame = CFrame.new(x - 7.3, y + 7.6, z),
                Color = Color3.fromRGB(34, 38, 52),
                Material = Enum.Material.SmoothPlastic,
        })
        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Left
        gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        gui.PixelsPerStud = 50
        gui.Parent = sign
        Util.create("TextLabel", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = wallColor:Lerp(Color3.new(1, 1, 1), 0.55),
                Text = string.upper(title),
        }, sign)
        -- jendela neon
        part({
                Name = "Toko_Jendela",
                Size = Vector3.new(0.4, 2.2, 8),
                CFrame = CFrame.new(x - 7.2, y + 3.4, z),
                Color = Color3.fromRGB(255, 236, 170),
                Material = Enum.Material.Neon,
        })
        -- peti & karung dekorasi
        part({
                Name = "Toko_Peti1",
                Size = Vector3.new(2.4, 2.4, 2.4),
                CFrame = CFrame.new(x - 9.5, y + 1.2, z + 7.5) * CFrame.Angles(0, math.rad(18), 0),
                Color = Color3.fromRGB(150, 108, 66),
                Material = Enum.Material.WoodPlanks,
        })
        part({
                Name = "Toko_Peti2",
                Size = Vector3.new(2, 2, 2),
                CFrame = CFrame.new(x - 9.3, y + 3.4, z + 7.4) * CFrame.Angles(0, math.rad(-24), 0),
                Color = Color3.fromRGB(164, 120, 74),
                Material = Enum.Material.WoodPlanks,
        })
end

--------------------------------------------------------------------
-- ZONA PUSAT
--------------------------------------------------------------------

local function buildPlaza()
        -- air mancur
        part({
                Name = "MancurBak",
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(2, 17, 17),
                CFrame = CFrame.new(0, 1, 0) * CFrame.Angles(0, 0, math.rad(90)),
                Color = Color3.fromRGB(208, 200, 186),
                Material = Enum.Material.Marble,
        })
        part({
                Name = "MancurAir",
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(1.2, 13.4, 13.4),
                CFrame = CFrame.new(0, 2.1, 0) * CFrame.Angles(0, 0, math.rad(90)),
                Color = Color3.fromRGB(90, 170, 220),
                Material = Enum.Material.Glass,
                Transparency = 0.25,
                CanCollide = false,
        })
        part({
                Name = "MancurTiang",
                Size = Vector3.new(2.6, 5, 2.6),
                CFrame = CFrame.new(0, 4.6, 0),
                Color = Color3.fromRGB(208, 200, 186),
                Material = Enum.Material.Marble,
        })
        local orb = part({
                Name = "MancurBola",
                Shape = Enum.PartType.Ball,
                Size = Vector3.new(2.6, 2.6, 2.6),
                CFrame = CFrame.new(0, 8.2, 0),
                Color = Color3.fromRGB(255, 209, 102),
                Material = Enum.Material.Neon,
        })
        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(255, 209, 102)
        light.Range = 28
        light.Brightness = 1.4
        light.Parent = orb

        -- gerbang judul di spawn (z = 34)
        for side = -1, 1, 2 do
                part({
                        Name = "GerbangPilar" .. side,
                        Size = Vector3.new(2.2, 14, 2.2),
                        CFrame = CFrame.new(side * 8, 7, 34),
                        Color = Color3.fromRGB(70, 74, 92),
                        Material = Enum.Material.SmoothPlastic,
                })
        end
        local beam = part({
                Name = "GerbangPalang",
                Size = Vector3.new(20, 3.2, 1.8),
                CFrame = CFrame.new(0, 15.2, 34),
                Color = Color3.fromRGB(34, 38, 52),
                Material = Enum.Material.SmoothPlastic,
        })
        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Front
        gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        gui.PixelsPerStud = 50
        gui.Parent = beam
        Util.create("TextLabel", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = Color3.fromRGB(255, 209, 102),
                Text = "DUNIA AKIOMIDA",
        }, gui)

        -- bangku mengelilingi air mancur
        local benchSpots = {
                { pos = Vector3.new(11.5, 0, 11.5), yaw = 135 },
                { pos = Vector3.new(-11.5, 0, 11.5), yaw = 45 },
                { pos = Vector3.new(11.5, 0, -11.5), yaw = 45 },
                { pos = Vector3.new(-11.5, 0, -11.5), yaw = 135 },
        }
        for _, spot in benchSpots do
                buildBench(spot.pos, spot.yaw)
        end

        -- lampu alun-alun
        for _, pos in {
                Vector3.new(16, 0, 16), Vector3.new(-16, 0, 16), Vector3.new(16, 0, -16), Vector3.new(-16, 0, -16),
        } do
                buildLamp(pos)
        end

        -- bunga warna-warni di alun-alun
        local rng = Random.new(1234)
        local flowerColors = {
                Color3.fromRGB(255, 120, 150), Color3.fromRGB(255, 210, 90),
                Color3.fromRGB(150, 200, 255), Color3.fromRGB(200, 140, 255),
        }
        for i = 1, 14 do
                local angle = rng:NextNumber(0, math.pi * 2)
                local dist = rng:NextNumber(9, 17)
                part({
                        Name = "Bunga" .. i,
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(1, 1, 1) * rng:NextNumber(0.8, 1.5),
                        CFrame = CFrame.new(math.cos(angle) * dist, 0.6, math.sin(angle) * dist),
                        Color = flowerColors[rng:NextInteger(1, #flowerColors)],
                        Material = Enum.Material.Grass,
                        CanCollide = false,
                })
        end
end

--------------------------------------------------------------------
-- BUILD ALL
--------------------------------------------------------------------

function MapService.init(svc)
        folder.Parent = workspace

        ---------------------------------------------------------------- pulau & langit
        part({
                Name = "Pulau",
                Size = Vector3.new(640, 8, 640),
                CFrame = CFrame.new(0, -4, 0),
                Color = Color3.fromRGB(105, 168, 90),
                Material = Enum.Material.Grass,
        })
        part({
                Name = "Samudra",
                Size = Vector3.new(2600, 2, 2600),
                CFrame = CFrame.new(0, -3, 0),
                Color = Color3.fromRGB(48, 118, 180),
                Material = Enum.Material.Glass,
                Transparency = 0.2,
        })

        -- atmosfer cerah (bukan kabut kelabu!)
        local atmo = Instance.new("Atmosphere")
        atmo.Density = 0.14
        atmo.Offset = 0.2
        atmo.Color = Color3.fromRGB(205, 215, 235)
        atmo.Glare = 0.15
        atmo.Haze = 0.8
        atmo.Parent = game:GetService("Lighting")

        -- perbukitan cakrawala
        local rngBukit = Random.new(88)
        for i = 1, 10 do
                local angle = (i / 10) * math.pi * 2
                local dist = 285 + rngBukit:NextNumber(-15, 15)
                local h = rngBukit:NextNumber(24, 42)
                part({
                        Name = "Bukit" .. i,
                        Shape = Enum.PartType.Cylinder,
                        Size = Vector3.new(h, rngBukit:NextNumber(90, 130), rngBukit:NextNumber(90, 130)),
                        CFrame = CFrame.new(math.cos(angle) * dist, h / 2 - 8, math.sin(angle) * dist)
                                * CFrame.Angles(0, 0, math.rad(90)),
                        Color = Color3.fromRGB(70, 120, 78):Lerp(Color3.fromRGB(50, 90, 110), rngBukit:NextNumber(0, 0.5)),
                        Material = Enum.Material.Grass,
                })
        end

        -- awan
        local rngAwan = Random.new(77)
        for i = 1, 8 do
                part({
                        Name = "Awan" .. i,
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(1, 1, 1) * rngAwan:NextNumber(28, 56),
                        CFrame = CFrame.new(rngAwan:NextNumber(-240, 240), rngAwan:NextNumber(85, 125), rngAwan:NextNumber(-240, 240)),
                        Color = Color3.new(1, 1, 1),
                        Material = Enum.Material.SmoothPlastic,
                        Transparency = 0.35,
                        CanCollide = false,
                })
        end

        ---------------------------------------------------------------- jalan
        part({
                Name = "JalanUtara",
                Size = Vector3.new(10, 0.3, 60),
                CFrame = CFrame.new(0, 0.15, -30),
                Color = Color3.fromRGB(178, 172, 162),
                Material = Enum.Material.Concrete,
        })
        part({
                Name = "JalanSelatan",
                Size = Vector3.new(10, 0.3, 105),
                CFrame = CFrame.new(0, 0.15, 52.5),
                Color = Color3.fromRGB(178, 172, 162),
                Material = Enum.Material.Concrete,
        })
        part({
                Name = "JalanTimurBarat",
                Size = Vector3.new(280, 0.3, 10),
                CFrame = CFrame.new(0, 0.15, 0),
                Color = Color3.fromRGB(178, 172, 162),
                Material = Enum.Material.Concrete,
        })
        part({
                Name = "JalanPasar",
                Size = Vector3.new(10, 0.3, 84),
                CFrame = CFrame.new(90, 0.15, 0),
                Color = Color3.fromRGB(178, 172, 162),
                Material = Enum.Material.Concrete,
        })
        part({
                Name = "PlazaLingkaran",
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(0.3, 38, 38),
                CFrame = CFrame.new(0, 0.28, 0) * CFrame.Angles(0, 0, math.rad(90)),
                Color = Color3.fromRGB(196, 188, 176),
                Material = Enum.Material.Granite,
        })

        -- lampu jalan
        for _, z in { -50, -25, 25, 50, 75, 100 } do
                buildLamp(Vector3.new(-6.8, 0, z))
                buildLamp(Vector3.new(6.8, 0, z))
        end
        for _, x in { -125, -100, -75, -50, 50, 75, 100, 125 } do
                buildLamp(Vector3.new(x, 0, -6.8))
                buildLamp(Vector3.new(x, 0, 6.8))
        end

        ---------------------------------------------------------------- alun-alun
        buildPlaza()

        -- Kak Pintar: kuis opsional (tidak pernah memaksa!)
        local quizPrompt = buildNPC("KAK PINTAR", Vector3.new(10, 0, 14), Color3.fromRGB(88, 200, 130))
        svc.Quiz.bindPrompt(quizPrompt)

        -- papan penunjuk arah
        buildSign("PASAR TIMUR >", Vector3.new(48, 0, 8), -90)
        buildSign("KAWASAN LADANG ^", Vector3.new(9, 0, -56), 0)
        buildSign("HUTAN KAYU <", Vector3.new(-52, 0, 8), 90)
        buildSign("TAMBANG SELATAN v", Vector3.new(9, 0, 96), 180)
        buildSign("DANAU TENANG \\", Vector3.new(-62, 0, 52), 90)

        ---------------------------------------------------------------- pasar timur (4 toko)
        local shops = {
                { id = "bibit", pos = Vector3.new(102, 0, -36), wall = Color3.fromRGB(120, 178, 110), roof = Color3.fromRGB(84, 110, 76), title = "Toko Bibit", npc = "KAK TANI", npcColor = Color3.fromRGB(120, 178, 110) },
                { id = "jual", pos = Vector3.new(102, 0, -12), wall = Color3.fromRGB(226, 168, 84), roof = Color3.fromRGB(150, 100, 50), title = "Pasar Pengepul", npc = "BU LARIS", npcColor = Color3.fromRGB(255, 209, 102) },
                { id = "alat", pos = Vector3.new(102, 0, 12), wall = Color3.fromRGB(110, 160, 210), roof = Color3.fromRGB(66, 96, 130), title = "Toko Alat", npc = "PAK BANG", npcColor = Color3.fromRGB(110, 160, 210) },
                { id = "pet", pos = Vector3.new(102, 0, 36), wall = Color3.fromRGB(224, 140, 190), roof = Color3.fromRGB(140, 84, 120), title = "Toko Peliharaan", npc = "MBAH SEKAR", npcColor = Color3.fromRGB(224, 140, 190) },
        }
        for _, shop in shops do
                buildShop(shop.pos, shop.wall, shop.roof, shop.title)
                local npcPos = shop.pos + Vector3.new(-11, 0, 0)
                local prompt = buildNPC(shop.npc, npcPos, shop.npcColor)
                svc.Shop.bindPrompt(prompt, shop.id)
        end

        ---------------------------------------------------------------- ladang utara (6 ladang)
        buildSign("KAWASAN LADANG", Vector3.new(0, 0, -64), 180, Color3.fromRGB(124, 94, 62))
        local plotSpots = {
                Vector3.new(-40, 0.5, -80), Vector3.new(0, 0.5, -80), Vector3.new(40, 0.5, -80),
                Vector3.new(-40, 0.5, -114), Vector3.new(0, 0.5, -114), Vector3.new(40, 0.5, -114),
        }
        for i, spot in plotSpots do
                svc.Farm.buildPlot(i, spot)
        end

        -- kincir angin & orang orangutan ladang (dekorasi)
        local towerX, towerZ = -24, -95
        part({
                Name = "KincirMenara",
                Size = Vector3.new(4, 18, 4),
                CFrame = CFrame.new(towerX, 9, towerZ),
                Color = Color3.fromRGB(214, 206, 192),
                Material = Enum.Material.WoodPlanks,
        })
        for blade = 1, 4 do
                part({
                        Name = "KincirBaling" .. blade,
                        Size = Vector3.new(1, 12, 0.6),
                        CFrame = CFrame.new(towerX, 19, towerZ - 2.4)
                                * CFrame.Angles(0, 0, math.rad(blade * 90)),
                        Color = Color3.fromRGB(240, 236, 226),
                        Material = Enum.Material.WoodPlanks,
                })
        end
        -- orang orangutan: tongkat + kepala + topi jerami
        part({
                Name = "OrorTongkat",
                Size = Vector3.new(0.5, 6, 0.5),
                CFrame = CFrame.new(14, 3, -95),
                Color = Color3.fromRGB(140, 100, 62),
                Material = Enum.Material.Wood,
        })
        part({
                Name = "OrorKepala",
                Shape = Enum.PartType.Ball,
                Size = Vector3.new(2.2, 2.2, 2.2),
                CFrame = CFrame.new(14, 6.6, -95),
                Color = Color3.fromRGB(255, 224, 189),
                Material = Enum.Material.SmoothPlastic,
        })
        part({
                Name = "OrorTopi",
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(0.5, 4, 4),
                CFrame = CFrame.new(14, 8.2, -95) * CFrame.Angles(0, 0, math.rad(90)),
                Color = Color3.fromRGB(235, 205, 130),
                Material = Enum.Material.Grass,
        })

        ---------------------------------------------------------------- hutan barat
        buildSign("HUTAN KAYU", Vector3.new(-64, 0, 0), 90, Color3.fromRGB(60, 110, 70))
        local treeSpots = {
                Vector3.new(-105, 0, -55), Vector3.new(-125, 0, -60), Vector3.new(-140, 0, -45),
                Vector3.new(-112, 0, -38), Vector3.new(-132, 0, -22), Vector3.new(-145, 0, -5),
                Vector3.new(-118, 0, -14), Vector3.new(-128, 0, 18), Vector3.new(-108, 0, 25),
                Vector3.new(-142, 0, 30), Vector3.new(-122, 0, 40), Vector3.new(-98, 0, 12),
        }
        for i, spot in treeSpots do
                svc.Gather.buildTree(spot, 100 + i)
        end

        ---------------------------------------------------------------- tambang selatan
        part({
                Name = "TambangLantai",
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(0.25, 60, 60),
                CFrame = CFrame.new(0, 0.14, 132) * CFrame.Angles(0, 0, math.rad(90)),
                Color = Color3.fromRGB(112, 112, 118),
                Material = Enum.Material.Slate,
        })
        buildSign("TAMBANG SELATAN", Vector3.new(0, 0, 108), 0, Color3.fromRGB(90, 90, 96))
        -- gerbang tambang + obor
        for side = -1, 1, 2 do
                part({
                        Name = "TambangPilar" .. side,
                        Size = Vector3.new(2.4, 10, 2.4),
                        CFrame = CFrame.new(side * 6, 5, 112),
                        Color = Color3.fromRGB(70, 70, 78),
                        Material = Enum.Material.Rock,
                })
                local torch = part({
                        Name = "TambangObor" .. side,
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(1.4, 1.4, 1.4),
                        CFrame = CFrame.new(side * 6, 10.6, 112),
                        Color = Color3.fromRGB(255, 150, 70),
                        Material = Enum.Material.Neon,
                })
                local light = Instance.new("PointLight")
                light.Color = Color3.fromRGB(255, 150, 70)
                light.Range = 18
                light.Brightness = 1.4
                light.Parent = torch
        end
        part({
                Name = "TambangPalang",
                Size = Vector3.new(15, 2, 2),
                CFrame = CFrame.new(0, 11, 112),
                Color = Color3.fromRGB(48, 48, 56),
                Material = Enum.Material.Rock,
        })
        -- gua gelap di belakang gerbang
        part({
                Name = "TambangGua",
                Size = Vector3.new(12, 9, 6),
                CFrame = CFrame.new(0, 4.5, 118),
                Color = Color3.fromRGB(30, 30, 36),
                Material = Enum.Material.Rock,
        })

        local rocks = {
                { id = "batu", pos = Vector3.new(-14, 0, 118) },
                { id = "batu", pos = Vector3.new(12, 0, 122) },
                { id = "batu", pos = Vector3.new(-2, 0, 134) },
                { id = "besi", pos = Vector3.new(-16, 0, 142) },
                { id = "besi", pos = Vector3.new(10, 0, 146) },
                { id = "besi", pos = Vector3.new(-8, 0, 128) },
                { id = "kristal", pos = Vector3.new(8, 0, 154) },
                { id = "kristal", pos = Vector3.new(-12, 0, 152) },
        }
        for i, rock in rocks do
                svc.Gather.buildRock(rock.pos, rock.id, 200 + i)
        end

        ---------------------------------------------------------------- danau tenang
        part({
                Name = "DanauPasir",
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(0.3, 64, 64),
                CFrame = CFrame.new(-115, 0.16, 95) * CFrame.Angles(0, 0, math.rad(90)),
                Color = Color3.fromRGB(238, 214, 160),
                Material = Enum.Material.Sand,
        })
        part({
                Name = "DanauAir",
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(0.6, 56, 56),
                CFrame = CFrame.new(-115, 0.32, 95) * CFrame.Angles(0, 0, math.rad(90)),
                Color = Color3.fromRGB(70, 150, 200),
                Material = Enum.Material.Glass,
                Transparency = 0.3,
                CanCollide = false,
        })
        svc.Gather.buildPier(Vector3.new(-90, 0, 95), Vector3.new(-1, 0, 0))
        buildSign("DANAU TENANG", Vector3.new(-72, 0, 82), 90, Color3.fromRGB(60, 110, 130))

        ---------------------------------------------------------------- pandai besi (tempa) - timur laut pasar
        local forgeX, forgeZ = 102, -58
        part({
                Name = "TempaBadan",
                Size = Vector3.new(13, 8, 12),
                CFrame = CFrame.new(forgeX, 4, forgeZ),
                Color = Color3.fromRGB(90, 96, 110),
                Material = Enum.Material.Brick,
        })
        part({
                Name = "TempaAtap",
                Size = Vector3.new(15.5, 1.2, 14.5),
                CFrame = CFrame.new(forgeX, 8.6, forgeZ),
                Color = Color3.fromRGB(50, 54, 64),
                Material = Enum.Material.Slate,
        })
        local forgeSign = part({
                Name = "TempaPapanNama",
                Size = Vector3.new(0.5, 2.4, 10),
                CFrame = CFrame.new(forgeX - 6.8, 6.6, forgeZ),
                Color = Color3.fromRGB(34, 38, 52),
                Material = Enum.Material.SmoothPlastic,
        })
        local forgeGui = Instance.new("SurfaceGui")
        forgeGui.Face = Enum.NormalId.Left
        forgeGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        forgeGui.PixelsPerStud = 50
        forgeGui.Parent = forgeSign
        Util.create("TextLabel", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = Color3.fromRGB(255, 150, 90),
                Text = "PANDAI BESI",
        }, forgeGui)

        -- perapian (anvil) + tukul + api tempa
        local anvil = part({
                Name = "Perapian",
                Size = Vector3.new(3, 1.6, 1.6),
                CFrame = CFrame.new(forgeX - 10.5, 1.8, forgeZ) * CFrame.Angles(0, math.rad(20), 0),
                Color = Color3.fromRGB(60, 62, 72),
                Material = Enum.Material.Metal,
        })
        part({
                Name = "PerapianKaki",
                Size = Vector3.new(1.4, 1.2, 1.4),
                CFrame = CFrame.new(forgeX - 10.5, 0.6, forgeZ),
                Color = Color3.fromRGB(50, 52, 60),
                Material = Enum.Material.Metal,
        })
        local forgeFire = part({
                Name = "ApiTempa",
                Shape = Enum.PartType.Ball,
                Size = Vector3.new(1.8, 1.8, 1.8),
                CFrame = CFrame.new(forgeX - 14, 1.6, forgeZ + 4),
                Color = Color3.fromRGB(255, 130, 60),
                Material = Enum.Material.Neon,
        })
        do
                local light = Instance.new("PointLight")
                light.Color = Color3.fromRGB(255, 130, 60)
                light.Range = 16
                light.Brightness = 1.5
                light.Parent = forgeFire
        end
        local forgePrompt = buildNPC("PAK TEMPA", Vector3.new(forgeX - 14, 0, forgeZ - 3), Color3.fromRGB(255, 150, 90))
        local anvilPrompt = Instance.new("ProximityPrompt")
        anvilPrompt.Parent = anvil
        svc.Craft.bindStation(anvilPrompt, "tempa")
        -- sambungkan juga prompt NPC (dua cara akses)
        svc.Craft.bindStation(forgePrompt, "tempa")

        ---------------------------------------------------------------- dapur alam (api unggun) - tenggara alun-alun
        part({
                Name = "ApiUnggunBatu",
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(0.8, 6, 6),
                CFrame = CFrame.new(26, 0.4, 26) * CFrame.Angles(0, 0, math.rad(90)),
                Color = Color3.fromRGB(120, 118, 124),
                Material = Enum.Material.Slate,
        })
        for i = 1, 4 do
                part({
                        Name = "ApiUnggunKayu" .. i,
                        Size = Vector3.new(0.7, 3.4, 0.7),
                        CFrame = CFrame.new(26, 1.4, 26) * CFrame.Angles(math.rad(24), math.rad(i * 90), 0) * CFrame.new(0, 1.2, 0),
                        Color = Color3.fromRGB(110, 76, 46),
                        Material = Enum.Material.Wood,
                })
        end
        local kitchenFire = part({
                Name = "ApiUnggunApi",
                Shape = Enum.PartType.Ball,
                Size = Vector3.new(2.4, 2.4, 2.4),
                CFrame = CFrame.new(26, 1.8, 26),
                Color = Color3.fromRGB(255, 160, 70),
                Material = Enum.Material.Neon,
        })
        do
                local light = Instance.new("PointLight")
                light.Color = Color3.fromRGB(255, 160, 70)
                light.Range = 18
                light.Brightness = 1.4
                light.Parent = kitchenFire
        end
        -- kuali & rak rempah
        part({
                Name = "Kuali",
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(0.9, 3, 3),
                CFrame = CFrame.new(29, 1.1, 28) * CFrame.Angles(0, 0, math.rad(90)),
                Color = Color3.fromRGB(40, 42, 50),
                Material = Enum.Material.Metal,
        })
        buildNPC("BU MASAK", Vector3.new(23, 0, 29), Color3.fromRGB(240, 130, 150))
        local cookPrompt = buildNPC("KUALI AJAIB", Vector3.new(29, 0, 24), Color3.fromRGB(240, 130, 150))
        svc.Craft.bindStation(cookPrompt, "dapur")

        ---------------------------------------------------------------- papan tugas harian - barat laut alun-alun
        part({
                Name = "PapanTugasTiang",
                Size = Vector3.new(0.8, 6, 0.8),
                CFrame = CFrame.new(-16, 3, -18),
                Color = Color3.fromRGB(96, 66, 42),
                Material = Enum.Material.Wood,
        })
        local questBoard = part({
                Name = "PapanTugasPapan",
                Size = Vector3.new(8, 5, 0.7),
                CFrame = CFrame.new(-16, 6.4, -18) * CFrame.Angles(0, math.rad(35), 0),
                Color = Color3.fromRGB(178, 140, 90),
                Material = Enum.Material.WoodPlanks,
        })
        do
                local gui = Instance.new("SurfaceGui")
                gui.Face = Enum.NormalId.Back
                gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
                gui.PixelsPerStud = 40
                gui.Parent = questBoard
                Util.create("TextLabel", {
                        Size = UDim2.fromScale(1, 1),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBlack,
                        TextScaled = true,
                        TextColor3 = Color3.fromRGB(90, 60, 30),
                        Text = "TUGAS HARIAN",
                }, gui)
        end
        buildNPC("KAK TUGAS", Vector3.new(-14, 0, -15), Color3.fromRGB(255, 209, 102))
        local questPrompt = buildNPC("PAPAN TUGAS", Vector3.new(-18, 0, -21), Color3.fromRGB(255, 209, 102))
        svc.Quest.bindBoard(questPrompt)

        ---------------------------------------------------------------- arena timur (koloseum boss)
        do
                local ax, az = 150, 92
                part({
                        Name = "ArenaLantai",
                        Shape = Enum.PartType.Cylinder,
                        Size = Vector3.new(0.3, 76, 76),
                        CFrame = CFrame.new(ax, 0.16, az) * CFrame.Angles(0, 0, math.rad(90)),
                        Color = Color3.fromRGB(196, 176, 150),
                        Material = Enum.Material.Sand,
                })
                -- dinding cincin (12 segmen)
                for i = 1, 12 do
                        local ang = (i / 12) * math.pi * 2
                        part({
                                Name = "ArenaDinding" .. i,
                                Size = Vector3.new(20, 9, 2.6),
                                CFrame = CFrame.new(ax + math.cos(ang) * 38, 4.5, az + math.sin(ang) * 38)
                                        * CFrame.Angles(0, -math.deg(ang) + 90, 0),
                                Color = Color3.fromRGB(150, 132, 110),
                                Material = Enum.Material.Slate,
                        })
                end
                -- obor arena
                for i = 1, 6 do
                        local ang = (i / 6) * math.pi * 2
                        local torch = part({
                                Name = "ArenaObor" .. i,
                                Shape = Enum.PartType.Ball,
                                Size = Vector3.new(1.6, 1.6, 1.6),
                                CFrame = CFrame.new(ax + math.cos(ang) * 32, 8.6, az + math.sin(ang) * 32),
                                Color = Color3.fromRGB(255, 140, 70),
                                Material = Enum.Material.Neon,
                        })
                        local light = Instance.new("PointLight")
                        light.Color = Color3.fromRGB(255, 140, 70)
                        light.Range = 22
                        light.Brightness = 1.5
                        light.Parent = torch
                end
                buildSign("ARENA TIMUR - PUNCAK GOLEM", Vector3.new(ax - 46, 0, az), 90, Color3.fromRGB(150, 90, 60))
                buildSign("PADANG TIMUR >", Vector3.new(52, 0, 16), -90, Color3.fromRGB(120, 150, 90))
        end

        print("[AKIOMIDA] Dunia siap: alun-alun, pasar, ladang, hutan, tambang, danau, pandai besi, dapur, papan tugas, arena boss.")
end

return MapService
