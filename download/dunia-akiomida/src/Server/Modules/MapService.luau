--!nonstrict
--[[
        MapService.luau
        Pulau panjang berisi 6 zona (bioma prosedural, tanpa aset eksternal):
          kamp - hutan - gunung - kota - lembah - salju
        Tiap zona: alas berwarna, gerbang label, NPC cerita (ProximityPrompt),
        dan Papan Bahasan (materi baca). Semua karya original.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Remotes)
local Util = require(ReplicatedStorage.Shared.Util)

local MapService = {}

local folder = Instance.new("Folder")
folder.Name = "DuniaAkiomida"

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

local function zoneCenter(zoneIndex: number): Vector3
        return Vector3.new(0, 0, Config.World.StartZ + (zoneIndex - 1) * Config.World.ZoneSpacing)
end

--------------------------------------------------------------------
-- BIOMA (dekorasi per zona)
--------------------------------------------------------------------

local function biomeKamp(center: Vector3, color: Color3)
        -- tenda: dua papan miring membentuk atap
        for i = 0, 1 do
                part({
                        Name = "Tenda" .. i,
                        Size = Vector3.new(8, 0.8, 6),
                        CFrame = CFrame.new(center + Vector3.new(-6, 4.2, 8)) * CFrame.Angles(i == 0 and math.rad(35) or math.rad(-35), 0, i == 0 and math.rad(-28) or math.rad(28)),
                        Color = color,
                        Material = Enum.Material.Fabric,
                })
        end
        -- api unggun
        part({
                Name = "ApiUnggun",
                Shape = Enum.PartType.Ball,
                Size = Vector3.new(2.4, 2.4, 2.4),
                CFrame = CFrame.new(center + Vector3.new(0, 1.8, 10)),
                Color = Color3.fromRGB(255, 140, 60),
                Material = Enum.Material.Neon,
        })
        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(255, 160, 80)
        light.Range = 22
        light.Brightness = 1.6
        light.Parent = folder.ApiUnggun
        -- kayu tumpuk
        for i = 1, 3 do
                part({
                        Name = "Kayu" .. i,
                        Size = Vector3.new(1.2, 1.2, 5),
                        CFrame = CFrame.new(center + Vector3.new(7, 0.6 + (i - 1) * 1.2, 12)) * CFrame.Angles(0, math.rad(15 * i), 0),
                        Color = Color3.fromRGB(120, 82, 45),
                        Material = Enum.Material.Wood,
                })
        end
end

local function biomeHutan(center: Vector3, color: Color3)
        local rng = Random.new(11)
        for i = 1, 10 do
                local x = rng:NextNumber(-30, 30)
                local z = rng:NextNumber(-18, 18)
                part({
                        Name = "Pohon" .. i,
                        Size = Vector3.new(1.6, rng:NextNumber(7, 12), 1.6),
                        CFrame = CFrame.new(center + Vector3.new(x, 5, z)),
                        Color = Color3.fromRGB(46, 110, 88),
                        Material = Enum.Material.Grass,
                })
                part({
                        Name = "Dedaunan" .. i,
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(7, 7, 7),
                        CFrame = CFrame.new(center + Vector3.new(x, 11, z)),
                        Color = Color3.fromRGB(40, 150, 100),
                        Material = Enum.Material.Grass,
                })
        end
        -- simbol matematika melayang
        local symbols = { "+", "-", "x", ":", "=", "pi" }
        for i, sym in symbols do
                local angle = (i / #symbols) * math.pi * 2
                part({
                        Name = "Simbol" .. i,
                        Size = Vector3.new(3, 3, 0.4),
                        CFrame = CFrame.new(center + Vector3.new(math.cos(angle) * 22, 9 + (i % 3), math.sin(angle) * 22))
                                * CFrame.Angles(0, angle + math.rad(90), 0),
                        Color = color,
                        Material = Enum.Material.Neon,
                        Transparency = 0.15,
                })
        end
end

local function biomeGunung(center: Vector3, color: Color3)
        local specs = {
                { x = -16, h = 26, r = 10 },
                { x = 14, h = 34, r = 12 },
                { x = 0, h = 44, r = 14 },
        }
        for i, spec in specs do
                local layers = 4
                for l = 1, layers do
                        local t = l / layers
                        part({
                                Name = "Gunung" .. i .. "L" .. l,
                                Shape = Enum.PartType.Cylinder,
                                Size = Vector3.new(spec.h / layers, spec.r * (1 - t) * 2 + 2, spec.r * (1 - t) * 2 + 2),
                                CFrame = CFrame.new(center + Vector3.new(spec.x, spec.h / layers * (l - 0.5), 0))
                                        * CFrame.Angles(0, 0, math.rad(90)),
                                Color = color:Lerp(Color3.fromRGB(255, 255, 255), t * 0.85),
                                Material = Enum.Material.Slate,
                        })
                end
        end
end

local function biomeKota(center: Vector3, color: Color3)
        -- kolom-kolom kota bukti
        local rng = Random.new(44)
        for i = 1, 6 do
                local x = rng:NextNumber(-26, 26)
                local z = rng:NextNumber(-14, 14)
                local h = rng:NextNumber(8, 18)
                part({
                        Name = "Kolom" .. i,
                        Size = Vector3.new(4, h, 4),
                        CFrame = CFrame.new(center + Vector3.new(x, h / 2, z)),
                        Color = Color3.fromRGB(235, 230, 220),
                        Material = Enum.Material.Marble,
                })
                part({
                        Name = "AtapKolom" .. i,
                        Size = Vector3.new(5, 1, 5),
                        CFrame = CFrame.new(center + Vector3.new(x, h + 0.5, z)),
                        Color = color,
                        Material = Enum.Material.Marble,
                })
        end
end

local function biomeLembah(center: Vector3, color: Color3)
        -- cekungan: dinding rendah keliling
        for i = 1, 4 do
                local angle = (i / 4) * math.pi * 2
                part({
                        Name = "DindingLembah" .. i,
                        Size = Vector3.new(40, 10, 3),
                        CFrame = CFrame.new(center + Vector3.new(math.cos(angle) * 26, 5, math.sin(angle) * 26))
                                * CFrame.Angles(0, -angle + math.rad(90), 0),
                        Color = Color3.fromRGB(70, 55, 95),
                        Material = Enum.Material.Slate,
                })
        end
        local rng = Random.new(5)
        for i = 1, 5 do
                part({
                        Name = "KristalLembah" .. i,
                        Size = Vector3.new(2.4, rng:NextNumber(5, 9), 2.4),
                        CFrame = CFrame.new(center + Vector3.new(rng:NextNumber(-18, 18), 3.5, rng:NextNumber(-12, 12)))
                                * CFrame.Angles(0, rng:NextNumber(0, math.pi), math.rad(14)),
                        Color = color,
                        Material = Enum.Material.Neon,
                        Transparency = 0.1,
                })
        end
end

local function biomeSalju(center: Vector3, color: Color3)
        local layers = 4
        for l = 1, layers do
                local t = l / layers
                part({
                        Name = "PuncakL" .. l,
                        Shape = Enum.PartType.Cylinder,
                        Size = Vector3.new(10, (16 * (1 - t)) * 2 + 2, (16 * (1 - t)) * 2 + 2),
                        CFrame = CFrame.new(center + Vector3.new(0, 10 / layers * (l - 0.5) + 2, -4))
                                * CFrame.Angles(0, 0, math.rad(90)),
                        Color = Color3.fromRGB(240, 246, 255):Lerp(color, 0.25),
                        Material = Enum.Material.Snow,
                })
        end
        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(200, 230, 255)
        light.Range = 26
        light.Brightness = 0.9
        local holder = folder:FindFirstChild("PuncakL" .. layers)
        if holder then
                light.Parent = holder
        end
end

local BIOMES = { biomeKamp, biomeHutan, biomeGunung, biomeKota, biomeLembah, biomeSalju }

--------------------------------------------------------------------
-- NPC + PAPAN BAHASAN + GERBANG
--------------------------------------------------------------------

local function buildNPC(center: Vector3, zoneIndex: number, color: Color3)
        local name = "KAK " .. string.upper((Config.Zones[zoneIndex].name:split(" ")[2] or "AKIOMIDA"))
        local body = part({
                Name = "NPC_Body_" .. zoneIndex,
                Size = Vector3.new(2.4, 3, 1.6),
                CFrame = CFrame.new(center + Vector3.new(0, 2.5, -6)),
                Color = color,
                Material = Enum.Material.SmoothPlastic,
        })
        local head = part({
                Name = "NPC_Head_" .. zoneIndex,
                Shape = Enum.PartType.Ball,
                Size = Vector3.new(1.8, 1.8, 1.8),
                CFrame = CFrame.new(center + Vector3.new(0, 5.2, -6)),
                Color = Color3.fromRGB(255, 224, 189),
                Material = Enum.Material.SmoothPlastic,
        })

        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 140, 0, 34)
        billboard.StudsOffset = Vector3.new(0, 1.6, 0)
        billboard.AlwaysOnTop = true
        billboard.MaxDistance = 60
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
        prompt.ActionText = "Bicara"
        prompt.ObjectText = name
        prompt.MaxActivationDistance = 12
        prompt.HoldDuration = 0
        prompt.Parent = body
        prompt.Triggered:Connect(function(player)
                Remotes.get("ZoneEntered"):FireClient(player, { type = "npc", zone = zoneIndex })
        end)
end

local function buildBoard(center: Vector3, zoneIndex: number, color: Color3)
        local board = part({
                Name = "PapanBahasan_" .. zoneIndex,
                Size = Vector3.new(10, 6, 0.6),
                CFrame = CFrame.new(center + Vector3.new(-12, 6, -2)) * CFrame.Angles(0, math.rad(35), 0),
                Color = Color3.fromRGB(60, 45, 30),
                Material = Enum.Material.WoodPlanks,
        })
        Util.create("SurfaceGui", {
                Face = Enum.NormalId.Front,
                SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
                PixelsPerStud = 50,
        }, board)
        local gui = board:FindFirstChildOfClass("SurfaceGui")
        Util.create("TextLabel", {
                Size = UDim2.fromScale(1, 0.3),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = color,
                Text = "BAHASAN",
        }, gui)

        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Baca Bahasan"
        prompt.ObjectText = Config.Zones[zoneIndex].name
        prompt.MaxActivationDistance = 10
        prompt.HoldDuration = 0
        prompt.Parent = board
        prompt.Triggered:Connect(function(player)
                Remotes.get("ZoneEntered"):FireClient(player, { type = "board", zone = zoneIndex })
        end)
end

local function buildGate(center: Vector3, zoneIndex: number, color: Color3)
        local zone = Config.Zones[zoneIndex]
        for side = -1, 1, 2 do
                part({
                        Name = "GerbangPilar_" .. zoneIndex .. "_" .. side,
                        Size = Vector3.new(1.6, 12, 1.6),
                        CFrame = CFrame.new(center + Vector3.new(side * 7, 6, 16)),
                        Color = Color3.fromRGB(60, 64, 80),
                        Material = Enum.Material.SmoothPlastic,
                })
        end
        local beam = part({
                Name = "GerbangPalang_" .. zoneIndex,
                Size = Vector3.new(16, 2, 1.4),
                CFrame = CFrame.new(center + Vector3.new(0, 13, 16)),
                Color = Color3.fromRGB(25, 28, 38),
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
                TextColor3 = color,
                Text = string.upper(zone.name),
        }, gui)
end

--------------------------------------------------------------------
-- BUILD ALL
--------------------------------------------------------------------

function MapService.init()
        folder.Parent = workspace

        -- pulau panjang (sumbu panjang = Z, sejajar barisan zona!)
        local totalLen = Config.World.StartZ + (#Config.Zones - 1) * Config.World.ZoneSpacing + 80
        part({
                Name = "Pulau",
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(Config.World.IslandHeight, Config.World.IslandWidth * 2, totalLen),
                CFrame = CFrame.new(0, -Config.World.IslandHeight / 2, totalLen / 2 - 20) * CFrame.Angles(0, 0, math.rad(90)),
                Color = Color3.fromRGB(95, 165, 75),
                Material = Enum.Material.Grass,
        })

        -- samudra luas: cegah pemain jatuh ke kehampaan + memperindah dunia
        part({
                Name = "Samudra",
                Size = Vector3.new(3000, 2, 3000),
                CFrame = CFrame.new(0, -2, totalLen / 2 - 20),
                Color = Color3.fromRGB(58, 132, 195),
                Material = Enum.Material.Glass,
                Transparency = 0.2,
        })

        -- atmosfer lembut biar langit terasa hidup
        local atmo = Instance.new("Atmosphere")
        atmo.Density = 0.3
        atmo.Offset = 0.25
        atmo.Color = Color3.fromRGB(199, 199, 205)
        atmo.Glare = 0.2
        atmo.Haze = 1.6
        atmo.Parent = game:GetService("Lighting")

        -- awan dekoratif (tak bisa ditabrak)
        local rngAwan = Random.new(77)
        for i = 1, 8 do
                part({
                        Name = "Awan" .. i,
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(1, 1, 1) * rngAwan:NextNumber(26, 54),
                        CFrame = CFrame.new(rngAwan:NextNumber(-140, 140), rngAwan:NextNumber(75, 115), rngAwan:NextNumber(-40, totalLen + 40)),
                        Color = Color3.fromRGB(255, 255, 255),
                        Material = Enum.Material.SmoothPlastic,
                        Transparency = 0.4,
                        CanCollide = false,
                })
        end

        -- arch judul di spawn
        part({
                Name = "PilarKiri",
                Size = Vector3.new(2, 14, 2),
                CFrame = CFrame.new(-8, 7, 34),
                Color = Color3.fromRGB(60, 64, 80),
                Material = Enum.Material.SmoothPlastic,
        })
        part({
                Name = "PilarKanan",
                Size = Vector3.new(2, 14, 2),
                CFrame = CFrame.new(8, 7, 34),
                Color = Color3.fromRGB(60, 64, 80),
                Material = Enum.Material.SmoothPlastic,
        })
        local beam = part({
                Name = "PalangJudul",
                Size = Vector3.new(20, 3.5, 1.5),
                CFrame = CFrame.new(0, 15, 34),
                Color = Color3.fromRGB(25, 28, 38),
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

        -- zona per zona
        for zoneIndex, zone in Config.Zones do
                local center = zoneCenter(zoneIndex)
                local color = Util.zoneColor(zone.color)

                -- alas zona berwarna
                part({
                        Name = "AlasZona_" .. zoneIndex,
                        Shape = Enum.PartType.Cylinder,
                        Size = Vector3.new(0.4, 76, 76),
                        CFrame = CFrame.new(center + Vector3.new(0, 0.2, 0)) * CFrame.Angles(0, 0, math.rad(90)),
                        Color = color,
                        Material = Enum.Material.SmoothPlastic,
                        Transparency = 0.45,
                })

                buildGate(center, zoneIndex, color)
                buildNPC(center, zoneIndex, color)
                buildBoard(center, zoneIndex, color)
                BIOMES[zoneIndex](center, color)
        end
end

return MapService
