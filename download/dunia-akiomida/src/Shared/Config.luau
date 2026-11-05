--!nonstrict
--[[
        Config.luau - DUNIA AKIOMIDA (versi Roblox) - v1.0.1
        Port original dari game browser "Dunia Akiomida: Petualangan Matematika".
        Fitur sengaja TIDAK dibawa ke Roblox: ads, donasi, share, toggle wawasan.
]]

local Config = {}

Config.Game = {
        Name = "Dunia Akiomida",
        Tagline = "Petualangan Matematika",
        Version = "1.0.0",
}

--------------------------------------------------------------------
-- ZONA (identitas & urutan dari game browser)
-- biome menentukan dekorasi prosedural di MapService.
--------------------------------------------------------------------
Config.Zones = {
        { id = "kamp",    name = "Kamp Angka",        slogan = "Wilayah permulaan perjalanan",    color = { 99, 200, 255 }, biome = "kamp" },
        { id = "hutan",   name = "Hutan Simbol",      slogan = "Wilayah bahasa dan tanda",        color = { 79, 227, 200 }, biome = "hutan" },
        { id = "gunung",  name = "Pegunungan Pola",   slogan = "Wilayah susunan dan bentuk",      color = { 255, 209, 102 }, biome = "gunung" },
        { id = "kota",    name = "Kota Bukti",        slogan = "Wilayah alasan dan pembuktian",   color = { 255, 157, 157 }, biome = "kota" },
        { id = "lembah",  name = "Lembah Kedalaman",  slogan = "Wilayah pemahaman yang dalam",    color = { 187, 143, 255 }, biome = "lembah" },
        { id = "salju",   name = "Puncak Riset",      slogan = "Wilayah para penjelajah terdepan", color = { 165, 216, 255 }, biome = "salju" },
}

--------------------------------------------------------------------
-- PROGRES & KUIS
--------------------------------------------------------------------
Config.Progress = {
        MasteryTarget = 10, -- jawaban benar per zona untuk menguasai
        XpPerCorrect = 10,
        CoinPerCorrect = 5, -- dikali indeks zona (zona makin jauh makin berharga)
        StreakBonusMax = 5, -- bonus XP maksimum dari streak (XP tambahan = streak, dibatasi)
        MasteryBonusXp = 50,
        MasteryBonusCoins = 50,
        UnlockNextOnMastery = true,
        MaxActiveQuestionSeconds = 120, -- soal kedaluwarsa setelah 2 menit
        AnswerCooldown = 0.4, -- anti-spam jawab (detik)
}

--------------------------------------------------------------------
-- KODE PENJELAJAH: dipindah ke SERVER-ONLY (Server/Modules/DevCodeVault)
-- supaya tidak bisa dibaca client saat runtime. Jangan taruh nilainya di Shared.
--------------------------------------------------------------------

--------------------------------------------------------------------
-- DATA / LEADERBOARD
--------------------------------------------------------------------
Config.Data = {
        StoreName = "AKM_Progress_v1",
        OrderedStoreName = "AKM_XP_v1",
        AutosaveInterval = 120,
        LoadRetries = 3,
}

Config.Leaderboard = {
        RefreshInterval = 60,
        Size = 10,
}

--------------------------------------------------------------------
-- WORLD LAYOUT: satu pulau panjang, 6 zona berjajar.
--------------------------------------------------------------------
Config.World = {
        ZoneSpacing = 110, -- jarak antar pusat zona (stud, sumbu Z)
        StartZ = 60, -- pusat zona pertama
        IslandWidth = 90,
        IslandHeight = 3,
}

return Config
