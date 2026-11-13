'use client'

/**
 * Miodakali — HUD (antarmuka atas)
 * Menampilkan waktu nyata, level petani & XP, tenaga, Kirupi,
 * tugas berjalan (ala Sunflower Land), tombol tas & bantuan, dan toast.
 */
import { useEffect } from 'react'
import { Backpack, Coins, HelpCircle, Moon, Sun, Sunrise, Sunset } from 'lucide-react'
import { useGameStore } from '@/lib/miodakali/store'
import { NAMA_NPC } from '@/lib/miodakali/data'

const ikonFase = {
  Pagi: Sunrise,
  Siang: Sun,
  Sore: Sunset,
  Malam: Moon,
}

function ToastRow({ id, text }: { id: number; text: string }) {
  const dropToast = useGameStore((s) => s.dropToast)
  useEffect(() => {
    const t = window.setTimeout(() => dropToast(id), 3800)
    return () => window.clearTimeout(t)
  }, [id, dropToast])
  return (
    <div className="pointer-events-auto rounded-full border border-amber-200/40 bg-stone-900/85 px-4 py-2 text-sm font-medium text-amber-50 shadow-lg shadow-black/30">
      {text}
    </div>
  )
}

export default function HUD() {
  const hud = useGameStore((s) => s.hud)
  const toasts = useGameStore((s) => s.toasts)
  const setPanel = useGameStore((s) => s.setPanel)
  const Fase = ikonFase[hud.fase]
  const xpPersen = hud.xpButuh > 0 ? Math.min(100, (hud.xp / hud.xpButuh) * 100) : 100

  return (
    <div className="pointer-events-none absolute inset-0 flex flex-col justify-between p-3 sm:p-4">
      {/* baris atas */}
      <div className="flex items-start justify-between gap-2">
        <div className="flex flex-col gap-2">
          <div className="pointer-events-auto flex items-center gap-3 rounded-2xl border border-amber-200/30 bg-stone-900/80 px-4 py-2.5 text-amber-50 shadow-lg shadow-black/30 backdrop-blur-sm">
            <div className="flex items-center gap-2">
              <Fase className="h-5 w-5 text-amber-300" />
              <div className="leading-tight">
                <div className="text-[11px] uppercase tracking-wide text-amber-200/80">
                  Hari {hud.day} · {hud.fase} · waktu nyata
                </div>
                <div className="text-lg font-bold">{hud.jam}</div>
              </div>
            </div>
            <div className="h-9 w-px bg-amber-200/20" />
            <div className="leading-tight">
              <div className="text-[11px] uppercase tracking-wide text-amber-200/80">{NAMA_NPC.uang}</div>
              <div className="flex items-center gap-1 text-lg font-bold">
                <Coins className="h-4 w-4 text-amber-400" />
                {hud.money.toLocaleString('id-ID')}
              </div>
            </div>
          </div>

          {/* level & pengalaman */}
          <div className="pointer-events-auto w-56 rounded-2xl border border-amber-200/30 bg-stone-900/80 px-4 py-2.5 shadow-lg shadow-black/30 backdrop-blur-sm">
            <div className="flex items-center justify-between text-[11px] uppercase tracking-wide text-amber-200/80">
              <span className="font-bold text-amber-200">Level {hud.level} Petani</span>
              <span className="text-stone-400">{hud.xpButuh > 0 ? `${hud.xp}/${hud.xpButuh} XP` : 'Maks'}</span>
            </div>
            <div className="mt-1.5 h-2 overflow-hidden rounded-full bg-stone-700/70">
              <div
                className="h-full rounded-full bg-gradient-to-r from-violet-400 to-fuchsia-300 transition-all duration-300"
                style={{ width: `${xpPersen}%` }}
              />
            </div>
          </div>

          {/* tenaga */}
          <div className="pointer-events-auto w-56 rounded-2xl border border-amber-200/30 bg-stone-900/80 px-4 py-2.5 shadow-lg shadow-black/30 backdrop-blur-sm">
            <div className="flex items-center justify-between text-[11px] uppercase tracking-wide text-amber-200/80">
              <span>{NAMA_NPC.tenaga}</span>
              <span className="font-bold text-amber-100">
                {hud.energy}/{hud.energyMaks}
              </span>
            </div>
            <div className="mt-1.5 h-2.5 overflow-hidden rounded-full bg-stone-700/70">
              <div
                className="h-full rounded-full transition-all duration-300"
                style={{
                  width: `${Math.max(0, Math.min(100, (hud.energy / hud.energyMaks) * 100))}%`,
                  background: hud.energy > 40 ? 'linear-gradient(90deg,#7fbf5a,#a8d878)' : 'linear-gradient(90deg,#d88a4a,#e8b878)',
                }}
              />
            </div>
          </div>

          {/* tugas berjalan ala Sunflower Land */}
          <button
            aria-label="Buka panduan & daftar tugas"
            onClick={() => setPanel('help')}
            className="pointer-events-auto max-w-64 rounded-2xl border border-emerald-300/30 bg-emerald-900/50 px-3.5 py-2 text-left shadow-lg shadow-black/30 backdrop-blur-sm transition hover:bg-emerald-900/70 active:scale-[0.98]"
          >
            <div className="text-[10px] font-bold uppercase tracking-wide text-emerald-300/90">Tugas</div>
            <div className="text-xs leading-snug text-emerald-50">{hud.quest || 'Selesaikan tugas pertanaman pertamamu!'}</div>
          </button>
        </div>

        {/* tombol kanan */}
        <div className="pointer-events-auto flex gap-2">
          <button
            aria-label="Buka tas"
            onClick={() => setPanel('inv')}
            className="flex h-12 w-12 items-center justify-center rounded-2xl border border-amber-200/30 bg-stone-900/80 text-amber-100 shadow-lg shadow-black/30 backdrop-blur-sm transition hover:bg-stone-800/90 active:scale-95"
          >
            <Backpack className="h-6 w-6" />
          </button>
          <button
            aria-label="Bantuan"
            onClick={() => setPanel('help')}
            className="flex h-12 w-12 items-center justify-center rounded-2xl border border-amber-200/30 bg-stone-900/80 text-amber-100 shadow-lg shadow-black/30 backdrop-blur-sm transition hover:bg-stone-800/90 active:scale-95"
          >
            <HelpCircle className="h-6 w-6" />
          </button>
        </div>
      </div>

      {/* toast bawah-tengah */}
      <div className="mb-28 flex flex-col items-center gap-2 sm:mb-24">
        {toasts.map((t) => (
          <ToastRow key={t.id} id={t.id} text={t.text} />
        ))}
      </div>
    </div>
  )
}
