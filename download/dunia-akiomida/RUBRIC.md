# RUBRIK SELEVEL TORAM ONLINE / GROWTOPIA — DUNIA AKIOMIDA

Dipakai setiap sesi update mandiri: beri skor jujur, tingkatkan area terlemah,
publish, lalu skor ulang. Target pemilik: **100/100**.

Skor per kriteria 0-10, dikali bobot. Total dihitung dari (skor x bobot) / 10.

## Kriteria & Bobot

| # | Kriteria | Bobot | Acuan Toram Online | Acuan Growtopia |
|---|----------|-------|--------------------|-----------------|
| 1 | Kombat (monster, AI, boss, skill) | 15 | monster beragam, skill combo, bos mekanik | PvP / grif & pertahanan dunia |
| 2 | Crafting & Profes (objek jadi bahan) | 15 | tempaa, menjahit, alkimia, masak (mastery) | spawning blok, blueprint |
| 3 | Stat & Progresi (stat points, equipment) | 10 | 5 stat, skill tree, ribuan item | level + item hiasan |
| 4 | Ekonomi (pasar dinamis, player shop) | 15 | bazar, item langka, sink & faucet | vending player economy |
| 5 | Dunia & Peta (zona, dungeon, dekorasi) | 10 | banyak map & dungeon | dunia player-built |
| 6 | Aktivitas Multiplayer | 10 | party, boss bersama, guild | berinteraksi, trade, scam-proof |
| 7 | Bertani / Gardening | 10 | farm (bahan masak) | Grow a Garden plot |
| 8 | Polish & UX (UI, suara, animasi, efek) | 10 | animasi kombat, BGM, partikel | UI rapi & responsif |
| 9 | Originalitas 100% & aman hak cipta | 5 | - | - |

## Skor v26 (versi LIVE #26, 6 Nov 2026) - RESET TOTAL (permintaan pemilik)

Pemilik meminta reset total: semua map dan semua sistem lama dihapus, dunia kembali
dari nol ("semuanya kembali dari nol, jangan ada apa-apa dulu"). Penurunan skor
di bawah ini adalah keadaan yang DIMINTA, bukan kemunduran tak sengaja. Nilai
masa lalu (puncak 83 di #25) disimpan di riwayat sebagai acuan membangun ulang.

| Kriteria | Skor | Catatan |
|----------|------|---------|
| 1 Kombat | 0/10 | Dihapus bersama reset. Monster/skill/boss akan dibangun ulang dari nol. |
| 2 Crafting | 0/10 | Dihapus bersama reset. |
| 3 Stat & Progresi | 0/10 | Dihapus bersama reset (tanpa sistem level, sesuai arah terakhir pemilik). |
| 4 Ekonomi | 0/10 | Dihapus bersama reset. Rancangan ekonomi tani (34 tanaman, pack benih, 8 resep gabung, tas 50x250, dana awal 900.000 Micda) sudah disepakati dan menunggu giliran dibangun. |
| 5 Dunia & Peta | 1/10 | Dunia kosong: baseplate 2048x2048 + satu titik lahir + pencahayaan dasar. StreamingEnabled aktif. |
| 6 Multiplayer | 1/10 | Pemain bisa bergabung, lahir, dan berjalan bersama di dunia kosong. Tidak ada aktivitas lain. |
| 7 Bertani | 0/10 | Dihapus bersama reset. |
| 8 Polish & UX | 2/10 | Pencahayaan bersih, dunia ringan (build hanya 3,5 KB), loading instan. Tidak ada UI, suara, atau animasi. |
| 9 Originalitas | 10/10 | 100% karya sendiri; reset justru memastikan tidak ada sisa apa pun dari luar. |

**TOTAL: 9/100** (bobot: 0+0+0+0+10+10+0+20+50 = 90/10)

Riwayat: v10 = 56 -> v11 = 64 (penilaian owner) -> v20 = 79 -> v21 = 80 -> v25 = 83 -> v26 = 9 (RESET TOTAL diminta pemilik; titik nol membangun ulang).

## Catatan kepatuhan syariah (permintaan pemilik, tetap berlaku)

- TANPA RIBA: tidak ada bunga, cicilan, atau "tabungan berbunga". Segala pembelian lunas di muka.
- TANPA MAYSIR: tidak ada undian/lotre/gacha berbayar. Peluang berbasis hasil usaha, tarif transparan.
- TANPA GHARAR: pembeli melihat barang, jumlah, dan harga sebelum konfirmasi.
- TANPA SYIRIK: tidak ada pemujaan/dewa; hiasan netral.
- Mata uang: MICDA (nama milik sendiri).

## Urutan membangun ulang (menunggu arah pemilik; daftar ini bukan janji otomatis)

1. Tata dunia dasar dari nol: wilayah, lahan, pusat kota (pintu 2x karakter, bangunan 4x karakter, pintu benar-benar buka-tutup, air terrain sungguhan).
2. Ekonomi tani baru sesuai spek pemilik: 34 tanaman (3 detik, panen 1-4), tas 50 slot x 250, pack benih 400/1.500/3.500, 8 resep gabung benih, dana awal 900.000 Micda, tanpa level.
3. Toko benih profesional di pusat kota + koperasi per lahan.
4. Setelah fondasi oke: kombat, craft, progresi, multiplayer, polish.

## Aturan tetap setiap sesi (WAJIB)

1. Semua aset & kode original buatan sendiri - tidak menyalin aset/nama konten pihak ketiga.
2. Tidak menghadirkan: toggle wawasan, ads.js, donasi, share (permintaan pemilik).
3. Kode dev tetap server-only (DevCodeVault), kredensial hanya di .secrets/ + credentials.json.
4. Test dulu: `tools/luau tests/run_tests.luau` (harus 0 FAIL) + luau-lsp analyze 0 TypeError.
5. Publish langsung ke Roblox (jangan kirim file ke pemilik):
   `export ROBLOX_API_KEY="$(grep -E '^ROBLOX_API_KEY=' /home/z/my-project/.secrets/akiomida.env | cut -d= -f2-)"`
   `python3 publish.py --universe-id 10774464946 --place-id 77626159664192 --file build/DuniaAkiomida.rbxlx`
6. Update README.md + tabel skor di file ini setiap publish.
