--!nonstrict
--[[
        DataService.luau - data pemain v2 "Ekonomi Hidup":
        Micda, XP, bibit, hasil panen, sumber daya, ikan, alat, peliharaan.
        DataStore + autosave + snapshot state untuk client.
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)
local Remotes = require(ReplicatedStorage.Remotes)

local DataService = {}

local store = DataStoreService:GetDataStore(Config.Data.StoreName)

local sessions: { [Player]: { data: { [string]: any }, dirty: boolean, fallback: boolean } } = {}

-- provider state tambahan dari layanan lain (didftar lewat init, tanpa siklus require)
local providers: { [string]: (Player) -> any } = {}

function DataService.registerProvider(name: string, fn: (Player) -> any)
        providers[name] = fn
end

-- kind -> nama tabel inventaris
local KIND_FIELD = {
        seed = "Seeds",
        crop = "Crops",
        bag = "Bag",
        fish = "Fish",
        equip = "Equips", -- v3: senjata & zirah tempaan
        use = "Usables", -- v3: makanan & ramuan
}

function DataService.kindField(kind: string): string?
        return KIND_FIELD[kind]
end

local function defaultData(): { [string]: any }
        return {
                Coins = Config.Economy.StartCoins,
                XP = 0,
                Seeds = Util.deepCopy(Config.Economy.StartSeeds),
                Crops = {},
                Bag = {},
                Fish = {},
                Tools = { pickTier = 1, can = false, rod = false, bike = false },
                Pets = {},
                ActivePet = "",
                -- v3: Toram-grade progression
                Stats = { str = 0, vit = 0, agi = 0, int = 0, dex = 0 },
                StatPoints = 0, -- poin gratis dari naik level
                Equips = {},
                EquipStars = {}, -- v8: level upgrade +1..+5 per equip
                CraftCount = {}, -- v10: jumlah tiap resep dibuat (mastery)
                Usables = {},
                Equipped = { weapon = "", armor = "" },
                Buff = { kind = "", expiry = 0 },
                Quest = { id = "", prog = 0, acceptedAt = 0, done = false },
                TotalEarned = 0,
                LastLoginDay = 0,
                Streak = 0, -- v9: rantai login harian
                Dev = false,
                LastSeen = 0,
        }
end

local function sanitizeCount(v: any): number
        return math.max(0, math.floor(tonumber(v) or 0))
end

local function sanitize(raw: any): { [string]: any }
        local out = defaultData()
        if type(raw) ~= "table" then
                return out
        end
        out.Coins = sanitizeCount(raw.Coins)
        out.XP = sanitizeCount(raw.XP)
        out.Streak = math.clamp(math.floor(tonumber(raw.Streak) or 0), 0, 999)
        for kind, field in KIND_FIELD do
                if type(raw[field]) == "table" then
                        out[field] = {} -- timpa default supaya inventaris lama dihormati
                        for id, count in raw[field] do
                                if type(id) == "string" then
                                        out[field][id] = sanitizeCount(count)
                                end
                        end
                end
        end
        if type(raw.CraftCount) == "table" then
                for id, n in raw.CraftCount do
                        if type(id) == "string" then
                                out.CraftCount[id] = math.clamp(math.floor(tonumber(n) or 0), 0, 9999)
                        end
                end
        end
        if type(raw.EquipStars) == "table" then
                for id, star in raw.EquipStars do
                        if type(id) == "string" then
                                out.EquipStars[id] = math.clamp(math.floor(tonumber(star) or 0), 0, 5)
                        end
                end
        end
        if type(raw.Tools) == "table" then
                out.Tools.pickTier = math.clamp(math.floor(tonumber(raw.Tools.pickTier) or 1), 1, 3)
                out.Tools.can = raw.Tools.can == true
                out.Tools.rod = raw.Tools.rod == true
                out.Tools.bike = raw.Tools.bike == true
        end
        if type(raw.Pets) == "table" then
                for id, owned in raw.Pets do
                        if type(id) == "string" and owned == true then
                                out.Pets[id] = true
                        end
                end
        end
        -- v3: stat & poin
        if type(raw.Stats) == "table" then
                for _, key in { "str", "vit", "agi", "int", "dex" } do
                        out.Stats[key] = math.clamp(math.floor(tonumber(raw.Stats[key]) or 0), 0, 60)
                end
        end
        out.StatPoints = math.clamp(math.floor(tonumber(raw.StatPoints) or 0), 0, 400)
        if type(raw.Equipped) == "table" then
                out.Equipped.weapon = type(raw.Equipped.weapon) == "string" and raw.Equipped.weapon or ""
                out.Equipped.armor = type(raw.Equipped.armor) == "string" and raw.Equipped.armor or ""
        end
        if type(raw.Buff) == "table" then
                out.Buff.kind = type(raw.Buff.kind) == "string" and raw.Buff.kind or ""
                out.Buff.expiry = math.floor(tonumber(raw.Buff.expiry) or 0)
        end
        if type(raw.Quest) == "table" then
                out.Quest.id = type(raw.Quest.id) == "string" and raw.Quest.id or ""
                out.Quest.prog = sanitizeCount(raw.Quest.prog)
                out.Quest.acceptedAt = sanitizeCount(raw.Quest.acceptedAt)
                out.Quest.done = raw.Quest.done == true
        end
        out.ActivePet = type(raw.ActivePet) == "string" and raw.ActivePet or ""
        out.TotalEarned = sanitizeCount(raw.TotalEarned)
        out.LastLoginDay = sanitizeCount(raw.LastLoginDay)
        out.Dev = raw.Dev == true
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

function DataService.levelOf(player: Player): number
        return Config.Level.levelFromXp(DataService.get(player).XP)
end

--------------------------------------------------------------------
-- PERUBAHAN EKONOMI
--------------------------------------------------------------------

function DataService.addCoins(player: Player, amount: number, countAsEarned: boolean?)
        local data = DataService.get(player)
        data.Coins = math.max(0, math.floor(data.Coins + amount))
        if countAsEarned and amount > 0 then
                data.TotalEarned += math.floor(amount)
        end
        DataService.markDirty(player)
end

function DataService.spend(player: Player, amount: number): boolean
        local data = DataService.get(player)
        if data.Coins < amount then
                return false
        end
        data.Coins -= amount
        DataService.markDirty(player)
        return true
end

function DataService.addXP(player: Player, amount: number)
        local data = DataService.get(player)
        local before = Config.Level.levelFromXp(data.XP)
        data.XP = math.max(0, math.floor(data.XP + amount))
        local after = Config.Level.levelFromXp(data.XP)
        if after > before then
                -- v3: naik level memberi poin stat gratis (gaya Toram)
                data.StatPoints += (after - before) * Config.Level.StatPointsPerLevel
        end
        DataService.markDirty(player)
end

function DataService.giveItem(player: Player, kind: string, id: string, count: number)
        local field = KIND_FIELD[kind]
        if not field then
                return
        end
        local data = DataService.get(player)
        data[field][id] = (data[field][id] or 0) + count
        if data[field][id] <= 0 then
                data[field][id] = nil
        end
        DataService.markDirty(player)
end

function DataService.takeItem(player: Player, kind: string, id: string, count: number): boolean
        local field = KIND_FIELD[kind]
        if not field then
                return false
        end
        local data = DataService.get(player)
        local have = data[field][id] or 0
        if have < count then
                return false
        end
        data[field][id] = have - count
        if data[field][id] <= 0 then
                data[field][id] = nil
        end
        DataService.markDirty(player)
        return true
end

function DataService.countItem(player: Player, kind: string, id: string): number
        local field = KIND_FIELD[kind]
        if not field then
                return 0
        end
        local data = DataService.get(player)
        return data[field][id] or 0
end

--------------------------------------------------------------------
-- SNAPSHOT STATE -> CLIENT
--------------------------------------------------------------------

function DataService.push(player: Player)
        if not DataService.has(player) then
                return
        end
        local data = DataService.get(player)

        -- sinkronkan leaderstats Roblox (Micda + XP)
        local stats = player:FindFirstChild("leaderstats")
        if stats then
                local Micda = stats:FindFirstChild("Micda")
                if Micda and Micda:IsA("IntValue") then
                        Micda.Value = math.floor(data.Coins)
                end
                local xp = stats:FindFirstChild("XP")
                if xp and xp:IsA("IntValue") then
                        xp.Value = math.floor(data.XP)
                end
        end

        -- snapshot dari provider lain (FarmService = ladang, ShopService = pasar)
        local okPlot, plotState = pcall(function()
                local fn = providers["plot"]
                if not fn then
                        return { claimed = false, tiles = {} }
                end
                return fn(player)
        end)
        local okDemand, demand = pcall(function()
                local fn = providers["demand"]
                if not fn then
                        return {}
                end
                return fn(player)
        end)

        local level = Config.Level.levelFromXp(data.XP)
        local prev = Config.Level.thresholdOf(level)
        local next = Config.Level.thresholdOf(level + 1)
        local pct = (data.XP - prev) / math.max(1, next - prev)

        Remotes.get("StateSync"):FireClient(player, {
                Coins = math.floor(data.Coins),
                XP = math.floor(data.XP),
                Level = level,
                LevelPct = math.clamp(pct, 0, 1),
                Seeds = Util.deepCopy(data.Seeds),
                Crops = Util.deepCopy(data.Crops),
                Bag = Util.deepCopy(data.Bag),
                Fish = Util.deepCopy(data.Fish),
                Tools = Util.deepCopy(data.Tools),
                Pets = Util.deepCopy(data.Pets),
                ActivePet = data.ActivePet,
                -- v3
                Stats = Util.deepCopy(data.Stats),
                StatPoints = data.StatPoints,
                Equips = Util.deepCopy(data.Equips),
                EquipStars = Util.deepCopy(data.EquipStars),
                CraftCount = Util.deepCopy(data.CraftCount),
                Usables = Util.deepCopy(data.Usables),
                Equipped = Util.deepCopy(data.Equipped),
                Buff = Util.deepCopy(data.Buff),
                Quest = Util.deepCopy(data.Quest),
                Plot = okPlot and plotState or { claimed = false, tiles = {} },
                Demand = okDemand and demand or {},
                Dev = data.Dev,
                Streak = data.Streak,
        })
end

--------------------------------------------------------------------
-- LOAD / SAVE / LOOPS
--------------------------------------------------------------------

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

        -- push state berkala (progres tanaman & harga pasar)
        task.spawn(function()
                while true do
                        task.wait(15)
                        for player in sessions do
                                task.spawn(DataService.push, player)
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
