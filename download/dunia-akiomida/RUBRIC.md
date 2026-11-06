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

## Skor v31 (versi LIVE #31, 6 Nov 2026) - SISTEM TANAM-PANEN BARU: PAPAN TANAM + SOAL MATEMATIKA + PUNCH + GUDANG

Permintaan pemilik dieksekusi penuh ("Sekarang fokus ke tempat tanam plot"):
1. **Tanam lewat Papan** — tidak lagi klik plot satu per satu. Papan Tanam
   berdiri di tepi blok plot tiap lahan dengan label fisik "TERTANAM X/500"
   yang hidup. Dekati papan -> panel: pilih jenis benih + jumlah (preset
   10/50/100/250/Maks atau angka bebas) -> plot terisi otomatis 10 per 10.
2. **Soal matematika acak** — setiap 10 plot dibuka dengan 1 soal: 250 benih =
   25 soal, 500 plot = 50 soal. Selalu acak per pemain per sesi (tidak pernah
   sama, SoalLogic + test anti-duplikat 220 soal). Jawaban salah -> soal
   TERTAHAN sampai benar (soal yang sama tetap tampil). Kesulitan naik:
   soal 1-20 tambah/kurang, 21-35 kali, 36+ bagi.
3. **Panen dengan PUNCH** — tidak lewat menu/klik plot. Tombol PUNCH besar
   muncul di layar saat pemain dekat tanaman siap-panen miliknya; hasil
   panen terpental fisik (memantul, bunyi, partikel); kombo pukulan beruntun
   (x4, x8) memperbesar efek + suara. Hasil diambil dengan menyentuh drop.
4. **Tas penuh = hasil melayang** — drop yang tidak muat melayang (anchor +
   bob tween) dengan label "Tas Penuh! Ke Gudang" dan TIDAK bisa diambil
   sampai tas ada ruang.
5. **Gudang hasil panen** — bangunan baru di tiap lahan (rak penuh peti,
   karung, pot). Setor 1-250 buah = memakai 1 tampungan dari 1000 (250 ->
   sisa 999 -> 998, persis contoh pemilik, terverifikasi simulasi + test).
   Ambil kembali per slot (semua / 100). Gudang persisten per dunia
   (AKM_Dunia field gd, sanitasi GudangLogic).
6. Perbaikan lanjutan laporan lama: tombol perjalanan cepat "Masuk/Pulang"
   di HUD (balik lahan tidak lagi tergantung gerbang), teleport diperkuat
   (placeWait + settle streaming 0,8 dtk + gagal-aman 8 dtk), beli benih
   longgar (radius 45, batas laju 10), rak toko tambah buah + karung + pot,
   gabung benih tetap HANYA di lahan: sesi benih pasangan mengubah plot
   yang berisi pasangan resepnya; pusat kota tetap hanya Toko Benih.

Simulasi alur main (modul asli): 250 benih -> 25 soal (1 salah tertahan) ->
250 plot -> panen 500 -> setor 250 (sisa 999) -> setor 250 (sisa 998) ->
ambil (sisa 999). Tes 132 PASS / 0 FAIL, luau-lsp 0 temuan.

| Kriteria | Skor | Catatan |
|----------|------|---------|
| 1 Kombat | 0/10 | Belum ada (sesuai urutan rencana). |
| 2 Crafting | 2/10 | Gabung benih 8 resep kini lewat Papan Tanam (sesi benih pasangan mengubah plot berisi A); tetap tanpa crafting lain. |
| 3 Stat & Progresi | 1/10 | Tanpa level (sesuai arah pemilik), tapi soal matematika bertingkat kini jadi gerbang progres tanam (mini-edukasi). |
| 4 Ekonomi | 5/10 | Micda 900.000 & tas 50x250 persisten; pack Common/Rare; jual hasil; GUDANG 1000 tampungan x 250 buah = kapasitas penyimpanan besar baru (persisten). Belum: pasar dinamis, toko pemain. |
| 5 Dunia & Peta | 6/10 | Kota hanya Toko Benih (aturan pemilik, rak makin penuh); tiap lahan kini punya Papan Tanam fisik + bangunan Gudang berisi pernak-pernik. Belum: rumah, air, dungeon. |
| 6 Multiplayer | 6/10 | Kunjung instan/salinan, tamu read-only; tombol perjalanan cepat; teleport placeWait. Belum: trade, party. |
| 7 Bertani | 9/10 | Alur tanam BARU sesuai pemilik: papan pilih benih+jumlah, auto-isi 10 plot/soal, label TERTANAM X/500 fisik, soal acak bertingkat, panen PUNCH dengan drop fisik kombo, tas penuh = melayang, gudang 1000x250. |
| 8 Polish & UX | 8/10 | Tombol PUNCH on-screen dekat tanaman siap; drop memantul + bunyi + partikel + kombo; FOV kick pukulan; label papan & gudang hidup; panel soal/gudang/tanam baru; perjalanan cepat 1 klik. Belum: BGM, animasi karakter. |
| 9 Originalitas | 10/10 | 100% karya sendiri; suara hanya rbxasset bawaan engine; tanpa require ID, loadstring, getfenv, HttpService. |

**TOTAL: 44/100** (bobot: 0+30+10+75+60+60+90+80+50 = 455/10 = 45,5,
dibulatkan ke bawah agar jujur)

Riwayat: v10 = 56 -> v11 = 64 -> v20 = 79 -> v21 = 80 -> v25 = 83 -> v26 = 9
(RESET) -> v27 = 33 (TAHAP 1) -> v28 = 40 -> v29 = 39 -> v30 = 42 -> v31 =
44 (sistem tanam-panen baru sesuai blueprint pemilik).
Celah menuju 100: kombat (15), ekonomi pemain (10), dunia lebih kaya (4),
polish (2), multiplayer lanjut (4), crafting lanjut (13).

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
