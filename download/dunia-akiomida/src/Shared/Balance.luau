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
        -- senjata (atk = serangan tambahan)
        { id = "pedang_kayu", name = "Pedang Kayu", kind = "weapon", atk = 6, def = 0, level = 1, price = 90,
                recipe = { kayu = 8 }, color = { 150, 108, 66 }, desc = "Pedang pemula dari kayu hutan." },
        { id = "pedang_besi", name = "Pedang Besi", kind = "weapon", atk = 14, def = 0, level = 4, price = 320,
                recipe = { kayu = 6, balok_besi = 3 }, color = { 200, 200, 210 }, desc = "Tajam kokoh dari balok besi." },
        { id = "pedang_kristal", name = "Pedang Kristal", kind = "weapon", atk = 26, def = 0, level = 7, price = 950,
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
Balance.Monsters = {
        { id = "gelatin", name = "Gelatin Hijau", hp = 34, atk = 6, def = 0, speed = 10, xp = 9,
                respawn = 35, aggro = 16, coin = { 2, 6 },
                drops = { { id = "gel", chance = 0.65, min = 1, max = 2 } },
                zone = "padang", level = 1,
                body = { color = { 130, 220, 120 }, size = 4.2, shape = "ball" } },
        { id = "serigala", name = "Serigala Bayang", hp = 60, atk = 11, def = 2, speed = 17, xp = 16,
                respawn = 45, aggro = 20, coin = { 4, 10 },
                drops = { { id = "taring", chance = 0.55, min = 1, max = 2 }, { id = "gel", chance = 0.15, min = 1, max = 1 } },
                zone = "hutan", level = 3,
                body = { color = { 90, 92, 120 }, size = 3.4, shape = "box" } },
        { id = "golem", name = "Golem Batu", hp = 120, atk = 17, def = 6, speed = 8, xp = 28,
                respawn = 60, aggro = 15, coin = { 8, 18 },
                drops = { { id = "inti", chance = 0.35, min = 1, max = 1 }, { id = "batu", chance = 0.8, min = 2, max = 3 } },
                zone = "tambang", level = 5,
                body = { color = { 120, 120, 128 }, size = 5.5, shape = "box" } },
        { id = "gelatin_raksasa", name = "Gelatin Raksasa", hp = 260, atk = 22, def = 4, speed = 7, xp = 70,
                respawn = 90, aggro = 22, coin = { 20, 45 },
                drops = { { id = "gel", chance = 1.0, min = 3, max = 6 }, { id = "inti", chance = 0.2, min = 1, max = 1 } },
                zone = "arena", level = 7, elite = true,
                body = { color = { 90, 200, 220 }, size = 8, shape = "ball" } },
}

-- BOSS RAID: muncul di Arena Timur, semua pemain berburu bersama
Balance.Boss = {
        id = "raja_golem",
        name = "RAJA GOLEM",
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
        body = { color = { 100, 100, 115 }, size = 11, shape = "box" },
        -- hadiah partisipasi dibagi proporsional damage
        participationCoin = 40,
        participationXp = 30,
        topBonusCoin = 150,
}

--------------------------------------------------------------------
-- ZONA SPAWN MONSTER (dipakai CombatService + MapService dekorasi)
--------------------------------------------------------------------
Balance.Zones = {
        { id = "padang", name = "Padang Timur", center = { 62, 0, 26 }, radius = 44, monsters = { { id = "gelatin", count = 6 } } },
        { id = "hutan", name = "Hutan Kayu", center = { -122, 0, -8 }, radius = 40, monsters = { { id = "serigala", count = 5 } } },
        { id = "tambang", name = "Tambang Selatan", center = { 0, 0, 136 }, radius = 36, monsters = { { id = "golem", count = 4 } } },
        { id = "arena", name = "Arena Timur", center = { 150, 0, 92 }, radius = 38, monsters = { { id = "gelatin_raksasa", count = 2 } } },
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

--- Serangan pemain: senjata + STR + DEX + level (Toram-like scaling)
function Balance.playerAttack(args: { weaponAtk: number, str: number, dex: number, int: number, level: number }): number
        return math.floor(5 + (args.weaponAtk or 0) + args.str * 2 + args.dex * 0.6 + args.int * 1.5 + args.level * 1.2)
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
