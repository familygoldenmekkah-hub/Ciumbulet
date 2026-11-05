# RUBRIK SELEVEL TORAM ONLINE / GROWTOPIA — DUNIA AKIOMIDA

Dipakai setiap sesi update mandiri: beri skor jujur, tingkatkan area terlemah,
publish, lalu skor ulang. Target pemilik: **100/100**.

Skor per kriteria 0-10, dikali bobot. Total dihitung dari (skor x bobot) / 10.

## Kriteria & Bobot

| # | Kriteria | Bobot | Acuan Toram Online | Acuan Growtopia |
|---|----------|-------|--------------------|-----------------|
| 1 | Kombat (monster, AI, boss, skill) | 15 | monster beragam, skill combo, bos mekanik | PvP / grif & pertahanan dunia |
| 2 | Crafting & Profes (objek jadi bahan) | 15 | tempaa, menjahit, alkimia, masak (mastery) | spawning blok, blueprint |
| 3 | Stat & Progresi (stat points, equipment) | 10 | 5 stat, skill tree, ribuan item | level + item hiasan |
| 4 | Ekonomi (pasar dinamis, player shop) | 15 | bazar, item langka, sink & faucet | vending player economy |
| 5 | Dunia & Peta (zona, dungeon, dekorasi) | 10 | banyak map & dungeon | dunia player-built |
| 6 | Aktivitas Multiplayer | 10 | party, boss bersama, guild | berinteraksi, trade, scam-proof |
| 7 | Bertani / Gardening | 10 | farm (bahan masak) | Grow a Garden plot |
| 8 | Polish & UX (UI, suara, animasi, efek) | 10 | animasi kombat, BGM, partikel | UI rapi & responsif |
| 9 | Originalitas 100% & aman hak cipta | 5 | - | - |

## Skor v11 (versi LIVE #19, 5 Nov 2026) - siklus mandiri penuh

| Kriteria | Skor | Catatan |
|----------|------|---------|
| 1 Kombat | 8/10 | 8 monster ANGKA (1,2,3,4,5,6,7,8) + boss "Angka Sang Raja" (9); 2 skill senjata aktif (Tebasan Kuat, Sabetan Putar AoE); angka damage melayang; recoil kena pukul; SFX slash; ledakan aura saat mati. |
| 2 Crafting | 7/10 | 12 resep + MASTERY (tiap 10x resep = M1..M3, XP craft sampai +50%). |
| 3 Stat | 7/10 | 5 stat + poin/level + UPGRADE PERALATAN +1..+5 (+12%/bintang, biaya Micda & balok). |
| 4 Ekonomi | 9/10 | Papan Jual antar pemain (persisten, jasa 2% transparan, kotak pos offline), pasar dinamis, toko NPC, sink kuat (lahan, upgrade, jasa), MICDA, streak login. Syariah: tanpa riba/maysir/gharar/syirik. |
| 5 Dunia | 7/10 | 10 zona + DUNGEON "Gua Kristal" (dinding, kristal neon, belik kristal ekstra, angka 8 & 6). Belum ada dungeon instanced per-party. |
| 6 Multiplayer | 7/10 | Boss raid kooperatif, EVENT TERJADWAL "Pesta Panen" (30 menit sekali, Micda/XP x2 diumumkan semua), trade 2 sisi, papan jual, kompas zona. Belum ada party/guild. |
| 7 Bertani | 7/10 | 6 ladang: 1 GRATIS, 5 dibeli LUNAS Micda (400-20.000). |
| 8 Polish | 7/10 | UI minimal flat (1 aksen emas, tombol seragam), pop-in panel, kompas jarak, SFX. Tanpa animasi karakter/BGM. |
| 9 Originalitas | 10/10 | 100% karya sendiri: konsep angka-aura, semua nama & model original. |

**TOTAL: 76/100** (bobot: 8x15+7x15+7x10+9x15+7x10+7x10+7x10+7x10+10x5 = 760/10)

Riwayat: v10 = 56 -> v11 = 64 (penilaian owner) -> siklus mandiri = 76.
Celah utama menuju 100: party/guild (7), animasi karakter & BGM (7),
dungeon instanced (7), skill tree (7).

## Catatan kepatuhan syariah (permintaan pemilik, 5 Nov 2026)

- TANPA RIBA: tidak ada bunga, cicilan, atau "tabungan berbunga". Lahan dibeli lunas di muka.
- TANPA MAYSIR: tidak ada undian/lotre/gacha berbayar. Peluang ikan = hasil usaha memancing, tarif transparan.
- TANPA GHARAR: pembeli Papan Jual melihat barang, jumlah, harga, dan biaya jasa (2%, min 1 Micda) sebelum konfirmasi.
- TANPA SYIRIK: tidak ada pemujaan/dewa; NPC hanyalah saudagar biasa; hiasan netral.
- Mata uang: MICDA (nama milik sendiri).

## Roadmap menuju 100 (dikerjakan sesi mandiri berikutnya, tanpa menunggu owner)

- **v12 (target ~75)**: 2 skill aktif senjata, +4 spesies angka baru (3, 5, 6, 8),
  SFX & BGM original disintesis kode, animasi serang sederhana, efek kematian monster.
- **v13 (target ~85)**: dungeon "Gua Kristal" (boss 9 kedua), kios vending milik pemain
  di lahan sendiri (ala Growtopia), furniture ladang, pet ikut kombat, achievement.
- **v14 (target ~95)**: guild + territory, event musiman, minimap, upgrade equip (+1..+5),
  quest rantai NPC, cuaca & siang-malam, tutorial questline.

## Aturan tetap setiap sesi (WAJIB)

1. Semua aset & kode original buatan sendiri - tidak menyalin aset/nama konten pihak ketiga.
2. Tidak menghadirkan: toggle wawasan, ads.js, donasi, share (permintaan pemilik).
3. Kode dev tetap server-only (DevCodeVault), kredensial hanya di .secrets/ + credentials.json.
4. Test dulu: `tools/luau tests/run_tests.luau` (harus 0 FAIL) + luau-lsp analyze 0 TypeError.
5. Publish langsung ke Roblox (jangan kirim file ke pemilik):
   `export ROBLOX_API_KEY="$(grep -E '^ROBLOX_API_KEY=' /home/z/my-project/.secrets/akiomida.env | cut -d= -f2-)"`
   `python3 publish.py --universe-id 10774464946 --place-id 77626159664192 --file build/DuniaAkiomida.rbxlx`
6. Update README.md + tabel skor di file ini setiap publish.
