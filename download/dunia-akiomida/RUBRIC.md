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

## Skor v30 (versi LIVE #30, 6 Nov 2026) - PLAYTEST OTOMATIS + PERBAIKAN AKAR MASALAH

Permintaan pemilik dieksekusi: "tes dan mainkan agar tahu letak errornya."
Dibangun mesin playtest yang menjalankan kode server ASLI + UI klien ASLI di
simulator Roblox, lalu memainkan alur lengkap: join -> beli benih lewat UI ->
masuk dunia lahan lewat gerbang -> tanam -> gabung benih di plot yang sama ->
panen -> jual -> pukul meja semai -> pulang -> balik lagi -> kunjungan tamu ->
keluar & cek simpanan. Playtest v30: 51 PASS / 0 FAIL.

Akar masalah yang DIBUKTIKAN playtest (dan diperbaiki):
1. UI klien MATI sejak v27-v29: init.client hanya print, UIController tidak
   pernah di-require -> panel toko, tombol beli, tombol masuk dunia tidak ada
   di lapangan. Ini penyebab laporan pemilik "beli benih gak bisa" dan "gak
   bisa balik dunia lahan". (Faktanya juga: UIController tidak mengembalikan
   nilai sehingga require-nya akan selalu gagal di Roblox asli.)
2. 500 plot per lahan dibangun TANPA offset 5000 stud -> menumpuk di Pusat
   Kota, lahan tidak punya tanah yang bisa diklik -> tanam/gabung mustahil
   lewat klik, kota penuh kotak tanah liar. (Faktor lag juga.)
3. PlotService.startLoop tidak pernah dipanggil -> status "siap panen" tidak
   pernah dikirim -> tombol Panen tidak pernah muncul di UI.
4. Pintu toko/semai cuma lubang (melompong) -> kini pintu sungguhan dua daun
   berengsel dengan animasi buka/tutup via prompt.
5. Rak toko masih terasa kosong -> ditambah barisan paket benih berwarna di
   semua rak & rak dinding, peti kayu, etalase kaca di kasir, papan BUKA,
   poster panduan, spanduk gantung, papan promo luar, alas pintu, tumpukan
   karung, pot tanaman tambahan.
6. Gabung benih kini persis aturan pemilik: tanam satu benih, lalu tanam
   pasangan resepnya DI PLOT YANG SAMA (logika Recipes.sameSpot; tetangga
   tidak lagi otomatis menggabung). Panel plot terisi menampilkan tombol
   Gabung untuk benih resep yang ada di tas.
7. Teleport diperkuat anti-jatuh: tunggu RequestStreamAroundAsync selesai
   sebelum lepas anchor, gagal-aman 5 dtk, pengawas jurang 15 dtk.

| Kriteria | Skor | Catatan |
|----------|------|---------|
| 1 Kombat | 0/10 | Belum ada (sesuai urutan rencana). |
| 2 Crafting | 2/10 | Gabung benih 8 resep kini benar-benar bisa dimainkan ujung-ke-ujung (tombol Gabung di panel plot, aturan tanam ulang di plot yang sama) dan terbukti playtest. Belum: crafting bahan lain. |
| 3 Stat & Progresi | 0/10 | Tanpa sistem level (sesuai arah pemilik). |
| 4 Ekonomi | 5/10 | Micda 900.000 & tas 50x250 persisten (AKM_T1); pack Common 2.400 / Rare 9.000 isi 3; jual hasil di toko; pembelian terbukti jalan lewat UI sungguhan di playtest. Belum: pasar dinamis, toko pemain. |
| 5 Dunia & Peta | 6/10 | Pusat Kota hanya Toko Benih (aturan pemilik) dengan interior padat pernak-pernik + pintu sungguhan; plot lahan kini benar-benar berada di dunia masing-masing (5000+ stud). Belum: rumah, air, dungeon. |
| 6 Multiplayer | 6/10 | Kunjung antar dunia instan (seksi sama) atau salinan DataStore (offline); tamu read-only terverifikasi playtest; balik ke dunia sendiri terverifikasi lewat tombol UI asli. Belum: trade, party, daftar dunia publik. |
| 7 Bertani | 8/10 | 500 plot per dunia di koordinat benar; tumbuh 3 dtk; panen 1-10/1-6/1-4; sinkron siap-panen kini hidup (startLoop); gabung di plot yang sama; tanaman & meja persisten. |
| 8 Polish & UX | 7/10 | UI kini benar-benar tampil (dibuktikan playtest): HUD Micda, panel toko/tas/plot/gerbang, toast, hitung mundur, tombol panen & gabung; pintu berengsel beranimasi; anti-jatuh diperkuat. Belum: BGM, animasi karakter, partikel. |
| 9 Originalitas | 10/10 | 100% karya sendiri; tanpa require ID, loadstring, getfenv, HttpService. |

**TOTAL: 42/100** (bobot: 0+30+0+75+60+60+80+70+50 = 425/10 = 42,5, dibulatkan
ke bawah agar jujur)

Riwayat: v10 = 56 -> v11 = 64 -> v20 = 79 -> v21 = 80 -> v25 = 83 -> v26 = 9
(RESET) -> v27 = 33 (TAHAP 1) -> v28 = 40 -> v29 = 39 (klaim UI belum
terverifikasi) -> v30 = 42 (playtest otomatis, akar masalah diperbaiki,
semua laporan pemilik dieksekusi dan dibuktikan hijau).
Celah menuju 100: kombat (15), ekonomi pemain (10), dunia lebih kaya (4),
polish (3), multiplayer lanjut (4), crafting lanjut (13).

## Arsitektur dunia sambung (v29) - tanpa ID manual, tanpa teleport API, anti-lag

- SATU place, SATU jenis server. Pusat Kota di koordinat 0; setiap dunia
  pribadi = seksi Model di petak koordinat X+5000 (24 petak 240x220 per server).
- Masuk/pulang/kunjung = teleport CFrame server: tanpa loading screen, tanpa
  ReserveServer, tanpa MemoryStore, tanpa kegagalan TeleportService. Seksi
  pemilik TETAP ADA selama ia online - pulang ke kota lalu kembali = dunia
  persis seperti ditinggal (termasuk isi meja semai).
- Anti-jatuh saat streaming: SafeFloor raksasa (8000x1600, tak ter-stream),
  anchor root 1,1 dtk saat tiba, RequestStreamAroundAsync, watchdog Y<-20
  mengembalikan ke titik tiba.
- Kunjungan: pemain di server yang sama -> langsung; pemain offline -> seksi
  hantu baca-saja dari DataStore AKM_Dunia (auto-hancur 120 dtk kosong);
  pemilik kembali masuk -> hantu otomatis jadi dunia miliknya.
- Persistensi: DataStore AKM_Dunia per userId (tanaman + meja, sanitasi ketat
  DuniaLogic), save tiap 60 dtk bila berubah + saat keluar game + BindToClose.
  Bila DataStore gagal, dunia tetap bisa dimainkan mode sesi (tanpa menimpa
  data lama).
- Peran: pemilik lahan (ownerOf per seksi) vs tamu; PlotAct/SmashAct divalidasi
  server per-seksi dengan pesan jujur.
- StreamingEnabled aktif; semua Anchored; plot tanpa Script dari satu template;
  tanaman hanya dibuat saat ditanam/dimuat; save hanya bila dirty.

## Keamanan TAHAP 1 (wajib resep, semua dipenuhi)

- Semua logika uang, tas, pembelian, penjualan, pukulan, drop, gabung benih di ServerScriptService.
- Semua RemoteFunction divalidasi server: pemilik lahan, jarak (plot 48, meja/kasir 24-30, gerbang prompt), saldo, dan batas laju per detik (token bucket per remote).
- Tanpa require ID angka, loadstring, getfenv, HttpService.
- Tanpa model/script luar - semua Part buatan sendiri.
- Data penting (Micda, tas) hanya di server + DataStore AKM_T1; ReplicatedStorage hanya config statis.

## Anti-lag (v29, semua dipenuhi)

- Dunia pribadi = seksi koordinat jauh dalam satu server: pemain kota tidak
  pernah memuat seksi lain (di luar radius streaming); ramai keluar-masuk
  tidak menggeser beban antar server.
- Plot = Part sederhana tanpa Script, diklon dari satu template.
- Sisa waktu tumbuh dihitung on-demand (readyAt timestamp), tanpa loop per plot;
  1 loop per lahan hanya menyentuh plot yang baru siap.
- Visual tanaman hanya dibuat saat ditanam / dimuat dari data.
- Seksi hantu kunjungan auto-hancur 120 dtk kosong; save dunia hanya bila
  berubah (flag dirty) tiap 60 dtk.
- StreamingEnabled aktif; semua objek Anchored; tanpa Mesh berat.

## Catatan penting place Pusat Kota

Semenjak v29, Pusat Kota dan semua dunia pribadi berada di place dan server
yang SAMA, dipisah koordinat (kota di 0, dunia di X+5000) - tidak ada
kebutuhan place kedua, ID manual, ReserveServer, MemoryStore, maupun
TeleportService. Gerbang di dunia pribadi mengembalikan pemain ke Pusat Kota
seketika (CFrame); gerbang di Pusat Kota membuka panel Masuk/Kunjungi dunia.

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
4. Test dulu: `tools/luau tests/run_tests.luau` (harus 0 FAIL) + luau-lsp
   analyze 0 TypeError + playtest 0 FAIL
   (`cd /home/z/my-project/scripts && python3 sim/gen.py && tools luau
   sim/gen_playtest.luau` via `tools/luau sim/gen_playtest.luau`).
5. Publish langsung ke Roblox (jangan kirim file ke pemilik):
   `export ROBLOX_API_KEY="$(grep -E '^ROBLOX_API_KEY=' /home/z/my-project/.secrets/akiomida.env | cut -d= -f2-)"`
   `python3 publish.py --universe-id 10774464946 --place-id 77626159664192 --file build/DuniaAkiomida.rbxlx`
6. Update README.md + tabel skor di file ini setiap publish.
