--!nonstrict
--[[
        Config.luau - DUNIA AKIOMIDA v3 "MICDA Economy World"
        MMO petualangan: bertani, mengumpulkan, memancing, KOMBAT, MEMADAI
        (crafting dari material), STAT & PERALATAN, TUGAS, BOSS RAID,
        dagang antar pemain. Seluruh konten karya original, tanpa aset pihak ketiga.
]]

local Config = {}

Config.Game = {
        Name = "Dunia Akiomida",
        Tagline = "Petualangan & Ekonomi",
        Version = "6.1.0",
}

--------------------------------------------------------------------
-- EKONOMI DASAR
--------------------------------------------------------------------
Config.Economy = {
        StartCoins = 50,
        StartSeeds = { wortel = 3 },
        DailyBonus = 100, -- Micda bonus login per hari
        WaterBoost = 0.25, -- siraman memangkas 25% sisa waktu tanaman
        MarketPeriod = 600, -- permintaan pasar berganti tiap 10 menit
        QuizRewardCoins = 20,
        QuizRewardXp = 8,
        QuizCooldown = 20,
}

--------------------------------------------------------------------
-- LEVEL (XP dari aktivitas: panen, tebang, tambang, mancing, kombat, craft)
--------------------------------------------------------------------
Config.Level = {
        Base = 60, -- syarat XP naik level: Base * (level-1)^2
        StatPointsPerLevel = 2, -- poin stat gratis tiap naik level
}

function Config.Level.levelFromXp(xp: number): number
        return math.floor(math.sqrt(math.max(0, xp) / Config.Level.Base)) + 1
end

function Config.Level.thresholdOf(level: number): number
        return Config.Level.Base * math.max(0, level - 1) * (level - 1)
end

--------------------------------------------------------------------
-- BIBIT & HASIL PANEN (harga = Micda; grow = detik; level = syarat)
--------------------------------------------------------------------
Config.Crops = {
        { id = "wortel", name = "Wortel", cost = 5, grow = 25, sell = 12, level = 1, color = { 255, 152, 60 } },
        { id = "jagung", name = "Jagung", cost = 14, grow = 50, sell = 32, level = 2, color = { 255, 221, 80 } },
        { id = "tomat", name = "Tomat", cost = 32, grow = 100, sell = 70, level = 3, color = { 235, 70, 70 } },
        { id = "labu", name = "Labu Raksasa", cost = 80, grow = 200, sell = 170, level = 4, color = { 230, 130, 40 } },
        { id = "bintang", name = "Melon Bintang", cost = 220, grow = 400, sell = 480, level = 6, color = { 255, 235, 120 } },
}

--------------------------------------------------------------------
-- SUMBER DAYA & MATERIAL (semua bisa dijual; beberapa jadi bahan craft)
--------------------------------------------------------------------
Config.Resources = {
        { id = "kayu", name = "Kayu", sell = 6 },
        { id = "apel", name = "Apel", sell = 8 },
        { id = "batu", name = "Batu", sell = 7 },
        { id = "besi", name = "Besi", sell = 18 },
        { id = "kristal", name = "Kristal", sell = 45 },
        -- drop monster (bahan craft & jualan)
        { id = "gel", name = "Gelatin", sell = 9, color = { 130, 220, 120 } },
        { id = "taring", name = "Pecahan Angka 2", sell = 16, color = { 240, 240, 235 } },
        { id = "inti", name = "Inti Angka", sell = 38, color = { 255, 160, 80 } },
        -- hasil tempa (ingot) untuk senjata & zirah
        { id = "balok_besi", name = "Balok Besi", sell = 55, color = { 200, 200, 210 } },
        { id = "balok_kristal", name = "Balok Kristal", sell = 145, color = { 190, 120, 255 } },
}

--------------------------------------------------------------------
-- IKAN (chance = peluang saat memancing)
--------------------------------------------------------------------
Config.Fish = {
        { id = "ikan_kecil", name = "Ikan Kecil", sell = 10, chance = 0.55 },
        { id = "ikan_besar", name = "Ikan Besar", sell = 28, chance = 0.30 },
        { id = "ikan_langka", name = "Ikan Langka", sell = 65, chance = 0.10 },
        { id = "sepatu", name = "Sepatu Bot Tua", sell = 3, chance = 0.05 },
}

--------------------------------------------------------------------
-- ALAT (tier belik menentukan bijih yang bisa ditambang)
--------------------------------------------------------------------
Config.Tools = {
        { id = "can", name = "Kaleng Siram", cost = 150, desc = "Siram tanaman agar tumbuh 25% lebih cepat" },
        { id = "rod", name = "Pancing Ajaib", cost = 250, desc = "Membuka aksi memancing di Danau Tenang" },
        { id = "pick2", name = "Belik Batu", cost = 350, desc = "Tambang bijih Besi", tier = 2 },
        { id = "bike", name = "Sepeda Angin", cost = 900, desc = "Berjalan +60% lebih cepat menjelajah dunia" },
        { id = "pick3", name = "Belik Baja", cost = 1600, desc = "Tambang Kristal langka", tier = 3 },
}

--------------------------------------------------------------------
-- PELIHARAAN (bonus harga jual, satu yang aktif)
--------------------------------------------------------------------
Config.Pets = {
        { id = "kucing", name = "Kucing Micda", cost = 500, bonus = 0.10, color = { 255, 190, 90 }, desc = "Bonus jual +10%" },
        { id = "panda", name = "Panda Martabak", cost = 2500, bonus = 0.25, color = { 240, 240, 245 }, desc = "Bonus jual +25%" },
        { id = "naga", name = "Naga Emas", cost = 10000, bonus = 0.50, color = { 255, 215, 0 }, desc = "Bonus jual +50%" },
}

--------------------------------------------------------------------
-- DATA / LEADERBOARD
--------------------------------------------------------------------
Config.Data = {
        StoreName = "AKM_World_v2",
        OrderedStoreName = "AKM_XP_v2",
        AutosaveInterval = 120,
        LoadRetries = 3,
}

Config.Leaderboard = {
        RefreshInterval = 60,
        Size = 8,
}

return Config
