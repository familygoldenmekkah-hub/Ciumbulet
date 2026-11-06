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
        BuildingKit.part(model, Vector3.new(8, 8, 2), CFrame.new(-10, 6, 13), DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(model, Vector3.new(8, 8, 2), CFrame.new(10, 6, 13), DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(model, Vector3.new(2, 8, 8), CFrame.new(-18, 6, 4), DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(model, Vector3.new(2, 8, 8), CFrame.new(18, 6, 4), DARKWOOD, Enum.Material.Wood)
        BuildingKit.part(model, Vector3.new(6, 4, 3), CFrame.new(0, 4, 2), DARKWOOD, Enum.Material.Wood)
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
        BuildingKit.lamp(model, -6, 21, 0)
        BuildingKit.lamp(model, 6, 21, 0)
        model.Parent = parent
        model.WorldPivot = CFrame.new(0, 0, 0)
        return model
end

return BuildingKit
