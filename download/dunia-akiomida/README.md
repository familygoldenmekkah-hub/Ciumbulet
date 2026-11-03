# DUNIA AKIOMIDA - Versi Roblox (v1.0.0)

Port original dari game browser **"Dunia Akiomida: Petualangan Matematika"**
(akiomida.com / repo `akiomida/Io`) ke Roblox. Seluruh kode Luau ditulis dari
nol (karya mandiri), soal digenerate prosedural, dialog & materi ditulis ulang.

**File jadi:** `build/DuniaAkiomida.rbxlx` - siap publish.

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

## CARA PUBLISH

### Opsi A - lewat API (perlu perbaikan 1 menit di dashboard)

Publish terakhir dari sisi kita gagal **HTTP 403 "Scope not authorized"**:
API key yang diberikan belum punya izin untuk universe AKIOMIDA (universe ini
dibuat SETELAH key, jadi belum ter-scope). Perbaikannya:

1. Buka <https://create.roblox.com/credentials> → edit API key lu (atau buat baru).
2. **Access Permissions** → **Add API System** → pilih `universe-places` →
   pilih experience **AKIOMIDA** → Operations: **Write**.
3. (Opsional) Security: expiration date + IP restriction.
4. Simpan, lalu jalankan:
   ```bash
   cd dunia-akiomida
   python3 publish.py --api-key KEY_BARU --universe-id 10774464946 --place-id 77626159664192
   ```
5. Sukses = respons berisi `versionNumber`. Game langsung bisa dimainkan.

> Selama API key belum diperbaiki, bot tidak bisa publish - ini batasan
> keamanan Roblox, bukan bug kode.

### Opsi B - lewat Studio (tanpa API key)

1. Buka Roblox Studio → **File → Open from File** → `build/DuniaAkiomida.rbxlx`.
2. **File → Publish to Roblox As...** → pilih experience **AKIOMIDA** → publish.
3. (Sekali saja) **Home → Game Settings → Security** → aktifkan
   **Studio Access to API Services** supaya DataStore (progres & leaderboard) jalan.

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
