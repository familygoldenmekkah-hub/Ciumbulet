# DUNIA AKIOMIDA v6.2 — "ARSITEKTUR WILAYAH" (Roblox)

Status: LIVE di Roblox (versionNumber 22, 5 Nov 2026 — arsitektur wilayah)
Universe: 10774464946 · Place: 77626159664192 · Versi game: 6.2.0
Build: `tools/rojo build --output build/DuniaAkiomida.rbxlx .` (luau-lsp 0 TypeError & 0 lint, tes offline 122 PASS, 0 FAIL)

Skor banding Toram/Growtopia: **80/100** — lihat `RUBRIC.md`.

## Riwayat siklus (v12→v22)

| Ver | Isi |
|-----|-----|
| v12 | Monster ANGKA BERSAURA (1/2/4/7 + boss 9) dengan aura, fix part tercecer (PivotTo), pukulan x0.45 vs pedang, PAPAN JUAL antar pemain + uang MICDA, lahan 1 gratis 5 bayar lunas, UI minimal flat, StreamingEnabled + trim 34 PointLight. |
| v13 | +4 spesies angka (3,5,6,8) campur zona, 2 SKILL SENJATA (Tebasan Kuat, Sabetan Putar AoE) dengan tombol HUD & cooldown, SFX slash. |
| v14 | EVENT TERJADWAL "Pesta Panen" (tiap 30 menit, Micda/XP x2, chip timer + pengumuman server). |
| v15 | Dungeon GUA KRISTAL (dinding, kristal neon, 3 belik kristal ekstra, angka 8 & 6), recoil kena pukul, notifikasi LEVEL NAIK, pop-in panel. |
| v16 | UPGRADE PERALATAN +1..+5 (biaya Micda + balok, +12%/bintang, tampil di panel Kar). |
| v17 | KOMPAS ZONA, STREAK LOGIN. |
| v18 | MASTERY CRAFTING. |
| v19 | Konsistensi dunia angka, versi 6.0.0. |
| v20 | KIOS VENDING PEMAIN (250 Micda lunas, 6 slot, jasa 2% transparan) · skill Tusukan Kilat · FASE MURKA boss · BGM pentatonik sintesis · partikel hemat mobile. Versi 6.1.0. |
| v21 | **ARSITEKTUR WILAYAH (permintaan pemilik)**: dunia = pulau-pulau di LAUT AIR SUNGUHAN terrain, pindah wilayah lewat GERBANG PORTAL. PULAU RUMAH pribadi x6 (klaim persisten: 1 gratis, 2-6 lunas Micda) berisi rumah berinterior, LAHAN TANI pribadi, KOLAM AIR SUNGUHAN (bergelombang, bisa berenang, bukan balok), RUANG BEDAH / RUANG SAINS / RUANG STARTOPIA, gerbang ke kota. PULAU PANEN bebas monster (hutan kayu, tambang bijih, Danau Tenang). 3 PULAU MONSTER terpisah bertingkat: Padang Liar (LV1-3), Hutan Bayang (LV3-5), Negeri Baja & Kristal (LV5+: Tambang Baja, Gua Kristal, Arena koloseum berpintu). Tata ruang rapi: jalan batu, lampu taman, pagar rambate, plaza. Modul baru: RegionService, PersonalWorldBuilder, data Balance.Regions + validasi otomatis "monster tidak boleh menembus wilayah umum". Versi 6.2.0. |

## Arsitektur wilayah (v21)

- **Pusat Kota** (hub): spawn, air mancur, 4 toko, pandai besi, api unggun, papan tugas,
  papan jual, Kak Pintar, papan juara + 5 gerbang portal.
- **Pulau Panen** (civil, TANPA monster): Hutan Kayu (12 pohon), Tambang bijih,
  Danau Tenang (air terrain + dermaga memancing).
- **Pulau Monster** (combat): Padang Liar · Hutan Bayang · Negeri Baja & Kristal
  (Tambang Baja, Gua Kristal, Arena boss).
- **Pulau Rumah x6** (home, klaim persisten per pemain): rumah, ladang pribadi + pad kios,
  kolam air sungguhan (bisa berenang & memancing), ruang Bedah/Sains/Startopia.
- Zona monster DIJAMIN tidak menembus wilayah peradaban oleh tes offline
  (`Balance.validateRegions()` — dijalankan setiap build).

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
