/**
 * Miodakali — Data & Tipe Game (skema real-time ala Sunflower Land)
 * Seluruh nama item, karakter, dan tempat adalah ciptaan asli milik game Miodakali.
 * Tidak ada nama, label, atau aset dari proyek lain.
 *
 * Skema inti (mengikuti pola Sunflower Land):
 * - Tanaman tumbuh mengikuti WAKTU NYATA (detik), bukan hari tidur.
 * - Tenaga pulih perlahan seiring waktu nyata; makan masakan memulihkan lebih cepat.
 * - XP & Level Petani membuka benih, resep, dan ternak baru.
 * - Petak kebun dibeli bertahap (ekspansi lahan) dengan Kirupi + Balanu + Batuku.
 * - Hewan ternak dibeli, diberi Pakanu, lalu menghasilkan produk pada timer nyata.
 * - Tanpa mekanik tidur/siram: alur tanam-panen berjalan terus.
 */

export type ToolId = 'cangkur' | 'kapura' | 'giliuk' | 'panyukan'

export type TernakJenis = 'ayumi' | 'sapiyu'

export type ItemId = string

export type KategoriItem =
  | 'alat'
  | 'benih'
  | 'hasil'
  | 'material'
  | 'ikan'
  | 'masakan'

export interface ItemDef {
  id: ItemId
  nama: string
  deskripsi: string
  kategori: KategoriItem
  /** Harga jual ke kios (0 = tidak bisa dijual) */
  hargaJual: number
  /** Harga beli di kios (undefined = tidak dijual) */
  hargaBeli?: number
  /** Pemulihan tenaga saat dimakan */
  energi?: number
  /** true = termasuk perangkat kerja */
  alat?: boolean
  /** Level Petani minimum untuk membeli (default 1) */
  levelButuh?: number
  warna: string
}

export interface CropDef {
  /** id hasil panen */
  hasil: ItemId
  /** id benih */
  benih: ItemId
  nama: string
  /** waktu tumbuh nyata dalam detik (0..1 kemajuan tampil bertahap) */
  detikTumbuh: number
  /** Level Petani minimum untuk membeli benih */
  levelButuh: number
  /** XP yang didapat saat panen */
  xpPanen: number
  warnaDaun: string
  warnaBuah: string
}

export interface ResepDef {
  id: ItemId
  bahan: Array<[ItemId, number]>
  /** Level Petani minimum untuk memasak resep */
  levelButuh: number
  /** XP yang didapat saat masak */
  xp: number
}

export interface IkanDef {
  id: ItemId
  peluang: number
}

export interface TernakDef {
  jenis: TernakJenis
  nama: string
  harga: number
  levelButuh: number
  /** waktu nyata dari pakanu sampai hasil siap (detik) */
  detikProduksi: number
  hasil: ItemId
}

/** Peta zona pertanian (dalam tile) */
export const FARM = {
  x0: 5,
  y0: 9,
  x1: 14,
  y1: 18,
}

export const MAP_W = 36
export const MAP_H = 30
export const TS = 48

export const KONSTANTA = {
  /** tenaga maksimum dasar (bertambah tiap naik level) */
  energiMaksDasar: 100,
  /** tambahan tenaga maksimum per level */
  energiPerLevel: 5,
  /** pulih 1 tenaga tiap N detik nyata (termasuk saat game tertutup) */
  regenTenagaDetik: 12,
  uangAwal: 150,
  /** jumlah petak yang terbuka sejak awal (ala Sunflower Land: mulai kecil) */
  petakAwal: 3,
  /** pohon & batu tumbuh kembali setelah N detik nyata */
  respawnDetik: 150,
}

/** Tenaga maksimum untuk suatu level */
export function energiMaks(level: number): number {
  return KONSTANTA.energiMaksDasar + Math.max(0, level - 1) * KONSTANTA.energiPerLevel
}

/**
 * XP yang dibutuhkan untuk naik dari level L ke L+1.
 * XP_BUTUH[0] = level 1 -> 2, dst.
 */
export const XP_BUTUH = [30, 50, 80, 120, 180, 260, 330, 450, 600, 800, 1000, 1250, 1500, 1800, 2200]

export function infoLevel(xp: number): { level: number; xpSaatIni: number; xpButuh: number } {
  let level = 1
  let sisa = Math.max(0, Math.floor(xp))
  while (level <= XP_BUTUH.length && sisa >= XP_BUTUH[level - 1]) {
    sisa -= XP_BUTUH[level - 1]
    level += 1
  }
  const butuh = level <= XP_BUTUH.length ? XP_BUTUH[level - 1] : 0
  return { level, xpSaatIni: sisa, xpButuh: butuh }
}

/** Biaya membeli petak ke-N (0 = petak ke-4, dst.) — meniru ekspansi lahan bertahap */
export function biayaPetak(n: number): { uang: number; balanu: number; batuku: number } {
  return {
    uang: 40 + 25 * n,
    balanu: 2 + Math.floor(n / 2),
    batuku: 1 + Math.floor(n / 3),
  }
}

export const CROPS: CropDef[] = [
  { hasil: 'lumira', benih: 'benih_lumira', nama: 'Lumira', detikTumbuh: 60, levelButuh: 1, xpPanen: 2, warnaDaun: '#4f9e3c', warnaBuah: '#79c953' },
  { hasil: 'beraka', benih: 'benih_beraka', nama: 'Beraka', detikTumbuh: 180, levelButuh: 2, xpPanen: 3, warnaDaun: '#5aa04a', warnaBuah: '#e5b94f' },
  { hasil: 'terunu', benih: 'benih_terunu', nama: 'Terunu', detikTumbuh: 300, levelButuh: 3, xpPanen: 4, warnaDaun: '#4e9a46', warnaBuah: '#e8862f' },
  { hasil: 'makira', benih: 'benih_makira', nama: 'Makira', detikTumbuh: 600, levelButuh: 5, xpPanen: 6, warnaDaun: '#4f9e3c', warnaBuah: '#f0c93e' },
  { hasil: 'kopanu', benih: 'benih_kopanu', nama: 'Kopanu', detikTumbuh: 900, levelButuh: 6, xpPanen: 7, warnaDaun: '#48903f', warnaBuah: '#7fbf5a' },
  { hasil: 'sundara', benih: 'benih_sundara', nama: 'Sundara', detikTumbuh: 1500, levelButuh: 8, xpPanen: 9, warnaDaun: '#4a9440', warnaBuah: '#e04b3a' },
]

export const CROPS_BY_ID: Record<ItemId, CropDef> = Object.fromEntries(
  CROPS.map((c) => [c.hasil, c]),
)

export const TERNAK: Record<TernakJenis, TernakDef> = {
  ayumi: { jenis: 'ayumi', nama: 'Ayumi', harga: 60, levelButuh: 1, detikProduksi: 120, hasil: 'telur_ayumi' },
  sapiyu: { jenis: 'sapiyu', nama: 'Sapiyu', harga: 180, levelButuh: 4, detikProduksi: 300, hasil: 'susu_sapiyu' },
}

export const ITEMS: Record<ItemId, ItemDef> = {
  // ---- Perangkat ----
  cangkur: { id: 'cangkur', nama: 'Cangkur', deskripsi: 'Perangkat untuk menggemburkan tanah pertanian.', kategori: 'alat', hargaJual: 0, alat: true, warna: '#8a5a33' },
  kapura: { id: 'kapura', nama: 'Kapura', deskripsi: 'Perangkat menebang Kayanu menjadi Balanu.', kategori: 'alat', hargaJual: 0, alat: true, warna: '#a0a0a0' },
  giliuk: { id: 'giliuk', nama: 'Giliuk', deskripsi: 'Perangkat memecah Batuku yang keras.', kategori: 'alat', hargaJual: 0, alat: true, warna: '#6f6f6f' },
  panyukan: { id: 'panyukan', nama: 'Panyukan', deskripsi: 'Joran pancing untuk menangkap ikan di kolam.', kategori: 'alat', hargaJual: 0, hargaBeli: 120, levelButuh: 2, alat: true, warna: '#7a6a4f' },

  // ---- Benih (level membuka benih baru, ala pasar Sunflower Land) ----
  benih_lumira: { id: 'benih_lumira', nama: 'Benih Lumira', deskripsi: 'Benih sayuran daun — matang 1 menit.', kategori: 'benih', hargaJual: 0, hargaBeli: 12, levelButuh: 1, warna: '#79c953' },
  benih_beraka: { id: 'benih_beraka', nama: 'Benih Beraka', deskripsi: 'Benih bijian emas — matang 3 menit.', kategori: 'benih', hargaJual: 0, hargaBeli: 28, levelButuh: 2, warna: '#e5b94f' },
  benih_terunu: { id: 'benih_terunu', nama: 'Benih Terunu', deskripsi: 'Benih umbi jingga — matang 5 menit.', kategori: 'benih', hargaJual: 0, hargaBeli: 45, levelButuh: 3, warna: '#e8862f' },
  benih_makira: { id: 'benih_makira', nama: 'Benih Makira', deskripsi: 'Benih tongkol bijian — matang 10 menit.', kategori: 'benih', hargaJual: 0, hargaBeli: 70, levelButuh: 5, warna: '#f0c93e' },
  benih_kopanu: { id: 'benih_kopanu', nama: 'Benih Kopanu', deskripsi: 'Benih polong hijau — matang 15 menit.', kategori: 'benih', hargaJual: 0, hargaBeli: 95, levelButuh: 6, warna: '#7fbf5a' },
  benih_sundara: { id: 'benih_sundara', nama: 'Benih Sundara', deskripsi: 'Benih buah merah — matang 25 menit.', kategori: 'benih', hargaJual: 0, hargaBeli: 140, levelButuh: 8, warna: '#e04b3a' },

  // ---- Hasil panen ----
  lumira: { id: 'lumira', nama: 'Lumira', deskripsi: 'Sayuran daun hijau segar.', kategori: 'hasil', hargaJual: 22, warna: '#79c953' },
  beraka: { id: 'beraka', nama: 'Beraka', deskripsi: 'Bijian emas wajib di dapur desa.', kategori: 'hasil', hargaJual: 48, warna: '#e5b94f' },
  terunu: { id: 'terunu', nama: 'Terunu', deskripsi: 'Umbi jingga manis dari tanah subur.', kategori: 'hasil', hargaJual: 75, warna: '#e8862f' },
  makira: { id: 'makira', nama: 'Makira', deskripsi: 'Tongkol bijian kuning cerah.', kategori: 'hasil', hargaJual: 110, warna: '#f0c93e' },
  kopanu: { id: 'kopanu', nama: 'Kopanu', deskripsi: 'Polong hijau yang renyah.', kategori: 'hasil', hargaJual: 150, warna: '#7fbf5a' },
  sundara: { id: 'sundara', nama: 'Sundara', deskripsi: 'Buah merah premium khas ladang.', kategori: 'hasil', hargaJual: 220, warna: '#e04b3a' },

  // ---- Material & ternak ----
  balanu: { id: 'balanu', nama: 'Balanu', deskripsi: 'Kayu hasil tebangan Kayanu, bahan ekspansi petak.', kategori: 'material', hargaJual: 10, warna: '#a97142' },
  batuku: { id: 'batuku', nama: 'Batuku', deskripsi: 'Batu hasil pecahan untuk bahan bangunan.', kategori: 'material', hargaJual: 12, warna: '#8f8f8f' },
  pakanu: { id: 'pakanu', nama: 'Pakanu', deskripsi: 'Pakan hewan ternak Ayumi dan Sapiyu.', kategori: 'material', hargaJual: 0, hargaBeli: 8, warna: '#c9a35a' },
  telur_ayumi: { id: 'telur_ayumi', nama: 'Telur Ayumi', deskripsi: 'Telur segar dari Ayumi yang rajin.', kategori: 'hasil', hargaJual: 22, warna: '#f2e3c2' },
  susu_sapiyu: { id: 'susu_sapiyu', nama: 'Susu Sapiyu', deskripsi: 'Susu segar dari Sapiyu yang sehat.', kategori: 'hasil', hargaJual: 60, warna: '#f7f3e8' },

  // ---- Ikan ----
  ikana: { id: 'ikana', nama: 'Ikana', deskripsi: 'Ikan kolam yang paling umum.', kategori: 'ikan', hargaJual: 20, warna: '#8fa8b8' },
  silara: { id: 'silara', nama: 'Silara', deskripsi: 'Ikan berkilau perak, cukup langka.', kategori: 'ikan', hargaJual: 36, warna: '#c8d8e0' },
  kiraya: { id: 'kiraya', nama: 'Kiraya', deskripsi: 'Ikan emas legendaris Desa Miodakali.', kategori: 'ikan', hargaJual: 62, warna: '#e8b840' },

  // ---- Masakan ----
  tumis_lumira: { id: 'tumis_lumira', nama: 'Tumis Lumira', deskripsi: 'Lumira dimasak bumbu desa.', kategori: 'masakan', hargaJual: 55, energi: 30, warna: '#5a9e4a' },
  panggang_terunu: { id: 'panggang_terunu', nama: 'Panggang Terunu', deskripsi: 'Terunu bakar aroma kayu api.', kategori: 'masakan', hargaJual: 110, energi: 45, warna: '#c9702f' },
  makira_rebus: { id: 'makira_rebus', nama: 'Makira Rebus', deskripsi: 'Makira rebus bersanding Telur Ayumi.', kategori: 'masakan', hargaJual: 150, energi: 55, warna: '#f0c93e' },
  bubur_beraka: { id: 'bubur_beraka', nama: 'Bubur Beraka', deskripsi: 'Bubur Beraka lembut ber-Susu Sapiyu.', kategori: 'masakan', hargaJual: 145, energi: 55, warna: '#e8ddc4' },
  kue_kopanu: { id: 'kue_kopanu', nama: 'Kue Kopanu', deskripsi: 'Kue gurih dari Kopanu dan Telur Ayumi.', kategori: 'masakan', hargaJual: 185, energi: 65, warna: '#a8894f' },
  sup_sundara: { id: 'sup_sundara', nama: 'Sup Sundara', deskripsi: 'Sup hangat Sundara dan Susu Sapiyu.', kategori: 'masakan', hargaJual: 260, energi: 80, warna: '#e04b3a' },
}

export const RECIPES: ResepDef[] = [
  { id: 'tumis_lumira', bahan: [['lumira', 2]], levelButuh: 1, xp: 4 },
  { id: 'panggang_terunu', bahan: [['terunu', 2]], levelButuh: 3, xp: 6 },
  { id: 'makira_rebus', bahan: [['makira', 2], ['telur_ayumi', 1]], levelButuh: 4, xp: 8 },
  { id: 'bubur_beraka', bahan: [['beraka', 3], ['susu_sapiyu', 1]], levelButuh: 5, xp: 8 },
  { id: 'kue_kopanu', bahan: [['kopanu', 2], ['telur_ayumi', 1]], levelButuh: 6, xp: 10 },
  { id: 'sup_sundara', bahan: [['sundara', 2], ['susu_sapiyu', 1]], levelButuh: 8, xp: 12 },
]

export const FISH_TABLE: IkanDef[] = [
  { id: 'ikana', peluang: 0.62 },
  { id: 'silara', peluang: 0.28 },
  { id: 'kiraya', peluang: 0.1 },
]

export const TOOLS_ORDER: ToolId[] = ['cangkur', 'kapura', 'giliuk', 'panyukan']

/** Biaya tenaga tiap aksi (meniru biaya tenaga aksi ala Sunflower Land) */
export const BIAYA_TENAGA = {
  gembur: 2,
  tanam: 1,
  panen: 1,
  tebang: 5,
  pecah: 5,
  pancing: 6,
  pakanu: 1,
  ambil: 1,
  masak: 3,
}

/** XP yang didapat tiap aksi */
export const XP_AKSI = {
  gembur: 1,
  tanam: 1,
  tebang: 3,
  pecah: 3,
  pancing: 6,
  pakanu: 1,
  ambil: 3,
  makan: 2,
  beliPetak: 5,
}

/** Rantai tugas pembuka ala tutorial Sunflower Land */
export interface QuestDef {
  id: string
  teks: string
  hadiahUang: number
  hadiahXp: number
}

export const QUESTS: QuestDef[] = [
  { id: 'tanam', teks: 'Tanam Benih Lumira di petak kebun', hadiahUang: 20, hadiahXp: 5 },
  { id: 'panen', teks: 'Panen Lumira yang sudah matang', hadiahUang: 25, hadiahXp: 10 },
  { id: 'jual', teks: 'Jual hasil panen di Kios Desa', hadiahUang: 30, hadiahXp: 10 },
  { id: 'beli', teks: 'Beli 3 benih apa pun di Kios Desa', hadiahUang: 20, hadiahXp: 5 },
  { id: 'tebas', teks: 'Tebas Kayanu dengan Kapura', hadiahUang: 25, hadiahXp: 10 },
  { id: 'tambang', teks: 'Pecah Batuku dengan Giliuk', hadiahUang: 25, hadiahXp: 10 },
  { id: 'ternak', teks: 'Beli Ayumi di kandang & beri Pakanu', hadiahUang: 40, hadiahXp: 15 },
  { id: 'petak', teks: 'Perluas kebun: beli petak baru', hadiahUang: 30, hadiahXp: 15 },
  { id: 'masak', teks: 'Masak satu masakan di Dapur Desa', hadiahUang: 40, hadiahXp: 15 },
  { id: 'pancing', teks: 'Pancing ikan di Kolam', hadiahUang: 50, hadiahXp: 20 },
  { id: 'makan', teks: 'Makan masakan untuk memulihkan tenaga', hadiahUang: 30, hadiahXp: 10 },
  { id: 'lv3', teks: 'Capai Level 3 Petani', hadiahUang: 60, hadiahXp: 0 },
]

export interface KarakterCfg {
  kelamin: 'pria' | 'wanita'
  /** indeks warna kulit 0..2 */
  kulit: number
  /** indeks gaya pakaian 0..2 (Desa / Ladang / Pesisir) */
  gaya: number
}

export const KULIT_WARNA = ['#f2c9a0', '#d9a066', '#a9713f']
export const GAYA_NAMA = ['Desa', 'Ladang', 'Pesisir']
/** [baju, bawahan, penutup pria, selendang wanita] — pakaian rapi dan menutup dada-paha */
export const GAYA_WARNA: Array<{ baju: string; bawah: string; tutup: string; tutupWanita: string }> = [
  { baju: '#5e8c4a', bawah: '#5a4a3a', tutup: '#3a3a3a', tutupWanita: '#8a5a5a' },
  { baju: '#c4703f', bawah: '#6a5a44', tutup: '#3a3a3a', tutupWanita: '#c98a4a' },
  { baju: '#2f6f6a', bawah: '#464e52', tutup: '#3a3a3a', tutupWanita: '#4a7a74' },
]

export const NAMA_NPC = {
  penjual: 'Pak Dalu',
  desa: 'Desa Miodakali',
  uang: 'Kirupi',
  tenaga: 'Tenaga',
  level: 'Level Petani',
  xp: 'Pengalaman',
}

/** Inventori awal pemain baru: 3 petak & 3 benih (ala awal Sunflower Land) */
export function inventoriAwal(): Record<ItemId, number> {
  return {
    cangkur: 1,
    kapura: 1,
    giliuk: 1,
    benih_lumira: 3,
  }
}

/** Format sisa waktu detik -> "45 dtk", "1m 20dtk" */
export function formatWaktu(detik: number): string {
  const s = Math.max(0, Math.ceil(detik))
  if (s < 60) return `${s} dtk`
  const m = Math.floor(s / 60)
  const r = s % 60
  if (m < 60) return r > 0 ? `${m}m ${r} dtk` : `${m}m`
  const h = Math.floor(m / 60)
  return `${h}j ${m % 60}m`
}
