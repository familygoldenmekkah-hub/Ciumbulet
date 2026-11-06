# DUNIA AKIOMIDA (Roblox)

Status: LIVE di Roblox (**versionNumber 28**, 6 Nov 2026) — **TAHAP 2: DUNIA
PRIBADI TER-INSTANS**. Permintaan pemilik terpenuhi: TANPA ID place manual,
anti-lag saat banyak pemain keluar-masuk, dan pemain lain bisa mengunjungi
dunia pemain lain tanpa saling mengganggu.
Universe: 10774464946 · Place: 77626159664192 · Label era: 9.1.0 "Tahap 2"
Build: `tools/rojo build default.project.json -o build/DuniaAkiomida.rbxlx`
(luau-lsp 0 TypeError, tes offline 90 PASS / 0 FAIL)

Skor banding Toram/Growtopia: **40/100** — lihat `RUBRIC.md`.

## Arsitektur TAHAP 2 (v28): satu place, dua jenis server

- **PUSAT KOTA (hub publik)** — join biasa. Spawn plaza, **Gerbang Dunia**
  (lengkung kayu 10 stud, buka panel Masuk/Kunjungi), **Toko Benih** lengkap
  (jual pack Common 2.400 / Rare 9.000 isi 3 benih acak + beli hasil panen),
  **Meja Gabung** (gabung benih 8 resep, cek jarak 24 stud), papan & lampu.
  Ringan (~70 part); kalau ramai, Roblox otomatis membagi pemain ke beberapa
  server hub — tidak pernah jadi bottleneck.
- **DUNIA PRIBADI (instance khusus)** — dibuat lewat
  `TeleportService:ReserveServer(game.PlaceId)`: **tidak perlu membuat atau
  mengisi ID place apa pun**. 1 dunia = 1 server (model Growtopia): beban
  komputasi & render sepenuhnya terisolasi, ramai sekalipun tidak saling lag.
  Isi: 1 lahan penuh 500 plot + pagar + meja semai + papan nama pemilik +
  gerbang pulang.
- **KUNJUNGI DUNIA ORANG LAIN** — ketik nama pemain di panel Gerbang:
  - Pemain ONLINE dunianya aktif → digabung ke server dunia yang sama (sosial).
  - Pemain OFFLINE → dibuat instance baca dari data tersimpan.
  - Tamu TIDAK bisa menanam/panen/memukul/menaruh — semua aksi mutasi ditolak
    server ("Dunia ini milik X. Kamu sedang berkunjung.") → anti-ganggu.
- **RENDEZVOUS & PERSISTENSI** — MemoryStoreSortedMap AKM_DuniaAktif (TTL 90 dtk,
  heartbeat 30 dtk) untuk menemukan server dunia yang aktif; DataStore AKM_Dunia
  menyimpan tanaman (timestamp readyAt) & isi meja semai → bertahan saat
  offline, siap saat dimuat. Save tiap 60 dtk bila berubah, saat pemilik
  keluar, saat server kosong, dan BindToClose.
- **DATA GLOBAL** — Micda 900.000 & tas 50 slot x 250 (satu jenis per slot)
  tersimpan DataStore AKM_T1, berlaku di hub maupun dunia. Tanpa sistem level.
- **SKALA** — tinggi karakter acuan 5 stud: lengkung gerbang 10 stud, bangunan
  20 stud, dinding 1 stud, ukuran kelipatan 2 stud; modeling modular, maks 3
  warna utama per bangunan.
- **ANTI LAG** — dunia per-server; plot Part sederhana tanpa Script dari satu
  template klon; sisa waktu tanam on-demand tanpa loop per plot; visual
  tanaman hanya saat ditanam/dimuat; MemoryStore 1 operasi / 30 dtk per dunia;
  StreamingEnabled aktif; semua Anchored; tanpa Mesh berat.
- **KEAMANAN** — semua logika uang/tas/beli/jual/pukul/gabung/teleport di
  ServerScriptService; semua remote divalidasi server (role pemilik/tamu,
  kepemilikan lahan, jarak, saldo, batas permintaan per detik); teleport dibungkus
  pcall dengan pesan jujur saat gagal; data dunia disanitasi ketat (DuniaLogic);
  tanpa require ID angka, loadstring, getfenv, HttpService; tanpa model/script
  luar; kode dev tetap server-only (DevCodeVault).

## Catatan place Pusat Kota

Semenjak v28 tidak ada lagi kebutuhan place kedua atau ID manual (modul
PlaceConfig dihapus). Pusat Kota = server publik; dunia pribadi = instance
ReserveServer di place yang sama; gerbang saling menghubungkan keduanya.

## Riwayat versi (ringkas)

| Ver | Isi |
|-----|-----|
| v10-v25 | Era pertama (kombat angka, ekonomi tani v7, arsitektur pulau), puncak skor 83/100. |
| v26 | RESET TOTAL diminta pemilik: semua map & sistem dihapus, dunia kosong. |
| v27 | **TAHAP 1 dari nol** sesuai resep blog pemilik: lahan + 500 plot + Semai Panen + pusat kota & Toko Benih + gabung benih 8 resep + tas 50x250 + Micda 900.000 persisten. 76 tes PASS (#27). |
| v28 | **TAHAP 2 dunia pribadi ter-instans**: tanpa ID place manual, 1 dunia = 1 server (ReserveServer, anti-lag), kunjung antar dunia (online join server aktif / offline mode baca), tamu read-only, tanaman & meja persisten saat offline, panel Gerbang Dunia + label zona. 90 tes PASS, 0 FAIL (#28). |

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
   (DataStore + MemoryStore + Teleport wajib untuk dunia pribadi).
2. Set Public bila ingin pemain lain bergabung & saling mengunjungi.
3. Tidak ada lagi pengaturan ID place — semua otomatis lewat ReserveServer.

## Keamanan

Kredensial (API key, kode dev) disimpan di /home/z/my-project/.secrets/akiomida.env
(server-only DevCodeVault untuk kode). Jangan commit / bagikan. Rotate bila bocor.
