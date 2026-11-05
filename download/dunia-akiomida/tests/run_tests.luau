local Config = require("./../src/Shared/Config")
local Balance = require("./../src/Shared/Balance")
local CropConfig = require("./../src/Shared/CropConfig")
local TasLogic = require("./../src/Shared/TasLogic")

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

print("=== TES DUNIA AKIOMIDA v7 - PANEN BARU ===")

print("--- Ekonomi dasar ---")
do
        check("Dana awal pemain = 900.000 Micda", Config.Economy.StartCoins == 900000,
                tostring(Config.Economy.StartCoins))
        check("Bonus login tetap ada", Config.Economy.DailyBonus > 0, "-")
        for _, res in ipairs(Config.Resources) do
                check("Bahan " .. res.id .. " punya harga jual", res.sell > 0, tostring(res.sell))
        end
        for _, f in ipairs(Config.Fish) do
                check("Ikan " .. f.id .. " harga & peluang sah", f.sell > 0 and f.chance > 0, "-")
        end
end

print("--- CropConfig: 34 tanaman ---")
do
        check("Jumlah tanaman = 34", #CropConfig.Crops == 34, tostring(#CropConfig.Crops))
        local ids, rarityCount = {}, { common = 0, rare = 0, epic = 0 }
        local unique = true
        for _, crop in ipairs(CropConfig.Crops) do
                if ids[crop.id] then
                        unique = false
                end
                ids[crop.id] = true
                rarityCount[crop.rarity] = (rarityCount[crop.rarity] or 0) + 1
                check("Tanaman " .. crop.id .. " harga jual > 0", crop.sell > 0, tostring(crop.sell))
                check("Tanaman " .. crop.id .. " warna lengkap", crop.color ~= nil and #crop.color == 3, "-")
        end
        check("ID tanaman unik", unique, "-")
        check("Common = 12", rarityCount.common == 12, tostring(rarityCount.common))
        check("Rare = 14", rarityCount.rare == 14, tostring(rarityCount.rare))
        check("Epic = 8", rarityCount.epic == 8, tostring(rarityCount.epic))
        check("Waktu tumbuh = 3 detik", CropConfig.GrowTime == 3, tostring(CropConfig.GrowTime))
        check("Panen 1-4", CropConfig.YieldMin == 1 and CropConfig.YieldMax == 4, "-")
        local w = CropConfig.byId("wortel")
        check("byId wortel = 5 Micda", w ~= nil and w.sell == 5, tostring(w and w.sell))
        check("Harga sesuai daftar pemilik", CropConfig.byId("ceri").sell == 438
                and CropConfig.byId("sorgum").sell == 88
                and CropConfig.byId("tetsukabuto").sell == 375
                and CropConfig.byId("jamur").sell == 30, "-")
end

print("--- CropConfig: resep gabung (8) ---")
do
        check("Jumlah resep gabung = 8", #CropConfig.Recipes == 8, tostring(#CropConfig.Recipes))
        for _, recipe in ipairs(CropConfig.Recipes) do
                local a = CropConfig.byId(recipe.inputs[1])
                local b = CropConfig.byId(recipe.inputs[2])
                local out = CropConfig.byId(recipe.out)
                check("Resep " .. recipe.out .. " bahan & hasil terdaftar", a ~= nil and b ~= nil and out ~= nil, "-")
                check("Hasil gabung " .. recipe.out .. " kategori Epic", out and out.rarity == "epic", tostring(out and out.rarity))
                check("Input gabung " .. recipe.out .. " beda jenis", recipe.inputs[1] ~= recipe.inputs[2], "-")
                local again = CropConfig.findRecipe(recipe.inputs[2], recipe.inputs[1])
                check("Resep " .. recipe.out .. " urutan bebas", again ~= nil and again.out == recipe.out, "-")
        end
        check("Gabung tak sah ditolak", CropConfig.findRecipe("wortel", "pisang") == nil, "-")
        check("Gabung sama dengan sendiri ditolak", CropConfig.findRecipe("plum", "plum") == nil, "-")
        local nectaplum = CropConfig.findRecipe("nektarin", "plum")
        check("Nectaplum = Nektarin + Plum", nectaplum ~= nil and nectaplum.out == "nectaplum", "-")
        local tetsu = CropConfig.findRecipe("labu_maxima", "labu_moschata")
        check("Tetsukabuto = Maxima + Moschata", tetsu ~= nil and tetsu.out == "tetsukabuto", "-")
end

print("--- CropConfig: pack benih ---")
do
        check("Jumlah pack = 3", #CropConfig.Packs == 3, tostring(#CropConfig.Packs))
        local prices = {}
        for _, pack in ipairs(CropConfig.Packs) do
                prices[pack.id] = pack.price
                check("Pack " .. pack.id .. " berisi 3 benih", pack.count == 3, tostring(pack.count))
                check("Pack " .. pack.id .. " kategori sah", CropConfig.byId(pack.rarity ~= nil and "" or "") == nil and #CropConfig.byRarity(pack.rarity) > 0, tostring(#CropConfig.byRarity(pack.rarity)))
        end
        check("Pack Common 400", prices.common == 400, tostring(prices.common))
        check("Pack Rare 1.500", prices.rare == 1500, tostring(prices.rare))
        check("Pack Epic 3.500", prices.epic == 3500, tostring(prices.epic))
        check("Pool common cukup untuk random", #CropConfig.byRarity("common") >= 10, "-")
end

print("--- TasLogic: 50 slot x 250 ---")
do
        local seeds, crops = {}, {}
        check("Tas kosong = 0 slot terpakai", TasLogic.usedSlots(seeds, crops) == 0, "-")
        check("Slot baru diterima", TasLogic.roomFor(seeds, crops, "seed", "wortel", 100) == 100, "-")
        seeds.wortel = 100
        check("Stack menumpuk sampai 250", TasLogic.roomFor(seeds, crops, "seed", "wortel", 200) == 150, "-")
        seeds.wortel = 250
        check("Stack penuh ditolak", TasLogic.roomFor(seeds, crops, "seed", "wortel", 1) == 0, "-")
        check("Jenis lain masih dapat slot", TasLogic.roomFor(seeds, crops, "crop", "pisang", 50) == 50, "-")
        crops.pisang = 50
        check("Slot view menghitung benih + hasil", #TasLogic.slotView({ a = 1 }, { b = 2, c = 3 }) == 3, "-")
        local fullSeeds, fullCrops = {}, {}
        for i = 1, 30 do
                fullSeeds["s" .. i] = 1
        end
        for i = 1, 20 do
                fullCrops["c" .. i] = 1
        end
        check("50 slot terpakai penuh", TasLogic.usedSlots(fullSeeds, fullCrops) == 50, tostring(TasLogic.usedSlots(fullSeeds, fullCrops)))
        check("Item baru ditolak saat 50 slot", TasLogic.roomFor(fullSeeds, fullCrops, "crop", "baru", 1) == 0, "-")
        fullCrops.c1 = 10
        check("Item lama masih bisa menumpuk saat penuh", TasLogic.roomFor(fullSeeds, fullCrops, "crop", "c1", 5) == 5, "-")
        local batch = { { kind = "seed", id = "plum", n = 1 }, { kind = "seed", id = "aprikot", n = 1 } }
        local emptyS, emptyC = {}, {}
        check("Batch 2 benih muat di tas kosong", TasLogic.canFitBatch(emptyS, emptyC, batch), "-")
        local nearFull = {}
        for i = 1, 50 do
                nearFull["s" .. i] = 1
        end
        check("Batch ditolak saat tas penuh", not TasLogic.canFitBatch(nearFull, {}, batch), "-")
        check("Kind tidak dikenal ditolak", TasLogic.roomFor({}, {}, "fish", "ikan_kecil", 1) == 0, "-")
end

print("--- Kurva level ---")
do
        check("Level 1 di XP 0", Config.Level.levelFromXp(0) == 1, "-")
        check("Level naik dengan XP", Config.Level.levelFromXp(60) == 2, tostring(Config.Level.levelFromXp(60)))
        check("Threshold monoton", Config.Level.thresholdOf(5) < Config.Level.thresholdOf(6), "-")
end

print("--- Resep craft ---")
do
        local materials = {}
        for _, res in ipairs(Config.Resources) do
                materials[res.id] = true
        end
        for _, crop in ipairs(CropConfig.Crops) do
                materials[crop.id] = true
        end
        for _, f in ipairs(Config.Fish) do
                materials[f.id] = true
        end
        local equips, usables, resources = {}, {}, {}
        for _, e in ipairs(Balance.Equipment) do
                equips[e.id] = true
        end
        for _, u in ipairs(Balance.Usables) do
                usables[u.id] = true
        end
        for _, r in ipairs(Config.Resources) do
                resources[r.id] = true
        end
        local errs = Balance.validateRecipes(materials, equips, usables, resources)
        check("Semua resep craft valid tanpa bahan lama", #errs == 0, table.concat(errs, "; "))
        local hasKayu = false
        for _, r in ipairs(Balance.Recipes) do
                for matId in pairs(r.recipe) do
                        if matId == "kayu" or matId == "apel" or matId == "batu" or matId == "jagung" or matId == "tomat" then
                                hasKayu = true
                        end
                end
        end
        check("Tidak ada bahan ekonomi lama di resep", not hasKayu, "-")
        check("Mastery craft naik", Balance.craftXpWithMastery(10, 0) == 10
                and Balance.craftXpWithMastery(10, 30) == 25, tostring(Balance.craftXpWithMastery(10, 30)))
end

print("--- Kombat & monster ---")
do
        local fist = Balance.playerAttack({ weaponAtk = 0, str = 0, dex = 0, int = 0, level = 1 })
        local sword = Balance.playerAttack({ weaponAtk = 24, str = 0, dex = 0, int = 0, level = 1 })
        check("Pukulan lebih lemah dari pedang", fist < sword, fist .. " vs " .. sword)
        check("Fist multiplier 0.45", Balance.FistMult == 0.45, tostring(Balance.FistMult))
        check("Kritikal dibatasi 45%", Balance.critChance(999) == 0.45, tostring(Balance.critChance(999)))
        check("Pertahanan mengurangi damage", Balance.damageTaken(100, 0) > Balance.damageTaken(100, 60), "-")
        check("HP tumbuh dengan VIT", Balance.maxHp(0) < Balance.maxHp(10), "-")
        local digits = {}
        local dropIds = { gel = true, taring = true, inti = true, besi = true, kristal = true }
        for _, m in ipairs(Balance.Monsters) do
                digits[m.body.digit] = true
                for _, d in ipairs(m.drops) do
                        check("Drop " .. m.id .. "/" .. d.id .. " sah (ekonomi baru)", dropIds[d.id] == true, d.id)
                end
        end
        local resourceIds = {}
        for _, res in ipairs(Config.Resources) do
                resourceIds[res.id] = true
        end
        for _, d in ipairs(Balance.Boss.drops) do
                check("Drop boss " .. d.id .. " terdaftar", resourceIds[d.id] == true, d.id)
        end
        check("Digit 1-8 ada", digits["1"] and digits["2"] and digits["8"], "-")
        check("Boss = digit 9", Balance.Boss.body.digit == "9", "-")
end

print("--- Wilayah & lahan ---")
do
        check("10 lahan pemain", Balance.HOME_COUNT == 10, tostring(Balance.HOME_COUNT))
        local errs = Balance.validateRegions()
        check("Arsitektur wilayah valid", #errs == 0, table.concat(errs, "; "))
        check("Wilayah panen dihapus", Balance.regionById("panen") == nil, "-")
        local pusat = Balance.regionById("pusat")
        check("Pusat Kota: 4 gerbang (lahan + 3 monster)", pusat ~= nil and #pusat.gates == 4, tostring(pusat and #pusat.gates))
        local homeGates, combatGates = 0, 0
        for _, g in ipairs(pusat.gates) do
                if g.dest == "home" then
                        homeGates += 1
                elseif g.dest == "padang" or g.dest == "hutan" or g.dest == "baja" then
                        combatGates += 1
                end
        end
        check("Gerbang lahan & monster benar", homeGates == 1 and combatGates == 3, homeGates .. "," .. combatGates)
        local hx, hz = Balance.homeCenter(1)
        local hx2, hz2 = Balance.homeCenter(2)
        check("homeCenter menjauh per index", hx ~= hx2 or hz ~= hz2, "-")
        local sx, sz = Balance.landSpawn(1)
        check("Titik lahir di dalam lahan", math.abs(sx - hx) <= 105 and math.abs(sz - hz) <= 95, sx .. "," .. sz)
        check("nextFreeHome pilih terkecil", Balance.nextFreeHome({ [1] = true, [2] = true }) == 3, "-")
        check("nextFreeHome penuh = 0", Balance.nextFreeHome({ [1] = true, [2] = true, [3] = true, [4] = true, [5] = true,
                [6] = true, [7] = true, [8] = true, [9] = true, [10] = true }) == 0, "-")
        local ax, az = Balance.gateArrival("rumah1", "pusat")
        check("Datang ke lahan dari pusat valid", ax ~= nil, "-")
end

print("--- Koperasi & papan nama ---")
do
        local rng = { NextInteger = function(_, _a, _b)
                return 1
        end }
        local name = Balance.koperasiName(rng)
        check("Nama koperasi 16 karakter", #name == 16, name)
        check("Nama koperasi berawalan akiomida", string.sub(name, 1, 8) == "akiomida", name)
        local suffix = string.sub(name, 9)
        local validChars = true
        for i = 1, #suffix do
                local c = string.sub(suffix, i, i)
                if not string.find("ABCDEFGHJKLMNPQRSTUVWXYZ23456789", c, 1, true) then
                        validChars = false
                end
        end
        check("Kode koperasi dari karakter aman", validChars, suffix)
        check("Nama koperasi deterministik per seed", Balance.koperasiName(rng) == name, "-")
        check("Nama lahan sah diterima", Balance.sanitizeLandName("Kebun Bahagia-1") == "Kebun Bahagia-1", "-")
        check("Nama lahan terlalu pendek ditolak", Balance.sanitizeLandName("ab") == nil, "-")
        check("Nama lahan karakter liar ditolak", Balance.sanitizeLandName("nama<script>") == nil, "-")
        check("Nama lahan non-string ditolak", Balance.sanitizeLandName(123) == nil, "-")
end

print("--- Skill ---")
do
        for _, s in ipairs(Balance.Skills) do
                check("Skill " .. s.id .. " mult & cooldown sah", s.mult > 1 and s.cooldown >= 5, "-")
        end
        check("3 skill senjata", #Balance.Skills == 3, tostring(#Balance.Skills))
end

print(("="):rep(28))
print(string.format("HASIL: %d PASS, %d FAIL", passed, failed))
if failed > 0 then
        os.exit(1)
end
