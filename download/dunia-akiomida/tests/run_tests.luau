local CropData = require("./../src/Shared/CropData")
local Recipes = require("./../src/Shared/Recipes")
local TasLogic = require("./../src/Shared/TasLogic")
local Layout = require("./../src/Shared/Layout")
local RecipesSame = require("./../src/Shared/Recipes")

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

print("=== TES DUNIA AKIOMIDA - DUNIA SAMBUNG SATU SERVER ===")

print("--- Data tanaman (34) ---")
do
        check("Jumlah tanaman = 34", #CropData.Crops == 34, tostring(#CropData.Crops))
        local counts = { common = 0, rare = 0, epic = 0 }
        local unique = true
        local ids = {}
        for _, c in ipairs(CropData.Crops) do
                if ids[c.id] then
                        unique = false
                end
                ids[c.id] = true
                counts[c.rarity] = (counts[c.rarity] or 0) + 1
        end
        check("ID tanaman unik", unique, "-")
        check("Common = 12", counts.common == 12, tostring(counts.common))
        check("Rare = 14", counts.rare == 14, tostring(counts.rare))
        check("Epic = 8", counts.epic == 8, tostring(counts.epic))

        local harga = {
                wortel = 1, pisang = 1, bayam = 1, kentang = 1, ubi_jalar = 2, jambu_biji = 2,
                singkong = 2, tebu = 5, kedelai = 6, jamur = 6, brokoli = 7, sorgum = 17,
                jeruk_mandarin = 2, plum = 3, aprikot = 4, nektarin = 5, brassica_rapa = 7,
                brassica_oleracea = 7, grapefruit = 10, labu_moschata = 15, labu_maxima = 17,
                gandum = 19, arachis_duranensis = 20, arachis_ipaensis = 20, rye = 40, ceri = 87,
                tangelo = 17, plumcot = 22, nectaplum = 25, kacang_tanah = 30, pluerry = 35,
                canola = 60, triticale = 67, tetsukabuto = 75,
        }
        local salah = {}
        for id, h in pairs(harga) do
                local c = CropData.byId[id]
                if not c then
                        table.insert(salah, id .. " hilang")
                elseif c.jual ~= h then
                        table.insert(salah, id .. "=" .. tostring(c.jual))
                end
        end
        check("Harga jual 34 tanaman sesuai daftar", #salah == 0, table.concat(salah, ", "))

        local byRarityOk = true
        for _, r in ipairs({ "common", "rare", "epic" }) do
                if #CropData.byRarity(r) ~= ({ common = 12, rare = 14, epic = 8 })[r] then
                        byRarityOk = false
                end
        end
        check("byRarity benar", byRarityOk, "-")
end

print("--- Sistem inti ---")
do
        check("Waktu tumbuh 3 detik", CropData.GrowTime == 3, tostring(CropData.GrowTime))
        check("Dana awal 900.000", CropData.StartMoney == 900000, tostring(CropData.StartMoney))
        check("Tas 50 slot", CropData.TasSlots == 50 and TasLogic.MaxSlots == 50, "-")
        check("Stack 250", CropData.TasStack == 250 and TasLogic.MaxStack == 250, "-")
        check("Blok panen item", CropData.BlokId == "blok_panen", tostring(CropData.BlokId))
        check("Pack Common 2.400 isi 3", CropData.Packs.common.price == 2400 and CropData.Packs.common.count == 3, "-")
        check("Pack Rare 9.000 isi 3", CropData.Packs.rare.price == 9000 and CropData.Packs.rare.count == 3, "-")
        check("Tidak ada pack epic di toko", CropData.Packs.epic == nil, "-")
        local y = CropData.Yield
        check("Panen Common 1-10", y.common.min == 1 and y.common.max == 10, "-")
        check("Panen Rare 1-6", y.rare.min == 1 and y.rare.max == 6, "-")
        check("Panen Epic 1-4", y.epic.min == 1 and y.epic.max == 4, "-")
        local s = CropData.Smash
        check("Pukul Common 5x, benih 45%, blok 20%, Micda 1-5",
                s.common.hits == 5 and s.common.seed == 0.45 and s.common.blok == 0.20 and s.common.micdaMin == 1 and s.common.micdaMax == 5, "-")
        check("Pukul Rare 10x, benih 30%, blok 15%, Micda 3-9",
                s.rare.hits == 10 and s.rare.seed == 0.30 and s.rare.blok == 0.15 and s.rare.micdaMin == 3 and s.rare.micdaMax == 9, "-")
        check("Pukul Epic 15x, benih 10%, blok 15%, Micda 9-19",
                s.epic.hits == 15 and s.epic.seed == 0.10 and s.epic.blok == 0.15 and s.epic.micdaMin == 9 and s.epic.micdaMax == 19, "-")
end

print("--- Resep gabung (8) ---")
do
        check("Jumlah resep = 8", #Recipes.List == 8, tostring(#Recipes.List))
        local pasangan = {
                { "jeruk_mandarin", "grapefruit", "tangelo" },
                { "plum", "aprikot", "plumcot" },
                { "nektarin", "plum", "nectaplum" },
                { "arachis_duranensis", "arachis_ipaensis", "kacang_tanah" },
                { "ceri", "plum", "pluerry" },
                { "brassica_rapa", "brassica_oleracea", "canola" },
                { "gandum", "rye", "triticale" },
                { "labu_maxima", "labu_moschata", "tetsukabuto" },
        }
        for _, p in ipairs(pasangan) do
                local out = Recipes.find(p[1], p[2])
                local out2 = Recipes.find(p[2], p[1])
                check("Resep " .. p[3] .. " urutan bebas", out == p[3] and out2 == p[3], tostring(out))
                check("Hasil " .. p[3] .. " epic", CropData.byId[p[3]] and CropData.byId[p[3]].rarity == "epic", "-")
        end
        check("Kombinasi liar ditolak", Recipes.find("wortel", "pisang") == nil, "-")
        check("Benih sama ditolak", Recipes.find("plum", "plum") == nil, "-")
        check("Semua bahan resep terdaftar", (function()
                for _, r in ipairs(Recipes.List) do
                        if not CropData.byId[r.a] or not CropData.byId[r.b] or not CropData.byId[r.out] then
                                return false
                        end
                end
                return true
        end)(), "-")
end

print("--- Tas 50x250 ---")
do
        local tas = {}
        check("Tas kosong 0", TasLogic.usedSlots(tas) == 0, "-")
        check("Ruang item baru 100", TasLogic.roomFor(tas, "benih", "wortel", 100) == 100, "-")
        TasLogic.add(tas, "benih", "wortel", 100)
        check("Menambah 100 benih", TasLogic.countOf(tas, "benih", "wortel") == 100, tostring(TasLogic.countOf(tas, "benih", "wortel")))
        check("Sisa stack tepat 150", TasLogic.roomFor(tas, "benih", "wortel", 150) == 150, tostring(TasLogic.roomFor(tas, "benih", "wortel", 150)))
        check("Lebih dari stack pakai slot baru", TasLogic.roomFor(tas, "benih", "wortel", 151) == 151, "-")
        TasLogic.add(tas, "benih", "wortel", 150)
        check("Slot pertama penuh 250", TasLogic.countOf(tas, "benih", "wortel") == 250, tostring(TasLogic.countOf(tas, "benih", "wortel")))
        check("Jenis sama boleh buka slot kedua", TasLogic.roomFor(tas, "benih", "wortel", 1) == 1, "-")
        TasLogic.add(tas, "benih", "wortel", 1)
        check("Jenis lain dapat slot terpisah", TasLogic.roomFor(tas, "hasil", "wortel", 10) == 10, "-")
        TasLogic.add(tas, "hasil", "wortel", 5)
        check("Hasil dan benih di slot berbeda", TasLogic.countOf(tas, "hasil", "wortel") == 5 and TasLogic.countOf(tas, "benih", "wortel") == 251, "-")
        local removed = TasLogic.remove(tas, "benih", "wortel", 60)
        check("Mengurangi 60", removed == 60 and TasLogic.countOf(tas, "benih", "wortel") == 191, tostring(TasLogic.countOf(tas, "benih", "wortel")))
        local full = {}
        for i = 1, 50 do
                TasLogic.add(full, "blok", "b" .. i, 1)
        end
        check("50 slot penuh", TasLogic.usedSlots(full) == 50, tostring(TasLogic.usedSlots(full)))
        check("Item baru ditolak saat penuh", TasLogic.roomFor(full, "hasil", "wortel", 1) == 0, "-")
        check("Item lama masih bisa menumpuk", TasLogic.roomFor(full, "blok", "b1", 10) == 10, "-")
        local batch = { { kind = "benih", id = "plum", count = 1 }, { kind = "benih", id = "aprikot", count = 1 } }
        check("Batch muat di tas kosong", TasLogic.canFitBatch({}, batch), "-")
        check("Batch ditolak saat penuh", not TasLogic.canFitBatch(full, batch), "-")
        local over = TasLogic.add(full, "blok", "b1", 300)
        check("Tambah melebihi stack terpotong", TasLogic.countOf(full, "blok", "b1") == 250 and over >= 50, tostring(over))
end

print("--- Denah lahan ---")
do
        check("24 lahan per server", Layout.LahanCount == 24, tostring(Layout.LahanCount))
        check("Grid 4 x 6", Layout.Rows == 4 and Layout.Cols == 6, "-")
        check("Ukuran lahan 240 x 220", Layout.SizeX == 240 and Layout.SizeZ == 220, "-")
        check("Jarak antar lahan 40", Layout.Gap == 40, "-")
        check("500 plot", Layout.plotCount() == 500, tostring(Layout.plotCount()))
        check("Grid plot 25 x 20", Layout.PlotCols == 25 and Layout.PlotRows == 20, "-")
        check("Blok plot 150 x 120", Layout.PlotBlockW == 150 and Layout.PlotBlockD == 120, "-")
        local semuaDalam = true
        for idx = 0, Layout.plotCount() - 1 do
                local x, z = Layout.plotLocal(idx)
                if x - 2 < Layout.PlotBlockX or x + 2 > Layout.PlotBlockX + Layout.PlotBlockW then
                        semuaDalam = false
                end
                if z - 2 < Layout.PlotBlockZ or z + 2 > Layout.PlotBlockZ + Layout.PlotBlockD then
                        semuaDalam = false
                end
        end
        check("Semua 500 plot di dalam blok", semuaDalam, "-")
        check("Pitch antar plot 6 stud", Layout.PlotPitch == 6, tostring(Layout.PlotPitch))
        local x0, z0 = Layout.plotLocal(0)
        local x1, _ = Layout.plotLocal(1)
        check("Jarak pusat antar plot 6", (x1 - x0) == 6, tostring(x1 - x0))
        local _, z20 = Layout.plotLocal(25)
        check("Baris kedua turun 6", (z20 - z0) == 6, tostring(z20 - z0))
        local inside = true
        for i = 1, 24 do
                local ox, oz = Layout.cellOrigin(i)
                local row = math.floor((i - 1) / Layout.Cols)
                local col = (i - 1) % Layout.Cols
                if ox ~= col * (Layout.SizeX + Layout.Gap) or oz ~= row * (Layout.SizeZ + Layout.Gap) then
                        inside = false
                end
        end
        check("Posisi sel 4x6 benar", inside, "-")
        local o1x = Layout.cellOrigin(1)
        local o2x = Layout.cellOrigin(2)
        check("Jarak sel 1 ke 2 = 280", (o2x - o1x) == 280, tostring(o2x - o1x))
        check("Dunia dipisah 5000 stud dari kota", Layout.duniaOffsetX() >= 5000, tostring(Layout.duniaOffsetX()))
end

print("--- Batas laju ---")
do
        local RateLimit = require("./../src/Server/Modules/RateLimit")
        local now = 0
        RateLimit.clock = function()
                return now
        end
        RateLimit.clear(999)
        local ok1 = RateLimit.allow(999, "plot", 6, 3)
        local ok2 = RateLimit.allow(999, "plot", 6, 3)
        local ok3 = RateLimit.allow(999, "plot", 6, 3)
        local ok4 = RateLimit.allow(999, "plot", 6, 3)
        check("Burst 3 lalu ditolak", ok1 and ok2 and ok3 and not ok4, tostring(ok4))
        now = 1
        local ok5 = RateLimit.allow(999, "plot", 6, 3)
        check("Isi ulang setelah 1 detik", ok5, tostring(ok5))
        RateLimit.clear(999)
end

print("--- Logika dunia tersimpan ---")
do
        local DuniaLogic = require("./../src/Shared/DuniaLogic")
        check("Key dunia dari userId", DuniaLogic.keyFor(42) == "d_42", tostring(DuniaLogic.keyFor(42)))
        check("Nama bersih diterima", DuniaLogic.cleanName("  akiomida ") == "akiomida", "-")
        check("Nama rusak ditolak", DuniaLogic.cleanName("") == nil and DuniaLogic.cleanName(5) == nil and DuniaLogic.cleanName(string.rep("x", 31)) == nil, "-")
        local pl = { [0] = { crop = "wortel", readyAt = 123.7, model = {} }, [499] = { crop = "ceri", readyAt = 99 }, rusak = { crop = "x", readyAt = 1 }, [-1] = { crop = "y", readyAt = 1 }, [3] = { crop = 9, readyAt = 1 } }
        local ser = DuniaLogic.serPlots(pl)
        check("Serialize plot menyaring data", ser[0] ~= nil and ser[0].c == "wortel" and ser[0].r == 123 and ser[499] ~= nil and ser[499].c == "ceri" and ser.rusak == nil and ser[-1] == nil and ser[3] == nil, "-")
        local des = DuniaLogic.desPlots(ser)
        check("Deserialize plot roundtrip", des[0] ~= nil and des[0].c == "wortel" and des[0].r == 123 and des[499] ~= nil and des[499].c == "ceri", "-")
        check("Deserialize plot tolak rusak", DuniaLogic.desPlots({ [5] = { c = 9, r = 1 } })[5] == nil and DuniaLogic.desPlots(nil)[5] == nil and DuniaLogic.desPlots({ [6] = { c = "wortel", r = "x" } })[6] == nil, "-")
        check("Batas plot 500 ditegakkan", DuniaLogic.serPlots({ [500] = { crop = "x", readyAt = 1 } })[500] == nil and DuniaLogic.desPlots({ [501] = { c = "x", r = 1 } })[501] == nil, "-")
        local mj = { { crop = "plum", hitsLeft = 3, model = {} }, { crop = "aprikot", hitsLeft = -2 }, { crop = 5, hitsLeft = 1 } }
        local ser2 = DuniaLogic.serMeja(mj)
        check("Serialize meja menyaring data", #ser2 == 2 and ser2[1].c == "plum" and ser2[1].h == 3 and ser2[2].c == "aprikot" and ser2[2].h == 1, tostring(#ser2))
        local des2 = DuniaLogic.desMeja(ser2)
        check("Deserialize meja roundtrip", des2[1] ~= nil and des2[1].c == "plum" and des2[1].h == 3, "-")
        local penuh = {}
        for _ = 1, 9 do
                table.insert(penuh, { crop = "plum", hitsLeft = 2 })
        end
        check("Meja maks 6 slot", #DuniaLogic.serMeja(penuh) == 6 and #DuniaLogic.desMeja(DuniaLogic.serMeja(penuh)) == 6, "-")
        check("Save tiap 60 dtk", DuniaLogic.SaveEvery == 60, tostring(DuniaLogic.SaveEvery))
end

print("--- Gabung benih di plot yang sama ---")
do
        local pasangan = {
                { "jeruk_mandarin", "grapefruit", "tangelo" },
                { "plum", "aprikot", "plumcot" },
                { "nektarin", "plum", "nectaplum" },
                { "arachis_duranensis", "arachis_ipaensis", "kacang_tanah" },
                { "ceri", "plum", "pluerry" },
                { "brassica_rapa", "brassica_oleracea", "canola" },
                { "gandum", "rye", "triticale" },
                { "labu_maxima", "labu_moschata", "tetsukabuto" },
        }
        for _, p in ipairs(pasangan) do
                check("Tanam ulang " .. p[3] .. " urutan bebas", RecipesSame.sameSpot(p[1], p[2]) == p[3] and RecipesSame.sameSpot(p[2], p[1]) == p[3], tostring(RecipesSame.sameSpot(p[1], p[2])))
                check("Hasil " .. p[3] .. " epic", CropData.byId[p[3]] and CropData.byId[p[3]].rarity == "epic", "-")
        end
        check("Benih sama di plot yang sama ditolak", RecipesSame.sameSpot("plum", "plum") == nil, "-")
        check("Bukan resep ditolak", RecipesSame.sameSpot("wortel", "pisang") == nil, "-")
        check("Input rusak ditolak", RecipesSame.sameSpot(nil, "plum") == nil and RecipesSame.sameSpot("plum", 5) == nil and RecipesSame.sameSpot(9, "plum") == nil and RecipesSame.sameSpot("plum", nil) == nil, "-")
        check("Epic tidak jadi bahan resep lain", RecipesSame.sameSpot("tangelo", "plum") == nil, "-")
        check("Resep kanan+kiri tetap tertangkap", Recipes.matchList("grapefruit", { "jeruk_mandarin" }) == "tangelo", "-")
        check("Semua bahan resep terdaftar", (function()
                for _, r in ipairs(Recipes.List) do
                        if not CropData.byId[r.a] or not CropData.byId[r.b] or not CropData.byId[r.out] then
                                return false
                        end
                end
                return true
        end)(), "-")
end

print(("="):rep(28))
print(string.format("HASIL: %d PASS, %d FAIL", passed, failed))
if failed > 0 then
        error(string.format("%d tes gagal", failed))
end
