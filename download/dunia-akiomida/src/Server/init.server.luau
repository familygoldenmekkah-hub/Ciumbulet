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
local MarketService = require(Modules.MarketService)
local KiosService = require(Modules.KiosService)
local RegionService = require(Modules.RegionService) -- v21: sistem wilayah & portal
local MapService = require(Modules.MapService)

-- bangun dunia (butuh referensi layanan untuk menghubungkan NPC)
MapService.init({
        Farm = FarmService,
        Gather = GatherService,
        Shop = ShopService,
        Quiz = QuizService,
        Craft = CraftService,
        Quest = QuestService,
        Market = MarketService,
})

-- v21: gerbang portal antar wilayah (butuh DataService & FarmService)
RegionService.init({
        Data = DataService,
        Farm = FarmService,
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
MarketService.init()
KiosService.init() -- v20: kios vending pemain (butuh ladang sudah dibangun)
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
        local Micda = Instance.new("IntValue")
        Micda.Name = "Micda"
        Micda.Value = math.floor(DataService.get(player).Coins)
        Micda.Parent = leaderstats
        local xp = Instance.new("IntValue")
        xp.Name = "XP"
        xp.Value = math.floor(DataService.get(player).XP)
        xp.Parent = leaderstats
        leaderstats.Parent = player

        -- kotak pos pasar: hasil jual di Papan Jual saat pemain offline
        MarketService.claimMail(player)

        -- v21: daftarkan pulau rumah pemain (klaim ulang ladang di pulau sendiri)
        RegionService.onPlayerAdded(player)

        -- bonus login harian + rantai streak (v9, hadiah langsung tanpa syarat)
        local today = tonumber(os.date("!%Y%m%d")) or 0
        local data = DataService.get(player)
        if data.LastLoginDay ~= today then
                local yesterday = tonumber(os.date("!%Y%m%d", os.time() - 86400)) or 0
                data.Streak = (data.LastLoginDay == yesterday) and (data.Streak + 1) or 1
                data.LastLoginDay = today
                DataService.markDirty(player)
                local bonus = Config.Economy.DailyBonus + 25 * math.min(data.Streak - 1, 6)
                DataService.addCoins(player, bonus, false)
                task.delay(5, function()
                        if player.Parent then
                                Remotes.get("Notify"):FireClient(player, "Bonus Harian",
                                        "+" .. bonus .. " Micda! Rantai login: " .. data.Streak .. " hari.")
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
                        "Tanam, tebang, tambang, mancing, lawan MONSTER ANGKA, tempa senjata, kalahkan Angka Sang Raja, dan jual barangmu di PAPAN JUAL dengan MICDA!")
        end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in Players:GetPlayers() do
        task.spawn(onPlayerAdded, player)
end

Players.PlayerRemoving:Connect(function(player)
        RegionService.onPlayerRemoving(player)
        FarmService.releasePlot(player)
        PetService.cleanup(player)
end)

-- v8: upgrade peralatan
Remotes.get("EquipUpgrade").OnServerInvoke = function(player, equipId)
        local EquipService = require(script.Modules.EquipService)
        return EquipService.upgrade(player, equipId)
end

-- v5: skill senjata
Remotes.get("Skill").OnServerInvoke = function(player, payload)
        local CombatService = require(script.Modules.CombatService)
        return CombatService.useSkill(player, payload)
end

-- client bisa minta refresh state (fallback kalau StateSync terlewat)
Remotes.get("GetState").OnServerInvoke = function(player)
        DataService.push(player)
        return true
end

print("[AKIOMIDA] Server v6.2 siap: arsitektur wilayah pulau (pusat kota - pulau panen - pulau monster - pulau rumah pribadi), portal antar wilayah, kolam air sungguhan, ruang Bedah/Sains/Startopia, kios vending pemain, BGM sintesis, fase murka boss, monster angka bersaura, papan jual Micda.")
