--!nonstrict
--[[
        PersonalWorldBuilder.luau - v21 PULAU RUMAH PRIBADI (milik satu pemain)
        Tata ruang rapi ala dunia personal MMO:
          gerbang timur -> plaza -> jalan batu ke:
            RUMAH        (barat laut; lantai, dinding, atap 3 lapis, teras,
                          interior: karpet, ranjang, meja, kursi, rak)
            LADANG       (barat daya; plot FarmService 4x4 petak + kios pad)
            KOLAM        (timur laut; AIR SUNGUHAN terrain - bergelombang &
                          bisa berenang, bukan balok; dermaga + alang-alang)
            3 RUANGAN    (deret selatan rapi: BEDAH, SAINS, STARTOPIA)
          Semua dikelilingi pagar rambate rendah + lampu taman.
        100% original Dunia Akiomida.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Remotes)
local Util = require(ReplicatedStorage.Shared.Util)
local Balance = require(ReplicatedStorage.Shared.Balance)

local PersonalWorldBuilder = {}

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

local function lamp(position: Vector3)
        part({
                Name = "RumahLampuTiang",
                Size = Vector3.new(0.6, 7.4, 0.6),
                CFrame = CFrame.new(position + Vector3.new(0, 3.7, 0)),
                Color = Color3.fromRGB(58, 62, 74),
                Material = Enum.Material.Metal,
        })
        part({
                Name = "RumahLampuKepala",
                Shape = Enum.PartType.Ball,
                Size = Vector3.new(1.5, 1.5, 1.5),
                CFrame = CFrame.new(position + Vector3.new(0, 7.7, 0)),
                Color = Color3.fromRGB(255, 226, 160),
                Material = Enum.Material.Neon,
        })
end

local function textBoard(name: string, pos: Vector3, yawDeg: number, title: string, sub: string, color: Color3)
        local board = part({
                Name = name,
                Size = Vector3.new(9, 3.4, 0.6),
                CFrame = CFrame.new(pos + Vector3.new(0, 4.4, 0)) * CFrame.Angles(0, math.rad(yawDeg), 0),
                Color = color,
                Material = Enum.Material.WoodPlanks,
        })
        part({
                Name = name .. "Tiang",
                Size = Vector3.new(0.6, 3, 0.6),
                CFrame = CFrame.new(pos + Vector3.new(0, 1.5, 0)),
                Color = color,
                Material = Enum.Material.WoodPlanks,
        })
        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Front
        gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        gui.PixelsPerStud = 50
        gui.Parent = board
        Util.create("TextLabel", {
                Size = UDim2.fromScale(1, 0.62),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = Color3.fromRGB(255, 226, 150),
                Text = title,
        }, gui)
        Util.create("TextLabel", {
                Position = UDim2.fromScale(0, 0.62),
                Size = UDim2.fromScale(1, 0.38),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                TextScaled = true,
                TextColor3 = Color3.fromRGB(210, 214, 224),
                Text = sub,
        }, gui)
        return board
end

-- papan info ruangan: dekat pintu, beri penjelasan saat dibaca
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

--------------------------------------------------------------------
-- KOLAM AIR SUNGUHAN (terrain: bergelombang, bisa berenang)
--------------------------------------------------------------------

local function buildPond(center: Vector3, svc)
        local terrain = workspace.Terrain
        -- set tampilan air sekali (dipanggil tiap pulau, idempotent)
        terrain.WaterWaveSize = 0.14
        terrain.WaterWaveSpeed = 14
        terrain.WaterReflectance = 0.35
        terrain.WaterTransparency = 0.55

        -- 1) gali cekungan (melewati permukaan pulau supaya terbuka)
        terrain:FillBlock(CFrame.new(center.X, -3.6, center.Z), Vector3.new(44, 10, 36), Enum.Material.Air)
        -- 2) tepian pasir keliling
        terrain:FillBlock(CFrame.new(center.X, -5.1, center.Z), Vector3.new(50, 9.5, 42), Enum.Material.Sand)
        -- 3) air sungguhan di tengah (permukaan -0.55, dalam ~8 -> bisa berenang)
        terrain:FillBlock(CFrame.new(center.X, -5.05, center.Z), Vector3.new(40, 9, 32), Enum.Material.Water)

        -- dermaga memancing kecil di tepi barat (GatherService: sekaligus prompt Pancing Ikan)
        svc.Gather.buildPier(center + Vector3.new(14, 0, 0), Vector3.new(-1, 0, 0))

        -- alang-alang & batu tepian
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
                        })
                end
                part({
                        Name = "AlangKepala" .. i,
                        Size = Vector3.new(0.5, 1, 0.5),
                        CFrame = CFrame.new(bx, 3, bz),
                        Color = Color3.fromRGB(150, 116, 70),
                        Material = Enum.Material.SmoothPlastic,
                        CanCollide = false,
                })
        end
        for i = 1, 3 do
                local ang = (i / 3) * math.pi * 2 + 0.7
                local r = rng:NextNumber(1.2, 2)
                part({
                        Name = "BatuKolam" .. i,
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(1, 1, 1) * r * 2,
                        CFrame = CFrame.new(center.X + math.cos(ang) * 23.5, 0.4, center.Z + math.sin(ang) * 19),
                        Color = Color3.fromRGB(128, 128, 134),
                        Material = Enum.Material.Slate,
                })
        end
end

--------------------------------------------------------------------
-- RUMAH (lantai, dinding, atap 3 lapis, teras, interior)
--------------------------------------------------------------------

local function buildHouse(center: Vector3)
        local hx, hz = center.X, center.Z
        local wall = Color3.fromRGB(232, 220, 198)
        local wood = Color3.fromRGB(150, 108, 66)
        local roof = Color3.fromRGB(148, 66, 54)

        -- lantai
        part({
                Name = "RumahLantai",
                Size = Vector3.new(27, 0.5, 21),
                CFrame = CFrame.new(hx, 0.25, hz),
                Color = Color3.fromRGB(168, 124, 78),
                Material = Enum.Material.WoodPlanks,
        })
        -- dinding: belakang (barat), utara, selatan, depan timur dengan bukaan pintu
        part({ Name = "RumahDindingB", Size = Vector3.new(1, 9, 21), CFrame = CFrame.new(hx - 13, 4.5, hz), Color = wall, Material = Enum.Material.WoodPlanks })
        part({ Name = "RumahDindingU", Size = Vector3.new(27, 9, 1), CFrame = CFrame.new(hx, 4.5, hz - 10), Color = wall, Material = Enum.Material.WoodPlanks })
        part({ Name = "RumahDindingS", Size = Vector3.new(27, 9, 1), CFrame = CFrame.new(hx, 4.5, hz + 10), Color = wall, Material = Enum.Material.WoodPlanks })
        part({ Name = "RumahDindingDU", Size = Vector3.new(1, 9, 7), CFrame = CFrame.new(hx + 13, 4.5, hz - 6.5), Color = wall, Material = Enum.Material.WoodPlanks })
        part({ Name = "RumahDindingDS", Size = Vector3.new(1, 9, 7), CFrame = CFrame.new(hx + 13, 4.5, hz + 6.5), Color = wall, Material = Enum.Material.WoodPlanks })
        part({ Name = "RumahPalangPintu", Size = Vector3.new(1, 3, 6), CFrame = CFrame.new(hx + 13, 7.5, hz), Color = wall, Material = Enum.Material.WoodPlanks })
        -- bingkai pintu
        part({ Name = "RumahBingkaiU", Size = Vector3.new(1.3, 7.4, 0.8), CFrame = CFrame.new(hx + 13, 3.7, hz - 3.4), Color = wood, Material = Enum.Material.Wood })
        part({ Name = "RumahBingkaiS", Size = Vector3.new(1.3, 7.4, 0.8), CFrame = CFrame.new(hx + 13, 3.7, hz + 3.4), Color = wood, Material = Enum.Material.Wood })
        -- jendela kaca (utara & selatan)
        for _, side in { -1, 1 } do
                part({
                        Name = "RumahJendela" .. side,
                        Size = Vector3.new(5, 4, 0.5),
                        CFrame = CFrame.new(hx - 4, 5, hz + side * 10.3),
                        Color = Color3.fromRGB(170, 215, 235),
                        Material = Enum.Material.Glass,
                        Transparency = 0.45,
                })
        end
        -- atap 3 lapis (kabin rapi)
        part({ Name = "RumahAtap1", Size = Vector3.new(29, 1.4, 23), CFrame = CFrame.new(hx, 9.7, hz), Color = roof, Material = Enum.Material.Slate })
        part({ Name = "RumahAtap2", Size = Vector3.new(21, 1.4, 17), CFrame = CFrame.new(hx, 11.1, hz), Color = roof:Lerp(Color3.new(1, 1, 1), 0.08), Material = Enum.Material.Slate })
        part({ Name = "RumahAtap3", Size = Vector3.new(13, 1.4, 11), CFrame = CFrame.new(hx, 12.5, hz), Color = roof:Lerp(Color3.new(1, 1, 1), 0.16), Material = Enum.Material.Slate })

        -- teras depan
        part({
                Name = "RumahTeras",
                Size = Vector3.new(8, 0.4, 11),
                CFrame = CFrame.new(hx + 17.5, 0.2, hz),
                Color = Color3.fromRGB(198, 190, 178),
                Material = Enum.Material.Concrete,
        })
        for _, side in { -1, 1 } do
                part({
                        Name = "RumahPilarTeras" .. side,
                        Size = Vector3.new(1, 6.4, 1),
                        CFrame = CFrame.new(hx + 21, 3.2, hz + side * 4.6),
                        Color = wood,
                        Material = Enum.Material.Wood,
                })
        end
        part({ Name = "RumahPalangTeras", Size = Vector3.new(1, 1, 10.4), CFrame = CFrame.new(hx + 21, 6.6, hz), Color = wood, Material = Enum.Material.Wood })
        part({
                Name = "RumahLampuTeras",
                Shape = Enum.PartType.Ball,
                Size = Vector3.new(1.2, 1.2, 1.2),
                CFrame = CFrame.new(hx + 21, 7.4, hz),
                Color = Color3.fromRGB(255, 226, 160),
                Material = Enum.Material.Neon,
        })

        -- interior: karpet, ranjang, meja, kursi, rak
        part({
                Name = "RumahKarpet",
                Size = Vector3.new(13, 0.12, 9),
                CFrame = CFrame.new(hx - 4, 0.56, hz + 2),
                Color = Color3.fromRGB(158, 76, 66),
                Material = Enum.Material.Fabric,
        })
        part({ Name = "RumahRanjang", Size = Vector3.new(3.2, 1, 6.6), CFrame = CFrame.new(hx - 9.5, 1, hz - 5.6), Color = wood, Material = Enum.Material.WoodPlanks })
        part({ Name = "RumahBantal", Size = Vector3.new(2.6, 0.9, 2), CFrame = CFrame.new(hx - 9.5, 1.8, hz - 7.6), Color = Color3.fromRGB(240, 238, 232), Material = Enum.Material.Fabric })
        part({ Name = "RumahSelimut", Size = Vector3.new(3.3, 0.5, 4), CFrame = CFrame.new(hx - 9.5, 1.6, hz - 4), Color = Color3.fromRGB(96, 130, 170), Material = Enum.Material.Fabric })
        part({ Name = "RumahMejaKaki", Size = Vector3.new(0.8, 1.6, 0.8), CFrame = CFrame.new(hx - 2, 0.8, hz + 2), Color = wood, Material = Enum.Material.Wood })
        part({ Name = "RumahMejaAtas", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.35, 3.6, 3.6), CFrame = CFrame.new(hx - 2, 1.75, hz + 2) * CFrame.Angles(0, 0, math.rad(90)), Color = wood, Material = Enum.Material.WoodPlanks })
        for _, side in { -1, 1 } do
                part({ Name = "RumahKursi" .. side, Size = Vector3.new(1.6, 0.7, 1.6), CFrame = CFrame.new(hx - 2 + side * 2.6, 0.4, hz + 2), Color = wood, Material = Enum.Material.WoodPlanks })
        end
        part({ Name = "RumahRak", Size = Vector3.new(0.8, 0.6, 7), CFrame = CFrame.new(hx - 12.2, 4.6, hz + 4), Color = wood, Material = Enum.Material.Wood })
        for i = 1, 3 do
                part({
                        Name = "RumahBarang" .. i,
                        Size = Vector3.new(0.9, 0.9, 0.9),
                        CFrame = CFrame.new(hx - 12.2, 5.4, hz + 2.2 + (i - 1) * 1.8),
                        Color = Color3.fromRGB(255, 209, 102):Lerp(Color3.fromRGB(120, 200, 235), (i - 1) / 2),
                        Material = Enum.Material.SmoothPlastic,
                })
        end
        -- lampu gantung hangat (satu-satunya PointLight di rumah, hemat mobile)
        local bulb = part({
                Name = "RumahLampuGantung",
                Shape = Enum.PartType.Ball,
                Size = Vector3.new(1.3, 1.3, 1.3),
                CFrame = CFrame.new(hx, 7.6, hz + 2),
                Color = Color3.fromRGB(255, 226, 160),
                Material = Enum.Material.Neon,
        })
        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(255, 226, 160)
        light.Range = 16
        light.Brightness = 0.9
        light.Shadows = false
        light.Parent = bulb
end

--------------------------------------------------------------------
-- RUANGAN TEMA (bedah / sains / startopia) - deret rapi selatan
--------------------------------------------------------------------

local function roomShell(center: Vector3, judul: string, floorC: Color3, wallC: Color3, roofC: Color3)
        local x, z = center.X, center.Z
        part({ Name = judul .. "Lantai", Size = Vector3.new(20, 0.4, 16), CFrame = CFrame.new(x, 0.2, z), Color = floorC, Material = Enum.Material.Concrete })
        part({ Name = judul .. "DindingSel", Size = Vector3.new(20, 8, 1), CFrame = CFrame.new(x, 4, z + 8), Color = wallC, Material = Enum.Material.SmoothPlastic })
        part({ Name = judul .. "DindingBar", Size = Vector3.new(1, 8, 16), CFrame = CFrame.new(x - 10, 4, z), Color = wallC, Material = Enum.Material.SmoothPlastic })
        part({ Name = judul .. "DindingTim", Size = Vector3.new(1, 8, 16), CFrame = CFrame.new(x + 10, 4, z), Color = wallC, Material = Enum.Material.SmoothPlastic })
        part({ Name = judul .. "DindingDepU", Size = Vector3.new(7.5, 8, 1), CFrame = CFrame.new(x - 6.25, 4, z - 8), Color = wallC, Material = Enum.Material.SmoothPlastic })
        part({ Name = judul .. "DindingDepS", Size = Vector3.new(7.5, 8, 1), CFrame = CFrame.new(x + 6.25, 4, z - 8), Color = wallC, Material = Enum.Material.SmoothPlastic })
        part({ Name = judul .. "PalangPintu", Size = Vector3.new(20, 2, 1), CFrame = CFrame.new(x, 7, z - 8), Color = wallC, Material = Enum.Material.SmoothPlastic })
        part({ Name = judul .. "Atap", Size = Vector3.new(22, 1.2, 18), CFrame = CFrame.new(x, 8.6, z), Color = roofC, Material = Enum.Material.Slate })
        -- papan nama di atas pintu (menghadap utara/jalan)
        local board = part({
                Name = judul .. "Papan",
                Size = Vector3.new(8.5, 2.2, 0.5),
                CFrame = CFrame.new(x, 6.2, z - 8.6) * CFrame.Angles(0, math.rad(180), 0),
                Color = Color3.fromRGB(34, 38, 52),
                Material = Enum.Material.SmoothPlastic,
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
                Text = judul,
        }, board)
        return board
end

local function buildSurgeryRoom(center: Vector3)
        local board = roomShell(center, "RUANG BEDAH", Color3.fromRGB(226, 229, 234), Color3.fromRGB(238, 240, 244), Color3.fromRGB(168, 62, 58))
        local x, z = center.X, center.Z
        -- tanda palang merah di atap
        part({ Name = "BedahSalang1", Size = Vector3.new(5.4, 0.7, 0.7), CFrame = CFrame.new(x, 9.8, z) * CFrame.Angles(0, math.rad(45), 0), Color = Color3.fromRGB(235, 62, 56), Material = Enum.Material.Neon, CanCollide = false })
        part({ Name = "BedahSalang2", Size = Vector3.new(5.4, 0.7, 0.7), CFrame = CFrame.new(x, 9.8, z) * CFrame.Angles(0, math.rad(-45), 0), Color = Color3.fromRGB(235, 62, 56), Material = Enum.Material.Neon, CanCollide = false })
        -- ranjang operasi + bantal
        part({ Name = "BedahRanjang", Size = Vector3.new(7.6, 1.2, 4), CFrame = CFrame.new(x - 2, 1.3, z + 1), Color = Color3.fromRGB(245, 246, 248), Material = Enum.Material.SmoothPlastic })
        part({ Name = "BedahBantal", Size = Vector3.new(2.2, 0.8, 3.2), CFrame = CFrame.new(x - 5, 2.2, z + 1), Color = Color3.fromRGB(220, 230, 240), Material = Enum.Material.Fabric })
        -- lampu operasi di tiang
        part({ Name = "BedahTiangLampu", Size = Vector3.new(0.4, 6, 0.4), CFrame = CFrame.new(x - 2, 3, z + 4.4), Color = Color3.fromRGB(120, 126, 138), Material = Enum.Material.Metal })
        part({ Name = "BedahLampu", Shape = Enum.PartType.Ball, Size = Vector3.new(2.2, 2.2, 2.2), CFrame = CFrame.new(x - 2, 6.2, z + 1), Color = Color3.fromRGB(250, 252, 255), Material = Enum.Material.Neon, CanCollide = false })
        -- lemari alat & troli
        part({ Name = "BedahLemari", Size = Vector3.new(2.2, 5.6, 3.6), CFrame = CFrame.new(x + 8.4, 2.8, z + 5.4), Color = Color3.fromRGB(150, 156, 168), Material = Enum.Material.Metal })
        part({ Name = "BedahTroli", Size = Vector3.new(3, 0.3, 2), CFrame = CFrame.new(x + 4, 2.2, z + 5.6), Color = Color3.fromRGB(170, 176, 186), Material = Enum.Material.Metal })
        part({ Name = "BedahKotakAlat", Size = Vector3.new(1.4, 0.8, 1.2), CFrame = CFrame.new(x + 4, 2.8, z + 5.6), Color = Color3.fromRGB(90, 160, 210), Material = Enum.Material.SmoothPlastic })
        infoPrompt(board, "RUANG BEDAH", "Ruang operasi pribadimu. Fitur stand bedah darurat akan dibangun di sini - untuk sekarang ruangan ini aman & bebas monster.")
end

local function buildScienceRoom(center: Vector3)
        local board = roomShell(center, "RUANG SAINS", Color3.fromRGB(62, 92, 98), Color3.fromRGB(74, 142, 150), Color3.fromRGB(54, 68, 76))
        local x, z = center.X, center.Z
        -- 3 stasiun eksperimen (meja + tabung warna)
        local tubeColors = {
                Color3.fromRGB(120, 230, 140),
                Color3.fromRGB(100, 180, 240),
                Color3.fromRGB(190, 120, 255),
        }
        for i = 0, 2 do
                local sx = x - 6 + i * 6
                part({ Name = "SainsMeja" .. i, Size = Vector3.new(4, 1, 2.6), CFrame = CFrame.new(sx, 1.2, z + 3.6), Color = Color3.fromRGB(150, 156, 168), Material = Enum.Material.Metal })
                part({ Name = "SainsTabung" .. i, Shape = Enum.PartType.Cylinder, Size = Vector3.new(2.6, 1.3, 1.3), CFrame = CFrame.new(sx, 3.2, z + 3.6) * CFrame.Angles(0, 0, math.rad(90)), Color = tubeColors[i + 1], Material = Enum.Material.Neon, Transparency = 0.15 })
        end
        -- rak botol
        part({ Name = "SainsRak", Size = Vector3.new(6, 0.5, 1.4), CFrame = CFrame.new(x - 4, 4.6, z - 7.2), Color = Color3.fromRGB(104, 90, 70), Material = Enum.Material.Wood })
        for i = 1, 5 do
                part({
                        Name = "SainsBotol" .. i,
                        Size = Vector3.new(0.7, 0.7, 0.7),
                        CFrame = CFrame.new(x - 6.4 + i * 1.1, 5.2, z - 7.2),
                        Color = Color3.fromHSV((i - 1) / 5, 0.65, 0.95),
                        Material = Enum.Material.SmoothPlastic,
                })
        end
        infoPrompt(board, "RUANG SAINS", "Stasiun eksperimen pribadimu. Riset bahan kimia & campuran akan aktif di sini - siapkan ruang labmu sejak sekarang!")
end

local function buildStartopiaRoom(center: Vector3)
        local board = roomShell(center, "RUANG STARTOPIA", Color3.fromRGB(32, 38, 62), Color3.fromRGB(46, 58, 98), Color3.fromRGB(26, 30, 50))
        local x, z = center.X, center.Z
        -- teleskop antariksa
        part({ Name = "StarTiang", Size = Vector3.new(1, 3.2, 1), CFrame = CFrame.new(x - 5, 1.6, z + 3), Color = Color3.fromRGB(120, 126, 140), Material = Enum.Material.Metal })
        part({
                Name = "StarTeleskop",
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(6.5, 1, 1),
                CFrame = CFrame.new(x - 5, 4.4, z + 3) * CFrame.Angles(0, 0, math.rad(50)),
                Color = Color3.fromRGB(196, 202, 216),
                Material = Enum.Material.Metal,
        })
        -- konsol pesawat + layar galaksi
        part({ Name = "StarKonsol", Size = Vector3.new(5, 1.2, 2.2), CFrame = CFrame.new(x + 5, 0.6, z + 4), Color = Color3.fromRGB(38, 44, 66), Material = Enum.Material.Metal })
        part({ Name = "StarLayar", Size = Vector3.new(4.6, 2.6, 0.3), CFrame = CFrame.new(x + 5, 2.6, z + 4.6), Color = Color3.fromRGB(90, 160, 255), Material = Enum.Material.Neon, CanCollide = false })
        part({ Name = "StarTombol", Size = Vector3.new(3, 0.3, 1), CFrame = CFrame.new(x + 5, 1.35, z + 3.4), Color = Color3.fromRGB(255, 190, 90), Material = Enum.Material.Neon })
        -- tanaman alien
        part({ Name = "StarPot", Shape = Enum.PartType.Cylinder, Size = Vector3.new(1.4, 1.8, 1.8), CFrame = CFrame.new(x + 1, 0.7, z - 6) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(150, 96, 62), Material = Enum.Material.SmoothPlastic })
        part({ Name = "StarAlien", Shape = Enum.PartType.Ball, Size = Vector3.new(2.4, 2.4, 2.4), CFrame = CFrame.new(x + 1, 2.6, z - 6), Color = Color3.fromRGB(180, 100, 235), Material = Enum.Material.Grass })
        part({ Name = "StarAlienDaun", Shape = Enum.PartType.Ball, Size = Vector3.new(1.3, 1.3, 1.3), CFrame = CFrame.new(x + 2.1, 3.4, z - 6), Color = Color3.fromRGB(120, 230, 150), Material = Enum.Material.Grass, CanCollide = false })
        -- bintang di dinding (neon kecil, hemat)
        local rng = Random.new(777)
        for i = 1, 6 do
                part({
                        Name = "StarBintang" .. i,
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(0.5, 0.5, 0.5),
                        CFrame = CFrame.new(x - 8 + i * 2.6, 5.4 + rng:NextNumber(-1.4, 1.4), z + 8.2),
                        Color = Color3.fromRGB(255, 240, 180),
                        Material = Enum.Material.Neon,
                        CanCollide = false,
                })
        end
        infoPrompt(board, "RUANG STARTOPIA", "Basis antariksa pribadimu. Portal eksplorasi galaksi akan dibuka dari ruangan ini - bersiaplah, penjelajah bintang!")
end

--------------------------------------------------------------------
-- BUILD SATU PULAU RUMAH
--------------------------------------------------------------------

function PersonalWorldBuilder.build(index: number, svc)
        local hx, hz = Balance.homeCenter(index)
        local C = Vector3.new(hx, 0, hz)
        local at = function(dx: number, dy: number, dz: number)
                return C + Vector3.new(dx, dy, dz)
        end

        -- plaza timur (depan gerbang)
        part({
                Name = "RumahPlaza",
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(0.3, 28, 28),
                CFrame = CFrame.new(at(70, 0.16, 0)) * CFrame.Angles(0, 0, math.rad(90)),
                Color = Color3.fromRGB(196, 188, 176),
                Material = Enum.Material.Granite,
        })

        -- jalan batu rapi
        local function road(x: number, z: number, w: number, d: number)
                part({
                        Name = "RumahJalan",
                        Size = Vector3.new(w, 0.24, d),
                        CFrame = CFrame.new(at(x, 0.12, z)),
                        Color = Color3.fromRGB(186, 180, 170),
                        Material = Enum.Material.Concrete,
                })
        end
        road(27, 0, 120, 7) -- jalan utama timur-barat (plaza -> gerbang)
        road(-32, -16, 6, 32) -- cabang rumah (sampai teras)
        road(-52, 16, 6, 32) -- cabang ladang
        road(30, 25, 6, 50) -- cabang deret ruangan
        road(10, 50, 84, 6) -- sepanjang deret ruangan
        road(40, -15, 6, 30) -- cabang kolam

        -- pagar rambate keliling (4 sisi)
        part({ Name = "RumahHedgeU", Size = Vector3.new(196, 3, 2), CFrame = CFrame.new(at(0, 1.5, -89)), Color = Color3.fromRGB(66, 122, 66), Material = Enum.Material.Grass })
        part({ Name = "RumahHedgeS", Size = Vector3.new(196, 3, 2), CFrame = CFrame.new(at(0, 1.5, 89)), Color = Color3.fromRGB(66, 122, 66), Material = Enum.Material.Grass })
        part({ Name = "RumahHedgeB", Size = Vector3.new(2, 3, 180), CFrame = CFrame.new(at(-99, 1.5, 0)), Color = Color3.fromRGB(66, 122, 66), Material = Enum.Material.Grass })
        part({ Name = "RumahHedgeT1", Size = Vector3.new(2, 3, 56), CFrame = CFrame.new(at(99, 1.5, -61)), Color = Color3.fromRGB(66, 122, 66), Material = Enum.Material.Grass })
        part({ Name = "RumahHedgeT2", Size = Vector3.new(2, 3, 56), CFrame = CFrame.new(at(99, 1.5, 61)), Color = Color3.fromRGB(66, 122, 66), Material = Enum.Material.Grass })

        -- rumah (barat laut)
        buildHouse(at(-52, 0, -38))
        -- ladang pribadi (barat daya) - plot FarmService milik pulau ini
        svc.Farm.buildPlot(index, at(-52, 0.5, 44))
        -- kolam air sungguhan (timur laut)
        buildPond(at(40, 0, -50), svc)

        -- 3 ruangan tema (deret selatan rapi, pintu menghadap jalan)
        buildSurgeryRoom(at(-8, 0, 58))
        buildScienceRoom(at(20, 0, 58))
        buildStartopiaRoom(at(48, 0, 58))

        -- lampu taman di tepi persimpangan
        for _, pos in {
                at(84, 0, 11), at(84, 0, -11), at(-14, 0, 9), at(-45, 0, 24), at(37, 0, 44), at(45, 0, -27),
        } do
                lamp(pos)
        end

        -- pohon buah 2 (bisa ditebang: kayu & apel)
        svc.Gather.buildTree(at(0, 0, -78), 300 + index * 2)
        svc.Gather.buildTree(at(80, 0, -64), 300 + index * 2 + 1)

        -- papan nama pulau
        textBoard("RumahPapan" .. index, at(86, 0, 14), 90,
                "PULAU RUMAH " .. index, "GERBANG KE PUSAT KOTA ->", Color3.fromRGB(96, 66, 38))

        -- bangku santai
        do
                local base = CFrame.new(at(56, 0, -34)) * CFrame.Angles(0, math.rad(90), 0)
                part({ Name = "RumahBangku1", Size = Vector3.new(4.4, 0.8, 1.8), CFrame = base * CFrame.new(0, 1.1, 0), Color = Color3.fromRGB(150, 108, 66), Material = Enum.Material.WoodPlanks })
                part({ Name = "RumahBangku1S", Size = Vector3.new(4.4, 1.6, 0.5), CFrame = base * CFrame.new(0, 2.2, -0.7), Color = Color3.fromRGB(150, 108, 66), Material = Enum.Material.WoodPlanks })
                local base2 = CFrame.new(at(-24, 0, -22)) * CFrame.Angles(0, math.rad(160), 0)
                part({ Name = "RumahBangku2", Size = Vector3.new(4.4, 0.8, 1.8), CFrame = base2 * CFrame.new(0, 1.1, 0), Color = Color3.fromRGB(150, 108, 66), Material = Enum.Material.WoodPlanks })
                part({ Name = "RumahBangku2S", Size = Vector3.new(4.4, 1.6, 0.5), CFrame = base2 * CFrame.new(0, 2.2, -0.7), Color = Color3.fromRGB(150, 108, 66), Material = Enum.Material.WoodPlanks })
        end

        -- bunga hias deterministik (jauhi jalan & bangunan supaya rapi)
        local rng = Random.new(500 + index)
        local flowerColors = {
                Color3.fromRGB(255, 120, 150), Color3.fromRGB(255, 210, 90),
                Color3.fromRGB(150, 200, 255), Color3.fromRGB(200, 140, 255),
        }
        local function blocked(fx: number, fz: number): boolean
                if math.abs(fz) < 7 then return true end -- jalan utama
                if fx > -70 and fx < -34 and fz > -54 and fz < -22 then return true end -- rumah
                if fx > -70 and fx < -34 and fz > 26 and fz < 62 then return true end -- ladang
                if fx > -22 and fx < 62 and fz > 44 and fz < 70 then return true end -- ruangan
                if fx > 14 and fx < 66 and fz > -72 and fz < -28 then return true end -- kolam
                if math.abs(fx - 70) < 17 and math.abs(fz) < 17 then return true end -- plaza
                if math.abs(fz - 50) < 5 and fx > -34 and fx < 54 then return true end -- jalan ruangan
                return false
        end
        for i = 1, 10 do
                local fx = rng:NextNumber(-92, 92)
                local fz = rng:NextNumber(-82, 82)
                if not blocked(fx, fz) then
                        part({
                                Name = "RumahBunga" .. i,
                                Shape = Enum.PartType.Ball,
                                Size = Vector3.new(1, 1, 1) * rng:NextNumber(0.8, 1.4),
                                CFrame = CFrame.new(at(fx, 0.55, fz)),
                                Color = flowerColors[rng:NextInteger(1, #flowerColors)],
                                Material = Enum.Material.Grass,
                                CanCollide = false,
                        })
                end
        end
end

return PersonalWorldBuilder
