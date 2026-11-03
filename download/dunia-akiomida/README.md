# DUNIA AKIOMIDA - Versi Roblox (v1.0.0)

Port original dari game browser **"Dunia Akiomida: Petualangan Matematika"**
(akiomida.com / repo `akiomida/Io`) ke Roblox. Seluruh kode Luau ditulis dari
nol (karya mandiri), soal digenerate prosedural, dialog & materi ditulis ulang.

**Status: ✅ LIVE DI ROBLOX** - publish sukses via Open Cloud API
(Universe `10774464946` / Place `77626159664192`, **versionNumber: 5**, 3 Nov 2026).

---

## Yang dibawa ke Roblox (identitas dipertahankan)

| Elemen | Status |
|---|---|
| 6 zona: Kamp Angka, Hutan Simbol, Pegunungan Pola, Kota Bukti, Lembah Kedalaman, Puncak Riset | ✅ nama + slogan + warna asli |
| NPC cerita per zona (Kak Satu, dll) | ✅ dialog ditulis ulang original |
| Kuis matematika pilihan 3 opsi + feedback edukatif | ✅ generator prosedural per zona |
| Progres membaca bahasan/topik | ✅ jadi Papan Bahasan tiap zona |
| Progresif zona (kuasai -> buka berikutnya) | ✅ 10 jawaban benar per zona |
| Leaderboard | ✅ Papan Penjelajah XP (OrderedDataStore) + leaderstats Roblox |
| Dunia eksplorasi | ✅ pulau panjang 6 bioma prosedural + gerbang zona |

## Yang SENGAJA TIDAK dibawa (sesuai instruksi owner)

- ❌ `ads.js` / iklan apa pun
- ❌ Donasi
- ❌ Share / "Kartu Niaga" (salin ke grup)
- ❌ Toggle wawasan (insight)
- ❌ Minigame karavan/niaga & pasar (bisa jadi roadmap v1.1)

## Fitur khusus

- **Kode Penjelajah** (tombol `*` kiri atas): masukkan kode dev internal
  game Akiomida untuk status pembuat dunia.
- Kuis 100% server-authoritative: kunci jawaban tidak pernah dikirim ke client.

## Target publish (milik owner)

- Universe ID: `10774464946` (AKIOMIDA, creator Akiomidaroblox)
- Place ID (root): `77626159664192`

## STATUS PUBLISH & CARA UPDATE

### ✅ Publish pertama - SUKSES (via Open Cloud API)

Setelah owner menambahkan scope `universe-places: Write` untuk experience
AKIOMIDA pada API key, publish berhasil:

```
POST /universes/v1/10774464946/places/77626159664192/versions?versionType=Published
Respons: HTTP 200  {"versionNumber": 5}
```

### Cara update berikutnya (setelah ubah kode)

```bash
cd dunia-akiomida
rojo build --output build/DuniaAkiomida.rbxlx .
python3 publish.py --api-key KEY_ANDA --universe-id 10774464946 \
    --place-id 77626159664192 --file build/DuniaAkiomida.rbxlx
```

Respons berisi `versionNumber` baru = langsung live.

### Catatan penting setelah publish (sekali saja, di Creator Dashboard)

1. **API Services**: AKIOMIDA → Game Settings → Security → aktifkan
   **"Studio Access to API Services"** supaya DataStore jalan
   (progres pemain & Papan Penjelajah XP tersimpan).
2. **Publik/Private**: game sekarang masih Private (hanya owner yang bisa main
   via dashboard). Kalau mau dibuka untuk semua orang: Game Settings →
   Permissions → **Public**.

### Alternatif - lewat Studio (tanpa API key)

1. Buka Roblox Studio → **File → Open from File** → `build/DuniaAkiomida.rbxlx`.
2. **File → Publish to Roblox As...** → pilih experience **AKIOMIDA** → publish.

## Modifikasi & rebuild

```bash
rojo build --output build/DuniaAkiomida.rbxlx .
```

Semua angka tuning (target penguasaan, XP, koin, jarak zona) ada di
`src/Shared/Config.luau`. Bank soal per zona ada di `src/Shared/MathGen.luau`
(prosedural - tambah pola soal = tambah variasi tanpa batas). Materi bahasan
ada di `src/Shared/LessonData.luau`.

## Roadmap sarankan (v1.1)

1. Bahasa Inggris (i18n seperti versi browser)
2. Minigame karavan versi Roblox (tanpa share)
3. Badge Roblox: "Penjelajah Pertama", "Kuasa Kamp Angka", dst.
4. Visual pet/karakter NPC lebih hidup (animasi procedural)
