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

## Skor v28 (versi LIVE #28, 6 Nov 2026) - TAHAP 2: DUNIA PRIBADI TER-INSTANS

Permintaan pemilik terpenuhi: TANPA ID PLACE MANUAL sama sekali (PlaceConfig
dihapus), anti-lag saat banyak pemain keluar-masuk, dan pemain lain bisa
mengunjungi dunia pemain lain tanpa saling mengganggu. Arsitektur: satu place,
dua jenis server - Pusat Kota (hub publik ringan) dan dunia pribadi per-
instance lewat `TeleportService:ReserveServer(game.PlaceId)` (model dunia-
per-server), rendezvous MemoryStore TTL 90 dtk + heartbeat 30 dtk, persistensi
dunia DataStore AKM_Dunia (tanaman + meja semai bertahan saat offline).

| Kriteria | Skor | Catatan |
|----------|------|---------|
| 1 Kombat | 0/10 | Belum ada (sesuai urutan rencana). |
| 2 Crafting | 1/10 | Gabung benih 8 resep; kini di Meja Gabung Pusat Kota (server cek jarak meja 24 stud). |
| 3 Stat & Progresi | 0/10 | Tanpa sistem level (sesuai arah pemilik). |
| 4 Ekonomi | 5/10 | Micda 900.000 persisten lintas server (DataStore AKM_T1 global, sama di hub & dunia); Toko Benih & jual hasil di Pusat Kota. Belum: pasar dinamis, toko pemain. |
| 5 Dunia & Peta | 5/10 | Pusat Kota fungsional (spawn, gerbang dunia 10 stud, Toko Benih lengkap, Meja Gabung, papan, lampu) + dunia pribadi terinstans: 1 lahan penuh 500 plot + pagar + meja semai + papan nama pemilik + gerbang pulang. Belum: rumah/ruangan/kolam nyata, air, dungeon. |
| 6 Multiplayer | 6/10 | **Kunjung antar dunia nyata**: masuk dunia sendiri (instance pribadi), kunjungi pemain lain yang online (join server aktifnya) atau offline (mode baca dari data tersimpan); tamu TIDAK bisa tanam/panen/pukul/taruh - semua aksi mutasi ditolak server dengan pesan. Anti-ganggu terjamin. Belum: trade, party, daftar dunia publik. |
| 7 Bertani | 8/10 | 500 plot per dunia pribadi; tumbuh 3 dtk; panen 1-10/1-6/1-4; tas 50x250; **tanaman & meja semai kini PERSISTEN saat pemain offline** (timestamp readyAt disimpan, siap saat dimuat). |
| 8 Polish & UX | 5/10 | Panel Gerbang Dunia baru (Masuk Dunia-ku + Kunjungi via nama), label zona HUD (Pusat Kota / Dunia <nama>), toast status teleport. Belum: BGM, animasi, partikel. |
| 9 Originalitas | 10/10 | 100% karya sendiri; tanpa require ID, loadstring, getfenv, HttpService. |

**TOTAL: 40/100** (bobot: 0+15+0+75+50+60+80+50+50 = 380/10)

Riwayat: v10 = 56 -> v11 = 64 -> v20 = 79 -> v21 = 80 -> v25 = 83 -> v26 = 9 (RESET) -> v27 = 33 (TAHAP 1) -> v28 = 40 (TAHAP 2 dunia pribadi).
Celah menuju 100: kombat (15), ekonomi pemain (10), polish (5), dunia lebih kaya (5), multiplayer lanjut (4).

## Arsitektur dunia pribadi (v28) - tanpa ID manual, anti-lag

- Server Pusat Kota = join biasa (tanpa teleport data). Ringan (~70 part); bila
  ramai, Roblox otomatis membagi pemain ke beberapa server hub - tidak pernah
  jadi bottleneck.
- Dunia pribadi = server tersendiri via `ReserveServer(game.PlaceId)` - TIDAK
  perlu membuat/mengisi ID place apa pun. Beban komputasi & render dunia satu
  pemain sepenuhnya terisolasi dari pemain lain: ramai sekalipun tidak saling
  membuat lag (model Growtopia: 1 dunia = 1 server).
- Rendezvous: MemoryStoreSortedMap AKM_DuniaAktif (kunci d_<userId>, TTL 90 dtk,
  heartbeat 30 dtk) + save dunia tiap 60 dtk bila berubah, saat pemilik keluar,
  saat server kosong, dan BindToClose.
- Role: pemilik (aksi penuh) vs tamu (hanya lihat-jalan). PlotAct/SmashAct di
  dunia divalidasi role + kepemilikan lahan di server.
- Teleport gagal (Studio/awal server) ditangani pcall + pesan jujur; data rusak
  disanitasi (DuniaLogic: batas 500 plot, 6 slot meja, tipe ketat) - 90 tes PASS.

## Keamanan TAHAP 1 (wajib resep, semua dipenuhi)

- Semua logika uang, tas, pembelian, penjualan, pukulan, drop, combine di ServerScriptService.
- Semua RemoteFunction divalidasi server: pemilik lahan, jarak (plot 48, meja/kasir 24-30, gerbang prompt), saldo, dan batas laju per detik (token bucket per remote).
- Tanpa require ID angka, loadstring, getfenv, HttpService.
- Tanpa model/script luar - semua Part buatan sendiri.
- Data penting (Micda, tas) hanya di server + DataStore AKM_T1; ReplicatedStorage hanya config statis.

## Anti-lag TAHAP 1-2 (semua dipenuhi)

- Dunia pribadi = server terpisah (ReserveServer): beban terisolasi, ramai
  pemain keluar-masuk tidak mengganggu server lain.
- Plot = Part sederhana tanpa Script, diklon dari satu template.
- Sisa waktu tumbuh dihitung on-demand (readyAt timestamp), tanpa loop per plot;
  1 heartbeat per lahan hanya menyentuh plot yang baru siap.
- Visual tanaman hanya dibuat saat ditanam / dimuat dari data.
- Rendezvous MemoryStore hanya 1 operasi per 30 dtk per dunia; save dunia hanya
  bila berubah (flag dirty) tiap 60 dtk.
- StreamingEnabled aktif; semua objek Anchored; tanpa Mesh berat.

## Catatan penting place Pusat Kota

Semenjak v28, Pusat Kota dan dunia pribadi berada di place yang SAMA dan
dipisah lewat instancing ReserveServer - tidak ada lagi kebutuhan membuat
place kedua atau mengisi ID manual (PlaceConfig sudah dihapus dari kode).
Gerbang di dunia pribadi mengembalikan pemain ke Pusat Kota dengan
TeleportAsync biasa; gerbang di Pusat Kota membuka panel Masuk/Kunjungi dunia.

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
