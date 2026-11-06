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

## Skor v27 (versi LIVE #27, 6 Nov 2026) - TAHAP 1: ALUR INTI (resep blog pemilik)

Dibangun dari nol sesuai resep TAHAP 1 pemilik: LAHAN, PUSAT KOTA, SEMAI PANEN,
COMBINE SEED. Tanpa rumah, ruangan, koperasi, kolam (hanya penanda area).
Semua logika uang/tas/beli/jual/pukul/drop/gabung di ServerScriptService; client
hanya menampilkan dan mengirim permintaan.

| Kriteria | Skor | Catatan |
|----------|------|---------|
| 1 Kombat | 0/10 | Tidak ada di TAHAP 1 (sesuai resep). |
| 2 Crafting | 1/10 | Gabung benih 8 resep (data tabel, validasi penuh server, urutan bebas, salah resep ditolak tanpa potong). |
| 3 Stat & Progresi | 0/10 | Tanpa sistem level (sesuai arah pemilik). |
| 4 Ekonomi | 5/10 | Micda awal 900.000 persisten DataStore (antar-place siap); Toko Benih jual pack Common 2.400 / Rare 9.000 (3 benih acak, epic TIDAK dijual) dan beli hasil panen harga/unit x jumlah. Sink & faucet jelas. Belum: pasar dinamis, toko pemain. |
| 5 Dunia & Peta | 4/10 | 10 lahan 240x220 per denah wajib (2x5, jarak 40), pagar, jalan 10 stud, lampu, papan nama (tempat saja), penanda area Koperasi/Kolam/Rumah/4 ruangan (tidak dibangun). Zona Pusat Kota terpisah 2600 stud: spawn dekat gerbang + Toko Benih 40x30 resep lengkap (pondasi batu, dinding krem 1 stud, tiang sudut, bukaan 6x10 tanpa daun, 2 etalase 10x8 dasar 3, atap pelana 30 derajat overhang 3 merah bata, kanopi 2 tiang, papan 16x4, kasir 12x3, 4 rak 8x2x8, meja 6x3, 3 lampu, lantai kayu). Belum: dungeon, dekorasi lebih kaya. |
| 6 Multiplayer | 3/10 | Pengunjung boleh masuk lahan tapi server menolak semua perubahan isi; klaim lahan otomatis & lepas saat keluar; respawn di lahan sendiri. Belum: party/trade/aktivitas bersama. |
| 7 Bertani | 8/10 | 500 plot grid 25x20 (4x4, pitch 6) per lahan, status kosong/tumbuh/siap, hanya pemilik bisa tanam/panen; tumbuh 3 detik; panen acak Common 1-10 / Rare 1-6 / Epic 1-4; tas 50 slot x 250 (satu jenis per slot, tas penuh ditolak + diberi tahu); Semai Panen 30x30: letakkan hasil di meja, pukul 5/10/15x, hadiah Micda 1-5/3-9/9-19 + peluang benih 45/30/10% & blok 20/15/15% (dihitung terpisah). |
| 8 Polish & UX | 4/10 | UI lengkap alur inti (HUD Micda, tas 50 slot, panel plot + hitung mundur, gabung benih, semai panen, toko beli/jual, toast), bangunan modular sesuai arahan modeling (maks 3 warna utama, kelipatan 2 stud). Belum: BGM, animasi, efek partikel. |
| 9 Originalitas | 10/10 | 100% karya sendiri; tanpa require ID, loadstring, getfenv, HttpService; tanpa model/script luar; semua dari Part buatan sendiri. |

**TOTAL: 33/100** (bobot: 0+15+0+75+40+30+80+40+50 = 330/10)

Riwayat: v10 = 56 -> v11 = 64 (penilaian owner) -> v20 = 79 -> v21 = 80 -> v25 = 83 -> v26 = 9 (RESET TOTAL) -> v27 = 33 (TAHAP 1 dari nol).
Celah menuju 100: kombat (15), ekonomi pemain (10), polish (6), dunia lebih kaya (6), multiplayer (7).

## Keamanan TAHAP 1 (wajib resep, semua dipenuhi)

- Semua logika uang, tas, pembelian, penjualan, pukulan, drop, combine di ServerScriptService.
- Semua RemoteFunction divalidasi server: pemilik lahan, jarak (plot 48, meja/kasir 24-30, gerbang prompt), saldo, dan batas laju per detik (token bucket per remote).
- Tanpa require ID angka, loadstring, getfenv, HttpService.
- Tanpa model/script luar - semua Part buatan sendiri.
- Data penting (Micda, tas) hanya di server + DataStore AKM_T1; ReplicatedStorage hanya config statis.

## Anti-lag TAHAP 1 (semua dipenuhi)

- Plot = Part sederhana tanpa Script, diklon dari satu template.
- Grid plot dibuat saat lahan diklaim, dihancurkan saat dilepas.
- Sisa waktu tumbuh dihitung on-demand (readyAt timestamp), tanpa loop per plot; 1 heartbeat per lahan hanya menyentuh plot yang baru siap.
- Visual tanaman hanya dibuat saat ditanam.
- StreamingEnabled aktif; semua objek Anchored; tanpa Mesh berat.

## Catatan penting place Pusat Kota

Universe 10774464946 hanya punya SATU place (77626159664192), dan Open Cloud
tidak mengizinkan membuat place baru. Karena itu Pusat Kota dibangun sebagai
zona terpisah 2600 stud (streaming terpisah, anti-lag) dan gerbang memakai
logika TeleportService penuh: begitu pemilik membuat place kedua di dashboard
dan memasukkan ID-nya ke `src/Server/Modules/PlaceConfig.luau` (KotaPlaceId),
gerbang otomatis berpindah ke teleport lintas-place sesungguhnya.

## Catatan kepatuhan syariah (permintaan pemilik, tetap berlaku)

- TANPA RIBA: tidak ada bunga/cicilan; beli lunas di muka.
- TANPA MAYSIR: pack benih berisi benih pasti (3 benih acak dari kategori yang dijamin), bukan undian barang/jackpot; peluang pukul adalah hasil usaha dan transparan di UI.
- TANPA GHARAR: harga, isi pack, dan harga beli hasil panen terlihat sebelum konfirmasi.
- TANPA SYIRIK: hiasan netral.
- Mata uang: MICDA (nama milik sendiri).

## Aturan tetap setiap sesi (WAJIB)

1. Semua aset & kode original buatan sendiri - tidak menyalin aset/nama konten pihak ketiga.
2. Tidak menghadirkan: toggle wawasan, ads.js, donasi, share (permintaan pemilik).
3. Kode dev tetap server-only (DevCodeVault), kredensial hanya di .secrets/.
4. Test dulu: `tools/luau tests/run_tests.luau` (harus 0 FAIL) + luau-lsp analyze 0 TypeError.
5. Publish langsung ke Roblox (jangan kirim file ke pemilik):
   `export ROBLOX_API_KEY="$(grep -E '^ROBLOX_API_KEY=' /home/z/my-project/.secrets/akiomida.env | cut -d= -f2-)"`
   `python3 publish.py --universe-id 10774464946 --place-id 77626159664192 --file build/DuniaAkiomida.rbxlx`
6. Update README.md + tabel skor di file ini setiap publish.
