--!nonstrict
--[[
        init.server.luau - bootstrap DUNIA AKIOMIDA v2 "Ekonomi Hidup".
        Dunia MMO: bertani, memanen, mengumpulkan, memancing, berdagang,
        peliharaan, ladang pribadi. Kuis opsional di Kak Pintar.
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
local MapService = require(Modules.MapService)

-- bangun dunia (butuh referensi layanan untuk menghubungkan NPC)
MapService.init({
        Farm = FarmService,
        Gather = GatherService,
        Shop = ShopService,
        Quiz = QuizService,
})

FarmService.init()
FarmService.startLoop()
GatherService.init()
ShopService.init()
PetService.init()
QuizService.init()
LeaderboardService.init()
DataService.startLoops()

--------------------------------------------------------------------
-- PEMAIN
--------------------------------------------------------------------

local function applySpeed(player: Player)
        local character = player.Character
        if not character then
                return
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
                humanoid.WalkSpeed = DataService.get(player).Tools.bike and 26 or 16
        end
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
                        "Kamu dapat 3 Bibit Wortel & koin awal. Beli bibit di Pasar Timur, klaim ladang gratis di Utara, tanam, panen, lalu jual!")
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

print("[AKIOMIDA] Server v2 siap: ekonomi hidup - ladang, hutan, tambang, danau, pasar, peliharaan.")
