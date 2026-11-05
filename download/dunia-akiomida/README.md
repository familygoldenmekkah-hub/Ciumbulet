# DUNIA AKIOMIDA v3 — "Toram-grade Economy World" (Roblox)

Status: LIVE di Roblox (versionNumber 10, 5 Nov 2026)
Universe: 10774464946 · Place: 77626159664192
Build: `tools/rojo build --output build/DuniaAkiomida.rbxlx .` (335 KB, 20 modul, luau-lsp 0 TypeError, tes offline 24/24 PASS)

Skor banding Toram/Growtopia: **56/100** — lihat `RUBRIC.md` (roadmap ke 100).

## Isi v3 (di atas fondasi ekonomi v2)

- **KOMBAT**: 4 monster original (Gelatin Hijau, Serigala Bayang, Golem Batu,
  Gelatin Raksasa elite) dengan AI berkeliaran/mengejar/memukul balik, HP bar,
  drop material (Gelatin/Taring/Inti Golem) yang jadi BAHAN TEMPAA.
- **BOSS RAID**: Raja Golem muncul di Arena Timur (koloseum) tiap ±15 menit,
  semua pemain serang bersama, hadiah dibagi sesuai kontribusi, teratas bonus besar.
- **TEMPAA (crafting)**: PAK TEMPA (balok besi/kristal, Pedang Kayu/Besi/Kristal,
  Zirah Kulit/Besi/Kristal) + BU MASAK (Roti Aktif buff lari, Sate Ikan,
  Ramuan pulihkan HP). Objek alam → bahan → peralatan.
- **STAT & PERALATAN**: 5 stat (STR/VIT/AGI/INT/DEX) + 2 poin tiap naik level,
  pakai/lepas senjata & zirah (ATK/DEF nyata), senjata tampak di tangan.
- **TUGAS HARIAN**: papan tugas rotasi harian (7 kolam tugas: panen/tebang/
  tambang/mancing/bunuh/tempa/masak), hadiah koin+XP besar.
- **DAGANG ANTAR PEMAIN**: undang pemain terdekat, tawar barang & koin dua sisi,
  status SIAP dua-duanya, eksekusi atomik server-side (anti-scam dasar).
- Fondasi v2 tetap: ladang pribadi (klaim gratis, 5 bibit, siram, panen),
  hutan/tambang/danau, pasar dinamis 10 menit, peliharaan, sepeda, belik tier,
  kuis Kak Pintar OPSIONAL (tidak pernah memaksa, tidak ada popup paksa).
- Tidak dibawa dari versi lama (aturan pemilik): ads, donasi, share, toggle wawasan.

## Sesi update mandiri berikutnya (tanpa menunggu pemilik)

1. Baca `RUBRIC.md` → kerjakan roadmap item terlemah → tambah fitur.
2. Uji: `tools/luau tests/run_tests.luau` (tambah tes untuk fitur baru),
   `tools/luau-lsp analyze --definitions=/home/z/my-project/tools/globalTypes.d.luau --sourcemap=sourcemap.json src`.
3. Build & publish:
   ```bash
   export ROBLOX_API_KEY="$(grep -E '^ROBLOX_API_KEY=' /home/z/my-project/.secrets/akiomida.env | cut -d= -f2-)"
   /home/z/my-project/tools/rojo build --output build/DuniaAkiomida.rbxlx .
   python3 publish.py --universe-id 10774464946 --place-id 77626159664192 --file build/DuniaAkiomida.rbxlx
   ```
4. Perbarui skor `RUBRIC.md` + README ini.

## Pasca-publish (dashboard pemilik, sekali saja bila belum)

1. Game Settings → Security → aktifkan "Studio Access to API Services" (DataStore wajib).
2. Set Public bila ingin pemain lain bergabung (boss raid & dagang butuh pemain lain!).

## Keamanan

Kredensial (API key, kode dev) disimpan di /home/z/my-project/.secrets/akiomida.env
(server-only DevCodeVault untuk kode). Jangan commit / bagikan. Rotate bila bocor.
