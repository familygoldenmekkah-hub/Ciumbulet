local Balance = {}

Balance.Stats = {
        { id = "str", name = "Kekuatan", desc = "+2 serangan per poin" },
        { id = "vit", name = "Vitalitas", desc = "+6 HP & +1.2 pertahanan per poin" },
        { id = "agi", name = "Kelincahan", desc = "+0.05 laju lari & serangan lebih cepat" },
        { id = "int", name = "Intelek", desc = "+1.5 serangan sihir & ramuan lebih kuat" },
        { id = "dex", name = "Ketepatan", desc = "+0.6 serangan & peluang kritikal" },
}
Balance.MaxStatPerStat = 60
Balance.MaxHpBase = 100

Balance.Equipment = {

        { id = "pedang_kayu", name = "Pedang Kayu", kind = "weapon", atk = 11, def = 0, level = 1, price = 90,
                recipe = { gel = 10 }, color = { 150, 108, 66 }, desc = "Pedang pemula dari kayu hutan. Jauh lebih sakit dari pukulan." },
        { id = "pedang_besi", name = "Pedang Besi", kind = "weapon", atk = 24, def = 0, level = 4, price = 320,
                recipe = { gel = 6, balok_besi = 3 }, color = { 200, 200, 210 }, desc = "Tajam kokoh dari balok besi." },
        { id = "pedang_kristal", name = "Pedang Kristal", kind = "weapon", atk = 42, def = 0, level = 7, price = 950,
                recipe = { balok_besi = 5, kristal = 3 }, color = { 190, 120, 255 }, desc = "Bercahaya ungu, membelah udara." },

        { id = "zirah_kulit", name = "Zirah Kulit", kind = "armor", atk = 0, def = 8, level = 2, price = 110,
                recipe = { taring = 5, gel = 5 }, color = { 165, 120, 80 }, desc = "Kulit gelatin yang dikeringkan." },
        { id = "zirah_besi", name = "Zirah Besi", kind = "armor", atk = 0, def = 16, level = 5, price = 380,
                recipe = { taring = 4, balok_besi = 4 }, color = { 150, 155, 170 }, desc = "Lapisan besi penangkal taring." },
        { id = "zirah_kristal", name = "Zirah Kristal", kind = "armor", atk = 0, def = 28, level = 8, price = 1050,
                recipe = { inti = 2, kristal = 5 }, color = { 210, 150, 255 }, desc = "Kristal hidup melindungi pemakainya." },
}

Balance.MaxStar = 5
Balance.StarBonus = 0.12

Balance.CraftMasterySteps = 10
Balance.CraftMasteryXpMult = 1.5

function Balance.craftMasteryLevel(count: number): number
        return math.floor(math.max(0, count) / Balance.CraftMasterySteps)
end

function Balance.craftXpWithMastery(baseXp: number, count: number): number
        local lvl = Balance.craftMasteryLevel(count)
        return math.floor(baseXp * (1 + (Balance.CraftMasteryXpMult - 1) * math.min(lvl, 3)))
end

function Balance.upgradeCost(star: number): (number, string, number)
        if star <= 2 then
                return 150 * (star + 1) * (star + 1), "balok_besi", star + 1
        end
        return 150 * (star + 1) * (star + 1), "balok_kristal", star - 1
end

function Balance.starScaled(base: number, star: number): number
        return math.floor(base * (1 + Balance.StarBonus * math.clamp(star, 0, Balance.MaxStar)))
end

Balance.Recipes = {

        { id = "balok_besi", station = "tempa", kind = "mat", out = "balok_besi", count = 1, level = 2,
                recipe = { besi = 3 }, xp = 6 },
        { id = "balok_kristal", station = "tempa", kind = "mat", out = "balok_kristal", count = 1, level = 5,
                recipe = { kristal = 3 }, xp = 14 },

        { id = "pedang_kayu", station = "tempa", kind = "equip", out = "pedang_kayu", count = 1, level = 1,
                recipe = { gel = 10 }, xp = 10 },
        { id = "pedang_besi", station = "tempa", kind = "equip", out = "pedang_besi", count = 1, level = 4,
                recipe = { gel = 6, balok_besi = 3 }, xp = 26 },
        { id = "pedang_kristal", station = "tempa", kind = "equip", out = "pedang_kristal", count = 1, level = 7,
                recipe = { balok_besi = 5, kristal = 3 }, xp = 60 },
        { id = "zirah_kulit", station = "tempa", kind = "equip", out = "zirah_kulit", count = 1, level = 2,
                recipe = { taring = 5, gel = 5 }, xp = 12 },
        { id = "zirah_besi", station = "tempa", kind = "equip", out = "zirah_besi", count = 1, level = 5,
                recipe = { taring = 4, balok_besi = 4 }, xp = 30 },
        { id = "zirah_kristal", station = "tempa", kind = "equip", out = "zirah_kristal", count = 1, level = 8,
                recipe = { inti = 2, kristal = 5 }, xp = 70 },

        { id = "roti_aktif", station = "dapur", kind = "use", out = "roti_aktif", count = 1, level = 1,
                recipe = { wortel = 3 }, xp = 5 },
        { id = "sate_ikan", station = "dapur", kind = "use", out = "sate_ikan", count = 1, level = 2,
                recipe = { ikan_kecil = 2 }, xp = 6 },
        { id = "ramuan_hijau", station = "dapur", kind = "use", out = "ramuan_hijau", count = 1, level = 2,
                recipe = { jamur = 3 }, xp = 6 },
        { id = "ramuan_inti", station = "dapur", kind = "use", out = "ramuan_inti", count = 1, level = 6,
                recipe = { inti = 1, jamur = 2 }, xp = 18 },
}

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
                drops = { { id = "inti", chance = 0.35, min = 1, max = 1 }, { id = "besi", chance = 0.8, min = 2, max = 3 } },
                zone = "tambang", level = 5,
                body = { color = { 255, 170, 90 }, size = 6, digit = "4", aura = { 255, 170, 90 } } },
        { id = "angka_tiga", name = "Angka Tiga", hp = 48, atk = 8, def = 1, speed = 12, xp = 12,
                respawn = 40, aggro = 17, coin = { 3, 8 },
                drops = { { id = "gel", chance = 0.5, min = 1, max = 2 }, { id = "taring", chance = 0.35, min = 1, max = 2 } },
                zone = "padang", level = 2,
                body = { color = { 120, 200, 235 }, size = 4.6, digit = "3", aura = { 120, 200, 235 } } },
        { id = "angka_lima", name = "Angka Lima", hp = 92, atk = 14, def = 3, speed = 15, xp = 20,
                respawn = 50, aggro = 19, coin = { 5, 12 },
                drops = { { id = "taring", chance = 0.5, min = 1, max = 2 }, { id = "gel", chance = 0.4, min = 1, max = 3 } },
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

Balance.Boss = {
        id = "raja_golem",
        name = "ANGKA SANG RAJA",
        hp = 3200,
        atk = 30,
        def = 10,
        speed = 9,
        aggro = 55,
        respawn = 900,
        despawn = 420,
        xp = 220,
        coin = { 150, 320 },
        drops = { { id = "inti", chance = 1, min = 3, max = 5 }, { id = "kristal", chance = 1, min = 2, max = 4 } },
        body = { color = { 255, 110, 60 }, size = 11, digit = "9", aura = { 255, 110, 60 } },

        participationCoin = 40,
        participationXp = 30,
        topBonusCoin = 150,

        enrageAt = 0.5,
        enrageSpeed = 1.35,
        enrageAtk = 1.3,
        enrageAura = { 255, 60, 50 },
}

Balance.Skills = {
        { id = "tebasan_kuat", name = "Tebasan Kuat", mult = 2.2, cooldown = 8, level = 2,
                desc = "Tebasan 220% ke angka terdekat. Butuh pedang." },
        { id = "sabetan_putar", name = "Sabetan Putar", mult = 1.5, cooldown = 15, level = 5, aoe = true,
                desc = "Putaran 150% ke SEMUA angka di sekitar. Butuh pedang." },
        { id = "tusukan_kilat", name = "Tusukan Kilat", mult = 3.0, cooldown = 14, level = 8,
                desc = "Tusukan kilat 300% ke angka terdekat. Butuh pedang." },
}

Balance.Zones = {
        { id = "padang", name = "Padang Liar", center = { 640, 0, -320 }, radius = 95,
                monsters = { { id = "gelatin", count = 4 }, { id = "angka_tiga", count = 3 }, { id = "serigala", count = 2 } } },
        { id = "hutan", name = "Hutan Bayang", center = { 640, 0, 60 }, radius = 95,
                monsters = { { id = "serigala", count = 3 }, { id = "angka_lima", count = 3 } } },
        { id = "tambang", name = "Tambang Baja", center = { 605, 0, 430 }, radius = 65,
                monsters = { { id = "golem", count = 3 }, { id = "angka_enam", count = 3 } } },
        { id = "gua", name = "Gua Kristal", center = { 920, 0, 430 }, radius = 55,
                monsters = { { id = "angka_delapan", count = 3 }, { id = "angka_enam", count = 2 } } },
        { id = "arena", name = "Arena", center = { 760, 0, 650 }, radius = 70,
                monsters = { { id = "gelatin_raksasa", count = 2 }, { id = "angka_delapan", count = 2 } } },
}

Balance.HOME_COUNT = 10
Balance.HOME_COLS = { -700, -380 }
Balance.HOME_Z0 = -440
Balance.HOME_GAP = 260
Balance.HOME_HALF = { 105, 95 }

Balance.Regions = {
        { id = "pusat", name = "Pusat Kota", kind = "hub", center = { 0, 0 }, half = { 170, 150 },
                gates = {
                        { dest = "home", pos = { 0, 132 } },
                        { dest = "padang", pos = { 152, -60 } },
                        { dest = "hutan", pos = { 152, 40 } },
                        { dest = "baja", pos = { 152, 130 } },
                } },
        { id = "padang", name = "Padang Liar", kind = "combat", center = { 640, -320 }, half = { 130, 130 },
                gates = { { dest = "pusat", pos = { 516, -320 } } } },
        { id = "hutan", name = "Hutan Bayang", kind = "combat", center = { 640, 60 }, half = { 130, 130 },
                gates = { { dest = "pusat", pos = { 516, 60 } } } },
        { id = "baja", name = "Negeri Baja & Kristal", kind = "combat", center = { 760, 560 }, half = { 240, 210 },
                gates = { { dest = "pusat", pos = { 528, 560 } } } },
}

function Balance.homeCenter(index: number): (number, number)
        if index < 1 or index > Balance.HOME_COUNT then
                return 0, 0
        end
        local col = (index - 1) % 2
        local row = math.floor((index - 1) / 2)
        return Balance.HOME_COLS[col + 1], Balance.HOME_Z0 + row * Balance.HOME_GAP
end

for hi = 1, Balance.HOME_COUNT do
        local hx, hz = Balance.homeCenter(hi)
        table.insert(Balance.Regions, {
                id = "rumah" .. hi, name = "Lahan " .. hi, kind = "home",
                center = { hx, hz }, half = { Balance.HOME_HALF[1], Balance.HOME_HALF[2] },
                gates = { { dest = "pusat", pos = { hx + Balance.HOME_HALF[1] - 5, hz } } },
        })
end

function Balance.landSpawn(index: number): (number, number)
        local hx, hz = Balance.homeCenter(index)
        return hx + 84, hz + 10
end

function Balance.nextFreeHome(taken: { [number]: boolean }): number
        for i = 1, Balance.HOME_COUNT do
                if not taken[i] then
                        return i
                end
        end
        return 0
end

Balance.KOPERASI_PREFIX = "akiomida"
local KOPERASI_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"

function Balance.koperasiName(rng: Random?): string
        local r = rng or Random.new()
        local code = table.create(8)
        for i = 1, 8 do
                local n = r:NextInteger(1, #KOPERASI_CHARS)
                code[i] = string.sub(KOPERASI_CHARS, n, n)
        end
        return Balance.KOPERASI_PREFIX .. table.concat(code)
end

function Balance.sanitizeLandName(text: any): string?
        if type(text) ~= "string" then
                return nil
        end
        local cleaned = string.gsub(text, "%s+", " ")
        cleaned = string.gsub(cleaned, "^%s+", ""):gsub("%s+$", "")
        if #cleaned < 3 or #cleaned > 20 then
                return nil
        end
        if not string.match(cleaned, "^[A-Za-z0-9 _.'%-]+$") then
                return nil
        end
        return cleaned
end

function Balance.regionById(id: string)
        for _, r in ipairs(Balance.Regions) do
                if r.id == id then
                        return r
                end
        end
        return nil
end

function Balance.gateArrival(regionId: string, fromRegionId: string): (number?, number?)
        local region = Balance.regionById(regionId)
        if not region then
                return nil, nil
        end
        for _, g in ipairs(region.gates) do
                local match = g.dest == fromRegionId
                        or (g.dest == "home" and string.sub(fromRegionId, 1, 5) == "rumah")
                if match then
                        local dx = region.center[1] - g.pos[1]
                        local dz = region.center[2] - g.pos[2]
                        local len = math.sqrt(dx * dx + dz * dz)
                        if len < 1 then
                                return g.pos[1], g.pos[2]
                        end
                        return g.pos[1] + dx / len * 13, g.pos[2] + dz / len * 13
                end
        end
        return nil, nil
end

function Balance.rectsOverlap(c1: { number }, h1: { number }, c2: { number }, h2: { number }, margin: number): boolean
        return math.abs(c1[1] - c2[1]) < h1[1] + h2[1] + margin
                and math.abs(c1[2] - c2[2]) < h1[2] + h2[2] + margin
end

function Balance.validateRegions(): { string }
        local errs = {}
        local ids = {}
        for _, r in ipairs(Balance.Regions) do
                if ids[r.id] then
                        table.insert(errs, "region duplikat: " .. r.id)
                end
                ids[r.id] = true
        end
        for _, r in ipairs(Balance.Regions) do
                for _, g in ipairs(r.gates) do
                        if g.dest ~= "home" and not ids[g.dest] then
                                table.insert(errs, "gerbang " .. r.id .. " menunjuk wilayah tak dikenal: " .. tostring(g.dest))
                        end
                        if math.abs(g.pos[1] - r.center[1]) > r.half[1] - 4
                                or math.abs(g.pos[2] - r.center[2]) > r.half[2] - 4 then
                                table.insert(errs, "gerbang " .. r.id .. " keluar batas pulau")
                        end
                end
        end
        for _, zone in ipairs(Balance.Zones) do
                local island
                for _, r in ipairs(Balance.Regions) do
                        if r.kind == "combat" and Balance.rectsOverlap(
                                { zone.center[1], zone.center[3] }, { zone.radius, zone.radius },
                                r.center, r.half, 0) then
                                island = r
                                break
                        end
                end
                if not island then
                        table.insert(errs, "zona monster '" .. zone.id .. "' tidak berada di pulau combat mana pun")
                else
                        if math.abs(zone.center[1] - island.center[1]) + zone.radius > island.half[1] - 10
                                or math.abs(zone.center[3] - island.center[2]) + zone.radius > island.half[2] - 10 then
                                table.insert(errs, "zona monster '" .. zone.id .. "' menjulur keluar pulau " .. island.id)
                        end
                end
                for _, r in ipairs(Balance.Regions) do
                        if r.kind ~= "combat" and Balance.rectsOverlap(
                                { zone.center[1], zone.center[3] }, { zone.radius, zone.radius },
                                r.center, r.half, 12) then
                                table.insert(errs, "zona monster '" .. zone.id .. "' menembus wilayah " .. r.kind .. " '" .. r.id .. "'")
                        end
                end
        end
        for _, m in ipairs(Balance.Monsters) do
                local ok = false
                for _, z in ipairs(Balance.Zones) do
                        if z.id == m.zone then
                                ok = true
                                break
                        end
                end
                if not ok then
                        table.insert(errs, "monster '" .. m.id .. "' zona tidak dikenal: " .. tostring(m.zone))
                end
        end
        return errs
end

Balance.FistMult = 0.45

function Balance.playerAttack(args: { weaponAtk: number, str: number, dex: number, int: number, level: number }): number
        local total = 5 + (args.weaponAtk or 0) + args.str * 2 + args.dex * 0.6 + args.int * 1.5 + args.level * 1.2
        if (args.weaponAtk or 0) <= 0 then
                total = 5 + (total - 5) * Balance.FistMult
        end
        return math.floor(total)
end

function Balance.critChance(dex: number): number
        return math.clamp(0.04 + dex * 0.006, 0, 0.45)
end

Balance.CritMult = 1.6

function Balance.playerDefense(armorDef: number, vit: number): number
        return (armorDef or 0) + vit * 1.2
end

function Balance.damageTaken(rawAtk: number, defense: number): number
        local mult = defense / (defense + 60)
        return math.max(1, math.floor(rawAtk * (1 - mult) + 0.5))
end

function Balance.maxHp(vit: number): number
        return Balance.MaxHpBase + vit * 6
end

function Balance.walkSpeed(agi: number): number
        return math.min(16 + agi * 0.05, 19)
end

function Balance.attackCooldown(agi: number): number
        return math.max(0.35, 0.7 - agi * 0.008)
end

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

        local def = Balance.playerDefense(8, vit)
        local hits = math.ceil(ttk / 1.5)
        return ttk, Balance.damageTaken(mon.atk, def) * hits
end

return Balance
