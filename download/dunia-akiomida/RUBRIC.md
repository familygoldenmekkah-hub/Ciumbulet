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

## Skor v33 (versi LIVE #33, 6 Nov 2026) - UJIAN MASSA PANEN + 3 PERBAIKAN AKAR

Permintaan pemilik "uji tunggu massa panen, panen, combine, dan efektivitas
punch" dijawab dengan ujian end-to-end baru (94 tahap, semua hijau):

1. **BUG FATAL PUNCH DITEMUKAN & DIPERBAIKI** — loop penarget PUNCH di klien
   mencari PlotGrid langsung di folder Dunia, padahal grid berada di dalam
   model seksi lahan. Akibatnya tombol PUNCH tidak pernah punya target sejak
   fitur ini ada. Kini dicari rekursif -> tombol layar benar-benar memukul
   tanaman terdekat (terverifikasi: tombol memanggil PlotAct -> drop muncul).
2. **BUG STATE LAHAN DIPERBAIKI** — tombol HUD "Masuk Dunia-ku / Pulang ke
   Kota" tidak pernah menyegarkan state klien, jadi setelah perjalanan cepat
   penarget punch mati. Kini travel HUD memanggil syncState, dan payload Sync
   server membawa lahan (provider baru) sehingga semua jalur teleport selalu
   sinkron.
3. **BUG TAB COMBINE DIPERBAIKI** — membuka tab Combine Seed menampilkan
   daftar benih kosong sampai ada perubahan tas berikutnya. Kini daftar dua
   slot langsung terisi saat tab dibuka.
4. **UJIAN MASSA PANEN (94 PASS / 0 FAIL)** — tanam 50 wortel lewat papan
   (5 soal inline, papan fisik 0 -> 50/500), status Masih Tumbuh 50 -> tunggu
   3+ detik -> Siap Panen 50 + warna buah berubah, panen raya: pukulan
   pertama lewat TOMBOL PUNCH asli (kick kamera terasa), 49 pukulan lanjutan,
   kombo tier 1 -> 2 -> 3 (drop 1.8 -> 2.1 -> 2.4 + partikel/suara), 50 drop
   disentuh satu per satu -> 288 buah masuk tas persis, papan kembali 0/500;
   bayam tumbuh dipukul beruntun 5x -> hancur tanpa drop; combine GUI
   Gandum+Rye -> Triticale, ditolak "Tidak bisa di-combine" dengan benih
   utuh, 8 resep rahasia jadi semua + urutan dibalik tetap jadi; Tangelo
   ditanam (bentuk pohon, warna siap sendiri) dan dipanen; gudang 250 -> 999
   -> 998; tas penuh = drop melayang tak bisa diambil sampai ada ruang.

Validasi: tes offline 127 PASS / 0 FAIL, ujian massa panen 94 PASS / 0 FAIL,
playtest simulasi 72 PASS / 0 FAIL, luau-lsp 0 temuan. Publish #33.

| Kriteria | Skor | Catatan |
|----------|------|---------|
| 1 Kombat | 0/10 | Belum ada (sesuai urutan rencana). |
| 2 Crafting | 3/10 | Combine Seed kini menu penemuan di papan: 2 slot tanpa petunjuk, 8 hibrida dengan bentuk unik masing-masing. |
| 3 Stat & Progresi | 1/10 | Tanpa level (sesuai arah pemilik); soal matematika bertingkat tetap gerbang progres tanam. |
| 4 Ekonomi | 5/10 | Micda 900.000, tas 50x250, pack Common/Rare, jual hasil, gudang 1000 tampungan. Belum: pasar dinamis, toko pemain. |
| 5 Dunia & Peta | 6/10 | Kota hanya Toko Benih; tiap lahan: Papan Tanam 2 sisi + Gudang. Dunia kini bersih dari teks instruksi. Belum: rumah, air, dungeon. |
| 6 Multiplayer | 6/10 | Kunjung instan/salinan, tamu read-only kini juga untuk papan tanam (pemberitahuan di dalam panel). Belum: trade, party. |
| 7 Bertani | 10/10 | Alur FINAL pemilik kini TERUJI end-to-end: papan saja, 10 plot/soal, tunggu matang, punch siap -> drop peluang disentuh (tombol asli kini benar-benar memukul), punch tumbuh 5x hancur, status per jenis, combine 8 resep, tas penuh melayang. |
| 8 Polish & UX | 9/10 | PUNCH permanen, 34 bentuk tanaman unik + warna siap berbeda, efek pukul tanaman tumbuh, panel papan 3 tab rapi, dunia tanpa teks melayang. Belum: BGM, animasi karakter. |
| 9 Originalitas | 10/10 | 100% karya sendiri; suara hanya rbxasset bawaan engine; tanpa require ID, loadstring, getfenv, HttpService. |

**TOTAL: 49/100** (bobot: 0+45+10+75+60+60+100+90+50 = 490/10 = 49)

Riwayat: v10 = 56 -> v11 = 64 -> v20 = 79 -> v21 = 80 -> v25 = 83 -> v26 = 9
(RESET) -> v27 = 33 (TAHAP 1) -> v28 = 40 -> v29 = 39 -> v30 = 42 -> v31 =
44 -> v32 = 48 (revisi final tanam-panen pemilik) -> v33 = 49 (ujian massa
panen + 3 perbaikan akar: penarget punch, state lahan, render tab combine).
Celah menuju 100: kombat (15), ekonomi pemain (10), dunia lebih kaya (4),
polish (1), multiplayer lanjut (4), crafting lanjut (12).

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
