/**
 * Miodakali — Engine Game (canvas 2D)
 * Dunia desa Miodakali dengan skema real-time ala Sunflower Land:
 * tanaman tumbuh mengikuti waktu nyata, tenaga pulih bertahap, XP & level
 * petani, ekspansi petak kebun, ternak ber-timer, memancing, dan masak.
 * Seluruh sistem & model adalah karya asli game Miodakali.
 */
import {
  BIAYA_TENAGA,
  CROPS_BY_ID,
  CROPS,
  FARM,
  FISH_TABLE,
  ITEMS,
  KONSTANTA,
  MAP_H,
  MAP_W,
  QUESTS,
  RECIPES,
  TERNAK,
  TS,
  TOOLS_ORDER,
  XP_AKSI,
  biayaPetak,
  formatWaktu,
  infoLevel,
  energiMaks,
  ToolId,
  TernakJenis,
  ItemId,
  KarakterCfg,
  inventoriAwal,
} from './data'
import {
  Arah,
  drawAyumi,
  drawBuilding,
  drawCharacter,
  drawCropPlant,
  drawFencePost,
  drawNPC,
  drawRock,
  drawSapiyu,
  drawToolSwing,
  drawTree,
  JenisBangunan,
} from './sprites'
import { useGameStore } from './store'

/* ----------------------------- Struktur data ----------------------------- */

export interface PlotSimpan {
  t: boolean // sudah digemburkan
  c?: ItemId // tanaman yang ditanam
  at?: number // timestamp tanam (ms) — pertumbuhan mengikuti waktu nyata
  buka?: boolean // petak sudah dibeli (ekspansi lahan)
}

interface Plot extends PlotSimpan {
  tx: number
  ty: number
}

interface TreeObj {
  tx: number
  ty: number
  hp: number
  hidup: boolean
  respawn: number
  seed: number
  shake: number
}

interface RockObj {
  tx: number
  ty: number
  hp: number
  hidup: boolean
  respawn: number
  seed: number
  shake: number
}

/** Slot ternak di kandang — dibeli, diberi Pakanu, hasil siap pada timer nyata */
interface TernakSlot {
  jenis: TernakJenis | null
  pakanAt: number | null
  siapAt: number | null
  tx: number
  ty: number
}

interface Partikel {
  x: number
  y: number
  vx: number
  vy: number
  life: number
  warna: string
}

interface InteractPoint {
  tx: number
  ty: number
  jenis: 'rumah' | 'dapur' | 'kios' | 'kandang' | 'pondok' | 'npc' | 'sign'
}

interface BangunanDef {
  jenis: JenisBangunan
  tx: number
  ty: number
  w: number
  h: number
}

export interface Simpanan {
  v: 2
  dibuatPada: number
  lastSeen: number
  lastRegenAt: number
  money: number
  xp: number
  energy: number
  inv: Record<ItemId, number>
  tool: ToolId
  activeItem: ItemId | null
  plots: PlotSimpan[]
  trees: Array<[number, number, number, boolean, number]>
  rocks: Array<[number, number, number, boolean, number]>
  ternak: Array<[TernakJenis | null, number | null, number | null]>
  panyukan: boolean
  questIdx: number
  stat: Record<string, number>
  char: KarakterCfg
  px: number
  py: number
  arah: Arah
}

const KUNCI_SIMPAN = 'miodakali_save_v2'

const BANGUNAN: BangunanDef[] = [
  { jenis: 'rumah', tx: 3, ty: 2, w: 6, h: 5 },
  { jenis: 'dapur', tx: 11, ty: 2, w: 4, h: 4 },
  { jenis: 'kios', tx: 22, ty: 2, w: 6, h: 5 },
  { jenis: 'kandang', tx: 2, ty: 19, w: 4, h: 4 },
  { jenis: 'pondok', tx: 25, ty: 19, w: 4, h: 4 },
]

const POND = { x0: 21, y0: 9, x1: 26, y1: 13 }

const GATE = {
  atas1: { x: 9, y: 8 },
  atas2: { x: 10, y: 8 },
  kiri1: { x: 4, y: 13 },
  kiri2: { x: 4, y: 14 },
  kandang: { x: 8, y: 25 },
  pondok: { x: 24, y: 25 },
}

const PETA_POHON: Array<[number, number]> = [
  [2, 10], [2, 12], [3, 14], [2, 16], [3, 17],
  [30, 6], [32, 8], [31, 10], [33, 12], [30, 14], [32, 16],
  [8, 0], [12, 0], [16, 0], [20, 1], [29, 0], [33, 0],
  [5, 27], [7, 28], [9, 27], [12, 28], [15, 27], [18, 28],
  [21, 27], [24, 28], [28, 27], [31, 28], [33, 27],
]

const PETA_BATU: Array<[number, number]> = [
  [17, 12], [18, 15], [16, 18], [12, 21], [16, 21],
  [28, 10], [29, 13], [27, 16],
]

const JALUR: Array<[number, number]> = []
for (let x = 6; x <= 28; x++) JALUR.push([x, 7])
JALUR.push([10, 8])
for (let y = 8; y <= 25; y++) JALUR.push([19, y])
for (let x = 8; x <= 23; x++) JALUR.push([x, 25])

function diDalam(x: number, y: number, x0: number, y0: number, x1: number, y1: number) {
  return x >= x0 && x <= x1 && y >= y0 && y <= y1
}

function hashTile(x: number, y: number) {
  const n = Math.sin(x * 127.1 + y * 311.7) * 43758.5453
  return n - Math.floor(n)
}

/* ------------------------------ Efek Suara ------------------------------ */

class Sfx {
  private ac: AudioContext | null = null
  private aktif = false

  init() {
    if (this.aktif) return
    try {
      const AC = window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext
      this.ac = new AC()
      this.aktif = true
    } catch {
      this.ac = null
    }
  }

  play(nama: 'pop' | 'coin' | 'chop' | 'splash' | 'eat' | 'error') {
    if (!this.ac) return
    const t0 = this.ac.currentTime
    const o = this.ac.createOscillator()
    const g = this.ac.createGain()
    o.connect(g)
    g.connect(this.ac.destination)
    const v = 0.09
    switch (nama) {
      case 'pop':
        o.type = 'square'
        o.frequency.setValueAtTime(440, t0)
        o.frequency.exponentialRampToValueAtTime(660, t0 + 0.08)
        g.gain.setValueAtTime(v, t0)
        g.gain.exponentialRampToValueAtTime(0.001, t0 + 0.1)
        o.start(t0); o.stop(t0 + 0.1)
        break
      case 'coin':
        o.type = 'sine'
        o.frequency.setValueAtTime(880, t0)
        o.frequency.setValueAtTime(1320, t0 + 0.06)
        g.gain.setValueAtTime(v, t0)
        g.gain.exponentialRampToValueAtTime(0.001, t0 + 0.16)
        o.start(t0); o.stop(t0 + 0.16)
        break
      case 'chop':
        o.type = 'sawtooth'
        o.frequency.setValueAtTime(180, t0)
        o.frequency.exponentialRampToValueAtTime(60, t0 + 0.1)
        g.gain.setValueAtTime(v * 1.4, t0)
        g.gain.exponentialRampToValueAtTime(0.001, t0 + 0.12)
        o.start(t0); o.stop(t0 + 0.12)
        break
      case 'splash':
        o.type = 'sine'
        o.frequency.setValueAtTime(300, t0)
        o.frequency.exponentialRampToValueAtTime(80, t0 + 0.22)
        g.gain.setValueAtTime(v * 1.2, t0)
        g.gain.exponentialRampToValueAtTime(0.001, t0 + 0.24)
        o.start(t0); o.stop(t0 + 0.24)
        break
      case 'eat':
        o.type = 'triangle'
        o.frequency.setValueAtTime(300, t0)
        o.frequency.setValueAtTime(500, t0 + 0.07)
        g.gain.setValueAtTime(v, t0)
        g.gain.exponentialRampToValueAtTime(0.001, t0 + 0.16)
        o.start(t0); o.stop(t0 + 0.16)
        break
      case 'error':
        o.type = 'square'
        o.frequency.setValueAtTime(160, t0)
        g.gain.setValueAtTime(v, t0)
        g.gain.exponentialRampToValueAtTime(0.001, t0 + 0.16)
        o.start(t0); o.stop(t0 + 0.16)
        break
    }
  }
}

/* -------------------------------- Engine -------------------------------- */

export class Engine {
  private canvas: HTMLCanvasElement
  private ctx: CanvasRenderingContext2D
  private raf = 0
  private last = 0
  private waktu = 0
  private keys = new Set<string>()
  private gerakVec = { x: 0, y: 0 }
  private keyVec = { x: 0, y: 0 }
  private simpanTimer = 0
  private hudTimer = 0
  private labelTerakhir = ''

  // state dunia
  private money = KONSTANTA.uangAwal
  private xp = 0
  private energy = energiMaks(1)
  private dibuatPada = Date.now()
  private lastRegenAt = Date.now()
  private lastSeen = Date.now()
  private inv: Record<ItemId, number> = inventoriAwal()
  private tool: ToolId = 'cangkur'
  private activeItem: ItemId | null = null
  private plots: Plot[] = []
  private trees: TreeObj[] = []
  private rocks: RockObj[] = []
  private ternak: TernakSlot[] = []
  private panyukan = false
  private questIdx = 0
  private stat: Record<string, number> = {}
  private char: KarakterCfg = { kelamin: 'pria', kulit: 0, gaya: 0 }
  private px = 10
  private py = 7.5
  private arah: Arah = 0
  private langkah = 0
  private berjalan = false
  private aksiAnim = 0
  private aksiTool: ToolId | null = null
  private partikel: Partikel[] = []
  private hintPancing = false

  private fish: {
    t: number
    ok: number
    miss: number
    fx: number
    zx: number
    zw: number
    over: number
    sukses: boolean
  } | null = null

  private solid: Uint8Array
  private interPoints: InteractPoint[] = []
  private sfx = new Sfx()

  constructor(canvas: HTMLCanvasElement) {
    this.canvas = canvas
    const c = canvas.getContext('2d')
    if (!c) throw new Error('Canvas 2D tidak tersedia')
    this.ctx = c
    this.solid = new Uint8Array(MAP_W * MAP_H)
    this.bangunDunia()
    this.bindInput()
    this.resize()
    // muat data tersimpan bila ada (agar aman dari pemuatan ulang halaman)
    if (this.punyaSimpanan()) this.muatData()
    // sinkronkan UI dengan keadaan engine saat ini
    this.syncInv()
    useGameStore.getState().setTool(this.tool)
  }

  /* ------------------------------- Dunia ------------------------------- */

  private bangunDunia() {
    // solid dasar: tepi peta
    for (let x = 0; x < MAP_W; x++) {
      this.markSolid(x, 0, 1)
      this.markSolid(x, MAP_H - 1, 1)
    }
    for (let y = 0; y < MAP_H; y++) {
      this.markSolid(0, y, 1)
      this.markSolid(MAP_W - 1, y, 1)
    }

    // bangunan
    for (const b of BANGUNAN) {
      for (let x = b.tx; x < b.tx + b.w; x++) {
        for (let y = b.ty; y < b.ty + b.h; y++) this.markSolid(x, y, 1)
      }
    }

    // kolam
    for (let x = POND.x0; x <= POND.x1; x++) {
      for (let y = POND.y0; y <= POND.y1; y++) this.markSolid(x, y, 1)
    }

    // pohon
    this.trees = PETA_POHON.map(([tx, ty], i) => {
      this.markSolid(tx, ty, 1)
      return { tx, ty, hp: 3, hidup: true, respawn: 0, seed: (i * 7.13) % 1, shake: 0 }
    })

    // batu
    this.rocks = PETA_BATU.map(([tx, ty], i) => {
      this.markSolid(tx, ty, 1)
      return { tx, ty, hp: 3, hidup: true, respawn: 0, seed: (i * 5.31) % 1, shake: 0 }
    })

    // pagar zona pertanian (x4..15, y8..19) dengan gerbang
    for (let x = FARM.x0 - 1; x <= FARM.x1 + 1; x++) {
      for (const y of [FARM.y0 - 1, FARM.y1 + 1]) {
        if ((x === GATE.atas1.x && y === GATE.atas1.y) || (x === GATE.atas2.x && y === GATE.atas2.y)) continue
        this.markSolid(x, y, 1)
      }
    }
    for (let y = FARM.y0 - 1; y <= FARM.y1 + 1; y++) {
      for (const x of [FARM.x0 - 1, FARM.x1 + 1]) {
        if ((x === GATE.kiri1.x && y === GATE.kiri1.y) || (x === GATE.kiri2.x && y === GATE.kiri2.y)) continue
        this.markSolid(x, y, 1)
      }
    }

    // pagar halaman kandang (x2..8, y24..26) & pondok (x24..29, y24..26)
    for (let x = 2; x <= 8; x++) {
      for (const y of [24, 26]) this.markSolid(x, y, 1)
    }
    for (let y = 24; y <= 26; y++) {
      for (const x of [2, 8]) {
        if (x === GATE.kandang.x && y === GATE.kandang.y) continue
        this.markSolid(x, y, 1)
      }
    }
    for (let x = 24; x <= 29; x++) {
      for (const y of [24, 26]) this.markSolid(x, y, 1)
    }
    for (let y = 24; y <= 26; y++) {
      for (const x of [24, 29]) {
        if (x === GATE.pondok.x && y === GATE.pondok.y) continue
        this.markSolid(x, y, 1)
      }
    }

    // petak pertanian (urutan baris-major agar cocok dengan plotDi)
    // mulai dengan 3 petak terbuka ala Sunflower Land; sisanya dibeli bertahap
    this.plots = []
    for (let y = FARM.y0; y <= FARM.y1; y++) {
      for (let x = FARM.x0; x <= FARM.x1; x++) {
        this.plots.push({
          tx: x,
          ty: y,
          t: false,
          buka: this.plots.length < KONSTANTA.petakAwal,
        })
      }
    }

    // slot ternak di kandang: 3 Ayumi + 2 Sapiyu (semua halal)
    const slotAyumi: Array<[number, number]> = [[3, 25], [4, 25], [5, 25]]
    const slotSapiyu: Array<[number, number]> = [[6, 25], [7, 25]]
    this.ternak = [
      ...slotAyumi.map(([tx, ty]) => ({ jenis: null, pakanAt: null, siapAt: null, tx, ty })),
      ...slotSapiyu.map(([tx, ty]) => ({ jenis: null, pakanAt: null, siapAt: null, tx, ty })),
    ]

    // titik interaksi
    this.interPoints = [
      { tx: 5.5, ty: 7.2, jenis: 'rumah' },
      { tx: 12.5, ty: 6.2, jenis: 'dapur' },
      { tx: 24.5, ty: 7.2, jenis: 'kios' },
      { tx: 27.6, ty: 8.6, jenis: 'npc' },
      { tx: 11.5, ty: 6.9, jenis: 'sign' },
    ]
  }

  private markSolid(x: number, y: number, v: number) {
    if (x < 0 || y < 0 || x >= MAP_W || y >= MAP_H) return
    this.solid[y * MAP_W + x] = v
  }

  private isSolid(x: number, y: number) {
    if (x < 0 || y < 0 || x >= MAP_W || y >= MAP_H) return true
    return this.solid[Math.floor(y) * MAP_W + Math.floor(x)] === 1
  }

  private plotDi(tx: number, ty: number): Plot | null {
    if (!diDalam(tx, ty, FARM.x0, FARM.y0, FARM.x1, FARM.y1)) return null
    return this.plots[(ty - FARM.y0) * (FARM.x1 - FARM.x0 + 1) + (tx - FARM.x0)] ?? null
  }

  /** Kemajuan tumbuh 0..1 berdasarkan waktu nyata sejak ditanam */
  private rasioTumbuh(p: Plot): number {
    if (!p.c || !p.at) return 0
    const def = CROPS_BY_ID[p.c]
    return (Date.now() - p.at) / (def.detikTumbuh * 1000)
  }

  private stageOf(p: Plot): number {
    const r = this.rasioTumbuh(p)
    if (r >= 1) return 3
    if (r >= 0.62) return 2
    if (r >= 0.3) return 1
    return 0
  }

  private level(): number {
    return infoLevel(this.xp).level
  }

  private hariKe(): number {
    return 1 + Math.floor((Date.now() - this.dibuatPada) / 86400000)
  }

  /** Jumlah petak yang sudah dibeli melewati petak awal */
  private petakDibeli(): number {
    return Math.max(0, this.plots.filter((p) => p.buka).length - KONSTANTA.petakAwal)
  }

  /* ---------------------------- Input & Siklus ---------------------------- */

  private onKey = (e: KeyboardEvent) => {
    const st = useGameStore.getState()
    if (e.key === 'Escape') {
      if (this.fish) {
        this.fish = null
        return
      }
      if (st.panel) st.setPanel(null)
      return
    }
    if (st.screen !== 'game') return
    if (['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight', ' '].includes(e.key)) e.preventDefault()
    if (e.repeat) return
    this.keys.add(e.key)
    this.sfx.init()
    if (e.key === 'e' || e.key === 'E' || e.key === ' ') {
      this.pressAction()
    } else if (e.key === 'i' || e.key === 'I') {
      st.setPanel(st.panel === 'inv' ? null : 'inv')
    } else if (['1', '2', '3', '4'].includes(e.key)) {
      this.setTool(parseInt(e.key, 10) - 1)
    }
  }

  private onKeyUp = (e: KeyboardEvent) => {
    this.keys.delete(e.key)
  }

  private bindInput() {
    window.addEventListener('keydown', this.onKey)
    window.addEventListener('keyup', this.onKeyUp)
    window.addEventListener('resize', this.resize)
    window.addEventListener('pointerdown', this.onPointerFirst)
  }

  private onPointerFirst = () => {
    this.sfx.init()
  }

  private resize = () => {
    const dpr = Math.min(2, window.devicePixelRatio || 1)
    this.canvas.width = Math.floor(window.innerWidth * dpr)
    this.canvas.height = Math.floor(window.innerHeight * dpr)
    this.canvas.style.width = '100%'
    this.canvas.style.height = '100%'
  }

  start() {
    this.last = performance.now()
    const loop = (t: number) => {
      const dt = Math.min(0.05, (t - this.last) / 1000)
      this.last = t
      this.update(dt)
      this.draw()
      this.raf = requestAnimationFrame(loop)
    }
    this.raf = requestAnimationFrame(loop)
  }

  stop() {
    cancelAnimationFrame(this.raf)
    window.removeEventListener('keydown', this.onKey)
    window.removeEventListener('keyup', this.onKeyUp)
    window.removeEventListener('resize', this.resize)
    window.removeEventListener('pointerdown', this.onPointerFirst)
  }

  /* --------------------------- Muat / Simpan --------------------------- */

  punyaSimpanan(): boolean {
    try {
      return !!window.localStorage.getItem(KUNCI_SIMPAN)
    } catch {
      return false
    }
  }

  newGame(char: KarakterCfg) {
    this.char = char
    this.money = KONSTANTA.uangAwal
    this.xp = 0
    this.energy = energiMaks(1)
    this.dibuatPada = Date.now()
    this.lastRegenAt = Date.now()
    this.lastSeen = Date.now()
    this.inv = inventoriAwal()
    this.tool = 'cangkur'
    this.activeItem = null
    this.panyukan = false
    this.questIdx = 0
    this.stat = {}
    this.px = 10
    this.py = 7.5
    this.arah = 0
    this.plots.forEach((p, i) => {
      p.t = false
      p.c = undefined
      p.at = undefined
      p.buka = i < KONSTANTA.petakAwal
    })
    this.trees.forEach((t) => {
      t.hidup = true
      t.hp = 3
      t.respawn = 0
      this.markSolid(t.tx, t.ty, 1)
    })
    this.rocks.forEach((r) => {
      r.hidup = true
      r.hp = 3
      r.respawn = 0
      this.markSolid(r.tx, r.ty, 1)
    })
    this.ternak.forEach((s) => {
      s.jenis = null
      s.pakanAt = null
      s.siapAt = null
    })
    this.fish = null
    this.simpan()
    this.syncInv()
    useGameStore.getState().setScreen('game')
    this.toast('Selamat datang di Desa Miodakali! Tanam benih — tanamanmu tumbuh mengikuti waktu nyata.')
  }

  continueGame() {
    if (!this.muatData()) return this.newGame(this.char)
    this.syncInv()
    useGameStore.getState().setScreen('game')
    this.toast('Selamat kembali! Tanaman, ternak, dan tenagamu tetap berjalan selama kamu pergi.')
  }

  private muatData(): boolean {
    try {
      const raw = window.localStorage.getItem(KUNCI_SIMPAN)
      if (!raw) return false
      const s = JSON.parse(raw) as Simpanan
      if (s.v !== 2) return false
      this.dibuatPada = s.dibuatPada
      this.money = s.money
      this.xp = s.xp
      // pemulihan tenaga offline — berjalan mengikuti waktu nyata
      const maks = energiMaks(infoLevel(s.xp).level)
      const regenMs = KONSTANTA.regenTenagaDetik * 1000
      const pulih = Math.max(0, Math.floor((Date.now() - s.lastRegenAt) / regenMs))
      this.energy = Math.min(maks, (Number.isFinite(s.energy) ? s.energy : maks) + pulih)
      if (this.energy < maks) {
        this.lastRegenAt = s.lastRegenAt + pulih * regenMs
      } else {
        this.lastRegenAt = Date.now()
      }
      this.lastSeen = Date.now()
      this.inv = s.inv
      this.tool = s.tool
      this.activeItem = s.activeItem
      this.panyukan = s.panyukan
      this.questIdx = s.questIdx
      this.stat = s.stat
      this.char = s.char
      this.px = s.px
      this.py = s.py
      this.arah = s.arah
      s.plots.forEach((ps, i) => {
        const p = this.plots[i]
        if (!p) return
        p.t = ps.t
        p.c = ps.c
        p.at = ps.at
        p.buka = ps.buka ?? i < KONSTANTA.petakAwal
      })
      const kini = Date.now()
      s.trees.forEach((ts, i) => {
        const t = this.trees[i]
        if (!t) return
        t.hp = ts[2]
        t.hidup = ts[3] || ts[4] <= kini
        t.respawn = t.hidup ? 0 : ts[4]
        this.markSolid(t.tx, t.ty, t.hidup ? 1 : 0)
      })
      s.rocks.forEach((rs, i) => {
        const r = this.rocks[i]
        if (!r) return
        r.hp = rs[2]
        r.hidup = rs[3] || rs[4] <= kini
        r.respawn = r.hidup ? 0 : rs[4]
        this.markSolid(r.tx, r.ty, r.hidup ? 1 : 0)
      })
      s.ternak.forEach((ts, i) => {
        const slot = this.ternak[i]
        if (!slot) return
        slot.jenis = ts[0]
        slot.pakanAt = ts[1]
        slot.siapAt = ts[2]
      })
      this.fish = null
      return true
    } catch {
      return false
    }
  }

  private simpan() {
    try {
      const data: Simpanan = {
        v: 2,
        dibuatPada: this.dibuatPada,
        lastSeen: Date.now(),
        lastRegenAt: this.lastRegenAt,
        money: this.money,
        xp: this.xp,
        energy: this.energy,
        inv: this.inv,
        tool: this.tool,
        activeItem: this.activeItem,
        plots: this.plots.map((p) => ({ t: p.t, c: p.c, at: p.at, buka: p.buka })),
        trees: this.trees.map((t) => [t.tx, t.ty, t.hp, t.hidup, t.respawn]),
        rocks: this.rocks.map((r) => [r.tx, r.ty, r.hp, r.hidup, r.respawn]),
        ternak: this.ternak.map((s) => [s.jenis, s.pakanAt, s.siapAt]),
        panyukan: this.panyukan,
        questIdx: this.questIdx,
        stat: this.stat,
        char: this.char,
        px: this.px,
        py: this.py,
        arah: this.arah,
      }
      window.localStorage.setItem(KUNCI_SIMPAN, JSON.stringify(data))
    } catch {
      // penyimpanan lokal tidak tersedia — abaikan
    }
  }

  hapusSimpanan() {
    try {
      window.localStorage.removeItem(KUNCI_SIMPAN)
    } catch {
      // abaikan
    }
  }

  /* ------------------------------ API UI ------------------------------ */

  setTool(i: number) {
    const id = TOOLS_ORDER[i]
    if (!id) return
    if (id === 'panyukan' && !this.panyukan) {
      this.toast('Panyukan belum dimiliki — beli di Kios Desa.')
      return
    }
    this.tool = id
    useGameStore.getState().setTool(id)
  }

  setActiveItem(id: ItemId | null) {
    this.activeItem = id
    useGameStore.getState().setActiveItem(id)
  }

  setMove(x: number, y: number) {
    this.gerakVec.x = x
    this.gerakVec.y = y
  }

  getTool(): ToolId {
    return this.tool
  }

  getChar(): KarakterCfg {
    return this.char
  }

  /** Ganti penampilan karakter (lemari pakaian di Rumah) */
  ubahChar(cfg: KarakterCfg) {
    this.char = cfg
    this.simpan()
  }

  /** Level petani saat ini */
  levelPetani(): number {
    return this.level()
  }

  /** Hanya untuk pengujian: pindahkan pemain ke posisi tertentu */
  tp(tx: number, ty: number, arah?: Arah) {
    this.px = tx
    this.py = ty
    if (arah !== undefined) this.arah = arah
  }

  /** Uji percepatan: tanaman, ternak, pohon & batu langsung siap */
  percepat() {
    for (const p of this.plots) {
      if (p.c && p.at) p.at = Date.now() - CROPS_BY_ID[p.c].detikTumbuh * 1000 - 1
    }
    for (const t of this.trees) {
      if (!t.hidup) {
        t.hidup = true
        t.hp = 3
        t.respawn = 0
        this.markSolid(t.tx, t.ty, 1)
      }
    }
    for (const r of this.rocks) {
      if (!r.hidup) {
        r.hidup = true
        r.hp = 3
        r.respawn = 0
        this.markSolid(r.tx, r.ty, 1)
      }
    }
    for (const s of this.ternak) {
      if (s.jenis && s.siapAt) s.siapAt = Date.now() - 1
    }
    this.toast('Waktu dipercepat untuk pengujian.')
  }

  /** Info debug untuk pengujian */
  debug(): Record<string, unknown> {
    const st = useGameStore.getState()
    const lv = infoLevel(this.xp)
    return {
      px: this.px,
      py: this.py,
      keys: Array.from(this.keys),
      screen: st.screen,
      panel: st.panel,
      money: this.money,
      energy: Math.round(this.energy),
      level: lv.level,
      xp: this.xp,
      questIdx: this.questIdx,
      petakBuka: this.plots.filter((p) => p.buka).length,
      ternakIsi: this.ternak.filter((s) => s.jenis).length,
      inv: { ...this.inv },
      stat: { ...this.stat },
    }
  }

  getPanyukan(): boolean {
    return this.panyukan
  }

  beli(id: ItemId, qty: number): boolean {
    const def = ITEMS[id]
    if (!def?.hargaBeli) return false
    const butuhLv = def.levelButuh ?? 1
    if (this.level() < butuhLv) {
      this.toast(`${def.nama} terbuka di Level ${butuhLv} Petani!`)
      this.sfx.play('error')
      return false
    }
    const total = def.hargaBeli * qty
    if (this.money < total) {
      this.toast('Kirupi tidak cukup!')
      this.sfx.play('error')
      return false
    }
    this.money -= total
    if (id === 'panyukan') {
      this.panyukan = true
      useGameStore.getState().setPanyukan(true)
    } else {
      this.inv[id] = (this.inv[id] ?? 0) + qty
    }
    if (def.kategori === 'benih') {
      this.stat.beliBenih = (this.stat.beliBenih ?? 0) + qty
      this.cekQuest()
    }
    this.sfx.play('coin')
    this.toast(`Membeli ${def.nama} x${qty}`)
    this.syncInv()
    this.simpan()
    return true
  }

  jual(id: ItemId, qty: number): boolean {
    const def = ITEMS[id]
    if (!def || def.hargaJual <= 0) return false
    const milik = this.inv[id] ?? 0
    const n = Math.min(qty, milik)
    if (n <= 0) return false
    this.money += def.hargaJual * n
    this.inv[id] = milik - n
    if (this.inv[id] <= 0) delete this.inv[id]
    this.stat.jual = (this.stat.jual ?? 0) + n
    this.cekQuest()
    this.sfx.play('coin')
    this.toast(`Menjual ${def.nama} x${n} (+${def.hargaJual * n} Kirupi)`)
    this.syncInv()
    this.simpan()
    return true
  }

  bisaMasak(resepId: ItemId): boolean {
    const resep = RECIPES.find((r) => r.id === resepId)
    if (!resep) return false
    return resep.bahan.every(([id, n]) => (this.inv[id] ?? 0) >= n)
  }

  masak(resepId: ItemId): boolean {
    const resep = RECIPES.find((r) => r.id === resepId)
    if (!resep) return false
    if (this.level() < resep.levelButuh) {
      this.toast(`Resep terbuka di Level ${resep.levelButuh} Petani!`)
      this.sfx.play('error')
      return false
    }
    if (!this.bisaMasak(resepId)) {
      this.toast('Bahan belum lengkap!')
      this.sfx.play('error')
      return false
    }
    if (!this.useEnergy(BIAYA_TENAGA.masak)) return false
    for (const [id, n] of resep.bahan) {
      this.inv[id] = (this.inv[id] ?? 0) - n
      if (this.inv[id] <= 0) delete this.inv[id]
    }
    this.inv[resepId] = (this.inv[resepId] ?? 0) + 1
    this.stat.masak = (this.stat.masak ?? 0) + 1
    this.tambahXp(resep.xp)
    this.cekQuest()
    this.sfx.play('pop')
    this.toast(`Jadi ${ITEMS[resepId].nama}!`)
    this.syncInv()
    this.simpan()
    return true
  }

  makan(id: ItemId): boolean {
    const def = ITEMS[id]
    if (!def?.energi) return false
    if ((this.inv[id] ?? 0) <= 0) return false
    this.inv[id] -= 1
    if (this.inv[id] <= 0) delete this.inv[id]
    this.energy = Math.min(energiMaks(this.level()), this.energy + def.energi)
    this.stat.makan = (this.stat.makan ?? 0) + 1
    this.tambahXp(XP_AKSI.makan)
    this.cekQuest()
    this.sfx.play('eat')
    this.toast(`Makan ${def.nama} — Tenaga +${def.energi}`)
    this.syncInv()
    this.simpan()
    return true
  }

  private terapkanXp(n: number) {
    const sebelum = infoLevel(this.xp).level
    this.xp += Math.max(0, Math.round(n))
    const sesudah = infoLevel(this.xp).level
    if (sesudah > sebelum) {
      this.energy = Math.min(energiMaks(sesudah), this.energy + 20)
      this.sfx.play('coin')
      this.toast(`Naik ke Level ${sesudah} Petani! Benih & resep baru terbuka di Kios.`)
    }
  }

  private tambahXp(n: number) {
    this.terapkanXp(n)
    this.cekQuest()
  }

  /** Rantai tugas pembuka ala tutorial Sunflower Land */
  private cekQuest() {
    let jalan = true
    while (jalan && this.questIdx < QUESTS.length) {
      const q = QUESTS[this.questIdx]
      if (!this.cekSyaratQuest(q.id)) {
        jalan = false
        break
      }
      this.questIdx += 1
      if (q.hadiahUang > 0) this.money += q.hadiahUang
      if (q.hadiahXp > 0) this.terapkanXp(q.hadiahXp)
      this.sfx.play('coin')
      const bonus = [q.hadiahUang > 0 ? `+${q.hadiahUang} Kirupi` : '', q.hadiahXp > 0 ? `+${q.hadiahXp} XP` : '']
        .filter(Boolean)
        .join(' ')
      this.toast(`Tugas selesai: ${q.teks} (${bonus})`)
    }
  }

  private cekSyaratQuest(id: string): boolean {
    const s = this.stat
    switch (id) {
      case 'tanam': return (s.tanam ?? 0) >= 1
      case 'panen': return (s.panen ?? 0) >= 1
      case 'jual': return (s.jual ?? 0) >= 1
      case 'beli': return (s.beliBenih ?? 0) >= 3
      case 'tebas': return (s.tebas ?? 0) >= 1
      case 'tambang': return (s.tambang ?? 0) >= 1
      case 'ternak': return (s.pakanu ?? 0) >= 1
      case 'petak': return (s.petak ?? 0) >= 1
      case 'masak': return (s.masak ?? 0) >= 1
      case 'pancing': return (s.pancing ?? 0) >= 1
      case 'makan': return (s.makan ?? 0) >= 1
      case 'lv3': return this.level() >= 3
      default: return true
    }
  }

  /* --------------------------- Aksi Kontekstual --------------------------- */

  private toast(text: string) {
    useGameStore.getState().pushToast(text)
  }

  private useEnergy(cost: number): boolean {
    if (!Number.isFinite(this.energy)) this.energy = 0
    if (this.energy < cost) {
      this.toast('Tenaga habis! Makan masakan atau tunggu pulih beberapa saat.')
      this.sfx.play('error')
      return false
    }
    this.energy -= cost
    return true
  }

  private arahOffset(): [number, number] {
    switch (this.arah) {
      case 0:
        return [0, 1]
      case 1:
        return [0, -1]
      case 2:
        return [-1, 0]
      default:
        return [1, 0]
    }
  }

  private tileDepan(): [number, number] {
    const [ox, oy] = this.arahOffset()
    return [Math.floor(this.px + ox * 0.85), Math.floor(this.py + oy * 0.85)]
  }

  private ternakSlotTerdekat(): TernakSlot | null {
    let best: TernakSlot | null = null
    let bd = 1.9
    for (const s of this.ternak) {
      const d = Math.hypot(s.tx + 0.5 - this.px, s.ty + 0.5 - this.py)
      if (d < bd) {
        bd = d
        best = s
      }
    }
    return best
  }

  private interTerdekat(): InteractPoint | null {
    let best: InteractPoint | null = null
    let bd = 1.8
    for (const ip of this.interPoints) {
      const d = Math.hypot(ip.tx - this.px, ip.ty - this.py)
      if (d < bd) {
        bd = d
        best = ip
      }
    }
    return best
  }

  /** Label konteks untuk tombol aksi */
  private konteks(): { label: string; jenis: string; ref?: string } {
    const ip = this.interTerdekat()
    if (ip) {
      switch (ip.jenis) {
        case 'rumah':
          return { label: 'Lemari Pakaian', jenis: 'wardrobe' }
        case 'dapur':
          return { label: 'Masak', jenis: 'dapur' }
        case 'kios':
          return { label: 'Kios Desa', jenis: 'kios' }
        case 'npc':
          return { label: 'Bicara Pak Dalu', jenis: 'kios' }
        case 'sign':
          return { label: 'Baca Papan', jenis: 'sign' }
        case 'kandang':
          return { label: 'Kandang Ternak', jenis: 'info' }
        case 'pondok':
          return { label: 'Pondok Nelayan', jenis: 'info' }
      }
    }
    if (this.fish) return { label: 'Jaring!', jenis: 'fish' }
    const slot = this.ternakSlotTerdekat()
    if (slot) {
      const kini = Date.now()
      if (!slot.jenis) {
        return { label: 'Beli Ternak', jenis: 'beliTernak' }
      }
      const def = TERNAK[slot.jenis]
      if (slot.siapAt && kini >= slot.siapAt) {
        return { label: `Ambil ${ITEMS[def.hasil].nama}`, jenis: 'ambil' }
      }
      if (slot.siapAt) {
        return { label: `${def.nama} — ${formatWaktu((slot.siapAt - kini) / 1000)}`, jenis: 'none' }
      }
      return { label: `Beri Pakanu (${def.nama})`, jenis: 'pakanu' }
    }
    const [tx, ty] = this.tileDepan()
    const p = this.plotDi(tx, ty)
    if (p) {
      if (!p.buka) {
        const biaya = biayaPetak(this.petakDibeli())
        return { label: `Beli Petak (${biaya.uang} K)`, jenis: 'beliPetak' }
      }
      if (p.c) {
        const def = CROPS_BY_ID[p.c]
        const rasio = this.rasioTumbuh(p)
        if (rasio >= 1) return { label: `Panen ${def.nama}`, jenis: 'panen', ref: p.c }
        const sisa = (1 - rasio) * def.detikTumbuh
        return { label: `${def.nama} matang dalam ${formatWaktu(sisa)}`, jenis: 'none' }
      }
      if (p.t) {
        if (this.activeItem && CROPS.some((c) => c.benih === this.activeItem)) {
          return { label: `Tanam ${ITEMS[this.activeItem].nama.replace('Benih ', '')}`, jenis: 'tanam', ref: this.activeItem }
        }
        return { label: 'Pilih benih di Tas', jenis: 'none' }
      }
      if (this.tool === 'cangkur') return { label: 'Gembur Tanah', jenis: 'gembur' }
      return { label: 'Tanah belum digembur', jenis: 'none' }
    }
    if (diDalam(tx, ty, POND.x0, POND.y0, POND.x1, POND.y1)) {
      if (this.tool === 'panyukan') return { label: 'Pancing', jenis: 'pancing' }
      return { label: 'Kolam — butuh Panyukan', jenis: 'none' }
    }
    const t = this.trees.find((tr) => tr.tx === tx && tr.ty === ty && tr.hidup)
    if (t) {
      if (this.tool === 'kapura') return { label: 'Tebang Kayanu', jenis: 'tebang' }
      return { label: 'Butuh Kapura', jenis: 'none' }
    }
    const r = this.rocks.find((rk) => rk.tx === tx && rk.ty === ty && rk.hidup)
    if (r) {
      if (this.tool === 'giliuk') return { label: 'Pecah Batuku', jenis: 'pecah' }
      return { label: 'Butuh Giliuk', jenis: 'none' }
    }
    return { label: '', jenis: 'none' }
  }

  pressAction() {
    if (useGameStore.getState().screen !== 'game') return
    if (useGameStore.getState().panel) return
    this.sfx.init()
    const k = this.konteks()
    switch (k.jenis) {
      case 'wardrobe':
        useGameStore.getState().setPanel('wardrobe')
        return
      case 'dapur':
        useGameStore.getState().setPanel('cook')
        return
      case 'kios':
        useGameStore.getState().setPanel('shop')
        return
      case 'sign':
        this.toast('Desa Miodakali: tanam benih, tunggu matang mengikuti waktu nyata, panen, lalu jual di Kios. Naik level untuk membuka benih & ternak baru!')
        return
      case 'info':
        this.toast('Pondok Nelayan — beli Panyukan di Kios Desa, lalu pancing di Kolam.')
        return
      case 'fish':
        this.resolusiPancing()
        return
      case 'beliTernak': {
        const slot = this.ternakSlotTerdekat()
        if (!slot || slot.jenis) return
        const jenis: TernakJenis = slot.tx >= 6 ? 'sapiyu' : 'ayumi'
        const def = TERNAK[jenis]
        if (this.level() < def.levelButuh) {
          this.toast(`${def.nama} terbuka di Level ${def.levelButuh} Petani!`)
          this.sfx.play('error')
          return
        }
        if (this.money < def.harga) {
          this.toast(`Kirupi tidak cukup — ${def.nama} ${def.harga} Kirupi.`)
          this.sfx.play('error')
          return
        }
        this.money -= def.harga
        slot.jenis = jenis
        slot.pakanAt = null
        slot.siapAt = null
        this.sfx.play('coin')
        this.toast(`${def.nama} masuk kandang! Beri Pakanu untuk mulai produksi.`)
        this.simpan()
        return
      }
      case 'pakanu': {
        const slot = this.ternakSlotTerdekat()
        if (!slot || !slot.jenis || slot.siapAt) return
        if ((this.inv.pakanu ?? 0) <= 0) {
          this.toast('Pakanu habis — beli di Kios Desa.')
          this.sfx.play('error')
          return
        }
        if (!this.useEnergy(BIAYA_TENAGA.pakanu)) return
        this.inv.pakanu -= 1
        if (this.inv.pakanu <= 0) delete this.inv.pakanu
        const defPakan = TERNAK[slot.jenis]
        slot.pakanAt = Date.now()
        slot.siapAt = Date.now() + defPakan.detikProduksi * 1000
        this.stat.pakanu = (this.stat.pakanu ?? 0) + 1
        this.tambahXp(XP_AKSI.pakanu)
        this.cekQuest()
        this.sfx.play('eat')
        this.toast(`${defPakan.nama} makan Pakanu — hasil siap ${formatWaktu(defPakan.detikProduksi)}.`)
        this.syncInv()
        this.simpan()
        return
      }
      case 'ambil': {
        const slot = this.ternakSlotTerdekat()
        if (!slot || !slot.jenis || !slot.siapAt || Date.now() < slot.siapAt) return
        if (!this.useEnergy(BIAYA_TENAGA.ambil)) return
        const hasil = TERNAK[slot.jenis].hasil
        slot.pakanAt = null
        slot.siapAt = null
        this.inv[hasil] = (this.inv[hasil] ?? 0) + 1
        this.tambahXp(XP_AKSI.ambil)
        this.cekQuest()
        this.sfx.play('pop')
        this.toast(`Mendapat ${ITEMS[hasil].nama}!`)
        this.syncInv()
        this.simpan()
        return
      }
      case 'beliPetak': {
        const biaya = biayaPetak(this.petakDibeli())
        if (this.money < biaya.uang || (this.inv.balanu ?? 0) < biaya.balanu || (this.inv.batuku ?? 0) < biaya.batuku) {
          this.toast(`Butuh ${biaya.uang} Kirupi + ${biaya.balanu} Balanu + ${biaya.batuku} Batuku.`)
          this.sfx.play('error')
          return
        }
        const p = this.plots.find((q) => !q.buka)
        if (!p) return
        this.money -= biaya.uang
        this.inv.balanu = (this.inv.balanu ?? 0) - biaya.balanu
        if (this.inv.balanu <= 0) delete this.inv.balanu
        this.inv.batuku = (this.inv.batuku ?? 0) - biaya.batuku
        if (this.inv.batuku <= 0) delete this.inv.batuku
        p.buka = true
        this.stat.petak = (this.stat.petak ?? 0) + 1
        this.tambahXp(XP_AKSI.beliPetak)
        this.cekQuest()
        this.sfx.play('coin')
        this.toast('Petak baru terbuka! Kebunmu makin luas.')
        this.simpan()
        return
      }
      case 'gembur': {
        const [tx, ty] = this.tileDepan()
        const p = this.plotDi(tx, ty)
        if (!p || !p.buka || p.t || p.c) return
        if (!this.useEnergy(BIAYA_TENAGA.gembur)) return
        p.t = true
        this.tambahXp(XP_AKSI.gembur)
        this.aksiMulai('cangkur')
        this.sfx.play('pop')
        this.partikelTanah(tx, ty)
        return
      }
      case 'tanam': {
        const benih = k.ref!
        const [tx, ty] = this.tileDepan()
        const p = this.plotDi(tx, ty)
        if (!p || !p.buka || !p.t || p.c) return
        if ((this.inv[benih] ?? 0) <= 0) return
        if (!this.useEnergy(BIAYA_TENAGA.tanam)) return
        const def = CROPS.find((c) => c.benih === benih)
        if (!def) return
        this.inv[benih] -= 1
        if (this.inv[benih] <= 0) delete this.inv[benih]
        p.c = def.hasil
        p.at = Date.now()
        this.stat.tanam = (this.stat.tanam ?? 0) + 1
        this.tambahXp(XP_AKSI.tanam)
        this.cekQuest()
        this.aksiMulai('cangkur')
        this.sfx.play('pop')
        this.syncInv()
        this.simpan()
        return
      }
      case 'panen': {
        const [tx, ty] = this.tileDepan()
        const p = this.plotDi(tx, ty)
        if (!p || !p.c || this.rasioTumbuh(p) < 1) return
        if (!this.useEnergy(BIAYA_TENAGA.panen)) return
        const hasil = p.c
        const n = 1 + (Math.random() < 0.35 ? 1 : 0)
        this.inv[hasil] = (this.inv[hasil] ?? 0) + n
        p.c = undefined
        p.at = undefined
        this.stat.panen = (this.stat.panen ?? 0) + 1
        this.tambahXp(CROPS_BY_ID[hasil].xpPanen * n)
        this.cekQuest()
        this.aksiMulai('cangkur')
        this.sfx.play('coin')
        this.toast(`Panen ${ITEMS[hasil].nama} x${n}!`)
        this.syncInv()
        this.simpan()
        return
      }
      case 'pancing': {
        if (!this.useEnergy(BIAYA_TENAGA.pancing)) return
        this.fish = { t: 0, ok: 0, miss: 0, fx: 0.5, zx: 0.3, zw: 0.24, over: 0, sukses: false }
        this.sfx.play('splash')
        return
      }
      case 'tebang': {
        const [tx, ty] = this.tileDepan()
        const t = this.trees.find((tr) => tr.tx === tx && tr.ty === ty && tr.hidup)
        if (!t) return
        if (!this.useEnergy(BIAYA_TENAGA.tebang)) return
        t.hp -= 1
        t.shake = 0.4
        this.tambahXp(XP_AKSI.tebang)
        this.aksiMulai('kapura')
        this.sfx.play('chop')
        if (t.hp <= 0) {
          t.hidup = false
          t.respawn = Date.now() + KONSTANTA.respawnDetik * 1000
          this.markSolid(t.tx, t.ty, 0)
          this.inv.balanu = (this.inv.balanu ?? 0) + 2
          this.stat.tebas = (this.stat.tebas ?? 0) + 1
          let bonus = ' +2 Balanu'
          if (Math.random() < 0.35) {
            this.inv.benih_lumira = (this.inv.benih_lumira ?? 0) + 1
            bonus += ' +1 Benih Lumira'
          }
          this.cekQuest()
          this.toast(`Kayanu tumbang —${bonus}`)
          this.syncInv()
          this.simpan()
        }
        return
      }
      case 'pecah': {
        const [tx, ty] = this.tileDepan()
        const r = this.rocks.find((rk) => rk.tx === tx && rk.ty === ty && rk.hidup)
        if (!r) return
        if (!this.useEnergy(BIAYA_TENAGA.pecah)) return
        r.hp -= 1
        r.shake = 0.4
        this.tambahXp(XP_AKSI.pecah)
        this.aksiMulai('giliuk')
        this.sfx.play('chop')
        if (r.hp <= 0) {
          r.hidup = false
          r.respawn = Date.now() + KONSTANTA.respawnDetik * 1000
          this.markSolid(r.tx, r.ty, 0)
          this.inv.batuku = (this.inv.batuku ?? 0) + 2
          this.stat.tambang = (this.stat.tambang ?? 0) + 1
          this.cekQuest()
          this.toast('Batuku pecah — +2 Batuku')
          this.syncInv()
          this.simpan()
        }
        return
      }
      default:
        return
    }
  }

  private aksiMulai(tool: ToolId) {
    this.aksiAnim = 0.36
    this.aksiTool = tool
  }

  private partikelTanah(tx: number, ty: number) {
    for (let i = 0; i < 6; i++) {
      this.partikel.push({
        x: (tx + 0.5) * TS + (Math.random() - 0.5) * 20,
        y: (ty + 0.7) * TS,
        vx: (Math.random() - 0.5) * 40,
        vy: -Math.random() * 60,
        life: 0.4,
        warna: '#8a5a33',
      })
    }
  }

  private resolusiPancing() {
    if (!this.fish || this.fish.over > 0) return
    const f = this.fish
    const tengah = f.zx + f.zw / 2
    if (Math.abs(f.fx - tengah) < f.zw / 2) {
      f.ok += 1
      this.sfx.play('pop')
      f.zx = 0.08 + Math.random() * (0.92 - f.zw - 0.16)
      f.zw = Math.max(0.13, f.zw - 0.025)
      if (f.ok >= 3) {
        const r = Math.random()
        let akum = 0
        let dapat = FISH_TABLE[0].id
        for (const ik of FISH_TABLE) {
          akum += ik.peluang
          if (r <= akum) {
            dapat = ik.id
            break
          }
        }
        this.inv[dapat] = (this.inv[dapat] ?? 0) + 1
        this.stat.pancing = (this.stat.pancing ?? 0) + 1
        this.tambahXp(XP_AKSI.pancing)
        this.cekQuest()
        this.sfx.play('splash')
        this.toast(`Tertangkap ${ITEMS[dapat].nama}!`)
        f.sukses = true
        f.over = 1.1
        this.syncInv()
        this.simpan()
      }
    } else {
      f.miss += 1
      this.sfx.play('error')
      if (f.miss >= 3) {
        f.sukses = false
        f.over = 1.1
        this.toast('Ikannya kabur… coba lagi!')
      }
    }
  }

  /* ------------------------------- Update ------------------------------- */

  private syncInv() {
    const entri: Array<[ItemId, number]> = []
    for (const t of TOOLS_ORDER) {
      if (t === 'panyukan') {
        if (this.panyukan) entri.push([t, 1])
      } else if (this.inv[t]) entri.push([t, this.inv[t]])
    }
    const urutan: Record<string, number> = { benih: 0, hasil: 1, material: 2, ikan: 3, masakan: 4 }
    const lain = Object.entries(this.inv)
      .filter(([id, n]) => n > 0 && !TOOLS_ORDER.includes(id as ToolId))
      .sort((a, b) => {
        const ka = urutan[ITEMS[a[0]]?.kategori ?? 'material'] ?? 9
        const kb = urutan[ITEMS[b[0]]?.kategori ?? 'material'] ?? 9
        return ka - kb || a[0].localeCompare(b[0])
      })
    entri.push(...lain)
    const st = useGameStore.getState()
    st.setInv(entri)
    st.setPanyukan(this.panyukan)
    if (this.activeItem && !(this.inv[this.activeItem] > 0)) {
      this.setActiveItem(null)
    }
  }

  private update(dt: number) {
    const st = useGameStore.getState()
    const paused = st.screen !== 'game' || st.panel !== null
    this.waktu += dt

    // pemulihan tenaga berjalan waktu-nyata (termasuk saat panel terbuka)
    const regenMs = KONSTANTA.regenTenagaDetik * 1000
    const maksE = energiMaks(this.level())
    if (this.energy < maksE && Date.now() - this.lastRegenAt >= regenMs) {
      const pulih = Math.floor((Date.now() - this.lastRegenAt) / regenMs)
      this.energy = Math.min(maksE, this.energy + pulih)
      this.lastRegenAt += pulih * regenMs
    }
    if (this.energy >= maksE) this.lastRegenAt = Date.now()

    if (paused) {
      this.hudSync(dt, false)
      return
    }

    // gerakan pemain
    let mx = this.gerakVec.x
    let my = this.gerakVec.y
    if (this.keys.has('ArrowUp') || this.keys.has('w') || this.keys.has('W')) my -= 1
    if (this.keys.has('ArrowDown') || this.keys.has('s') || this.keys.has('S')) my += 1
    if (this.keys.has('ArrowLeft') || this.keys.has('a') || this.keys.has('A')) mx -= 1
    if (this.keys.has('ArrowRight') || this.keys.has('d') || this.keys.has('D')) mx += 1
    if (this.fish) {
      mx = 0
      my = 0
    }
    const len = Math.hypot(mx, my)
    if (len > 0.01) {
      mx /= Math.max(1, len)
      my /= Math.max(1, len)
      const kecepatan = 3.4
      const nx = this.px + mx * kecepatan * dt
      const ny = this.py + my * kecepatan * dt
      // cek tabrakan per sumbu
      if (!this.tabrakan(nx, this.py)) this.px = nx
      if (!this.tabrakan(this.px, ny)) this.py = ny
      this.px = Math.min(MAP_W - 0.45, Math.max(0.45, this.px))
      this.py = Math.min(MAP_H - 0.45, Math.max(0.45, this.py))
      this.arah = Math.abs(mx) > Math.abs(my) ? (mx > 0 ? 3 : 2) : my > 0 ? 0 : 1
      this.langkah += dt * 9
      this.berjalan = true
    } else {
      this.berjalan = false
    }

    if (this.aksiAnim > 0) this.aksiAnim -= dt

    // goyang pohon/batu
    for (const t of this.trees) if (t.shake > 0) t.shake -= dt
    for (const r of this.rocks) if (r.shake > 0) r.shake -= dt

    // pohon & batu tumbuh kembali mengikuti waktu nyata
    const kini = Date.now()
    for (const t of this.trees) {
      if (!t.hidup && t.respawn > 0 && kini >= t.respawn) {
        t.hidup = true
        t.hp = 3
        t.respawn = 0
        this.markSolid(t.tx, t.ty, 1)
      }
    }
    for (const r of this.rocks) {
      if (!r.hidup && r.respawn > 0 && kini >= r.respawn) {
        r.hidup = true
        r.hp = 3
        r.respawn = 0
        this.markSolid(r.tx, r.ty, 1)
      }
    }

    // partikel
    this.partikel = this.partikel.filter((p) => {
      p.life -= dt
      p.x += p.vx * dt
      p.y += p.vy * dt
      p.vy += 160 * dt
      return p.life > 0
    })

    // minigame pancing
    if (this.fish) {
      const f = this.fish
      if (f.over > 0) {
        f.over -= dt
        if (f.over <= 0) this.fish = null
      } else {
        f.t += dt
        f.fx = 0.5 + Math.sin(f.t * 2.7) * 0.4 + Math.sin(f.t * 5.9) * 0.06
        f.fx = Math.min(0.97, Math.max(0.03, f.fx))
      }
    }

    // simpan otomatis
    this.simpanTimer += dt
    if (this.simpanTimer > 10) {
      this.simpanTimer = 0
      this.simpan()
    }

    this.hudSync(dt, false)
  }

  private hudSync(dt: number, hanyaLabel: boolean) {
    this.hudTimer += dt
    const k = this.konteks()
    const st = useGameStore.getState()
    if (k.label !== this.labelTerakhir) {
      this.labelTerakhir = k.label
      st.setHud({ label: k.label })
    }
    if (hanyaLabel) return
    if (this.hudTimer < 0.25) return
    this.hudTimer = 0
    const kini = new Date()
    const hh = kini.getHours()
    const mm = kini.getMinutes()
    const jamStr = `${String(hh).padStart(2, '0')}:${String(mm).padStart(2, '0')}`
    const h = hh + mm / 60
    let fase: 'Pagi' | 'Siang' | 'Sore' | 'Malam' = 'Malam'
    if (h >= 5 && h < 10) fase = 'Pagi'
    else if (h >= 10 && h < 15) fase = 'Siang'
    else if (h >= 15 && h < 18) fase = 'Sore'
    const lv = infoLevel(this.xp)
    st.setHud({
      day: this.hariKe(),
      jam: jamStr,
      fase,
      energy: Math.round(this.energy),
      energyMaks: energiMaks(lv.level),
      money: this.money,
      level: lv.level,
      xp: lv.xpSaatIni,
      xpButuh: lv.xpButuh,
      quest: QUESTS[this.questIdx]?.teks ?? 'Semua tugas awal selesai — kembangkan desamu!',
      questIdx: this.questIdx,
    })
  }

  private tabrakan(x: number, y: number): boolean {
    const r = 0.32
    const x0 = Math.floor(x - r)
    const x1 = Math.floor(x + r)
    const y0 = Math.floor(y - r)
    const y1 = Math.floor(y + r)
    for (let tx = x0; tx <= x1; tx++) {
      for (let ty = y0; ty <= y1; ty++) {
        if (this.isSolid(tx, ty)) return true
      }
    }
    return false
  }

  /* -------------------------------- Render -------------------------------- */

  private draw() {
    const ctx = this.ctx
    const W = this.canvas.width
    const H = this.canvas.height
    const dpr = Math.min(2, window.devicePixelRatio || 1)
    const cw = W / dpr
    const ch = H / dpr
    const zoom = Math.min(1.9, Math.max(0.85, Math.min(cw / (TS * 13), ch / (TS * 9.5))))

    ctx.save()
    ctx.scale(dpr, dpr)
    ctx.clearRect(0, 0, cw, ch)
    ctx.fillStyle = '#5e8c3e'
    ctx.fillRect(0, 0, cw, ch)

    // kamera
    let camX = this.px * TS - cw / (2 * zoom)
    let camY = this.py * TS - ch / (2 * zoom)
    camX = Math.min(MAP_W * TS - cw / zoom, Math.max(0, camX))
    camY = Math.min(MAP_H * TS - ch / zoom, Math.max(0, camY))
    if (MAP_W * TS < cw / zoom) camX = (MAP_W * TS - cw / zoom) / 2
    if (MAP_H * TS < ch / zoom) camY = (MAP_H * TS - ch / zoom) / 2

    ctx.save()
    ctx.scale(zoom, zoom)
    ctx.translate(-camX, -camY)

    const tx0 = Math.max(0, Math.floor(camX / TS) - 1)
    const ty0 = Math.max(0, Math.floor(camY / TS) - 1)
    const tx1 = Math.min(MAP_W - 1, Math.ceil((camX + cw / zoom) / TS) + 1)
    const ty1 = Math.min(MAP_H - 1, Math.ceil((camY + ch / zoom) / TS) + 1)

    this.gambarTanah(tx0, ty0, tx1, ty1)
    this.gambarPetak()
    this.gambarPagar(tx0, ty0, tx1, ty1)
    this.gambarEntitas()

    // partikel
    for (const p of this.partikel) {
      ctx.fillStyle = p.warna
      ctx.globalAlpha = Math.min(1, p.life * 2.5)
      ctx.beginPath()
      ctx.arc(p.x, p.y, 2.6, 0, Math.PI * 2)
      ctx.fill()
    }
    ctx.globalAlpha = 1

    ctx.restore()

    // label aksi di atas target
    const k = this.konteks()
    if (k.label && k.jenis !== 'fish' && useGameStore.getState().screen === 'game' && !useGameStore.getState().panel) {
      const [ox, oy] = this.arahOffset()
      const sx = (this.px + ox * 0.85 + 0.5) * TS * zoom - camX * zoom
      const sy = (this.py + oy * 0.85) * TS * zoom - camY * zoom - 26
      ctx.save()
      ctx.font = 'bold 12px sans-serif'
      const tw = ctx.measureText(k.label).width + 18
      ctx.fillStyle = 'rgba(50,38,20,0.82)'
      this.roundRect(ctx, sx - tw / 2, sy - 16, tw, 24, 12)
      ctx.fillStyle = '#ffe9b8'
      ctx.textAlign = 'center'
      ctx.fillText(k.label, sx, sy)
      ctx.restore()
    }

    // malam
    this.gambarMalam(cw, ch)

    // minigame memancing
    if (this.fish) this.gambarPancing(cw, ch)

    // vignette lembut
    const vg = ctx.createRadialGradient(cw / 2, ch / 2, Math.min(cw, ch) * 0.45, cw / 2, ch / 2, Math.max(cw, ch) * 0.75)
    vg.addColorStop(0, 'rgba(0,0,0,0)')
    vg.addColorStop(1, 'rgba(30,20,8,0.25)')
    ctx.fillStyle = vg
    ctx.fillRect(0, 0, cw, ch)

    ctx.restore()
  }

  private roundRect(ctx: CanvasRenderingContext2D, x: number, y: number, w: number, h: number, r: number) {
    ctx.beginPath()
    ctx.moveTo(x + r, y)
    ctx.arcTo(x + w, y, x + w, y + h, r)
    ctx.arcTo(x + w, y + h, x, y + h, r)
    ctx.arcTo(x, y + h, x, y, r)
    ctx.arcTo(x, y, x + w, y, r)
    ctx.closePath()
    ctx.fill()
  }

  private gambarTanah(tx0: number, ty0: number, tx1: number, ty1: number) {
    const ctx = this.ctx
    const palet = ['#8fbf5a', '#88b554', '#93c462', '#84b050']
    for (let x = tx0; x <= tx1; x++) {
      for (let y = ty0; y <= ty1; y++) {
        const hsh = hashTile(x, y)
        ctx.fillStyle = palet[Math.floor(hsh * palet.length)]
        ctx.fillRect(x * TS, y * TS, TS + 1, TS + 1)
        // rumput kecil
        if (hsh > 0.55) {
          ctx.fillStyle = 'rgba(60,120,40,0.5)'
          const gx = x * TS + 10 + hsh * 26
          const gy = y * TS + 12 + hashTile(y, x) * 26
          ctx.fillRect(gx, gy, 2.4, 5)
          ctx.fillRect(gx + 4, gy + 2, 2, 4)
        }
        // bunga langka
        if (hsh > 0.955) {
          const fx = x * TS + 24
          const fy = y * TS + 22
          ctx.fillStyle = ['#f2e3c2', '#e8a8b8', '#f0d060'][Math.floor(hsh * 30) % 3]
          ctx.beginPath()
          ctx.arc(fx, fy, 3, 0, Math.PI * 2)
          ctx.fill()
          ctx.fillStyle = '#e8b840'
          ctx.beginPath()
          ctx.arc(fx, fy, 1.3, 0, Math.PI * 2)
          ctx.fill()
        }
        // jalur tanah
        if (JALUR.some(([jx, jy]) => jx === x && jy === y)) {
          ctx.fillStyle = '#d8c08a'
          ctx.fillRect(x * TS, y * TS, TS + 1, TS + 1)
          ctx.fillStyle = 'rgba(150,120,70,0.35)'
          for (let i = 0; i < 3; i++) {
            const hx = hashTile(x * 3 + i, y)
            const hy = hashTile(x, y * 3 + i)
            ctx.beginPath()
            ctx.ellipse(x * TS + 8 + hx * 32, y * TS + 8 + hy * 32, 3.2, 2.2, 0, 0, Math.PI * 2)
            ctx.fill()
          }
        }
      }
    }
    // kolam
    ctx.save()
    ctx.beginPath()
    this.roundRect(ctx, POND.x0 * TS + 4, POND.y0 * TS + 4, (POND.x1 - POND.x0 + 1) * TS - 8, (POND.y1 - POND.y0 + 1) * TS - 8, 26)
    ctx.clip()
    const gr = ctx.createLinearGradient(0, POND.y0 * TS, 0, (POND.y1 + 1) * TS)
    gr.addColorStop(0, '#6fb4d0')
    gr.addColorStop(1, '#4a8cab')
    ctx.fillStyle = gr
    ctx.fillRect(POND.x0 * TS, POND.y0 * TS, (POND.x1 - POND.x0 + 1) * TS, (POND.y1 - POND.y0 + 1) * TS)
    // riak
    ctx.strokeStyle = 'rgba(255,255,255,0.5)'
    ctx.lineWidth = 2
    for (let i = 0; i < 4; i++) {
      const wy = POND.y0 * TS + 30 + i * 34 + Math.sin(this.waktu * 1.4 + i * 1.7) * 5
      const wx = POND.x0 * TS + 20 + Math.sin(this.waktu * 0.9 + i) * 14
      ctx.beginPath()
      ctx.moveTo(wx, wy)
      ctx.quadraticCurveTo(wx + 26, wy - 6, wx + 52, wy)
      ctx.quadraticCurveTo(wx + 78, wy + 6, wx + 104, wy)
      ctx.stroke()
    }
    // teratai
    ctx.fillStyle = '#5aa85a'
    ctx.beginPath()
    ctx.ellipse((POND.x0 + 1.2) * TS, (POND.y1 - 0.6) * TS, 13, 9, 0, 0, Math.PI * 2)
    ctx.fill()
    ctx.beginPath()
    ctx.ellipse((POND.x1 - 0.5) * TS, (POND.y0 + 1.1) * TS, 11, 8, 0, 0, Math.PI * 2)
    ctx.fill()
    ctx.fillStyle = '#e8e2c8'
    ctx.beginPath()
    ctx.ellipse((POND.x0 + 1.2) * TS + 4, (POND.y1 - 0.6) * TS - 3, 3, 2.4, 0, 0, Math.PI * 2)
    ctx.fill()
    ctx.restore()
    // bibir kolam
    ctx.strokeStyle = 'rgba(240,230,190,0.8)'
    ctx.lineWidth = 4
    this.roundRectStroke(POND.x0 * TS + 4, POND.y0 * TS + 4, (POND.x1 - POND.x0 + 1) * TS - 8, (POND.y1 - POND.y0 + 1) * TS - 8, 26)
  }

  private roundRectStroke(x: number, y: number, w: number, h: number, r: number) {
    const ctx = this.ctx
    ctx.beginPath()
    ctx.moveTo(x + r, y)
    ctx.arcTo(x + w, y, x + w, y + h, r)
    ctx.arcTo(x + w, y + h, x, y + h, r)
    ctx.arcTo(x, y + h, x, y, r)
    ctx.arcTo(x, y, x + w, y, r)
    ctx.closePath()
    ctx.stroke()
  }

  private gambarPetak() {
    const ctx = this.ctx
    const biaya = biayaPetak(this.petakDibeli())
    const idxTandaBeli = this.plots.findIndex((p) => !p.buka)
    for (let i = 0; i < this.plots.length; i++) {
      const p = this.plots[i]
      const x = p.tx * TS
      const y = p.ty * TS
      if (!p.buka) {
        // petak terkunci — tanda ekspansi lahan ala Sunflower Land
        const dapatDibeli = i === idxTandaBeli
        ctx.save()
        ctx.globalAlpha = dapatDibeli ? 0.9 : 0.35
        ctx.setLineDash([6, 5])
        ctx.strokeStyle = dapatDibeli ? '#ffe9b8' : 'rgba(90,60,30,0.6)'
        ctx.lineWidth = 2
        ctx.strokeRect(x + 6, y + 6, TS - 12, TS - 12)
        ctx.setLineDash([])
        if (dapatDibeli) {
          ctx.fillStyle = '#e8d8a8'
          this.roundRect(ctx, x + 6, y + 12, TS - 12, 18, 4)
          ctx.strokeStyle = '#8a5a33'
          ctx.lineWidth = 1.6
          ctx.strokeRect(x + 6, y + 12, TS - 12, 18)
          ctx.fillStyle = '#5a3a1a'
          ctx.font = 'bold 9px sans-serif'
          ctx.textAlign = 'center'
          ctx.fillText(`JUAL ${biaya.uang}K`, x + TS / 2, y + 24.5)
        }
        ctx.restore()
        continue
      }
      if (p.t) {
        ctx.fillStyle = '#a3714b'
        this.roundRect(ctx, x + 3, y + 3, TS - 6, TS - 6, 8)
        ctx.strokeStyle = '#8a5a33'
        ctx.lineWidth = 2.2
        for (let i2 = 0; i2 < 2; i2++) {
          const fy = y + 14 + i2 * 15
          ctx.beginPath()
          ctx.moveTo(x + 8, fy)
          ctx.lineTo(x + TS - 8, fy)
          ctx.stroke()
        }
      }
      if (p.c) {
        const def = CROPS_BY_ID[p.c]
        const rasio = this.rasioTumbuh(p)
        drawCropPlant(ctx, x + TS / 2, y + TS / 2 + 8, def, this.stageOf(p), this.waktu)
        // bilah kemajuan waktu-nyata / tanda siap panen
        if (rasio < 1) {
          const bw = TS - 14
          const bx = x + 7
          const by = y - 4
          ctx.fillStyle = 'rgba(50,38,20,0.55)'
          this.roundRect(ctx, bx, by, bw, 6, 3)
          ctx.fillStyle = '#8fdc7a'
          this.roundRect(ctx, bx + 1, by + 1, Math.max(2, (bw - 2) * Math.min(1, rasio)), 4, 2)
        } else {
          const bob = Math.sin(this.waktu * 3) * 2.4
          ctx.fillStyle = '#ffe9b8'
          ctx.beginPath()
          ctx.arc(x + TS / 2, y - 6 + bob, 7.5, 0, Math.PI * 2)
          ctx.fill()
          ctx.fillStyle = '#c98a2f'
          ctx.font = 'bold 10px sans-serif'
          ctx.textAlign = 'center'
          ctx.fillText('!', x + TS / 2, y - 2.4 + bob)
        }
      }
    }
  }

  private gambarPagar(tx0: number, ty0: number, tx1: number, ty1: number) {
    const ctx = this.ctx
    const cekPagar = (x: number, y: number) => {
      if (!diDalam(x, y, FARM.x0 - 1, FARM.y0 - 1, FARM.x1 + 1, FARM.y1 + 1)) {
        const kandangRing = diDalam(x, y, 2, 24, 7, 26) && (x === 2 || x === 7 || y === 24 || y === 26)
        const pondokRing = diDalam(x, y, 24, 24, 29, 26) && (x === 24 || x === 29 || y === 24 || y === 26)
        if (!kandangRing && !pondokRing) return false
      }
      return this.isSolid(x, y)
    }
    const gates = [GATE.atas1, GATE.atas2, GATE.kiri1, GATE.kiri2, GATE.kandang, GATE.pondok]
    const isGate = (x: number, y: number) => gates.some((g) => g.x === x && g.y === y)
    for (let x = tx0; x <= tx1; x++) {
      for (let y = ty0; y <= ty1; y++) {
        if (isGate(x, y)) continue
        if (cekPagar(x, y)) {
          const kanan = cekPagar(x + 1, y) && !isGate(x + 1, y)
          const bawah = cekPagar(x, y + 1) && !isGate(x, y + 1)
          drawFencePost(ctx, x * TS + TS / 2, y * TS + TS / 2 + 14, kanan || bawah, this.waktu)
          if (kanan) {
            ctx.strokeStyle = '#8a5a33'
            ctx.lineWidth = 2.6
            ctx.beginPath()
            ctx.moveTo(x * TS + TS / 2, y * TS + TS / 2 + 3)
            ctx.lineTo(x * TS + TS / 2 + TS, y * TS + TS / 2 + 3)
            ctx.stroke()
          }
        }
      }
    }
  }

  private gambarEntitas() {
    const ctx = this.ctx
    const items: Array<{ y: number; gambar: () => void }> = []

    for (const b of BANGUNAN) {
      items.push({
        y: (b.ty + b.h) * TS,
        gambar: () => drawBuilding(ctx, b.tx * TS, b.ty * TS, b.w * TS, b.h * TS, b.jenis),
      })
    }
    for (const t of this.trees) {
      const tebas = t.hidup ? 0 : 2
      const sway = t.shake > 0 ? Math.sin(this.waktu * 30) * 3 : 0
      items.push({
        y: t.ty * TS + TS,
        gambar: () => {
          ctx.save()
          if (sway) {
            ctx.translate(t.tx * TS + TS / 2, t.ty * TS + TS)
            ctx.rotate(sway * 0.02)
            ctx.translate(-(t.tx * TS + TS / 2), -(t.ty * TS + TS))
          }
          drawTree(ctx, t.tx * TS + TS / 2, t.ty * TS + TS - 4, this.waktu, t.seed, tebas)
          ctx.restore()
        },
      })
    }
    for (const r of this.rocks) {
      if (!r.hidup) continue
      const guncang = r.shake > 0 ? Math.sin(this.waktu * 30) * 2 : 0
      items.push({
        y: r.ty * TS + TS - 6,
        gambar: () => drawRock(ctx, r.tx * TS + TS / 2 + guncang, r.ty * TS + TS - 10, r.seed),
      })
    }
    for (const s of this.ternak) {
      items.push({
        y: s.ty * TS + TS,
        gambar: () => {
          const kini = Date.now()
          const cx = (s.tx + 0.5) * TS
          const cy = (s.ty + 0.6) * TS
          if (!s.jenis) {
            // tanda slot kosong — tempat membeli ternak
            ctx.save()
            ctx.strokeStyle = 'rgba(90,60,30,0.5)'
            ctx.setLineDash([5, 4])
            ctx.lineWidth = 1.6
            ctx.strokeRect(cx - 16, cy - 16, 32, 22)
            ctx.setLineDash([])
            ctx.fillStyle = 'rgba(90,60,30,0.65)'
            ctx.font = 'bold 9px sans-serif'
            ctx.textAlign = 'center'
            ctx.fillText('+', cx, cy - 1)
            ctx.restore()
            return
          }
          if (s.jenis === 'ayumi') drawAyumi(ctx, cx, cy, this.waktu + s.tx * 1.7, '#f2ead8')
          else drawSapiyu(ctx, cx, cy, this.waktu, s.tx % 2 === 0)
          if (s.siapAt && kini >= s.siapAt) {
            const bob = Math.sin(this.waktu * 3) * 3
            ctx.fillStyle = '#ffe9b8'
            ctx.beginPath()
            ctx.arc(cx, cy - 30 + bob, 7, 0, Math.PI * 2)
            ctx.fill()
            ctx.fillStyle = '#c98a2f'
            ctx.font = 'bold 9px sans-serif'
            ctx.textAlign = 'center'
            ctx.fillText('!', cx, cy - 26.6 + bob)
          } else if (!s.siapAt) {
            // lapar — gelembung pakan
            ctx.fillStyle = 'rgba(255,233,184,0.92)'
            this.roundRect(ctx, cx - 13, cy - 42, 26, 16, 8)
            ctx.fillStyle = '#a9823c'
            ctx.font = 'bold 9px sans-serif'
            ctx.textAlign = 'center'
            ctx.fillText('pakanu', cx, cy - 30.5)
          }
        },
      })
    }
    // NPC Pak Dalu
    items.push({
      y: 8.6 * TS,
      gambar: () => drawNPC(ctx, 27.6 * TS, 8.6 * TS, this.waktu),
    })
    // papan petunjuk
    items.push({
      y: 6.9 * TS,
      gambar: () => {
        ctx.save()
        ctx.fillStyle = '#a97142'
        ctx.fillRect(11.45 * TS, 6.4 * TS, 3.4, 13)
        ctx.fillStyle = '#e8d8a8'
        this.roundRect(ctx, 11.05 * TS, 6.0 * TS, 4.3 * 9.6, 15, 3)
        ctx.strokeStyle = '#8a5a33'
        ctx.lineWidth = 2
        this.roundRectStroke(11.05 * TS, 6.0 * TS, 4.3 * 9.6, 15, 3)
        ctx.fillStyle = '#5a3a1a'
        ctx.font = 'bold 9px sans-serif'
        ctx.textAlign = 'center'
        ctx.fillText('INFO', 11.5 * TS + 5, 6.0 * TS + 10.5)
        ctx.restore()
      },
    })

    // pemain (dengan animasi aksi)
    items.push({
      y: this.py * TS,
      gambar: () => {
        const skala = 1
        drawCharacter(ctx, this.px * TS, this.py * TS, skala, this.arah, this.berjalan ? this.langkah : 0, this.char)
        if (this.aksiAnim > 0 && this.aksiTool) {
          drawToolSwing(ctx, this.px * TS, this.py * TS, skala, this.arah, 1 - this.aksiAnim / 0.36, this.aksiTool)
        }
      },
    })

    items.sort((a, b) => a.y - b.y)
    for (const it of items) it.gambar()

    // lampu jalan dekoratif dekat kios
    ctx.fillStyle = '#6a5a44'
    ctx.fillRect(21.6 * TS, 7.9 * TS, 3.4, 14)
    ctx.fillStyle = '#ffd97a'
    ctx.beginPath()
    ctx.arc(21.75 * TS + 1.5, 7.8 * TS, 4.6, 0, Math.PI * 2)
    ctx.fill()
  }

  private gambarMalam(cw: number, ch: number) {
    // waktu nyata — gelap saat malam hari sungguhan
    const kini = new Date()
    const h = kini.getHours() + kini.getMinutes() / 60
    let alpha = 0
    if (h >= 20 || h < 4.5) alpha = 0.5
    else if (h >= 17) alpha = ((h - 17) / 3) * 0.5
    else if (h >= 4.5) alpha = Math.max(0, (6 - h) / 1.5) * 0.5
    if (alpha <= 0.01) return
    const ctx = this.ctx
    const off = document.createElement('canvas')
    off.width = Math.max(1, Math.floor(cw))
    off.height = Math.max(1, Math.floor(ch))
    const octx = off.getContext('2d')
    if (!octx) return
    octx.fillStyle = `rgba(16,20,52,${alpha})`
    octx.fillRect(0, 0, cw, ch)
    octx.globalCompositeOperation = 'destination-out'
    const lampu: Array<[number, number, number]> = [
      [(this.px) * TS, (this.py) * TS - 24, 150],
      [5.5 * TS, 7.2 * TS, 120],
      [12.5 * TS, 6.2 * TS, 110],
      [24.5 * TS, 7.2 * TS, 130],
      [21.75 * TS, 7.8 * TS, 120],
      [27.6 * TS, 8.2 * TS, 100],
    ]
    const zoom = Math.min(1.9, Math.max(0.85, Math.min(cw / (TS * 13), ch / (TS * 9.5))))
    const camX = Math.min(MAP_W * TS - cw / zoom, Math.max(0, this.px * TS - cw / (2 * zoom)))
    const camY = Math.min(MAP_H * TS - ch / zoom, Math.max(0, this.py * TS - ch / (2 * zoom)))
    for (const [wx, wy, r] of lampu) {
      const sx = (wx - camX) * zoom
      const sy = (wy - camY) * zoom
      const g = octx.createRadialGradient(sx, sy, 0, sx, sy, r * zoom)
      g.addColorStop(0, 'rgba(0,0,0,0.95)')
      g.addColorStop(1, 'rgba(0,0,0,0)')
      octx.fillStyle = g
      octx.beginPath()
      octx.arc(sx, sy, r * zoom, 0, Math.PI * 2)
      octx.fill()
    }
    octx.globalCompositeOperation = 'source-over'
    ctx.drawImage(off, 0, 0)
  }

  private gambarPancing(cw: number, ch: number) {
    const ctx = this.ctx
    const f = this.fish!
    const w = Math.min(380, cw * 0.8)
    const x = cw / 2 - w / 2
    const y = ch * 0.3
    ctx.save()
    ctx.fillStyle = 'rgba(50,38,20,0.9)'
    this.roundRect(ctx, x, y, w, 130, 16)
    ctx.strokeStyle = 'rgba(255,233,184,0.5)'
    ctx.lineWidth = 2
    this.roundRectStroke(x, y, w, 130, 16)
    ctx.fillStyle = '#ffe9b8'
    ctx.font = 'bold 14px sans-serif'
    ctx.textAlign = 'center'
    ctx.fillText(f.over > 0 ? (f.sukses ? 'Dapat ikan!' : 'Ikannya kabur…') : 'Tekan aksi saat ikan di zona!', cw / 2, y + 24)
    // lintasan
    const bx = x + 20
    const bw = w - 40
    const by = y + 48
    ctx.fillStyle = 'rgba(255,255,255,0.14)'
    this.roundRect(ctx, bx, by, bw, 18, 9)
    // zona
    ctx.fillStyle = 'rgba(140,220,140,0.85)'
    this.roundRect(ctx, bx + f.zx * bw, by - 4, f.zw * bw, 26, 8)
    // ikan
    const fx = bx + f.fx * bw
    ctx.fillStyle = f.over > 0 ? (f.sukses ? '#e8b840' : '#b8c4cc') : '#8fd0e8'
    ctx.beginPath()
    ctx.ellipse(fx, by + 9, 10, 6.5, 0, 0, Math.PI * 2)
    ctx.fill()
    ctx.beginPath()
    ctx.moveTo(fx - 9, by + 9)
    ctx.lineTo(fx - 16, by + 4)
    ctx.lineTo(fx - 16, by + 14)
    ctx.closePath()
    ctx.fill()
    // titik hasil
    for (let i = 0; i < 3; i++) {
      ctx.fillStyle = i < f.ok ? '#8fdc7a' : 'rgba(255,255,255,0.2)'
      ctx.beginPath()
      ctx.arc(cw / 2 - 26 + i * 26, y + 104, 7, 0, Math.PI * 2)
      ctx.fill()
    }
    ctx.restore()
  }
}

/** Tempat engine global agar komponen React bisa memanggil aksi */
export const engineHolder: { current: Engine | null } = { current: null }
