'use client'

/**
 * Miodakali — Kontrol sentuh (ponsel)
 * Joystick kiri + tombol aksi kontekstual kanan. Hanya tampil di perangkat sentuh.
 */
import { useEffect, useRef, useState } from 'react'
import { useGameStore } from '@/lib/miodakali/store'
import { engineHolder } from '@/lib/miodakali/engine'

export default function TouchControls() {
  const [sentuh, setSentuh] = useState(
    () =>
      typeof window !== 'undefined' &&
      (window.matchMedia('(pointer: coarse)').matches || 'ontouchstart' in window),
  )
  const [tarik, setTarik] = useState<{ x: number; y: number } | null>(null)
  const padRef = useRef<HTMLDivElement>(null)
  const label = useGameStore((s) => s.hud.label)
  const panel = useGameStore((s) => s.panel)

  useEffect(() => {
    const mq = window.matchMedia('(pointer: coarse)')
    const ganti = (e: MediaQueryListEvent) => setSentuh(e.matches || 'ontouchstart' in window)
    mq.addEventListener?.('change', ganti)
    return () => mq.removeEventListener?.('change', ganti)
  }, [])

  if (!sentuh) {
    return (
      <div className="pointer-events-none absolute inset-x-0 bottom-20 hidden justify-center sm:flex">
        <span className="rounded-full bg-stone-900/60 px-3 py-1 text-[11px] text-amber-100/70 backdrop-blur-sm">
          WASD/panah = jalan · E = aksi · 1–4 = perangkat · I = tas
        </span>
      </div>
    )
  }

  const tangani = (e: React.PointerEvent) => {
    const pad = padRef.current
    if (!pad) return
    const rect = pad.getBoundingClientRect()
    const cx = rect.left + rect.width / 2
    const cy = rect.top + rect.height / 2
    let dx = (e.clientX - cx) / (rect.width / 2)
    let dy = (e.clientY - cy) / (rect.height / 2)
    const len = Math.hypot(dx, dy)
    if (len > 1) {
      dx /= len
      dy /= len
    }
    engineHolder.current?.setMove(dx, dy)
    setTarik({ x: dx, y: dy })
  }

  const lepas = () => {
    engineHolder.current?.setMove(0, 0)
    setTarik(null)
  }

  return (
    <>
      {/* joystick kiri */}
      <div
        ref={padRef}
        onPointerDown={(e) => {
          e.currentTarget.setPointerCapture(e.pointerId)
          tangani(e)
        }}
        onPointerMove={(e) => {
          if (tarik) tangani(e)
        }}
        onPointerUp={lepas}
        onPointerCancel={lepas}
        className="absolute bottom-24 left-4 z-10 flex h-32 w-32 touch-none items-center justify-center rounded-full border border-amber-200/30 bg-stone-900/40 backdrop-blur-sm"
        aria-label="Joystick gerak"
      >
        <div
          className="pointer-events-none h-14 w-14 rounded-full bg-amber-200/70 shadow-lg shadow-black/40 transition-transform"
          style={{
            transform: tarik ? `translate(${tarik.x * 34}px, ${tarik.y * 34}px)` : 'translate(0,0)',
          }}
        />
      </div>

      {/* tombol aksi kanan */}
      <button
        onPointerDown={(e) => {
          e.preventDefault()
          engineHolder.current?.pressAction()
        }}
        disabled={!!panel}
        className="absolute bottom-24 right-4 z-10 flex h-24 w-24 touch-none flex-col items-center justify-center rounded-full border-2 border-amber-300/60 bg-amber-600/90 text-amber-50 shadow-xl shadow-black/40 transition active:scale-95 disabled:opacity-40"
        aria-label={`Aksi: ${label || 'Aksi'}`}
      >
        <span className="px-2 text-center text-sm font-bold leading-tight">
          {label || 'Aksi'}
        </span>
      </button>
    </>
  )
}
