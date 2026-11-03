--!nonstrict
--[[
	init.server.luau - bootstrap Dunia Akiomida.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Remotes)

Remotes.init()

local Modules = script.Modules
local MapService = require(Modules.MapService)
local DataService = require(Modules.DataService)
local QuizService = require(Modules.QuizService)
local LeaderboardService = require(Modules.LeaderboardService)

MapService.init()
DataService.startLoops()
QuizService.init()
LeaderboardService.init()

local notify = Remotes.get("Notify")

local function onPlayerAdded(player: Player)
	local ok = DataService.load(player)
	if not ok then
		player:Kick("Gagal memuat progres - coba masuk lagi sebentar.")
		return
	end

	-- leaderstats: XP (papan peringkat Roblox standar)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	local xp = Instance.new("IntValue")
	xp.Name = "XP"
	xp.Value = DataService.get(player).XP
	xp.Parent = leaderstats
	leaderstats.Parent = player

	QuizService.pushState(player)
	notify:FireClient(player, "Dunia Akiomida", "Selamat datang, penjelajah! Temui Kak Satu di Kamp Angka.")
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

print("[AKIOMIDA] Server siap: 6 zona + kuis + leaderboard.")
