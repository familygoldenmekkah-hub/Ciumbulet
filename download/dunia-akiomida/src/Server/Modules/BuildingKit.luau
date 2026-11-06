local BuildingKit = {}

local CREAM = Color3.fromRGB(234, 222, 192)
local DARKWOOD = Color3.fromRGB(84, 62, 44)
local FLOORWOOD = Color3.fromRGB(128, 96, 62)
local BRICKRED = Color3.fromRGB(148, 62, 48)
local STONE = Color3.fromRGB(128, 128, 126)
local GLASS = Color3.fromRGB(200, 228, 235)

BuildingKit.CREAM = CREAM
BuildingKit.DARKWOOD = DARKWOOD
BuildingKit.FLOORWOOD = FLOORWOOD
BuildingKit.BRICKRED = BRICKRED
BuildingKit.STONE = STONE
BuildingKit.GLASS = GLASS

function BuildingKit.part(parent: Instance, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?, transparency: number?): Part
        local p = Instance.new("Part")
        p.Anchored = true
        p.Size = size
        p.CFrame = cf
        p.Color = color
        p.Material = material or Enum.Material.SmoothPlastic
        p.TopSurface = Enum.SurfaceType.Smooth
        p.BottomSurface = Enum.SurfaceType.Smooth
        if transparency then
                p.Transparency = transparency
        end
        p.Parent = parent
        return p
end

function BuildingKit.wedge(parent: Instance, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?): WedgePart
        local w = Instance.new("WedgePart")
        w.Anchored = true
        w.Size = size
        w.CFrame = cf
        w.Color = color
        w.Material = material or Enum.Material.SmoothPlastic
        w.Parent = parent
        return w
end

function BuildingKit.gableRoof(parent: Instance, w: number, d: number, oh: number, y0: number, color: Color3)
        local slope = math.rad(30)
        local hd = d / 2 + oh
        local rise = hd * math.tan(slope)
        local slabLen = hd / math.cos(slope)
        BuildingKit.part(parent, Vector3.new(w + 2 * oh, 1, slabLen), CFrame.new(0, y0 + rise / 2, -hd / 2) * CFrame.Angles(-slope, 0, 0), color, Enum.Material.Slate)
        BuildingKit.part(parent, Vector3.new(w + 2 * oh, 1, slabLen), CFrame.new(0, y0 + rise / 2, hd / 2) * CFrame.Angles(slope, 0, 0), color, Enum.Material.Slate)
        for sx = -1, 1, 2 do
                local x = sx * (w / 2 - 0.5)
                BuildingKit.wedge(parent, Vector3.new(1, rise, d / 2), CFrame.new(x, y0 + rise / 2, -d / 4), color, Enum.Material.Slate)
                BuildingKit.wedge(parent, Vector3.new(1, rise, d / 2), CFrame.new(x, y0 + rise / 2, d / 4) * CFrame.Angles(0, math.rad(180), 0), color, Enum.Material.Slate)
        end
end

function BuildingKit.lamp(parent: Instance, x: number, ceilingY: number, z: number)
        local rod = BuildingKit.part(parent, Vector3.new(0.5, 3, 0.5), CFrame.new(x, ceilingY - 1.5, z), DARKWOOD, Enum.Material.Wood)
        rod.CanCollide = false
        local shade = BuildingKit.part(parent, Vector3.new(2, 1, 2), CFrame.new(x, ceilingY - 3.5, z), Color3.fromRGB(235, 205, 130), Enum.Material.Neon)
        shade.CanCollide = false
        local light = Instance.new("PointLight")
        light.Range = 16
        light.Brightness = 0.6
        light.Color = Color3.fromRGB(255, 224, 178)
        light.Parent = shade
end

function BuildingKit.streetLamp(parent: Instance, x: number, groundTop: number, z: number)
        BuildingKit.part(parent, Vector3.new(2, 8, 2), CFrame.new(x, groundTop + 4, z), DARKWOOD, Enum.Material.Wood)
        local head = BuildingKit.part(parent, Vector3.new(2, 1, 2), CFrame.new(x, groundTop + 8.5, z), Color3.fromRGB(235, 205, 130), Enum.Material.Neon)
        local light = Instance.new("PointLight")
        light.Range = 20
        light.Brightness = 0.55
        light.Color = Color3.fromRGB(255, 224, 178)
        light.Parent = head
end

function BuildingKit.fenceLine(parent: Instance, x1: number, z1: number, x2: number, z2: number, groundTop: number)
        local dx, dz = x2 - x1, z2 - z1
        local len = math.sqrt(dx * dx + dz * dz)
        if len < 2 then
                return
        end
        local alongX = math.abs(dx) >= math.abs(dz)
        local size = alongX and Vector3.new(len, 2, 1) or Vector3.new(1, 2, len)
        local mid = Vector3.new((x1 + x2) / 2, groundTop + 3, (z1 + z2) / 2)
        BuildingKit.part(parent, size, CFrame.new(mid), DARKWOOD, Enum.Material.Wood)
        local n = math.max(1, math.floor(len / 40))
        for i = 0, n do
                local t = i / n
                local px = x1 + dx * t
                local pz = z1 + dz * t
                BuildingKit.part(parent, Vector3.new(2, 6, 2), CFrame.new(px, groundTop + 3, pz), DARKWOOD, Enum.Material.Wood)
        end
end

function BuildingKit.marker(parent: Instance, cx: number, cz: number, groundTop: number, w: number, d: number, color: Color3)
        local y = groundTop + 0.15
        local t = 0.4
        local mk = function(size: Vector3, pos: Vector3)
                local p = BuildingKit.part(parent, size, CFrame.new(pos), color, Enum.Material.SmoothPlastic, 0.35)
                p.CanCollide = false
                return p
        end
        mk(Vector3.new(w, t, t), Vector3.new(cx, y, cz - d / 2))
        mk(Vector3.new(w, t, t), Vector3.new(cx, y, cz + d / 2))
        mk(Vector3.new(t, t, d), Vector3.new(cx - w / 2, y, cz))
        mk(Vector3.new(t, t, d), Vector3.new(cx + w / 2, y, cz))
end

local function trim(parent: Instance, w: number, d: number, y: number)
        BuildingKit.part(parent, Vector3.new(w + 2, 1, 0.5), CFrame.new(0, y, -(d / 2 + 0.75)), BuildingKit.DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(parent, Vector3.new(w + 2, 1, 0.5), CFrame.new(0, y, d / 2 + 0.75), BuildingKit.DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(parent, Vector3.new(0.5, 1, d + 2), CFrame.new(-(w / 2 + 0.75), y, 0), BuildingKit.DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(parent, Vector3.new(0.5, 1, d + 2), CFrame.new(w / 2 + 0.75, y, 0), BuildingKit.DARKWOOD, Enum.Material.Wood)
end

local function seedBag(parent: Instance, cf: CFrame, color: Color3)
        local body = BuildingKit.part(parent, Vector3.new(1.2, 1.4, 0.8), cf, color, Enum.Material.Fabric)
        local band = BuildingKit.part(parent, Vector3.new(1.3, 0.25, 0.9), cf * CFrame.new(0, 0.35, 0), Color3.fromRGB(84, 62, 44), Enum.Material.Fabric)
        band.CanCollide = false
        return body
end

local function potPlant(parent: Instance, cf: CFrame)
        local pot = BuildingKit.part(parent, Vector3.new(1.2, 1, 1.2), cf, Color3.fromRGB(172, 96, 66), Enum.Material.SmoothPlastic)
        local tanah = BuildingKit.part(parent, Vector3.new(1, 0.2, 1), cf * CFrame.new(0, 0.55, 0), Color3.fromRGB(84, 62, 44), Enum.Material.Ground)
        tanah.CanCollide = false
        local tanaman = BuildingKit.part(parent, Vector3.new(0.9, 1.2, 0.9), cf * CFrame.new(0, 1.25, 0), Color3.fromRGB(88, 140, 66), Enum.Material.Grass)
        tanaman.CanCollide = false
        return pot
end

local function priceTag(parent: Instance, cf: CFrame, teks: string)
        local papan = BuildingKit.part(parent, Vector3.new(2.4, 1.2, 0.2), cf, BuildingKit.DARKWOOD, Enum.Material.Wood)
        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Front
        gui.CanvasSize = Vector2.new(240, 120)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Text = teks
        label.TextColor3 = Color3.fromRGB(255, 232, 180)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = gui
        gui.Parent = papan
        return papan
end

local function textBoard(parent: Instance, size: Vector3, cf: CFrame, teks: string, face: Enum.NormalId)
        local papan = BuildingKit.part(parent, size, cf, BuildingKit.CREAM, Enum.Material.Wood)
        local gui = Instance.new("SurfaceGui")
        gui.Face = face
        gui.CanvasSize = Vector2.new(400, 120)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Text = teks
        label.TextColor3 = Color3.fromRGB(84, 62, 44)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = gui
        gui.Parent = papan
        return papan
end

local function hingedDoor(model: Instance, size: Vector3, closedCF: CFrame, hingeLocal: Vector3, openAngle: number): Part
        local leaf = BuildingKit.part(model, size, closedCF, BuildingKit.DARKWOOD, Enum.Material.Wood)
        leaf:SetAttribute("PintuDaun", true)
        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Buka Pintu"
        prompt.ObjectText = "Pintu"
        prompt.HoldDuration = 0.2
        prompt.MaxActivationDistance = 9
        prompt.RequiresLineOfSight = false
        prompt.Parent = leaf
        local terbuka = false
        local bergerak = false
        local storedClosed: CFrame? = nil
        local function swing(target: CFrame, nextAction: string)
                bergerak = true
                prompt.Enabled = false
                local from = leaf.CFrame
                task.spawn(function()
                        for i = 1, 6 do
                                task.wait(0.04)
                                leaf.CFrame = from:Lerp(target, i / 6)
                        end
                        leaf.CFrame = target
                        prompt.ActionText = nextAction
                        prompt.Enabled = true
                        bergerak = false
                end)
        end
        prompt.Triggered:Connect(function()
                if bergerak then
                        return
                end
                if not terbuka then
                        local base = leaf.CFrame
                        storedClosed = base
                        local hinge = base * CFrame.new(hingeLocal.X, hingeLocal.Y, hingeLocal.Z)
                        local openCF = hinge * CFrame.Angles(0, openAngle, 0) * hinge:Inverse() * base
                        terbuka = true
                        swing(openCF, "Tutup Pintu")
                else
                        terbuka = false
                        swing(storedClosed or leaf.CFrame, "Buka Pintu")
                end
        end)
        return leaf
end

function BuildingKit.buildToko(parent: Instance): Model
        local model = Instance.new("Model")
        model.Name = "TokoBenih"
        local w, d = 40, 30
        BuildingKit.part(model, Vector3.new(w + 2, 1, d + 2), CFrame.new(0, 0.5, 0), STONE, Enum.Material.Slate)
        BuildingKit.part(model, Vector3.new(w - 2, 1, d - 2), CFrame.new(0, 1.5, 0), FLOORWOOD, Enum.Material.WoodPlanks)
        BuildingKit.part(model, Vector3.new(w, 20, 1), CFrame.new(0, 11, d / 2 - 0.5), CREAM)
        BuildingKit.part(model, Vector3.new(1, 20, d - 2), CFrame.new(-(w / 2 - 0.5), 11, 0), CREAM)
        BuildingKit.part(model, Vector3.new(1, 20, d - 2), CFrame.new(w / 2 - 0.5, 11, 0), CREAM)
        local fz = -(d / 2 - 0.5)
        BuildingKit.part(model, Vector3.new(5, 20, 1), CFrame.new(-17.5, 11, fz), CREAM)
        BuildingKit.part(model, Vector3.new(2, 20, 1), CFrame.new(-4, 11, fz), CREAM)
        BuildingKit.part(model, Vector3.new(2, 20, 1), CFrame.new(4, 11, fz), CREAM)
        BuildingKit.part(model, Vector3.new(5, 20, 1), CFrame.new(17.5, 11, fz), CREAM)
        BuildingKit.part(model, Vector3.new(10, 4, 1), CFrame.new(-10, 3, fz), CREAM)
        BuildingKit.part(model, Vector3.new(10, 4, 1), CFrame.new(10, 3, fz), CREAM)
        BuildingKit.part(model, Vector3.new(6, 9, 1), CFrame.new(0, 16.5, fz), CREAM)
        local glassL = BuildingKit.part(model, Vector3.new(10, 8, 0.4), CFrame.new(-10, 9, fz), GLASS, Enum.Material.Glass, 0.5)
        glassL.CanCollide = false
        local glassR = BuildingKit.part(model, Vector3.new(10, 8, 0.4), CFrame.new(10, 9, fz), GLASS, Enum.Material.Glass, 0.5)
        glassR.CanCollide = false
        for sx = -1, 1, 2 do
                for sz = -1, 1, 2 do
                        BuildingKit.part(model, Vector3.new(2, 20, 2), CFrame.new(sx * (w / 2 - 1), 11, sz * (d / 2 - 1)), DARKWOOD, Enum.Material.Wood)
                end
        end
        trim(model, w, d, 1.5)
        trim(model, w, d, 20.5)
        BuildingKit.gableRoof(model, w, d, 3, 21, BRICKRED)
        BuildingKit.part(model, Vector3.new(w, 1, 4), CFrame.new(0, 12.5, -(d / 2 + 2)), BRICKRED, Enum.Material.Slate)
        BuildingKit.part(model, Vector3.new(2, 12, 2), CFrame.new(-17, 6, -(d / 2 + 4)), DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(model, Vector3.new(2, 12, 2), CFrame.new(17, 6, -(d / 2 + 4)), DARKWOOD, Enum.Material.Wood)
        local sign = BuildingKit.part(model, Vector3.new(16, 4, 0.5), CFrame.new(0, 14, -(d / 2 + 0.4)), DARKWOOD, Enum.Material.Wood)
        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Front
        gui.CanvasSize = Vector2.new(400, 100)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Text = "TOKO BENIH"
        label.TextColor3 = Color3.fromRGB(255, 232, 180)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = gui
        gui.Parent = sign
        BuildingKit.part(model, Vector3.new(12, 4, 3), CFrame.new(-8, 4, -10), DARKWOOD, Enum.Material.Wood)
        local rakKiri = BuildingKit.part(model, Vector3.new(8, 8, 2), CFrame.new(-10, 6, 13), DARKWOOD, Enum.Material.Wood)
        local rakKanan = BuildingKit.part(model, Vector3.new(8, 8, 2), CFrame.new(10, 6, 13), DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(model, Vector3.new(2, 8, 8), CFrame.new(-18, 6, 4), DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(model, Vector3.new(2, 8, 8), CFrame.new(18, 6, 4), DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(model, Vector3.new(6, 4, 3), CFrame.new(0, 4, 2), DARKWOOD, Enum.Material.Wood)
        rakKiri:SetAttribute("Rak", true)
        rakKanan:SetAttribute("Rak", true)

        local BAG_A = Color3.fromRGB(150, 108, 62)
        local BAG_B = Color3.fromRGB(96, 128, 72)
        local BAG_C = Color3.fromRGB(196, 168, 120)

        for sx = -1, 1, 2 do
                local rx = sx * 10
                BuildingKit.part(model, Vector3.new(8, 0.3, 1.6), CFrame.new(rx, 5.4, 11.6), FLOORWOOD, Enum.Material.WoodPlanks).CanCollide = false
                BuildingKit.part(model, Vector3.new(8, 0.3, 1.6), CFrame.new(rx, 8, 11.6), FLOORWOOD, Enum.Material.WoodPlanks).CanCollide = false
                seedBag(model, CFrame.new(rx - 2.6, 6.2, 11.6), BAG_A)
                seedBag(model, CFrame.new(rx, 6.2, 11.6), BAG_B)
                seedBag(model, CFrame.new(rx + 2.6, 6.2, 11.6), BAG_C)
                seedBag(model, CFrame.new(rx - 1.6, 8.8, 11.6), BAG_B)
                seedBag(model, CFrame.new(rx + 1.6, 8.8, 11.6), BAG_A)
                seedBag(model, CFrame.new(rx - 1.6, 11.4, 13), BAG_A)
                seedBag(model, CFrame.new(rx + 1.6, 11.4, 13), BAG_B)
                potPlant(model, CFrame.new(rx + 3.4, 10.5, 13))
        end
        seedBag(model, CFrame.new(-18, 10.4, 4), BAG_C)
        seedBag(model, CFrame.new(-18, 10.4, 5.6), BAG_A)
        seedBag(model, CFrame.new(18, 10.4, 4), BAG_B)
        potPlant(model, CFrame.new(18, 10.4, 5.8))
        potPlant(model, CFrame.new(-10, 5.6, -14))
        potPlant(model, CFrame.new(10, 5.6, -14))
        seedBag(model, CFrame.new(-11.4, 5.2, -10.4), BAG_A)
        seedBag(model, CFrame.new(-4.6, 5.2, -9.6), BAG_B)
        BuildingKit.part(model, Vector3.new(1.6, 1, 1.2), CFrame.new(-3.4, 4.5, -10), Color3.fromRGB(56, 44, 36), Enum.Material.Wood)
        BuildingKit.part(model, Vector3.new(1.2, 0.3, 0.9), CFrame.new(-3.4, 5.15, -10), Color3.fromRGB(255, 214, 110), Enum.Material.Neon)
        BuildingKit.part(model, Vector3.new(2.2, 2.2, 2.2), CFrame.new(2, 3.1, -5.4), BAG_C, Enum.Material.Fabric)
        BuildingKit.part(model, Vector3.new(2.2, 2.2, 2.2), CFrame.new(4.5, 3.1, -6.4), BAG_A, Enum.Material.Fabric)
        BuildingKit.part(model, Vector3.new(2.2, 1.6, 2.2), CFrame.new(3.2, 5.2, -5.9), BAG_B, Enum.Material.Fabric)
        BuildingKit.part(model, Vector3.new(3, 2, 3), CFrame.new(-16.5, 3, -3), Color3.fromRGB(122, 96, 58), Enum.Material.WoodPlanks)
        seedBag(model, CFrame.new(-16.5, 4.8, -3), BAG_A)
        seedBag(model, CFrame.new(-15.3, 4.8, -3.4), BAG_B)
        priceTag(model, CFrame.new(-13.2, 6.4, -8.4) * CFrame.Angles(0, math.rad(90), 0), "Pack Common 2.400")
        priceTag(model, CFrame.new(-13.2, 4.9, -11.6) * CFrame.Angles(0, math.rad(90), 0), "Pack Rare 9.000")
        priceTag(model, CFrame.new(-10, 10.6, 11.9), "Benih Aneka")
        priceTag(model, CFrame.new(10, 10.6, 11.9), "Benih Pilihan")
        textBoard(model, Vector3.new(10, 3, 0.4), CFrame.new(-8, 12.5, -14.1), "PACK BENIH 3 ISI", Enum.NormalId.Back)
        textBoard(model, Vector3.new(9, 1.6, 0.3), CFrame.new(0, 17.2, -8), "BENIH SEGAR SETIAP HARI", Enum.NormalId.Front)

        local PACK_COLORS = { BAG_A, BAG_B, BAG_C }
        for sx = -1, 1, 2 do
                local rx = sx * 10
                for tier = 0, 1 do
                        local py = 5.55 + tier * 2.6
                        for i = 0, 7 do
                                BuildingKit.part(model, Vector3.new(0.62, 0.85, 0.14), CFrame.new(rx - 3.2 + i * 0.92, py + 0.45, 11.62), PACK_COLORS[(i + tier) % 3 + 1], Enum.Material.SmoothPlastic)
                        end
                end
                BuildingKit.part(model, Vector3.new(2, 2.4, 1.2), CFrame.new(rx - 2, 10.7, 13), PACK_COLORS[sx == 1 and 1 or 2], Enum.Material.Fabric)
                BuildingKit.part(model, Vector3.new(2, 2.4, 1.2), CFrame.new(rx + 2, 10.7, 13), PACK_COLORS[sx == 1 and 3 or 1], Enum.Material.Fabric)
                for t2 = 0, 1 do
                        local sy = 5.55 + t2 * 2.6
                        BuildingKit.part(model, Vector3.new(1.2, 0.3, 6), CFrame.new(sx * 16.3, sy, 4), FLOORWOOD, Enum.Material.WoodPlanks).CanCollide = false
                        for i = 0, 5 do
                                BuildingKit.part(model, Vector3.new(0.14, 0.85, 0.62), CFrame.new(sx * 15.55, sy + 0.58, 1.5 + i * 1.05), PACK_COLORS[(i + t2) % 3 + 1], Enum.Material.SmoothPlastic)
                        end
                end
        end
        local function crate(cx: number, cy: number, cz: number)
                BuildingKit.part(model, Vector3.new(2.4, 2.4, 2.4), CFrame.new(cx, cy, cz), Color3.fromRGB(150, 116, 74), Enum.Material.WoodPlanks)
                BuildingKit.part(model, Vector3.new(1.8, 0.2, 1.8), CFrame.new(cx, cy + 1.3, cz), FLOORWOOD, Enum.Material.WoodPlanks).CanCollide = false
        end
        crate(-14, 1.3, -5)
        crate(-14, 3.7, -5)
        crate(-11.5, 1.3, -3.5)
        seedBag(model, CFrame.new(-14, 5.4, -5), BAG_B)
        seedBag(model, CFrame.new(-13.4, 5.4, -5.2), BAG_A)
        BuildingKit.part(model, Vector3.new(3.4, 1.1, 2), CFrame.new(-6, 6.55, -10), GLASS, Enum.Material.Glass, 0.4).CanCollide = false
        BuildingKit.part(model, Vector3.new(0.8, 0.6, 1.4), CFrame.new(-4.2, 6.3, -10), Color3.fromRGB(56, 44, 36), Enum.Material.Wood)
        seedBag(model, CFrame.new(-6.8, 6.75, -10), BAG_C)
        seedBag(model, CFrame.new(-5.6, 6.75, -9.6), BAG_A)
        textBoard(model, Vector3.new(3, 1.4, 0.3), CFrame.new(-8, 7.6, -10), "BUKA", Enum.NormalId.Back)
        textBoard(model, Vector3.new(0.3, 5, 8), CFrame.new(-19.2, 13, -2), "PANDUAN TANAM 3 DETIK", Enum.NormalId.Right)
        textBoard(model, Vector3.new(14, 1.6, 0.2), CFrame.new(0, 16, 6), "BENIH UNGGUL SETIAP HARI", Enum.NormalId.Front)
        BuildingKit.part(model, Vector3.new(0.2, 2.6, 0.2), CFrame.new(-5, 18, 6), DARKWOOD, Enum.Material.Wood).CanCollide = false
        BuildingKit.part(model, Vector3.new(0.2, 2.6, 0.2), CFrame.new(5, 18, 6), DARKWOOD, Enum.Material.Wood).CanCollide = false
        local mat = BuildingKit.part(model, Vector3.new(6, 0.1, 3), CFrame.new(0, 2.05, -12.5), BRICKRED, Enum.Material.Fabric)
        mat.CanCollide = false
        BuildingKit.part(model, Vector3.new(0.4, 5, 0.4), CFrame.new(6, 2.5, -18), DARKWOOD, Enum.Material.Wood)
        textBoard(model, Vector3.new(4.2, 3, 0.3), CFrame.new(6, 6.2, -18), "PROMO PACK BENIH", Enum.NormalId.Back)
        BuildingKit.part(model, Vector3.new(2.2, 2.2, 2.2), CFrame.new(16, 1.3, 10.6), BAG_C, Enum.Material.Fabric)
        BuildingKit.part(model, Vector3.new(2.2, 2.2, 2.2), CFrame.new(13.6, 1.3, 10.8), BAG_A, Enum.Material.Fabric)
        BuildingKit.part(model, Vector3.new(2, 1.8, 2), CFrame.new(14.8, 3.2, 10.7), BAG_B, Enum.Material.Fabric)
        potPlant(model, CFrame.new(-15.5, 2.5, -12.5))
        potPlant(model, CFrame.new(15.5, 2.5, -12.5))

        BuildingKit.part(model, Vector3.new(6.4, 2, 1), CFrame.new(0, 11, fz), CREAM)
        hingedDoor(model, Vector3.new(3, 10, 0.5), CFrame.new(-1.5, 5, fz), Vector3.new(-1.55, 0, 0), -math.rad(105))
        hingedDoor(model, Vector3.new(3, 10, 0.5), CFrame.new(1.5, 5, fz), Vector3.new(1.55, 0, 0), math.rad(105))

        BuildingKit.part(model, Vector3.new(0.2, 2.4, 0.2), CFrame.new(-4, 18.6, -8), DARKWOOD, Enum.Material.Wood).CanCollide = false
        BuildingKit.part(model, Vector3.new(0.2, 2.4, 0.2), CFrame.new(4, 18.6, -8), DARKWOOD, Enum.Material.Wood).CanCollide = false
        BuildingKit.lamp(model, -12, 21, 0)
        BuildingKit.lamp(model, 0, 21, 0)
        BuildingKit.lamp(model, 12, 21, 0)
        model.Parent = parent
        model.WorldPivot = CFrame.new(0, 0, 0)
        return model
end

function BuildingKit.buildSemai(parent: Instance): Model
        local model = Instance.new("Model")
        model.Name = "SemaiPanen"
        local w, d = 30, 30
        BuildingKit.part(model, Vector3.new(w + 2, 1, d + 2), CFrame.new(0, 0.5, 0), STONE, Enum.Material.Slate)
        BuildingKit.part(model, Vector3.new(w - 2, 1, d - 2), CFrame.new(0, 1.5, 0), FLOORWOOD, Enum.Material.WoodPlanks)
        BuildingKit.part(model, Vector3.new(w, 20, 1), CFrame.new(0, 11, d / 2 - 0.5), CREAM)
        BuildingKit.part(model, Vector3.new(1, 20, d - 2), CFrame.new(-(w / 2 - 0.5), 11, 0), CREAM)
        BuildingKit.part(model, Vector3.new(1, 20, d - 2), CFrame.new(w / 2 - 0.5, 11, 0), CREAM)
        local fz = -(d / 2 - 0.5)
        BuildingKit.part(model, Vector3.new(5, 20, 1), CFrame.new(-12.5, 11, fz), CREAM)
        BuildingKit.part(model, Vector3.new(5, 20, 1), CFrame.new(12.5, 11, fz), CREAM)
        BuildingKit.part(model, Vector3.new(20, 9, 1), CFrame.new(0, 16.5, fz), CREAM)
        for sx = -1, 1, 2 do
                BuildingKit.part(model, Vector3.new(2, 20, 2), CFrame.new(sx * 11, 11, -13.5), DARKWOOD, Enum.Material.Wood)
                BuildingKit.part(model, Vector3.new(2, 20, 2), CFrame.new(sx * 13, 11, 13), DARKWOOD, Enum.Material.Wood)
        end
        trim(model, w, d, 1.5)
        trim(model, w, d, 20.5)
        BuildingKit.gableRoof(model, w, d, 3, 21, BRICKRED)
        BuildingKit.part(model, Vector3.new(12, 4, 4), CFrame.new(0, 4, 2), DARKWOOD, Enum.Material.Wood)
        local pad = BuildingKit.part(model, Vector3.new(8, 0.4, 4), CFrame.new(0, 2.4, -6), BRICKRED, Enum.Material.SmoothPlastic, 0.3)
        pad.CanCollide = false
        BuildingKit.part(model, Vector3.new(20.4, 2, 1), CFrame.new(0, 11, fz), CREAM)
        hingedDoor(model, Vector3.new(10, 10, 0.5), CFrame.new(-5, 5, fz), Vector3.new(-5.05, 0, 0), -math.rad(105))
        hingedDoor(model, Vector3.new(10, 10, 0.5), CFrame.new(5, 5, fz), Vector3.new(5.05, 0, 0), math.rad(105))
        BuildingKit.lamp(model, -6, 21, 0)
        BuildingKit.lamp(model, 6, 21, 0)
        model.Parent = parent
        model.WorldPivot = CFrame.new(0, 0, 0)
        return model
end

return BuildingKit
