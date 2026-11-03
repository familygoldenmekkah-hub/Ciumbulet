--!nonstrict
--[[
	init.server.luau
	Server bootstrap. Init order matters:
	  Remotes -> Map -> Data loops -> Economy loops -> Monetization ->
	  Pets -> Shop -> Leaderboard -> per-player: data load -> setup.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Remotes)

Remotes.init()

local Modules = script.Modules
local MapService = require(Modules.MapService)
local DataService = require(Modules.DataService)
local EconomyService = require(Modules.EconomyService)
local MonetizationService = require(Modules.MonetizationService)
local PetService = require(Modules.PetService)
local ShopService = require(Modules.ShopService)
local LeaderboardService = require(Modules.LeaderboardService)

MapService.init()
DataService.startLoops()
EconomyService.startLoops()
MonetizationService.init()
PetService.init()
ShopService.init()
LeaderboardService.init()

local function onPlayerAdded(player: Player)
	local ok = DataService.load(player)
	if not ok then
		player:Kick("Data failed to load - please rejoin in a minute.")
		return
	end
	EconomyService.setupPlayer(player)
	PetService.validateEquipped(player)
	EconomyService.requestSync(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

print("[CoinRush] Server booted: map + services ready.")
