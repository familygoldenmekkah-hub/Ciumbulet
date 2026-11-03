--!nonstrict
--[[
        ShopService.luau
        Handles the Purchase RemoteFunction: upgrades, pets, rebirth.
        Every purchase is validated server-side against Config prices.
        Client can never dictate a price.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Remotes)
local DataService = require(script.Parent.DataService)
local EconomyService = require(script.Parent.EconomyService)
local PetService = require(script.Parent.PetService)

local ShopService = {}

local purchaseRemote = Remotes.get("Purchase")
local notifyRemote = Remotes.get("Notify")

local function upgradeById(id: string)
        for _, u in Config.Upgrades do
                if u.id == id then
                        return u
                end
        end
        return nil
end

local function petById(id: string)
        for _, p in Config.Pets do
                if p.id == id then
                        return p
                end
        end
        return nil
end

--------------------------------------------------------------------
-- HANDLERS
--------------------------------------------------------------------

local function buyUpgrade(player: Player, upgradeId: string): (boolean, string)
        local def = upgradeById(upgradeId)
        if not def then
                return false, "Unknown upgrade."
        end
        local data = DataService.get(player)
        local level = data.Upgrades[def.id] or 0
        local cost = EconomyService.upgradeCost(def, level)
        if not cost then
                return false, def.name .. " is already maxed!"
        end
        if not EconomyService.spendCoins(player, cost) then
                return false, "Not enough coins! Need " .. string.format("%d", cost) .. "."
        end
        data.Upgrades[def.id] = level + 1
        DataService.markDirty(player)
        return true, def.name .. " -> Lv " .. (level + 1) .. "!"
end

local function buyPet(player: Player, petId: string): (boolean, string)
        local def = petById(petId)
        if not def then
                return false, "Unknown pet."
        end
        local data = DataService.get(player)
        if table.find(data.Pets, def.id) then
                return false, "You already own " .. def.name .. "."
        end
        if not EconomyService.spendCoins(player, def.price) then
                return false, "Not enough coins! " .. def.name .. " costs " .. def.price .. "."
        end
        table.insert(data.Pets, def.id)
        DataService.markDirty(player)
        return true, def.name .. " hatched! Equip it in the Pets tab."
end

local function equipPet(player: Player, petId: string, equip: boolean): (boolean, string)
        local def = petById(petId)
        if not def then
                return false, "Unknown pet."
        end
        local data = DataService.get(player)
        if equip then
                if not table.find(data.Pets, def.id) then
                        return false, "You don't own " .. def.name .. "."
                end
                if table.find(data.Equipped, def.id) then
                        return true, def.name .. " is already equipped."
                end
                local cap = data.Gamepasses.VIP and Config.VipEquipCap or Config.PetEquipCap
                if #data.Equipped >= cap then
                        return false, "Pet slots full (" .. cap .. "). Unequip one first."
                end
                table.insert(data.Equipped, def.id)
                DataService.markDirty(player)
                return true, def.name .. " equipped! +" .. def.income .. "/s"
        else
                local idx = table.find(data.Equipped, def.id)
                if not idx then
                        return true, def.name .. " is not equipped."
                end
                table.remove(data.Equipped, idx)
                DataService.markDirty(player)
                return true, def.name .. " unequipped."
        end
end

local function doRebirth(player: Player): (boolean, string)
        local data = DataService.get(player)
        local cost = EconomyService.rebirthCost(data)
        if data.Coins < cost then
                return false, "Rebirth needs " .. cost .. " coins!"
        end
        data.Coins = 0
        for _, u in Config.Upgrades do
                data.Upgrades[u.id] = 0
        end
        data.Rebirths += 1
        DataService.markDirty(player)
        EconomyService.requestSync(player)
        return true, "REBIRTH #" .. data.Rebirths .. "! Permanent x" .. (1 + data.Rebirths * Config.Rebirth.BonusPer) .. " coins!"
end

--------------------------------------------------------------------
-- WIRING
--------------------------------------------------------------------

function ShopService.init()
        PetService.init()

        purchaseRemote.OnServerInvoke = function(player, kind: string, arg: any)
                -- reject everything until the player's data finished loading
                if not DataService.has(player) then
                        notifyRemote:FireClient(player, "Shop", "Still loading - try again in a second.")
                        return false, "Data not loaded yet."
                end
                local ok, msg = false, "Invalid request."
                if kind == "upgrade" and type(arg) == "string" then
                        ok, msg = buyUpgrade(player, arg)
                elseif kind == "pet_buy" and type(arg) == "string" then
                        ok, msg = buyPet(player, arg)
                elseif kind == "pet_equip" and type(arg) == "string" then
                        ok, msg = equipPet(player, arg, true)
                elseif kind == "pet_unequip" and type(arg) == "string" then
                        ok, msg = equipPet(player, arg, false)
                elseif kind == "rebirth" then
                        ok, msg = doRebirth(player)
                end
                if ok then
                        EconomyService.requestSync(player)
                end
                notifyRemote:FireClient(player, ok and "Success" or "Shop", msg)
                return ok, msg
        end
end

return ShopService
