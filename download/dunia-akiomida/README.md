# DUNIA AKIOMIDA (Roblox)

Status: LIVE di Roblox (**versionNumber 26**, 6 Nov 2026) — **RESET TOTAL**:
dunia kembali kosong dari nol, sesuai permintaan pemilik.
Universe: 10774464946 · Place: 77626159664192 · Label era: 8.0.0 "Dari Nol"
Build: `tools/rojo build default.project.json -o build/DuniaAkiomida.rbxlx`
(luau-lsp 0 TypeError, tes offline 3 PASS / 0 FAIL)

Skor banding Toram/Growtopia: **9/100** — kembali ke nol karena diminta;
riwayat puncak 83/100 (#25) tersimpan di `RUBRIC.md` sebagai acuan membangun ulang.

## Keadaan sekarang (#26 — reset total)

- **Semua map lama dihapus**: tidak ada lahan, rumah, koperasi, toko benih,
  portal, monster, pulau — tidak ada apa-apa, persis permintaan pemilik.
- **Semua sistem lama dihapus dari kode**: ekonomi tani v7, kombat, craft,
  data store, UI — server & klien kini hanya bootstrap minimal.
- Yang tersisa di dunia:
  - Baseplate 2048x2048 (Slate) + satu SpawnLocation.
  - Pencahayaan dasar; StreamingEnabled aktif; build hanya 3,5 KB.
- `DevCodeVault` tetap ada, tetap server-only (ServerScriptService).

## Riwayat versi (ringkas)

| Ver | Isi |
|-----|-----|
| v10-v25 | Era ekonomi tani v7 (34 tanaman, pack benih, 8 resep gabung, tas 50x250, koperasi, toko benih), kombat angka bersaura, arsitektur wilayah pulau + gerbang, normalisasi pintu (10 stud) & lantai bangunan (20 stud), puncak skor 83/100. |
| v26 | **RESET TOTAL (permintaan pemilik)**: semua map & semua sistem dihapus, dunia kembali dari nol — baseplate + titik lahir saja. Tes disederhanakan (3 PASS, 0 FAIL). |

## Rencana membangun ulang (menunggu arah pemilik, bukan janji otomatis)

1. Tata dunia dasar: wilayah, lahan, pusat kota — pintu tinggi 2x karakter dan
   benar-benar buka-tutup, lantai bangunan 4x karakter, air terrain sungguhan.
2. Ekonomi tani baru: 34 tanaman (tumbuh 3 detik, panen 1-4 acak), tas 50 slot
   x 250 per slot satu jenis, pack benih 400/1.500/3.500 (3 benih acak),
   8 resep gabung benih, dana awal 900.000 Micda, tanpa sistem level.
3. Toko benih interior profesional di pusat kota + koperasi per lahan.
4. Setelah fondasi beres: kombat, craft, progresi, multiplayer, polish.

## Sesi update mandiri berikutnya (tanpa menunggu pemilik)

1. Baca `RUBRIC.md` → kerjakan area terlemah sesuai arah terbaru pemilik → tambah fitur.
2. Uji: `tools/luau tests/run_tests.luau` (0 FAIL wajib; tambah tes untuk fitur baru),
   `tools/luau-lsp analyze --definitions=/home/z/my-project/tools/globalTypes.d.luau src tests`.
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

## Keamanan

Kredensial (API key, kode dev) disimpan di /home/z/my-project/.secrets/akiomida.env
(server-only DevCodeVault untuk kode). Jangan commit / bagikan. Rotate bila bocor.
