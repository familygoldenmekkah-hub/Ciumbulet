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
        local BUAH_A = Color3.fromRGB(214, 92, 76)
        local BUAH_B = Color3.fromRGB(226, 176, 64)
        local BUAH_C = Color3.fromRGB(120, 168, 82)
        local BUAH_L = { BUAH_A, BUAH_B, BUAH_C }
        for i = 0, 5 do
                BuildingKit.part(model, Vector3.new(0.9, 0.9, 0.9), CFrame.new(-13.4 + i * 0.95, 2.55, 12.2), BUAH_L[i % 3 + 1], Enum.Material.SmoothPlastic).CanCollide = false
                BuildingKit.part(model, Vector3.new(0.9, 0.9, 0.9), CFrame.new(13.4 + i * 0.95, 2.55, 12.2), BUAH_L[(i + 1) % 3 + 1], Enum.Material.SmoothPlastic).CanCollide = false
        end
        for sx = -1, 1, 2 do
                BuildingKit.part(model, Vector3.new(1.4, 2.6, 1.4), CFrame.new(sx * 15.5, 2.3, 14.8), Color3.fromRGB(122, 96, 58), Enum.Material.WoodPlanks)
                BuildingKit.part(model, Vector3.new(1.5, 0.25, 1.5), CFrame.new(sx * 15.5, 3.7, 14.8), FLOORWOOD, Enum.Material.WoodPlanks).CanCollide = false
                seedBag(model, CFrame.new(sx * 12.6, 1.7, 15), BAG_A)
                seedBag(model, CFrame.new(sx * 12.6, 3.3, 15), BAG_C)
        end
        BuildingKit.part(model, Vector3.new(2.6, 3.2, 2.6), CFrame.new(16.8, 2.1, -12.5), Color3.fromRGB(122, 96, 58), Enum.Material.WoodPlanks)
        BuildingKit.part(model, Vector3.new(2.7, 0.3, 2.7), CFrame.new(16.8, 3.8, -12.5), FLOORWOOD, Enum.Material.WoodPlanks).CanCollide = false
        for i = 0, 2 do
                seedBag(model, CFrame.new(-17 + i * 1.7, 1.5 + (i % 2) * 1.3, -17 + (i % 2) * 1.2), BUAH_L[i + 1])
        end
        potPlant(model, CFrame.new(19, 2.5, 2))
        potPlant(model, CFrame.new(-19, 2.5, -6))

        BuildingKit.part(model, Vector3.new(6.4, 2, 1), CFrame.new(0, 11, fz), CREAM)
        hingedDoor(model, Vector3.new(3, 10, 0.5), CFrame.new(-1.5, 5, fz), Vector3.new(-1.55, 0, 0), -math.rad(105))
        hingedDoor(model, Vector3.new(3, 10, 0.5), CFrame.new(1.5, 5, fz), Vector3.new(1.55, 0, 0), math.rad(105))

        BuildingKit.part(model, Vector3.new(0.2, 2.4, 0.2), CFrame.new(-4, 18.6, -8), DARKWOOD, Enum.Material.Wood).CanCollide = false
        BuildingKit.part(model, Vector3.new(0.2, 2.4, 0.2), CFrame.new(4, 18.6, -8), DARKWOOD, Enum.Material.Wood).CanCollide = false

        for i = 0, 4 do
                local strip = BuildingKit.part(model, Vector3.new(2.2, 0.3, 2.8), CFrame.new(-4.4 + i * 2.2, 11.4, fz - 1.2) * CFrame.Angles(math.rad(-16), 0, 0), (i % 2 == 0) and BRICKRED or CREAM, Enum.Material.Fabric)
                strip.CanCollide = false
        end
        for sx = -1, 1, 2 do
                local rod = BuildingKit.part(model, Vector3.new(0.22, 0.22, 2.4), CFrame.new(sx * 4.9, 10.1, fz - 1.3) * CFrame.Angles(math.rad(-24), 0, 0), DARKWOOD, Enum.Material.Wood)
                rod.CanCollide = false
        end
        for sx = -1, 1, 2 do
                local box = BuildingKit.part(model, Vector3.new(9, 1, 1.2), CFrame.new(sx * 10, 4.3, fz - 0.9), DARKWOOD, Enum.Material.Wood)
                box.CanCollide = false
                for i = 0, 5 do
                        local bunga = BuildingKit.part(model, Vector3.new(0.6, 0.6, 0.6), CFrame.new(sx * 10 - 3.75 + i * 1.5, 5.15, fz - 0.9), (i % 2 == 0) and Color3.fromRGB(214, 92, 76) or Color3.fromRGB(226, 176, 64), Enum.Material.SmoothPlastic)
                        bunga.Shape = Enum.PartType.Ball
                        bunga.CanCollide = false
                end
        end
        for sx = -1, 1, 2 do
                BuildingKit.part(model, Vector3.new(0.3, 0.3, 0.9), CFrame.new(sx * 3.6, 7.8, fz - 0.4), DARKWOOD, Enum.Material.Wood).CanCollide = false
                local badan = BuildingKit.part(model, Vector3.new(0.7, 1.1, 0.7), CFrame.new(sx * 3.6, 7.1, fz - 0.8), GLASS, Enum.Material.Glass, 0.35)
                badan.CanCollide = false
                local api = BuildingKit.part(model, Vector3.new(0.32, 0.5, 0.32), CFrame.new(sx * 3.6, 7, fz - 0.8), Color3.fromRGB(255, 214, 110), Enum.Material.Neon)
                api.CanCollide = false
                local cahaya = Instance.new("PointLight")
                cahaya.Range = 10
                cahaya.Brightness = 0.5
                cahaya.Color = Color3.fromRGB(255, 224, 178)
                cahaya.Parent = api
        end
        for sx = -1, 1, 2 do
                BuildingKit.part(model, Vector3.new(0.3, 5, 0.3), CFrame.new(sx * 14, 33.9, 0), DARKWOOD, Enum.Material.Wood)
                BuildingKit.part(model, Vector3.new(2, 0.9, 0.12), CFrame.new(sx * 15.2, 35.9, 0), BRICKRED, Enum.Material.SmoothPlastic).CanCollide = false
                BuildingKit.part(model, Vector3.new(1.1, 0.6, 0.12), CFrame.new(sx * 15.6, 34.9, 0), CREAM, Enum.Material.SmoothPlastic).CanCollide = false
        end
        local emblem = BuildingKit.part(model, Vector3.new(0.4, 3.6, 3.6), CFrame.new(0, 17.5, fz - 0.7) * CFrame.Angles(0, math.rad(90), 0), BRICKRED, Enum.Material.SmoothPlastic)
        emblem.CanCollide = false
        local emblemIn = BuildingKit.part(model, Vector3.new(0.45, 2.1, 2.1), CFrame.new(0, 17.5, fz - 0.72) * CFrame.Angles(0, math.rad(90), 0), CREAM, Enum.Material.SmoothPlastic)
        emblemIn.CanCollide = false
        for sx = -1, 1, 2 do
                BuildingKit.part(model, Vector3.new(0.3, 6.5, 0.3), CFrame.new(sx * 13, 4.2, -17.3), DARKWOOD, Enum.Material.Wood)
        end
        BuildingKit.part(model, Vector3.new(26.4, 0.12, 0.12), CFrame.new(0, 7.2, -17.3), DARKWOOD, Enum.Material.Wood).CanCollide = false
        for i = 0, 6 do
                local bohlam = BuildingKit.part(model, Vector3.new(0.34, 0.34, 0.34), CFrame.new(-9 + i * 3, 6.9, -17.3), (i % 2 == 0) and Color3.fromRGB(255, 224, 178) or Color3.fromRGB(255, 196, 120), Enum.Material.Neon)
                bohlam.Shape = Enum.PartType.Ball
                bohlam.CanCollide = false
        end
        potPlant(model, CFrame.new(-6.8, 0.5, fz - 2.2))
        potPlant(model, CFrame.new(6.8, 0.5, fz - 2.2))

        BuildingKit.lamp(model, -12, 21, 0)
        BuildingKit.lamp(model, 0, 21, 0)
        BuildingKit.lamp(model, 12, 21, 0)
        model.Parent = parent
        model.WorldPivot = CFrame.new(0, 0, 0)
        return model
end

local STEEL = Color3.fromRGB(150, 156, 164)
local STEEL_DARK = Color3.fromRGB(86, 92, 102)
local STEEL_BLUE = Color3.fromRGB(96, 118, 138)
local ACCENT_ORANGE = Color3.fromRGB(214, 128, 58)
local STRIPE_KUNING = Color3.fromRGB(232, 186, 60)
local KABEL_MERAH = Color3.fromRGB(214, 64, 56)
local KABEL_BIRU = Color3.fromRGB(58, 122, 214)
local KABEL_KUNING = Color3.fromRGB(240, 196, 60)
local HIJAU_BTN = Color3.fromRGB(108, 220, 116)
local LAMPU_OFF = Color3.fromRGB(72, 76, 84)

function BuildingKit.buildMesinSemai(parent: Instance, index: number, hooks): Model
        local model = Instance.new("Model")
        model.Name = "MesinSemaiPanen"
        local w, d = 30, 30
        BuildingKit.part(model, Vector3.new(w + 2, 1, d + 2), CFrame.new(0, 0.5, 0), STONE, Enum.Material.Slate)
        BuildingKit.part(model, Vector3.new(w - 3, 0.3, d - 3), CFrame.new(0, 1, 0), FLOORWOOD, Enum.Material.WoodPlanks)
        for i = 0, 9 do
                BuildingKit.part(model, Vector3.new(2.4, 0.14, 0.7), CFrame.new(-13.5 + i * 3, 1.22, -14.4), (i % 2 == 0) and STRIPE_KUNING or STEEL_DARK, Enum.Material.SmoothPlastic).CanCollide = false
        end
        local sudutPenyokong = math.atan(18 / 20)
        for sx = -1, 1, 2 do
                for sz = -1, 1, 2 do
                        BuildingKit.part(model, Vector3.new(2.2, 0.4, 2.2), CFrame.new(sx * 11, 1.2, sz * 9), STEEL, Enum.Material.Metal)
                        BuildingKit.part(model, Vector3.new(1.2, 20, 1.2), CFrame.new(sx * 11, 11, sz * 9), STEEL_DARK, Enum.Material.Metal)
                end
                BuildingKit.part(model, Vector3.new(0.7, 0.7, 19.2), CFrame.new(sx * 11, 20.65, 0), STEEL_DARK, Enum.Material.Metal)
                local sokA = BuildingKit.part(model, Vector3.new(0.45, 26.91, 0.45), CFrame.new(sx * 11, 11, 0) * CFrame.Angles(sudutPenyokong, 0, 0), STEEL, Enum.Material.Metal)
                sokA.CanCollide = false
                local sokB = BuildingKit.part(model, Vector3.new(0.45, 26.91, 0.45), CFrame.new(sx * 11, 11, 0) * CFrame.Angles(-sudutPenyokong, 0, 0), STEEL, Enum.Material.Metal)
                sokB.CanCollide = false
        end
        for sz = -1, 1, 2 do
                BuildingKit.part(model, Vector3.new(23.2, 0.7, 0.7), CFrame.new(0, 20.65, sz * 9), STEEL_DARK, Enum.Material.Metal)
        end
        local atap = BuildingKit.part(model, Vector3.new(26, 0.6, 22), CFrame.new(0, 21.3, 0) * CFrame.Angles(0, 0, math.rad(3)), STEEL_DARK, Enum.Material.Metal)
        atap.CanCollide = false
        for i = 0, 3 do
                BuildingKit.part(model, Vector3.new(25, 0.25, 1.6), CFrame.new(0, 21.85, -7 + i * 4.6) * CFrame.Angles(0, 0, math.rad(3)), (i % 2 == 0) and BRICKRED or CREAM, Enum.Material.SmoothPlastic).CanCollide = false
        end
        for _, lx in ipairs({ -5, 6 }) do
                local tali = BuildingKit.part(model, Vector3.new(0.3, 7.4, 0.3), CFrame.new(lx, 17.3, 4), STEEL_DARK, Enum.Material.Metal)
                tali.CanCollide = false
                local kap = BuildingKit.part(model, Vector3.new(2.4, 0.9, 2.4), CFrame.new(lx, 13.35, 4), Color3.fromRGB(235, 205, 130), Enum.Material.Neon)
                kap.CanCollide = false
                local cahaya = Instance.new("PointLight")
                cahaya.Range = 18
                cahaya.Brightness = 0.6
                cahaya.Color = Color3.fromRGB(255, 224, 178)
                cahaya.Parent = kap
        end
        BuildingKit.fenceLine(model, -15, 15, 15, 15, 1)
        BuildingKit.fenceLine(model, -15, -15, -15, 15, 1)
        BuildingKit.fenceLine(model, 15, -15, 15, 15, 1)

        local plat = BuildingKit.part(model, Vector3.new(12, 0.6, 7), CFrame.new(0, 1.45, 3), STEEL_DARK, Enum.Material.DiamondPlate)
        plat:SetAttribute("MesinPlat", true)
        BuildingKit.part(model, Vector3.new(10, 0.8, 6), CFrame.new(0, 2.1, 3), STEEL, Enum.Material.Concrete)
        for sx = -1, 1, 2 do
                for sz = -1, 1, 2 do
                        BuildingKit.part(model, Vector3.new(0.8, 1.4, 0.8), CFrame.new(sx * 2.7, 2.9, 3 + sz * 1.7), STEEL_DARK, Enum.Material.Metal)
                end
        end
        BuildingKit.part(model, Vector3.new(6.4, 2.6, 4.4), CFrame.new(0, 4.7, 3), STEEL, Enum.Material.Metal)
        for i = 0, 2 do
                BuildingKit.part(model, Vector3.new(6.5, 0.18, 0.3), CFrame.new(0, 3.9 + i * 0.8, 0.85), STEEL_DARK, Enum.Material.Metal).CanCollide = false
        end
        BuildingKit.part(model, Vector3.new(6.6, 0.5, 4.6), CFrame.new(0, 6.1, 3), STEEL_DARK, Enum.Material.Metal)
        for sx = -1, 1, 2 do
                BuildingKit.part(model, Vector3.new(0.7, 2.6, 5), CFrame.new(sx * 3.1, 7.6, 3), STEEL_DARK, Enum.Material.Metal)
        end

        local drum = BuildingKit.part(model, Vector3.new(7.2, 2.6, 2.6), CFrame.new(0, 7.9, 3), STEEL_BLUE, Enum.Material.Metal)
        drum.Shape = Enum.PartType.Cylinder
        drum.Name = "MesinDrum"
        for i, rib in ipairs({ "MesinRib1", "MesinRib2", "MesinRib3" }) do
                local r = BuildingKit.part(model, Vector3.new(0.35, 2.85, 2.85), CFrame.new(-1.8 + (i - 1) * 2.2, 7.9, 3), ACCENT_ORANGE, Enum.Material.Metal)
                r.Shape = Enum.PartType.Cylinder
                r.Name = rib
                r.CanCollide = false
        end
        local roda = BuildingKit.part(model, Vector3.new(0.7, 3.1, 3.1), CFrame.new(4.4, 7.9, 3), STEEL_DARK, Enum.Material.Metal)
        roda.Shape = Enum.PartType.Cylinder
        roda.Name = "MesinRoda"
        local hub = BuildingKit.part(model, Vector3.new(0.9, 1.2, 1.2), CFrame.new(4.75, 7.9, 3), ACCENT_ORANGE, Enum.Material.Metal)
        hub.Shape = Enum.PartType.Cylinder
        hub.CanCollide = false

        local girA = BuildingKit.part(model, Vector3.new(0.4, 1.7, 1.7), CFrame.new(-1.9, 3.6, 0.7), STEEL_DARK, Enum.Material.Metal)
        girA.Shape = Enum.PartType.Cylinder
        girA.CFrame = CFrame.new(-1.9, 3.6, 0.7) * CFrame.Angles(0, math.rad(90), 0)
        girA.Name = "MesinGirA"
        local girB = BuildingKit.part(model, Vector3.new(0.4, 1.3, 1.3), CFrame.new(1.9, 3.9, 0.7), ACCENT_ORANGE, Enum.Material.Metal)
        girB.Shape = Enum.PartType.Cylinder
        girB.CFrame = CFrame.new(1.9, 3.9, 0.7) * CFrame.Angles(0, math.rad(90), 0)
        girB.Name = "MesinGirB"
        BuildingKit.part(model, Vector3.new(0.12, 0.12, 3.4), CFrame.new(0, 3.75, 0.55) * CFrame.Angles(0, 0, math.rad(4)), STEEL_DARK, Enum.Material.Metal).CanCollide = false

        BuildingKit.part(model, Vector3.new(2.4, 2.2, 2.4), CFrame.new(6.2, 4.6, 3), STEEL_DARK, Enum.Material.Metal)
        for i = 0, 3 do
                BuildingKit.part(model, Vector3.new(0.16, 1.6, 2.5), CFrame.new(7.5, 4.3 + i * 0.45, 3), STEEL, Enum.Material.Metal).CanCollide = false
        end
        local cerobong = BuildingKit.part(model, Vector3.new(1.9, 1, 1), CFrame.new(6.2, 6.6, 3), STEEL, Enum.Material.Metal)
        cerobong.Shape = Enum.PartType.Cylinder
        cerobong.CFrame = CFrame.new(6.2, 6.6, 3) * CFrame.Angles(0, 0, math.rad(90))
        local tutupCerobong = BuildingKit.part(model, Vector3.new(0.3, 1.2, 1.2), CFrame.new(6.2, 7.7, 3), ACCENT_ORANGE, Enum.Material.Metal)
        tutupCerobong.Shape = Enum.PartType.Cylinder
        tutupCerobong.CFrame = CFrame.new(6.2, 7.7, 3) * CFrame.Angles(0, 0, math.rad(90))
        tutupCerobong.CanCollide = false
        local attachment = Instance.new("Attachment")
        attachment.Position = Vector3.new(0, 0.35, 0)
        attachment.Parent = tutupCerobong
        local asap = Instance.new("ParticleEmitter")
        asap.Name = "AsapMesin"
        asap.Color = ColorSequence.new(Color3.fromRGB(176, 178, 184))
        asap.Lifetime = NumberRange.new(0.9, 1.6)
        asap.Speed = NumberRange.new(2.5, 4.5)
        asap.SpreadAngle = Vector2.new(14, 14)
        asap.Size = NumberSequence.new(0.7, 2.2)
        asap.Transparency = NumberSequence.new(0.45, 1)
        asap.Rate = 26
        asap.Enabled = false
        asap.Parent = attachment

        for i, tilt in ipairs({ -1, 1 }) do
                local panel = BuildingKit.part(model, Vector3.new(5.8, 0.35, 3.4), CFrame.new(-2.2, 9.55, 3 + tilt * 1.25) * CFrame.Angles(math.rad(tilt * 42), 0, 0), STEEL_DARK, Enum.Material.Metal)
                panel.CanCollide = false
        end
        for sx = -1, 1, 2 do
                BuildingKit.part(model, Vector3.new(0.35, 2.6, 3.9), CFrame.new(-2.2 + sx * 2.85, 8.9, 3), STEEL_DARK, Enum.Material.Metal)
        end
        for i, sisi in ipairs({ -1, 1 }) do
                local rel = BuildingKit.part(model, Vector3.new(5.9, 0.3, 0.35), CFrame.new(-2.2, 10.35, 3 + sisi * 2.2), ACCENT_ORANGE, Enum.Material.Metal)
                rel.CanCollide = false
        end
        for sx = -1, 1, 2 do
                BuildingKit.part(model, Vector3.new(0.35, 1.6, 0.35), CFrame.new(-2.2 + sx * 2.4, 6.9, 3), STEEL_DARK, Enum.Material.Metal).CanCollide = false
        end
        BuildingKit.part(model, Vector3.new(1.4, 0.25, 1.4), CFrame.new(-2.2, 10.55, 3), ACCENT_ORANGE, Enum.Material.Metal).CanCollide = false

        local pedestal = BuildingKit.part(model, Vector3.new(1.8, 2.8, 1.8), CFrame.new(-8.6, 2.7, 6.6), STEEL_DARK, Enum.Material.Metal)
        local panelTilt = BuildingKit.part(model, Vector3.new(2.2, 0.35, 1.9), CFrame.new(-8.6, 4.25, 6.35) * CFrame.Angles(math.rad(-28), 0, 0), STEEL, Enum.Material.Metal)
        panelTilt.CanCollide = false
        local posLampu = {
                { -9.1, 4.45, 6.2, "MesinLampuMerah" },
                { -8.6, 4.55, 6.2, "MesinLampuKuning" },
                { -8.1, 4.65, 6.2, "MesinLampuHijau" },
        }
        for _, l in ipairs(posLampu) do
                local lampu = BuildingKit.part(model, Vector3.new(0.34, 0.34, 0.34), CFrame.new(l[1], l[2], l[3]), LAMPU_OFF, Enum.Material.Neon)
                lampu.Shape = Enum.PartType.Ball
                lampu.Name = l[4]
                lampu.CanCollide = false
        end
        BuildingKit.part(model, Vector3.new(0.5, 0.22, 0.5), CFrame.new(-8.6, 4.5, 6.75), HIJAU_BTN, Enum.Material.Neon).CanCollide = false
        local layarKecil = BuildingKit.part(model, Vector3.new(1.3, 0.9, 0.2), CFrame.new(-8.6, 3.4, 5.75), Color3.fromRGB(24, 26, 32), Enum.Material.SmoothPlastic)
        layarKecil.CanCollide = false
        local guiKecil = Instance.new("SurfaceGui")
        guiKecil.Face = Enum.NormalId.Front
        guiKecil.CanvasSize = Vector2.new(200, 140)
        local labelKecil = Instance.new("TextLabel")
        labelKecil.Size = UDim2.fromScale(1, 1)
        labelKecil.BackgroundTransparency = 1
        labelKecil.Text = "MESIN SEMAI"
        labelKecil.TextColor3 = Color3.fromRGB(122, 232, 130)
        labelKecil.TextScaled = true
        labelKecil.Font = Enum.Font.GothamBold
        labelKecil.Parent = guiKecil
        guiKecil.Parent = layarKecil

        local kabelJalur = {
                { KABEL_MERAH, 6.35, 3.6 },
                { KABEL_BIRU, 6.65, 3.0 },
                { KABEL_KUNING, 6.95, 2.4 },
        }
        for _, k in ipairs(kabelJalur) do
                local naik = BuildingKit.part(model, Vector3.new(1.3, 0.22, 0.22), CFrame.new(-8.6, k[2], k[3]), k[1], Enum.Material.SmoothPlastic)
                naik.Shape = Enum.PartType.Cylinder
                naik.CFrame = CFrame.new(-8.6, k[2], k[3]) * CFrame.Angles(0, 0, math.rad(90))
                naik.CanCollide = false
                local datar = BuildingKit.part(model, Vector3.new(4.6, 0.22, 0.22), CFrame.new(-6.2, k[2] + 0.6, k[3]), k[1], Enum.Material.SmoothPlastic)
                datar.CanCollide = false
        end

        for sisi, s in ipairs({ { nama = "Kanan", arah = 1 }, { nama = "Kiri", arah = -1 } }) do
                local x = s.arah * 12
                local z = 9.5
                local _alas = BuildingKit.part(model, Vector3.new(2.8, 0.35, 2.8), CFrame.new(x, 1.32, z), STEEL_DARK, Enum.Material.DiamondPlate)
                for i = 0, 2 do
                        BuildingKit.part(model, Vector3.new(0.85, 0.14, 0.62), CFrame.new(x - 0.9 + i * 0.9, 1.22, z + 1.75), (i % 2 == 0) and STRIPE_KUNING or STEEL_DARK, Enum.Material.SmoothPlastic).CanCollide = false
                end
                local tiangTuas = BuildingKit.part(model, Vector3.new(1.6, 2.1, 1.6), CFrame.new(x, 2.55, z), STEEL_DARK, Enum.Material.DiamondPlate)
                tiangTuas.Name = "Tuas" .. s.nama .. "Pedestal"
                for pz = -1, 1, 2 do
                        BuildingKit.part(model, Vector3.new(1.4, 1.5, 0.35), CFrame.new(x, 4.1, z + pz * 0.62), STEEL, Enum.Material.Metal)
                end
                local pin = BuildingKit.part(model, Vector3.new(0.55, 1.7, 1.7), CFrame.new(x, 4.15, z), STEEL, Enum.Material.Metal)
                pin.Shape = Enum.PartType.Cylinder
                pin.CFrame = CFrame.new(x, 4.15, z) * CFrame.Angles(0, math.rad(90), 0)
                pin.CanCollide = false
                local pivot = CFrame.new(x, 4.15, z)
                local naik = (s.arah == 1) and -52 or 52
                local turun = (s.arah == 1) and 40 or -40
                local arm = BuildingKit.part(model, Vector3.new(0.5, 3.4, 0.5), pivot * CFrame.Angles(0, 0, math.rad(naik)) * CFrame.new(0, 1.7, 0), STEEL, Enum.Material.Metal)
                arm.Name = "Tuas" .. s.nama .. "Arm"
                arm:SetAttribute("CFNaik", pivot * CFrame.Angles(0, 0, math.rad(naik)) * CFrame.new(0, 1.7, 0))
                arm:SetAttribute("CFTurun", pivot * CFrame.Angles(0, 0, math.rad(turun)) * CFrame.new(0, 1.7, 0))
                local knob = BuildingKit.part(model, Vector3.new(0.9, 0.9, 0.9), pivot * CFrame.Angles(0, 0, math.rad(naik)) * CFrame.new(0, 3.78, 0), BRICKRED, Enum.Material.Neon)
                knob.Shape = Enum.PartType.Ball
                knob.Name = "Tuas" .. s.nama .. "Knob"
                knob:SetAttribute("CFNaik", pivot * CFrame.Angles(0, 0, math.rad(naik)) * CFrame.new(0, 3.78, 0))
                knob:SetAttribute("CFTurun", pivot * CFrame.Angles(0, 0, math.rad(turun)) * CFrame.new(0, 3.78, 0))
                local lampu = BuildingKit.part(model, Vector3.new(0.42, 0.42, 0.42), CFrame.new(x, 3.35, z + 0.95), LAMPU_OFF, Enum.Material.Neon)
                lampu.Shape = Enum.PartType.Ball
                lampu.Name = "Tuas" .. s.nama .. "Lampu"
                lampu.CanCollide = false
                local label = Instance.new("SurfaceGui")
                label.Face = Enum.NormalId.Front
                label.CanvasSize = Vector2.new(160, 90)
                local teksLabel = Instance.new("TextLabel")
                teksLabel.Size = UDim2.fromScale(1, 1)
                teksLabel.BackgroundTransparency = 1
                teksLabel.Text = "TUAS " .. string.upper(s.nama)
                teksLabel.TextColor3 = Color3.fromRGB(255, 232, 180)
                teksLabel.TextScaled = true
                teksLabel.Font = Enum.Font.GothamBold
                teksLabel.Parent = label
                label.Parent = tiangTuas
                BuildingKit.part(model, Vector3.new(7.9, 0.45, 0.45), CFrame.new(s.arah * 7.25, 2, z), STEEL_DARK, Enum.Material.Metal)
                for _, px in ipairs({ 5.4, 9 }) do
                        BuildingKit.part(model, Vector3.new(0.35, 1.3, 0.35), CFrame.new(s.arah * px, 1.9, z), STEEL, Enum.Material.Metal)
                end
                local suaraTuas = Instance.new("Sound")
                suaraTuas.Name = "SuaraTuas" .. s.nama
                suaraTuas.SoundId = "rbxasset://sounds/electronicpingshort.wav"
                suaraTuas.Volume = 0.65
                suaraTuas.PlaybackSpeed = 0.5
                suaraTuas.RollOffMaxDistance = 90
                suaraTuas.Parent = tiangTuas
                local promptTuas = Instance.new("ProximityPrompt")
                promptTuas.Name = "PromptTuas" .. s.nama
                promptTuas.ActionText = "Tekan Tuas"
                promptTuas.ObjectText = "Tuas " .. s.nama
                promptTuas.HoldDuration = 0.2
                promptTuas.MaxActivationDistance = 9
                promptTuas.RequiresLineOfSight = false
                promptTuas.Enabled = false
                promptTuas.Parent = tiangTuas
                promptTuas.Triggered:Connect(function(player: Player)
                        if hooks and hooks.onTuasPrompt then
                                hooks.onTuasPrompt(player, index, string.lower(s.nama))
                        end
                end)
        end

        local corong = BuildingKit.part(model, Vector3.new(2.8, 0.35, 2.2), CFrame.new(-4.6, 6.9, 3) * CFrame.Angles(0, 0, math.rad(32)), STEEL_DARK, Enum.Material.Metal)
        corong.CanCollide = false
        BuildingKit.part(model, Vector3.new(0.35, 2.4, 2), CFrame.new(-5.75, 5.7, 3), STEEL_DARK, Enum.Material.Metal).CanCollide = false
        local _bak = BuildingKit.part(model, Vector3.new(2.8, 2.4, 2.8), CFrame.new(-7.4, 2.75, 3), Color3.fromRGB(150, 116, 74), Enum.Material.WoodPlanks)
        BuildingKit.part(model, Vector3.new(2.9, 0.25, 2.9), CFrame.new(-7.4, 4.05, 3), FLOORWOOD, Enum.Material.WoodPlanks).CanCollide = false
        for i = 0, 2 do
                local buah = BuildingKit.part(model, Vector3.new(0.8, 0.8, 0.8), CFrame.new(-7.9 + i * 0.55, 4.5, 3.1 + (i % 2) * 0.3), (i == 1) and STEEL_BLUE or ACCENT_ORANGE, Enum.Material.SmoothPlastic)
                buah.Shape = Enum.PartType.Ball
                buah.CanCollide = false
        end

        for sx = -1, 1, 2 do
                BuildingKit.part(model, Vector3.new(0.4, 6, 0.4), CFrame.new(sx * 3.4, 5, -4.6), STEEL_DARK, Enum.Material.Metal)
        end
        local papan = BuildingKit.part(model, Vector3.new(8.6, 3.4, 0.5), CFrame.new(0, 8.6, -4.6), DARKWOOD, Enum.Material.Wood)
        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Front
        gui.CanvasSize = Vector2.new(520, 200)
        local judul = Instance.new("TextLabel")
        judul.Size = UDim2.new(1, -12, 0.42, 0)
        judul.Position = UDim2.new(0, 6, 0.04, 0)
        judul.BackgroundTransparency = 1
        judul.Text = "MESIN SEMAI PANEN"
        judul.TextColor3 = Color3.fromRGB(255, 232, 180)
        judul.TextScaled = true
        judul.Font = Enum.Font.GothamBlack
        judul.Parent = gui
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Name = "StatusMesin"
        statusLabel.Size = UDim2.new(1, -12, 0.44, 0)
        statusLabel.Position = UDim2.new(0, 6, 0.5, 0)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = "NONAKTIF"
        statusLabel.TextColor3 = Color3.fromRGB(208, 210, 216)
        statusLabel.TextScaled = true
        statusLabel.Font = Enum.Font.GothamBold
        statusLabel.Parent = gui
        local guiBack = gui:Clone()
        guiBack.Face = Enum.NormalId.Back
        gui.Parent = papan
        guiBack.Parent = papan

        local tong = BuildingKit.part(model, Vector3.new(2.4, 2, 2), CFrame.new(12.5, 2.2, -7), STEEL_BLUE, Enum.Material.Metal)
        tong.Shape = Enum.PartType.Cylinder
        tong.CFrame = CFrame.new(12.5, 2.2, -7) * CFrame.Angles(0, 0, math.rad(90))
        local tongBand = BuildingKit.part(model, Vector3.new(0.3, 2.05, 2.05), CFrame.new(12.5, 2.2, -7), STEEL, Enum.Material.Metal)
        tongBand.Shape = Enum.PartType.Cylinder
        tongBand.CFrame = CFrame.new(12.5, 2.2, -7) * CFrame.Angles(0, 0, math.rad(90))
        tongBand.CanCollide = false
        local tong2 = BuildingKit.part(model, Vector3.new(2.4, 2, 2), CFrame.new(12.5, 2.2, -4), ACCENT_ORANGE, Enum.Material.Metal)
        tong2.Shape = Enum.PartType.Cylinder
        tong2.CFrame = CFrame.new(12.5, 2.2, -4) * CFrame.Angles(0, 0, math.rad(90))
        for i = 0, 2 do
                BuildingKit.part(model, Vector3.new(2.2, 2.2, 2.2), CFrame.new(9 + i * 2.4, 2.3, -8.6), Color3.fromRGB(150, 116, 74), Enum.Material.WoodPlanks)
        end
        local _kotakAlat = BuildingKit.part(model, Vector3.new(1.6, 0.9, 1), CFrame.new(-12, 1.65, 7.5), BRICKRED, Enum.Material.Metal)
        BuildingKit.part(model, Vector3.new(0.9, 0.16, 0.3), CFrame.new(-12, 2.25, 7.5), STEEL, Enum.Material.Metal).CanCollide = false
        for i = 0, 1 do
                local karung = BuildingKit.part(model, Vector3.new(1.6, 1.9, 1), CFrame.new(-12.6 + i * 1.8, 2.15, -8.2), (i == 0) and Color3.fromRGB(150, 108, 62) or Color3.fromRGB(96, 128, 72), Enum.Material.Fabric)
                karung.CanCollide = false
        end
        BuildingKit.part(model, Vector3.new(1.6, 1.9, 1), CFrame.new(-11.7, 3.9, -8.2), Color3.fromRGB(196, 168, 120), Enum.Material.Fabric).CanCollide = false
        local pipa = BuildingKit.part(model, Vector3.new(22, 0.7, 0.7), CFrame.new(0, 2.6, 13.6), STEEL_DARK, Enum.Material.Metal)
        pipa.CanCollide = false
        for i = 0, 3 do
                BuildingKit.part(model, Vector3.new(0.35, 1.6, 0.35), CFrame.new(-8 + i * 5.4, 1.9, 13.6), STEEL, Enum.Material.Metal).CanCollide = false
        end

        local suaraGiling = Instance.new("Sound")
        suaraGiling.Name = "SuaraGiling"
        suaraGiling.SoundId = "rbxasset://sounds/swoosh.wav"
        suaraGiling.Looped = true
        suaraGiling.Volume = 0.55
        suaraGiling.PlaybackSpeed = 0.55
        suaraGiling.RollOffMaxDistance = 90
        suaraGiling.Parent = drum
        local suaraDing = Instance.new("Sound")
        suaraDing.Name = "SuaraDing"
        suaraDing.SoundId = "rbxasset://sounds/electronicpingshort.wav"
        suaraDing.Volume = 0.6
        suaraDing.PlaybackSpeed = 0.72
        suaraDing.RollOffMaxDistance = 90
        suaraDing.Parent = pedestal
        local suaraStart = Instance.new("Sound")
        suaraStart.Name = "SuaraStart"
        suaraStart.SoundId = "rbxasset://sounds/swoosh.wav"
        suaraStart.Volume = 0.5
        suaraStart.PlaybackSpeed = 1.25
        suaraStart.RollOffMaxDistance = 90
        suaraStart.Parent = pedestal

        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Semai Panen"
        prompt.ObjectText = "Mesin Semai"
        prompt.HoldDuration = 0.3
        prompt.MaxActivationDistance = 12
        prompt.RequiresLineOfSight = false
        prompt.Parent = pedestal
        prompt.Triggered:Connect(function(player: Player)
                if hooks and hooks.onSemaiPrompt then
                        hooks.onSemaiPrompt(player, index)
                end
        end)

        model.Parent = parent
        model.WorldPivot = CFrame.new(0, 0, 0)
        return model
end

return BuildingKit
