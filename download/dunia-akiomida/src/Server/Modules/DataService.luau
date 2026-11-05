--!nonstrict
--[[
        DataService.luau - progres pemain: XP, koin, jawaban benar per zona,
        bahasan dibaca, streak, status dev. DataStore + autosave + sanitize.
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)

local DataService = {}

local store = DataStoreService:GetDataStore(Config.Data.StoreName)

local sessions: { [Player]: { data: { [string]: any }, dirty: boolean, fallback: boolean } } = {}

local function defaultData(): { [string]: any }
        local correct: { [string]: number } = {}
        for _, zone in Config.Zones do
                correct[zone.id] = 0
        end
        local mastered: { [string]: boolean } = {}
        for _, zone in Config.Zones do
                mastered[zone.id] = false
        end
        return {
                XP = 0,
                Coins = 0,
                Correct = correct,
                Mastered = mastered,
                Read = {}, -- topic ids
                Streak = 0,
                BestStreak = 0,
                Dev = false,
                LastSeen = 0,
        }
end

local function sanitize(raw: any): { [string]: any }
        local out = defaultData()
        if type(raw) ~= "table" then
                return out
        end
        out.XP = tonumber(raw.XP) or 0
        out.Coins = tonumber(raw.Coins) or 0
        out.Streak = tonumber(raw.Streak) or 0
        out.BestStreak = tonumber(raw.BestStreak) or 0
        out.Dev = raw.Dev == true
        if type(raw.Correct) == "table" then
                for _, zone in Config.Zones do
                        out.Correct[zone.id] = math.max(0, math.floor(tonumber(raw.Correct[zone.id]) or 0))
                end
        end
        if type(raw.Mastered) == "table" then
                for _, zone in Config.Zones do
                        out.Mastered[zone.id] = raw.Mastered[zone.id] == true
                end
        end
        if type(raw.Read) == "table" then
                for _, id in raw.Read do
                        if type(id) == "string" then
                                table.insert(out.Read, id)
                        end
                end
        end
        out.LastSeen = tonumber(raw.LastSeen) or 0
        return out
end

function DataService.get(player: Player): { [string]: any }
        local s = sessions[player]
        return s and s.data or defaultData()
end

function DataService.has(player: Player): boolean
        return sessions[player] ~= nil
end

function DataService.markDirty(player: Player)
        local s = sessions[player]
        if s then
                s.dirty = true
        end
end

function DataService.load(player: Player): boolean
        local key = "p_" .. player.UserId
        local ok, raw = Util.retry(Config.Data.LoadRetries, function()
                return store:GetAsync(key)
        end)
        if not ok then
                return false
        end
        sessions[player] = { data = sanitize(raw), dirty = false, fallback = false }
        return true
end

--- Sesi cadangan (memori saja) saat DataStore tidak tersedia,
--- supaya pemain tetap bisa bermain tanpa di-kick.
function DataService.startSession(player: Player)
        if sessions[player] then
                return
        end
        sessions[player] = { data = defaultData(), dirty = false, fallback = true }
end

function DataService.save(player: Player): boolean
        local s = sessions[player]
        if not s then
                return false
        end
        if s.fallback then
                return false -- sesi memori: tidak ada tempat menyimpan
        end
        s.data.LastSeen = os.time()
        local ok = Util.retry(Config.Data.LoadRetries, function()
                store:SetAsync("p_" .. player.UserId, s.data)
        end)
        if ok then
                s.dirty = false
        end
        return ok
end

function DataService.startLoops()
        task.spawn(function()
                while true do
                        task.wait(Config.Data.AutosaveInterval)
                        for player, s in sessions do
                                if s.dirty then
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
