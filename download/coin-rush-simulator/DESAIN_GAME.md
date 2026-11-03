# DESAIN GAME - Coin Rush Simulator v1.0

Dokumen keputusan desain & ekonomi. Gue yang pegang prerogatif desainnya -
dokumen ini biar lu (dan siapun yang nyambung) paham kenapa angkanya segini.

---

## 1. Konsep

- **Genre**: Clicker / Simulator
- **Loop inti**: Klik → dapet koin → beli upgrade & pet → koin naik lebih cepat → rebirth (reset, multiplier permanen) → ulang dengan kecepatan lebih tinggi.
- **Kenapa genre ini**: onboarding 10 detik, retensi bagus (loop harian), dan 100% bisa dibangun prosedural tanpa aset eksternal - cocok untuk rilis cepat lalu iterasi data.
- **Target**: pemain global (UI bahasa Inggris - standar pasar Roblox; dokumen Indonesia).

## 2. Sumber koin

| Sumber | Rumus | Catatan |
|---|---|---|
| Klik | `(1 + MultiClick Lv × 1) × multiplier` | Rate limit 15 klik/detik di server |
| Auto Click (upgrade) | `Lv × 2 × multiplier` per detik | Diterapkan tiap 1 detik |
| Pet terpasang | `Σ income pet × multiplier` per detik | Income pet: 1 → 1200 |
| Turbo Hands (gamepass) | `+20 × multiplier` per detik | |

### Multiplier total
```
mult = (1 + Rebirths × 0.5)
     × (1 + CoinBoost Lv × 10%)
     × (2 kalau 2x Coins)         <- gamepass
     × (1.25 kalau VIP)           <- gamepass
```

## 3. Harga & kurva (angka awal, ubah di Config.luau)

### Upgrades
| Upgrade | Harga Lv1 | Pertumbuhan | Maks | Efek/Lv |
|---|---|---|---|---|
| Multi Click | 50 | ×1.35 | 100 | +1/klik |
| Coin Boost | 250 | ×1.40 | 50 | +10% semua koin |
| Auto Click | 400 | ×1.38 | 100 | +2/detik |

Kurva ×1.35–1.40 = standar simulator: tiap level terasa agak mahal tapi masih
"sekali nyaman beli" - mendorong pemain balik sesi berikutnya.

### Pets (karakter pengikut + income)
| Pet | Harga | Income | Tier |
|---|---|---|---|
| Coiny | 100 | 1/s | starter |
| Speedy Bunny | 500 | 3/s | early |
| Lucky Cat | 2.000 | 8/s | early |
| Doggo | 7.500 | 20/s | mid |
| Robo Buddy | 25.000 | 55/s | mid |
| Phoenix | 100.000 | 150/s | late-mid |
| Dragon | 500.000 | 400/s | late |
| Galaxy Fox | 2.000.000 | 1.200/s | endgame |

Slot pasang: **3** (VIP: **5**). Pet visual: bola/kubus neon warna per pet,
melayang mengorbit pemain (client-side, murah di jaringan).

### Rebirth
- Biaya: `25.000 × 2.2^rebirth` (naik cepat → jangka panjang)
- Bonus: **+50% multiplier permanen** per rebirth
- Reset: koin & upgrade. **Tetap**: pet, gamepass.

### Monetisasi (Robux)
| Item | Harga | Efek |
|---|---|---|
| 2x Coins | R$ 99 | Semua sumber koin ×2 - best seller di genre ini |
| VIP | R$ 199 | +25% koin, slot pet 5, (chat tag menyusul v1.1) |
| Turbo Hands | R$ 149 | +20 koin/detik |
| 1.000 / 15.000 / 200.000 Coins | R$ 49 / 199 / 999 | Paket instan |

Harga 99/199 pas di titik impulsif; paket koin dibuat sedikit lebih mahal
dari nilai upgrade yang setara supaya gamepass lebih menarik (praktik umum).

## 4. Leaderboard
- Metrik: **Total Earned** (akumulasi seumur hidup, gak direset rebirth).
- Upload ke OrderedDataStore tiap 60 detik, tampil: 2 papan fisik di map + panel UI "TOP 10".
- Top 3 diberi warna emas/perak/perunggu.

## 5. Keamanan & anti-exploit
1. **Klik** di-rate-limit 15/detik per pemain; kelebihan di-drop diam-diam.
2. **Semua harga divalidasi server** - client cuma kirim `kind` + `id`.
3. **Pembelian (invoke) ditolak** sebelum data selesai load.
4. **Dev product**: receipt dicatat ke DataStore `CRS_Receipts_v1` SEBELUM koin
   dikasih; receipt sama gak akan dikasih dua kali.
5. **Data disanitize** saat load (tipe, max level, kepemilikan pet, cap equip).
6. **Kick** kalau data gagal load 3x (cegah duplikasi data).
7. Autosave 120 detik + save saat keluar + save saat server mati (BindToClose).

## 6. Arsitektur teknis
- **Rojo project** → build ke `.rbxlx` → publish via Open Cloud (tanpa Studio).
- Server-authoritative: satu sumber rumus (`EconomyService`), klien hanya render.
- Pet visual di client (RenderStepped), income di server → nol replikasi gerakan.
- State ke client: snapshot penuh via `StateSync`, debounce 200 ms.
- Map: 1 folder instance dari script (pulau, koin raksasa berputar + ClickDetector,
  papan leaderboard, signage, pohon, kristal). SpawnLocation + Lighting dari project JSON.

## 7. Metrik awal yang layak dipantau (v1.1)
- D1 retention (target genre ini: 20–30%)
- Waktu ke pet pertama (target: < 10 menit)
- Waktu ke rebirth pertama (target: 1–2 jam total main)
- Konversi 2x Coins (target: 1–2% D1)

Kalau time-to-pet terlalu lama, turunkan harga Bunny/Cat dulu - jangan tambah
income klik (merusak kurva klik).
