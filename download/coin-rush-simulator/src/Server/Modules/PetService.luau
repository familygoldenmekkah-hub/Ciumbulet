--!nonstrict
--[[
        PetService.luau
        Pet ownership & equipped slots are stored in player data (DataService).
        Pet INCOME is computed server-side in EconomyService - exploit-proof.
        Pet MODELS are purely cosmetic and rendered client-side (PetVisuals.luau),
        so there is zero replication traffic for pet movement.

        This service keeps equipped slots consistent with ownership and caps
        (e.g. a player who lost VIP gets trimmed back to the normal cap).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local PetService = {}

--- Rebuilds data.Equipped in place: owned-only, no duplicates, within cap.
function PetService.validateEquipped(player: Player): { string }
        local DataService = require(script.Parent.DataService)
        local data = DataService.get(player)
        local cap = data.Gamepasses.VIP and Config.VipEquipCap or Config.PetEquipCap

        local valid: { string } = {}
        for _, petId in data.Equipped do
                if #valid >= cap then
                        break
                end
                if table.find(data.Pets, petId) and not table.find(valid, petId) then
                        table.insert(valid, petId)
                end
        end
        data.Equipped = valid
        DataService.markDirty(player)
        return valid
end

function PetService.init()
        Players.PlayerAdded:Connect(function(player)
                PetService.validateEquipped(player)
        end)
        -- Also run once for anyone already present (robust against init order)
        for _, player in Players:GetPlayers() do
                PetService.validateEquipped(player)
        end
end

return PetService
