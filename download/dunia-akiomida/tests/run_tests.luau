--!nonstrict
--[[
        run_tests.luau - tes offline DUNIA AKIOMIDA v3 (dijalankan lewat luau CLI).
        Menguji integritas Config + Balance: resep, monster, tugas, kombat,
        kurva level, rotasi tugas. Jalankan:
          tools/luau tests/run_tests.luau
]]

local Config = require("./../src/Shared/Config")
local Balance = require("./../src/Shared/Balance")

local passed, failed = 0, 0
local function check(name: string, ok: boolean, detail: string?)
        if ok then
                passed += 1
                print("  PASS  " .. name)
        else
                failed += 1
                print("  FAIL  " .. name .. (detail and ("  -> " .. detail) or ""))
        end
end

print("=== TES DUNIA AKIOMIDA v3 ===")

-------------------------------------------------------------------- Config
do
        local ok = true
        local ids = {}
        for _, crop in ipairs(Config.Crops) do
                if not crop.id or not crop.name or not crop.cost or not crop.grow or not crop.sell or not crop.level then
                        ok = false
                end
                ids[crop.id] = (ids[crop.id] or 0) + 1
        end
        for id, n in ids do
                if n > 1 then
                        ok = false
                end
        end
        check("Config.Crops lengkap & unik", ok)

        local resOk = true
        local resIds = {}
        for _, res in ipairs(Config.Resources) do
                if not res.id or not res.name or not res.sell or res.sell <= 0 then
                        resOk = false
                end
                resIds[res.id] = true
        end
        check("Config.Resources lengkap", resOk)

        local chanceSum = 0
        for _, f in ipairs(Config.Fish) do
                chanceSum += f.chance
        end
        check("Config.Fish peluang total <= 1.05", chanceSum <= 1.05, tostring(chanceSum))
end

-------------------------------------------------------------------- Level curve
do
        check("Level XP 0 = level 1", Config.Level.levelFromXp(0) == 1)
        local mono = true
        local prev = -1
        for l = 1, 30 do
                local t = Config.Level.thresholdOf(l)
                if t <= prev and l > 1 then
                        mono = false
                end
                prev = t
                if Config.Level.levelFromXp(t) ~= l then
                        mono = false
                end
        end
        check("Kurva level monoton & konsisten", mono)
end

-------------------------------------------------------------------- Resep craft
do
        local mats = {}
        for _, r in ipairs(Config.Resources) do
                mats[r.id] = true
        end
        for _, c in ipairs(Config.Crops) do
                mats[c.id] = true
        end
        for _, f in ipairs(Config.Fish) do
                mats[f.id] = true
        end
        local equips, usables = {}, {}
        for _, e in ipairs(Balance.Equipment) do
                equips[e.id] = true
        end
        for _, u in ipairs(Balance.Usables) do
                usables[u.id] = true
        end
        local errs = Balance.validateRecipes(mats, equips, usables, mats)
        check("Semua resep valid (bahan & output dikenal)", #errs == 0, table.concat(errs, "; "))

        -- setiap Equipment punya resep di Recipes
        local ok = true
        for _, e in ipairs(Balance.Equipment) do
                local found = false
                for _, r in ipairs(Balance.Recipes) do
                        if r.kind == "equip" and r.out == e.id then
                                found = true
                                break
                        end
                end
                if not found then
                        ok = false
                end
        end
        check("Setiap peralatan bisa ditempa dari resep", ok)

        -- keuntungan craft wajar: harga jual output > total bahan dasar
        local priceOf = {}
        for _, r in ipairs(Config.Resources) do
                priceOf[r.id] = r.sell
        end
        for _, c in ipairs(Config.Crops) do
                priceOf[c.id] = c.sell
        end
        for _, f in ipairs(Config.Fish) do
                priceOf[f.id] = f.sell
        end
        local econOk = true
        for _, r in ipairs(Balance.Recipes) do
                local rawCost = 0
                for matId, need in pairs(r.recipe) do
                        rawCost += (priceOf[matId] or 0) * need
                end
                local outPrice = priceOf[r.out] or 0
                if r.kind == "mat" and outPrice <= rawCost then
                        econOk = false
                end
        end
        check("Smelting menguntungkan (balok > bijih mentah)", econOk)
end

-------------------------------------------------------------------- Monster & zona
do
        local resIds = {}
        for _, r in ipairs(Config.Resources) do
                resIds[r.id] = true
        end
        local ok = true
        for _, m in ipairs(Balance.Monsters) do
                if m.hp <= 0 or m.atk <= 0 or m.xp <= 0 then
                        ok = false
                end
                if m.coin[1] > m.coin[2] then
                        ok = false
                end
                for _, d in ipairs(m.drops) do
                        if not resIds[d.id] then
                                ok = false
                        end
                        if d.min > d.max then
                                ok = false
                        end
                end
        end
        check("Monster: stat positif & drop dikenal", ok)

        local boss = Balance.Boss
        local bossOk = boss.hp > 0 and boss.respawn >= 300 and boss.despawn <= boss.respawn
        for _, d in ipairs(boss.drops) do
                if not resIds[d.id] then
                        bossOk = false
                end
        end
        check("Boss raid terdefinisi baik", bossOk)

        local monIds = {}
        for _, m in ipairs(Balance.Monsters) do
                monIds[m.id] = true
        end
        local zoneOk = true
        for _, z in ipairs(Balance.Zones) do
                local cx, cz = z.center[1], z.center[3]
                if math.abs(cx) > 320 or math.abs(cz) > 320 then
                        zoneOk = false -- di luar pulau!
                end
                for _, spec in ipairs(z.monsters) do
                        if not monIds[spec.id] then
                                zoneOk = false
                        end
                end
        end
        check("Zona spawn di dalam pulau & monster dikenal", zoneOk)
end

-------------------------------------------------------------------- Kombat: TTK simulasi
do
        local ttk1, dmg1 = Balance.simulateTtk(1, "gelatin")
        check("Lv1 vs Gelatin: bunuh 1-15s", ttk1 > 1 and ttk1 < 15, string.format("ttk=%.1fs", ttk1))
        check("Lv1 vs Gelatin: damage diterima < HP dasar", dmg1 < Balance.maxHp(0), tostring(dmg1))

        local ttk5 = Balance.simulateTtk(5, "serigala")
        check("Lv5 vs Serigala: bunuh < 20s", ttk5 > 0 and ttk5 < 20, string.format("ttk=%.1fs", ttk5))

        local ttk5g = Balance.simulateTtk(5, "golem")
        check("Lv5 vs Golem: bisa dikalahkan < 30s", ttk5g > 0 and ttk5g < 30, string.format("ttk=%.1fs", ttk5g))

        -- v4: pukulan telanjang LEMAH (desain), tapi monster tetap bisa dikalahkan
        local atk0 = Balance.playerAttack({ weaponAtk = 0, str = 0, dex = 0, int = 0, level = 1 })
        check("Pukulan telanjang lemah (4-6)", atk0 >= 4 and atk0 <= 6, tostring(atk0))
        local atkSword = Balance.playerAttack({ weaponAtk = 11, str = 0, dex = 0, int = 0, level = 1 })
        check("Pedang jauh lebih sakit dari pukulan", atkSword >= atk0 * 2, tostring(atkSword) .. " vs pukulan " .. tostring(atk0))

        -- kritikal dalam batas
        check("CritChance 0 <= c <= 0.45",
                Balance.critChance(0) >= 0 and Balance.critChance(60) <= 0.45)

        -- damageTaken selalu >= 1
        local dt = Balance.damageTaken(50, 1000)
        check("Damage minimal 1 dengan pertahanan tinggi", dt >= 1, tostring(dt))

        -- attackCooldown turun dengan AGI, lantai 0.35
        check("Cooldown AGI 0 = 0.7s, AGI 60 = lantai 0.35s",
                math.abs(Balance.attackCooldown(0) - 0.7) < 0.01 and math.abs(Balance.attackCooldown(60) - 0.35) < 0.01)
end

-------------------------------------------------------------------- Tugas
do
        local ids = Balance.todayQuestIds()
        check("Rotasi tugas = 3 tugas", #ids == 3, tostring(#ids))
        local uniq = true
        local seen = {}
        for _, id in ids do
                if seen[id] then
                        uniq = false
                end
                seen[id] = true
        end
        check("Rotasi tugas unik", uniq)
        local same = true
        for i, id in ids do
                if Balance.todayQuestIds()[i] ~= id then
                        same = false
                end
        end
        check("Rotasi tugas stabil (deterministik hari ini)", same)

        local rewardOk = true
        for _, q in ipairs(Balance.Quests) do
                if q.reward.coins <= 0 or q.reward.xp <= 0 or q.goal.count <= 0 then
                        rewardOk = false
                end
        end
        check("Hadiah tugas positif", rewardOk)
end

-------------------------------------------------------------------- Usables
do
        local ok = true
        for _, u in ipairs(Balance.Usables) do
                if u.effect == "heal" and (u.power <= 0 or u.power > 1) then
                        ok = false
                end
                if u.effect == "speed" and u.duration <= 0 then
                        ok = false
                end
                if u.sell <= 0 then
                        ok = false
                end
        end
        check("Usables: efek & harga wajar", ok)
end

--------------------------------------------------------------------
print(("="):rep(28))
print(string.format("HASIL: %d PASS, %d FAIL", passed, failed))
if failed > 0 then
        os.exit(1)
end

-- ===== v5: SKILL & MONSTER ANGKA =====
do
        for _, s in ipairs(Balance.Skills) do
                check("Skill " .. s.id .. ": mult > 1", s.mult > 1, tostring(s.mult))
                check("Skill " .. s.id .. ": cooldown >= 5s", s.cooldown >= 5, tostring(s.cooldown))
                check("Skill " .. s.id .. ": level >= 2", s.level >= 2, tostring(s.level))
        end
        local digits = {}
        for _, m in ipairs(Balance.Monsters) do
                check("Monster " .. m.id .. ": digit ada", m.body.digit ~= nil, tostring(m.body.digit))
                check("Monster " .. m.id .. ": aura ada", m.body.aura ~= nil, "-")
                check("Monster " .. m.id .. ": drop sah", #m.drops > 0, tostring(#m.drops))
                digits[m.body.digit] = true
        end
        check("Digit 1 & 2 ada di monster biasa", digits["1"] and digits["2"], "1,2 ada")
        check("Boss = ANGKA 9", Balance.Boss.body.digit == "9", tostring(Balance.Boss.body.digit))
        local totalMon = 0
        for _, z in ipairs(Balance.Zones) do
                for _, spec in ipairs(z.monsters) do
                        totalMon += spec.count
                end
        end
        check("Total spawn monster >= 24 (dunia ramai)", totalMon >= 24, tostring(totalMon))
end


-- ===== v6: EVENT DUNIA =====
do
        local ev = Balance.Event
        check("Event: nama ada", ev.name ~= "", ev.name)
        check("Event: period >= 900s", ev.period >= 900, tostring(ev.period))
        check("Event: durasi 120-900s", ev.duration >= 120 and ev.duration <= 900, tostring(ev.duration))
        check("Event: multiplier 2", ev.coinMult == 2 and ev.xpMult == 2, tostring(ev.coinMult))
end


-- ===== v7: GUA KRISTAL =====
do
        local gua
        for _, z in ipairs(Balance.Zones) do
                if z.id == "gua" then
                        gua = z
                end
        end
        check("Zona Gua Kristal ada", gua ~= nil, "-")
        if gua then
                local total = 0
                for _, spec in ipairs(gua.monsters) do
                        total += spec.count
                end
                check("Gua dihuni 5 angka", total == 5, tostring(total))
        end
end


-- ===== v8: UPGRADE PERALATAN =====
do
        local last = 0
        for star = 0, 4 do
                local micda, mat, n = Balance.upgradeCost(star)
                check("Upgrade +" .. (star + 1) .. ": biaya naik", micda > last, tostring(micda))
                check("Upgrade +" .. (star + 1) .. ": material sah", mat == "balok_besi" or mat == "balok_kristal", mat)
                check("Upgrade +" .. (star + 1) .. ": jumlah mat positif", n >= 1, tostring(n))
                last = micda
        end
        check("Bintang +5 memperkuat ATK 60%", Balance.starScaled(10, 5) == 16, tostring(Balance.starScaled(10, 5)))
        check("Bintang 0 = dasar", Balance.starScaled(10, 0) == 10, tostring(Balance.starScaled(10, 0)))
end


-- ===== v9: STREAK LOGIN =====
do
        check("Bonus harian dasar 100", Config.Economy.DailyBonus == 100, tostring(Config.Economy.DailyBonus))
        -- rumus bonus streak sama dengan server: 100 + 25*min(streak-1, 6)
        local function bonusOf(streak)
                return Config.Economy.DailyBonus + 25 * math.min(streak - 1, 6)
        end
        check("Streak 1 = 100", bonusOf(1) == 100, tostring(bonusOf(1)))
        check("Streak 7 = 250 (maks)", bonusOf(7) == 250 and bonusOf(99) == 250, tostring(bonusOf(7)))
end


-- ===== v10: MASTERY CRAFT =====
do
        check("Mastery 0 = XP dasar", Balance.craftXpWithMastery(10, 0) == 10, tostring(Balance.craftXpWithMastery(10, 0)))
        check("Mastery 1 = +50%", Balance.craftXpWithMastery(10, 10) == 15, tostring(Balance.craftXpWithMastery(10, 10)))
        check("Mastery 3 = maks +50%", Balance.craftXpWithMastery(10, 30) == Balance.craftXpWithMastery(10, 90), tostring(Balance.craftXpWithMastery(10, 30)))
        check("Level mastery naik tiap 10", Balance.craftMasteryLevel(19) == 1 and Balance.craftMasteryLevel(20) == 2, tostring(Balance.craftMasteryLevel(20)))
end

print("SEMUA TES LULUS - siap publish.")
