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

## Skor v3.0 (versi LIVE #10, 5 Nov 2026)

| Kriteria | Skor | Catatan |
|----------|------|---------|
| 1 Kombat | 5/10 | 4 monster + elite + boss raid kooperatif, AI kejar/pukul, crit & pertahanan. Belum ada skill aktif, animasi serang, atau banyak spesies. |
| 2 Crafting | 5/10 | 12 resep: smelting balok, 3 pedang, 3 zirah, 2 makanan, 2 ramuan. Belum ada mastery profesi, raritas, atau resep bertingkat. |
| 3 Stat | 5/10 | 5 stat + 2 poin/level, 6 peralatan tempaan ber-TK, senjata visual di tangan. Belum ada skill tree. |
| 4 Ekonomi | 6/10 | pasar dinamis 10 menit, 4 toko NPC, drop monster jadi bahan. Belum ada vending player shop / sink kuat. |
| 5 Dunia | 6/10 | 9 zona (plaza, pasar, ladang, hutan, tambang, danau, pandai besi, dapur, arena koloseum). Belum ada dungeon instanced. |
| 6 Multiplayer | 5/10 | boss raid bersama, trade 2 sisi anti-scam, papan juara. Belum ada party, guild, vending. |
| 7 Bertani | 6/10 | 6 ladang klaim, 5 bibit, siram, panen cahaya, auto-harvest keluar server. Belum ada tanaman rumpun/sprinkler. |
| 8 Polish | 5/10 | 10 panel UI lengkap, toast, tips, bar boss & HP. Belum ada BGM/SFX kombat, animasi, partikel. |
| 9 Originalitas | 10/10 | semua aset & nama original; tanpa aset pihak ketiga; ads/donasi/share/toggle wawasan tidak dibawa. |

**TOTAL v10: 56/100**

## Roadmap menuju 100 (dikerjakan sesi mandiri berikutnya, tanpa menunggu owner)

- **v11 (target ~70)**: vending kios milik pemain (jualan otomatis ala Growtopia),
  2 skill aktif per jenis senjata, +4 spesies monster baru, SFX & BGM original
  (disintesis lewat kode), efek pukulan & partikel, animasi serang.
- **v12 (target ~80)**: dungeon instanced "Gua Kristal" (boss #2), furniture & bangun
  di ladang (blok ala Growtopia), pet ikut kombat, streak login, achievement.
- **v13 (target ~90)**: guild + territory, event musiman, minimap, crafting bertingkat
  (+1..+5 upgrade), sink ekonomi (pajak pasar, biaya upgrade), quest rantai NPC.
- **v14 (target 100)**: polish penuh - animasi karakter, cuaca & siang-malam,
  tutorial questline, UI mobile, telemetri keseimbangan.

## Aturan tetap setiap sesi (WAJIB)

1. Semua aset & kode original buatan sendiri - tidak menyalin aset/nama konten pihak ketiga.
2. Tidak menghadirkan: toggle wawasan, ads.js, donasi, share (permintaan pemilik).
3. Kode dev tetap server-only (DevCodeVault), kredensial hanya di .secrets/ + credentials.json.
4. Test dulu: `tools/luau tests/run_tests.luau` (harus 0 FAIL) + luau-lsp analyze 0 TypeError.
5. Publish langsung ke Roblox (jangan kirim file ke pemilik):
   `export ROBLOX_API_KEY="$(grep -E '^ROBLOX_API_KEY=' /home/z/my-project/.secrets/akiomida.env | cut -d= -f2-)"`
   `python3 publish.py --universe-id 10774464946 --place-id 77626159664192 --file build/DuniaAkiomida.rbxlx`
6. Update README.md + tabel skor di file ini setiap publish.
