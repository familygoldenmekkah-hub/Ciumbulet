# COIN RUSH SIMULATOR - Panduan Lengkap (Bahasa Indonesia)

Game Roblox siap publish, dibangun penuh lewat script tanpa aset eksternal.
Genre: **Clicker/Simulator** dengan ekonomi koin, pet, rebirth, leaderboard global, dan monetisasi.

> File `build/CoinRushSimulator.rbxlx` sudah JADI dan siap dipublish.
> Lu gak perlu install Rojo kecuali mau modifikasi kode.

---

## 1. Isi paket ini

| Path | Fungsi |
|---|---|
| `build/CoinRushSimulator.rbxlx` | **File place jadi, siap publish / buka di Studio** |
| `default.project.json` | Struktur project Rojo (definisi tree + SpawnLocation + Lighting) |
| `src/Shared/` | `Config.luau` (SEMUA angka ekonomi/harga), `Util.luau` |
| `src/Remotes/` | Daftar RemoteEvent/RemoteFunction |
| `src/Server/` | Script server: data, ekonomi, toko, pet, monetisasi, leaderboard, map |
| `src/Client/` | UI (dibangun lewat kode), visual pet |
| `publish.py` / `publish.sh` | Script publish ke Roblox via Open Cloud API |
| `DESAIN_GAME.md` | Dokumen desain: konsep, harga, formula, arsitektur |

---

## 2. Persiapan di Roblox (sekali saja, ±5 menit)

### a. Buat experience
1. Buka <https://create.roblox.com> → **Creations** → **Create** → pilih template apa saja (misal *Baseplate*).
2. Beri nama, misal `Coin Rush Simulator`.
3. Buka experience tersebut → di URL browser ada angka seperti
   `.../creations/experience/1234567890/...` → itu **Universe ID**.
4. Untuk **Place ID**: buka experience → tab ... menu → *Copy place ID* (atau lewat Asset Manager di Studio).

### b. Aktifkan API Services (wajib untuk DataStore & publish API)
1. Di halaman experience → **Configure** → **Security** (atau Game Settings di Studio).
2. Aktifkan **Studio Access to API Services**.

### c. Buat Open Cloud API Key
1. Buka <https://create.roblox.com/credentials> → **Create API Key**.
2. Isi nama (misal `coin-rush-publisher`).
3. Bagian **Access Permissions** → **Add API System** → pilih `universe-places` →
   pilih experience lu → Operations: **Write**.
4. (Disarankan) Bagian **Security** → set **Expiration date** (misal 30 hari) dan
   IP restriction ke IP rumah lu. Kalau mau publish dari mana saja, kosongkan
   IP list tapi ganti dengan expiration pendek.
5. **Copy key-nya sekarang** - setelah keluar halaman, key gak bisa dilihat lagi.

---

## 3. Publish game

### Cara A - script publish (tanpa Studio)
```bash
python3 publish.py --api-key KEY_LU --universe-id UNIVERSE_ID --place-id PLACE_ID
```
Sukses = muncul `versionNumber`. Game langsung bisa dimainkan di Roblox app.

### Cara B - lewat Roblox Studio
1. Download `build/CoinRushSimulator.rbxlx`.
2. Studio → **File → Open from File** → pilih file itu.
3. **File → Publish to Roblox As...** → pilih experience lu → Create.

### Cara C - live sync (buat iterasi cepat)
```bash
rojo serve .        # butuh Rojo: https://rojo.space (atau via rokit/aftman)
```
Lalu di Studio (yang sudah dipasang plugin Rojo): **PLUGIN → Rojo → Connect**.
Setiap edit file langsung ke-sync ke Studio.

---

## 4. Setup monetisasi (opsional, biar bisa pemasukan Robux)

Saat ini semua tombol Robux di game tampil **"SOON"** karena ID-nya masih 0.

1. Di Creator Dashboard → experience lu → **Monetization**:
   - **Passes** → buat 3: *2x Coins* (R$ 99), *VIP* (R$ 199), *Turbo Hands* (R$ 149)
   - **Developer Products** → buat 3: *1,000 Coins* (R$ 49), *15,000 Coins* (R$ 199), *200,000 Coins* (R$ 999)
2. Copy ID masing-masing (ada di dashboard).
3. Buka `src/Shared/Config.luau`, isi ID di bagian `Config.Gamepasses` dan `Config.Products`:
   ```lua
   Config.Gamepasses = {
       DoubleCoins = { id = 12345678, ... },  -- <- ID dari dashboard
       ...
   }
   ```
4. Rebuild + republish:
   ```bash
   rojo build --output build/CoinRushSimulator.rbxlx .
   python3 publish.py --api-key KEY --universe-id U --place-id P
   ```

Harga di atas adalah rekomendasi awal (standar pasar simulator). Ubah bebas -
tombol pembelian otomatis ikut harga dashboard yang lu set.

---

## 5. Tuning ekonomi tanpa nyentuh logika

Semua angka ada di **`src/Shared/Config.luau`**:

| Yang mau diubah | Lokasi |
|---|---|
| Koin per klik | `Config.Economy.BaseClickValue` |
| Batas klik/detik (anti-cheat) | `Config.Economy.MaxClicksPerSecond` |
| Harga & efek upgrade | `Config.Upgrades` |
| Daftar pet, harga, income | `Config.Pets` |
| Slot pet (normal/VIP) | `Config.PetEquipCap` / `Config.VipEquipCap` |
| Biaya & bonus rebirth | `Config.Rebirth` |
| Waktu autosave / refresh leaderboard | `Config.Data` / `Config.Leaderboard` |

Setelah edit: rebuild (rojo build) → republish (publish.py). Selesai.

---

## 6. Struktur kode

```
src/
├── Shared/Config.luau      <- SEMUA angka tuning + ID monetisasi
├── Shared/Util.luau        <- format angka (1.2M), helper UI, retry
├── Remotes/init.luau       <- registry RemoteEvent/RemoteFunction
├── Server/
│   ├── init.server.luau    <- bootstrap urutan init
│   └── Modules/
│       ├── DataService.luau         <- save/load DataStore + autosave + sanitize
│       ├── EconomyService.luau      <- formula koin, rate limit, sync state
│       ├── ShopService.luau         <- validasi semua pembelian (server-side)
│       ├── PetService.luau          <- ledger pet & slot equip
│       ├── MonetizationService.luau <- gamepass + dev product (receipt ledger)
│       ├── LeaderboardService.luau  <- top 10 global (OrderedDataStore) + papan
│       └── MapService.luau          <- map prosedural (pulau, koin raksasa, dll)
└── Client/
    ├── init.client.luau
    ├── UIController.luau   <- seluruh UI (klik, shop 3 tab, papan, notifikasi)
    └── PetVisuals.luau     <- pet melayang mengikuti pemain (client-side)
```

Prinsip keamanan yang sudah diterapkan:
- Semua pembelian & klik divalidasi **server-side** (client gak bisa nipu harga).
- Rate limit klik (15/detik) - exploiter gak kebagian apa-apa kalau spam.
- Receipt dev product dicatat ke DataStore dulu sebelum koin dikasih (anti dobel/lost purchase).
- Data disanitize saat load - save lama/korup gak bikin crash.

---

## 7. Rebuild dari source (kalau lu modifikasi kode)

```bash
# install rojo sekali (pilih salah satu):
#   Windows: winget install rojo  |  atau: https://github.com/rojo-rbx/rojo/releases
rojo build --output build/CoinRushSimulator.rbxlx .
python3 publish.py --api-key KEY --universe-id U --place-id P
```

## 8. Roadmap yang gue sarankan (v1.1+)

1. **Daily rewards** - login harian (retensi paling murah).
2. **Pets dengan rarity & hatch egg** - pseudo-gacha dari koin (bukan Robux) dulu.
3. **Zona/klik kedua** (teleport ke "island 2") - konten jangka panjang.
4. **Sound & efek partikel** - pakai aset gratis dari Toolbox via Studio.
5. **Badge awal** ("Welcome", "First Rebirth") - discovery algorithm suka badge.
