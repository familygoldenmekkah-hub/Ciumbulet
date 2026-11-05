local DoorKit = {}

DoorKit.CHAR_HEIGHT = 5
DoorKit.DOOR_HEIGHT = DoorKit.CHAR_HEIGHT * 2
DoorKit.DOOR_WIDTH = 4.6
DoorKit.DOOR_THICK = 0.5

function DoorKit.part(props, parent): Part
        local p = Instance.new("Part")
        p.Anchored = true
        p.TopSurface = Enum.SurfaceType.Smooth
        p.BottomSurface = Enum.SurfaceType.Smooth
        for k, v in props do
                (p :: any)[k] = v
        end
        p.Parent = parent
        return p
end

function DoorKit.frame(center: Vector3, yawDeg: number, parent, width: number?, height: number?)
        local w = width or DoorKit.DOOR_WIDTH
        local h = height or DoorKit.CHAR_HEIGHT * 4
        local base = CFrame.new(center) * CFrame.Angles(0, math.rad(yawDeg), 0)
        local frameC = Color3.fromRGB(96, 72, 46)
        DoorKit.part({
                Name = "BingkaiKiri",
                Size = Vector3.new(0.7, h, 1.1),
                CFrame = base * CFrame.new(-w / 2 - 0.35, h / 2, 0),
                Color = frameC,
                Material = Enum.Material.Wood,
        }, parent)
        DoorKit.part({
                Name = "BingkaiKanan",
                Size = Vector3.new(0.7, h, 1.1),
                CFrame = base * CFrame.new(w / 2 + 0.35, h / 2, 0),
                Color = frameC,
                Material = Enum.Material.Wood,
        }, parent)
        DoorKit.part({
                Name = "BingkaiAtas",
                Size = Vector3.new(w + 1.4, 0.7, 1.1),
                CFrame = base * CFrame.new(0, h + 0.35, 0),
                Color = frameC,
                Material = Enum.Material.Wood,
        }, parent)
end

function DoorKit.hinged(center: Vector3, yawDeg: number, parent, width: number?, height: number?, color: Color3?)
        local w = width or DoorKit.DOOR_WIDTH
        local h = height or DoorKit.DOOR_HEIGHT
        local base = CFrame.new(center) * CFrame.Angles(0, math.rad(yawDeg), 0)
        local hinge = base * CFrame.new(-w / 2, h / 2, 0)
        local woodColor = color or Color3.fromRGB(146, 104, 62)

        local panel = DoorKit.part({
                Name = "Pintu",
                Size = Vector3.new(w, h, DoorKit.DOOR_THICK),
                Color = woodColor,
                Material = Enum.Material.WoodPlanks,
        }, parent)

        local trim1 = DoorKit.part({
                Name = "PintuRapih1",
                Size = Vector3.new(w - 0.9, h / 3.4, 0.16),
                Color = woodColor:Lerp(Color3.new(0, 0, 0), 0.14),
                Material = Enum.Material.Wood,
                CanCollide = false,
                Massless = true,
        }, parent)
        local trim2 = DoorKit.part({
                Name = "PintuRapih2",
                Size = Vector3.new(w - 0.9, h / 3.4, 0.16),
                Color = woodColor:Lerp(Color3.new(0, 0, 0), 0.14),
                Material = Enum.Material.Wood,
                CanCollide = false,
                Massless = true,
        }, parent)
        local knob = DoorKit.part({
                Name = "PintuGagang",
                Shape = Enum.PartType.Ball,
                Size = Vector3.new(0.5, 0.5, 0.5),
                Color = Color3.fromRGB(240, 204, 108),
                Material = Enum.Material.Metal,
                CanCollide = false,
                Massless = true,
        }, parent)

        local OPEN_DEG = 104
        local function layout(deg: number)
                local doorCF = hinge * CFrame.Angles(0, math.rad(deg), 0) * CFrame.new(w / 2, 0, 0)
                panel.CFrame = doorCF
                trim1.CFrame = doorCF * CFrame.new(0, h / 4.4, DoorKit.DOOR_THICK / 2 + 0.09)
                trim2.CFrame = doorCF * CFrame.new(0, -h / 4.4, DoorKit.DOOR_THICK / 2 + 0.09)
                knob.CFrame = doorCF * CFrame.new(w - 0.7, 0, DoorKit.DOOR_THICK / 2 + 0.16)
        end
        layout(0)

        local open = false
        local busy = false
        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Buka"
        prompt.ObjectText = "Pintu"
        prompt.MaxActivationDistance = 7
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.Parent = panel
        prompt.Triggered:Connect(function()
                if busy then
                        return
                end
                busy = true
                open = not open
                prompt.ActionText = open and "Tutup" or "Buka"
                local startCF = panel.CFrame
                local startTrim1, startTrim2, startKnob = trim1.CFrame, trim2.CFrame, knob.CFrame
                local targetCF = hinge * CFrame.Angles(0, math.rad(OPEN_DEG), 0) * CFrame.new(w / 2, 0, 0)
                local targetTrim1 = targetCF * CFrame.new(0, h / 4.4, DoorKit.DOOR_THICK / 2 + 0.09)
                local targetTrim2 = targetCF * CFrame.new(0, -h / 4.4, DoorKit.DOOR_THICK / 2 + 0.09)
                local targetKnob = targetCF * CFrame.new(w - 0.7, 0, DoorKit.DOOR_THICK / 2 + 0.16)
                task.spawn(function()
                        local steps = 9
                        for step = 1, steps do
                                local alpha = step / steps
                                panel.CFrame = startCF:Lerp(targetCF, alpha)
                                trim1.CFrame = startTrim1:Lerp(targetTrim1, alpha)
                                trim2.CFrame = startTrim2:Lerp(targetTrim2, alpha)
                                knob.CFrame = startKnob:Lerp(targetKnob, alpha)
                                task.wait(0.03)
                        end
                        panel.CFrame = targetCF
                        trim1.CFrame = targetTrim1
                        trim2.CFrame = targetTrim2
                        knob.CFrame = targetKnob
                        busy = false
                end)
        end)
        return panel
end

return DoorKit
