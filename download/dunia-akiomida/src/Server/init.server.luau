local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)

Remotes.init()

local Modules = script.Modules
local DataService = require(Modules.DataService)
local FarmService = require(Modules.FarmService)
local GatherService = require(Modules.GatherService)
local KoperasiService = require(Modules.KoperasiService)
local SeedShopService = require(Modules.SeedShopService)
local LeaderboardService = require(Modules.LeaderboardService)
local EquipService = require(Modules.EquipService)
local CraftService = require(Modules.CraftService)
local CombatService = require(Modules.CombatService)
local RegionService = require(Modules.RegionService)
local MapService = require(Modules.MapService)

MapService.init({
	Farm = FarmService,
	Gather = GatherService,
	Craft = CraftService,
})

RegionService.init({
	Data = DataService,
	Farm = FarmService,
	Koperasi = KoperasiService,
})

FarmService.init()
FarmService.startLoop()
GatherService.init()
KoperasiService.init()
SeedShopService.init()
LeaderboardService.init()
EquipService.init()
CraftService.init()
CombatService.init()
CombatService.spawnMonsters()
DataService.startLoops()

local DevCodeVault = require(Modules.DevCodeVault)
Remotes.get("RedeemDevCode").OnServerInvoke = function(player, code)
        if not DataService.has(player) then
                return false, "Data belum siap."
        end
        if type(code) ~= "string" or code ~= DevCodeVault.CODE then
                return false, "Kode salah."
        end
        local data = DataService.get(player)
        if data.Dev then
                return false, "Kode sudah pernah dipakai."
        end
        data.Dev = true
        DataService.markDirty(player)
        DataService.push(player)
        return true, "Status dev aktif. Terima kasih, pemilik dunia!"
end

local function applySpeed(player: Player)
	EquipService.apply(player)
end

local function onPlayerAdded(player: Player)
	local ok = DataService.load(player)
	if not ok then
		DataService.startSession(player)
		warn("[AKIOMIDA] DataStore gagal, sesi memori dipakai untuk " .. player.Name)
		task.delay(5, function()
			if player.Parent then
				Remotes.get("Notify"):FireClient(player, "Mode Sesi",
					"Progres sementara hanya tersimpan di sesi ini. Keluar-masuk lagi nanti untuk simpan permanen.")
			end
		end)
	end

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

	RegionService.onPlayerAdded(player)

	local today = tonumber(os.date("!%Y%m%d")) or 0
	local data = DataService.get(player)
	if data.LastLoginDay ~= today then
		local yesterday = tonumber(os.date("!%Y%m%d", os.time() - 86400)) or 0
		data.Streak = (data.LastLoginDay == yesterday) and (data.Streak + 1) or 1
		data.LastLoginDay = today
		DataService.markDirty(player)
		local bonus = Config.Economy.DailyBonus + 25 * math.min(data.Streak - 1, 6)
		DataService.addCoins(player, bonus, false)
		Remotes.get("Notify"):FireClient(player, "Bonus Hari " .. data.Streak,
			"+" .. bonus .. " Micda hadiah login! Datang lagi besok.")
	end

	applySpeed(player)
	DataService.push(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

print("[AKIOMIDA] Server v7 siap: ekonomi tani baru, 10 lahan, toko benih, koperasi.")
