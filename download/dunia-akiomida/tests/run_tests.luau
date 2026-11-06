local CropData = require("./../src/Shared/CropData")
local Recipes = require("./../src/Shared/Recipes")
local StrukBeli = require("./../src/Shared/StrukBeli")
local TasLogic = require("./../src/Shared/TasLogic")
local Layout = require("./../src/Shared/Layout")

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
        check("Blok per tanaman (tanpa blok_panen)", (CropData :: any).BlokId == nil and CropData.blokIdFor("nektarin") == "blok_nektarin" and CropData.blokCrop("blok_nektarin") == "nektarin" and CropData.blokNamaFor("nektarin") == "Blok Nektarin", tostring((CropData :: any).BlokId))
        check("Pack Common 2.400 isi 3", CropData.Packs.common.price == 2400 and CropData.Packs.common.count == 3, "-")
        check("Pack Rare 9.000 isi 3", CropData.Packs.rare.price == 9000 and CropData.Packs.rare.count == 3, "-")
        check("Tidak ada pack epic di toko", CropData.Packs.epic == nil, "-")
        local y = CropData.Yield
        check("Panen Common 1-10", y.common.min == 1 and y.common.max == 10, "-")
        check("Panen Rare 1-6", y.rare.min == 1 and y.rare.max == 6, "-")
        check("Panen Epic 1-4", y.epic.min == 1 and y.epic.max == 4, "-")
        local s = CropData.Giling
        check("Giling Common 5x, benih 45%, blok 20%, Micda 1-5",
                s.common.hits == 5 and s.common.seed == 0.45 and s.common.blok == 0.20 and s.common.micdaMin == 1 and s.common.micdaMax == 5, "-")
        check("Giling Rare 10x, benih 30%, blok 15%, Micda 3-9",
                s.rare.hits == 10 and s.rare.seed == 0.30 and s.rare.blok == 0.15 and s.rare.micdaMin == 3 and s.rare.micdaMax == 9, "-")
        check("Giling Epic 15x, benih 10%, blok 15%, Micda 9-19",
                s.epic.hits == 15 and s.epic.seed == 0.10 and s.epic.blok == 0.15 and s.epic.micdaMin == 9 and s.epic.micdaMax == 19, "-")
        check("Kapasitas mesin semai 2000 & giling 3 dtk", CropData.MesinSemai.Kapasitas == 2000 and CropData.MesinSemai.WaktuGiling == 3, "-")
end

print("--- Struk pembelian toko ---")
do
        check("Struk kosong bila tidak ada pick", #StrukBeli.rangkum({}, CropData.byId) == 0, "-")
        local rows = StrukBeli.rangkum({ "gandum", "rye", "gandum" }, CropData.byId)
        check("3 pick jadi 2 baris struk", #rows == 2, tostring(#rows))
        check("Urutan baris sesuai kemunculan pertama", rows[1].id == "gandum" and rows[2].id == "rye", "-")
        check("Jumlah baris teragregasi benar", rows[1].count == 2 and rows[2].count == 1, tostring(rows[1].count) .. "/" .. tostring(rows[2].count))
        check("Nama baris memakai nama resmi tanaman", rows[1].nama == "Gandum" and rows[2].nama == "Rye", rows[1].nama .. "/" .. rows[2].nama)
        local pool = CropData.byRarity("common")
        local picks = {}
        for _ = 1, CropData.Packs.common.count do
                table.insert(picks, pool[math.random(1, #pool)].id)
        end
        local struk = StrukBeli.rangkum(picks, CropData.byId)
        check("Total isi struk pack selalu = isi pack", StrukBeli.totalBaris(struk) == CropData.Packs.common.count, tostring(StrukBeli.totalBaris(struk)))
        local kenal = true
        for _, r in ipairs(struk) do
                if not CropData.byId[r.id] or r.count < 1 then
                        kenal = false
                end
        end
        check("Semua baris struk benih dikenal & berjumlah positif", kenal, "-")
        local rareStruk = StrukBeli.rangkum({ "plum", "plum", "plum" }, CropData.byId)
        check("Struk pack rare konsisten", #rareStruk == 1 and rareStruk[1].id == "plum" and rareStruk[1].count == 3 and rareStruk[1].nama == "Plum", "-")
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
        local ser2 = DuniaLogic.serMesin({ c = "plum", j = 20, m = 55, b = 3, k = 2 })
        check("Serialize mesin satu batch", #ser2 == 1 and ser2[1].c == "plum" and ser2[1].j == 20 and ser2[1].m == 55 and ser2[1].b == 3 and ser2[1].k == 2, tostring(#ser2))
        local des2 = DuniaLogic.desMesin(ser2)
        check("Deserialize mesin roundtrip", des2[1] ~= nil and des2[1].c == "plum" and des2[1].j == 20, "-")
        local legacy = DuniaLogic.desMesin({ { c = "aprikot", h = 2 } })
        check("Data meja lama dimigrasi ke mesin", #legacy == 1 and legacy[1].c == "aprikot" and legacy[1].j == 1, tostring(#legacy))
        check("Serialize mesin tolak rusak", #DuniaLogic.serMesin({ c = 9, j = 1 }) == 0 and #DuniaLogic.serMesin(nil) == 0, "-")
        check("Save tiap 60 dtk", DuniaLogic.SaveEvery == 60, tostring(DuniaLogic.SaveEvery))
end

print("--- Bentuk model tiap tanaman ---")
do
        local JENIS = { akar = true, daun = true, bulat = true, tangkai = true, pohon = true, semak = true, kacang = true, cendawan = true }
        local kurang, rusak, sama = {}, {}, {}
        for _, c in ipairs(CropData.Crops) do
                local b = CropData.Bentuk[c.id]
                if not b then
                        table.insert(kurang, c.id)
                elseif not JENIS[b.jenis] then
                        table.insert(rusak, c.id .. ":jenis")
                elseif type(b.t) ~= "number" or b.t <= 0 or type(b.w) ~= "number" or b.w <= 0 then
                        table.insert(rusak, c.id .. ":ukuran")
                elseif b.warna[1] == b.siap[1] and b.warna[2] == b.siap[2] and b.warna[3] == b.siap[3] then
                        table.insert(sama, c.id)
                end
        end
        check("34 tanaman semua punya bentuk", #kurang == 0, table.concat(kurang, ", "))
        check("Jenis bentuk valid & ukuran masuk akal", #rusak == 0, table.concat(rusak, ", "))
        check("Warna tumbuh beda dari warna siap (34)", #sama == 0, table.concat(sama, ", "))
        check("Hybrid punya bentuk sendiri", (function()
                local ids = { tangelo = true, plumcot = true, nectaplum = true, kacang_tanah = true, pluerry = true, canola = true, triticale = true, tetsukabuto = true }
                for id in pairs(ids) do
                        if not CropData.Bentuk[id] then
                                return false
                        end
                end
                return true
        end)(), "-")
        check("Warna siap kacang tanah kekuningan", CropData.Bentuk.kacang_tanah.siap[1] > 200 and CropData.Bentuk.kacang_tanah.siap[2] > 150, "-")
end

print("--- Pukul tanaman masih tumbuh ---")
do
        local PukulLogic = require("./../src/Shared/PukulLogic")
        check("Batas pukul 5", PukulLogic.MaksPukul == 5, tostring(PukulLogic.MaksPukul))
        local n1, h1 = PukulLogic.catat(0, 0, 100)
        check("Pukulan pertama hitungan 1", n1 == 1 and not h1, tostring(n1))
        local n2 = PukulLogic.catat(n1, 100, 101)
        local n3 = PukulLogic.catat(n2, 101, 102)
        local n4 = PukulLogic.catat(n3, 102, 103)
        local n5, h5 = PukulLogic.catat(n4, 103, 104)
        check("5x beruntun tanaman hancur", n5 == 5 and h5 == true, tostring(n5) .. "/" .. tostring(h5))
        local r1 = PukulLogic.catat(0, 0, 50)
        local r2 = PukulLogic.catat(r1, 50, 51)
        local r3 = PukulLogic.catat(r2, 51, 52)
        local r4 = PukulLogic.catat(r3, 52, 53)
        check("4x beruntun belum hancur", r4 == 4, tostring(r4))
        local s1 = PukulLogic.catat(4, 200, 500)
        check("Jeda lewat jendela reset hitungan", s1 == 1, tostring(s1))
        check("Masih tumbuh tidak membuka pukulan ke-6", PukulLogic.catat(PukulLogic.MaksPukul, 0, 10) == 1, "-")
end

print("--- Status papan tanam ---")
do
        local PanenStatus = require("./../src/Shared/PanenStatus")
        check("Lahan kosong -> daftar kosong", #PanenStatus.hitung({}, 100) == 0, "-")
        check("Input rusak -> daftar kosong", #PanenStatus.hitung(nil, 100) == 0 and #PanenStatus.hitung("x", 100) == 0, "-")
        local recs = {
                [0] = { crop = "wortel", readyAt = 90 },
                [1] = { crop = "wortel", readyAt = 200 },
                [2] = { crop = "gandum", readyAt = 50 },
                [3] = { crop = "tangelo", readyAt = 150 },
                [4] = { crop = "tangelo", readyAt = 151 },
                [5] = { crop = "tangelo", readyAt = 90 },
                rusak = { crop = 9, readyAt = 1 },
        }
        local daftar = PanenStatus.hitung(recs, 100)
        local per = {}
        for _, row in ipairs(daftar) do
                per[row.id] = row
        end
        check("Wortel 1 siap 1 tumbuh", per.wortel and per.wortel.siap == 1 and per.wortel.tumbuh == 1, "-")
        check("Gandum 1 siap", per.gandum and per.gandum.siap == 1 and per.gandum.tumbuh == 0, "-")
        check("Tangelo 1 siap 2 tumbuh", per.tangelo and per.tangelo.siap == 1 and per.tangelo.tumbuh == 2, "-")
        check("Record rusak diabaikan", #daftar == 3, tostring(#daftar))
end

print("--- Soal matematika tanam ---")
do
        local SoalLogic = require("./../src/Shared/SoalLogic")
        local function shimRng(seed: number)
                local s = seed % 2147483647
                if s == 0 then
                        s = 12345
                end
                return {
                        NextInteger = function(_, a: number, b: number)
                                s = (s * 48271) % 2147483647
                                return a + (s % (b - a + 1))
                        end,
                        NextNumber = function(_)
                                s = (s * 48271) % 2147483647
                                return s / 2147483647
                        end,
                }
        end
        local rng = shimRng(2026)
        local q1 = SoalLogic.buat(rng, 1, {})
        check("Soal punya teks dan jawab angka", type(q1.teks) == "string" and type(q1.jawab) == "number", tostring(q1.teks))
        local stageOk = true
        local u = {}
        for nomor = 1, 20 do
                local q = SoalLogic.buat(rng, nomor, u)
                if q.op ~= "tambah" and q.op ~= "kurang" then
                        stageOk = false
                end
        end
        for nomor = 21, 35 do
                local q = SoalLogic.buat(rng, nomor, u)
                if q.op ~= "kali" then
                        stageOk = false
                end
        end
        for nomor = 36, 60 do
                local q = SoalLogic.buat(rng, nomor, u)
                if q.op ~= "bagi" then
                        stageOk = false
                end
        end
        check("Kesulitan naik: tambah/kurang lalu kali lalu bagi", stageOk, "-")
        check("Jawaban tambah benar", (function()
                for _ = 1, 40 do
                        local q = SoalLogic.buat(rng, 1, {})
                        if q.op == "tambah" and q.jawab ~= q.a + q.b then
                                return false
                        end
                end
                return true
        end)(), "-")
        check("Kurang tidak pernah minus", (function()
                for _ = 1, 60 do
                        local q = SoalLogic.buat(rng, 2, {})
                        if q.op == "kurang" and (q.jawab < 0 or q.jawab ~= q.a - q.b) then
                                return false
                        end
                end
                return true
        end)(), "-")
        check("Jawaban kali benar", (function()
                for _ = 1, 40 do
                        local q = SoalLogic.buat(rng, 25, {})
                        if q.jawab ~= q.a * q.b then
                                return false
                        end
                end
                return true
        end)(), "-")
        check("Bagi selalu habis dibagi", (function()
                for _ = 1, 40 do
                        local q = SoalLogic.buat(rng, 40, {})
                        if q.b == 0 or q.a % q.b ~= 0 or q.jawab ~= q.a / q.b then
                                return false
                        end
                end
                return true
        end)(), "-")
        check("Soal tidak pernah sama dalam satu sesi", (function()
                local used2 = {}
                local tanda = {}
                local rng2 = shimRng(777)
                local nomor = 1
                for _ = 1, 220 do
                        local q = SoalLogic.buat(rng2, nomor, used2)
                        nomor = nomor % 60 + 1
                        local k = q.op .. q.a .. "_" .. q.b
                        if tanda[k] then
                                return false
                        end
                        tanda[k] = true
                end
                return true
        end)(), "-")
        check("Soal beda antar pemain", (function()
                local u1, u2 = {}, {}
                local r1, r2 = shimRng(11), shimRng(42)
                local beda = false
                for _ = 1, 12 do
                        local a = SoalLogic.buat(r1, 1, u1)
                        local b = SoalLogic.buat(r2, 1, u2)
                        if a.teks ~= b.teks then
                                beda = true
                        end
                end
                return beda
        end)(), "-")
end

print("--- Gudang 1000 tampungan ---")
do
        local GudangLogic = require("./../src/Shared/GudangLogic")
        local gd = GudangLogic.baru()
        check("Gudang baru 0 terpakai", GudangLogic.terpakai(gd) == 0, "-")
        local ok1 = GudangLogic.simpan(gd, "wortel", 250)
        check("Setor 250 memakai 1 tampungan (sisa 999)", ok1 and GudangLogic.terpakai(gd) == 1, tostring(GudangLogic.terpakai(gd)))
        GudangLogic.simpan(gd, "wortel", 250)
        check("Setor 250 lagi (sisa 998)", GudangLogic.terpakai(gd) == 2, tostring(GudangLogic.terpakai(gd)))
        check("Setor 300 ditolak", not GudangLogic.simpan(gd, "wortel", 300), "-")
        check("Setor 0 ditolak", not GudangLogic.simpan(gd, "wortel", 0), "-")
        check("Setor 1 boleh", GudangLogic.simpan(gd, "pisang", 1), "-")
        local gdFull = GudangLogic.baru()
        for _ = 1, 1000 do
                GudangLogic.simpan(gdFull, "bayam", 1)
        end
        check("Tampungan maksimal 1000", GudangLogic.terpakai(gdFull) == 1000, tostring(GudangLogic.terpakai(gdFull)))
        check("Setor ke-1001 ditolak", not GudangLogic.simpan(gdFull, "bayam", 1), "-")
        local okA, _, nA = GudangLogic.ambil(gd, 1, nil)
        check("Ambil slot 1 berisi semua isi", okA and nA == 250, tostring(nA))
        GudangLogic.kurangi(gd, 1, nA)
        check("Slot bebas setelah diambil semua", GudangLogic.terpakai(gd) == 2, tostring(GudangLogic.terpakai(gd)))
        local _, _, nP = GudangLogic.ambil(gd, 1, 100)
        GudangLogic.kurangi(gd, 1, nP)
        check("Ambil sebagian menyisakan 150", gd.s[1].count == 150 and GudangLogic.terpakai(gd) == 2, tostring(gd.s[1].count))
        check("Ambil lebih dari isi dibatasi", (function()
                local _, _, n = GudangLogic.ambil(gd, 1, 999)
                return n == 150
        end)(), "-")
        check("Slot kosong ditolak", not GudangLogic.ambil(gd, 99, nil), "-")
        local ser = GudangLogic.ser(gd)
        local des = GudangLogic.des(ser)
        check("Serialize gudang roundtrip", des.s[1].id == "wortel" and des.s[1].count == 150 and GudangLogic.terpakai(des) == 2, "-")
        check("Deserialize tolak data rusak", GudangLogic.terpakai(GudangLogic.des({ { id = 9, count = 5 }, { id = "wortel", count = "x" }, { id = "pisang", count = 40 } })) == 1, tostring(GudangLogic.terpakai(GudangLogic.des({ { id = 9, count = 5 }, { id = "wortel", count = "x" }, { id = "pisang", count = 40 } }))))
        check("Deserialize batasi 1000 slot", (function()
                local banyak = {}
                for _ = 1, 1200 do
                        table.insert(banyak, { id = "bayam", count = 1 })
                end
                return GudangLogic.terpakai(GudangLogic.des(banyak)) == 1000
        end)(), "-")
        check("Deserialize data hilang tetap aman", GudangLogic.terpakai(GudangLogic.des(nil)) == 0, "-")
        check("Batas gudang 1000 x 250", GudangLogic.MaksSlot == 1000 and GudangLogic.MaksIsi == 250, "-")
end

print("--- D: Drop panen sesuai bentuk tanaman ---")
do
        local DropBentuk = require("./../src/Shared/DropBentuk")
        local JENIS = { akar = true, daun = true, bulat = true, tangkai = true, pohon = true, semak = true, kacang = true, cendawan = true }
        local kurang, warnaSalah = {}, {}
        for _, c in ipairs(CropData.Crops) do
                local b = CropData.Bentuk[c.id]
                local spes = b and DropBentuk.spesifikasi(b)
                if not spes then
                        table.insert(kurang, c.id)
                elseif not JENIS[spes.jenis] then
                        table.insert(kurang, c.id .. ":jenis")
                elseif spes.buah[1] ~= b.siap[1] or spes.buah[2] ~= b.siap[2] or spes.buah[3] ~= b.siap[3] then
                        table.insert(warnaSalah, c.id)
                end
        end
        check("34 tanaman punya spesifikasi drop", #kurang == 0, table.concat(kurang, ", "))
        check("Warna drop = warna siap tanaman (34)", #warnaSalah == 0, table.concat(warnaSalah, ", "))
        check("8 hibrida punya drop sendiri", (function()
                for _, id in ipairs({ "tangelo", "plumcot", "nectaplum", "kacang_tanah", "pluerry", "canola", "triticale", "tetsukabuto" }) do
                        if not DropBentuk.spesifikasi(CropData.Bentuk[id]) then
                                return false
                        end
                end
                return true
        end)(), "-")
        local ikonOk = true
        for jenis in pairs(JENIS) do
                local bagian = DropBentuk.ikonBagian(jenis)
                if type(bagian) ~= "table" or #bagian < 2 then
                        ikonOk = false
                else
                        for _, g in ipairs(bagian) do
                                if type(g.dx) ~= "number" or type(g.dy) ~= "number" or type(g.dw) ~= "number" or type(g.dh) ~= "number" or g.dx < 0 or g.dx > 1 or g.dy < 0 or g.dy > 1 or g.dw <= 0 or g.dh <= 0 then
                                        ikonOk = false
                                end
                                if g.warna ~= "buah" and g.warna ~= "aksen" then
                                        ikonOk = false
                                end
                        end
                end
        end
        check("Ikon tas 8 arketipe lengkap & koordinat valid", ikonOk, "-")
        check("Warna ikon berbeda antara buah dan aksen", (function()
                local b = DropBentuk.ikonBagian("pohon")
                return b[2].warna ~= b[3].warna
        end)(), "-")
        check("Spesifikasi rusak ditolak", DropBentuk.spesifikasi(nil) == nil and DropBentuk.spesifikasi({ jenis = "alien" }) == nil and DropBentuk.spesifikasi({ jenis = "akar", siap = "x", aksen = {} }) == nil, "-")
        local spesW = DropBentuk.spesifikasi(CropData.Bentuk.wortel)
        check("Skala drop masuk akal", spesW ~= nil and spesW.skala >= 0.7 and spesW.skala <= 1.8, tostring(spesW and spesW.skala))
end

print("--- E: Animasi & efek punch ---")
do
        local PukulAnim = require("./../src/Shared/PukulAnim")
        local f1 = PukulAnim.fase(0, 0.05)
        check("Animasi hidup segera setiap tombol ditekan", f1.memukul == true and f1.kena == false, tostring(f1.memukul))
        local f2 = PukulAnim.fase(0, PukulAnim.MomenKena)
        check("Momen kena sinkron di 0.12 dtk", f2.kena == true, tostring(f2.kena))
        local f3 = PukulAnim.fase(0, PukulAnim.Durasi + 0.01)
        check("Animasi selesai setelah 0.32 dtk", not f3.memukul and not f3.kena, tostring(f3.memukul))
        local f4 = PukulAnim.fase(0, 0.16)
        check("Sudut ayunan positif di tengah ayunan", f4.sudut > 0 and f4.p > 0, tostring(f4.sudut))
        check("Tekan lagi = ayunan baru dari nol", PukulAnim.mulaiUlang(0.2, 0.25) == 0.25 and PukulAnim.mulaiUlang(nil, 1.0) == 1.0, "-")
        local g1, g2, g3 = PukulAnim.getar(1), PukulAnim.getar(2), PukulAnim.getar(3)
        check("Getaran naik dengan tier kombo", g3 > g2 and g2 > g1 and g1 > 0, tostring(g1) .. "/" .. tostring(g3))
        check("Getaran aman untuk tier aneh", PukulAnim.getar(99) == PukulAnim.getar(3) and PukulAnim.getar(0) == PukulAnim.getar(1), "-")
end

print("--- F: Presisi punch (hitbox depan karakter) ---")
do
        local ArahPukul = require("./../src/Shared/ArahPukul")
        local asal = { x = 0, y = 2, z = 0 }
        local arah = { x = 0, y = 0, z = -1 }
        local daftar = {
                { idx = 7, pos = { x = 0, y = 0, z = -6 } },
                { idx = 11, pos = { x = 0, y = 0, z = -11 } },
                { idx = 3, pos = { x = 8, y = 0, z = -6 } },
                { idx = 9, pos = { x = 0, y = 0, z = 5 } },
                { idx = 21, pos = { x = 0, y = 0, z = -30 } },
        }
        local p = ArahPukul.pilih(asal, arah, daftar)
        check("Raycast memilih tanaman terdekat di depan", p ~= nil and p.idx == 7, tostring(p and p.idx))
        check("Titik pukul tepat di titik kena", p ~= nil and p.titik.x == 0 and p.titik.z == -6, p and tostring(p.titik.x) .. "," .. tostring(p.titik.z))
        check("Sasaran menyamping ditolak", ArahPukul.pilih(asal, arah, { daftar[3] }) == nil, "-")
        check("Sasaran di belakang ditolak", ArahPukul.pilih(asal, arah, { daftar[4] }) == nil, "-")
        check("Sasaran di luar jangkauan ditolak", ArahPukul.pilih(asal, arah, { daftar[5] }) == nil, "-")
        check("Pukul titik lain = sasaran lain", (function()
                local q = ArahPukul.pilih({ x = 0, y = 2, z = -8 }, arah, daftar)
                return q ~= nil and q.idx == 11
        end)(), "-")
        check("Radius per kandidat dipakai", ArahPukul.pilih(asal, arah, { { idx = 5, pos = { x = 2.4, y = 2, z = -5 }, radius = 3.0 } }) ~= nil, "-")
        check("diDepan sesuai arah hadap", ArahPukul.diDepan(asal, arah, { x = 0, y = 0, z = -5 }) and not ArahPukul.diDepan(asal, arah, { x = 0, y = 0, z = 5 }), "-")
        check("titikPukul sepanjang sinar", (function()
                local t = ArahPukul.titikPukul(asal, arah, 6)
                return t.x == 0 and t.y == 2 and t.z == -6
        end)(), "-")
        check("Arah nol aman", ArahPukul.pilih(asal, { x = 0, y = 0, z = 0 }, daftar) == nil, "-")
        check("Jarak minimum ditolak", ArahPukul.pilih(asal, arah, { { idx = 1, pos = { x = 0, y = 0, z = -0.5 } } }) == nil, "-")
end

print("--- G: Tombol kontrol HP (Punch kiri Jump, jarak 12-20 px) ---")
do
        local KontrolHP = require("./../src/Shared/KontrolHP")
        local layar = { { 640, 360 }, { 667, 375 }, { 844, 390 }, { 915, 412 }, { 1284, 720 }, { 375, 667 }, { 2224, 1668 } }
        local semuaOk, rincian = true, ""
        for _, l in ipairs(layar) do
                local dasar = math.min(l[1], l[2])
                for _, fr in ipairs({ 0.16, 0.19, 0.22 }) do
                        local ok, alasan = KontrolHP.valid(l[1], l[2], fr * dasar)
                        if not ok then
                                semuaOk = false
                                rincian = l[1] .. "x" .. l[2] .. " jump " .. tostring(fr) .. " -> " .. alasan
                        end
                end
                if not KontrolHP.valid(l[1], l[2], nil) then
                        semuaOk = false
                        rincian = l[1] .. "x" .. l[2] .. " default"
                end
        end
        check("Punch valid di 7 ukuran layar HP & tablet", semuaOk, rincian)
        local pos = KontrolHP.posisiPunch(667, 375, nil)
        check("Punch sama dengan Jump atau sedikit lebih kecil", pos.punchPx <= pos.jumpPx and pos.punchPx >= pos.jumpPx * KontrolHP.BesarMin, tostring(pos.punchPx / pos.jumpPx))
        check("Gap punch-jump 12-20 px", pos.gapPx >= KontrolHP.GapMinPx and pos.gapPx <= KontrolHP.GapMaksPx, tostring(pos.gapPx))
        check("Gap konsisten di semua ukuran layar", (function()
                for _, l in ipairs(layar) do
                        local g = KontrolHP.posisiPunch(l[1], l[2], nil).gapPx
                        if g < KontrolHP.GapMinPx - 0.01 or g > KontrolHP.GapMaksPx + 0.01 then
                                return false
                        end
                end
                return true
        end)(), "-")
        check("Punch di kiri Jump dengan dasar segaris", (function()
                local pp = KontrolHP.rectPunch(667, 375, nil)
                local pj = KontrolHP.rectJump(667, 375, nil)
                return pp.x + pp.w <= pj.x and math.abs((pp.y + pp.h) - (pj.y + pj.h)) < 0.5
        end)(), "-")
        check("Punch tak pernah menimpa Jump di semua layar", (function()
                for _, l in ipairs(layar) do
                        if KontrolHP.tumpangTindih(KontrolHP.rectPunch(l[1], l[2], nil), KontrolHP.rectJump(l[1], l[2], nil)) then
                                return false
                        end
                end
                return true
        end)(), "-")
        check("Punch tidak menutupi area tanam tengah layar", (function()
                for _, l in ipairs(layar) do
                        if KontrolHP.tumpangTindih(KontrolHP.rectPunch(l[1], l[2], nil), KontrolHP.zonaTanam(l[1], l[2])) then
                                return false
                        end
                end
                return true
        end)(), "-")
        check("Punch merapat saat ukuran jump asli terukur", (function()
                local pos2 = KontrolHP.posisiPunch(667, 375, 70)
                return pos2.dariKananPx < KontrolHP.Anggaran * 667 and pos2.gapPx >= KontrolHP.GapMinPx
        end)(), tostring(KontrolHP.posisiPunch(667, 375, 70).dariKananPx))
        check("Posisi punch murni skala (0-1) di kaki layar", (function()
                local p = KontrolHP.posisiPunch(915, 412, nil)
                return p.skalaX > 0 and p.skalaX < 1 and p.skalaY > 0.9 and p.skalaLebar > 0 and p.skalaTinggi > 0
        end)(), "-")
        check("Punch tetap dalam layar saat jump nyata besar", (function()
                local pp = KontrolHP.rectPunch(1284, 720, 96)
                return pp.x >= 0 and pp.y >= 0 and pp.x + pp.w <= 1284 and pp.y + pp.h <= 720
        end)(), "-")
        check("Punch tetap dalam zona jempol kanan bawah", (function()
                for _, l in ipairs(layar) do
                        local pp = KontrolHP.rectPunch(l[1], l[2], nil)
                        local cx = pp.x + pp.w / 2
                        local cy = pp.y + pp.h / 2
                        if cx < KontrolHP.ZonaJempolX * l[1] or cy < KontrolHP.ZonaJempolY * l[2] then
                                return false
                        end
                end
                return true
        end)(), "-")
        check("Ukuran punch tidak berubah drastis antar layar (rasio stabil)", (function()
                local rasioLama = nil
                for _, l in ipairs(layar) do
                        local p = KontrolHP.posisiPunch(l[1], l[2], nil)
                        local r = p.punchPx / p.jumpPx
                        if rasioLama and math.abs(r - rasioLama) > 0.01 then
                                return false
                        end
                        rasioLama = r
                end
                return true
        end)(), "-")
end

print("--- HUD: Saldo & tombol navigasi di semua layar HP ---")
do
        local HUDLayout = require("./../src/Shared/HUDLayout")
        local layar = { { 640, 360 }, { 667, 375 }, { 844, 390 }, { 915, 412 }, { 1284, 720 }, { 375, 667 } }
        check("Saldo selalu di bawah ikon menu Roblox (inset 58)", (function()
                for _, l in ipairs(layar) do
                        local s = HUDLayout.rectSaldo(l[1], l[2], 0, 58)
                        if s.y < 58 + 2 then
                                return false
                        end
                end
                return true
        end)(), "-")
        check("Saldo memuat ikon + angka + satuan utuh dalam kotak", (function()
                for _, l in ipairs(layar) do
                        local s = HUDLayout.rectSaldo(l[1], l[2], 0, 58)
                        if s.w < HUDLayout.SaldoLebarMin or s.h < 24 then
                                return false
                        end
                        for _, r in ipairs({ HUDLayout.rectIkon(s), HUDLayout.rectAngka(s), HUDLayout.rectSatuan(s) }) do
                                if r.w <= 0 or r.h <= 0 or not HUDLayout.diDalam(r, s) then
                                        return false
                                end
                        end
                        if HUDLayout.tumpangTindih(HUDLayout.rectAngka(s), HUDLayout.rectSatuan(s)) then
                                return false
                        end
                end
                return true
        end)(), "-")
        check("Inset kiri ikut menggeser saldo ke kanan", (function()
                local s1 = HUDLayout.rectSaldo(915, 412, 0, 58)
                local s2 = HUDLayout.rectSaldo(915, 412, 12, 58)
                return s2.x > s1.x and s2.y == s1.y
        end)(), "-")
        local s367 = HUDLayout.rectSaldo(667, 375, 0, 58)
        local navPendek = HUDLayout.rectNav(667, 375, 0, 58, 33)
        local navPanjang = HUDLayout.rectNav(667, 375, 0, 58, 213)
        local navRaksasa = HUDLayout.rectNav(667, 375, 0, 58, 400)
        check("Tombol nav tepat di bawah saldo & rata kiri", (function()
                return navPendek.x == s367.x and navPendek.y >= s367.y + s367.h and (navPendek.y - (s367.y + s367.h)) < s367.h * 0.5
        end)(), tostring(navPendek.y))
        check("Lebar nav dalam batas minimum & maksimum", navPendek.w >= navPendek.minim and navPendek.w <= navPendek.maks and navPanjang.w <= navPanjang.maks, tostring(navPanjang.w))
        check("Nama terpanjang terpotong, tidak keluar kotak", navRaksasa.terpotong and navRaksasa.w <= navRaksasa.maks, tostring(navRaksasa.w))
        check("Nama terpendek tidak terpotong", not navPendek.terpotong, "-")
        check("Posisi nav tidak bergeser saat teks berganti", navPendek.x == navPanjang.x and navPanjang.x == navRaksasa.x and navPendek.y == navPanjang.y and navPanjang.y == navRaksasa.y, "-")
        check("Nav tak pernah menimpa saldo di semua layar", (function()
                for _, l in ipairs(layar) do
                        local s = HUDLayout.rectSaldo(l[1], l[2], 0, 58)
                        local n = HUDLayout.rectNav(l[1], l[2], 0, 58, 999)
                        if HUDLayout.tumpangTindih(s, n) then
                                return false
                        end
                end
                return true
        end)(), "-")
        check("Nav nama terpanjang tetap berada di dalam layar", (function()
                for _, l in ipairs(layar) do
                        local n = HUDLayout.rectNav(l[1], l[2], 0, 58, 999)
                        if n.x < 0 or n.x + n.w > l[1] + 0.5 or n.y + n.h > l[2] + 0.5 then
                                return false
                        end
                end
                return true
        end)(), "-")
        check("Tas sebaris & setinggi saldo di kanan atas", (function()
                for _, l in ipairs(layar) do
                        local a = HUDLayout.areaAman(l[1], l[2], 0, 58)
                        local bt = HUDLayout.batasTas(a)
                        local bs = HUDLayout.batasSaldo(a)
                        if math.abs(bt.tinggi - bs.tinggi) > 0.01 or bt.lebar < HUDLayout.TasLebarMin then
                                return false
                        end
                end
                return true
        end)(), "-")
end

print("--- A/C: Papan Tanam aman di layar HP ---")
do
        local UIStyle = require("./../src/Shared/UIStyle")
        check("Safe area atas >= 48 px (tak tertutup tombol menu)", UIStyle.AmanAtas >= 48, tostring(UIStyle.AmanAtas))
        check("Panel berbasis skala dengan batas ukuran", UIStyle.LebarPanelMaks >= 600 and UIStyle.TinggiPanelMaks >= 440, tostring(UIStyle.LebarPanelMaks) .. "x" .. tostring(UIStyle.TinggiPanelMaks))
        check("Satu font, tepat tiga ukuran", UIStyle.cekTigaUkuran() and UIStyle.UkuranJudul <= 20, tostring(UIStyle.UkuranJudul))
        check("Judul diperkecil & hierarki jelas", UIStyle.UkuranIsi < UIStyle.UkuranJudul and UIStyle.UkuranKecil < UIStyle.UkuranIsi, "-")
        check("Hijau hanya untuk aksi utama", UIStyle.Hijau[2] > UIStyle.Hijau[1] and UIStyle.Hijau[2] > UIStyle.Hijau[3], tostring(UIStyle.Hijau[2]))
        check("Aksen beda dari latar gelap", UIStyle.Aksen[1] ~= UIStyle.Latar[1] and UIStyle.Aksen[3] > UIStyle.Latar[3], "-")
        local t1, t2, t3 = UIStyle.tabTampak("tanam"), UIStyle.tabTampak("gabung"), UIStyle.tabTampak("status")
        check("Tab Tanam: angka + Mulai tampil, tombol lain sembunyi", t1.angka and t1.mulai and not t1.gabung and not t1.status, "-")
        check("Tab Combine: hanya tombol Gabung", t2.gabung and not t2.angka and not t2.mulai and not t2.status and not t2.daftarTanam, "-")
        check("Tab Status: hanya status", t3.status and not t3.gabung and not t3.mulai and not t3.angka, "-")
        check("Setiap tab tepat satu grup tombol", UIStyle.tabTunggal("tanam") and UIStyle.tabTunggal("gabung") and UIStyle.tabTunggal("status"), "-")
        check("Tab tak dikenal aman (semua sembunyi)", not UIStyle.tabTampak("salah").angka and not UIStyle.tabTampak("salah").status, "-")
        check("Nama benih panjang terpotong", #UIStyle.potong("Labu Cucurbita Moschata") <= UIStyle.NamaMaks + 3, UIStyle.potong("Labu Cucurbita Moschata"))
        check("Potongan berakhiran elipsis", (function()
                local s = UIStyle.potong(string.rep("a", 40))
                return #s == UIStyle.NamaMaks + 2 and string.sub(s, -3) == "…"
        end)(), "-")
        check("Nama pendek utuh", UIStyle.potong("Wortel") == "Wortel", "-")
        check("Input rusak aman", UIStyle.potong(nil) == "?" and UIStyle.potong(9) == "?", "-")
end

print("--- H: Keamanan Micda (server-authoritative, simulasi exploit) ---")
do
        local UangLogic = require("./../src/Shared/UangLogic")
        local st = UangLogic.baru(900000)
        check("Saldo awal 900.000", UangLogic.saldo(st) == 900000, tostring(UangLogic.saldo(st)))
        local ok = UangLogic.tambah(st, 50, "jual_hasil", 100)
        check("Tambah sah menambah saldo", ok and UangLogic.saldo(st) == 900050, tostring(UangLogic.saldo(st)))
        check("Ledger mencatat transaksi sah", #UangLogic.ledgerOf(st) == 1 and UangLogic.ledgerOf(st)[1].d == 50 and UangLogic.ledgerOf(st)[1].r == "jual_hasil" and UangLogic.ledgerOf(st)[1].s == "ok", "-")
        local a1 = UangLogic.tambah(st, -5, "jual_hasil", 100)
        local a2 = UangLogic.tambah(st, 0, "jual_hasil", 100)
        local a3 = UangLogic.tambah(st, 10.5, "jual_hasil", 100)
        local a4 = UangLogic.tambah(st, 0 / 0, "jual_hasil", 100)
        local a5 = UangLogic.tambah(st, math.huge, "jual_hasil", 100)
        local a6 = UangLogic.tambah(st, 10, "nakal", 100)
        local a7 = UangLogic.tambah(st, 10, nil, 100)
        local a8 = UangLogic.tambah(st, "500", "jual_hasil", 100)
        check("Micda palsu/negatif/NaN/inf/tipe salah semua ditolak", not a1 and not a2 and not a3 and not a4 and not a5 and not a6 and not a7 and not a8, tostring(a1) .. tostring(a4))
        check("Saldo tidak berubah oleh percobaan ilegal", UangLogic.saldo(st) == 900050, tostring(UangLogic.saldo(st)))
        local spike = UangLogic.tambah(st, UangLogic.MaksAksi + 1, "hadiah", 100)
        check("Lonjakan saldo melebihi batas ditolak", not spike and UangLogic.saldo(st) == 900050, tostring(UangLogic.saldo(st)))
        check("Ledger mencatat penolakan lonjakan", UangLogic.ledgerOf(st)[2] ~= nil and UangLogic.ledgerOf(st)[2].s == "tolak_lonjakan", tostring(UangLogic.ledgerOf(st)[2] and UangLogic.ledgerOf(st)[2].s))
        local b1 = UangLogic.bayar(st, 999999999, "beli_benih", 100)
        check("Bayar melebihi saldo ditolak, saldo tak minus", not b1 and UangLogic.saldo(st) == 900050, tostring(UangLogic.saldo(st)))
        local b2 = UangLogic.bayar(st, 2400, "beli_benih", 101)
        check("Bayar sah mengurangi saldo tepat", b2 and UangLogic.saldo(st) == 897650, tostring(UangLogic.saldo(st)))
        check("Bayar dengan alasan asing ditolak", not UangLogic.bayar(st, 1, "curang", 101), "-")
        local st2 = UangLogic.baru(0)
        local lajuOk, lajuTolak = 0, 0
        for i = 1, UangLogic.BatasPerMenit + 3 do
                local okL = UangLogic.tambah(st2, 1, "semai_hasil", i)
                if okL then
                        lajuOk += 1
                else
                        lajuTolak += 1
                end
        end
        check("Batas transaksi per menit ditegakkan", lajuOk == UangLogic.BatasPerMenit and lajuTolak == 3, tostring(lajuOk) .. "/" .. tostring(lajuTolak))
        local okLagi = UangLogic.tambah(st2, 1, "semai_hasil", UangLogic.JendelaDetik + 2)
        check("Jendela laju terbuka lagi setelah 60 detik", okLagi, "-")
        local st3 = UangLogic.baru(0)
        for i = 1, UangLogic.BatasLedger + 10 do
                UangLogic.tambah(st3, 1, "semai_hasil", i)
        end
        check("Ledger terpotong ke batas penyimpanan", #UangLogic.ledgerOf(st3) == UangLogic.BatasLedger, tostring(#UangLogic.ledgerOf(st3)))
        check("Whitelist alasan transaksi", UangLogic.alasanOk("jual_hasil") and UangLogic.alasanOk("beli_benih") and UangLogic.alasanOk("semai_hasil") and UangLogic.alasanOk("hadiah") and not UangLogic.alasanOk(" cheat "), "-")
end

print("--- I: Kunci sesi (anti-dua-server) ---")
do
        local SesiLogic = require("./../src/Shared/SesiLogic")
        check("Kunci kosong bisa diambil", SesiLogic.bisaAmbil(nil, "srvA", 100), "-")
        check("Kunci legam (j kosong) bisa diambil", SesiLogic.bisaAmbil({ j = "", t = 1 }, "srvA", 100), "-")
        check("Kunci milik server lain yang segar ditolak", not SesiLogic.bisaAmbil({ j = "srvB", t = 100 }, "srvA", 120), "-")
        check("Kunci server yang sama tetap bisa", SesiLogic.bisaAmbil({ j = "srvA", t = 100 }, "srvA", 500), "-")
        check("Kunci basi (lewat 90 dtk) bisa diambil", SesiLogic.bisaAmbil({ j = "srvB", t = 100 }, "srvA", 100 + SesiLogic.StaleDetik), "-")
        check("Kunci rusak dianggap basi", SesiLogic.bisaAmbil({ j = 7 }, "srvA", 100) == false or SesiLogic.bisaAmbil({ t = "x" }, "srvA", 100), "-")
        local k = SesiLogic.kunciBaru("srvA", 123)
        check("Kunci baru memuat job & waktu", k.j == "srvA" and k.t == 123, "-")
        local l = SesiLogic.lepas("srvA")
        check("Lepas kunci mengosongkan pemilik", l.j == "" , tostring(l.j))
end

print("--- J: Waktu kedaluwarsa hasil panen (bukan pohon) ---")
do
        local PanenWaktu = require("./../src/Shared/PanenWaktu")
        check("Konfigurasi HARVEST_EXPIRE_SECONDS = 900", PanenWaktu.HARVEST_EXPIRE_SECONDS == 900, tostring(PanenWaktu.HARVEST_EXPIRE_SECONDS))
        check("Tanpa waktu keluar (online) tetap aman", PanenWaktu.masihAman(nil, 500000), "-")
        check("Waktu keluar rusak dianggap aman", PanenWaktu.masihAman("x", 500000) and PanenWaktu.masihAman(0 / 0, 500000), "-")
        check("Rejoin sebelum 15 menit: hasil panen kembali", PanenWaktu.masihAman(1000, 1000 + PanenWaktu.HARVEST_EXPIRE_SECONDS - 1), "-")
        check("Rejoin tepat 15 menit: hasil panen dihapus", not PanenWaktu.masihAman(1000, 1000 + PanenWaktu.HARVEST_EXPIRE_SECONDS), "-")
        check("Rejoin setelah 15 menit: hasil panen dihapus", not PanenWaktu.masihAman(1000, 1000 + 3600), "-")
        check("Hitung ulang dari keluar terbaru", PanenWaktu.masihAman(2000, 1000 + PanenWaktu.HARVEST_EXPIRE_SECONDS + 100), "-")
        check("Sisa detik menurun sampai nol", PanenWaktu.sisaDetik(1000, 1000 + 300) == 600 and PanenWaktu.sisaDetik(1000, 1000 + 2000) == 0, tostring(PanenWaktu.sisaDetik(1000, 1300)))
end

print("--- K: Klaim drop atomik (anti-dupe, anti-claim) ---")
do
        local KlaimDrop = require("./../src/Shared/KlaimDrop")
        check("Jarak ambil wajar", KlaimDrop.JarakAmbil <= 16 and KlaimDrop.JarakAmbil >= 10, tostring(KlaimDrop.JarakAmbil))
        local rec = KlaimDrop.baru(7)
        local ok, alasan = KlaimDrop.coba(rec, 7, 5)
        check("Klaim sah oleh pemilik", ok and rec.status == "proses", tostring(alasan))
        local ok2, alasan2 = KlaimDrop.coba(rec, 7, 5)
        check("Klaim ganda ditolak (satu ID satu kali)", not ok2 and alasan2 == "sudah_diambil" and rec.status == "proses", tostring(alasan2))
        check("Selesai menandai ambil", KlaimDrop.selesai(rec, 7) and rec.status == "ambil", "-")
        local ok3, alasan3 = KlaimDrop.coba(rec, 7, 3)
        check("Drop yang sudah diambil tak bisa diambil lagi", not ok3 and alasan3 == "sudah_diambil", tostring(alasan3))
        local r2 = KlaimDrop.baru(7)
        local ok4, alasan4 = KlaimDrop.coba(r2, 99, 5)
        check("Drop milik orang lain ditolak", not ok4 and alasan4 == "bukan_milik" and r2.status == "ada", tostring(alasan4))
        local r3 = KlaimDrop.baru(7)
        local ok5, alasan5 = KlaimDrop.coba(r3, 7, 50)
        check("Ambil dari jarak jauh ditolak", not ok5 and alasan5 == "jarak", tostring(alasan5))
        local r4 = KlaimDrop.baru(7)
        local ok6 = KlaimDrop.coba(r4, 7, 0 / 0)
        check("Jarak NaN ditolak", not ok6, "-")
        local r5 = KlaimDrop.baru(7)
        KlaimDrop.coba(r5, 7, 4)
        check("Batalkan melepas status proses", KlaimDrop.batalkan(r5, 7) and r5.status == "ada" and KlaimDrop.coba(r5, 7, 4), "-")
        local r6 = KlaimDrop.baru(7)
        check("Selesai/batalkan pada status salah gagal", not KlaimDrop.selesai(r6, 7) and not KlaimDrop.batalkan(r6, 7), "-")
        check("Klaim dengan rec rusak aman", select(1, KlaimDrop.coba(nil, 7, 5)) == false, "-")
end

print("--- L: Simpan pohon & hasil panen ke DataStore ---")
do
        local DuniaLogic = require("./../src/Shared/DuniaLogic")
        check("Konfigurasi MaxDrops = 80", DuniaLogic.MaxDrops == 80, tostring(DuniaLogic.MaxDrops))
        local pl = { [3] = { crop = "wortel", readyAt = 500, hits = 3, lastHit = 490 }, [4] = { crop = "ceri", readyAt = 900, hits = 0.7, lastHit = -5 } }
        local ser = DuniaLogic.serPlots(pl)
        check("Progres pukulan pohon ikut tersimpan", ser[3] ~= nil and ser[3].h == 3 and ser[3].l == 490, tostring(ser[3] and ser[3].h))
        check("Progres pukulan disaring & dijepit", ser[4] ~= nil and ser[4].h == 0 and ser[4].l == 0, tostring(ser[4] and ser[4].h))
        local des = DuniaLogic.desPlots(ser)
        check("Restore pohon memulihkan status terakhir", des[3] ~= nil and des[3].h == 3 and des[3].l == 490 and des[3].r == 500, "-")
        local drops = {
                { id = "d1x1y111222333444", crop = "wortel", count = 4, pos = { x = 1.5, y = 2.5, z = 3.5 } },
                { id = "d2x2y555666777888", crop = "gandum", count = 251, pos = { x = 1, y = 1, z = 1 } },
                { id = 42, crop = "plum", count = 1, pos = { x = 0, y = 0, z = 0 } },
                { id = "d3", crop = 9, count = 1, pos = { x = 0, y = 0, z = 0 } },
                { id = "d4", crop = "plum", count = 1, pos = { x = "a", y = 1, z = 1 } },
        }
        local sd = DuniaLogic.serDrops(drops)
        check("Serialize drop menyaring data rusak", #sd == 1 and sd[1].i == "d1x1y111222333444" and sd[1].n == 4, tostring(#sd))
        check("Serialize drop memotong ke batas 80", (function()
                local banyak = {}
                for i = 1, 95 do
                        table.insert(banyak, { id = "x" .. i, crop = "plum", count = 1, pos = { x = i, y = 0, z = 0 } })
                end
                return #DuniaLogic.serDrops(banyak) == 80
        end)(), "-")
        local dd = DuniaLogic.desDrops(sd)
        check("Deserialize drop roundtrip", #dd == 1 and dd[1].id == "d1x1y111222333444" and dd[1].count == 4 and dd[1].pos.x == 1.5, "-")
        check("Deserialize drop tolak rusak", #DuniaLogic.desDrops({ { i = "x", c = "plum", n = "3", p = { x = 1, y = 1, z = 1 } } }) == 0 and #DuniaLogic.desDrops(nil) == 0, "-")
end

print("--- M: Ikon tombol punch (tanpa tulisan PUNCH) ---")
do
        local IkonJempol = require("./../src/Shared/IkonJempol")
        check("Ikon kepalan memakai >= 4 bagian", #IkonJempol.Bagian >= 4, tostring(#IkonJempol.Bagian))
        check("Semua bagian ikon di dalam kotak 0-1", IkonJempol.valid(), "-")
        check("Bentuk ikon dikenal (kotak/lingkaran/garis)", (function()
                for _, g in ipairs(IkonJempol.Bagian) do
                        if g.bentuk ~= "kotak" and g.bentuk ~= "lingkaran" and g.bentuk ~= "garis" then
                                return false
                        end
                end
                return true
        end)(), "-")
        check("Ikon dapat digandakan tanpa efek samping", (function()
                local a = IkonJempol.bagian()
                table.insert(a, { dx = 2, dy = 2, dw = 1, dh = 1, bentuk = "kotak" })
                return #IkonJempol.bagian() == #IkonJempol.Bagian
        end)(), "-")
end

print("--- N: Atur jual (jumlah sendiri + konfirmasi) ---")
do
        local JualLogic = require("./../src/Shared/JualLogic")
        check("Jumlah sah diterima", JualLogic.saring("7", 50) == 7, "-")
        check("Nol / negatif / pecahan ditolak", JualLogic.saring("0", 50) == nil and JualLogic.saring("-3", 50) == nil and JualLogic.saring("2.5", 50) == nil, "-")
        check("Teks bukan angka ditolak", JualLogic.saring("abc", 50) == nil and JualLogic.saring("", 50) == nil, "-")
        check("Jumlah dipotong ke stok maksimum", JualLogic.saring("99", 40) == 40, "-")
        check("Stok kosong selalu ditolak", JualLogic.saring("1", 0) == nil and JualLogic.saring("1", nil :: any) ~= nil, "-")
        check("Total harga = unit x jumlah", JualLogic.total(87, 3) == 261, "-")
end

print("--- O: Punch tahan tombol (auto ulang) ---")
do
        local PukulAnim = require("./../src/Shared/PukulAnim")
        check("Interval auto punch ada dan masuk akal", PukulAnim.Ulang >= 0.36 and PukulAnim.Ulang <= 0.5, tostring(PukulAnim.Ulang))
        check("Interval aman dari cooldown server 0.35 dtk", PukulAnim.Ulang > 0.35, tostring(PukulAnim.Ulang))
        local fw = PukulAnim.fase(0, 0.04)
        check("Ayunan tinju dimulai angkat tangan ke belakang", fw.sudut < 0, tostring(fw.sudut))
        local ft = PukulAnim.fase(0, 0.16)
        check("Tinju menghantam ke depan di tengah ayunan", ft.sudut > 1, tostring(ft.sudut))
        local fe = PukulAnim.fase(0, PukulAnim.Durasi * 0.96)
        check("Ayunan kembali nol di akhir", math.abs(fe.sudut) < 0.02, tostring(fe.sudut))
end

print("--- P: Mesin semai (atur jumlah, tuas, hasil) ---")
do
        local SemaiLogic = require("./../src/Shared/SemaiLogic")
        check("Jumlah sah diterima", SemaiLogic.saringJumlah("20", 100, 2000) == 20, "-")
        check("Nol / negatif / pecahan / teks ditolak", SemaiLogic.saringJumlah("0", 100, 2000) == nil and SemaiLogic.saringJumlah("-3", 100, 2000) == nil and SemaiLogic.saringJumlah("2.5", 100, 2000) == nil and SemaiLogic.saringJumlah("abc", 100, 2000) == nil, "-")
        check("Jumlah dipotong ke stok", SemaiLogic.saringJumlah("99999", 40, 2000) == 40, "-")
        check("Jumlah dipotong ke kapasitas mesin", SemaiLogic.saringJumlah("3000", 3000, 2000) == 2000, "-")
        check("Stok kosong ditolak", SemaiLogic.saringJumlah("1", 0, 2000) == nil and SemaiLogic.saringJumlah("1", nil, 2000) == nil, "-")
        check("Total pukulan = jumlah x per item", SemaiLogic.pukulanTotal(20, 10) == 200 and SemaiLogic.pukulanTotal(2000, 15) == 30000, "-")
        local function shimSemai(seed: number)
                local s0 = seed % 2147483647
                if s0 == 0 then
                        s0 = 12345
                end
                return {
                        NextInteger = function(_, a: number, b: number)
                                s0 = (s0 * 48271) % 2147483647
                                return a + (s0 % (b - a + 1))
                        end,
                        NextNumber = function(_)
                                s0 = (s0 * 48271) % 2147483647
                                return s0 / 2147483647
                        end,
                }
        end
        local a = SemaiLogic.gulung(shimSemai(7), CropData.Giling.common, 500)
        local b = SemaiLogic.gulung(shimSemai(7), CropData.Giling.common, 500)
        check("Gulung hasil deterministik per benih acak", a.micda == b.micda and a.benih == b.benih and a.blok == b.blok, tostring(a.micda))
        check("Gulung micda dalam rentang rarity", a.micda >= 500 and a.micda <= 2500, tostring(a.micda))
        check("Gulung benih & blok tak melebihi jumlah", a.benih <= 500 and a.blok <= 500, "-")
        local t = SemaiLogic.tuasBaru()
        check("Tuas baru: kanan & kiri belum aktif", t.kanan == false and t.kiri == false, "-")
        check("Sisi tidak dikenal ditolak", SemaiLogic.saringSisi("atas") == nil and SemaiLogic.saringSisi(1) == nil and SemaiLogic.saringSisi(nil) == nil, "-")
        local okK, kodeK = SemaiLogic.prosesTekan(t, "kanan")
        check("Tekan tuas KANAN dulu diterima", okK and t.kanan == true and t.kiri == false, tostring(kodeK))
        local okKK, kodeKK = SemaiLogic.prosesTekan(t, "kanan")
        check("Tekan tuas KANAN dua kali ditolak", not okKK and kodeKK == "sudah", tostring(kodeKK))
        local okDur, kodeDur = SemaiLogic.prosesTekan(t, "hax")
        check("Sisi asing ditolak saat menekan", not okDur and kodeDur == "sisi", tostring(kodeDur))
        local okUrut, kodeUrut = SemaiLogic.prosesTekan({ kanan = false, kiri = false }, "kiri")
        check("Urutan KIRI sebelum KANAN ditolak", not okUrut and kodeUrut == "urutan", tostring(kodeUrut))
        local okLK, kodeLK = SemaiLogic.prosesTekan(t, "kiri")
        check("Tekan tuas KIRI setelah KANAN diterima", okLK and kodeLK == "ok", tostring(kodeLK))
        check("Kedua tuas aktif = selesai", SemaiLogic.tuasSelesai(t), "-")
        check("tuasBerikut kosong saat selesai", SemaiLogic.tuasBerikut(t) == nil, "-")
        check("tuasBerikut mulai dari kanan", SemaiLogic.tuasBerikut(SemaiLogic.tuasBaru()) == "kanan", "-")
        check("tuasSelesai menolak input bukan tabel", not SemaiLogic.tuasSelesai(nil) and not SemaiLogic.tuasSelesai("kanan"), "-")
        check("prosesTekan menolak tuas bukan tabel", select(1, SemaiLogic.prosesTekan(nil, "kanan")) == false, "-")
end

print("--- Q: Tuas server-authoritative (urutan kanan-kiri, saring sisi) ---")
do
        local SemaiLogic = require("./../src/Shared/SemaiLogic")
        local alur = SemaiLogic.tuasBaru()
        check("Alur penuh: kosong -> tuasBerikut kanan", SemaiLogic.tuasBerikut(alur) == "kanan", "-")
        SemaiLogic.prosesTekan(alur, "kanan")
        check("Alur penuh: setelah kanan -> tuasBerikut kiri", SemaiLogic.tuasBerikut(alur) == "kiri", "-")
        SemaiLogic.prosesTekan(alur, "kiri")
        check("Alur penuh: kanan lalu kiri = mesin siap giling", SemaiLogic.tuasSelesai(alur), "-")
        local bolak = 0
        for _ = 1, 40 do
                local x = SemaiLogic.tuasBaru()
                if SemaiLogic.prosesTekan(x, "kiri") then
                        bolak += 1
                end
        end
        check("40 percobaan loncat urutan semuanya ditolak", bolak == 0, tostring(bolak))
        check("Saring sisi menolak nil", SemaiLogic.saringSisi(nil) == nil, "-")
        local tidakSah = { "atas", 1, "KANAN", "kanan " }
        local tolakSisi = 0
        for _, v in ipairs(tidakSah) do
                if not SemaiLogic.saringSisi(v) then
                        tolakSisi += 1
                end
        end
        check("Saring sisi menolak 4 bentuk tidak sah", tolakSisi == 4, tostring(tolakSisi))
        check("Saring sisi menerima kanan & kiri", SemaiLogic.saringSisi("kanan") == "kanan" and SemaiLogic.saringSisi("kiri") == "kiri", "-")
        local dua = SemaiLogic.tuasBaru()
        SemaiLogic.prosesTekan(dua, "kanan")
        local ok2, kode2 = SemaiLogic.prosesTekan(dua, "kiri")
        check("Alur dua langkah berurutan sukses tanpa galat", ok2 and kode2 == "ok" and dua.kanan and dua.kiri, tostring(kode2))
end

print(("="):rep(28))
print(string.format("HASIL: %d PASS, %d FAIL", passed, failed))
if failed > 0 then
        error(string.format("%d tes gagal", failed))
end
