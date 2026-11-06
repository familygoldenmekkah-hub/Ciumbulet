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

## Skor v29 (versi LIVE #29, 6 Nov 2026) - TOKO RAKSI PENUH + DUNIA SAMBUNG SATU SERVER

Masukan pemilik dieksekusi seluruhnya: (1) gabung benih DIHAPUS dari toko/UI dan
kini hanya terjadi di plot lahan - tanam satu benih lalu tanam pasangan resepnya
di plot bertetangga, plot baru berubah jadi hasil gabung; (2) Pusat Kota kini
hanya punya bangunan Toko Benih (bangunan Meja Gabung dihapus); (3) balik ke
dunia lahan kini INSTAN - arsitektur baru satu server: seksi dunia pribadi di
koordinat jauh (5000+ stud) + teleport CFrame, TANPA ReserveServer/Teleport/
MemoryStore sama sekali (sumber kegagalan teleport v28 dihapus total), seksi
pemilik bertahan selama ia online jadi pulang-pergi tanpa loading dan tanpa
kehilangan isi meja; (4) beli benih bisa dari kasir MAUPUN rak; (5) rak toko
diisi pernak-pernik: karung benih, pot tanaman, keranjang, kasa, papan harga.

| Kriteria | Skor | Catatan |
|----------|------|---------|
| 1 Kombat | 0/10 | Belum ada (sesuai urutan rencana). |
| 2 Crafting | 1/10 | Gabung benih 8 resep kini murni mekanik lahan (tanam bertetangga, logika murni GabungLogic+Recipes.matchList, 12 tes khusus). |
| 3 Stat & Progresi | 0/10 | Tanpa sistem level (sesuai arah pemilik). |
| 4 Ekonomi | 5/10 | Micda 900.000 & tas 50x250 persisten (AKM_T1); pack Common 2.400 / Rare 9.000 isi 3; jual hasil di toko. Belum: pasar dinamis, toko pemain. |
| 5 Dunia & Peta | 5/10 | Pusat Kota fokus: Toko Benih interior penuh (rak terisi, papan harga, lampu) + Gerbang Dunia + papan & lampu jalan. 24 petak seksi dunia pribadi 240x220 (500 plot, pagar, meja semai, gerbang pulang) di koordinat jauh + SafeFloor anti-jatuh 8000 stud. Belum: rumah/ruangan, air nyata, dungeon. |
| 6 Multiplayer | 6/10 | Kunjung antar dunia: seksi aktif di server sama (instan) atau salinan tersimpan DataStore (pemain offline); tamu read-only ditolak server per-seksi. Balik ke dunia sendiri kini pasti berhasil (tanpa API teleport). Belum: trade, party, daftar dunia publik. |
| 7 Bertani | 8/10 | 500 plot per dunia; tumbuh 3 dtk; panen 1-10/1-6/1-4; tanaman & meja persisten (timestamp readyAt); gabung benih terjadi saat menanam. |
| 8 Polish & UX | 6/10 | Perjalanan kota-dunia INSTAN tanpa loading; rak toko tidak lagi kosong melompong; hint cara gabung di panel tas; label zona hidup via Sync; anti-jatuh streaming (anchor singkat + watchdog + RequestStreamAroundAsync). Belum: BGM, animasi, partikel. |
| 9 Originalitas | 10/10 | 100% karya sendiri; tanpa require ID, loadstring, getfenv, HttpService. |

**TOTAL: 39/100** (bobot: 0+15+0+75+50+60+80+60+50 = 390/10)

Riwayat: v10 = 56 -> v11 = 64 -> v20 = 79 -> v21 = 80 -> v25 = 83 -> v26 = 9 (RESET) -> v27 = 33 (TAHAP 1) -> v28 = 40 (TAHAP 2 instans; skor era lama) -> v29 = 39 (dunia sambung satu-server + toko purna; semua catatan pemilik terpenuhi).
Celah menuju 100: kombat (15), ekonomi pemain (10), dunia lebih kaya (5), polish (4), multiplayer lanjut (4).

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
4. Test dulu: `tools/luau tests/run_tests.luau` (harus 0 FAIL) + luau-lsp analyze 0 TypeError.
5. Publish langsung ke Roblox (jangan kirim file ke pemilik):
   `export ROBLOX_API_KEY="$(grep -E '^ROBLOX_API_KEY=' /home/z/my-project/.secrets/akiomida.env | cut -d= -f2-)"`
   `python3 publish.py --universe-id 10774464946 --place-id 77626159664192 --file build/DuniaAkiomida.rbxlx`
6. Update README.md + tabel skor di file ini setiap publish.
