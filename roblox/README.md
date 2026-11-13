# Miodakali versi Roblox Studio

Kerangka Desa Miodakali dalam format `.rbxlx` dengan skrip **Luau** — siap dibuka di Roblox Studio. Sistemnya mengikuti skema real-time seperti versi web: tanaman tumbuh mengikuti waktu nyata (tanpa siram/tidur), XP & level petani, ekspansi petak kebun, ternak ber-timer, dan tugas pembuka.

## Cara membuka

1. Buka **Roblox Studio**.
2. Menu **File → Open from File…**
3. Pilih `miodakali.rbxlx`.
4. Tekan **Play** (F5) untuk menguji.

## Skema sistem (sama dengan versi web)

- **Real-time**: Lumira matang 1 menit nyata, Beraka 3 menit, Terunu 5 menit, dst. Timer berjalan terus.
- **XP & Level Petani**: semua aksi memberi XP; level membuka benih baru (Beraka L2, Terunu L3, Makira L5, Kopanu L6, Sundara L8), Panyukan L2, Sapiyu L4.
- **Tenaga**: aksi memakai tenaga; pulih +1 tiap 12 detik nyata; naik level menambah kapasitas.
- **Ekspansi kebun**: 3 petak awal terbuka; petak berikutnya dibeli dengan Kirupi + Balanu + Batuku (harga menaik).
- **Kandang ternak halal**: beli Ayumi/Sapiyu di slot kandang, beri Pakanu, ambil Telur/Susu saat timer siap.
- **Pohon & batu** respawn otomatis 150 detik.

## Isi kerangka

| Bagian | Isi |
| --- | --- |
| `Workspace/TanahDesa` | Pulau desa 240x240 studs |
| `Workspace/Ladang` | 24 petak: 3 terbuka sejak awal, sisanya "Beli Petak" (ekspansi) |
| `Workspace/Kayanu` | Pohon tebang (Balanu, respawn 150 dtk) |
| `Workspace/Batu` | Batu pecah (Batuku, respawn 150 dtk) |
| `Workspace/Kolam` | Kolam (titik memancing menyusul) |
| `Workspace/HewanTernak` | Slot kandang: 3 Ayumi & 2 Sapiyu — mulai kosong, beli lalu beri Pakanu |
| `Rumah, Dapur, Kios, Kandang, Pondok` | Bangunan desa dengan pintu interaktif |
| `ReplicatedStorage/KonfigurasiMiodakali` | Modul konfigurasi (harga, detikTumbuh, XP, ternak, tugas) |
| `ReplicatedStorage/KiosEvent` | RemoteEvent beli/jual |
| `StarterGui/KiosGui` | Antarmuka kios (dibangun oleh LocalScript) |
| `ServerScriptService/MiodakaliUtama` | Sistem utama: Kirupi, LevelPetani, Tenaga (regen real-time), petak & ekspansi, ternak timer, pohon/batu, kios, tugas |

## Salinan skrip

Salinan skrip tersedia di folder `luau/` untuk dibaca:

- `KonfigurasiMiodakali.lua` — modul konfigurasi
- `MiodakaliUtama.server.lua` — sistem utama (server)
- `KiosGui.client.lua` — antarmuka kios (klien)

Seluruh nama, model, dan sistem adalah karya asli game Miodakali — tanpa label dari proyek mana pun.
