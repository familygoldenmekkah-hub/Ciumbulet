'use client'

/**
 * Miodakali — Panel-panel: Kios Desa, Dapur, Lemari Pakaian, Tas, Bantuan
 * Skema ala Sunflower Land: benih/resep terkunci level, jual-beli di kios.
 */
import { useState } from 'react'
import { Coins, Info, RotateCcw, Shirt, Utensils, Zap } from 'lucide-react'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Button } from '@/components/ui/button'
import { ScrollArea } from '@/components/ui/scroll-area'
import { useGameStore } from '@/lib/miodakali/store'
import { engineHolder } from '@/lib/miodakali/engine'
import { GAYA_NAMA, ITEMS, KULIT_WARNA, QUESTS, RECIPES, KarakterCfg } from '@/lib/miodakali/data'
import { drawCharacterPreview, itemIconURL } from '@/lib/miodakali/sprites'

function uang(n: number) {
  return n.toLocaleString('id-ID')
}

/* ------------------------------- Kios Desa ------------------------------- */

export function ShopPanel() {
  const panel = useGameStore((s) => s.panel)
  const setPanel = useGameStore((s) => s.setPanel)
  const hud = useGameStore((s) => s.hud)
  const inv = useGameStore((s) => s.inv)
  const panyukan = useGameStore((s) => s.panyukan)
  const [, tick] = useState(0)

  const daftarBeli = Object.values(ITEMS).filter((d) => d.hargaBeli && d.hargaBeli > 0)
  const daftarJual = inv.filter(([id, n]) => n > 0 && (ITEMS[id]?.hargaJual ?? 0) > 0)

  return (
    <Dialog open={panel === 'shop'} onOpenChange={(v) => !v && setPanel(null)}>
      <DialogContent className="max-h-[85vh] border-amber-200/30 bg-stone-900/95 text-amber-50 sm:max-w-lg">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2 text-amber-100">
            <Coins className="h-5 w-5 text-amber-400" />
            Kios Desa — Pak Dalu
            <span className="ml-auto text-sm font-bold text-amber-300">{uang(hud.money)} Kirupi</span>
          </DialogTitle>
        </DialogHeader>
        <Tabs defaultValue="beli">
          <TabsList className="w-full bg-stone-800 text-amber-100">
            <TabsTrigger value="beli" className="flex-1">Beli</TabsTrigger>
            <TabsTrigger value="jual" className="flex-1">Jual</TabsTrigger>
          </TabsList>

          <TabsContent value="beli">
            <ScrollArea className="max-h-[52vh] pr-2">
              <div className="space-y-2">
                {daftarBeli.map((d) => {
                  const sudahPunya = d.id === 'panyukan' && panyukan
                  const terkunci = hud.level < (d.levelButuh ?? 1)
                  return (
                    <div key={d.id} className={`flex items-center gap-3 rounded-xl border border-stone-700/70 bg-stone-800/60 p-2.5 ${terkunci ? 'opacity-60' : ''}`}>
                      <img src={itemIconURL(d.id)} alt={d.nama} className="h-10 w-10 shrink-0" draggable={false} />
                      <div className="min-w-0 flex-1">
                        <div className="truncate text-sm font-semibold text-amber-100">{d.nama}</div>
                        <div className="truncate text-xs text-stone-400">
                          {d.deskripsi}
                          {terkunci && <span className="ml-1 font-semibold text-red-300">· Terbuka di Level {d.levelButuh}</span>}
                        </div>
                      </div>
                      {sudahPunya ? (
                        <span className="rounded-lg bg-emerald-700/40 px-2 py-1 text-xs font-bold text-emerald-200">Dimiliki</span>
                      ) : terkunci ? (
                        <span className="rounded-lg bg-stone-700/60 px-2 py-1 text-xs font-bold text-stone-300">Level {d.levelButuh}</span>
                      ) : (
                        <div className="flex shrink-0 items-center gap-1.5">
                          <span className="text-xs font-bold text-amber-300">{uang(d.hargaBeli!)}</span>
                          {[1, 5].map((q) => (
                            <Button
                              key={q}
                              size="sm"
                              variant="secondary"
                              aria-label={`Beli ${d.nama} x${q}`}
                              disabled={hud.money < d.hargaBeli! * q}
                              onClick={() => {
                                if (engineHolder.current?.beli(d.id, q)) tick((x) => x + 1)
                              }}
                              className="h-8 bg-amber-600/80 px-2.5 text-amber-50 hover:bg-amber-600"
                            >
                              x{q}
                            </Button>
                          ))}
                        </div>
                      )}
                    </div>
                  )
                })}
              </div>
            </ScrollArea>
          </TabsContent>

          <TabsContent value="jual">
            <ScrollArea className="max-h-[52vh] pr-2">
              {daftarJual.length === 0 ? (
                <p className="py-8 text-center text-sm text-stone-400">Tas masih kosong — panen dulu, lalu jual di sini.</p>
              ) : (
                <div className="space-y-2">
                  {daftarJual.map(([id, n]) => {
                    const d = ITEMS[id]
                    return (
                      <div key={id} className="flex items-center gap-3 rounded-xl border border-stone-700/70 bg-stone-800/60 p-2.5">
                        <img src={itemIconURL(id)} alt={d.nama} className="h-10 w-10 shrink-0" draggable={false} />
                        <div className="min-w-0 flex-1">
                          <div className="truncate text-sm font-semibold text-amber-100">
                            {d.nama} <span className="text-stone-400">x{n}</span>
                          </div>
                          <div className="text-xs text-amber-300/80">+{uang(d.hargaJual)} Kirupi / buah</div>
                        </div>
                        <div className="flex shrink-0 items-center gap-1.5">
                          <Button
                            size="sm"
                            variant="secondary"
                            aria-label={`Jual ${d.nama} satu`}
                            onClick={() => {
                              engineHolder.current?.jual(id, 1)
                              tick((x) => x + 1)
                            }}
                            className="h-8 bg-amber-600/80 px-2.5 text-amber-50 hover:bg-amber-600"
                          >
                            x1
                          </Button>
                          <Button
                            size="sm"
                            variant="secondary"
                            aria-label={`Jual semua ${d.nama}`}
                            onClick={() => {
                              engineHolder.current?.jual(id, n)
                              tick((x) => x + 1)
                            }}
                            className="h-8 bg-emerald-600/80 px-2.5 text-amber-50 hover:bg-emerald-600"
                          >
                            Semua
                          </Button>
                        </div>
                      </div>
                    )
                  })}
                </div>
              )}
            </ScrollArea>
          </TabsContent>
        </Tabs>
      </DialogContent>
    </Dialog>
  )
}

/* -------------------------------- Dapur -------------------------------- */

export function CookPanel() {
  const panel = useGameStore((s) => s.panel)
  const setPanel = useGameStore((s) => s.setPanel)
  const hud = useGameStore((s) => s.hud)
  const inv = useGameStore((s) => s.inv)
  const [, tick] = useState(0)

  const milik = (id: string) => inv.find(([i]) => i === id)?.[1] ?? 0

  return (
    <Dialog open={panel === 'cook'} onOpenChange={(v) => !v && setPanel(null)}>
      <DialogContent className="max-h-[85vh] border-amber-200/30 bg-stone-900/95 text-amber-50 sm:max-w-lg">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2 text-amber-100">
            <Utensils className="h-5 w-5 text-amber-400" />
            Dapur Desa — masakan memulihkan Tenaga
          </DialogTitle>
        </DialogHeader>
        <ScrollArea className="max-h-[55vh] pr-2">
          <div className="space-y-2">
            {RECIPES.map((r) => {
              const def = ITEMS[r.id]
              const terkunci = hud.level < r.levelButuh
              const cukup = !terkunci && (engineHolder.current?.bisaMasak(r.id) ?? false)
              return (
                <div key={r.id} className={`rounded-xl border border-stone-700/70 bg-stone-800/60 p-3 ${terkunci ? 'opacity-60' : ''}`}>
                  <div className="flex items-center gap-3">
                    <img src={itemIconURL(r.id)} alt={def.nama} className="h-11 w-11 shrink-0" draggable={false} />
                    <div className="min-w-0 flex-1">
                      <div className="text-sm font-semibold text-amber-100">{def.nama}</div>
                      <div className="flex flex-wrap items-center gap-x-3 gap-y-1 text-xs">
                        <span className="text-emerald-300/90"><Zap className="mr-0.5 inline h-3 w-3" />+{def.energi} Tenaga</span>
                        <span className="text-amber-300/90">jual {uang(def.hargaJual)} Kirupi</span>
                        {terkunci && <span className="font-semibold text-red-300">Resep terbuka di Level {r.levelButuh}</span>}
                      </div>
                    </div>
                    <Button
                      size="sm"
                      aria-label={`Masak ${def.nama}`}
                      disabled={!cukup}
                      onClick={() => {
                        if (engineHolder.current?.masak(r.id)) tick((x) => x + 1)
                      }}
                      className="h-9 shrink-0 bg-amber-600/90 text-amber-50 hover:bg-amber-600"
                    >
                      Masak
                    </Button>
                  </div>
                  <div className="mt-2 flex flex-wrap gap-2 border-t border-stone-700/50 pt-2">
                    {r.bahan.map(([bid, bn]) => {
                      const ada = milik(bid) >= bn
                      return (
                        <span
                          key={bid}
                          className={`flex items-center gap-1 rounded-lg px-2 py-0.5 text-xs font-medium ${
                            ada ? 'bg-emerald-800/40 text-emerald-200' : 'bg-red-900/40 text-red-300'
                          }`}
                        >
                          <img src={itemIconURL(bid)} alt={ITEMS[bid].nama} className="h-4 w-4" draggable={false} />
                          {ITEMS[bid].nama} x{bn}
                          <span className="opacity-60">({milik(bid)})</span>
                        </span>
                      )
                    })}
                  </div>
                </div>
              )
            })}
          </div>
        </ScrollArea>
      </DialogContent>
    </Dialog>
  )
}

/* --------------------------- Lemari Pakaian --------------------------- */

export function WardrobePanel() {
  const panel = useGameStore((s) => s.panel)
  const setPanel = useGameStore((s) => s.setPanel)
  const [char, setChar] = useState<KarakterCfg>(() => engineHolder.current?.getChar() ?? { kelamin: 'pria', kulit: 0, gaya: 0 })
  const cvRef = (el: HTMLCanvasElement | null) => {
    if (!el) return
    const ctx = el.getContext('2d')
    if (!ctx) return
    drawCharacterPreview(ctx, 150, 180, char)
  }

  const pilih = (sebagian: Partial<KarakterCfg>) => {
    const next = { ...char, ...sebagian }
    setChar(next)
    engineHolder.current?.ubahChar(next)
  }

  return (
    <Dialog open={panel === 'wardrobe'} onOpenChange={(v) => !v && setPanel(null)}>
      <DialogContent className="border-amber-200/30 bg-stone-900/95 text-amber-50 sm:max-w-sm">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2 text-amber-100">
            <Shirt className="h-5 w-5 text-amber-400" />
            Lemari Pakaian
          </DialogTitle>
        </DialogHeader>
        <div className="flex justify-center">
          <canvas ref={cvRef} width={150} height={180} className="rounded-2xl border border-amber-200/20" />
        </div>
        <div className="grid grid-cols-2 gap-2">
          {(['pria', 'wanita'] as const).map((k) => (
            <button
              key={k}
              onClick={() => pilih({ kelamin: k })}
              className={`rounded-xl border-2 px-3 py-2 text-sm font-semibold transition active:scale-95 ${
                char.kelamin === k ? 'border-amber-400 bg-amber-500/20 text-amber-100' : 'border-stone-600/60 bg-stone-800/60 text-stone-300'
              }`}
            >
              {k === 'pria' ? 'Pria' : 'Wanita'}
            </button>
          ))}
        </div>
        <div className="flex gap-3">
          {KULIT_WARNA.map((w, i) => (
            <button
              key={w}
              aria-label={`Warna kulit ${i + 1}`}
              onClick={() => pilih({ kulit: i })}
              className={`h-10 w-10 rounded-full border-4 transition active:scale-95 ${
                char.kulit === i ? 'border-amber-400 scale-105' : 'border-stone-600/60'
              }`}
              style={{ backgroundColor: w }}
            />
          ))}
        </div>
        <div className="grid grid-cols-3 gap-2">
          {GAYA_NAMA.map((nama, i) => (
            <button
              key={nama}
              onClick={() => pilih({ gaya: i })}
              className={`rounded-xl border-2 px-2 py-2 text-xs font-semibold transition active:scale-95 ${
                char.gaya === i ? 'border-amber-400 bg-amber-500/20 text-amber-100' : 'border-stone-600/60 bg-stone-800/60 text-stone-300'
              }`}
            >
              {nama}
            </button>
          ))}
        </div>
      </DialogContent>
    </Dialog>
  )
}

/* --------------------------------- Tas --------------------------------- */

export function InventoryPanel() {
  const panel = useGameStore((s) => s.panel)
  const setPanel = useGameStore((s) => s.setPanel)
  const inv = useGameStore((s) => s.inv)
  const activeItem = useGameStore((s) => s.activeItem)
  const [, tick] = useState(0)
  const [detail, setDetail] = useState<string | null>(null)

  const pilih = (id: string) => {
    const def = ITEMS[id]
    if (!def) return
    if (def.kategori === 'benih' || id === 'pakanu') {
      engineHolder.current?.setActiveItem(id)
      setDetail(null)
    } else if (def.energi) {
      engineHolder.current?.makan(id)
      setDetail(null)
    } else {
      setDetail(id)
    }
    tick((x) => x + 1)
  }

  const d = detail ? ITEMS[detail] : null

  return (
    <Dialog open={panel === 'inv'} onOpenChange={(v) => !v && setPanel(null)}>
      <DialogContent className="max-h-[85vh] border-amber-200/30 bg-stone-900/95 text-amber-50 sm:max-w-md">
        <DialogHeader>
          <DialogTitle className="text-amber-100">Tas</DialogTitle>
        </DialogHeader>
        <p className="-mt-2 text-xs text-stone-400">
          Ketuk benih/Pakanu untuk menjadikannya barang aktif, ketuk masakan untuk dimakan.
        </p>
        <ScrollArea className="max-h-[46vh] pr-1">
          <div className="grid grid-cols-4 gap-2">
            {inv.map(([id, n]) => (
              <button
                key={id}
                onClick={() => pilih(id)}
                className={`flex flex-col items-center rounded-xl border-2 p-2 transition active:scale-95 ${
                  activeItem === id
                    ? 'border-emerald-400/80 bg-emerald-500/15'
                    : 'border-stone-700/70 bg-stone-800/60 hover:border-stone-500/70'
                }`}
              >
                <img src={itemIconURL(id)} alt={ITEMS[id]?.nama ?? id} className="h-9 w-9" draggable={false} />
                <span className="mt-1 w-full truncate text-center text-[10px] font-medium text-amber-100/90">{ITEMS[id]?.nama}</span>
                <span className="text-[10px] font-bold text-amber-300">x{n}</span>
              </button>
            ))}
            {inv.length === 0 && <p className="col-span-4 py-6 text-center text-sm text-stone-400">Tas kosong.</p>}
          </div>
        </ScrollArea>
        {d && (
          <div className="rounded-xl border border-amber-200/20 bg-stone-800/60 p-3">
            <div className="flex items-center gap-3">
              <img src={itemIconURL(d.id)} alt={d.nama} className="h-10 w-10" draggable={false} />
              <div className="min-w-0 flex-1">
                <div className="text-sm font-bold text-amber-100">{d.nama}</div>
                <div className="text-xs text-stone-400">{d.deskripsi}</div>
              </div>
            </div>
            <div className="mt-2 flex gap-2">
              <Button size="sm" variant="secondary" className="h-8 bg-stone-700/80 text-amber-50" onClick={() => setDetail(null)}>
                Tutup
              </Button>
              {(d.hargaJual ?? 0) > 0 && (
                <span className="self-center text-xs text-amber-300/90">Nilai jual: {uang(d.hargaJual)} Kirupi — jual di Kios Desa</span>
              )}
            </div>
          </div>
        )}
      </DialogContent>
    </Dialog>
  )
}

/* ------------------------------- Bantuan ------------------------------- */

export function HelpPanel() {
  const panel = useGameStore((s) => s.panel)
  const setPanel = useGameStore((s) => s.setPanel)
  const hud = useGameStore((s) => s.hud)

  return (
    <Dialog open={panel === 'help'} onOpenChange={(v) => !v && setPanel(null)}>
      <DialogContent className="max-h-[85vh] border-amber-200/30 bg-stone-900/95 text-amber-50 sm:max-w-md">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2 text-amber-400">
            <Info className="h-5 w-5 text-amber-400" />
            Panduan Desa Miodakali
          </DialogTitle>
        </DialogHeader>
        <ScrollArea className="max-h-[55vh] pr-2">
          <div className="space-y-3 text-sm leading-relaxed text-stone-300">
            <p>
              <span className="font-bold text-amber-200">Miodakali</span> adalah game tani santai dengan
              waktu nyata: tanaman tumbuh meski kamu keluar dari game, tenaga pulih perlahan, dan
              hewan ternak berproduksi mengikuti timer — tanpa perlu tidur.
            </p>
            <div className="rounded-xl bg-stone-800/60 p-3">
              <div className="mb-1 font-semibold text-amber-200">Kontrol</div>
              <ul className="list-inside list-disc space-y-0.5 text-xs">
                <li>Jalan: WASD / panah / joystick</li>
                <li>Aksi: E / Spasi / tombol aksi</li>
                <li>Perangkat: 1–4 (Cangkur, Kapura, Giliuk, Panyukan)</li>
                <li>Tas: I — pilih benih/Pakanu sebagai barang aktif</li>
              </ul>
            </div>
            <div className="rounded-xl bg-stone-800/60 p-3">
              <div className="mb-1 font-semibold text-amber-200">Alur permainan</div>
              <ul className="list-inside list-disc space-y-0.5 text-xs">
                <li>Bel benih di Kios, tanam di petak, panen saat matang (ada bilah waktu).</li>
                <li>Jual hasilnya di Kios untuk Kirupi, beli benih lebih mahal.</li>
                <li>Tebang Kayanu (Kapura) &amp; pecah Batuku (Giliuk) untuk Balanu &amp; Batuku.</li>
                <li>Beli petak kebun baru dengan Kirupi + Balanu + Batuku (papan JUAL di ladang).</li>
                <li>Beli Ayumi/Sapiyu di kandang, beri Pakanu, ambil hasilnya saat siap.</li>
                <li>Masak di Dapur untuk makanan ber-tenaga besar; pancing di Kolam.</li>
              </ul>
            </div>
            <div className="rounded-xl bg-stone-800/60 p-3">
              <div className="mb-1 font-semibold text-amber-200">Level Petani</div>
              <ul className="list-inside list-disc space-y-0.5 text-xs">
                <li>Semua aksi memberi XP; naik level membuka benih, resep, dan ternak baru.</li>
                <li>Level 2: Beraka &amp; Panyukan · Level 3: Terunu · Level 4: Makira &amp; Sapiyu.</li>
                <li>Level 5: Bubur Beraka · Level 6: Kopanu &amp; Kue · Level 8: Sundara.</li>
                <li>Tenaga maksimum bertambah +5 setiap naik level.</li>
              </ul>
            </div>
            <div className="rounded-xl bg-stone-800/60 p-3">
              <div className="mb-1 font-semibold text-amber-200">Tugas berjalan</div>
              <ul className="space-y-0.5 text-xs">
                {QUESTS.map((q, i) => (
                  <li
                    key={q.id}
                    className={`flex items-start gap-1.5 ${i === 0 ? 'font-semibold text-amber-200' : 'text-stone-400'}`}
                  >
                    <span className={i < hud.questIdx ? 'text-emerald-400' : 'text-stone-500'}>{i < hud.questIdx ? '✓' : '·'}</span>
                    <span>{q.teks}</span>
                  </li>
                ))}
              </ul>
            </div>
            <p className="text-xs text-stone-500">
              Progres tersimpan otomatis di perangkat ini. Seluruh nama, model, dan dunia
              Miodakali adalah karya asli game ini.
            </p>
          </div>
        </ScrollArea>
        <Button
          variant="destructive"
          className="w-full"
          onClick={() => {
            if (window.confirm('Mulai dari awal? Seluruh progres Desa Miodakali akan dihapus.')) {
              engineHolder.current?.hapusSimpanan()
              window.location.reload()
            }
          }}
        >
          <RotateCcw className="mr-2 h-4 w-4" />
          Mulai Baru
        </Button>
      </DialogContent>
    </Dialog>
  )
}
