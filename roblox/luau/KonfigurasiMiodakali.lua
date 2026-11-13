--!strict
-- Miodakali — Konfigurasi (karya asli game Miodakali)
-- Skema real-time ala permainan tani modern: tanaman tumbuh mengikuti
-- waktu nyata, tenaga pulih bertahap, level petani membuka konten baru.
local Konfig = {}

Konfig.UangAwal = 150

-- Tanaman ladang: tumbuh dalam DETIK NYATA (bukan hari tidur)
Konfig.Tanaman = {
        { nama = "Lumira", benih = "BenihLumira", hargaBenih = 12, hargaJual = 22, detikTumbuh = 60, levelButuh = 1, xpPanen = 2 },
        { nama = "Beraka", benih = "BenihBeraka", hargaBenih = 28, hargaJual = 48, detikTumbuh = 180, levelButuh = 2, xpPanen = 3 },
        { nama = "Terunu", benih = "BenihTerunu", hargaBenih = 45, hargaJual = 75, detikTumbuh = 300, levelButuh = 3, xpPanen = 4 },
        { nama = "Makira", benih = "BenihMakira", hargaBenih = 70, hargaJual = 110, detikTumbuh = 600, levelButuh = 5, xpPanen = 6 },
        { nama = "Kopanu", benih = "BenihKopanu", hargaBenih = 95, hargaJual = 150, detikTumbuh = 900, levelButuh = 6, xpPanen = 7 },
        { nama = "Sundara", benih = "BenihSundara", hargaBenih = 140, hargaJual = 220, detikTumbuh = 1500, levelButuh = 8, xpPanen = 9 },
}

Konfig.HargaPakanu = 8
Konfig.HargaPanyukan = 120
Konfig.LevelPanyukan = 2

-- Hasil lain yang bisa dijual di kios
Konfig.HargaJualLain = {
        TelurAyumi = 22,
        SusuSapiyu = 60,
        Balanu = 10,
        Batuku = 12,
        Ikana = 20,
        Silara = 36,
        Kiraya = 62,
}

-- Ternak kandang: dibeli, diberi Pakanu, hasil siap pada timer nyata
Konfig.Ternak = {
        Ayumi = { harga = 60, levelButuh = 1, detikProduksi = 120, hasil = "TelurAyumi" },
        Sapiyu = { harga = 180, levelButuh = 4, detikProduksi = 300, hasil = "SusuSapiyu" },
}

-- Ekspansi lahan: petak awal terbuka, sisanya dibeli bertahap
Konfig.PetakAwal = 3
Konfig.BiayaPetak = function(keN: number)
        return {
                uang = 40 + 25 * keN,
                balanu = 2 + math.floor(keN / 2),
                batuku = 1 + math.floor(keN / 3),
        }
end

-- Level petani: XP_BUTUH[i] = XP agar naik dari level i ke i+1
Konfig.XPButuh = { 30, 50, 80, 120, 180, 260, 330, 450, 600, 800, 1000, 1250, 1500, 1800, 2200 }

Konfig.EnergiMaksDasar = 100
Konfig.EnergiPerLevel = 5
Konfig.RegenTenagaDetik = 12 -- pulih 1 tenaga tiap N detik nyata
Konfig.RespawnDetik = 150 -- pohon & batu tumbuh kembali (detik nyata)

Konfig.BiayaTenaga = {
        gembur = 2,
        tanam = 1,
        panen = 1,
        tebang = 5,
        pecah = 5,
        pakanu = 1,
        ambil = 1,
}

Konfig.XpAksi = {
        gembur = 1,
        tanam = 1,
        tebang = 3,
        pecah = 3,
        pakanu = 1,
        ambil = 3,
}

-- Rantai tugas pembuka
Konfig.Tugas = {
        { id = "tanam", teks = "Tanam Benih Lumira di petak kebun", uang = 20, xp = 5 },
        { id = "panen", teks = "Panen Lumira yang sudah matang", uang = 25, xp = 10 },
        { id = "jual", teks = "Jual hasil panen di Kios Desa", uang = 30, xp = 10 },
        { id = "beli", teks = "Beli 3 benih apa pun di Kios", uang = 20, xp = 5 },
        { id = "tebas", teks = "Tebas Kayanu dengan Kapura", uang = 25, xp = 10 },
        { id = "tambang", teks = "Pecah Batuku dengan Giliuk", uang = 25, xp = 10 },
        { id = "ternak", teks = "Beli Ayumi di kandang & beri Pakanu", uang = 40, xp = 15 },
        { id = "petak", teks = "Perluas kebun: beli petak baru", uang = 30, xp = 15 },
        { id = "masak", teks = "Masak di Dapur Desa (segera hadir)", uang = 40, xp = 15 },
        { id = "pancing", teks = "Pancing ikan di Kolam", uang = 50, xp = 20 },
        { id = "lv3", teks = "Capai Level 3 Petani", uang = 60, xp = 0 },
}

return Konfig
