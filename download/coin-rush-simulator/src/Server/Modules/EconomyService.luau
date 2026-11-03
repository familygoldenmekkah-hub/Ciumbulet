--!nonstrict
--[[
	EconomyService.luau
	All coin math lives here and ONLY here (server-authoritative):
	  - click value & passive income formulas
	  - click rate limiting (anti-exploit)
	  - debounced StateSync to clients + leaderstats
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Remotes)
local DataService = require(script.Parent.DataService)

local EconomyService = {}

local stateSync = Remotes.get("StateSync")
local notifyRemote = Remotes.get("Notify")

local SYNC_DEBOUNCE = 0.2

-- player -> { windowStart, count } for the click rate limiter
local clickLimiter: { [Player]: { windowStart: number, count: number } } = {}
-- player -> pending sync flag (debounce)
local syncPending: { [Player]: boolean } = {}
-- player -> leaderstats IntValue handles
local statsHandles: { [Player]: { Coins: IntValue, Rebirths: IntValue } } = {}

--------------------------------------------------------------------
-- FORMULAS
--------------------------------------------------------------------

--- Permanent multiplier from rebirths (1 + 0.5 per rebirth).
function EconomyService.rebirthMult(data): number
	return 1 + data.Rebirths * Config.Rebirth.BonusPer
end

--- Total percentage bonus from CoinBoost upgrade levels.
--- Config.Upgrades[2] is CoinBoost by design (see Config.luau order).
function EconomyService.boostMult(data): number
	local upgrade = nil
	for _, u in Config.Upgrades do
		if u.id == "CoinBoost" then
			upgrade = u
			break
		end
	end
	local percent = (upgrade and upgrade.percent) or 10
	return 1 + (data.Upgrades.CoinBoost * percent) / 100
end

--- Combined multiplier: rebirth x boost x gamepasses.
function EconomyService.totalMult(data): number
	local mult = EconomyService.rebirthMult(data) * EconomyService.boostMult(data)
	if data.Gamepasses.DoubleCoins then
		mult = mult * 2
	end
	if data.Gamepasses.VIP then
		mult = mult * 1.25
	end
	return mult
end

--- Coins per click.
function EconomyService.clickValue(data): number
	local perLevel = nil
	for _, u in Config.Upgrades do
		if u.id == "MultiClick" then
			perLevel = u.perLevel
			break
		end
	end
	local base = Config.Economy.BaseClickValue + data.Upgrades.MultiClick * (perLevel or 1)
	return base * EconomyService.totalMult(data)
end

--- Coins per second (Auto Click upgrade + equipped pets + Turbo Hands).
function EconomyService.perSecond(data): number
	local inc = 0
	for _, u in Config.Upgrades do
		if u.id == "AutoClick" then
			inc = data.Upgrades.AutoClick * (u.perLevel or 2)
			break
		end
	end
	for _, petId in data.Equipped do
		for _, pet in Config.Pets do
			if pet.id == petId then
				inc += pet.income
				break
			end
		end
	end
	if data.Gamepasses.TurboHands then
		inc += 20
	end
	return inc * EconomyService.totalMult(data)
end

--- Cost of the next level of an upgrade (nil when maxed).
function EconomyService.upgradeCost(upgradeDef, currentLevel: number): number?
	if currentLevel >= upgradeDef.max then
		return nil
	end
	return math.floor(upgradeDef.base * upgradeDef.growth ^ currentLevel + 0.5)
end

function EconomyService.rebirthCost(data): number
	return math.floor(Config.Rebirth.BaseCost * Config.Rebirth.Growth ^ data.Rebirths + 0.5)
end

--------------------------------------------------------------------
-- GRANTING COINS (single entry point so TotalEarned stays consistent)
--------------------------------------------------------------------

--- Adds coins (fractional amounts allowed, dust below 1 coin is dropped).
function EconomyService.addCoins(player: Player, amount: number)
	local data = DataService.get(player)
	if amount <= 0 then
		return
	end
	data.Coins = math.floor(data.Coins + amount)
	data.TotalEarned = math.floor(data.TotalEarned + amount)
	DataService.markDirty(player)
end

function EconomyService.spendCoins(player: Player, amount: number): boolean
	local data = DataService.get(player)
	if data.Coins < amount then
		return false
	end
	data.Coins -= amount
	DataService.markDirty(player)
	return true
end

--------------------------------------------------------------------
-- CLICKS (rate limited)
--------------------------------------------------------------------

function EconomyService.registerClick(player: Player)
	if not DataService.has(player) then
		return
	end
	local limiter = clickLimiter[player]
	if not limiter then
		limiter = { windowStart = time(), count = 0 }
		clickLimiter[player] = limiter
	end
	local now = time()
	if now - limiter.windowStart >= 1 then
		limiter.windowStart = now
		limiter.count = 0
	end
	limiter.count += 1
	if limiter.count > Config.Economy.MaxClicksPerSecond then
		return -- silently drop; exploiters gain nothing
	end
	local value = EconomyService.clickValue(DataService.get(player))
	EconomyService.addCoins(player, value)
	EconomyService.requestSync(player)
end

--------------------------------------------------------------------
-- SYNC + LEADERSTATS
--------------------------------------------------------------------

--- Debounced full-state push to one client. Also refreshes leaderstats.
function EconomyService.requestSync(player: Player)
	if syncPending[player] then
		return
	end
	syncPending[player] = true
	task.delay(SYNC_DEBOUNCE, function()
		syncPending[player] = nil
		if not player.Parent or not DataService.has(player) then
			return
		end
		local data = DataService.get(player)
		stateSync:FireClient(player, {
			Coins = data.Coins,
			TotalEarned = data.TotalEarned,
			Rebirths = data.Rebirths,
			Upgrades = data.Upgrades,
			Pets = data.Pets,
			Equipped = data.Equipped,
			Gamepasses = data.Gamepasses,
			PerSecond = EconomyService.perSecond(data),
			ClickValue = EconomyService.clickValue(data),
			RebirthCost = EconomyService.rebirthCost(data),
			EquipCap = data.Gamepasses.VIP and Config.VipEquipCap or Config.PetEquipCap,
		})
		local handles = statsHandles[player]
		if handles then
			handles.Coins.Value = data.Coins
			handles.Rebirths.Value = data.Rebirths
		end
	end)
end

--------------------------------------------------------------------
-- LOOPS
--------------------------------------------------------------------

function EconomyService.startLoops()
	-- Passive income tick (1s)
	task.spawn(function()
		while true do
			task.wait(1)
			for _, player in Players:GetPlayers() do
				if DataService.has(player) then
					local inc = EconomyService.perSecond(DataService.get(player))
					if inc > 0 then
						EconomyService.addCoins(player, inc)
						EconomyService.requestSync(player)
					end
				end
			end
		end
	end)

	-- Cleanup on leave
	Players.PlayerRemoving:Connect(function(player)
		clickLimiter[player] = nil
		syncPending[player] = nil
		statsHandles[player] = nil
	end)
end

--- Call once per player after data load: create leaderstats + first sync.
function EconomyService.setupPlayer(player: Player)
	local data = DataService.get(player)

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"

	local coinsStat = Instance.new("IntValue")
	coinsStat.Name = "Coins"
	coinsStat.Value = data.Coins
	coinsStat.Parent = leaderstats

	local rebirthStat = Instance.new("IntValue")
	rebirthStat.Name = "Rebirths"
	rebirthStat.Value = data.Rebirths
	rebirthStat.Parent = leaderstats

	leaderstats.Parent = player
	statsHandles[player] = { Coins = coinsStat, Rebirths = rebirthStat }

	EconomyService.requestSync(player)
	notifyRemote:FireClient(player, "Welcome", "Tap the giant coin or the button below to earn coins!")
end

return EconomyService
