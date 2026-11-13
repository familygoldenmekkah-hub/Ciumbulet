'use client'

/**
 * Miodakali — Layar Pembuatan Karakter
 * Karakter berpakaian rapi & menutup; tanpa label apa pun selain gaya netral.
 */
import { useEffect, useRef, useState } from 'react'
import { Play, Sprout } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { engineHolder } from '@/lib/miodakali/engine'
import { GAYA_NAMA, GAYA_WARNA, KULIT_WARNA, KarakterCfg } from '@/lib/miodakali/data'
import { drawCharacterPreview } from '@/lib/miodakali/sprites'
import { useGameStore } from '@/lib/miodakali/store'

export default function CharacterCreator() {
  const hasSave = useGameStore((s) => s.hasSave)
  const [char, setChar] = useState<KarakterCfg>({ kelamin: 'pria', kulit: 0, gaya: 0 })
  const cvRef = useRef<HTMLCanvasElement>(null)

  useEffect(() => {
    const cv = cvRef.current
    if (!cv) return
    cv.width = 240
    cv.height = 300
    const ctx = cv.getContext('2d')
    if (!ctx) return
    drawCharacterPreview(ctx, 240, 300, char)
  }, [char])

  return (
    <div className="absolute inset-0 z-20 flex items-center justify-center overflow-y-auto bg-gradient-to-b from-[#3a4d2a] via-[#4a6136] to-[#2c3d20] p-4">
      <div className="w-full max-w-md rounded-3xl border border-amber-200/30 bg-stone-900/85 p-6 text-amber-50 shadow-2xl shadow-black/50 backdrop-blur">
        <div className="mb-1 flex items-center justify-center gap-2 text-amber-300">
          <Sprout className="h-6 w-6" />
          <span className="text-xs font-bold uppercase tracking-[0.3em]">Desa Miodakali</span>
        </div>
        <h1 className="text-center text-4xl font-extrabold tracking-wide text-amber-100">MIODAKALI</h1>
        <p className="mt-1 text-center text-sm text-stone-300">
          Petualangan tani santai — tanam, pelihara, memancing, dan memasak.
        </p>

        <div className="mt-5 flex justify-center">
          <canvas ref={cvRef} className="rounded-2xl border border-amber-200/20 shadow-inner" />
        </div>

        <div className="mt-5 space-y-4">
          <div>
            <div className="mb-2 text-xs font-bold uppercase tracking-wide text-amber-200/80">Penampilan</div>
            <div className="grid grid-cols-2 gap-2">
              {(['pria', 'wanita'] as const).map((k) => (
                <button
                  key={k}
                  onClick={() => setChar((c) => ({ ...c, kelamin: k }))}
                  className={`rounded-xl border-2 px-3 py-2.5 text-sm font-semibold capitalize transition active:scale-95 ${
                    char.kelamin === k
                      ? 'border-amber-400 bg-amber-500/20 text-amber-100'
                      : 'border-stone-600/60 bg-stone-800/60 text-stone-300'
                  }`}
                >
                  {k === 'pria' ? 'Pria' : 'Wanita'}
                </button>
              ))}
            </div>
          </div>

          <div>
            <div className="mb-2 text-xs font-bold uppercase tracking-wide text-amber-200/80">Warna Kulit</div>
            <div className="flex gap-3">
              {KULIT_WARNA.map((w, i) => (
                <button
                  key={w}
                  aria-label={`Warna kulit ${i + 1}`}
                  onClick={() => setChar((c) => ({ ...c, kulit: i }))}
                  className={`h-11 w-11 rounded-full border-4 transition active:scale-95 ${
                    char.kulit === i ? 'border-amber-400 scale-105' : 'border-stone-600/60'
                  }`}
                  style={{ backgroundColor: w }}
                />
              ))}
            </div>
          </div>

          <div>
            <div className="mb-2 text-xs font-bold uppercase tracking-wide text-amber-200/80">Gaya Pakaian</div>
            <div className="grid grid-cols-3 gap-2">
              {GAYA_NAMA.map((nama, i) => {
                const g = GAYA_WARNA[i]
                return (
                  <button
                    key={nama}
                    onClick={() => setChar((c) => ({ ...c, gaya: i }))}
                    className={`flex flex-col items-center gap-1.5 rounded-xl border-2 px-2 py-2.5 transition active:scale-95 ${
                      char.gaya === i
                        ? 'border-amber-400 bg-amber-500/20'
                        : 'border-stone-600/60 bg-stone-800/60'
                    }`}
                  >
                    <span className="flex gap-1">
                      <span className="h-4 w-4 rounded-full border border-black/20" style={{ backgroundColor: g.baju }} />
                      <span className="h-4 w-4 rounded-full border border-black/20" style={{ backgroundColor: char.kelamin === 'wanita' ? g.tutupWanita : g.bawah }} />
                    </span>
                    <span className="text-xs font-semibold text-amber-100">{nama}</span>
                  </button>
                )
              })}
            </div>
          </div>
        </div>

        <div className="mt-6 space-y-2">
          {hasSave && (
            <Button
              size="lg"
              onClick={() => engineHolder.current?.continueGame()}
              className="w-full bg-emerald-600/90 py-6 text-base font-bold text-amber-50 hover:bg-emerald-600"
            >
              <Play className="mr-2 h-5 w-5" />
              Lanjutkan Petualangan
            </Button>
          )}
          <Button
            size="lg"
            onClick={() => engineHolder.current?.newGame(char)}
            className={`w-full py-6 text-base font-bold ${
              hasSave
                ? 'bg-stone-700/80 text-amber-100 hover:bg-stone-700'
                : 'bg-amber-600/90 text-amber-50 hover:bg-amber-600'
            }`}
          >
            <Sprout className="mr-2 h-5 w-5" />
            {hasSave ? 'Mulai Permainan Baru' : 'Mulai Petualangan'}
          </Button>
        </div>

        <p className="mt-4 text-center text-[11px] text-stone-500">
          Seluruh nama, model, dan dunia dalam game ini adalah karya asli Miodakali.
        </p>
      </div>
    </div>
  )
}
