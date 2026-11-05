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

## Skor v25 (versi LIVE #25, 5 Nov 2026) - PANEN BARU (permintaan pemilik)

| Kriteria | Skor | Catatan |
|----------|------|---------|
| 1 Kombat | 9/10 | 8 monster ANGKA (1-8) + boss "Angka Sang Raja" (9) dengan FASE MURKA (HP <=50%: aura merah, gerak +35%, serang +30%); 3 skill senjata aktif; damage melayang + partikel; SFX. Monster kini TERKURUNG di pulau monster (tidak menyebar ke wilayah umum). |
| 2 Crafting | 7/10 | 12 resep + MASTERY (M1..M3, XP craft sampai +50%). |
| 3 Stat | 7/10 | 5 stat + poin/level + UPGRADE PERALATAN +1..+5. |
| 4 Ekonomi | 9/10 | KIOS VENDING pemain (di ladang pulau rumah sendiri), Papan Jual persisten, pasar dinamis, sink kuat. + KLAIM PULAU RUMAH PERSISTEN (HomeId tersimpan; pulau 1 gratis, 2-6 dibeli LUNAS Micda - tanpa riba). |
| 5 Dunia | 8/10 | Pulau Panen lama dihapus (ekonomi baru); Pusat Kota kini berisi TOKO BENIH interior profesional (rak kemasan, konter kasir, planter demo, papan harga); semua pintu 2x karakter & buka-tutup (DoorKit), lantai bangunan 4x karakter; rumah 3 lantai + rooftop terrace berinterior penuh + ruang Bedah/Sains/Startopia/Pancing. Pusat kota sisanya kosong menunggu bahasan. | **ARSITEKTUR WILAYAH BARU (permintaan pemilik)**: dunia pulau-pulau di LAUT AIR SUNGUHAN terrain, dihubungkan GERBANG PORTAL. PULAU RUMAH pribadi x6 (rumah 2 lantai interior, LAHAN TANI pribadi, KOLAM AIR SUNGUHAN bergelombang & bisa berenang, RUANG BEDAH / RUANG SAINS / RUANG STARTOPIA, gerbang ke kota), Pusat Kota (hub sementara), Pulau Panen BEBAS MONSTER (hutan kayu, tambang bijih, Danau Tenang air sungguhan), 3 pulau monster terpisah bertingkat (Padang Liar LV1-3, Hutan Bayang LV3-5, Negeri Baja & Kristal LV5+ berisi Tambang Baja, Gua Kristal, Arena koloseum). Belum: dungeon instanced per-party, pusat kota final (menunggu bahasan pemilik). |
| 6 Multiplayer | 7/10 | Boss raid kooperatif, kompas zona, kunjungan lahan pemain lain. Papan jual/kios/trade lama dihapus bersama ekonomi lama - koperasi antar-pemain jadi penggantinya (roadmap). |
| 7 Bertani | 10/10 | **VERSI BARU sesuai spek pemilik**: 34 tanaman (12/14/8 Common-Rare-Epic, harga jual tetap), tumbuh 3 detik, panen 1-4 acak, KEBUN 500 PETAK per lahan, pack benih 400/1.500/3.500 (3 benih acak per kategori), 8 resep gabung benih, tas 50 slot x 250, koperasi harga tetap. |
| 8 Polish | 8/10 | BGM pentatonik original, partikel hemat mobile, SFX, kompas, kolam & danau air terrain bergelombang, tata ruang pulau rapi (jalan batu, lampu taman, pagar rambate, bunga). Tanpa animasi karakter. |
| 9 Originalitas | 10/10 | 100% karya sendiri; tidak ada aset/konten pihak ketiga. |

**TOTAL: 83/100** (bobot: 9x15+7x15+7x10+9x15+8x10+7x10+10x10+8x10+10x5 = 825/10)

Riwayat: v10 = 56 -> v11 = 64 (penilaian owner) -> v20 = 79 -> v21 = 80 -> v25 = 83.
Celah utama menuju 100: pusat kota final & dungeon instanced (8), party/guild (8),
animasi karakter (8), skill tree & progesi (7).

## Catatan arsitektur wilayah (v21, dasar desain MMORPG)

- Wilayah = pulau; pindah wilayah HANYA lewat gerbang portal (ProximityPrompt, server-side).
- kind hub (pusat kota) & civil (pulau panen) DIJAMIN bebas monster oleh tes offline
  (Balance.validateRegions: zona monster wajib di pulau combat & tak menembus wilayah peradaban).
- Pulau rumah = wilayah pribadi pemain: klaim persisten (DataStore HomeId), pulau 1 gratis,
  2-6 dibeli lunas Micda (syariah), ladang + kios ikut pulau pemiliknya.

## Catatan kepatuhan syariah (permintaan pemilik, diperbarui v20)

- TANPA RIBA: tidak ada bunga, cicilan, atau "tabungan berbunga". Lahan & kios dibeli lunas di muka.
- TANPA MAYSIR: tidak ada undian/lotre/gacha berbayar. Peluang ikan = hasil usaha memancing, tarif transparan.
- TANPA GHARAR: pembeli Papan Jual & KIOS melihat barang, jumlah, harga, dan biaya jasa (2%, min 1 Micda) sebelum konfirmasi.
- TANPA SYIRIK: tidak ada pemujaan/dewa; NPC hanyalah saudagar biasa; hiasan netral.
- Mata uang: MICDA (nama milik sendiri).

## Roadmap menuju 100 (dikerjakan sesi mandiri berikutnya, tanpa menunggu owner)

- **v21 (LIVE #21)**: ARSITEKTUR WILAYAH per permintaan pemilik: dunia pulau-pulau + gerbang
  portal, pulau rumah pribadi x6 (rumah/ladang/kolam air sungguhan/ruang Bedah-Sains-Startopia),
  pulau monster terpisah bertingkat, pulau panen bebas monster, klaim pulau persisten. (selesai)
- **v22 (target ~85)**: PUSAT KOTA final (menunggu bahasan pemilik), party + guild dasar,
  dungeon "Gua Kristal" instanced per-party, animasi serang karakter sederhana, pet ikut kombat.
- **v23 (target ~95)**: guild + territory, event musiman, minimap, quest rantai NPC,
  cuaca & siang-malam, tutorial questline, fungsi nyata ruang Bedah/Sains/Startopia.

## Aturan tetap setiap sesi (WAJIB)

1. Semua aset & kode original buatan sendiri - tidak menyalin aset/nama konten pihak ketiga.
2. Tidak menghadirkan: toggle wawasan, ads.js, donasi, share (permintaan pemilik).
3. Kode dev tetap server-only (DevCodeVault), kredensial hanya di .secrets/ + credentials.json.
4. Test dulu: `tools/luau tests/run_tests.luau` (harus 0 FAIL) + luau-lsp analyze 0 TypeError.
5. Publish langsung ke Roblox (jangan kirim file ke pemilik):
   `export ROBLOX_API_KEY="$(grep -E '^ROBLOX_API_KEY=' /home/z/my-project/.secrets/akiomida.env | cut -d= -f2-)"`
   `python3 publish.py --universe-id 10774464946 --place-id 77626159664192 --file build/DuniaAkiomida.rbxlx`
6. Update README.md + tabel skor di file ini setiap publish.
