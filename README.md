# Miodakali — Petualangan Tani Desa

Game tani santai 2D yang dimainkan langsung di peramban, dibangun dengan Next.js + TypeScript + Canvas 2D.
Seluruh nama item, model visual, dan sistem adalah **karya asli Miodakali** — tidak memakai aset atau nama
dari proyek lain, serta **bebas item yang diharamkan** (ternak hanya Ayumi & Sapiyu; masakan berbahan tumbuhan,
telur, dan susu). Karakter pria & wanita berpakaian rapi dan menutup dengan nama gaya netral.

## Skema sistem (real-time ala permainan tani modern)

- **Tanaman tumbuh waktu nyata** — Lumira 1 menit, Beraka 3 menit, Terunu 5 menit, Makira 10 menit,
  Kopanu 15 menit, Sundara 25 menit. Timer tetap berjalan walau permainan ditutup (progres tersimpan
  di perangkat lewat `localStorage`).
- **Tanpa tidur, tanpa siram** — alur tanam → tunggu → panen berjalan terus, seperti skema
  permainan tani bergaya pulau pribadi.
- **Tenaga** berkurang per aksi dan **pulih +1 tiap 12 detik** nyata (termasuk saat luring);
  masakan memulihkan lebih cepat.
- **XP & Level Petani** — setiap aksi memberi pengalaman; level membuka benih baru
  (Beraka L2, Terunu L3, Makira L5, Kopanu L6, Sundara L8), Panyukan L2, Sapiyu L4, serta resep dapur.
- **Ekspansi kebun** — mulai dengan 3 petak; petak berikutnya dibeli dengan Kirupi + Balanu + Batuku
  (harga menaik), tanda "JUAL" tertanam di petak terkunci.
- **Kandang ternak halal** — beli Ayumi/Sapiyu di slot kandang, beri Pakanu, ambil Telur/Susu saat
  timer produksi siap.
- **Tebang & tambang** — Kayanu menghasilkan Balanu, Batuku menghasilkan Batuku; keduanya tumbuh
  kembali otomatis dalam 150 detik nyata.
- **Rantai tugas pembuka** — 12 tugas berurutan dengan hadiah Kirupi & XP, mengantar pemain baru
  mempelajari seluruh sistem.
- **Kios Desa (Pak Dalu)** — membeli benih/Pakanu/Panyukan dan menjual seluruh hasil dengan harga tetap.
- **Dapur** — 6 resep masakan pemulih tenaga; **Kolam** — minigame Panyukan (Ikana, Silara, Kiraya).
- **Lemari Pakaian** — ganti penampilan (kelamin, warna kulit, gaya pakaian) kapan saja di Rumah.
- **Siang–malam waktu nyata** — pencahayaan dunia mengikuti jam perangkat, lengkap dengan lampu malam.

## Teknologi

- Next.js 16 (App Router) + TypeScript + Tailwind CSS 4 + shadcn/ui + zustand
- Canvas 2D dengan game engine mandiri (`src/lib/miodakali/engine.ts`)
- Seluruh visual digambar prosedural (vektor kode, bukan pixel art, tanpa aset eksternal)
- Efek suara prosedural WebAudio API

## Struktur

```
src/lib/miodakali/        data.ts · sprites.ts · engine.ts · store.ts
src/components/miodakali/ GameRoot · HUD · Hotbar · TouchControls · Panels · CharacterCreator
roblox/                   miodakali.rbxlx + skrip Luau (KonfigurasiMiodakali, MiodakaliUtama, KiosGui)
```

## Menjalankan

```bash
bun install
bun run dev   # buka http://localhost:3000
```

## Versi Roblox Studio

Folder `roblox/` berisi `miodakali.rbxlx` (tempat permainan siap buka di Studio) beserta salinan
skrip Luau di `roblox/luau/` dengan sistem yang sama: real-time, level, ekspansi petak, ternak
ber-timer, dan tugas pembuka. Lihat `roblox/README.md`.

---

Seluruh progres tersimpan otomatis di perangkat pemain. Seluruh nama, model, dan dunia
Miodakali adalah karya asli game ini.
