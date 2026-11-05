--!nonstrict
--[[
        PetService.luau - peliharaan mengikuti pemain & memberi bonus harga jual.
        Model pet dibuat lewat kode (bola menggembung + nama), digerakkan server
        lewat Heartbeat agar semua pemain melihatnya.
]]

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local DataService = require(script.Parent.DataService)

local PetService = {}

local active: { [Player]: { model: Part, petId: string } } = {}
local folder: Folder? = nil

local function petFolder(): Folder
        local f = folder
        if not f then
                f = Instance.new("Folder")
                f.Name = "AKM_Pets"
                f.Parent = workspace
                folder = f
        end
        return f :: Folder
end

local petById: { [string]: any } = {}
for _, pet in ipairs(Config.Pets) do
        petById[pet.id] = pet
end

function PetService.sellBonus(player: Player): number
        local data = DataService.get(player)
        local pet = petById[data.ActivePet]
        return pet and pet.bonus or 0
end

function PetService.attach(player: Player)
        PetService.cleanup(player)
        if not DataService.has(player) then
                return
        end
        local data = DataService.get(player)
        local def = petById[data.ActivePet]
        if not def then
                return
        end

        local body = Instance.new("Part")
        body.Name = "Pet_" .. player.UserId
        body.Shape = Enum.PartType.Ball
        body.Size = Vector3.new(2, 2, 2)
        body.Color = Color3.fromRGB(def.color[1], def.color[2], def.color[3])
        body.Material = data.Dev and Enum.Material.Neon or Enum.Material.SmoothPlastic
        body.Anchored = true
        body.CanCollide = false
        body.CanQuery = false

        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 120, 0, 26)
        billboard.StudsOffset = Vector3.new(0, 1.6, 0)
        billboard.AlwaysOnTop = true
        billboard.MaxDistance = 50
        billboard.Parent = body
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextScaled = true
        label.TextColor3 = body.Color
        label.TextStrokeTransparency = 0.5
        label.Text = def.name
        label.Parent = billboard

        body.Parent = petFolder()
        active[player] = { model = body, petId = def.id }
end

function PetService.cleanup(player: Player)
        local entry = active[player]
        if entry and entry.model then
                entry.model:Destroy()
        end
        active[player] = nil
end

function PetService.init()
        local Remotes = require(ReplicatedStorage.Remotes)
        Remotes.get("EquipPet").OnServerInvoke = function(player, petId)
                return PetService.equip(player, petId)
        end

        local t = 0
        RunService.Heartbeat:Connect(function(dt)
                t += dt
                for player, entry in active do
                        local character = player.Character
                        local root = character and character:FindFirstChild("HumanoidRootPart")
                        if root then
                                local bob = math.sin(t * 2.2 + player.UserId % 7) * 0.4
                                local target = (root :: BasePart).CFrame
                                        * CFrame.new(2.4, 2.6 + bob, 2.4)
                                entry.model.CFrame = entry.model.CFrame:Lerp(target, math.clamp(dt * 6, 0, 1))
                        end
                end
        end)

        local Players = game:GetService("Players")
        Players.PlayerRemoving:Connect(function(player)
                PetService.cleanup(player)
        end)
end

function PetService.equip(player: Player, petId: any)
        if not DataService.has(player) then
                return { ok = false, msg = "Data belum siap." }
        end
        if type(petId) ~= "string" or petId ~= "" and not petById[petId] then
                return { ok = false, msg = "Peliharaan tidak dikenal." }
        end
        local data = DataService.get(player)
        if petId ~= "" and not data.Pets[petId] then
                return { ok = false, msg = "Kamu belum punya peliharaan itu." }
        end
        data.ActivePet = petId
        DataService.markDirty(player)
        PetService.attach(player)
        DataService.push(player)
        if petId == "" then
                return { ok = true, msg = "Peliharaan diistirahatkan." }
        end
        return { ok = true, msg = petById[petId].name .. " menemanimu!" }
end

return PetService
