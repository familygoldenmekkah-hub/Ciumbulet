# DUNIA AKIOMIDA (Roblox)

Status: LIVE di Roblox (**versionNumber 27**, 6 Nov 2026) — **TAHAP 1: ALUR INTI**
dibangun dari nol persis resep blog pemilik (yuyanaka.blogspot.com "Tugasmu").
Universe: 10774464946 · Place: 77626159664192 · Label era: 9.0.0 "Tahap 1"
Build: `tools/rojo build default.project.json -o build/DuniaAkiomida.rbxlx`
(luau-lsp 0 TypeError, tes offline 76 PASS / 0 FAIL)

Skor banding Toram/Growtopia: **33/100** (dari nol, alur inti sudah jalan) — lihat `RUBRIC.md`.

## Isi TAHAP 1 (v27, dari nol)

- **PLACE LAHAN** — 10 lahan per server (2x5, jarak 40), satu pemain satu lahan,
  klaim otomatis & lepas saat keluar, respawn selalu di lahan sendiri.
  Pengunjung boleh masuk, server menolak semua perubahan isi.
  Per lahan 240x220 sesuai denah wajib: zona depan 20 (spawn + gerbang), blok
  plot 150x120, zona kanan 70 (Semai Panen 30x30 + penanda Koperasi 30x30 &
  Kolam 50x30 — tidak dibangun), zona belakang 60 (penanda Rumah 40x40 +
  4 ruangan 24x24 — tidak dibangun), jalan setapak 10 stud antar zona, pagar
  keliling, pencahayaan, papan nama (tempat saja).
- **500 PLOT** per lahan, grid 25x20, plot 4x4 (pitch 6), status kosong/tumbuh/siap.
  Hanya pemilik bisa tanam & panen. Tumbuh 3 detik. Panen acak
  Common 1-10 / Rare 1-6 / Epic 1-4.
- **SEMAI PANEN** (bangunan 30x30 di sebelah plot): letakkan hasil panen di
  meja, pukul hingga hancur — Common 5 pukul, Rare 10, Epic 15. Hasil hancur
  selalu memberi Micda (1-5 / 3-9 / 9-19) + peluang Benih (45/30/10%) dan
  Blok Panen (20/15/15%), dihitung terpisah. Blok Panen sementara hanya item tas.
- **PLACE PUSAT KOTA** — zona terpisah 2600 stud: lahan kosong, spawn dekat
  gerbang kembali ke lahan, satu bangunan TOKO BENIH 40x30 sesuai resep lengkap
  (pondasi batu, dinding krem, tiang sudut kayu gelap, bukaan masuk 6x10 tanpa
  daun pintu, dua etalase 10x8 dasar 3, atap pelana 30 derajat overhang 3 merah
  bata, kanopi depan 2 tiang, papan nama 16x4, kasir 12x3, 4 rak benih 8x2x8,
  meja etalase 6x3, 3 lampu gantung, lantai kayu, dinding dalam terang).
  Toko menjual pack isi 3 benih acak: Common 2.400, Rare 9.000 (benih Epic TIDAK
  dijual). Toko juga membeli hasil panen: harga/unit x jumlah.
- **GABUNG BENIH** di lahan sendiri: pilih 2 benih dari tas, hanya 8 resep valid
  (Tangelo, Plumcot, Nectaplum, Kacang Tanah, Pluerry, Canola, Triticale,
  Tetsukabuto), urutan bebas, salah resep ditolak tanpa memotong benih.
- **DATA** — Micda awal 900.000, tersimpan DataStore (AKM_T1) siap antar-place.
  Tas 50 slot, satu jenis per slot, maks 250/slot; tas penuh = panen ditolak +
  pemain diberi tahu. Tanpa sistem level.
- **SKALA** — tinggi karakter acuan 5 stud: semua bukaan pintu lubang kosong
  10x6 tanpa daun, tinggi bangunan 20 stud, dinding 1 stud, ukuran kelipatan
  2 stud. Modeling modular (dinding/lantai/atap/bukaan), maks 3 warna utama
  & material terbatas per bangunan, semua objek menempel lantai/dinding.
- **ANTI LAG** — plot Part sederhana tanpa Script dari satu template klon;
  grid plot dibuat saat klaim & dihancurkan saat lepas; sisa waktu tanam
  dihitung on-demand tanpa loop per plot; visual tanaman hanya saat ditanam;
  StreamingEnabled aktif; semua Anchored; tanpa Mesh berat.
- **KEAMANAN** — semua logika uang/tas/beli/jual/pukul/drop/gabung di
  ServerScriptService; semua remote divalidasi server (pemilik lahan, jarak,
  saldo, batas permintaan per detik); tanpa require ID angka, loadstring,
  getfenv, HttpService; tanpa model/script luar; data penting tidak di
  ReplicatedStorage; kode dev tetap server-only (DevCodeVault).

## Catatan place Pusat Kota

Universe hanya punya SATU place (Open Cloud tidak bisa membuat place baru).
Pusat Kota kini zona terpisah 2600 stud; gerbang sudah memakai logika
TeleportService penuh. Begitu pemilik membuat place kedua di dashboard,
isi ID-nya ke `src/Server/Modules/PlaceConfig.luau` (KotaPlaceId) dan gerbang
otomatis jadi teleport lintas-place sesungguhnya.

## Riwayat versi (ringkas)

| Ver | Isi |
|-----|-----|
| v10-v25 | Era pertama (kombat angka, ekonomi tani v7, arsitektur pulau), puncak skor 83/100. |
| v26 | RESET TOTAL diminta pemilik: semua map & sistem dihapus, dunia kosong. |
| v27 | **TAHAP 1 dari nol** sesuai resep blog pemilik: 10 lahan berdenah + 500 plot + Semai Panen + pusat kota & Toko Benih + gabung benih 8 resep + tas 50x250 + Micda 900.000 persisten. 76 tes PASS, 0 FAIL (#27). |

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

1. Game Settings → Security → aktifkan "Studio Access to API Services" (DataStore wajib).
2. Set Public bila ingin pemain lain bergabung.
3. Bila ingin Pusat Kota jadi place terpisah sungguhan: buat place di dashboard,
   lalu beri tahu ID-nya untuk diisi ke PlaceConfig.KotaPlaceId.

## Keamanan

Kredensial (API key, kode dev) disimpan di /home/z/my-project/.secrets/akiomida.env
(server-only DevCodeVault untuk kode). Jangan commit / bagikan. Rotate bila bocor.
