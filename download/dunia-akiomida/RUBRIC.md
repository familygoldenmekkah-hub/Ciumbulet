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

## Skor v53 (versi LIVE #53, 7 Nov 2026) - SALDO AWAL 999,99 T + HUD SINGKATAN INDONESIA (Rb/Jt/M/T) + KETUK ANGKA PENUH

Permintaan pemilik: user baru kini dapat 999 Triliun 999 Miliar 999 Juta 999
Ribu Micda (999.999.999.999.000, hanya berjarak 1.000 dari atap 1000 T) dan
tampilan saldo HUD dibereskan: angka tidak boleh terpotong dua baris, pakai
singkatan Indonesia maksimal 2 desimal, kotak melebar otomatis, ketuk untuk
melihat angka lengkap bertitik, muat sampai 1.000 T, teruji layar kecil & besar.

Diterapkan di #53:

A. **CropData.StartMoney 1.000.000.000.000 -> 999.999.999.999.000** — user
   baru (dan reset data rusak) mulai hampir di atap rekening; ruang sisa
   1.000 Micda terdokumentasi jujur di tes.
B. **Modul baru Shared/UangSingkat** — singkatan Indonesia: Rb (ribu),
   Jt (juta), M (miliar), T (triliun); maks 2 desimal pakai KOMA Indonesia;
   FLOOR (tidak pernah melebihi saldo nyata; 999,99 T tetap 999,99 T,
   tidak membulat jadi 1.000 T); contoh pemilik terverifikasi tes:
   1 T dan 250,5 M persis; atap 1.000.000.000.000.000 tampil 1.000 T.
C. **HUD saldo dibangun ulang** — kotak kini TextButton "SaldoHUD" dengan
   AutomaticSize X (melebar mengikuti teks, UIListLayout horizontal,
   UISizeConstraint 150-560 px); angka "SaldoAngka" TextWrapped=false +
   TextTruncate aman (TIDAK PERNAH dua baris), TextSize tetap 22 di semua
   layar; satuan "Micda" ikut list; clamp lama yang menyempitkan kotak
   dihapus dari aturUkuranAman.
D. **Ketuk saldo = angka lengkap** — ketukan menoggle mode: singkat
   "999,99 T" <-> penuh "999.999.999.999.000" bertitik; mode penuh
   menyembunyikan satuan supaya muat di layar 375 px; semua jalur sync
   (GetState awal, Sync, syncState) kini lewat renderSaldo tunggal.
E. **Model lebar HUDLayout baru** — lebarTeksPx (estimasi em 0,62),
   lebarSaldoPx (dijepit 150-560), muatLayar: tes otomatis memastikan
   singkatan & angka penuh MUAT di 7 layar (640x360, 667x375, 844x390,
   915x412, 1284x720, 2224x1668, 375x667) dengan inset 0 & 12.
F. **Simulator playtest diperbaiki akarnya** (3 bug stub lama menumpuk
   sejak v50: MODULES_SHARED kehilangan KameraKunci & MesinLogika,
   stub kamera tanpa Focus, stub Enum tanpa CameraType) + gen.py kini
   AUTO-DETEKSI seluruh modul Shared dengan urutan topologis — tidak
   bisa lagi ada modul yang tertinggal di harness; skenario massa
   disesuaikan alur semai v50 (pop-up Atur Jumlah, Maks, Masukkan ke
   Mesin) dan playtest menambah 11 cek HUD saldo.
G. **Pengujian**: offline 396 PASS / 0 FAIL (+18: 14 singkatan, 3 muat
   layar, saldo awal & ruang 1.000), playtest 141 PASS / 0 FAIL (+11
   HUD: AutomaticSize, satu baris, ketuk 1 penuh, ketuk 2 singkat,
   satuan hilang/muncul, 1.000 T, 250,5 M), massa 118 PASS / 0 FAIL,
   luau-lsp 0 TypeError, rojo build sukses. Publish #53.

| # | Kriteria | Skor | Alasan |
|---|----------|------|--------|
| 1 Kombat | 0/10 | Belum ada monster/AI/bos. |
| 2 Crafting | 4.5/10 | Tetap dari #51. |
| 3 Stat & Progresi | 1/10 | Tanpa level (sesuai arah pemilik). |
| 4 Ekonomi | 8/10 | Saldo awal 999,99 T hampir di atap; HUD kini sanggup menampilkan sampai 1.000 T rapi tanpa terpotong. |
| 5 Dunia & Peta | 7/10 | Tetap dari #51. |
| 6 Multiplayer | 7/10 | Tetap dari #51. |
| 7 Bertani | 10/10 | Tetap; massa 118 lari ulang hijau dengan alur v50. |
| 8 Polish & UX | 10/10 | HUD saldo singkatan Indonesia + ketuk penuh + auto-lebar teruji 7 layar. |
| 9 Originalitas | 10/10 | UangSingkat & model lebar HUDLayout karya sendiri. |

**TOTAL: 58.8/100** (bobot: 0+67.5+10+120+70+70+100+100+50 = 587.5/10 = 58.75)

## Skor v52 (versi LIVE #52, 7 Nov 2026) - SALDO AWAL USER BARU: 1 TRILIUN MICDA

Permintaan pemilik: "Untuk saldo user baru sebelumnya kan 900.000 micda kini
kita ganti jadi 1 triliun micda ya."

Diterapkan di #52:

A. **CropData.StartMoney 900.000 -> 1.000.000.000.000** (1 Triliun Micda):
   berlaku untuk user baru DAN data rusak/kunci gagal yang di-reset ke
   default ( DataService.defaultData & jalur pemulihan load ).
B. **Selaras ekonomi super besar**: saldo awal kini proporsional dengan
   arah game ekonomi 1000 Triliun (0,1% dari atap rekening) — user baru
   langsung bisa bermain ekonomi skala besar tanpa menunggu grinding
   awal; atap 1000 T dari #51 tetap berlaku.
C. **Tidak menyentuh data lama**: pemain lama tetap membawa saldo
   tersimpannya; jepitan 1000 T saat load tetap berjalan.
D. **Pengujian**: seksi inti "Dana awal 1 Triliun Micda" + seksi U
   "Ujian dimulai dari dunia baru: 1 Triliun Micda & tas kosong" +
   aritmetika siklus penuh kini relatif terhadap StartMoney (tidak ada
   lagi angka hardcoded). Total tes offline 378 PASS / 0 FAIL,
   luau-lsp 0 TypeError, rojo build sukses. Publish #52.

| # | Kriteria | Skor | Alasan |
|---|----------|------|--------|
| 1 Kombat | 0/10 | Belum ada monster/AI/bos. |
| 2 Crafting | 4.5/10 | Tetap dari #51. |
| 3 Stat & Progresi | 1/10 | Tanpa level (sesuai arah pemilik). |
| 4 Ekonomi | 8/10 | Saldo awal 1 Triliun proporsional ekonomi super besar; atap 1000 T + deteksi anomali + guard transaksi tetap utuh. |
| 5 Dunia & Peta | 7/10 | Tetap dari #51. |
| 6 Multiplayer | 7/10 | Tetap dari #51. |
| 7 Bertani | 10/10 | Tetap dari #51. |
| 8 Polish & UX | 10/10 | Tetap dari #51. |
| 9 Originalitas | 10/10 | Tetap dari #51. |

**TOTAL: 58.8/100** (bobot: 0+67.5+10+120+70+70+100+100+50 = 587.5/10 = 58.75)

## Skor v51 (versi LIVE #51, 7 Nov 2026) - ANTI-CHEAT EKONOMI: TANPA BATAS ANGKA TETAP, DETEKSI ANOMALI, KICK AMAN-DATA

Permintaan pemilik (pesan langsung + screenshot kick 267 "Aktivitas tidak
sah terdeteksi berulang"): ini game ekonomi — nominal besar dan aksi cepat
adalah hal normal. Jangan pakai batas angka tetap; batas = rate x waktu x
multiplier progres player. Server yang menghitung semuanya, client hanya
kirim aksi. Deteksi anomali (lonjakan tak masuk akal, item tanpa sumber,
transaksi mustahil), bukan angka besar. Sebelum kick, simpan data dulu dan
jangan kick saat transaksi berjalan. Uang maksimal 1000 Triliun per user.

Akar masalah yang ditemukan (jujur): AuditService lama menghitung SEMUA
penolakan (micda_tolak, laju, argumen, jarak, milik, klaim_ganda) dalam
jendela 5 menit dan menendang di 20 insiden; UangLogic lama menolak
transaksi > 25.000 ("lonjakan") dan > 24 transaksi/menit ("laju"). Player
ekonomi cepat-kaya memicu tolak beruntun lalu ditendang salah — persis
kick 267 di screenshot. Dua sistem ini ditulis ulang total.

Diterapkan di #51:

A. **UangLogic v2 tanpa batas angka tetap**: MaksAksi 25.000 dan
   BatasPerMenit 24 DIHAPUS — transaksi 500 M dan 30 transaksi cepat
   berturut-turut kini sah (tes otomatis). Satu-satunya atap = kapasitas
   rekening 1.000.000.000.000.000 Micda (1000 T) sesuai ketentuan
   pemilik; melebihinya ditolak dengan aturan "ruang" + pesan jelas
   (bukan tuduhan kecurangan), data lama melebihi batas dijepit saat
   dimuat. UangLogic.format baru untuk pesan angka besar bertitik.
B. **Server menghitung semuanya (sudah struktural, kini diperkuat)**:
   client hanya mengirim aksi (id item + jumlah); server memvalidasi
   terhadap stok tas nyata, isi mesin, harga CropData, dan whitelist
   sumber (jual_hasil/beli_benih/semai_hasil/hadiah). Uang tidak pernah
   dikirim client.
C. **AuditService v2 deteksi anomali, bukan angka besar**: catat() kini
   hanya LOG — 280 penolakan biasa pun tidak akan menendang siapa pun
   (tes otomatis). Kick hanya lewat anomali() berbobot untuk hal yang
   mustahil secara logika: uang_korup (saldo negatif/NaN, bobot 100),
   uang_lebih (rekening lewat 1000 T, bobot 100), sumber_tak_dikenal
   (60), sesi_anomali (20); ambang 100 dalam jendela 1 jam.
D. **CurrencyService.startIntegritas()**: sapuan tiap 45 detik memastikan
   saldo tidak pernah negatif/NaN/melebihi 1000 T — jika ya, diperbaiki,
   data disimpan, dan anomali dicatat.
E. **Kick aman-data**: kickAman menyimpan data DULU, menunggu transaksi
   selesai (guard transaksiMulai/Selesai/sedangTransaksi, timeout 8 dtk),
   menyimpan lagi, baru menendang. Pesan kick baru jujur: "Aktivitas
   tidak mungkin terdeteksi. Data kamu sudah disimpan dengan aman."
F. **Semua remote uang/barang dibungkus guard transaksi**: SemaiAct
   (atur/tuas/klaim), ShopAct (buy/sell), GudangAct (simpan/ambil),
   TanamAct (start/jawab/gabung), PlotAct (punch) — kick tidak pernah
   memotong transaksi di tengah.
G. **Dua bug kehilangan data dibunuh** (inti "aman untuk data"):
   ShopService.sell dulu menghapus barang BARU menambah uang — kalau
   tambah uang gagal, barang hilang. Kini cek ruang rekening dulu,
   barang diambil, uang ditambah, dan kalau gagal barang DIKEMBALIKAN
   utuh ("Penjualan ditunda sebentar. Barangmu dikembalikan utuh ke
   tas."). MesinSemaiService.klaim sama: cek ruang dulu, kalau tambah
   micda gagal benih dikembalikan dan isi mesin tidak hangus.
H. **Rate limit tetap ada untuk spam remote** (bukan anti-cheat) dengan
   anggaran lebih lega: punch 12/s, tanam/gudang 6/s, semai 8/s, shop
   8/s, dunia 3/s — penolakannya hanya log, tidak pernah menendang.
I. **Kamera modal diperkuat (keluhan papan tanam)**: selama panel terbuka
   kamera kini CameraType Scriptable (rotasi, zoom, pan, dan drag luar
   pop-up benar-benar mati di semua platform), dipulihkan persis saat
   ditutup; ScreenGui DisplayOrder 50 menyerap sentuhan joystick/jump
   selama modal terbuka supaya fokus tidak terpecah.
J. **Pengujian**: seksi H ditulis ulang (22 cek ekonomi raksasa: 500 M
   diterima, 30 transaksi cepat lolos, atap 1000 T, ruangSisa, format,
   jepit data lama) + seksi H2 baru (8 cek audit: 280 tolak = 0 kick;
   anomali bobot & ambang; guard bertingkat; eksekutor kick aman).
   Total tes offline 378 PASS / 0 FAIL, luau-lsp 0 TypeError, rojo build
   sukses. Publish #51.

| # | Kriteria | Skor | Alasan |
|---|----------|------|--------|
| 1 Kombat | 0/10 | Belum ada monster/AI/bos. |
| 2 Crafting | 4.5/10 | Rantai mesin semai tetap; guard transaksi kini membungkus semua aksi mesin. |
| 3 Stat & Progresi | 1/10 | Tanpa level (sesuai arah pemilik); soal matematika tetap gerbang tanam. |
| 4 Ekonomi | 8/10 | Ekonomi 1000 T tanpa batas angka tetap, deteksi anomali berbobot, guard transaksi, rollback jual/klaim — nominal besar kini sah dan aman. |
| 5 Dunia & Peta | 7/10 | Tetap: drop rapi di atas tanah; belum: rumah, air, dungeon. |
| 6 Multiplayer | 7/10 | Semua mutasi uang/barang server-authoritative + terjaga transaksi; tamu tidak bisa merusak; trade/party belum ada. |
| 7 Bertani | 10/10 | Semai panen tetap sesuai spesifikasi; 20 cek seksi W tetap hijau. |
| 8 Polish & UX | 10/10 | Kamera Scriptable + DisplayOrder 50: modal kini benar-benar memencungkan fokus (zoom, rotasi, drag luar, joystick). |
| 9 Originalitas | 10/10 | UangLogic v2, AuditService v2, CurrencyService integritas — semua modul orisinal sendiri. |

**TOTAL: 58.8/100** (bobot: 0+67.5+10+120+70+70+100+100+50 = 587.5/10 = 58.75)

## Skor v50 (versi LIVE #50, 7 Nov 2026) - SEMAI PANEN: PILIH ITEM -> ATUR JUMLAH + KAMERA PANEL DIKUNCI

Permintaan pemilik (pesan langsung): "Waktu masuk papan tanam kan muncul.
Pop up kok bisa geser area luar harusnya jangan, jadi ngalihin fokus loh!
Lagi di menu papan tanam malah bisa zoom out zoom in itu jelek!" + revisi
UI & Logic mesin semai: buka mesin = daftar hasil panen di tas; klik item =
pop-up atur jumlah (-, +, Maks); satu jenis item per waktu, item sama boleh
ditambah sampai 2000; 7 skenario wajib diuji semuanya sebelum dikirim.

Diterapkan di #50:

A. **Alur baru mesin semai**: daftar item dirangkum per jenis via
   TasLogic.ringkas (250+250+250 = satu baris "Wortel x750", terhitung
   total); klik item membuka pop-up "Atur Jumlah Semai" dengan -, +, Maks
   (preset dihapus sesuai revisi); konfirmasi memasukkan item; tas kosong
   menampilkan pesan yang sesuai.
B. **Aturan satu jenis item (server-authoritative)**: item berbeda saat
   mesin berisi ditolak dengan notifikasi "Mesin sedang memproses [nama
   item]" (toast klien instan + MesinLogika.atur di server); item SAMA
   boleh di-top-up sampai kapasitas 2000 — pukulan & hasil gulingan
   ditambahkan linear, status tuas dipertahankan; saat menggiling atau
   tuntas-belum-diklaim isi baru ditolak; jumlah kecil (10) bisa langsung
   disemai; Maks = min(stok tas, sisa kapasitas) via MesinLogika.maksIsi.
C. **Validasi dua lapis**: melebihi stok ditolak dengan stok nyata,
   melebihi sisa kapasitas (2000 - isi mesin) ditolak, jumlah
   0/negatif/pecahan tidak bisa dikonfirmasi, mesin penuh 2000/2000
   menolak tambahan.
D. **Kamera panel dikunci**: dim & semua modal kini Active sehingga geser
   di luar pop-up tidak memutar kamera; zoom dikunci selama panel apa pun
   terbuka pada jarak saat dibuka (modul baru Shared/KameraKunci) dan
   dipulihkan persis saat panel ditutup — keluhan fokus papan tanam tuntas.
E. **Agregasi tas di semua daftar**: semai, toko (jual memakai total tas,
   bukan satu slot), gudang, papan tanam, Combine Seed.
F. **Pengujian**: seksi W baru 20 cek — 7 skenario wajib pemilik semuanya
   (tas kosong; 10 langsung semai; 750 dari 250+250+250; isi 2000 ditolak
   tambah; melebihi stok & kapasitas ditolak; proses A masukkan B ditolak
   dengan nama item; setelah A selesai B bisa) + top-up linear, tahap
   giling/tuntas, Maks, ringkas multi-slot, sisaKapasitas aman rusak;
   seksi X 7 cek KameraKunci. Tes offline 361 PASS / 0 FAIL, luau-lsp
   0 temuan, rojo build sukses. Publish #50.

| # | Kriteria | Skor | Alasan |
|---|----------|------|--------|
| 1 Kombat | 0/10 | Belum ada monster/AI/bos. |
| 2 Crafting | 4.5/10 | Rantai mesin semai kini alurnya benar-benar machine-flow: pilih item -> atur jumlah -> top-up -> tuas -> klaim. |
| 3 Stat & Progresi | 1/10 | Tanpa level (sesuai arah pemilik); soal matematika tetap gerbang tanam. |
| 4 Ekonomi | 7/10 | Isi mesin & stok tas kini tervalidasi ketat dua lapis (klien + server); inventaris bisa dipercaya. |
| 5 Dunia & Peta | 7/10 | Tetap: drop tergeletak rapi di atas tanah; belum: rumah, air, dungeon. |
| 6 Multiplayer | 6.5/10 | Aturan mesin berlaku server-side untuk semua pemain; trade/party belum ada. |
| 7 Bertani | 10/10 | Semai panen sesuai spesifikasi lengkap pemilik + 20 cek otomatis. |
| 8 Polish & UX | 10/10 | Panel tak lagi mencuri fokus: geser luar pop-up mati, zoom terkunci selama menu terbuka; daftar dirangkum per jenis. |
| 9 Originalitas | 10/10 | MesinLogika & KameraKunci modul orisinal sendiri. |

**TOTAL: 56.8/100** (bobot: 0+67.5+10+105+70+65+100+100+50 = 567.5/10 = 56.8)

## Skor v49 (versi LIVE #49, 7 Nov 2026) - PEMBERSIHAN OTOMATIS DATA LAMA: BLOK_PANEN DIHAPUS DARI TAS, SEMAI PANEN TERBACA LAGI

Laporan pemilik (pesan langsung): "Ini kok ada item namanya blok_panen, itu
wajib dihapus loh! Karena gak kita pakai, kemudian di semai panen kok hasil
item dari panen gak terbaca!"

Diagnosa jujur: kode #48 sudah bebas blok, TAPI data tas lama di DataStore
(tertulis sebelum #47) masih berisi slot "blok_panen" dan dimuat mentah tanpa
disaring. Item hantu itu ikut tampil di tas dan di daftar mesin semai (nama
mentah, 0 pukulan/item, ditolak server "Hasil panen tidak dikenal") sehingga
daftar hasil panen terasa "gak terbaca". Satu akar masalah, dua gejala —
keduanya dibunuh sekaligus.

Diterapkan di #49:

A. **Modul baru Shared/SanitasiTas** (murni, tanpa dependensi, teruji
   offline): bersih(raw, byId) menolak slot dengan id yang bukan tanaman
   resmi (blok_panen & kawan-kawan dibuang), kind selain "benih"/"hasil",
   count bukan angka/0/negatif; count 999 dijepit jadi 250; maksimal 50
   slot; tanpa daftar id yang sah semuanya ditolak (gagal-aman).
B. **DataService.load menyaring tas lama** sebelum dipakai; jumlah slot
   yang dibuang dilaporkan, data langsung ditandai kotor supaya versi
   bersih tersimpan ke DataStore pada siklus simpan berikutnya — data lama
   hanya dibersihkan SEKALI di dunia nyata.
C. **Notifikasi jujur**: pemain yang tasnya mengandung item lama menerima
   toast "Tas Dibersihkan - N item lama yang tidak dipakai sudah dibuang
   otomatis dari tas."
D. **Gudang dunia lama ikut divalidasi**: GudangLogic.simpan/ser/des kini
   menerima daftar id sah (dikirim GudangService dengan CropData.byId) —
   blok_panen dari simpanan dunia lama tidak bisa di-restore, disetor,
   maupun diambil (ambil menolak dengan "Barang tidak dikenal.").
E. **UI klien memfilter item tak dikenal** di ketiga titik masuk state.tas
   (GetState awal, GetState sync, Sync berkala) plus guard di daftar semai
   panen: slot asing tak pernah tampil lagi sebagai baris mati.
F. **Pengujian**: seksi V baru 13 cek (blok_panen dibuang saat load; 6 slot
   rusak dibuang & 3 sah tersisa; 999->250; gagal-aman tanpa daftar; tas
   60 slot dipangkas ke 50; SEMAI PANEN TERBACA LAGI — hasil wortel dari
   tas bersih bisa diatur jumlah & masuk mesin; blok_panen tak bisa masuk
   mesin) + 2 cek gudang baru. Tes offline 334 PASS / 0 FAIL, PLAYTEST
   130 PASS / 0 FAIL, UJIAN MASSA 116 PASS / 0 FAIL, luau-lsp 0 temuan,
   rojo build sukses. Publish #49.

| # | Kriteria | Skor | Alasan |
|---|----------|------|--------|
| 1 Kombat | 0/10 | Belum ada monster/AI/bos. |
| 2 Crafting | 4/10 | Rantai olah mesin semai kini bersih dari item hantu dari data lama. |
| 3 Stat & Progresi | 1/10 | Tanpa level (sesuai arah pemilik); soal matematika tetap gerbang tanam. |
| 4 Ekonomi | 7/10 | Tas & gudang kini menolak/membersihkan item ilegal termasuk dari save lama — inventaris bisa dipercaya penuh. |
| 5 Dunia & Peta | 7/10 | Tetap: drop tergeletak rapi di atas tanah; belum: rumah, air, dungeon. |
| 6 Multiplayer | 6.5/10 | Sanitasi berjalan di server untuk semua pemain; trade/party belum ada. |
| 7 Bertani | 10/10 | Semai panen kembali terbaca: hasil panen dari tas bersih bisa diatur jumlahnya & diproses mesin (13 cek baru). |
| 8 Polish & UX | 10/10 | Item asing tak pernah tampil lagi di tas/daftar; pembersihan diberi tahu lewat toast, bukan diam-diam. |
| 9 Originalitas | 10/10 | SanitasiTas & validasi gudang modul orisinal sendiri. |

**TOTAL: 56.0/100** (bobot: 0+60+10+105+70+65+100+100+50 = 560/10 = 56.0)

## Skor v47 (versi LIVE #48, 7 Nov 2026) - TANPA ITEM BLOK + NAMA BENIH "BENIH X" + DROP TIDAK PERNAH TENGGELAM LAGI + UJIAN SIKLUS PENUH

Permintaan pemilik (pesan langsung): (1) "Di item kita gak ada item namanya
blok ya itu dibuang aja" — item blok dihapus total; (2) benih wajib memakai
nama "Benih X" (mis. Benih Wortel) dan baru bernama "Wortel" setelah panen —
benih dan hasil matang harus terbedakan jelas; (3) hasil panen yang jatuh
jangan sampai tertelan ke dalam tanah — wajib tergeletak di atas tanah
(sebelumnya terkadang tenggelam kayak ngebug); (4) drop yang diambil masuk tas
sebagai tanaman dewasa (tanam Benih Wortel -> panen -> tas berisi Wortel);
(5) lakukan ujian: beli benih -> tanam -> panen -> lihat perubahan -> ambil ->
semai panen -> pastikan berfungsi, tanpa bug, terintegrasi server.

Diterapkan di #47:

A. **Item "blok" dibuang total**: helper CropData blokIdFor/blokNamaFor/
   blokCrop dihapus, rasio blok di konfigurasi giling dihapus, gulung mesin
   kini hanya menghasilkan Micda + benih, struk klaim & pop-up semai tidak
   lagi menampilkan baris blok, ikon slot blok dihapus dari UI tas.
B. **Penamaan benih "Benih X" ditegakkan**: fungsi baru CropData.namaBenih();
   slot tas kini menampilkan "Benih Wortel" untuk benih dan "Wortel" untuk
   hasil; daftar pilih benih di Papan Tanam, dua slot Combine Seed, struk
   pembelian pack, dan struk klaim semai semuanya memakai awalan "Benih ".
   Hasil panen tetap tampil sebagai nama dewasa (Wortel).
C. **Drop panen dijamin tergeletak di atas tanah (bug tenggelam dibunuh)**:
   modul baru Shared/TanahDrops (logika murni teruji offline); saat spawn,
   server menghitung permukaan tanah dengan raycast + aturan deterministik
   permukaan plot 1.4 stud, drop diangkat ke 0.55 stud di atas tanah sebelum
   memantul; pengawas 0.25 dtk mengangkat drop yang menembus tanah, dan
   setelah diam 2 tick (atau 2.5 dtk) drop dipastikan duduk di atas tanah lalu
   di-anchor — tidak mungkin tenggelam, tidak menggelinding jauh, tetap bisa
   diambil sentuh.
D. **Integrasi server dipertahankan**: klaim mesin kini hanya memberi Micda +
   benih (sesuai tanaman) lewat Tas.canFitBatch; raycast tanah mengecualikan
   karakter & folder drop/plot supaya tidak salah ambil permukaan.
E. **Ujian siklus penuh (seksi U baru)**: 15 cek end-to-end — beli pack common
   (900.000 -> 897.600) -> 3 Benih Wortel masuk tas -> tanam lewat papan ->
   panen punch 3 plot (yield 1-10) -> ambil drop masuk tas sebagai "Wortel"
   BUKAN benih -> semai panen atur jumlah seluruh hasil -> total pukulan =
   jumlah x 5 -> tuas KANAN lalu KIRI (kiri duluan DITOLAK) -> giling 3 dtk ->
   klaim Micda + benih kembali "Benih Wortel" -> nol item blok sepanjang
   siklus; plus 9 cek seksi T (TanahDrops: tenggelam terdeteksi, diangkat,
   di-anchor di atas tanah, area plot 1.4).
F. **Pengujian**: tes offline 319 PASS / 0 FAIL (naik dari 293), luau-lsp
   0 temuan, rojo build sukses. Playtest & massa dijalankan ulang setelah
   simulator diperbaiki (daftar modul gen.py + stub Roblox kurang CFrame
   __add/__sub, Rotation, IsDescendantOf — diperbaiki di simulator, bukan di
   kode game): PLAYTEST 130 PASS / 0 FAIL, UJIAN MASSA 116 PASS / 0 FAIL
   (alur dunia nyata: papan tanam -> punch -> drop di atas tanah -> sentuh
   masuk tas "Wortel" -> 5x pukul hancur -> 8 arketipe -> gudang -> tuas).
   Publish #48 (final).

| # | Kriteria | Skor | Alasan |
|---|----------|------|--------|
| 1 Kombat | 0/10 | Belum ada monster/AI/bos. |
| 2 Crafting | 4/10 | Mesin semai kini bersih: keluaran Micda + benih per tanaman; item palsu hilang dari rantai olah. |
| 3 Stat & Progresi | 1/10 | Tanpa level (sesuai arah pemilik); soal matematika tetap gerbang tanam. |
| 4 Ekonomi | 7/10 | Identitas item jelas (Benih X vs X) dan tidak ada lagi item hantu "blok" di tas/struk — ekonomi lebih bisa dipercaya. |
| 5 Dunia & Peta | 7/10 | Drop panen kini pasti tergeletak rapi di atas tanah/plot (tidak ada lagi hasil "tenggelam" di dalam tanah). |
| 6 Multiplayer | 6.5/10 | Klaim drop & tuas tetap dijaga per-pemilik; trade/party belum ada. |
| 7 Bertani | 10/10 | Siklus penuh beli -> tanam -> panen -> ambil -> semai -> klaim teruji 15 cek end-to-end dengan penamaan benih/hasil yang benar. |
| 8 Polish & UX | 10/10 | Nama "Benih Wortel" vs "Wortel" konsisten di semua layar; keluhan drop tenggelam (ngebug) hilang lewat pengawas tanah. |
| 9 Originalitas | 10/10 | Semua logika & model tetap buatan sendiri; TanahDrops modul orisinal. |

**TOTAL: 56.0/100** (bobot: 0+60+10+105+70+65+100+100+50 = 560/10 = 56.0)

## Skor v45 (versi LIVE #46, 7 Nov 2026 — #46 republish rename internal tanpa perubahan perilaku) - DUA TUAS KANAN-KIRI MENGGANTIKAN KABEL + POP-UP SEMAI LEBIH BESAR & JELAS

Permintaan pemilik (pesan langsung): (1) ganti mekanisme sambung kabel dengan
dua TUAS fisik di ujung kanan & ujung kiri mesin — aktifkan tuas kanan dulu,
kemudian tuas kiri; di tiap tuas ada tombol "Tekan Tuas" dan saat ditekan
tuasnya berpindah sendiri; keduanya selesai -> mesin langsung aktif; (2) label
"sambungkan kabel" dibuang semua; (3) pop-up semai panen terlalu kaku, kecil,
dan sulit dipahami — perlu lebih besar dan jelas.

Diterapkan di #45:

A. **Dua tuas baja fisik di mesin**: pedestal DiamondPlate di x=+12 (ujung
   kanan) dan x=-12 (ujung kiri), garpu baja, pin engsel, lengan tuas 3.4 stud
   dengan kenop neon merah; label "TUAS KANAN" / "TUAS KIRI" di tiap pedestal;
   lampu indikator per tuas (abu = diam, kuning = giliranmu, hijau = selesai);
   pipa penghubung ke badan mesin + garis peringatan kuning-hitam.
B. **Tombol "Tekan Tuas" nyata**: ProximityPrompt di tiap tuas (HoldDuration
   0.2, jarak 9 stud). Ditekan -> server memvalidasi (pemilik lahan, tahap
   tuas, urutan, jarak) lalu Lengan tuas beranimasi sendiri pindah ke posisi
   turun (tween server 0.45 dtk) + bunyi klak. Prompt tuas hanya AKTIF pada
   tuas yang sedang jadi giliran (kanan dulu -> baru kiri), jadi urutan tidak
   mungkin salah dari sisi UI.
C. **Server-authoritative penuh**: status tuas disimpan server (tuas.kanan /
   tuas.kiri); SemaiAct("tuas", sisi) menolak sisi asing, tekan ulang, dan
   KIRI sebelum KANAN dengan pesan jelas; kedua tuas selesai -> mesin LANGSUNG
   masuk tahap giling 3 dtk tanpa aksi tambahan.
D. **Kabel dihapus total**: minigame kabel (modal seret-soket), fungsi
   SemaiLogic buatKabel/saringSambung/putuskanKabel/kabelSelesai/WarnaKabel,
   aksi remote "kabel", dan label "Sambungkan Kabel" semuanya dihapus dari
   kode; papan mesin kini "TEKAN TUAS KANAN LALU KIRI".
E. **Pop-up semai dirancang ulang**: panel diperluas (maks 760x620 saat panel
   semai terbuka); strip 3 langkah bernomor (Pilih -> Isi jumlah -> Tekan 2
   tuas); baris hasil panen lebih tinggi; bagian "Atur jumlah" baru dengan
   tombol besar -/+ , chip jumlah 1/10/50/100/500, tombol Maks aksen, kotak
   jumlah besar; saat menunggu tuas tampil kartu langkah 1/2 dengan status
   SELESAI / TEKAN! / TUNGGU berwarna; tombol Isi & Klaim lebih besar.
F. **BUG DITEMUKAN & DIPERBAIKI saat ujian massa**: setelah rename variabel
   lokal "pedestal", prompt/suara/label tuas ternyata menempel ke pedestal
   panel kontrol (shadow variabel lama) sehingga prompt tak pernah aktif —
   terdeteksi ujian massa (prompt Enabled tidak berubah), akarnya ditemukan,
   diparent ulang ke pedestal tuas, massa kembali 0 FAIL.
G. **Pengujian**: tes offline 293 PASS / 0 FAIL (seksi P+Q baru: urutan
   kanan-kiri, 40 percobaan loncat urutan ditolak, saring sisi, tekan ulang);
   playtest 130 PASS / 0 FAIL; ujian massa 119 PASS / 0 FAIL dengan alur dari
   dunia nyata: prompt tuas kanan aktif duluan -> ditekan -> prompt pindah ke
   kiri -> tekan ulang kanan DITOLAK server -> kiri ditekan -> mesin langsung
   MENGGILING -> tuntas -> klaim; luau-lsp 0 temuan.

| # | Kriteria | Skor | Alasan |
|---|----------|------|--------|
| 1 Kombat | 0/10 | Belum ada monster/AI/bos. |
| 2 Crafting | 4/10 | Stasiun olah kini berbasis dua tuas fisik beranimasi yang dijaga server; konten crafting belum bertambah. |
| 3 Stat & Progresi | 1/10 | Tanpa level (sesuai arah pemilik); soal matematika tetap gerbang tanam. |
| 4 Ekonomi | 6.5/10 | Alur jual-beli + mesin semai tetap terjaga server; pasar dinamis & toko pemain belum ada. |
| 5 Dunia & Peta | 7/10 | Mesin kini punya dua tuas interaktif berlabel + lampu status di kedua ujung; belum: rumah, air, dungeon. |
| 6 Multiplayer | 6.5/10 | Semua aksi mutasi (termasuk tuas) divalidasi per-pemilik; trade/party belum ada. |
| 7 Bertani | 10/10 | Alur tanam -> panen -> isi mesin -> 2 tuas -> klaim teruji end-to-end (119 cek massa). |
| 8 Polish & UX | 10/10 | Pop-up semai jauh lebih lega dan jelas (langkah bernomor, kartu tuas berstatus, tombol besar); umpan balik tuas visual + suara. Sisa: BGM/ambience, uji perangkat fisik. |
| 9 Originalitas | 10/10 | Semua part, animasi tuas, dan interaksi dibangun asli; tanpa aset/require luar. |

**TOTAL: 55.25/100** (bobot: 0+60+10+97.5+70+65+100+100+50 = 552.5/10 = 55.25)

## Skor v44 (versi LIVE #44, 7 Nov 2026) - KABEL SERVER-AUTHORITATIVE (BUG INTEGRASI DITEMUKAN & DIPERBAIKI) + TIANG KANOPI 4X KARAKTER

Permintaan pemilik (pesan langsung): (1) tiang kanopi baja mesin semai
tingginya 4x tinggi karakter; (2) ujikan sambung kabel acak — apakah mudah
atau ada bug belum terintegrasi.

Hasil ujian kabel — DITEMUKAN BUG BELUM TERINTEGRASI (kritis):
layout kabel selama ini dibuat di KLIEN (bukaKabel memanggil buatKabel
lokal) dan server TIDAK PERNAH membuat/memvalidasi kabel — remote
`SemaiAct("kabel")` polos tanpa argumen langsung mengaktifkan mesin, jadi
exploiter bisa melewati minigame penjodohan sepenuhnya, dan "acak tiap
kali" tidak pernah dijamin server.

Diterapkan di #44:

A. **Kabel kini 100% server-authoritative**: layout dibuat server saat
   "atur" (disimpan di batch, dikirim ke klien hanya untuk ditampilkan);
   `kabelJadi` WAJIB menerima mapping soket kiri->kanan dan memvalidasinya
   lewat SemaiLogic.saringSambung + kabelSelesai di server; tanpa mapping,
   mapping kosong, bolong, di luar rentang, pecahan, atau tertukar semuanya
   DITOLAK.
B. **Anti brute-force "penjodohan ulang"**: 3x pengajuan salah -> server
   mengacak ulang susunan (versi naik) dan klien otomatis membangun ulang
   modal ("Susunan kabel berubah!") — menebak permutasi jadi sia-sia;
   percobaan salah 1-2x TIDAK menghapus jodohan parsial pemain.
C. **Kemudahan pakai (hasil uji "mudah")**: saat menyeret kabel, soket
   kanan yang dilewati ikut menyala — HIJAU bila warnanya jodoh, MERAH
   bila bukan; lepas di radius 36 px; mode ketuk kiri lalu kanan tetap ada.
D. **Tiang kanopi 4x tinggi karakter**: karakter acuan 5 stud -> tiang
   baja 20 stud (sebelumnya 8), tebal 1.2, pelat dasar per tiang, balok
   ikat atas empat sisi, penyokong silang X di kedua sisi; atap + garis
   merah-krem naik ke 21.3 stud; lampu diganti gantung tali panjang
   (neon hangat + PointLight) agar tetap menerangi mesin.
E. **Pengujian**: tes offline 291 PASS / 0 FAIL (seksi baru Q: 12 cek
   saringSambung/putuskanKabel/acak-ulang/keunikan susunan); playtest
   130 PASS / 0 FAIL; ujian massa 113 PASS / 0 FAIL dengan alur kabel
   end-to-end baru — soket DIBACA DARI LAYAR lalu: tanpa mapping DITOLAK,
   mapping kosong DITOLAK, mapping tertukar DITOLAK, 3x gagal -> susunan
   terlihat BERUBAH di layar, jodoh dari layar -> mesin aktif -> tuntas ->
   klaim; luau-lsp 0 temuan (3 TypeError palsu di file tes dibersihkan).

| # | Kriteria | Skor | Alasan |
|---|----------|------|--------|
| 1 Kombat | 0/10 | Belum ada monster/AI/bos. |
| 2 Crafting | 4/10 | Minigame kabel kini benar-benar dijaga server (tak bisa dilewati), kualitas stasiun olah naik; konten crafting belum bertambah. |
| 3 Stat & Progresi | 1/10 | Tanpa level (sesuai arah pemilik); soal matematika tetap gerbang tanam. |
| 4 Ekonomi | 6.5/10 | Alur jual-beli + mesin semai tetap; faucet Micda kini tak bisa dimanipulasi lewat remote. Pasar dinamis & toko pemain belum ada. |
| 5 Dunia & Peta | 7/10 | Kanopi mesin kini menjulang 4x karakter dengan penyokong X dan lampu gantung; belum: rumah, air, dungeon. |
| 6 Multiplayer | 6.5/10 | Naik dari 6: satu celah remote eksploit (skip kabel) ditutup + validasi mapping + anti brute-force; trade/party belum ada. |
| 7 Bertani | 10/10 | Alur tanam -> panen -> semai -> klaim teruji end-to-end (113 cek massa); blok per tanaman; tanpa blok_panen. |
| 8 Polish & UX | 10/10 | Minigame kabel kini memberi umpan balik langsung saat menyeret (hijau/merah), tetap bisa drag atau ketuk; pesan acak-ulang jelas. Sisa: BGM/ambience, uji perangkat fisik. |
| 9 Originalitas | 10/10 | Semua part, minigame, dan interaksi dibangun asli; tanpa aset/require luar. |

**TOTAL: 55.25/100** (bobot: 0+60+10+97.5+70+65+100+100+50 = 552.5/10 = 55.25)

## Skor v43 (versi LIVE #43, 6 Nov 2026) - MESIN SEMAI PANEN: GILING BERSAMBUNG KABEL, BLOK PER TANAMAN, BUG BLOK_PANEN DIHAPUS

Permintaan pemilik (pesan langsung): alur "pukul ambil" di semai panen
diganti mesin semai — pemain memilih hasil panen, mengatur jumlah (kapasitas
mesin 2000), total pukulan = jumlah x pukulan per item; mesin baru aktif
setelah pemain menjodohkan kabel warna-warni yang posisinya selalu acak;
3 detik menggiling lalu label "Semai Tuntas"; klik lagi untuk melihat hasil
(Micda + drop benih + drop blok) dan klaim. Blok hasil WAJIB sesuai tanaman
yang disemai (semai Nektarin = Blok Nektarin) dan item generik "Blok Panen"
adalah bug yang harus dihapus. Tempat & tampilan semai panen diupgrade:
mesin giling realistis, aesthetic, dan terhiasi.

Diterapkan di #43:

A. **Mesin semai menggantikan meja pukul**: modul server baru
   MesinSemaiService (SmashService dihapus) dengan tahap kosong -> kabel ->
   giling (3 dtk) -> tuntas -> klaim, semua server-authoritative: jumlah
   divalidasi Shared/SemaiLogic (1..min(stok, 2000)), item dipotong saat
   diatur, hadiah digulung saat batch dibuat (Micda per unit sesuai rarity,
   peluang benih, peluang blok), klaim butuh ruang tas (canFitBatch) dan
   jarak <= 24 dari mesin. Batch tersimpan (serMesin) dan data meja lama
   dimigrasi otomatis; jika keluar di tengah proses, batch kembali sebagai
   "tuntas" tanpa kehilangan barang.

B. **Penjodohan kabel acak**: setelah "Isi Mesin Semai", modal
   "Sambungkan Kabel Mesin" memunculkan 4-6 pasang soket warna (dari 8
   warna) yang urutan kiri-kanan dan posisi vertikalnya diacak tiap kali;
   pemain menyambung dengan menyeret (drag) atau mengetuk kiri lalu kanan;
   garis kabel tergambar antar soket, warna salah ditolak, semua terjodoh
   -> mesin menyala. Konfigurasi & validasi diuji di Shared/SemaiLogic
   (bijective, warna sama, tidak lengkap = ditolak).

C. **Hasil per tanaman + bug Blok Panen dihapus**: CropData.BlokId
   ("blok_panen") dihapus total; blok kini id "blok_<tanaman>" (Blok
   Nektarin, Blok Wortel, dst) dengan ikon tas berwarna tanaman. Semua
   hasil klaim hanya keluar sesuai tanaman yang disemai; tes khusus
   memastikan "blok_panen" tidak pernah ada di tas.

D. **Mesin giling realistis & area terhiasi**: BuildingKit.buildMesinSemai
   membangun mesin industri di lahan — pondasi baja, bodi mesin, drum
   giling silinder dengan 3 cincin oranye yang BERPUTAR saat menggiling,
   roda gila, 2 gir, motor berpendingin + cerobong asap berasap, corong
   hopper V, pedalaman kontrol dengan 3 lampu status (merah nonaktif /
   kuning kedip menunggu kabel / hijau tuntas), kabel merah-biru-kuning,
   layar status "MESIN SEMAI PANEN" dua sisi yang teksnya hidup
   (NONAKTIF / SAMBUNGKAN KABEL / MENGGILING... / SEMAI TUNTAS - KLAIM
   HASIL), suara giling loop + ding tuntas; area dihias kanopi baja
   bergaris, pagar, tong, peti hasil, karung, kotak alat, pipa dinding,
   dan garis peringatan kuning-hitam.

E. **Pengujian**: tes offline 279 PASS / 0 FAIL (seksi baru P "Mesin semai"
   15 cek: saring jumlah, pukulan total, gulung deterministik + rentang,
   kabel acak bijective & validasi); playtest penuh 130 PASS / 0 FAIL;
   ujian massa 108 PASS / 0 FAIL dengan 15 cek baru end-to-end (buka mesin
   -> pilih wortel -> isi 10 -> modal kabel -> mesin aktif -> SEMAI TUNTAS
   di papan -> Klaim Semua -> struk + Micda naik -> wortel berkurang 10 ->
   blok_wortel sesuai tanaman -> papan NONAKTIF lagi, tanpa blok_panen);
   luau-lsp 0 temuan.

F. **Ditemukan & diperbaiki saat menguji**: bug nyata di modal kabel
   (variabel menimpa fungsi warna -> error saat membuka modal) tertangkap
   ujian massa dan diperbaiki; skenario kini menutup panel seperti pemain
   nyata sehingga alur papan setelah mesin teruji benar.

| # | Kriteria | Skor | Alasan |
|---|----------|------|--------|
| 1 Kombat | 0/10 | Belum ada monster/AI/bos. |
| 2 Crafting | 4/10 | Naik dari 3: mesin semai = stasiun olah beneran (input hasil -> minigame penjodohan kabel -> giling -> output Micda/benih/blok per tanaman), tapi belum ada crafting alat/armor. |
| 3 Stat & Progresi | 1/10 | Tanpa level (sesuai arah pemilik); soal matematika tetap gerbang tanam. |
| 4 Ekonomi | 6.5/10 | Alur jual-beli + konfirmasi tetap; mesin menambah sink/faucet Micda. Pasar dinamis & toko pemain belum ada. |
| 5 Dunia & Peta | 7/10 | Area mesin semai kini terhiasi penuh (kanopi, pagar, tong, peti, pipa); belum: rumah, air, dungeon. |
| 6 Multiplayer | 6/10 | Kunjung instan/salinan, tamu read-only, kunci sesi; belum: trade, party. |
| 7 Bertani | 10/10 | Alur tanam -> panen -> semai -> klaim teruji end-to-end 108 cek; blok hasil per tanaman; bug blok_panen dihapus. |
| 8 Polish & UX | 10/10 | Mesin beranimasi (drum/gir/roda putar, asap, lampu status, suara), minigame kabel drag/tap yang jelas, struk klaim beranimasi; papan status dunia hidup. Sisa: BGM/ambience, uji perangkat fisik. |
| 9 Originalitas | 10/10 | Mesin, minigame kabel, dan semua hiasan dibangun dari part asli; suara memakai rbxasset bawaan engine; tanpa aset/require luar. |

**TOTAL: 54.75/100** (bobot: 0+60+10+97.5+70+60+100+100+50 = 547.5/10 = 54.75)

## Skor v42 (versi LIVE #42, 6 Nov 2026) - PUNCH TAHAN TOMBOL + TINJU BOKS, ATUR JUAL BERKONFIRMASI, JALAN & TOKO DIHIAS

Permintaan pemilik (pesan langsung): (1) tombol punch ditekan-tahan harus
tetap memukul terus (sekarang satu-satu kurang efisien); (2) setiap pukulan
harus terlihat tangannya bergerak seperti meninju — efek visual pukulan yang
lama tidak nampak; (3) jalan menuju Toko Benih dihias pernak-pernik, jangan
polos, desain lebih aesthetic; (4) bangunan toko juga lebih indah; (5) ganti
"Jual 1" menjadi "Atur Jual" — pemain sendiri yang menentukan jumlahnya —
dan WAJIB konfirmasi yes/no dulu, tidak boleh klik langsung terjual.

Diterapkan di #42:

A. **Punch tahan tombol (auto ulang)**: tombol PUNCH kini memakai
   InputBegan/InputEnded, bukan Activated. Ditekan = langsung memukul;
   ditahan = memukul berulang tiap 0,38 detik (PukulAnim.Ulang, di atas
   kooldown server 0,35 dtk sehingga tidak pernah "Terlalu cepat") sampai
   jari dilepas. Tap singkat tetap = satu pukulan. Combo & tier efek tetap
   naik selama menahan. Rate limit server 10/dtk aman untuk laju ini.

B. **Animasi tinju boks yang NAMPAK**: profil ayunan diganti — tangan
   diangkat ke belakang dulu (fase windup, sudut negatif), lalu
   dihantamkan cepat ke depan penuh (puncak 1,85 rad ≈ 106°), lalu kembali
   nol tepat di akhir 0,32 dtk. Eksekusi dipindah ke
   RunService:BindToRenderStep pada prioritas Character+1 sehingga gerakan
   MENANG dari animasi default Roblox setiap frame (penyebab lama "efek
   visualnya gak nampak"). Tinju bergantian tangan kanan-kiri secara
   otomatis (kanan-kiri-kanan...), mendukung R15 (RightShoulder/
   LeftShoulder) dan R6 (Right/Left Shoulder). Efek baru client-side:
   jejak sabetan neon dari tangan ke sasaran + kilau memuai di titik kena
   (makin besar saat tier kombo naik), di atas getar kamera & kick FOV
   yang sudah ada.

C. **Atur Jual + konfirmasi wajib**: tombol "Jual 1" diganti "Atur Jual"
   — membuka modal dengan kotak jumlah (default 1), pratinjau langsung
   "Jual N — total X Micda", tombol "Ya, Jual" / "Batal". Angka divalidasi
   modul baru Shared/JualLogic (bukan angka/pecahan/nol/negatif ditolak,
   dipotong ke stok, stok 0 selalu ditolak). "Jual Semua" juga kini lewat
   konfirmasi yang sama. Uang & pengurangan barang tetap dihitung server.

D. **Jalan ke Toko Benih dihias**: kedua sisi jalan pusat kota kini
   berisi 6 bed bunga berbingkai batu (bunga 5 warna), 16 lindung semak,
   4 pohon hias tiga bulatan, 2 bangku taman, 2 tiang bendera biru/emas
   di depan toko, 4 lampu taman bercahaya hangat, dan gerbang rambate
   kayu dengan 3 pot bunga gantung di ambang toko. Semua non-blocking
   (CanCollide false kecuali tiang/bangku) agar jalur jalan tetap lega.

E. **Bangunan Toko Benih lebih indah**: kanopi bergaris merah-krem di
   atas pintu, kotak bunga jendela 12 bunga, 2 lentera dinding menyala,
   2 bendera pennant di bubungan atap, lambang bundar merah-krem di
   fasad atas, tali lampu bohlam 7 titik di teras, dan 2 pot tanaman
   mengapit pintu.

F. **Pengujian**: tes offline kini 262 PASS / 0 FAIL (seksi baru N
   "Atur jual" 6 cek + O "Punch tahan tombol" 5 cek: interval 0,38 >
   kooldown 0,35, ayunan mulai negatif, menghantam > 1 rad, kembali nol);
   playtest penuh 130 PASS / 0 FAIL (penekanan tombol kini disimulasikan
   sebagai sentuhan asli InputBegan+InputEnded; stub diisi
   Enum.UserInputState, Enum.RenderPriority, RunService:BindToRenderStep,
   Vector3.__div/one/zero, CFrame.lookAt); ujian massa panen 93 PASS /
   0 FAIL (50 tanaman, kombo tier, ukuran drop per tier, tas penuh
   melayang lalu terserap). luau-lsp 0 TypeError; rojo build sukses;
   publish #42 (Open Cloud, versionNumber 42).

| Kriteria | Skor | Catatan |
|----------|------|---------|
| 1 Kombat | 0/10 | Belum ada (sesuai urutan rencana). |
| 2 Crafting | 3/10 | Combine Seed menu minimalis di papan (2 slot, tanpa petunjuk). |
| 3 Stat & Progresi | 1/10 | Tanpa level (sesuai arah pemilik); soal matematika tetap gerbang tanam. |
| 4 Ekonomi | 6.5/10 | Atur Jual (jumlah bebas + pratinjau total + konfirmasi) melengkapi alur jual-beli profesional; kedalaman ekonomi (pasar dinamis, toko pemain) belum ada. |
| 5 Dunia & Peta | 7/10 | Naik dari 6: jalan kota & fasad toko kini dihias penuh (bunga, lindung, pohon, bendera, lampu, kanopi, lambang). Belum: rumah, air, dungeon. |
| 6 Multiplayer | 6/10 | Kunjung instan/salinan, tamu read-only, kunci sesi; belum: trade, party. |
| 7 Bertani | 10/10 | Sesuai "Lahanan": pohon tidak pernah hilang, hasil aman selama online, kedaluwarsa 15 menit setelah keluar, klaim atomik; alur massa panen teruji end-to-end. |
| 8 Polish & UX | 10/10 | Naik dari 9.5: punch tahan tombol + tinju boks dua tangan yang benar-benar terlihat (prioritas render di atas animasi default) + jejak sabet & kilau kena; Atur Jual berkonfirmasi; popup gerbang tertutup otomatis. Sisa: BGM/ambience, uji perangkat fisik. |
| 9 Originalitas | 10/10 | 100% karya sendiri; animasi via motor6d asli (bukan aset), semua hiasan dari part; tanpa aset/require luar. |

**TOTAL: 53.25/100** (bobot: 0+45+10+97.5+70+60+100+100+50 = 532.5/10 = 53.25)

## Skor v41 (versi LIVE #41, 6 Nov 2026) - KONFIRMASI BELI + STRUK HASIL + POPUP GERBANG TERTUTUP + BADAI SYNC DIPERBAIKI

Permintaan pemilik (pesan langsung): (1) beli pack common/rare tidak boleh
langsung potong — harus muncul label konfirmasi yes/no dulu, lalu setelah
"Ya" muncul pop up berisi benih apa yang didapat dengan daftar rincian yang
jelas, supaya kesan profesional; (2) pop up Gerbang Dunia harus hilang
sendiri saat pemain memilih tujuan, bukan tetap terbuka setelah teleport.

CATATAN JUJUR VERSI: sesi mandiri otomatis sempat menerbitkan #40 dan menulis
dokumentasi berisi efek struk berjenjang (UIScale easing Back, jeda 70
ms/baris) dan modal 268 px — KODE TERSEBUT TIDAK ADA di sumber yang dibangun
menjadi #41. Berikut dokumentasi yang sesuai kode #41 yang benar-benar live.

Diterapkan di #41:

A. **Konfirmasi pembelian**: tombol Pack Common / Pack Rare TIDAK lagi
   membeli langsung — membuka modal "Konfirmasi Pembelian" berisi nama
   pack, jumlah & kategori benih, harga (2.400 / 9.000 Micda), dan tombol
   "Ya, Beli" / "Batal". Batal menutup tanpa efek; hanya "Ya" yang mengirim
   ShopAct("buy"). Server tetap satu-satunya pihak yang memotong uang &
   meracak benih.

B. **Struk pembelian (popup rincian)**: setelah pembelian sukses muncul
   modal "Pembelian Berhasil" — daftar baris benih (ikon bentuk tanaman
   orisinal + nama resmi + jumlah xN), baris total "Total N Micda · benih
   sudah masuk tas", tombol Oke. Struk dirangkum server-side lewat modul
   baru Shared/StrukBeli (agregasi pick kembar, urutan kemunculan pertama
   dipertahankan); klien hanya menggambar.

C. **Popup Gerbang Dunia tertutup otomatis**: Masuk Dunia-ku / Pulang ke
   Pusat Kota / Kunjungi — begitu server menjawab sukses, panel langsung
   closePanel() (popup hilang serentak dengan teleport); bila gagal, panel
   tetap terbuka agar pemain bisa mencoba lagi, pesan galat lewat toast.

D. **BUG BADAI SYNC DITEMUKAN & DIPERBAIKI (penting untuk keandalan)**:
   panel Papan Tanam pada tab Status memanggil TanamAct("status") ulang di
   SETIAP event Sync/TanamSync — 50 pukulan panen raya = 50+ panggilan
   server, rate limit tanam 3/6 dtk meluap, AuditService mencatat 20
   insiden lalu MENENDANG pemain yang sah. Kini tab Status hanya memuat
   ulang lewat klik tab atau tombol "Perbarui" (refresh klien tanpa
   memanggil server untuk tab lain). Ditemukan berkat alat uji yang
   dihidupkan kembali (lihat E).

E. **Alat uji dihidupkan kembali (jujur)**: generator playtest/massa
   ternyata membeku sejak v39 — daftar modul gen.py tidak pernah
   diperbarui (CurrencyService/AuditService dsb. hilang) dan stub
   DataStore tidak punya UpdateAsync sehingga SEMUA load dianggap kunci
   sesi dan profil pemain kosong. Kini diperbaiki; seluruh skenario
   disesuaikan dengan UI v39-v41 (tombol punch ikon, baris tanam
   klik-baris, tombol jumlah, teks status "Siap/Tumbuh", atribut drop
   DropId/LahanIdx, arah & jarak pukul server, kooldown 0.35 dtk).
   HASIL: tes offline 251 PASS / 0 FAIL (seksi baru "Struk pembelian
   toko" 8 cek), playtest 130 PASS / 0 FAIL, ujian massa panen 93 PASS /
   0 FAIL; luau-lsp 0 temuan; publish #41 (Open Cloud, versionNumber 41).

| Kriteria | Skor | Catatan |
|----------|------|---------|
| 1 Kombat | 0/10 | Belum ada (sesuai urutan rencana). |
| 2 Crafting | 3/10 | Combine Seed menu minimalis di papan (2 slot, tanpa petunjuk). |
| 3 Stat & Progresi | 1/10 | Tanpa level (sesuai arah pemilik); soal matematika tetap gerbang tanam. |
| 4 Ekonomi | 6/10 | Alur beli kini profesional (konfirmasi + struk server-side) tapi kedalaman ekonomi belum berubah: belum pasar dinamis, toko pemain. |
| 5 Dunia & Peta | 6/10 | Kota hanya Toko Benih; tiap lahan: Papan Tanam + Gudang. Belum: rumah, air, dungeon. |
| 6 Multiplayer | 6/10 | Kunjung instan/salinan, tamu read-only, kunci sesi mencegah dupe lintas server; badai sync yang bisa menendang pemain sah kini hilang. Belum: trade, party. |
| 7 Bertani | 10/10 | Sesuai "Lahanan": pohon tidak pernah hilang, hasil panen aman selama online, kedaluwarsa 15 menit setelah keluar, klaim drop atomik; alur massa panen teruji ulang end-to-end (93 tahap). |
| 8 Polish & UX | 9.5/10 | Naik dari 9: konfirmasi beli yes/no + struk rincian menjawab keluhan "kurang profesional"; popup gerbang tak lagi menggantung; bug badai sync (potensi kick pemain sah) ditemukan & diperbaiki. Struk #41 masih tanpa animasi berjenjang. Sisa: BGM/ambience, uji perangkat fisik. |
| 9 Originalitas | 10/10 | 100% karya sendiri; ikon struk memakai bentuk tanaman orisinal; tanpa aset/require luar. |

**TOTAL: 51/100** (bobot: 0+45+10+90+60+60+100+95+50 = 510/10 = 51)

## Skor v39 (versi LIVE #39, 6 Nov 2026) - REVISI FINAL: UI, SISTEM PANEN, SERVER-AUTHORITATIVE & ANTI-EXPLOIT

Permintaan pemilik (halaman "Lahanan") diterapkan menyeluruh:

A. **UI**: (1) Micda + "Masuk Dunia-ku" kini SATU KOLOM VERTIKAL rata kiri di
   bawah bar Roblox (TopbarInset + margin 10 px), UIListLayout menjamin jarak
   konsisten & posisi tidak bergeser saat teks berganti; (2) tombol PUNCH
   baru: TANPA tulisan, ikon kepalan tangan (9 bagian frame orisinal),
   UIStroke tipis, UIGradient halus, bayangan, efek tekan (mengecil ke 0.9
   saat ditekan), ukuran 0.92x Jump, di KIRI Jump dengan jarak 12-20 px,
   dasar segaris Jump.

B. **Pohon vs Hasil Panen dipisah tegas**: pohon (tumbuh maupun matang) selalu
   tersimpan + progres 5x pukul ikut tersimpan (h/l di payload) — tidak pernah
   terhapus batas waktu; hasil panen yang belum diambil tersimpan ke DataStore
   dan HANYA kedaluwarsa 15 menit sejak pemain KELUAR (HARVEST_EXPIRE_SECONDS
   = 900, waktu server os.time()); selama online tidak ada penghapusan berbasis
   usia; hitungan diulang dari keluar terbaru; rejoin < 15 menit = drop
   muncul kembali di posisi semula.

C. **Server-authoritative total**: CurrencyService satu pintu (Get/Add/Spend)
   dengan alasan transaksi di-whitelist, cek saldo atomik, saldo tak pernah
   minus, batas 24 mutasi/menit, tolak lonjakan > 25.000/aksi, LEDGER 24
   transaksi (pemain, jumlah, alasan, waktu, status) tersimpan; semua
   penolakan dicatat AuditService ([AUDIT] log + kick otomatis pada 20
   insiden/5 menit); kunci sesi (session lock) UpdateAsync mencegah satu
   akun diproses dua server sekaligus (data tamu tidak pernah menimpa data
   asli); save kini UpdateAsync + retry 3x (DataService & ZonaService);
   autosave 75 dtk; BindToClose menyimpan & melepas semua kunci; drop diberi
   ID unik + klaim ATOMIK (ada -> proses -> ambil) satu kali per ID, cek
   jarak <= 14 stud + kepemilikan di server, batas 80 drop/lahan (FIFO).

D. **Anti-cheat waktu**: kematangan & kedaluwarsa murni waktu server
   (GetServerTimeNow/os.time); tidak ada remote yang menerima waktu/jumlah/
   harga/status dari klien; cooldown pukul 0.35 dtk dihitung server.

E. **Pengujian (jujur)**: 6 seksi tes baru (H-M) mensimulasikan exploit di
   level logika murni: Micda palsu/negatif/NaN/huge/tipe salah/lonjakan/
   laju -> semua ditolak, saldo tetap; kunci sesi segar ditolak & basi
   diterima; klaim ganda/milik orang/jarak jauh/NaN ditolak; rejoin 899 dtk
   vs 900 dtk; persistensi pohon+drop dengan sanitasi ketat. Ini SIMULASI
   LOGIKA di luau CLI, bukan eksploitasi nyata lintas perangkat; penguji UI
   7 ukuran layar (tambah 2224x1668 tablet) tetap level matematika layout.

Validasi: luau-lsp 0 temuan; tes offline 243 PASS / 0 FAIL. Publish #39.

| Kriteria | Skor | Catatan |
|----------|------|---------|
| 1 Kombat | 0/10 | Belum ada (sesuai urutan rencana). |
| 2 Crafting | 3/10 | Combine Seed menu minimalis di papan (2 slot, tanpa petunjuk). |
| 3 Stat & Progresi | 1/10 | Tanpa level (sesuai arah pemilik); soal matematika tetap gerbang tanam. |
| 4 Ekonomi | 6/10 | Naik dari 5: uang kini server-authoritative penuh (CurrencyService + ledger + batas laju + tolak lonjakan + kunci sesi anti-dupe + UpdateAsync retry). Belum: pasar dinamis, toko pemain. |
| 5 Dunia & Peta | 6/10 | Kota hanya Toko Benih; tiap lahan: Papan Tanam + Gudang. Belum: rumah, air, dungeon. |
| 6 Multiplayer | 6/10 | Kunjung instan/salinan, tamu read-only, kunci sesi mencegah dupe lintas server. Belum: trade, party. |
| 7 Bertani | 10/10 | Kini sesuai "Lahanan": pohon tidak pernah hilang (progres pukul ikut tersimpan), hasil panen aman selama online, hanya terhapus 15 menit setelah keluar, label peringatan di Papan Tanam, klaim drop atomik satu ID satu kali. |
| 8 Polish & UX | 9/10 | Punch tombol profesional (ikon kepalan orisinal, stroke, gradient, bayangan, efek tekan), posisi 12-20 px kiri Jump ukuran 0.92x, kolom kiri rapi konsisten di 7 ukuran layar. Sisa: BGM/ambience, uji perangkat fisik. |
| 9 Originalitas | 10/10 | 100% karya sendiri; ikon punch dari frame orisinal; tanpa aset/require luar. |

**TOTAL: 50.5/100** (bobot: 0+45+10+90+60+60+100+90+50 = 505/10 = 50.5)

## Skor v35 (versi LIVE #35, 6 Nov 2026) - REVISI HUD LAYAR GAME

Laporan pemilik: saldo kiri atas tertutup ikon menu Roblox (angka terpotong,
ikon & satuan hilang), tombol navigasi tidak menyesuaikan teks, dan PUNCH
terlalu jauh dari jempol (hampir di tengah layar). v35 menjawab ketiganya:

1. **SALDO** — dipindah ke bawah area ikon menu Roblox memakai safe area
   GuiService.TopbarInset (ikut berubah bila inset berubah); kini tampil
   utuh ikon M + ANGKA + SATUAN "Micda" sebagai tiga elemen terpisah dengan
   teks menyesuaikan ukuran layar (TextScaled + batas 11-22 px).
2. **TOMBOL NAVIGASI** — tepat di bawah saldo, rata kiri, jarak kecil
   konsisten (2% tinggi aman); AutomaticSize X dengan UISizeConstraint
   min/maks yang dihitung dari skala layar; nama panjang terpotong
   (TextTruncate) dan tidak pernah keluar kotak; ANCHOR kiri membuat
   POSISI TIDAK BERGESER saat teks berganti "Masuk Dunia-ku" <-> "Pulang
   ke Kota".
3. **PUNCH** — matematika posisi ditulis ulang dari piksel ke SKALA MURNI
   (KontrolHP baru): di KIRI Jump, jarak tepat 1 ukuran jump, ukuran 1.24x
   jump (sedikit lebih besar), dasar segaris Jump, dan zona tanam tengah
   layar dijamin tidak tertutup; bila layar sempit, jarak menyusut
   terkendali (min 0.4x jump) tanpa pernah menimpa Jump.
4. **TEKNIS & UJI** — semua posisi/ukuran HUD (saldo, nav, tas, zona, punch)
   berbasis skala + area aman; diuji otomatis di 6 ukuran layar
   (640x360, 667x375, 844x390, 915x412, 1284x720, 375x667 potret) dengan
   23 tes HUD baru: saldo tak tertutup inset, ikon+angka+satuan utuh,
   nav pendek/panjang/raksasa, posisi stabil, punch vs jump di tiap layar.

Validasi: tes offline 188 PASS / 0 FAIL, playtest 116 PASS / 0 FAIL,
ujian massa panen 94 PASS / 0 FAIL, luau-lsp 0 temuan. Publish #35.

| Kriteria | Skor | Catatan |
|----------|------|---------|
| 1 Kombat | 0/10 | Belum ada (sesuai urutan rencana). |
| 2 Crafting | 3/10 | Combine Seed menu minimalis di papan: 2 slot, tanpa petunjuk, hanya tombol Gabung. |
| 3 Stat & Progresi | 1/10 | Tanpa level (sesuai arah pemilik); soal matematika bertingkat tetap gerbang progres tanam. |
| 4 Ekonomi | 5/10 | Micda 900.000, tas 50x250, pack Common/Rare, jual hasil, gudang 1000 tampungan. Belum: pasar dinamis, toko pemain. |
| 5 Dunia & Peta | 6/10 | Kota hanya Toko Benih; tiap lahan: Papan Tanam 2 sisi + Gudang. Belum: rumah, air, dungeon. |
| 6 Multiplayer | 6/10 | Kunjung instan/salinan, tamu read-only. Belum: trade, party. |
| 7 Bertani | 10/10 | Alur FINAL pemilik utuh & teruji end-to-end (massa panen 94 tahap): papan, soal tiap 10 plot, punch siap -> drop disentuh, 5x pukul tumbuh hancur, combine 8 resep, gudang 250->999->998. |
| 8 Polish & UX | 9/10 | Turun dari 10 ke 9 dengan jujur: v34 ternyata masih menyisakan 3 cacat HUD yang dilaporkan pemilik (saldo tertutup, nav kaku, punch molor). v35 memperbaiki semuanya + teruji 6 ukuran layar. Sisa: BGM/ambience, belum sentuh perangkat fisik. |
| 9 Originalitas | 10/10 | 100% karya sendiri (model drop, ikon, animasi motor6d manual); suara hanya rbxasset bawaan engine; tanpa require ID, loadstring, getfenv, HttpService. |

**TOTAL: 49/100** (bobot: 0+45+10+75+60+60+100+90+50 = 490/10 = 49)

## Skor v34 (versi LIVE #34, 6 Nov 2026) - REVISI TAMPILAN HP

Permintaan pemilik "REVISI GAME (TAMPILAN HP)" dikerjakan dengan urutan
yang diminta (D,E,F -> G -> A,B,C -> H) dan diuji ganda: tes offline 175
PASS / 0 FAIL (5 seksi baru: drop bentuk, animasi punch, presisi punch,
tombol HP, papan aman HP) + playtest simulasi 116 PASS / 0 FAIL (kini
termasuk klik tombol PUNCH asli, drop diperiksa bentuk/warna per 8 arketipe,
aturan tombol per tab, safe area, batas ukuran panel). Publish #34.

| Kriteria | Skor | Catatan |
|----------|------|---------|
| 1 Kombat | 0/10 | Belum ada (sesuai urutan rencana). |
| 2 Crafting | 3/10 | Combine Seed kini menu minimalis di papan: 2 slot, tanpa petunjuk, hanya tombol Gabung di tabnya. |
| 3 Stat & Progresi | 1/10 | Tanpa level (sesuai arah pemilik); soal matematika bertingkat tetap gerbang progres tanam. |
| 4 Ekonomi | 5/10 | Micda 900.000, tas 50x250, pack Common/Rare, jual hasil, gudang 1000 tampungan. Belum: pasar dinamis, toko pemain. |
| 5 Dunia & Peta | 6/10 | Kota hanya Toko Benih; tiap lahan: Papan Tanam 2 sisi + Gudang. Belum: rumah, air, dungeon. |
| 6 Multiplayer | 6/10 | Kunjung instan/salinan, tamu read-only. Belum: trade, party. |
| 7 Bertani | 10/10 | Alur FINAL pemilik tetap utuh; drop panen kini berbentuk tanamannya sendiri dan ikon tas mengikuti bentuk/warna (verifikasi playtest per arketipe). |
| 8 Polish & UX | 10/10 | Seluruh daftar tampilan HP pemilik terpenuhi & teruji: drop bentuk tanaman, animasi punch + momen kena sinkron + getar bertingkat, presisi raycast + highlight, PUNCH berjarak >= 1 tombol dari Jump di area jempol, papan minimalis bebas overlap (safe area, tab garis bawah, tombol per tab, truncate, skala + batas ukuran). Sisa: BGM/ambience. |
| 9 Originalitas | 10/10 | 100% karya sendiri (model drop, ikon, animasi motor6d manual); suara hanya rbxasset bawaan engine; tanpa require ID, loadstring, getfenv, HttpService. |

**TOTAL: 50/100** (bobot: 0+45+10+75+60+60+100+100+50 = 500/10 = 50)

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
panen + 3 perbaikan akar: penarget punch, state lahan, render tab combine)
-> v34 = 50 (revisi tampilan HP: drop bentuk tanaman, animasi & presisi
punch, tombol kontrol HP, papan tanam minimalis) -> v35 = 49 (revisi HUD
layar game: saldo utuh di bawah ikon menu, nav dinamis stabil, punch skala
murni dekat Jump; skor Polish dikoreksi jujur 10 -> 9 karena v34 masih
menyisakan 3 cacat HUD yang dilaporkan pemilik) -> v39 = 50.5 (revisi final
"Lahanan": UI rapi, pohon vs hasil panen dipisah, server-authoritative total,
anti-exploit) -> v41 = 51 (konfirmasi beli + struk hasil + popup gerbang
tertutup otomatis; bug badai sync yang bisa menendang pemain sah ditemukan &
diperbaiki; alat uji playtest/massa dihidupkan kembali dan seluruhnya hijau).
Celah menuju 100: kombat (15), ekonomi pemain (10), dunia lebih kaya (4),
BGM (0-1), multiplayer lanjut (4), crafting lanjut (12), animasi struk (0.5).

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
