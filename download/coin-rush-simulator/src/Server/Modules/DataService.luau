--!nonstrict
--[[
        DataService.luau
        Loads/saves per-player data with retries, autosave and graceful shutdown.
        Also validates loaded data against the template so old/corrupt saves
        never crash the server.
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)

local DataService = {}

local store = DataStoreService:GetDataStore(Config.Data.StoreName)

-- Sessions[player] = { data = table, dirty = boolean }
local sessions: { [Player]: { data: { [string]: any }, dirty: boolean } } = {}

local DEFAULT_DATA = {
        Coins = 0,
        TotalEarned = 0,
        Rebirths = 0,
        Upgrades = { MultiClick = 0, CoinBoost = 0, AutoClick = 0 },
        Pets = {}, -- owned pet ids
        Equipped = {}, -- equipped pet ids (max = equip cap)
        Gamepasses = { DoubleCoins = false, VIP = false, TurboHands = false },
        LastSeen = 0,
}

local function sanitize(data: any): { [string]: any }
        local out = Util.deepCopy(DEFAULT_DATA)
        if type(data) ~= "table" then
                return out
        end
        out.Coins = tonumber(data.Coins) or 0
        out.TotalEarned = tonumber(data.TotalEarned) or 0
        out.Rebirths = tonumber(data.Rebirths) or 0
        if type(data.Upgrades) == "table" then
                for _, upg in Config.Upgrades do
                        out.Upgrades[upg.id] = math.min(tonumber(data.Upgrades[upg.id]) or 0, upg.max)
                end
        end
        if type(data.Pets) == "table" then
                for _, pet in Config.Pets do
                        if table.find(data.Pets, pet.id) then
                                table.insert(out.Pets, pet.id)
                        end
                end
        end
        if type(data.Equipped) == "table" then
                for _, id in data.Equipped do
                        local owned = table.find(out.Pets, id)
                        if owned and #out.Equipped < Config.VipEquipCap then
                                table.insert(out.Equipped, id)
                        end
                end
        end
        if type(data.Gamepasses) == "table" then
                for key in out.Gamepasses do
                        out.Gamepasses[key] = data.Gamepasses[key] == true
                end
        end
        out.LastSeen = tonumber(data.LastSeen) or 0
        return out
end

function DataService.get(player: Player): { [string]: any }
        local session = sessions[player]
        return session and session.data or DEFAULT_DATA
end

--- True if the player has a real (loaded) session.
function DataService.has(player: Player): boolean
        return sessions[player] ~= nil
end

function DataService.markDirty(player: Player)
        local session = sessions[player]
        if session then
                session.dirty = true
        end
end

--- Loads (or creates) data for a joining player. Kicks after repeated failure.
--- Returns true on success.
function DataService.load(player: Player): boolean
        local key = "p_" .. player.UserId
        local ok, raw = Util.retry(Config.Data.LoadRetries, function()
                return store:GetAsync(key)
        end)
        if not ok then
                return false
        end
        sessions[player] = { data = sanitize(raw), dirty = false }
        return true
end

function DataService.save(player: Player): boolean
        local session = sessions[player]
        if not session then
                return false
        end
        session.data.LastSeen = os.time()
        local key = "p_" .. player.UserId
        local ok = Util.retry(Config.Data.LoadRetries, function()
                store:SetAsync(key, session.data)
        end)
        if ok then
                session.dirty = false
        end
        return ok
end

function DataService.startLoops()
        -- Autosave loop
        task.spawn(function()
                while true do
                        task.wait(Config.Data.AutosaveInterval)
                        for player in sessions do
                                local session = sessions[player]
                                if session and session.dirty then
                                        task.spawn(DataService.save, player)
                                end
                        end
                end
        end)

        Players.PlayerRemoving:Connect(function(player)
                DataService.save(player)
                sessions[player] = nil
        end)

        game:BindToClose(function()
                for player in sessions do
                        DataService.save(player)
                end
        end)
end

return DataService
