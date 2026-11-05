# DUNIA AKIOMIDA v6.1 — "MICDA Economy World" (Roblox)

Status: LIVE di Roblox (versionNumber 20, 5 Nov 2026 — siklus mandiri v20)
Universe: 10774464946 · Place: 77626159664192 · Versi game: 6.1.0
Build: `tools/rojo build --output build/DuniaAkiomida.rbxlx .` (luau-lsp 0 TypeError & 0 lint, tes offline 107 PASS, 0 FAIL)

Skor banding Toram/Growtopia: **79/100** — lihat `RUBRIC.md`.

## Riwayat siklus mandiri (tanpa menunggu owner, v12→v20)

| Ver | Isi |
|-----|-----|
| v12 | Monster ANGKA BERSAURA (1/2/4/7 + boss 9) dengan aura, fix part tercecer (PivotTo), pukulan x0.45 vs pedang, PAPAN JUAL antar pemain + uang MICDA, lahan 1 gratis 5 bayar lunas, UI minimal flat, StreamingEnabled + trim 34 PointLight. |
| v13 | +4 spesies angka (3,5,6,8) campur zona, 2 SKILL SENJATA (Tebasan Kuat, Sabetan Putar AoE) dengan tombol HUD & cooldown, SFX slash. |
| v14 | EVENT TERJADWAL "Pesta Panen" (tiap 30 menit, Micda/XP x2, chip timer + pengumuman server). |
| v15 | Dungeon GUA KRISTAL (dinding, kristal neon, 3 belik kristal ekstra, angka 8 & 6), recoil kena pukul, notifikasi LEVEL NAIK, pop-in panel. |
| v16 | UPGRADE PERALATAN +1..+5 (biaya Micda + balok, +12%/bintang, tampil di panel Kar). |
| v17 | KOMPAS ZONA (jarak ke Papan Jual/Ladang/Hutan/Tambang/Gua/Arena), STREAK LOGIN (bonus naik sampai 250 Micda). |
| v18 | MASTERY CRAFTING (10x resep = M1..M3, XP craft +50% maks). |
| v19 | Konsistensi dunia angka (papan arena, tips, bahan "Pecahan Angka 2"/"Inti Angka"), versi 6.0.0. |
| v20 | **KIOS VENDING PEMAIN** di pad ladang (pasang 250 Micda lunas, 6 slot, harga bebas, jasa 2% transparan, hasil langsung ke pemilik, panel kelola/belanja) · skill ke-3 **Tusukan Kilat** (300%, Lv8) · **FASE MURKA** boss (HP ≤50%: aura merah, gerak +35%, serang +30%, diumumkan semua) · **BGM pentatonik** original disintesis kode + tombol Musik · partikel panen/tempa/kios/skill/murka (burst sekali-pakai, hemat mobile) · SFX jual. Versi 6.1.0. |

## Kepatuhan syariah (tetap)

Tanpa riba (semua pembelian LUNAS di muka — lahan & kios), tanpa maysir (tidak ada undian/lotre),
tanpa gharar (harga & biaya jasa 2% transparan sebelum konfirmasi di Papan Jual maupun Kios),
tanpa syirik (tidak ada pemujaan; NPC hanyalah saudagar). Uang: MICDA.

## Isi v3 (fondasi, tetap aktif di v4)

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
