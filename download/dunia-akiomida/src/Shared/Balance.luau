--!nonstrict
--[[
        Balance.luau - DUNIA AKIOMIDA v3 (TORAM-GRADE)
        Semua data kombat, stat, peralatan, resep craft, tugas, boss, dan
        rumus matematika murni - MODUL MURNI (tanpa API Roblox) supaya bisa
        diuji offline lewat luau CLI.
        Seluruh konten karya original Dunia Akiomida (tidak menyalin
        konten pihak ketiga; terinspirasi mekanik genre MMO klasik).
]]

local Balance = {}

--------------------------------------------------------------------
-- STAT KARAKTER (gaya Toram: 5 atribut, poin saat naik level)
--------------------------------------------------------------------
Balance.Stats = {
        { id = "str", name = "Kekuatan", desc = "+2 serangan per poin" },
        { id = "vit", name = "Vitalitas", desc = "+6 HP & +1.2 pertahanan per poin" },
        { id = "agi", name = "Kelincahan", desc = "+0.05 laju lari & serangan lebih cepat" },
        { id = "int", name = "Intelek", desc = "+1.5 serangan sihir & ramuan lebih kuat" },
        { id = "dex", name = "Ketepatan", desc = "+0.6 serangan & peluang kritikal" },
}
Balance.MaxStatPerStat = 60 -- batas tiap atribut supaya build seimbang
Balance.MaxHpBase = 100

--------------------------------------------------------------------
-- PERALATAN TEMPAA (bahan -> senjata/zirah; semua original)
--------------------------------------------------------------------
Balance.Equipment = {
        -- senjata (atk = serangan tambahan) - pedang JAUH lebih sakit dari pukulan
        { id = "pedang_kayu", name = "Pedang Kayu", kind = "weapon", atk = 11, def = 0, level = 1, price = 90,
                recipe = { kayu = 8 }, color = { 150, 108, 66 }, desc = "Pedang pemula dari kayu hutan. Jauh lebih sakit dari pukulan." },
        { id = "pedang_besi", name = "Pedang Besi", kind = "weapon", atk = 24, def = 0, level = 4, price = 320,
                recipe = { kayu = 6, balok_besi = 3 }, color = { 200, 200, 210 }, desc = "Tajam kokoh dari balok besi." },
        { id = "pedang_kristal", name = "Pedang Kristal", kind = "weapon", atk = 42, def = 0, level = 7, price = 950,
                recipe = { balok_besi = 5, kristal = 3 }, color = { 190, 120, 255 }, desc = "Bercahaya ungu, membelah udara." },
        -- zirah (def = pertahanan)
        { id = "zirah_kulit", name = "Zirah Kulit", kind = "armor", atk = 0, def = 8, level = 2, price = 110,
                recipe = { gel = 6, kayu = 4 }, color = { 165, 120, 80 }, desc = "Kulit gelatin yang dikeringkan." },
        { id = "zirah_besi", name = "Zirah Besi", kind = "armor", atk = 0, def = 16, level = 5, price = 380,
                recipe = { taring = 4, balok_besi = 4 }, color = { 150, 155, 170 }, desc = "Lapisan besi penangkal taring." },
        { id = "zirah_kristal", name = "Zirah Kristal", kind = "armor", atk = 0, def = 28, level = 8, price = 1050,
                recipe = { inti = 2, kristal = 5 }, color = { 210, 150, 255 }, desc = "Kristal hidup melindungi pemakainya." },
}

--------------------------------------------------------------------
-- UPGRADE PERALATAN (v8): +1..+5, tiap bintang +12% ATK/DEF
--   Biaya naik kuadrat - sink ekonomi Micda & balok tempaan.
--------------------------------------------------------------------
Balance.MaxStar = 5
Balance.StarBonus = 0.12

-- v10 MASTERY CRAFT: tiap 10x resep sama = MASTER (+50% XP craft resep itu)
Balance.CraftMasterySteps = 10
Balance.CraftMasteryXpMult = 1.5

function Balance.craftMasteryLevel(count: number): number
        return math.floor(math.max(0, count) / Balance.CraftMasterySteps)
end

function Balance.craftXpWithMastery(baseXp: number, count: number): number
        local lvl = Balance.craftMasteryLevel(count)
        return math.floor(baseXp * (1 + (Balance.CraftMasteryXpMult - 1) * math.min(lvl, 3)))
end

--- biaya naik ke bintang (star+1): { micda, mat, matCount }
function Balance.upgradeCost(star: number): (number, string, number)
        if star <= 2 then
                return 150 * (star + 1) * (star + 1), "balok_besi", star + 1
        end
        return 150 * (star + 1) * (star + 1), "balok_kristal", star - 1
end

--- ATK/DEF efektif dengan bintang
function Balance.starScaled(base: number, star: number): number
        return math.floor(base * (1 + Balance.StarBonus * math.clamp(star, 0, Balance.MaxStar)))
end

--------------------------------------------------------------------
-- RESEP STASIUN CRAFT
--   tempa  = perapian besi/kristal + senjata + zirah (anvil Pak Tempa)
--   dapur  = makanan buff & ramuan (api unggun Bu Masak)
--------------------------------------------------------------------
Balance.Recipes = {
        -- tempa: smelting
        { id = "balok_besi", station = "tempa", kind = "mat", out = "balok_besi", count = 1, level = 2,
                recipe = { besi = 3 }, xp = 6 },
        { id = "balok_kristal", station = "tempa", kind = "mat", out = "balok_kristal", count = 1, level = 5,
                recipe = { kristal = 3 }, xp = 14 },
        -- tempa: senjata & zirah (menghasilkan item "equip")
        { id = "pedang_kayu", station = "tempa", kind = "equip", out = "pedang_kayu", count = 1, level = 1,
                recipe = { kayu = 8 }, xp = 10 },
        { id = "pedang_besi", station = "tempa", kind = "equip", out = "pedang_besi", count = 1, level = 4,
                recipe = { kayu = 6, balok_besi = 3 }, xp = 26 },
        { id = "pedang_kristal", station = "tempa", kind = "equip", out = "pedang_kristal", count = 1, level = 7,
                recipe = { balok_besi = 5, kristal = 3 }, xp = 60 },
        { id = "zirah_kulit", station = "tempa", kind = "equip", out = "zirah_kulit", count = 1, level = 2,
                recipe = { gel = 6, kayu = 4 }, xp = 12 },
        { id = "zirah_besi", station = "tempa", kind = "equip", out = "zirah_besi", count = 1, level = 5,
                recipe = { taring = 4, balok_besi = 4 }, xp = 30 },
        { id = "zirah_kristal", station = "tempa", kind = "equip", out = "zirah_kristal", count = 1, level = 8,
                recipe = { inti = 2, kristal = 5 }, xp = 70 },
        -- dapur: makanan buff
        { id = "roti_aktif", station = "dapur", kind = "use", out = "roti_aktif", count = 1, level = 1,
                recipe = { wortel = 2, jagung = 1 }, xp = 5 },
        { id = "sate_ikan", station = "dapur", kind = "use", out = "sate_ikan", count = 1, level = 2,
                recipe = { ikan_kecil = 2 }, xp = 6 },
        { id = "ramuan_hijau", station = "dapur", kind = "use", out = "ramuan_hijau", count = 1, level = 2,
                recipe = { apel = 3 }, xp = 6 },
        { id = "ramuan_inti", station = "dapur", kind = "use", out = "ramuan_inti", count = 1, level = 6,
                recipe = { inti = 1, apel = 2 }, xp = 18 },
}

-- item "use" (makanan/ramuan): efek saat dimakan, harga jual di pasar
Balance.Usables = {
        { id = "roti_aktif", name = "Roti Aktif", sell = 18, effect = "speed", power = 0.12, duration = 300,
                color = { 230, 180, 110 }, desc = "Lari +12% selama 5 menit." },
        { id = "sate_ikan", name = "Sate Ikan", sell = 25, effect = "heal", power = 0.5, duration = 0,
                color = { 255, 190, 120 }, desc = "Pulihkan 50% HP seketika." },
        { id = "ramuan_hijau", name = "Ramuan Hijau", sell = 30, effect = "heal", power = 0.75, duration = 0,
                color = { 120, 220, 140 }, desc = "Pulihkan 75% HP seketika." },
        { id = "ramuan_inti", name = "Ramuan Inti", sell = 80, effect = "heal", power = 1.0, duration = 0,
                color = { 255, 160, 80 }, desc = "Pulihkan seluruh HP seketika." },
}

--------------------------------------------------------------------
-- MONSTER (semua makhluk original Dunia Akiomida)
--------------------------------------------------------------------
-- v4 MAKHLUK ANGKA: setiap monster berwujud ANGKA raksasa dikelilingi AURA
-- (angka = kekuatannya; makin besar angka, makin berbahaya). 100% original.
Balance.Monsters = {
        { id = "gelatin", name = "Angka Satu", hp = 34, atk = 6, def = 0, speed = 10, xp = 9,
                respawn = 35, aggro = 16, coin = { 2, 6 },
                drops = { { id = "gel", chance = 0.65, min = 1, max = 2 } },
                zone = "padang", level = 1,
                body = { color = { 130, 220, 120 }, size = 4.2, digit = "1", aura = { 130, 220, 120 } } },
        { id = "serigala", name = "Angka Dua", hp = 60, atk = 11, def = 2, speed = 17, xp = 16,
                respawn = 45, aggro = 20, coin = { 4, 10 },
                drops = { { id = "taring", chance = 0.55, min = 1, max = 2 }, { id = "gel", chance = 0.15, min = 1, max = 1 } },
                zone = "hutan", level = 3,
                body = { color = { 150, 155, 205 }, size = 5, digit = "2", aura = { 150, 155, 205 } } },
        { id = "golem", name = "Angka Empat", hp = 120, atk = 17, def = 6, speed = 8, xp = 28,
                respawn = 60, aggro = 15, coin = { 8, 18 },
                drops = { { id = "inti", chance = 0.35, min = 1, max = 1 }, { id = "batu", chance = 0.8, min = 2, max = 3 } },
                zone = "tambang", level = 5,
                body = { color = { 255, 170, 90 }, size = 6, digit = "4", aura = { 255, 170, 90 } } },
        { id = "angka_tiga", name = "Angka Tiga", hp = 48, atk = 8, def = 1, speed = 12, xp = 12,
                respawn = 40, aggro = 17, coin = { 3, 8 },
                drops = { { id = "gel", chance = 0.5, min = 1, max = 2 }, { id = "apel", chance = 0.35, min = 1, max = 2 } },
                zone = "padang", level = 2,
                body = { color = { 120, 200, 235 }, size = 4.6, digit = "3", aura = { 120, 200, 235 } } },
        { id = "angka_lima", name = "Angka Lima", hp = 92, atk = 14, def = 3, speed = 15, xp = 20,
                respawn = 50, aggro = 19, coin = { 5, 12 },
                drops = { { id = "taring", chance = 0.5, min = 1, max = 2 }, { id = "kayu", chance = 0.4, min = 1, max = 3 } },
                zone = "hutan", level = 4,
                body = { color = { 225, 130, 200 }, size = 5.4, digit = "5", aura = { 225, 130, 200 } } },
        { id = "angka_enam", name = "Angka Enam", hp = 185, atk = 20, def = 8, speed = 9, xp = 36,
                respawn = 65, aggro = 16, coin = { 10, 22 },
                drops = { { id = "inti", chance = 0.4, min = 1, max = 1 }, { id = "besi", chance = 0.7, min = 1, max = 3 } },
                zone = "tambang", level = 6,
                body = { color = { 160, 230, 150 }, size = 6.5, digit = "6", aura = { 160, 230, 150 } } },
        { id = "angka_delapan", name = "Angka Delapan", hp = 430, atk = 27, def = 6, speed = 8, xp = 95,
                respawn = 110, aggro = 24, coin = { 28, 60 },
                drops = { { id = "kristal", chance = 0.45, min = 1, max = 2 }, { id = "gel", chance = 1.0, min = 3, max = 5 } },
                zone = "arena", level = 9, elite = true,
                body = { color = { 255, 230, 110 }, size = 8, digit = "8", aura = { 255, 230, 110 } } },
        { id = "gelatin_raksasa", name = "Angka Tujuh", hp = 260, atk = 22, def = 4, speed = 7, xp = 70,
                respawn = 90, aggro = 22, coin = { 20, 45 },
                drops = { { id = "gel", chance = 1.0, min = 3, max = 6 }, { id = "inti", chance = 0.2, min = 1, max = 1 } },
                zone = "arena", level = 7, elite = true,
                body = { color = { 90, 200, 220 }, size = 7.5, digit = "7", aura = { 90, 200, 220 } } },
}

-- BOSS RAID: muncul di Arena Timur, semua pemain berburu bersama
Balance.Boss = {
        id = "raja_golem",
        name = "ANGKA SANG RAJA",
        hp = 3200,
        atk = 30,
        def = 10,
        speed = 9,
        aggro = 55,
        respawn = 900, -- tiap 15 menit muncul lagi
        despawn = 420, -- 7 menit tanpa dibunuh, pergi
        xp = 220,
        coin = { 150, 320 },
        drops = { { id = "inti", chance = 1, min = 3, max = 5 }, { id = "kristal", chance = 1, min = 2, max = 4 } },
        body = { color = { 255, 110, 60 }, size = 11, digit = "9", aura = { 255, 110, 60 } },
        -- hadiah partisipasi dibagi proporsional damage
        participationCoin = 40,
        participationXp = 30,
        topBonusCoin = 150,
}

--------------------------------------------------------------------
-- EVENT DUNIA TERJADWAL (v6): "PESTA PANEN" - momen multiplayer rame
--   Setiap PERIOD detik, selama DURATION detik semua monster & panen
--   memberi Micda/XP ganda - server mengumumkan agar pemain berkumpul.
--------------------------------------------------------------------
Balance.Event = {
        name = "PESTA PANEN",
        period = 1800, -- tiap 30 menit
        duration = 300, -- berlangsung 5 menit
        coinMult = 2,
        xpMult = 2,
}

--------------------------------------------------------------------
-- SKILL SENJATA (v5): aktif, cooldown, butuh pedang. Server-validated.
--------------------------------------------------------------------
Balance.Skills = {
        { id = "tebasan_kuat", name = "Tebasan Kuat", mult = 2.2, cooldown = 8, level = 2,
                desc = "Tebasan 220% ke angka terdekat. Butuh pedang." },
        { id = "sabetan_putar", name = "Sabetan Putar", mult = 1.5, cooldown = 15, level = 5, aoe = true,
                desc = "Putaran 150% ke SEMUA angka di sekitar. Butuh pedang." },
}

--------------------------------------------------------------------
-- ZONA SPAWN MONSTER (dipakai CombatService + MapService dekorasi)
--------------------------------------------------------------------
-- HARGA LAHAN (syariah: bayar penuh di muka, TANPA bunga/cicilan/riba).
-- Ladang 1 gratis untuk semua pemain; ladang lain dibeli dengan MICDA.
Balance.LandPrices = { [2] = 400, [3] = 1200, [4] = 3000, [5] = 8000, [6] = 20000 }

Balance.Zones = {
        { id = "padang", name = "Padang Timur", center = { 62, 0, 26 }, radius = 44,
                monsters = { { id = "gelatin", count = 5 }, { id = "angka_tiga", count = 3 } } },
        { id = "hutan", name = "Hutan Kayu", center = { -122, 0, -8 }, radius = 40,
                monsters = { { id = "serigala", count = 4 }, { id = "angka_lima", count = 3 } } },
        { id = "tambang", name = "Tambang Selatan", center = { 0, 0, 136 }, radius = 36,
                monsters = { { id = "golem", count = 3 }, { id = "angka_enam", count = 3 } } },
        { id = "arena", name = "Arena Timur", center = { 150, 0, 92 }, radius = 38,
                monsters = { { id = "gelatin_raksasa", count = 2 }, { id = "angka_delapan", count = 2 } } },
        { id = "gua", name = "Gua Kristal", center = { -170, 0, -175 }, radius = 30,
                monsters = { { id = "angka_delapan", count = 3 }, { id = "angka_enam", count = 2 } } },
}

--------------------------------------------------------------------
-- TUGAS (papan tugas; rotasi harian deterministik)
--------------------------------------------------------------------
Balance.Quests = {
        { id = "panen5", title = "Panen Raya", goal = { type = "harvest", count = 5 }, reward = { coins = 120, xp = 40 },
                desc = "Panen 5 tanaman apa pun di ladangmu." },
        { id = "tebang6", title = "Bantuan Tukang Kayu", goal = { type = "chop", count = 6 }, reward = { coins = 100, xp = 35 },
                desc = "Tebang 6 pohon di Hutan Kayu." },
        { id = "tambang8", title = "Kiriman Pak Bang", goal = { type = "mine", count = 8 }, reward = { coins = 140, xp = 45 },
                desc = "Tambang 8 bijih batu/besi/kristal." },
        { id = "mancing5", title = "Pesanan Bu Laris", goal = { type = "fish", count = 5 }, reward = { coins = 130, xp = 40 },
                desc = "Pancing 5 ikan di Danau Tenang." },
        { id = "kalah5", title = "Patroli Padang", goal = { type = "kill", count = 5 }, reward = { coins = 160, xp = 50 },
                desc = "Kalahkan 5 monster mana pun." },
        { id = "tempa1", title = "Praktik Pak Tempa", goal = { type = "craft", count = 1 }, reward = { coins = 180, xp = 55 },
                desc = "Tempa 1 peralatan atau balok di Pandai Besi." },
        { id = "masak2", title = "Katering Bu Masak", goal = { type = "cook", count = 2 }, reward = { coins = 150, xp = 45 },
                desc = "Masak 2 makanan/ramuan di Api Unggun." },
}
Balance.QuestsPerDay = 3 -- jumlah tugas yang ditawarkan tiap hari (rotasi)

--- Rotasi harian deterministik (sama di server & client): pilih
--- QuestsPerDay tugas dari kolam berdasarkan hash hari ini.
function Balance.todayQuestIds(): { string }
        local day = math.floor(os.time() / 86400)
        local pool = {}
        for _, q in ipairs(Balance.Quests) do
                table.insert(pool, q.id)
        end
        local function hashString(s: string): number
                local h = 0
                for i = 1, #s do
                        h = (h * 31 + string.byte(s, i)) % 1000000007
                end
                return h
        end
        local picked: { string } = {}
        local start = day % #pool
        for i = 1, Balance.QuestsPerDay do
                local idx = ((start + (hashString("akm" .. day) + i * 7) % #pool)) % #pool
                local id = pool[idx + 1]
                local dup = false
                for _, p in picked do
                        if p == id then
                                dup = true
                                break
                        end
                end
                if not dup then
                        table.insert(picked, id)
                end
        end
        -- fallback: kalau kurang (tabrakan duplikat), isi berurutan
        for _, id in pool do
                if #picked >= Balance.QuestsPerDay then
                        break
                end
                local dup = false
                for _, p in picked do
                        if p == id then
                                dup = true
                                break
                        end
                end
                if not dup then
                        table.insert(picked, id)
                end
        end
        return picked
end

--------------------------------------------------------------------
-- RUMUS KOMBAT (murni - diuji offline)
--------------------------------------------------------------------

--- Serangan pemain: senjata + STR + DEX + level (Toram-like scaling).
--- PUKULAN TELANJANG (tanpa senjata) lemah: total dikali FIST_MULT.
Balance.FistMult = 0.45

function Balance.playerAttack(args: { weaponAtk: number, str: number, dex: number, int: number, level: number }): number
        local total = 5 + (args.weaponAtk or 0) + args.str * 2 + args.dex * 0.6 + args.int * 1.5 + args.level * 1.2
        if (args.weaponAtk or 0) <= 0 then
                total = 5 + (total - 5) * Balance.FistMult
        end
        return math.floor(total)
end

--- Peluang kritikal (DEX membantu), maksimum 45%
function Balance.critChance(dex: number): number
        return math.clamp(0.04 + dex * 0.006, 0, 0.45)
end

Balance.CritMult = 1.6

--- Total pertahanan: zirah + VIT
function Balance.playerDefense(armorDef: number, vit: number): number
        return (armorDef or 0) + vit * 1.2
end

--- Damage yang diterima pemain dengan kurva pelunakan (soft cap)
function Balance.damageTaken(rawAtk: number, defense: number): number
        local mult = defense / (defense + 60)
        return math.max(1, math.floor(rawAtk * (1 - mult) + 0.5))
end

--- HP maksimum: dasar + VIT
function Balance.maxHp(vit: number): number
        return Balance.MaxHpBase + vit * 6
end

--- Laju lari: dasar + AGI (dibatasi), bike ditangani pemanggil
function Balance.walkSpeed(agi: number): number
        return math.min(16 + agi * 0.05, 19)
end

--- Jeda serangan pemain (detik): AGI mempercepat, minimal 0.35
function Balance.attackCooldown(agi: number): number
        return math.max(0.35, 0.7 - agi * 0.008)
end

--------------------------------------------------------------------
-- VALIDASI & KONSISTENSI (dipanggil test offline)
--------------------------------------------------------------------

--- Pastikan semua resep merujuk bahan yang ada & output terdaftar.
--- materials: set id sumber daya/crop/ikan yang sah. Return list kesalahan.
function Balance.validateRecipes(materials: { [string]: boolean }, equips: { [string]: boolean },
                usables: { [string]: boolean }, resources: { [string]: boolean }): { string }
        local errs = {}
        for _, r in ipairs(Balance.Recipes) do
                for matId in pairs(r.recipe) do
                        if not materials[matId] then
                                table.insert(errs, "recipe " .. r.id .. ": bahan tidak dikenal '" .. matId .. "'")
                        end
                end
                if r.kind == "equip" and not equips[r.out] then
                        table.insert(errs, "recipe " .. r.id .. ": output equip tidak dikenal '" .. r.out .. "'")
                end
                if r.kind == "use" and not usables[r.out] then
                        table.insert(errs, "recipe " .. r.id .. ": output usable tidak dikenal '" .. r.out .. "'")
                end
                if r.kind == "mat" and not resources[r.out] then
                        table.insert(errs, "recipe " .. r.id .. ": output material tidak dikenal '" .. r.out .. "'")
                end
        end
        return errs
end

--- Kurva kekuatan: simulasi waktu-bunuh monster oleh pemain level L.
--- Dipakai untuk cek keseimbangan (TTK wajar: tidak instan, tidak lama).
function Balance.simulateTtk(level: number, monsterId: string, statSpread: string?): (number, number)
        local spread = statSpread or "balanced"
        local str, dex, vit, agi, int = 0, 0, 0, 0, 0
        local points = (level - 1) * 2
        if spread == "balanced" then
                str = math.floor(points * 0.35)
                dex = math.floor(points * 0.25)
                vit = math.floor(points * 0.25)
                agi = points - str - dex - vit
        elseif spread == "attacker" then
                str = math.floor(points * 0.7)
                dex = math.floor(points * 0.3)
        else
                vit = math.floor(points * 0.7)
                agi = points - vit
        end
        local atk = Balance.playerAttack({ weaponAtk = 14, str = str, dex = dex, int = int, level = level })
        local crit = Balance.critChance(dex)
        local dps = atk * (1 + crit * (Balance.CritMult - 1)) / Balance.attackCooldown(agi)
        local mon = nil
        for _, m in ipairs(Balance.Monsters) do
                if m.id == monsterId then
                        mon = m
                        break
                end
        end
        if not mon then
                return -1, -1
        end
        local ttk = mon.hp / math.max(1, dps)
        -- berapa damage pemain terima sebelum monster mati
        local def = Balance.playerDefense(8, vit)
        local hits = math.ceil(ttk / 1.5) -- monster menyerang tiap ~1.5s
        return ttk, Balance.damageTaken(mon.atk, def) * hits
end

return Balance
