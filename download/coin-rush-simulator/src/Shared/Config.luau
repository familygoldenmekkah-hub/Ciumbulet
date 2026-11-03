--!nonstrict
--[[
	Config.luau
	Single source of truth for every tunable number in the game.
	Server reads this to validate purchases, client reads it to render the shop.
	Change values here -> republish -> done. No code changes needed.
]]

local Config = {}

Config.Game = {
	Name = "Coin Rush Simulator",
	Version = "1.0.0",
}

--------------------------------------------------------------------
-- ECONOMY
--------------------------------------------------------------------
Config.Economy = {
	BaseClickValue = 1, -- coins granted per click at 0 upgrades
	MaxClicksPerSecond = 15, -- server-side rate limit (anti-exploit)
	FracPrecision = 4, -- keep fractional coin accumulation hidden from players
}

-- Ordered list of click upgrades. Cost = base * growth ^ level.
Config.Upgrades = {
	{
		id = "MultiClick",
		name = "Multi Click",
		desc = "+1 coin per click",
		base = 50,
		growth = 1.35,
		max = 100,
		perLevel = 1,
	},
	{
		id = "CoinBoost",
		name = "Coin Boost",
		desc = "+10% total coins",
		base = 250,
		growth = 1.40,
		max = 50,
		percent = 10,
	},
	{
		id = "AutoClick",
		name = "Auto Click",
		desc = "+2 coins per second",
		base = 400,
		growth = 1.38,
		max = 100,
		perLevel = 2,
	},
}

--------------------------------------------------------------------
-- PETS (characters that follow the player and generate income)
--------------------------------------------------------------------
Config.PetEquipCap = 3
Config.VipEquipCap = 5

-- Ordered by price (order = shop display order).
-- income = coins per second while equipped.
-- color/shape/size drive the procedural pet model on the client.
Config.Pets = {
	{ id = "coiny",     name = "Coiny",        price = 100,      income = 1,    color = { 255, 196, 37 },  shape = "Ball",  size = 1.3 },
	{ id = "bunny",     name = "Speedy Bunny", price = 500,      income = 3,    color = { 245, 245, 245 }, shape = "Ball",  size = 1.1 },
	{ id = "cat",       name = "Lucky Cat",    price = 2000,     income = 8,    color = { 255, 128, 177 }, shape = "Block", size = 1.3 },
	{ id = "doggo",     name = "Doggo",        price = 7500,     income = 20,   color = { 146, 89, 39 },   shape = "Block", size = 1.4 },
	{ id = "robo",      name = "Robo Buddy",   price = 25000,    income = 55,   color = { 99, 142, 255 },  shape = "Block", size = 1.2 },
	{ id = "phoenix",   name = "Phoenix",      price = 100000,   income = 150,  color = { 255, 94, 58 },   shape = "Ball",  size = 1.6 },
	{ id = "dragon",    name = "Dragon",       price = 500000,   income = 400,  color = { 60, 200, 90 },   shape = "Ball",  size = 1.8 },
	{ id = "galaxyfox", name = "Galaxy Fox",   price = 2000000,  income = 1200, color = { 170, 86, 255 },  shape = "Ball",  size = 1.5 },
}

--------------------------------------------------------------------
-- REBIRTH
--------------------------------------------------------------------
Config.Rebirth = {
	BaseCost = 25000, -- cost = BaseCost * growth ^ currentRebirths
	Growth = 2.2,
	BonusPer = 0.5, -- permanent multiplier = 1 + rebirths * BonusPer
	ResetsCoins = true, -- coins + upgrades reset; pets & gamepasses are kept
}

--------------------------------------------------------------------
-- MONETIZATION (Robux)
-- IDs below are PLACEHOLDERS. After you create the passes/products
-- in the Creator Dashboard, paste their numeric IDs here and republish.
-- The game works fine with id = 0 (the buttons simply stay hidden).
--------------------------------------------------------------------
Config.Gamepasses = {
	DoubleCoins = { id = 0, price = 99,  name = "2x Coins",   desc = "Double all coins from clicks and pets." },
	VIP         = { id = 0, price = 199, name = "VIP",        desc = "+25% coins, 5 pet slots, VIP tag." },
	TurboHands  = { id = 0, price = 149, name = "Turbo Hands", desc = "+20 coins per second, forever." },
}

Config.Products = {
	PackS = { id = 0, price = 49,  name = "1,000 Coins",   coins = 1000 },
	PackM = { id = 0, price = 199, name = "15,000 Coins",  coins = 15000 },
	PackL = { id = 0, price = 999, name = "200,000 Coins", coins = 200000 },
}

--------------------------------------------------------------------
-- DATA / LEADERBOARD
--------------------------------------------------------------------
Config.Data = {
	StoreName = "CRS_PlayerData_v1",
	OrderedStoreName = "CRS_GlobalCoins_v1",
	AutosaveInterval = 120, -- seconds
	LoadRetries = 3,
}

Config.Leaderboard = {
	RefreshInterval = 60, -- seconds between global top-10 refreshes
	Size = 10,
}

--------------------------------------------------------------------
-- WORLD LAYOUT (map generator)
--------------------------------------------------------------------
Config.World = {
	IslandRadius = 100,
	CoinPosition = { 0, 10, -30 },
	CoinSize = 16,
}

return Config
