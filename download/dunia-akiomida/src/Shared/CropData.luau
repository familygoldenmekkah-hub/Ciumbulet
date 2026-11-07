local CropData = {}

CropData.GrowTime = 3
CropData.StartMoney = 1000000000000
CropData.TasSlots = 50
CropData.TasStack = 250
CropData.MesinSemai = {
        Kapasitas = 2000,
        WaktuGiling = 3,
        JarakMaks = 24,
}

CropData.Packs = {
        common = { price = 2400, count = 3 },
        rare = { price = 9000, count = 3 },
}

CropData.Yield = {
        common = { min = 1, max = 10 },
        rare = { min = 1, max = 6 },
        epic = { min = 1, max = 4 },
}

CropData.Giling = {
        common = { hits = 5, seed = 0.45, micdaMin = 1, micdaMax = 5 },
        rare = { hits = 10, seed = 0.30, micdaMin = 3, micdaMax = 9 },
        epic = { hits = 15, seed = 0.10, micdaMin = 9, micdaMax = 19 },
}

CropData.Crops = {
        { id = "wortel", nama = "Wortel", rarity = "common", jual = 1 },
        { id = "pisang", nama = "Pisang", rarity = "common", jual = 1 },
        { id = "bayam", nama = "Bayam", rarity = "common", jual = 1 },
        { id = "kentang", nama = "Kentang", rarity = "common", jual = 1 },
        { id = "ubi_jalar", nama = "Ubi Jalar", rarity = "common", jual = 2 },
        { id = "jambu_biji", nama = "Jambu Biji", rarity = "common", jual = 2 },
        { id = "singkong", nama = "Singkong", rarity = "common", jual = 2 },
        { id = "tebu", nama = "Tebu", rarity = "common", jual = 5 },
        { id = "kedelai", nama = "Kedelai", rarity = "common", jual = 6 },
        { id = "jamur", nama = "Jamur", rarity = "common", jual = 6 },
        { id = "brokoli", nama = "Brokoli", rarity = "common", jual = 7 },
        { id = "sorgum", nama = "Sorgum", rarity = "common", jual = 17 },
        { id = "jeruk_mandarin", nama = "Jeruk Mandarin", rarity = "rare", jual = 2 },
        { id = "plum", nama = "Plum", rarity = "rare", jual = 3 },
        { id = "aprikot", nama = "Aprikot", rarity = "rare", jual = 4 },
        { id = "nektarin", nama = "Nektarin", rarity = "rare", jual = 5 },
        { id = "brassica_rapa", nama = "Brassica Rapa", rarity = "rare", jual = 7 },
        { id = "brassica_oleracea", nama = "Brassica Oleracea", rarity = "rare", jual = 7 },
        { id = "grapefruit", nama = "Grapefruit", rarity = "rare", jual = 10 },
        { id = "labu_moschata", nama = "Labu Cucurbita Moschata", rarity = "rare", jual = 15 },
        { id = "labu_maxima", nama = "Labu Cucurbita Maxima", rarity = "rare", jual = 17 },
        { id = "gandum", nama = "Gandum", rarity = "rare", jual = 19 },
        { id = "arachis_duranensis", nama = "Arachis Duranensis", rarity = "rare", jual = 20 },
        { id = "arachis_ipaensis", nama = "Arachis Ipaensis", rarity = "rare", jual = 20 },
        { id = "rye", nama = "Rye", rarity = "rare", jual = 40 },
        { id = "ceri", nama = "Ceri", rarity = "rare", jual = 87 },
        { id = "tangelo", nama = "Tangelo", rarity = "epic", jual = 17 },
        { id = "plumcot", nama = "Plumcot", rarity = "epic", jual = 22 },
        { id = "nectaplum", nama = "Nectaplum", rarity = "epic", jual = 25 },
        { id = "kacang_tanah", nama = "Kacang Tanah", rarity = "epic", jual = 30 },
        { id = "pluerry", nama = "Pluerry", rarity = "epic", jual = 35 },
        { id = "canola", nama = "Canola", rarity = "epic", jual = 60 },
        { id = "triticale", nama = "Triticale", rarity = "epic", jual = 67 },
        { id = "tetsukabuto", nama = "Tetsukabuto", rarity = "epic", jual = 75 },
}

CropData.byId = {}
for _, c in ipairs(CropData.Crops) do
        CropData.byId[c.id] = c
end

CropData.PukulMaks = 5

CropData.Bentuk = {
        wortel = { jenis = "akar", t = 2.0, w = 1.0, b = 3, warna = { 224, 178, 120 }, siap = { 232, 112, 44 }, aksen = { 74, 142, 70 } },
        kentang = { jenis = "akar", t = 1.4, w = 1.2, b = 3, warna = { 198, 178, 142 }, siap = { 188, 140, 88 }, aksen = { 88, 148, 78 } },
        singkong = { jenis = "akar", t = 2.8, w = 1.0, b = 3, warna = { 168, 142, 110 }, siap = { 148, 104, 66 }, aksen = { 96, 156, 84 } },
        brassica_rapa = { jenis = "akar", t = 1.6, w = 1.3, b = 3, warna = { 222, 214, 224 }, siap = { 196, 148, 190 }, aksen = { 104, 162, 92 } },
        ubi_jalar = { jenis = "kacang", t = 0.9, w = 2.2, b = 5, warna = { 214, 150, 96 }, siap = { 226, 104, 58 }, aksen = { 88, 152, 86 } },
        bayam = { jenis = "daun", t = 1.5, w = 1.4, b = 1, warna = { 84, 146, 80 }, siap = { 44, 110, 60 }, aksen = { 110, 170, 96 } },
        brokoli = { jenis = "daun", t = 1.7, w = 1.5, b = 1, warna = { 96, 132, 70 }, siap = { 58, 118, 66 }, aksen = { 118, 166, 92 } },
        brassica_oleracea = { jenis = "daun", t = 1.9, w = 1.9, b = 1, warna = { 130, 168, 104 }, siap = { 170, 200, 132 }, aksen = { 96, 150, 88 } },
        labu_moschata = { jenis = "bulat", t = 1.1, w = 2.6, b = 1, warna = { 198, 142, 80 }, siap = { 230, 148, 58 }, aksen = { 96, 140, 70 } },
        labu_maxima = { jenis = "bulat", t = 1.3, w = 3.2, b = 1, warna = { 210, 120, 70 }, siap = { 236, 108, 52 }, aksen = { 90, 134, 66 } },
        tetsukabuto = { jenis = "bulat", t = 1.2, w = 2.8, b = 1, warna = { 120, 158, 92 }, siap = { 92, 140, 190 }, aksen = { 70, 120, 80 } },
        gandum = { jenis = "tangkai", t = 2.6, w = 1.6, b = 5, warna = { 146, 150, 72 }, siap = { 224, 182, 84 }, aksen = { 126, 152, 80 } },
        rye = { jenis = "tangkai", t = 3.0, w = 1.6, b = 5, warna = { 120, 136, 110 }, siap = { 150, 164, 128 }, aksen = { 110, 140, 96 } },
        triticale = { jenis = "tangkai", t = 2.8, w = 1.7, b = 5, warna = { 150, 142, 96 }, siap = { 216, 176, 110 }, aksen = { 96, 140, 104 } },
        sorgum = { jenis = "tangkai", t = 3.4, w = 1.8, b = 4, warna = { 150, 116, 66 }, siap = { 186, 88, 52 }, aksen = { 110, 150, 88 } },
        tebu = { jenis = "tangkai", t = 4.4, w = 1.6, b = 3, warna = { 130, 158, 96 }, siap = { 150, 96, 140 }, aksen = { 112, 160, 92 } },
        canola = { jenis = "tangkai", t = 2.4, w = 1.6, b = 5, warna = { 140, 168, 96 }, siap = { 240, 214, 70 }, aksen = { 120, 160, 96 } },
        pisang = { jenis = "pohon", t = 4.6, w = 2.6, b = 3, warna = { 120, 156, 88 }, siap = { 232, 208, 88 }, aksen = { 96, 148, 80 } },
        jambu_biji = { jenis = "pohon", t = 3.8, w = 2.2, b = 4, warna = { 110, 150, 90 }, siap = { 196, 190, 96 }, aksen = { 88, 140, 76 } },
        jeruk_mandarin = { jenis = "pohon", t = 3.4, w = 2.0, b = 5, warna = { 120, 164, 88 }, siap = { 238, 146, 44 }, aksen = { 84, 136, 72 } },
        grapefruit = { jenis = "pohon", t = 4.0, w = 2.4, b = 4, warna = { 116, 158, 92 }, siap = { 240, 168, 60 }, aksen = { 80, 132, 70 } },
        plum = { jenis = "pohon", t = 3.6, w = 2.2, b = 5, warna = { 122, 150, 96 }, siap = { 150, 86, 168 }, aksen = { 86, 136, 74 } },
        aprikot = { jenis = "pohon", t = 3.7, w = 2.2, b = 5, warna = { 118, 152, 92 }, siap = { 232, 138, 104 }, aksen = { 84, 134, 72 } },
        nektarin = { jenis = "pohon", t = 3.5, w = 2.1, b = 5, warna = { 116, 150, 90 }, siap = { 226, 92, 88 }, aksen = { 82, 132, 70 } },
        ceri = { jenis = "pohon", t = 3.0, w = 1.9, b = 6, warna = { 118, 148, 92 }, siap = { 216, 54, 58 }, aksen = { 80, 128, 68 } },
        tangelo = { jenis = "pohon", t = 3.6, w = 2.2, b = 5, warna = { 126, 160, 94 }, siap = { 244, 120, 52 }, aksen = { 226, 86, 70 } },
        plumcot = { jenis = "pohon", t = 3.6, w = 2.2, b = 5, warna = { 120, 148, 94 }, siap = { 168, 84, 180 }, aksen = { 210, 90, 110 } },
        nectaplum = { jenis = "pohon", t = 3.5, w = 2.1, b = 5, warna = { 118, 146, 92 }, siap = { 178, 58, 96 }, aksen = { 230, 120, 80 } },
        pluerry = { jenis = "pohon", t = 3.2, w = 2.0, b = 6, warna = { 120, 150, 94 }, siap = { 210, 70, 86 }, aksen = { 140, 80, 170 } },
        kedelai = { jenis = "semak", t = 1.6, w = 1.8, b = 6, warna = { 108, 146, 88 }, siap = { 222, 186, 70 }, aksen = { 96, 140, 82 } },
        arachis_duranensis = { jenis = "kacang", t = 0.8, w = 2.4, b = 5, warna = { 130, 160, 100 }, siap = { 220, 180, 90 }, aksen = { 104, 150, 88 } },
        arachis_ipaensis = { jenis = "kacang", t = 0.8, w = 2.2, b = 5, warna = { 140, 164, 96 }, siap = { 198, 146, 72 }, aksen = { 112, 154, 90 } },
        kacang_tanah = { jenis = "kacang", t = 1.0, w = 2.8, b = 6, warna = { 150, 168, 104 }, siap = { 236, 196, 110 }, aksen = { 100, 146, 86 } },
        jamur = { jenis = "cendawan", t = 1.8, w = 1.6, b = 1, warna = { 196, 150, 120 }, siap = { 206, 64, 56 }, aksen = { 224, 214, 196 } },
}

function CropData.namaBenih(cropId: string): string
        local info = CropData.byId[cropId]
        if not info then
                return "Benih"
        end
        return "Benih " .. info.nama
end

function CropData.byRarity(rarity: string): { any }
        local out = {}
        for _, c in ipairs(CropData.Crops) do
                if c.rarity == rarity then
                        table.insert(out, c)
                end
        end
        return out
end

return CropData
