# DUNIA AKIOMIDA v2 — "Ekonomi Hidup" (Roblox)

Status: ✅ LIVE di Roblox (versionNumber 9, 5 Nov 2026)
Universe: 10774464946 · Place: 77626159664192
Build: rojo build --output build/DuniaAkiomida.rbxlx . (189 KB, 14 modul, luau-lsp 0 error)

## Rombakan v2 (dari game kuis → dunia MMO ekonomi)
- **Ladang pribadi** ala Grow a Garden: klaim gratis 1 dari 6 ladang (4x4 petak),
  tanam 5 jenis bibit (wortel→melon bintang), tumbuh nyata waktu (25s-400s),
  siram (+25% kecepatan), panen bercahaya, auto-panen saat keluar server.
- **Ekonomi hidup**: harga pasar naik-turun tiap 10 menit (x0.8-x1.35),
  4 toko (Bibit, Pengepul, Alat, Peliharaan), tombol "Jual Semua".
- **Kumpulkan sumber daya**: tebang 12 pohon (kayu+apel), tambang batu/besi/kristal
  (butuh Belik Batu/Baja), memancing di Danau Tenang (4 jenis tangkapan).
- **Alat**: Kaleng Siram, Pancing Ajaib, Belik tier 2-3, Sepeda Angin (kecepatan+60%).
- **Peliharaan**: Kucing Koin (+10% jual), Panda Martabak (+25%), Naga Emas (+50%)
  - melayang mengikuti pemain.
- **Level & XP**: semua aktivitas memberi XP; level membuka bibit mahal.
- **Kuis BUKAN lagi inti**: hanya Kak Pintar di alun-alun, opsional penuh,
  +20 koin per jawaban benar. Tidak ada popup paksa, tidak ada zona terkunci.
- **Kota hidup**: alun-alun + air mancur, gerbang judul, jalan beton, 36 lampu,
  bangku, bunga, kincir angin, orang-orangan sawah, papan juara XP global.
- Fitur browser versi lama yang sengaja tidak dibawa: ads, donasi, share,
  toggle wawasan (sesuai aturan owner).

## Update versi berikutnya
export ROBLOX_API_KEY="$(grep -E '^ROBLOX_API_KEY=' /home/z/my-project/.secrets/akiomida.env | cut -d= -f2-)"
python3 publish.py --universe-id 10774464946 --place-id 77626159664192 --file build/DuniaAkiomida.rbxlx

## Pasca-publish (dashboard owner)
1. Game Settings → Security → aktifkan "Studio Access to API Services" (DataStore wajib).
2. Jika masih Private, set Public bila ingin pemain lain masuk.

## Keamanan
Kredensial (API key, kode dev) disimpan di /home/z/my-project/.secrets/akiomida.env
(server-only DevCodeVault untuk kode). Jangan commit / bagikan. Rotate bila bocor.
