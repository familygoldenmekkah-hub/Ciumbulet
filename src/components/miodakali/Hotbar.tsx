'use client'

/**
 * Miodakali — Hotbar perangkat
 */
import { Lock } from 'lucide-react'
import { useGameStore } from '@/lib/miodakali/store'
import { ITEMS, TOOLS_ORDER } from '@/lib/miodakali/data'
import { engineHolder } from '@/lib/miodakali/engine'
import { itemIconURL } from '@/lib/miodakali/sprites'

export default function Hotbar() {
  const tool = useGameStore((s) => s.tool)
  const panyukan = useGameStore((s) => s.panyukan)
  const inv = useGameStore((s) => s.inv)
  const activeItem = useGameStore((s) => s.activeItem)
  const setPanel = useGameStore((s) => s.setPanel)

  const hitung = (id: string) => inv.find(([i]) => i === id)?.[1] ?? 0

  return (
    <div className="pointer-events-none absolute inset-x-0 bottom-3 z-10 flex justify-center px-3">
      <div className="pointer-events-auto flex items-end gap-2 rounded-3xl border border-amber-200/30 bg-stone-900/85 p-2.5 shadow-xl shadow-black/40 backdrop-blur-sm">
        {TOOLS_ORDER.map((id, i) => {
          const terkunci = id === 'panyukan' && !panyukan
          const dipilih = tool === id
          return (
            <button
              key={id}
              aria-label={ITEMS[id].nama}
              onClick={() => engineHolder.current?.setTool(i)}
              className={`relative flex h-14 w-14 flex-col items-center justify-center rounded-2xl border-2 transition active:scale-95 sm:h-16 sm:w-16 ${
                dipilih
                  ? 'border-amber-400 bg-amber-500/20 shadow-inner shadow-amber-500/30'
                  : 'border-stone-600/60 bg-stone-800/60 hover:border-stone-400/60'
              }`}
            >
              {terkunci ? (
                <Lock className="h-6 w-6 text-stone-500" />
              ) : (
                <img src={itemIconURL(id)} alt={ITEMS[id].nama} className="h-9 w-9 sm:h-10 sm:w-10" draggable={false} />
              )}
              <span className="absolute left-1.5 top-1 text-[10px] font-bold text-amber-200/70">{i + 1}</span>
              {!terkunci && hitung(id) > 1 && (
                <span className="absolute bottom-0.5 right-1.5 text-[10px] font-bold text-amber-100">{hitung(id)}</span>
              )}
            </button>
          )
        })}

        {/* slot barang aktif */}
        <div className="mx-1 h-14 w-px bg-amber-200/20 sm:h-16" />
        <button
          aria-label="Barang aktif — buka tas"
          onClick={() => setPanel('inv')}
          className={`relative flex h-14 w-14 flex-col items-center justify-center rounded-2xl border-2 transition active:scale-95 sm:h-16 sm:w-16 ${
            activeItem
              ? 'border-emerald-400/80 bg-emerald-500/15'
              : 'border-dashed border-stone-600/60 bg-stone-800/40'
          }`}
        >
          {activeItem ? (
            <>
              <img src={itemIconURL(activeItem)} alt={ITEMS[activeItem]?.nama ?? ''} className="h-9 w-9 sm:h-10 sm:w-10" draggable={false} />
              <span className="absolute bottom-0.5 right-1.5 text-[10px] font-bold text-emerald-200">{hitung(activeItem)}</span>
            </>
          ) : (
            <span className="px-1 text-center text-[9px] leading-tight text-stone-400">
              Pilih benih
              <br />di Tas
            </span>
          )}
        </button>
      </div>
    </div>
  )
}
