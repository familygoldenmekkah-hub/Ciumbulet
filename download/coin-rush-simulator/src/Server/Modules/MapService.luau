--!nonstrict
--[[
        MapService.luau
        Builds the entire map procedurally at server boot - zero uploaded assets:
          - floating grass island
          - giant clickable coin (idle spin + ClickDetector)
          - spawn arch signage, decorative trees & crystals
        SpawnLocation comes from default.project.json.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local EconomyService = require(script.Parent.EconomyService)

local MapService = {}

local folder = Instance.new("Folder")
folder.Name = "Map"

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

local function buildIsland()
        local radius = Config.World.IslandRadius
        local island = part({
                Name = "Island",
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(4, radius * 2, radius * 2),
                CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, math.rad(90)),
                Color = Color3.fromRGB(90, 160, 70),
                Material = Enum.Material.Grass,
        })
        _ = island
        -- underside rock wedge for depth
        part({
                Name = "IslandBase",
                Size = Vector3.new(radius * 1.2, radius * 0.9, radius * 1.2),
                CFrame = CFrame.new(0, -radius * 0.45, 0) * CFrame.Angles(math.rad(45), 0, math.rad(45)),
                Color = Color3.fromRGB(90, 85, 80),
                Material = Enum.Material.Slate,
        })
end

local function buildCoin()
        local pos = Config.World.CoinPosition
        local d = Config.World.CoinSize
        local coin = part({
                Name = "GiantCoin",
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(1.6, d, d),
                CFrame = CFrame.new(pos[1], pos[2], pos[3]) * CFrame.Angles(0, math.rad(90), 0),
                Color = Color3.fromRGB(255, 196, 37),
                Material = Enum.Material.Neon,
        })

        -- idle spin (server-side tween, cheap: single anchored part)
        local spin = TweenService:Create(
                coin,
                TweenInfo.new(8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
                { CFrame = coin.CFrame * CFrame.Angles(0, math.rad(360), 0) }
        )
        spin:Play()

        -- click detection: players can click the coin directly
        local click = Instance.new("ClickDetector")
        click.MaxActivationDistance = 40
        click.Parent = coin
        click.MouseClick:Connect(function(player)
                EconomyService.registerClick(player)
        end)

        -- pedestal
        part({
                Name = "CoinPedestal",
                Size = Vector3.new(10, 2, 10),
                CFrame = CFrame.new(pos[1], 3, pos[3]),
                Color = Color3.fromRGB(60, 64, 80),
                Material = Enum.Material.SmoothPlastic,
        })
end

local function buildSignage()
        -- arch over spawn: two pillars + beam with game title
        local pillarMat = { Color = Color3.fromRGB(60, 64, 80), Material = Enum.Material.SmoothPlastic }
        part({
                Name = "SignPillarL",
                Size = Vector3.new(2, 16, 2),
                CFrame = CFrame.new(-8, 10, 40),
                Color = pillarMat.Color,
                Material = pillarMat.Material,
        })
        part({
                Name = "SignPillarR",
                Size = Vector3.new(2, 16, 2),
                CFrame = CFrame.new(8, 10, 40),
                Color = pillarMat.Color,
                Material = pillarMat.Material,
        })
        local beam = part({
                Name = "SignBeam",
                Size = Vector3.new(20, 3.5, 1.5),
                CFrame = CFrame.new(0, 18, 40),
                Color = Color3.fromRGB(25, 28, 38),
                Material = Enum.Material.SmoothPlastic,
        })
        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Front
        gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        gui.PixelsPerStud = 50
        gui.Parent = beam
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBlack
        label.TextScaled = true
        label.TextColor3 = Color3.fromRGB(255, 196, 37)
        label.Text = "COIN RUSH SIMULATOR"
        label.Parent = gui
end

local function buildTrees()
        local rng = Random.new(42)
        for i = 1, 8 do
                local angle = (i / 8) * math.pi * 2 + rng:NextNumber(-0.15, 0.15)
                local dist = 62 + rng:NextNumber(-6, 6)
                local x = math.cos(angle) * dist
                local z = math.sin(angle) * dist
                part({
                        Name = "TreeTrunk" .. i,
                        Size = Vector3.new(2, 9, 2),
                        CFrame = CFrame.new(x, 6.5, z),
                        Color = Color3.fromRGB(120, 82, 45),
                        Material = Enum.Material.Wood,
                })
                part({
                        Name = "TreeTop" .. i,
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(11, 11, 11),
                        CFrame = CFrame.new(x, 13, z),
                        Color = Color3.fromRGB(60, 140, 60),
                        Material = Enum.Material.Grass,
                })
        end
end

local function buildCrystals()
        local rng = Random.new(7)
        for i = 1, 6 do
                local angle = rng:NextNumber(0, math.pi * 2)
                local dist = rng:NextNumber(24, 46)
                part({
                        Name = "Crystal" .. i,
                        Size = Vector3.new(2.5, rng:NextNumber(4, 7), 2.5),
                        CFrame = CFrame.new(math.cos(angle) * dist, 4, math.sin(angle) * dist)
                                * CFrame.Angles(0, rng:NextNumber(0, math.pi), math.rad(18)),
                        Color = Color3.fromRGB(140, 110, 255),
                        Material = Enum.Material.Neon,
                        Transparency = 0.15,
                })
        end
end

function MapService.init()
        folder.Parent = workspace
        buildIsland()
        buildCoin()
        buildSignage()
        buildTrees()
        buildCrystals()
end

return MapService
