# DUNIA AKIOMIDA (Roblox)

Status: LIVE di Roblox (**versionNumber 60**, 7 Nov 2026) — **DATA TIDAK PERNAH NOL LAGI: BUG PEMUSNAH DATA DIBUNUH — SESI DARURAT TIDAK PERNAH MENIMPA DATA ASLI, KUNCI SESI DIULANG 4X (REJOIN CEPAT AMAN), DUNIA PULIH SENDIRI DI LATAR SAAT DATASTORE GAGAL**
BARU 999,99 T + HUD SINGKATAN INDONESIA + ANTI-CHEAT
EKONOMI: TANPA BATAS ANGKA TETAP, DETEKSI ANOMALI, KICK AMAN-DATA**:

1. **AKAR KICK 267 DITEMUKAN & DIBUNUH** — AuditService lama menghitung
   SEMUA penolakan (uang ditolak, laju, argumen, jarak, milik, klaim
   ganda) dalam 5 menit dan menendang di 20 insiden; UangLogic lama
   menolak transaksi > 25.000 Micda ("lonjakan") dan > 24 transaksi/menit
   ("laju"). Player ekonomi cepat-kaya kena tolak beruntun lalu ditendang
   salah ("Aktivitas tidak sah terdeteksi berulang" — persis screenshot).
   Keduanya ditulis ulang total.
2. **TANPA BATAS ANGKA TETAP (permintaan pemilik)** — batas transaksi
   25.000 dan batas 24 transaksi/menit DIHAPUS: jual 500 M Micda atau 30
   transaksi kilat berturut-turut kini sah (ada tes otomatisnya). Yang
   dicurigai bukan lagi angka besar, hanya hal yang mustahil secara
   logika. Satu-satunya atap: kapasitas rekening **1000 Triliun Micda**
   (1.000.000.000.000.000) per user sesuai ketentuan pemilik — melewati
   itu ditolak dengan aturan "ruang rekening" + pesan jelas, bukan
   tuduhan kecurangan.
3. **SERVER MENGHITUNG SEMUANYA** — client hanya mengirim aksi (id item +
   jumlah); server memvalidasi stok tas nyata, isi mesin, harga, dan
   whitelist sumber uang (jual_hasil/beli_benih/semai_hasil/hadiah).
   Uang tidak pernah dikirim oleh client.
4. **DETEKSI ANOMALI BERBOBOT** — penolakan biasa kini hanya LOG (280
   penolakan pun tidak menendang siapa pun). Kick hanya lewat anomali
   mustahil: saldo korup/negatif (bobot 100), rekening lewat 1000 T
   (100), uang tanpa sumber sah (60), sesi anomali (20); ambang 100 per
   jam. Sapuan integritas tiap 45 detik menjaga saldo tetap 0..1000 T.
5. **KICK AMAN-DATA** — kalau kick terpaksa: data DISIMPAN dulu, tunggu
   transaksi berjalan selesai (guard transaksi di semua remote
   SemaiAct/ShopAct/GudangAct/TanamAct/PlotAct), simpan lagi, baru
   menendang. Tidak ada uang/barang hilang atau dobel.
6. **DUA BUG KEHILANGAN DATA DIBUNUH** — jual: dulu barang dihapus dulu
   baru uang ditambah (kalau gagal, barang hangus); kini cek ruang
   rekening dulu dan kalau gagal barang dikembalikan utuh. Klaim mesin:
   cek ruang dulu; kalau micda gagal, benih dikembalikan dan isi mesin
   tetap bisa diklaim ulang.
7. **KAMERA MODAL DIPERKUAT (keluhan papan tanam)** — selama panel
   terbuka kamera Scriptable: zoom, rotasi, pan, dan geser di luar
   pop-up benar-benar mati di semua platform; joystick/jump terserap
   supaya fokus tidak terpecah; semuanya dipulihkan persis saat panel
   ditutup.
8. **PENGUJIAN** — seksi H ditulis ulang (22 cek ekonomi raksasa) +
   seksi H2 baru (8 cek audit & kick aman-data). Total tes offline 378
   PASS / 0 FAIL, luau-lsp 0 TypeError, rojo build sukses. Publish #51.
9. **SALDO AWAL USER BARU 1 TRILIUN MICDA (#52)** — sesuai permintaan
   pemilik, StartMoney 900.000 -> 1.000.000.000.000: user baru langsung
   main ekonomi super besar (0,1% dari atap rekening 1000 Triliun);
   data pemain lama tidak disentuh; aritmetika tes kini relatif
   StartMoney tanpa angka hardcoded.
10. **SALDO 999,99 T + HUD SINGKATAN INDONESIA (#53)** — StartMoney naik
   ke 999.999.999.999.000 (999 Triliun 999 Miliar 999 Juta 999 Ribu;
   hanya 1.000 di bawah atap). HUD saldo dibangun ulang: kotak
   AutomaticSize X melebar mengikuti teks; angka SATU BARIS selamanya
   (TextWrapped=false); singkatan Indonesia Rb/Jt/M/T maks 2 desimal
   koma via modul baru Shared/UangSingkat (floor, tak pernah
   melebihi saldo; 1 T & 250,5 M persis contoh pemilik; atap tampil
   1.000 T); KETUK kotak saldo = angka lengkap bertitik
   999.999.999.999.000 (satuan disembunyikan agar muat layar 375 px);
   teruji 7 ukuran layar kecil-besar. Simulator playtest juga
   diperbaiki akarnya (stub kamera Focus, Enum.CameraType, modul
   KameraKunci/MesinLogika yang hilang; gen.py kini auto-deteksi
   modul) — playtest 141, massa 118, offline 396, semua 0 FAIL.

Isi v50 tetap (semai panen alur baru + kamera panel):

1. **ALUR BARU MESIN SEMAI PERSIS SPESIFIKASI PEMILIK** — membuka mesin kini
   menampilkan DAFTAR hasil panen di tas (contoh: "Wortel x250, Tomat x10"),
   dirangkum PER JENIS: 250+250+250 slot berbeda tampil satu baris "Wortel
   x750" dan semuanya terhitung. Klik salah satu item -> muncul pop-up "Atur
   Jumlah Semai" dengan tombol -, +, dan Maks (tanpa preset). Setelah
   konfirmasi, item masuk ke mesin. Tas kosong menampilkan pesan yang sesuai.
2. **ATURAN SATU JENIS ITEM + TOP-UP + KAPASITAS 2000** — mesin hanya
   memproses satu jenis item dalam satu waktu; memasukkan item BERBEDA saat
   mesin masih berisi DITOLAK dengan notifikasi "Mesin sedang memproses [nama
   item]" (toast klien + validasi server). Item SAMA boleh ditambah sampai
   batas kapasitas 2000 — top-up menambah total pukulan & hasil gulingan
   secara linear dan status tuas dipertahankan. Jumlah kecil (10) pun bisa
   langsung disemai. Tombol Maks = jumlah terkecil antara stok di tas dan
   sisa kapasitas mesin.
3. **VALIDASI LENGKAP** — tidak bisa input melebihi stok di tas (pesan
   menyebut stok nyata), tidak bisa melebihi sisa kapasitas (2000 dikurangi
   isi mesin), jumlah 0/negatif/pecahan tidak bisa dikonfirmasi, mesin penuh
   2000/2000 menolak tambahan, dan saat menggiling/tuntas-belum-diklaim isi
   baru ditolak.
4. **KAMERA PANEL DIKUNCI (keluhan papan tanam)** — geser area di luar
   pop-up TIDAK LAGI memutar kamera (semua dim/modal kini Active = input
   diserap), dan zoom in/out DIKUNCI selama menu papan tanam/panel apa pun
   terbuka: jarak kamera dikunci di posisi saat panel dibuka (modul baru
   Shared/KameraKunci) dan dipulihkan persis saat panel ditutup.
5. **AGREGASI TAS DI SEMUA DAFTAR** — TasLogic.ringkas dipakai di daftar
   semai, toko (jual memakai total tas, bukan satu slot), gudang, papan
   tanam, dan Combine Seed — 250+250+250 tidak lagi muncul sebagai tiga
   baris terpisah.
6. **PENGUJIAN 7 SKENARIO WAJIB PEMILIK SEMUANYA** — seksi W baru 20 cek:
   tas kosong (pesan sesuai); 1 jenis 10 langsung semai; 250+250+250 semai
   sekaligus 750; isi tepat 2000 lalu tambah lagi DITOLAK; input melebihi
   stok & kapasitas DITOLAK; mesin proses A masukkan B DITOLAK; setelah A
   selesai B bisa — plus top-up, tahap giling/tuntas, Maks, dan agregasi.
   Seksi X 7 cek kamera. Tes offline 361 PASS / 0 FAIL, luau-lsp 0 temuan,
   rojo build sukses. Publish #50.

Isi v45-v46 tetap (dua tuas kanan-kiri menggantikan kabel + pop-up semai
lebih besar & jelas):

1. **DUA TUAS FISIK DI UJUNG MESIN** — minigame sambung kabel DIHAPUS TOTAL
   (modal, fungsi SemaiLogic kabel, remote "kabel", dan label "Sambungkan
   Kabel" semua dibuang). Kini ada dua tuas baja berlabel TUAS KANAN (ujung
   kanan) & TUAS KIRI (ujung kiri) dengan garpu, pin engsel, kenop neon merah,
   lampu indikator per tuas, pipa penghubung, dan garis peringatan.
2. **TOMBOL "TEKAN TUAS" NYATA & BERFUNGSI** — ProximityPrompt di tiap tuas;
   ditekan -> server memvalidasi (pemilik, tahap, urutan, jarak) lalu lengan
   tuas BERPINDAH SENDIRI ke posisi turun (tween 0.45 dtk) + bunyi klak.
   Urutan WAJIB: tuas KANAN dulu, lalu tuas KIRI — prompt hanya aktif pada
   tuas yang jadi giliran, dan server menolak tekan-ulang / kiri-duluan /
   sisi asing. Lampu tuas: abu diam, kuning giliran, hijau selesai.
3. **KEDUANYA SELESAI -> MESIN LANGSUNG MENYALA** — tanpa aksi tambahan masuk
   tahap giling 3 dtk -> "SEMAI TUNTAS - KLAIM HASIL" -> klaim Micda + benih +
   blok sesuai tanaman. Papan mesin kini berbunyi "TEKAN TUAS KANAN LALU KIRI".
4. **POP-UP SEMAI DIRANCANG ULANG (keluhan: kaku, kecil, sulit dipahami)** —
   panel diperluas sampai 760x620; strip 3 langkah bernomor (Pilih -> Isi
   jumlah -> Tekan 2 tuas); bagian "Atur jumlah" baru dengan tombol besar -/+
   , chip 1/10/50/100/500, Maks aksen, kotak jumlah besar; saat menunggu tuas
   tampil kartu langkah 1/2 berstatus SELESAI / TEKAN! / TUNGGU; tombol Isi
   & Klaim lebih besar.
5. **BUG DITEMUKAN & DIPERBAIKI UJI MASSA** — setelah rename variabel lokal,
   prompt/suara/label tuas menempel ke pedestal panel kontrol (shadow
   variabel) sehingga prompt tak pernah aktif; terdeteksi ujian massa (Enabled
   tak berubah), diparent ulang ke pedestal tuas, semua tes kembali 0 FAIL.

Isi v44 tetap: tiang kanopi 4x tinggi karakter, mesin giling 3 detik, klaim
Micda + benih + blok SESUAI tanaman, kapasitas mesin 2000, mesin berkanopi
terhias.

Isi v42 tetap: punch tahan tombol + tinju boks terlihat, Atur Jual
berkonfirmasi, jalan & toko dihias, beli pack berkonfirmasi + struk, popup
Gerbang Dunia tertutup otomatis.

1. **PUNCH TAHAN TOMBOL** — tombol PUNCH kini berbasis InputBegan/
   InputEnded: ditekan langsung memukul, DITAHA = memukul terus tiap 0,38
   dtk sampai jari dilepas (tap singkat = satu pukulan). Interval selalu di
   atas kooldown server 0,35 dtk sehingga tanpa "Terlalu cepat".
2. **TINJU BOKS YANG TERLIHAT** — ayunan baru: tangan diangkat ke belakang,
   dihantam ke depan penuh (~106°), kembali nol; dieksekusi lewat
   BindToRenderStep prioritas Character+1 sehingga menang dari animasi
   default Roblox (akar masalah "efek visualnya gak nampak"); tinju
   bergantian kanan-kiri, mendukung R15 & R6; plus jejak sabetan neon
   tangan->sasaran dan kilau memuai di titik kena (membesar saat kombo naik).
3. **ATUR JUAL + KONFIRMASI WAJIB** — "Jual 1" diganti "Atur Jual": pemain
   menulis jumlahnya, pratinjau total Micda langsung muncul, baru "Ya, Jual"
   / "Batal"; "Jual Semua" ikut berkonfirmasi. Validasi jumlah di modul baru
   Shared/JualLogic; uang & stok tetap dihitung server.
4. **JALAN KE TOKO DIHIAS** — bed bunga berbingkai batu (6), lindung semak
   (16), pohon hias (4), bangku taman (2), tiang bendera biru/emas (2),
   lampu taman hangat (4), dan gerbang rambate kayu berpot bunga di ambang
   toko — semua tidak menghalangi jalan.
5. **BANGUNAN TOKO LEBIH INDAH** — kanopi bergaris merah-krem, kotak bunga
   jendela, lentera dinding menyala, bendera pennant di atap, lambang bundar
   fasad, tali lampu bohlam teras, pot mengapit pintu.

Isi v41 tetap: beli pack berkonfirmasi (Ya/Batal) + struk daftar benih yang
didapat; popup Gerbang Dunia langsung tertutup saat pemain memilih tujuan;
bug badai sync (kick pemain sah) diperbaiki; alat uji playtest/massa hidup.

Universe: 10774464946 · Place: 77626159664192 · Label era: 10.0.3 "Benih X & Tanah Kering"
Build: `tools/rojo build default.project.json -o build/DuniaAkiomida.rbxlx`
(luau-lsp 0 temuan; tes offline 319 PASS / 0 FAIL; playtest 130 PASS / 0 FAIL;
ujian massa 116 PASS / 0 FAIL — termasuk ujian siklus penuh beli->tanam->
panen->ambil->semai->klaim dan pagar tanpa-blok)

Skor banding Toram/Growtopia: **56.0/100** — lihat `RUBRIC.md`.

Isi era 9.8 (tetap berlaku):

1. **D — DROP SESUAI TANAMAN** — drop panen kini model mini produce per
   arketipe (akar/pohon/tangkai/kacang/cendawan/dst, 8 pembentuk) memakai
   warna siap tanaman, muncul dengan pantulan fisik + partikel + suara, dan
   tiap slot tas mendapat ikon geometri yang sesuai bentuk + warnanya.
2. **E — ANIMASI & EFEK PUNCH** — karakter memainkan ayunan tangan asli
   (motor6d, original) SETIAP tombol ditekan; momen kena disinkronkan 0.12
   detik setelah tekan; efek getar kamera naik dengan tier kombo; partikel
   & suara tepat di titik kena.
3. **F — PRESISI PUNCH** — raycast dari karakter ke depan (jangkauan 14)
   dengan fallback hitbox kerucut; tanaman yang akan kena diberi highlight;
   efek & drop lahir di titik pukul; server menghitung sasarannya sendiri
   (anti-curang), bukan percaya klien.
4. **G — TOMBOL KONTROL HP (diperbaiki v35)** — PUNCH kini MURNI SKALA,
   menempel di area jempol kanan bawah: di KIRI tombol Jump asli dengan
   jarak tepat 1 ukuran jump, ukuran 1,24x jump (sedikit lebih besar), dasar
   segaris dengan Jump, dan dijamin tidak menutupi area tanam di tengah
   layar — teruji di 6 ukuran layar (360p-720p + potret).
5. **A+B+C — PAPAN TANAM MINIMALIS** — panel berbasis skala + batas ukuran
   + safe area 56 px (judul & tab tak lagi tertutup tombol menu), tab teks
   dengan garis bawah aktif, daftar dibersihkan tiap pindah tab, nama benih
   panjang terpotong rapi, baris utuh bisa diklik (tanpa tombol Pilih), tab
   Tanam = tombol angka 1/10/50/100/250/Maks + Mulai Tanam, tab Combine =
   hanya tombol Gabung (label Benih A/B di baris tersendiri, tidak lagi
   menimpa teks lain), hijau hanya untuk aksi utama, satu font tiga ukuran.
6. **REVISI HUD (v35)** — seluruh HUD kini berbasis skala murni + area aman
   GuiService.TopbarInset: SALDO pindah ke bawah ikon menu Roblox dan kini
   utuh (ikon M + angka + satuan "Micda", teks menyesuaikan ukuran layar);
   tombol "Masuk Dunia-ku / Pulang ke Kota" tepat di bawah saldo, rata kiri,
   AutomaticSize dengan batas lebar min/maks, nama panjang terpotong, dan
   POSISINYA TIDAK BERGESER saat teks berganti; tombol Tas & label zona ikut
   diatur ulang ke skala. Diuji di 6 ukuran layar HP.

Universe: 10774464946 · Place: 77626159664192 · Label era: 9.8.1 "Toko Profesional"
Build: `tools/rojo build default.project.json -o build/DuniaAkiomida.rbxlx`
(luau-lsp 0 temuan, tes offline 251 PASS / 0 FAIL, playtest 130 PASS / 0 FAIL,
ujian massa 93 PASS / 0 FAIL)

Skor banding Toram/Growtopia: **51/100** — lihat `RUBRIC.md`.

## Alur tanam-panen FINAL (revisi pemilik, teruji massa v33)

- **TANAM LEWAT PAPAN** — plot tidak merespons klik/tap sama sekali (popup
  "Plot Tanam" dan semua teks instruksinya dihapus, termasuk untuk lahan
  pemain lain). Dekati papan -> pilih benih + jumlah -> papan fisik menampilkan
  "TERTANAM X/500" (dua sisi papan hidup).
- **SOAL TIAP 10 PLOT** — 500 plot = 50 soal matematika dasar, tampil inline
  di papan; acak per pemain, tidak pernah sama, salah = tertahan sampai benar;
  kesulitan naik tambah/kurang -> kali -> bagi.
- **COMBINE SEED DI PAPAN** — menu hanya berisi dua slot benih + tombol Gabung.
  Tidak ada daftar resep/petunjuk; cocok = benih hibrida; tidak cocok = papan
  menampilkan "Tidak bisa di-combine" dan benih TIDAK terpakai. 8 resep rahasia
  di server: Triticale, Canola, Tangelo, Plumcot, Nectaplum, Pluerry,
  Tetsukabuto, Kacang tanah.
- **PUNCH PERMANEN & PRESISI (v34)** — tombol selalu ada di layar; kini
  raycast presisi di depan karakter + highlight sasaran + animasi ayunan
  karakter; pukul tanaman siap -> drop berbentuk tanaman sesuai peluang
  (peluang tetap rahasia, tanpa label); drop belum masuk tas sampai
  disentuh. Pukul tanaman masih tumbuh boleh kapan saja tanpa drop; 5x
  beruntun -> tanaman hancur.
- **STATUS DI PAPAN** — tab Status: per jenis "Siap Panen: N / Masih Tumbuh: M".
- **VISUAL** — tanaman siap panen berubah warna; tiap jenis (termasuk hibrida)
  punya bentuk model sendiri (8 arketipe geometri + warna/ukuran per jenis);
  drop panen & ikon tas mengikuti bentuk + warna tanamannya (v34).
- **LARANGAN** — nol teks melayang/popup dunia untuk tanam-panen (label drop &
  "Tas Penuh" dihapus; tas penuh cukup lewat drop melayang). Satu-satunya
  notifikasi: "Tidak bisa di-combine" di dalam papan.
- **GUDANG** (tetap dari v31) — setor 1-250 buah = 1 dari 1000 tampungan
  (250 -> sisa 999 -> 998 persis contoh pemilik), ambil kembali, persisten.
- **PERBAIKAN LANJUTAN** — tombol "Masuk Dunia-ku / Pulang ke Kota" 1 klik di
  HUD; teleport placeWait; beli benih jalan (playtest memverifikasi);
  pusat kota hanya Toko Benih dengan rak penuh pernak-pernik.

## Arsitektur v29+: satu place, satu server, dunia = seksi koordinat jauh

- **PUSAT KOTA** (koordinat 0) — spawn plaza, **Gerbang Dunia** (lengkung kayu
  10 stud, panel Masuk/Kunjungi), **satu-satunya bangunan: Toko Benih** —
  interior penuh: dua rak besar berisi karung benih & pot, kasa, keranjang,
  karung lantai, papan harga (Pack Common 2.400 / Rare 9.000 isi 3 benih
  acak), papan gantung, lampu. Tekan E di kasir ATAU rak untuk beli; toko juga
  membeli hasil panen.
- **DUNIA PRIBADI = SEKSI** — setiap pemain punya petak 240x220 (500 plot,
  pagar, meja semai, gerbang pulang, papan nama) di koordinat X+5000, 24 petak
  per server. Masuk/pulang/kunjung = **teleport CFrame instan**: tanpa loading,
  tanpa ReserveServer, tanpa MemoryStore, tanpa TeleportService — tidak ada
  lagi cara untuk gagal teleport.
- **BALIK PASTI BERHASIL** — seksi pemilik tetap ada selama ia online: pulang
  ke kota lalu kembali = dunia persis seperti ditinggal (tanaman, isi meja).
  Keluar game: dunia disimpan ke DataStore AKM_Dunia dan dimuat lagi nanti.
- **GABUNG BENIH DI PLOT YANG SAMA** — sesuai aturan pemilik: tanam satu
  benih di plot lahan, lalu tanam benih pasangan resepnya LAGI DI PLOT YANG
  SAMA; plot berubah menjadi tanaman hasil gabung (8 resep: Tangelo, Plumcot,
  Nectaplum, Kacang tanah, Pluerry, Canola, Triticale, Tetsukabuto). Panel
  plot yang terisi menampilkan tombol "Gabung <nama> -> <hasil>" hanya untuk
  benih di tas yang punya resep. Tidak ada tombol/panel/gedung gabung di toko
  maupun kota.
- **KUNJUNGI DUNIA ORANG LAIN** — ketik nama di panel Gerbang: pemain di server
  yang sama -> langsung; pemain offline -> seksi hantu baca-saja dari data
  tersimpan. Tamu TIDAK bisa menanam/panen/memukul/menaruh — semua aksi mutasi
  ditolak server per-seksi ("Dunia ini milik X. Kamu sedang berkunjung.").
- **ANTI LAG & ANTI JATUH** — seksi jauh di luar radius streaming pemain kota;
  plot Part sederhana tanpa Script dari satu template; sisa waktu on-demand;
  SafeFloor 8000 stud anti-jatuh (tak pernah ter-stream keluar); anchor 1,1
  dtk saat tiba + RequestStreamAroundAsync + watchdog; seksi hantu auto-hancur
  120 dtk kosong; save hanya bila berubah.
- **DATA** — Micda awal user baru **999.999.999.999.000 (999,99 T)**, atap
  rekening 1000 Triliun per user (sisa ruang awal 1.000) & tas 50 slot x 250 (AKM_T1), dunia per userId
  (AKM_Dunia, sanitasi ketat DuniaLogic: plot + meja + gudang + drop). Pohon &
  progres pukul + drop belum diambil tersimpan; drop hanya kedaluwarsa 900 dtk
  sejak pemain keluar (HARVEST_EXPIRE_SECONDS, waktu server; online aman).
  Kunci sesi mencegah satu akun aktif di dua server; save UpdateAsync + retry.
  Tanpa sistem level. Bila DataStore tidak tersedia, game tetap jalan mode
  sesi tanpa menimpa data lama.
- **SKALA** — tinggi karakter acuan 5 stud: lengkung gerbang 10 stud, bangunan
  20 stud; modeling modular, maks 3 warna utama per bangunan (pernak-pernik
  toko adalah aksen barang).
- **KEAMANAN** — semua logika uang/tas/beli/jual/pukul/gabung/perpindahan di
  ServerScriptService; uang hanya lewat CurrencyService (Get/Add/Spend +
  alasan whitelist + ledger + batas laju + tolak lonjakan); semua remote
  divalidasi server (tipe, rentang, pemilik per-seksi, jarak, cooldown,
  batas laju per detik); klaim drop atomik satu ID satu kali; AuditService
  mencatat insiden (laju, argumen, jarak, milik, klaim ganda, lonjakan) dan
  kick otomatis pada 20 insiden/5 menit; kematangan & kedaluwarsa murni
  waktu server; tanpa require ID angka, loadstring, getfenv, HttpService;
  tanpa model/script luar; kode dev tetap server-only (DevCodeVault).

## Riwayat versi (ringkas)

| Ver | Isi |
|-----|-----|
| v10-v25 | Era pertama (kombat angka, ekonomi tani v7, arsitektur pulau), puncak skor 83/100. |
| v26 | RESET TOTAL diminta pemilik: semua map & sistem dihapus, dunia kosong. |
| v27 | TAHAP 1 dari nol: lahan + 500 plot + Semai Panen + pusat kota & Toko Benih + gabung benih 8 resep + tas 50x250 + Micda 900.000 persisten. |
| v28 | TAHAP 2 dunia pribadi ter-instans (ReserveServer). Diganti di v29 karena teleport bisa gagal di lapangan. |
| v29 | Dunia sambung satu-server (seksi koordinat jauh, CFrame instan) + gabung benih di plot + Pusat Kota hanya Toko Benih. CATATAN JUJUR: UI klien ternyata tidak pernah dimuat (bug ditemukan v30 lewat playtest), jadi beli benih & tombol masuk dunia mati di lapangan. |
| v30 | **Playtest otomatis + perbaikan akar masalah**: (1) UI klien kini benar-benar dimuat (init.client me-require UIController — akar dari "beli gak bisa" & "gak bisa balik ke lahan"); (2) 500 plot per lahan dibangun di koordinat dunia yang benar (X+5000, sebelumnya nyasar ke kota); (3) status siap-panen tersinkron ke semua pemain (tombol Panen muncul); (4) gabung benih = tanam 2 benih resep di PLOT YANG SAMA + tombol Gabung di panel plot; (5) pintu Toko & Semai kini pintu sungguhan berengsel buka-tutup (bukan melompong); (6) interior toko makin penuh: barisan paket benih di rak, peti kayu, etalase kaca kasir, poster, spanduk gantung, papan promo, alas pintu, gunung karung, pot; (7) teleport diperkuat: tunggu streaming selesai sebelum lepas anchor, jangkar gagal-aman 5 dtk, pengawas jurang 15 dtk. Tes 106 PASS, playtest 51 PASS, 0 FAIL (#30). |
| v31 | **Sistem tanam-panen baru sesuai blueprint pemilik**: (1) PAPAN TANAM fisik per lahan dengan label hidup "TERTANAM X/500" — pilih benih + jumlah, plot terisi otomatis 10 per 10, tanpa klik plot; (2) SOAL MATEMATIKA acak per pemain tiap 10 plot (500 plot = 50 soal), salah = tertahan sampai benar, kesulitan naik tambah/kurang -> kali -> bagi; (3) PANEN PUNCH: tombol layar muncul dekat tanaman siap, hasil memantul + bunyi + partikel, kombo x4/x8 memperbesar efek, ambil dengan menyentuh; (4) tas penuh = hasil MELAYANG tidak bisa diambil; (5) GUDANG hasil panen per lahan: setor 1-250 = 1 tampungan dari 1000 (250 -> 999 -> 998 persis contoh pemilik), ambil kembali, persisten di AKM_Dunia; (6) tombol perjalanan cepat HUD, teleport placeWait, beli longgar, rak toko penuh. Tes 132 PASS / 0 FAIL, luau-lsp 0 temuan, simulasi alur main hijau (#31). |
| v32 | **REVISI FINAL tanam-panen (14 poin pemilik)**: (1) plot mati untuk klik/tap — popup "Plot Tanam" + semua teks instruksi dihapus dari dunia & UI (papan kota, papan tanam, papan gudang, papan toko, panel tas, sapaan spawn); (2) tanam hanya lewat Papan Tanam, label "TERTANAM X/500" hidup di dua sisi; (3) soal tiap 10 plot kini inline di papan; (4) Combine Seed jadi menu 2 slot di papan — tanpa resep/petunjuk, cocok = benih hibrida, tidak cocok = "Tidak bisa di-combine" di dalam papan & benih tidak terpakai; gabung di plot dihapus dari sistem; (5) 8 resep rahasia di server persis daftar pemilik; (6) PUNCH permanen di layar: pukul siap -> drop peluang (peluang disembunyikan) diambil dengan menyentuh, pukul tumbuh boleh kapan saja & 5x beruntun = hancur; (7) tab Status: Siap Panen / Masih Tumbuh per jenis; (8) 34 tanaman (termasuk 8 hibrida) punya bentuk model sendiri + warna siap berbeda; (9) dunia bebas teks melayang (label drop & "Tas Penuh" dihapus; melayang tetap sebagai sinyal visual). Tes 127 PASS / 0 FAIL, luau-lsp 0 temuan, playtest 72 PASS / 0 FAIL (#32). |
| v33 | **UJIAN MASSA PANEN + 3 perbaikan akar**: ujian end-to-end baru 94 tahap — tanam 50 wortel lewat papan (5 soal), tunggu matang (warna berubah, status Siap 50), panen raya dengan tombol PUNCH asli (kick kamera + kombo tier 1->2->3: drop 1.8->2.1->2.4), 50 drop disentuh -> 288 buah persis, bayam tumbuh 5x pukul hancur tanpa drop, combine GUI Gandum+Rye -> Triticale + penolakan "Tidak bisa di-combine" (benih utuh) + 8 resep & urutan dibalik, Tangelo (bentuk pohon) ditanam & dipanen, gudang 999->998, tas penuh = drop melayang. Ditemukan & diperbaiki: (1) penarget PUNCH tak pernah menemukan PlotGrid (grid ada di dalam model seksi; kini FindFirstChild rekursif — tombol kini benar-benar memukul); (2) travel HUD tidak menyegarkan state lahan (kini syncState + payload Sync membawa lahan via provider baru); (3) tab Combine Seed terbuka kosong (kini refresh saat tab dibuka). Tes 127 + massa 94 + playtest 72, semua 0 FAIL; luau-lsp 0 temuan (#33). |
| v34 | **REVISI TAMPILAN HP** (urutan D,E,F->G->A,B,C): drop panen mini produce per arketipe (8 pembentuk) + ikon tas ikut bentuk/warna; animasi ayunan tangan asli tiap tekan + momen kena 0.12 dtk + getar kamera bertingkat; presisi raycast 14 stud + fallback kerucut + highlight sasaran (server menghitung sendiri); tombol PUNCH relatif Jump; papan tanam minimalis (safe area, tab garis bawah, truncate, tombol per tab). Tes 175 PASS, playtest 116 PASS, 0 FAIL (#34). |
| v35 | **REVISI HUD LAYAR GAME** (laporan pemilik): (1) SALDO — kini di bawah ikon menu Roblox memakai safe area GuiService.TopbarInset, tampil utuh ikon M + angka + satuan "Micda" dengan teks menyesuaikan layar; (2) TOMBOL NAVIGASI — tepat di bawah saldo, rata kiri, AutomaticSize X dengan batas lebar min/maks, nama panjang terpotong, posisi tidak bergeser saat teks "Masuk Dunia-ku" <-> "Pulang ke Kota"; (3) PUNCH — kini skala murni, di KIRI Jump dengan jarak tepat 1 ukuran jump, 1.24x lebih besar, dasar segaris, dijamin tidak menutupi area tanam; (4) semua HUD (saldo, nav, tas, zona) skala + area aman, teruji di 6 ukuran layar (640x360, 667x375, 844x390, 915x412, 1284x720, 375x667). Tes 188 PASS, playtest 116 PASS, massa 94 PASS, semua 0 FAIL; luau-lsp 0 temuan (#35). |
| v39 | **REVISI FINAL: UI, SISTEM PANEN, SERVER-AUTHORITATIVE & ANTI-EXPLOIT** (halaman "Lahanan"): (A) kolom kiri Micda + "Masuk Dunia-ku" vertikal rata kiri di bawah bar Roblox (TopbarInset + margin), jarak konsisten via UIListLayout; tombol PUNCH baru tanpa tulisan: ikon kepalan 9 bagian orisinal, UIStroke, UIGradient, bayangan, efek tekan mengecil 0.9, ukuran 0.92x Jump, 12-20 px di KIRI Jump, dasar segaris; (B) POHON vs HASIL PANEN dipisah: pohon + progres 5x pukul selalu tersimpan (tak pernah terhapus waktu), hasil panen tersimpan & hanya kedaluwarsa 900 dtk sejak pemain KELUAR (waktu server; online aman selamanya; rejoin < 15 menit = drop kembali di posisi semula; hitungan diulang dari keluar terbaru), label peringatan di Papan Tanam; (C) SERVER-AUTHORITATIVE: CurrencyService satu pintu (Get/Add/Spend + alasan whitelist + atomik + batas 24 mutasi/menit + tolak lonjakan 25.000 + ledger 24 transaksi tersimpan), AuditService log [AUDIT] + kick 20 insiden/5 menit, kunci sesi UpdateAsync anti-dua-server (data tamu tak menimpa asli), save UpdateAsync + retry 3x + autosave 75 dtk + BindToClose simpan & lepas kunci, drop ID unik + klaim atomik satu kali + jarak 14 stud + pemilik saja + maks 80 drop/lahan FIFO; (D) semua waktu dari server (GetServerTimeNow/os.time), cooldown pukul 0.35 dtk server, tidak ada remote menerima jumlah/waktu/harga/status klien; (E) tes exploit simulasi baru: Micda palsu/NaN/lonjakan/laju ditolak, kunci sesi, kedaluwarsa 899 vs 900 dtk, klaim ganda/jarak/milik, persistensi pohon+drop sanitasi. BUG DITEMUKAN & DIPERBAIKI: PlotService.serialize memetakan crop/readyAt lalu DuniaLogic.serPlots menyaring crop -> pohon SEBELUMNYA TIDAK PERNAH TERSIMPAN; kini serialize mentah + h/l tersimpan. Tes 243 PASS / 0 FAIL (7 seksi baru), luau-lsp 0 temuan; uji 7 layar termasuk tablet 2224x1668 (#39). |
| v40 | (sesi otomatis) Menerbitkan #40; dokumentasinya menyebut efek struk berjenjang & modal 268 px yang TIDAK ada di sumber — klaim tidak akurat, kode tidak ditemukan di proyek. Fitur yang diminta pemilik benar-benar diimplementasikan di v41 (lihat atas). |
| v41 | **PEMBELIAN BERKONFIRMASI + GERBANG OTOMATIS TERTUTUP + BUG BADAI SYNC DIPERBAIKI** (permintaan pemilik): (1) TOKO BENIH — tekan Pack Common/Rare TIDAK langsung membeli: muncul pop up "Konfirmasi Pembelian" berisi isi pack, kategori, dan harga dengan tombol Ya, Beli / Batal; setelah Ya, server merapatkan benih (tetap server-authoritative) lalu pop up "Pembelian Berhasil" menampilkan STRUK daftar benih yang didapat per jenis (ikon + nama + jumlah) plus total Micda — modul baru Shared/StrukBeli merangkum picks jadi baris struk; (2) GERBANG DUNIA — memilih Masuk/Pulang/Kunjungi yang berhasil langsung menutup pop up (tidak lagi menggantung setelah teleport); (3) BUG BADAI SYNC — panel Papan Tanam pada tab Status memanggil TanamAct("status") ulang di SETIAP Sync/TanamSync (50 pukulan = 50+ panggilan, rate limit 3/6 dtk meluap, AuditService mencatat 20 insiden dan MENENDANG pemain); kini tab Status hanya memuat ulang lewat klik tab atau tombol "Perbarui" — badai sync hilang; (4) ALAT UJI DIHIDUPKAN KEMBALI (jujur): generator playtest/massa ternyata membeku sejak v39 (daftar modul tidak pernah diperbarui + stub DataStore tanpa UpdateAsync sehingga semua load dianggap kunci sesi) — kini diperbaiki dan seluruh skenario disesuaikan dengan UI v39-v41 (tombol punch ikon, baris tanam klik-baris, tombol jumlah, teks status "Siap/Tumbuh", atribut drop DropId/LahanIdx, jarak & arah pukul server); playtest 130 PASS / 0 FAIL, ujian massa 93 PASS / 0 FAIL, tes offline 251 PASS / 0 FAIL (8 tes StrukBeli baru), luau-lsp 0 temuan (#41). |
| v43 | **MESIN SEMAI PANEN** (permintaan pemilik): meja pukul diganti mesin giling — pilih hasil panen + atur jumlah (kapasitas 2000, total pukulan = jumlah x pukulan/item), batch dipotong & digulung server; aktif hanya setelah penjodohan kabel 4-6 pasang warna (drag atau ketuk), giling 3 dtk (drum/gir/roda putar, asap, suara), papan "SEMAI TUNTAS - KLAIM HASIL", klaim Micda + benih + blok SESUAI tanaman; item bug "blok_panen" dihapus total; area mesin dihias penuh. Ditemukan & diperbaiki: variabel menimpa fungsi warna modal kabel. Tes 279 offline, massa 108, playtest 130; luau-lsp 0 (#43). |
| v44 | **KABEL SERVER-AUTHORITATIVE + TIANG KANOPI 4X KARAKTER** (permintaan pemilik): ujian sambung kabel acak MENEMUKAN bug integrasi kritis — layout kabel dibuat di klien dan server tidak pernah memvalidasi ("kabel" polos langsung aktif, minigame bisa dilewati exploiter); kini layout dibuat server saat atur, pengajuan wajib membawa mapping kiri->kanan dan divalidasi server (saringSambung + kabelSelesai), 3x salah = susunan diacak ulang (versi naik) dan modal dibangun ulang otomatis, jodohan parsial aman di 1-2x salah; soket target menyala hijau/merah saat kabel diseret; tiang kanopi kini 20 stud = 4x tinggi karakter (karakter acuan 5 stud) dengan pelat dasar, balok ikat empat sisi, penyokong X, atap naik ke 21,3 stud, lampu gantung tali panjang. Tes offline 291 (+12 seksi Q), massa 113 (alur kabel dari layar: tanpa mapping/kosong/tertukar DITOLAK, acak ulang terlihat, jodoh dari layar -> klaim), playtest 130; luau-lsp 0 temuan (#44). |
| v46 | (republish) rename internal (jalur daya, judul seksi tes) — nol perubahan perilaku; massa 116 / playtest 130 / offline 293, semua 0 FAIL (#46). |
| v45 | **DUA TUAS KANAN-KIRI + POP-UP SEMAI LEBAR & JELAS** (permintaan pemilik): kabel dihapus total (modal, fungsi SemaiLogic kabel, remote "kabel", label); dua tuas baja fisik berlabel di ujung kanan & kiri mesin dengan lampu status, tombol "Tekan Tuas" per tuas; ditekan -> server validasi urutan (KANAN dulu, lalu KIRI; tekan-ulang/kiri-duluan/sisi asing DITOLAK) -> lengan tuas berpindah sendiri (tween) + bunyi; keduanya selesai -> mesin LANGSUNG menggiling 3 dtk; prompt hanya aktif pada tuas bergiliran; panel semai diperluas 760x620 dengan strip 3 langkah, tombol -/+ & chip jumlah, kartu langkah tuas berstatus SELESAI/TEKAN!/TUNGGU; BUG shadow variabel (prompt menempel ke pedestal salah) ditemukan ujian massa & diperbaiki. Tes offline 293, massa 119 (alur tuas end-to-end dari dunia), playtest 130; luau-lsp 0 temuan (#45). |
| v47 | **TANPA ITEM BLOK + NAMA BENIH "BENIH X" + DROP TIDAK TENGGELAM + UJIAN SIKLUS PENUH** (permintaan pemilik): (1) item "blok" dibuang total (helper CropData, rasio giling, baris struk/pop-up, ikon tas) — mesin kini hanya keluar Micda + benih sesuai tanaman; (2) benih wajib tampil "Benih X" (Benih Wortel) dan baru jadi "Wortel" setelah panen — ditegakkan di slot tas, pilih benih papan tanam, slot Combine Seed, struk beli & struk klaim; (3) bug drop panen "terkadang tenggelam ke tanah" dibunuh berlapis: hitung permukaan tanah saat spawn (raycast + aturan plot 1.4 stud via modul baru Shared/TanahDrops), angkat drop 0.55 stud sebelum memantul, pengawas 0.25 dtk mengangkat yang menembus, lalu anchor tepat DI ATAS tanah setelah diam — tetap bisa diambil sentuh; (4) ujian pemilik 15 cek end-to-end: beli pack -> 3 Benih Wortel -> tanam -> panen punch -> ambil masuk tas sebagai "Wortel" (bukan benih) -> semai atur jumlah -> tuas KANAN-KIRI (kiri duluan ditolak) -> giling 3 dtk -> klaim Micda + benih kembali, nol blok. Tes offline 319 PASS / 0 FAIL, luau-lsp 0 (#47). |
| v48 | (finalisasi v47) simulator playtest/massa diperbaiki (daftar modul gen.py + stub CFrame __add/__sub, Rotation, IsDescendantOf) lalu DIJALANKAN ULANG: playtest 130 PASS / 0 FAIL, ujian massa 116 PASS / 0 FAIL, offline 319 PASS / 0 FAIL, luau-lsp 0; penjaga kecepatan drop dibuat aman untuk drop pulihan; publish #48. |
| v49 | **PEMBERSIHAN OTOMATIS DATA LAMA: BLOK_PANEN DIHAPUS DARI TAS & SEMAI PANEN TERBACA LAGI** (laporan pemilik: "masih ada item blok_panen, wajib dihapus; di semai panen hasil panen gak terbaca"): akar masalahnya BUKAN kode — data tas lama di DataStore (sebelum #47) masih menyimpan slot "blok_panen" dan dimuat mentah. Solusi: modul baru Shared/SanitasiTas menyaring tas saat load (id bukan tanaman resmi dibuang, kind/count rusak dibuang, 999->250, maks 50 slot, gagal-aman), data bersih langsung ditandai simpan ulang + toast "Tas Dibersihkan"; gudang dunia lama ikut divalidasi (setor/ambil/restore menolak blok_panen); UI klien memfilter item tak dikenal di 3 titik masuk tas + guard daftar semai. Seksi test V baru 13 cek: blok_panen dibuang saat load, tas bersih bikin SEMAI PANEN TERBACA LAGI (wortel bisa diatur jumlah & masuk mesin), blok_panen tak bisa masuk mesin. Tes offline 334 PASS / 0 FAIL, playtest 130 PASS / 0 FAIL, massa 116 PASS / 0 FAIL, luau-lsp 0 (#49). |
| v50 | **SEMAI PANEN: PILIH ITEM -> ATUR JUMLAH + KAMERA PANEL DIKUNCI** (permintaan pemilik, revisi UI & Logic mesin): (1) buka mesin = daftar hasil panen di tas dirangkum per jenis (250+250+250 = satu baris "Wortel x750"), klik item -> pop-up "Atur Jumlah Semai" (-, +, Maks — preset dihapus sesuai revisi pemilik) -> konfirmasi masuk mesin; tas kosong = pesan sesuai; (2) aturan satu jenis: item berbeda saat mesin berisi DITOLAK dgn notifikasi "Mesin sedang memproses [nama item]" (toast klien + server), item SAMA boleh di-top-up sampai 2000 (pukulan & hasil linear, status tuas dipertahankan), stok tas dihitung total lintas slot, 10 pun bisa langsung disemai, Maks = min(stok, sisa kapasitas); (3) validasi penuh: melebihi stok/sisa kapasitas ditolak, 0/negatif/pecahan tak bisa dikonfirmasi, penuh 2000/2000 ditolak, giling/tuntas-belum-klaim ditolak; (4) keluhan papan tanam: geser di luar pop-up tak lagi memutar kamera (dim/modal Active) + zoom dikunci selama panel terbuka via modul baru Shared/KameraKunci (min=max=jarak saat buka, pulih saat tutup); (5) TasLogic.ringkas mengagregasi daftar di semai/toko/gudang/tanam/combine. Seksi W 20 cek (7 skenario wajib pemilik semuanya lolos) + seksi X 7 cek kamera. Tes offline 361 PASS / 0 FAIL, luau-lsp 0, rojo build sukses (#50). |
| v51 | **ANTI-CHEAT EKONOMI TANPA BATAS ANGKA TETAP** (permintaan pemilik; detail penuh di RUBRIC.md Skor v51): batas transaksi 25.000 & 24/menit DIHAPUS (nominal besar & aksi cepat adalah hal normal game ekonomi); server menghitung semuanya (client hanya kirim aksi); AuditService v2 deteksi anomali berbobot (uang korup/lewat atap 100, sumber tak dikenal 60, sesi 20 — ambang 100/jam; penolakan biasa hanya LOG, 280 tolak pun tidak menendang); kick aman-data (simpan dulu, tunggu transaksi selesai, simpan lagi, baru kick); sapuan integritas saldo tiap 45 dtk; 2 bug kehilangan data (jual & klaim) dibunuh dengan rollback; kamera modal diperkuat Scriptable. Tes 378 PASS / 0 FAIL, luau-lsp 0 (#51). |
| v56 | **DATA TIDAK PERNAH NOL LAGI — BUG PEMUSNAH DATA DIBUNUH** (keluhan pemilik: "keluar masuk lagi tetep diulang terus dari nol"): AKAR = (1) desain v55 "progres sesi darurat dipertahankan" ternyata berbalik jadi penghapus data — begitu pemain bertransaksi satu kali di sesi darurat (tandai simpan aktif), saat data asli berhasil dimuat data asli justru DIBUANG dan data darurat (saldo awal + tas kosong) disimpan MENIMPA data asli; semua progres lama musnah permanen, login berikutnya memang "dari nol" dan begitu terus; (2) pemicunya: rejoin cepat — lepas kunci saat keluar menulis kunci, rejoin < ~6 dtk kena throttle tulis, percobaan ambil kunci cuma 1x -> gagal -> sesi darurat; (3) dunia ikut: loadWorld tanpa retry -> sekali gagal dunia dibangun KOSONG + canSave=false seumur sesi (tanam/mesin/gudang tidak pernah tersimpan). Perbaikan: cobaSinkron kini HANYA mengadopsi data asli (sesi darurat tidak pernah menimpa), ambil kunci diulang 4x (0,3/1,2/2,7 dtk), loadWorld diulang 3x, dan pemulihan dunia di latar tiap 8 dtk (maks 40x) — DataStore pulih = pohon/mesin/gudang/drop tersimpan diadopsi di tempat, canSave dibuka, dunia langsung disimpan, toast netral "Sinkronisasi Dunia"; print DEBUG sisa v55 dihapus; stub uji baru __failUpdate (sabotase tulis). Playtest +8 cek: sesi darurat bertransaksi -> data asli 7.777 diadopsi (bukan darurat), kunci disabotase 3x -> data asli 3.333 langsung terpakai, dunia gagal 3x -> pulih otomatis pohon muncul lagi. CATATAN JUJUR: data yang SUDAH tertimpa sebelum #60 tidak bisa dikembalikan otomatis. Offline 399 PASS / 0 FAIL, playtest 164 PASS / 0 FAIL (+8), massa 122 PASS / 0 FAIL, luau-lsp 0 temuan, build sukses (#60). |
| v55 | **SINKRONISASI DATA OTOMATIS — PAPAN DARURAT PEMAIN DIHAPUS** (keluhan pemilik via screenshot: pemain kedapatan papan "Mode Sesi — progres sementara"): akar masalah = GetAsync DataStore hanya dicoba 1x, galat throttle/jaringan saat masuk langsung menjadikan sesi TANPA SIMPAN seumur bermain, dan kunci sesi basi (server mati mendadak) mengunci 90 dtk tanpa jalan keluar. Perbaikan: (1) load diulang 3x (tunggu 0,4/0,8 dtk); (2) modul baru DataService.cobaSinkron — bila tetap gagal, server menyapa netral sekali ("Sinkronisasi — progres kamu aman", TANPA kata-kata menakutkan) lalu tiap 8 dtk mencoba lagi sampai DataStore pulih/kunci lewat: data asli diadopsi otomatis (leaderstats melompat ke saldo nyata) dan pemain kembali tersimpan penuh; progres sesi darurat yang sudah berjalan dipertahankan lalu disimpan; (3) dua kalimat papan lama dihapus total dan frasa itu masuk daftar terlarang generator simulator (tidak bisa muncul lagi); (4) stub DataStore baru mendukung sabotase __failGet untuk uji: playtest membuktikan DataStore gagal 5x -> darurat 10.000 -> pulih -> data asli 5.000 diadopsi otomatis. Offline 399 PASS / 0 FAIL, playtest 155 PASS / 0 FAIL (+3), massa 122 PASS / 0 FAIL, luau-lsp 0 temuan, build sukses (#59). CATATAN v56: butir "progres sesi darurat dipertahankan" di atas ternyata BUG pemusnah data — dibunuh total di v56. |
| v54 | **PAPAN TANAM TANPA TEKS KUIS + KOIN EMAS MICDA + PUNCH/LOMPAT TERSEMBUNYI + SALDO AWAL 10.000** (permintaan pemilik, satu paket): (1) panel Papan Tanam susunan vertikal UIListLayout tanpa posisi manual — tab Tanam (kepala, daftar benih flex, umpan balik, angka, Mulai Tanam) dan tampilan soal kini ScrollingFrame vertikal (muat HP kecil & besar) dengan bar progres + label "1/5" menggantikan "Soal 1 dari 5 — tertanam 0/50", tombol Batalkan Sesi Tanam 44 px ber tempat sendiri di bawah Jawab tanpa tertimpa; (2) semua teks gaya kuis dibuang ("Benar!", "Sesi selesai", "tertanam X", "Panen dengan tombol Punch!") beserta area pesan status — jawaban benar: tanaman muncul langsung di lahan dengan partikel kecil + suara pendek dan panel MENUTUP SENDIRI saat sesi tuntas; jawaban salah: kolom input goyang (denyut UIScale) + merah sebentar tanpa kalimat; notifikasi toast netral 2 detik "+10 Wortel" (jumlah & nama saja); (3) modul Shared/IkonKoin: koin emas bulat (gradasi, kilau, tepi gelap, tanpa huruf) dipakai di HUD saldo, SEMAI TUNTAS, struk klaim, harga konfirmasi beli, pratinjau jual, dan toast — proporsional teks, tahan NaN/nil; (4) tombol Punch + lompat disembunyikan selama panel tanam terbuka dan muncul lagi saat tutup; (5) CropData.StartMoney -> 10.000 Micda (permintaan pemilik). Pesan server jadi netral pendek ("+10 Wortel"/"salah"/"Mulai tanam Wortel"). Offline 399 PASS / 0 FAIL, playtest 152 PASS / 0 FAIL, massa 122 PASS / 0 FAIL, luau-lsp 0 temuan, rojo build sukses (#57). |
| v53 | **SALDO AWAL 999,99 T + HUD SINGKATAN INDONESIA + KETUK ANGKA PENUH** (permintaan pemilik): StartMoney -> 999.999.999.999.000; modul baru Shared/UangSingkat (Rb/Jt/M/T, koma, maks 2 desimal, floor); kotak saldo TextButton AutomaticSize X + angka satu baris; ketuk -> 999.999.999.999.000 bertitik (satuan disembunyikan); HUDLayout dapat lebarTeksPx/lebarSaldoPx/muatLayar + tes 7 layar; simulator playtest diperbaiki akar (3 bug stub sejak v50) + gen.py auto-deteksi modul topologis; skenario massa disesuaikan alur semai v50. Offline 396 / playtest 141 / massa 118, semua 0 FAIL; luau-lsp 0 (#53). |
| v52 | **SALDO AWAL USER BARU 1 TRILIUN MICDA** (permintaan pemilik): CropData.StartMoney 900.000 -> 1.000.000.000.000 — user baru (dan reset data rusak) kini mulai dengan 1.000.000.000.000 Micda, proporsional dengan ekonomi super besar & atap rekening 1000 Triliun dari #51; data pemain lama tidak disentuh. Aritmetika tes siklus penuh kini relatif terhadap StartMoney (tanpa angka hardcoded). Tes offline 378 PASS / 0 FAIL, luau-lsp 0 TypeError, rojo build sukses (#52). |

## Sesi update mandiri berikutnya (tanpa menunggu pemilik)

1. Baca resep pemilik terbaru (blog) + `RUBRIC.md` → kerjakan area terlemah.
2. Uji: `tools/luau tests/run_tests.luau` (0 FAIL wajib; tambah tes untuk fitur baru),
   `tools/luau-lsp analyze --definitions=/home/z/my-project/tools/globalTypes.d.luau --sourcemap=sourcemap.json src tests`
   (sourcemap: `tools/rojo sourcemap default.project.json -o sourcemap.json`).
3. Build & publish:
   ```bash
   export ROBLOX_API_KEY="$(grep -E '^ROBLOX_API_KEY=' /home/z/my-project/.secrets/akiomida.env | cut -d= -f2-)"
   /home/z/my-project/tools/rojo build default.project.json -o build/DuniaAkiomida.rbxlx
   python3 publish.py --universe-id 10774464946 --place-id 77626159664192 --file build/DuniaAkiomida.rbxlx
   ```
4. Perbarui skor `RUBRIC.md` + README ini.
5. **WAJIB cadangan GitHub**: `bash /home/z/my-project/scripts/backup_github.sh`
   (commit + push seluruh proyek ke branch `dunia-akiomida` di
   github.com/familygoldenmekkah-hub/Ciumbulet — lokasi yang dipilih
   pemilik; harness uji ikut disalin; kredensial dari .secrets, tidak
   pernah ditampilkan).
6. **CADANGAN (SATU TARGET LANGSUNG)**: semua tulis langsung ke
   github.com/familygoldenmekkah-hub/Ciumbulet branch `dunia-akiomida`
   (main repo tidak disentuh) — tidak ada GitHub lain. Token
   `familygoldenmekkah-hub` tersimpan di .secrets/ciumbulet.env,
   tidak pernah dicetak. Jalankan
   `bash /home/z/my-project/scripts/backup_github.sh` di akhir setiap
   sesi update.

## Pasca-publish (dashboard pemilik, sekali saja bila belum)

1. Game Settings → Security → aktifkan "Studio Access to API Services"
   (DataStore wajib agar Micda/tas/dunia tersimpan permanen; tanpa ini game
   tetap jalan dalam mode sesi).
2. Set Public bila ingin pemain lain bergabung & saling mengunjungi.
3. Tidak ada pengaturan teleport/place lain — semua dunia otomatis dari
   sistem seksi.

## Keamanan

Kredensial (API key, kode dev, token GitHub) disimpan di
/home/z/my-project/.secrets/akiomida.env (server-only DevCodeVault untuk kode).
Jangan commit / bagikan. Rotate bila bocor.

## Cadangan GitHub (jaga-jaga + tim)

- Repo: **github.com/akiomida/Io**, branch khusus proyek ini:
  **`dunia-akiomida`** (main dipakai kerja lain, jangan disentuh).
- Isi: seluruh proyek (src, tests, build .rbxlx, dokumentasi) + `harness/`
  (playtest & ujian massa siap jalan, lihat harness/README.md).
- Dipush SETIAP selesai publish versi baru lewat
  `scripts/backup_github.sh` (langkah 5 di sesi mandiri) — riwayat commit
  per versi = riwayat pembaruan game.
- Sesi pertama membangun branch ini dari snapshot **v53** (commit fbb92f9).
- Token GitHub tersimpan di .secrets; bila repo khusus (DuniaAkiomida)
  ingin dipakai, beri token akses Contents: Read and write untuk repo itu
  di Settings > Developer settings > Fine-grained tokens.
