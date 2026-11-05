--!nonstrict
--[[
        MapService.luau - v22 ARSITEKTUR WILAYAH (dunia MMO pulau-pulau)
        Dunia terbagi pulau wilayah (data di Balance.Regions) di atas LAUT
        AIR SUNGUHAN terrain, dihubungkan gerbang portal (RegionService):
          PUSAT KOTA (hub)    : LAHAN KOSONG TOTAL - isi dibahas pemilik
                                kemudian, tidak ada bangunan apa pun.
          PULAU PANEN (civil) : Hutan Kayu, Tambang bijih, Danau Tenang
                                - TANPA MONSTER sama sekali.
          PULAU MONSTER (combat): Padang Liar, Hutan Bayang,
                                Negeri Baja & Kristal (tambang baja, gua
                                kristal, arena boss) - hanya di sini monster.
          LAHAN PEMAIN x10 (home): dibangun PersonalWorldBuilder - rumah
                                3 lantai + rooftop, ladang 500 petak, kolam,
                                ruang Bedah/Sains/Startopia/Pancing, koperasi.
        Semua karya original Dunia Akiomida.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Util = require(ReplicatedStorage.Shared.Util)
local Balance = require(ReplicatedStorage.Shared.Balance)

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
        })
end

local function buildSign(text: string, position: Vector3, yawDeg: number, color: Color3?)
        local board = part({
                Name = "PapanInfo",
                Size = Vector3.new(9, 2.6, 0.5),
                CFrame = CFrame.new(position + Vector3.new(0, 3.6, 0)) * CFrame.Angles(0, math.rad(yawDeg), 0),
                Color = color or Color3.fromRGB(96, 66, 38),
                Material = Enum.Material.WoodPlanks,
        })
        part({
                Name = "PapanTiang",
                Size = Vector3.new(0.6, 2.6, 0.6),
                CFrame = CFrame.new(position + Vector3.new(0, 1.3, 0)),
                Color = color or Color3.fromRGB(96, 66, 38),
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
        }, gui)
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
                Name = "BangkuPunggung",
                Size = Vector3.new(4.4, 1.6, 0.5),
                CFrame = base * CFrame.new(0, 2.2, -0.7),
                Color = Color3.fromRGB(150, 108, 66),
                Material = Enum.Material.WoodPlanks,
        })
end

--------------------------------------------------------------------
-- TERRAIN DUNIA (laut + pulau tiap wilayah, air sungguhan)
--------------------------------------------------------------------

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

        for _, pos in {
                { -320, 120 }, { 380, -720 }, { -280, -820 }, { 1180, -120 }, { 420, 950 }, { -180, 880 },
        } do
                terrain:FillBlock(CFrame.new(pos[1], -5.1, pos[2]), Vector3.new(74, 9.5, 74), Enum.Material.Sand)
                terrain:FillBlock(CFrame.new(pos[1], -5, pos[2]), Vector3.new(60, 10, 60), Enum.Material.Grass)
        end
end

--------------------------------------------------------------------
-- PULAU PANEN (civil - TANPA MONSTER): hutan, tambang, danau
--------------------------------------------------------------------

local function buildHarvestIsland(svc)
        local C = Vector3.new(0, 0, -640)

        part({
                Name = "PanenPlaza",
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(0.3, 26, 26),
                CFrame = CFrame.new(C.X, 0.28, C.Z + 130) * CFrame.Angles(0, 0, math.rad(90)),
                Color = Color3.fromRGB(196, 188, 176),
                Material = Enum.Material.Granite,
        })
        local function road(x: number, z: number, w: number, d: number)
                part({
                        Name = "JalanPanen",
                        Size = Vector3.new(w, 0.24, d),
                        CFrame = CFrame.new(C.X + x, 0.12, C.Z + z),
                        Color = Color3.fromRGB(186, 180, 170),
                        Material = Enum.Material.Concrete,
                })
        end
        road(0, 95, 8, 70)
        road(0, 60, 280, 8)
        road(-90, 0, 8, 120)
        road(105, 10, 8, 100)
        road(-60, 45, 8, 40)

        local rng = Random.new(4242)
        for i = 1, 12 do
                local tx = -150 + (i - 1) % 4 * 34 + rng:NextNumber(-8, 8)
                local tz = -30 - math.floor((i - 1) / 4) * 44 + rng:NextNumber(-8, 8)
                svc.Gather.buildTree(C + Vector3.new(tx, 0, tz), 400 + i)
        end
        buildSign("HUTAN KAYU", C + Vector3.new(-36, 0, 12), 45, Color3.fromRGB(60, 110, 70))

        part({
                Name = "TambangLantai",
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(0.25, 62, 62),
                CFrame = CFrame.new(C.X + 105, 0.14, C.Z - 85) * CFrame.Angles(0, 0, math.rad(90)),
                Color = Color3.fromRGB(112, 112, 118),
                Material = Enum.Material.Slate,
        })
        for side = -1, 1, 2 do
                part({
                        Name = "TambangPilar",
                        Size = Vector3.new(2.4, 10, 2.4),
                        CFrame = CFrame.new(C.X + 105 + side * 6, 5, C.Z - 46),
                        Color = Color3.fromRGB(70, 70, 78),
                        Material = Enum.Material.Rock,
                })
                part({
                        Name = "TambangObor",
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(1.4, 1.4, 1.4),
                        CFrame = CFrame.new(C.X + 105 + side * 6, 10.6, C.Z - 46),
                        Color = Color3.fromRGB(255, 150, 70),
                        Material = Enum.Material.Neon,
                })
        end
        part({
                Name = "TambangPalang",
                Size = Vector3.new(15, 2, 2),
                CFrame = CFrame.new(C.X + 105, 11, C.Z - 46),
                Color = Color3.fromRGB(48, 48, 56),
                Material = Enum.Material.Rock,
        })
        part({
                Name = "TambangGua",
                Size = Vector3.new(12, 9, 6),
                CFrame = CFrame.new(C.X + 105, 4.5, C.Z - 40),
                Color = Color3.fromRGB(30, 30, 36),
                Material = Enum.Material.Rock,
        })
        local rocks = {
                { id = "batu", pos = Vector3.new(90, 0, -100) },
                { id = "batu", pos = Vector3.new(122, 0, -95) },
                { id = "batu", pos = Vector3.new(104, 0, -72) },
                { id = "besi", pos = Vector3.new(88, 0, -52) },
                { id = "besi", pos = Vector3.new(126, 0, -58) },
                { id = "besi", pos = Vector3.new(140, 0, -120) },
                { id = "kristal", pos = Vector3.new(96, 0, -130) },
                { id = "kristal", pos = Vector3.new(70, 0, -118) },
        }
        for i, rock in rocks do
                svc.Gather.buildRock(C + rock.pos, rock.id, 200 + i)
        end
        buildSign("TAMBANG", C + Vector3.new(66, 0, -24), -45, Color3.fromRGB(90, 90, 96))

        local lake = C + Vector3.new(-90, 0, 80)
        local terrain = workspace.Terrain
        terrain:FillBlock(CFrame.new(lake.X, -3.6, lake.Z), Vector3.new(66, 10, 50), Enum.Material.Air)
        terrain:FillBlock(CFrame.new(lake.X, -5.1, lake.Z), Vector3.new(72, 9.5, 56), Enum.Material.Sand)
        terrain:FillBlock(CFrame.new(lake.X, -5.05, lake.Z), Vector3.new(60, 9, 44), Enum.Material.Water)
        svc.Gather.buildPier(lake + Vector3.new(35, 0, 0), Vector3.new(-1, 0, 0))
        buildSign("DANAU TENANG", C + Vector3.new(-36, 0, 108), 90, Color3.fromRGB(60, 110, 130))
        buildSign("PULAU PANEN", C + Vector3.new(0, 0, 118), 180, Color3.fromRGB(124, 94, 62))

        for _, pos in {
                Vector3.new(-7, 0, 100), Vector3.new(7, 0, 100), Vector3.new(-40, 0, 52), Vector3.new(60, 0, 52),
        } do
                buildLamp(C + pos)
        end
        buildBench(C + Vector3.new(-18, 0, 118), 0)
        buildBench(C + Vector3.new(18, 0, 118), 180)
        local towerX, towerZ = -30, -110
        part({
                Name = "KincirMenara",
                Size = Vector3.new(4, 18, 4),
                CFrame = CFrame.new(C.X + towerX, 9, C.Z + towerZ),
                Color = Color3.fromRGB(214, 206, 192),
                Material = Enum.Material.WoodPlanks,
        })
        for blade = 1, 4 do
                part({
                        Name = "KincirBaling",
                        Size = Vector3.new(1, 12, 0.6),
                        CFrame = CFrame.new(C.X + towerX, 19, C.Z + towerZ - 2.4) * CFrame.Angles(0, 0, math.rad(blade * 90)),
                        Color = Color3.fromRGB(240, 236, 226),
                        Material = Enum.Material.WoodPlanks,
                })
        end
end

--------------------------------------------------------------------
-- PULAU MONSTER (combat) - dekorasi bertema, zona spawn di Balance.Zones
--------------------------------------------------------------------

local function warningSign(pos: Vector3, text: string)
        buildSign(text, pos, 90, Color3.fromRGB(150, 70, 60))
end

local function buildMonsterIslands()
        local P = Vector3.new(640, 0, -320)
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
        buildSign("TAMBANG BAJA", Vector3.new(605, 0, 474), 0, Color3.fromRGB(90, 90, 96))
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
        buildSign("GUA KRISTAL", Vector3.new(gx - 40, 0, gz), 90, Color3.fromRGB(140, 90, 200))
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
                })
        end
        buildSign("ARENA - PUNCAK ANGKA 9", Vector3.new(ax - 46, 0, az), 90, Color3.fromRGB(150, 90, 60))
end

--------------------------------------------------------------------
-- BUILD ALL
--------------------------------------------------------------------

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

        buildHarvestIsland(svc)
        buildMonsterIslands()

        local PersonalWorldBuilder = require(script.Parent.PersonalWorldBuilder)
        for i = 1, Balance.HOME_COUNT do
                PersonalWorldBuilder.build(i, svc)
        end

        print("[AKIOMIDA] Dunia v22 siap: Pusat Kota kosong (menunggu desain), Pulau Panen, "
                .. "3 pulau monster, " .. Balance.HOME_COUNT .. " lahan pribadi (rumah 3 lantai, ladang 500 petak, "
                .. "kolam air sungguhan, ruang Bedah/Sains/Startopia/Pancing, koperasi).")
end

return MapService
