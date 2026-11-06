# DUNIA AKIOMIDA (Roblox)

Status: LIVE di Roblox (**versionNumber 35**, 6 Nov 2026) — **REVISI HUD
LAYAR GAME** sesuai laporan pemilik (saldo tertutup ikon menu Roblox,
tombol navigasi kaku, punch molor ke tengah layar). Isi v34 tetap:

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

Universe: 10774464946 · Place: 77626159664192 · Label era: 9.8.0 "HUD Rapi"
Build: `tools/rojo build default.project.json -o build/DuniaAkiomida.rbxlx`
(luau-lsp 0 temuan, tes offline 188 PASS / 0 FAIL, playtest 116 PASS / 0 FAIL,
ujian massa 94 PASS / 0 FAIL)

Skor banding Toram/Growtopia: **49/100** — lihat `RUBRIC.md`.

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
- **DATA** — Micda 900.000 & tas 50 slot x 250 (AKM_T1), dunia per userId
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

## Pasca-publish (dashboard pemilik, sekali saja bila belum)

1. Game Settings → Security → aktifkan "Studio Access to API Services"
   (DataStore wajib agar Micda/tas/dunia tersimpan permanen; tanpa ini game
   tetap jalan dalam mode sesi).
2. Set Public bila ingin pemain lain bergabung & saling mengunjungi.
3. Tidak ada pengaturan teleport/place lain — semua dunia otomatis dari
   sistem seksi.

## Keamanan

Kredensial (API key, kode dev) disimpan di /home/z/my-project/.secrets/akiomida.env
(server-only DevCodeVault untuk kode). Jangan commit / bagikan. Rotate bila bocor.
