--!nonstrict
--[[
        init.server.luau - bootstrap DUNIA AKIOMIDA v3 "Toram-grade".
        Ekonomi hidup + KOMBAT, TEMPAA (crafting), STAT & PERALATAN,
        TUGAS HARIAN, BOSS RAID, DAGANG ANTAR PEMAIN. Kuis opsional.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)

Remotes.init()

local Modules = script.Modules
local DataService = require(Modules.DataService)
local FarmService = require(Modules.FarmService)
local GatherService = require(Modules.GatherService)
local ShopService = require(Modules.ShopService)
local PetService = require(Modules.PetService)
local QuizService = require(Modules.QuizService)
local LeaderboardService = require(Modules.LeaderboardService)
local EquipService = require(Modules.EquipService)
local QuestService = require(Modules.QuestService)
local CraftService = require(Modules.CraftService)
local CombatService = require(Modules.CombatService)
local TradeService = require(Modules.TradeService)
local MapService = require(Modules.MapService)

-- bangun dunia (butuh referensi layanan untuk menghubungkan NPC)
MapService.init({
        Farm = FarmService,
        Gather = GatherService,
        Shop = ShopService,
        Quiz = QuizService,
        Craft = CraftService,
        Quest = QuestService,
})

FarmService.init()
FarmService.startLoop()
GatherService.init()
ShopService.init()
PetService.init()
QuizService.init()
LeaderboardService.init()
EquipService.init()
QuestService.init()
CraftService.init()
TradeService.init()
CombatService.init()
CombatService.spawnMonsters()
DataService.startLoops()

--------------------------------------------------------------------
-- PEMAIN
--------------------------------------------------------------------

local function applySpeed(player: Player)
        -- v3: semua perhitungan laju/HP/senjata ada di EquipService.apply
        local EquipService = require(script.Modules.EquipService)
        EquipService.apply(player)
end

local function onPlayerAdded(player: Player)
        local ok = DataService.load(player)
        if not ok then
                -- JANGAN kick pemain: pakai sesi memori supaya game tetap bisa dimainkan
                DataService.startSession(player)
                warn("[AKIOMIDA] DataStore gagal, sesi memori dipakai untuk " .. player.Name)
                task.delay(5, function()
                        if player.Parent then
                                Remotes.get("Notify"):FireClient(player, "Mode Sesi",
                                        "Progres sementara hanya tersimpan di sesi ini. Keluar-masuk lagi nanti untuk simpan permanen.")
                        end
                end)
        end

        -- leaderstats standar Roblox
        local leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        local koin = Instance.new("IntValue")
        koin.Name = "Koin"
        koin.Value = math.floor(DataService.get(player).Coins)
        koin.Parent = leaderstats
        local xp = Instance.new("IntValue")
        xp.Name = "XP"
        xp.Value = math.floor(DataService.get(player).XP)
        xp.Parent = leaderstats
        leaderstats.Parent = player

        -- bonus login harian
        local today = tonumber(os.date("!%Y%m%d")) or 0
        local data = DataService.get(player)
        if data.LastLoginDay ~= today then
                data.LastLoginDay = today
                DataService.markDirty(player)
                DataService.addCoins(player, Config.Economy.DailyBonus, false)
                task.delay(5, function()
                        if player.Parent then
                                Remotes.get("Notify"):FireClient(player, "Bonus Harian",
                                        "+" .. Config.Economy.DailyBonus .. " koin untuk petualangan hari ini!")
                        end
                end)
        end

        player.CharacterAdded:Connect(function()
                task.wait(0.5)
                applySpeed(player)
        end)
        if player.Character then
                applySpeed(player)
        end

        task.delay(4, function()
                if not player.Parent then
                        return
                end
                DataService.push(player)
                Remotes.get("Notify"):FireClient(player, "Selamat Datang di Dunia Akiomida!",
                        "Tanam, tebang, tambang, mancing, lawan monster, tempa senjata, kalahkan Raja Golem, dan berdagang dengan pemain lain!")
        end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in Players:GetPlayers() do
        task.spawn(onPlayerAdded, player)
end

Players.PlayerRemoving:Connect(function(player)
        FarmService.releasePlot(player)
        PetService.cleanup(player)
end)

-- client bisa minta refresh state (fallback kalau StateSync terlewat)
Remotes.get("GetState").OnServerInvoke = function(player)
        DataService.push(player)
        return true
end

print("[AKIOMIDA] Server v3 siap: kombat, tempa, stat & peralatan, tugas, boss raid, dagang - di atas fondasi ekonomi hidup.")
