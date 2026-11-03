--!nonstrict
--[[
        PetVisuals.luau
        Purely cosmetic client-side pets: floating models that orbit the player.
        Created from Config (color/shape/size) - no uploaded assets.
        The server computes income; this is decoration only.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Remotes)

local PetVisuals = {}
PetVisuals.__index = PetVisuals

local player = Players.LocalPlayer

local function petDef(id: string)
        for _, def in Config.Pets do
                if def.id == id then
                        return def
                end
        end
        return nil
end

local function buildModel(def)
        local color = Color3.fromRGB(def.color[1], def.color[2], def.color[3])
        local size = def.size

        local model = Instance.new("Model")
        model.Name = "PetLocal_" .. def.id

        local body = Instance.new("Part")
        body.Name = "Body"
        body.Shape = def.shape == "Ball" and Enum.PartType.Ball or Enum.PartType.Block
        body.Size = Vector3.new(size, size, size)
        body.Color = color
        body.Material = Enum.Material.Neon
        body.Anchored = true
        body.CanCollide = false
        body.CanQuery = false
        body.CanTouch = false
        body.CastShadow = false
        body.Parent = model
        model.PrimaryPart = body

        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 90, 0, 24)
        billboard.StudsOffset = Vector3.new(0, size + 0.6, 0)
        billboard.AlwaysOnTop = true
        billboard.MaxDistance = 80
        billboard.Parent = body

        local name = Instance.new("TextLabel")
        name.Size = UDim2.fromScale(1, 1)
        name.BackgroundTransparency = 1
        name.Font = Enum.Font.GothamBold
        name.TextScaled = true
        name.TextColor3 = color
        name.TextStrokeTransparency = 0.4
        name.Text = def.name
        name.Parent = billboard

        return model
end

function PetVisuals.new()
        local self = setmetatable({}, PetVisuals)
        self.equipped = {}
        self.models = {}
        self.folder = Instance.new("Folder")
        self.folder.Name = "PetVisuals_" .. player.Name

        Remotes.get("StateSync").OnClientEvent:Connect(function(state)
                self:setEquipped(state.Equipped)
        end)

        RunService.RenderStepped:Connect(function(dt)
                self:step(dt)
        end)

        return self
end

function PetVisuals:setEquipped(list: { string })
        if type(list) ~= "table" then
                return
        end
        self.equipped = list
        -- create missing models
        for _, id in list do
                if not self.models[id] then
                        local def = petDef(id)
                        if def then
                                local model = buildModel(def)
                                model.Parent = self.folder
                                self.models[id] = model
                        end
                end
        end
        -- remove models no longer equipped
        for id, model in self.models do
                if not table.find(list, id) then
                        model:Destroy()
                        self.models[id] = nil
                end
        end
end

function PetVisuals:step(dt: number)
        local character = player.Character
        local head = character and character:FindFirstChild("Head")
        if not head then
                self.folder.Parent = nil
                return
        end
        if self.folder.Parent ~= workspace then
                self.folder.Parent = workspace
        end

        local count = #self.equipped
        if count == 0 then
                return
        end

        local now = time()
        for i, id in self.equipped do
                local model = self.models[id]
                local root = model and model.PrimaryPart
                if root then
                        local angle = now * 1.6 + (i / count) * math.pi * 2
                        local bob = math.sin(now * 2.2 + i) * 0.35
                        local offset = Vector3.new(math.cos(angle) * 4.5, 2.4 + bob, math.sin(angle) * 4.5)
                        local target = head.Position + offset
                        local alpha = 1 - math.exp(-dt * 8)
                        root.CFrame = root.CFrame:Lerp(CFrame.new(target) * CFrame.Angles(0, angle, 0), alpha)
                end
        end
end

return PetVisuals
