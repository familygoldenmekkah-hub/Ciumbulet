local Config = {}

Config.Game = {
	Name = "Dunia Akiomida",
	Tagline = "Bertani, Panen, Koperasi",
	Version = "7.0.0",
}

Config.Economy = {
	StartCoins = 900000,
	DailyBonus = 100,
}

Config.Level = {
	Base = 60,
	StatPointsPerLevel = 2,
}

function Config.Level.levelFromXp(xp: number): number
	return math.floor(math.sqrt(math.max(0, xp) / Config.Level.Base)) + 1
end

function Config.Level.thresholdOf(level: number): number
	return Config.Level.Base * math.max(0, level - 1) * (level - 1)
end

Config.Resources = {
	{ id = "gel", name = "Gelatin", sell = 9, color = { 130, 220, 120 } },
	{ id = "taring", name = "Pecahan Angka", sell = 16, color = { 240, 240, 235 } },
	{ id = "inti", name = "Inti Angka", sell = 38, color = { 255, 160, 80 } },
	{ id = "besi", name = "Besi Bajak", sell = 18, color = { 170, 170, 178 } },
	{ id = "kristal", name = "Kristal", sell = 45, color = { 190, 120, 255 } },
	{ id = "balok_besi", name = "Balok Besi", sell = 55, color = { 200, 200, 210 } },
	{ id = "balok_kristal", name = "Balok Kristal", sell = 145, color = { 190, 120, 255 } },
}

Config.Fish = {
	{ id = "ikan_kecil", name = "Ikan Kecil", sell = 10, chance = 0.55 },
	{ id = "ikan_besar", name = "Ikan Besar", sell = 28, chance = 0.30 },
	{ id = "ikan_langka", name = "Ikan Langka", sell = 65, chance = 0.10 },
	{ id = "sepatu", name = "Sepatu Bot Tua", sell = 3, chance = 0.05 },
}

Config.Data = {
	StoreName = "AKM_World_v3",
	OrderedStoreName = "AKM_XP_v3",
	AutosaveInterval = 120,
	LoadRetries = 3,
}

Config.Leaderboard = {
	RefreshInterval = 60,
	Size = 8,
}

return Config
