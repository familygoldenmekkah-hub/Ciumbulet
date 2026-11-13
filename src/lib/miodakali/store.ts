/**
 * Miodakali — Store UI (zustand)
 * Menjembatani engine canvas dengan antarmuka React.
 */
import { create } from 'zustand'
import type { ItemId, ToolId } from './data'

export type PanelKind = null | 'shop' | 'cook' | 'inv' | 'help' | 'wardrobe'

export type FaseHari = 'Pagi' | 'Siang' | 'Sore' | 'Malam'

export interface HudState {
  day: number
  jam: string
  fase: FaseHari
  energy: number
  energyMaks: number
  money: number
  level: number
  xp: number
  xpButuh: number
  /** teks tugas berjalan (tutorial ala Sunflower Land) */
  quest: string
  /** indeks tugas berjalan (untuk daftar di panel bantuan) */
  questIdx: number
  /** label aksi kontekstual pada tombol/tombol E */
  label: string
}

export interface ToastItem {
  id: number
  text: string
}

interface GameStore {
  screen: 'creator' | 'game'
  hasSave: boolean
  panel: PanelKind
  hud: HudState
  tool: ToolId
  activeItem: ItemId | null
  inv: Array<[ItemId, number]>
  panyukan: boolean
  toasts: ToastItem[]
  setScreen: (s: 'creator' | 'game') => void
  setHasSave: (v: boolean) => void
  setPanel: (p: PanelKind) => void
  setHud: (h: Partial<HudState>) => void
  setTool: (t: ToolId) => void
  setActiveItem: (i: ItemId | null) => void
  setInv: (inv: Array<[ItemId, number]>) => void
  setPanyukan: (v: boolean) => void
  pushToast: (text: string) => void
  dropToast: (id: number) => void
}

let toastId = 0

export const useGameStore = create<GameStore>((set) => ({
  screen: 'creator',
  hasSave: false,
  panel: null,
  hud: {
    day: 1,
    jam: '06:00',
    fase: 'Pagi',
    energy: 100,
    energyMaks: 100,
    money: 150,
    level: 1,
    xp: 0,
    xpButuh: 30,
    quest: '',
    questIdx: 0,
    label: '',
  },
  tool: 'cangkur',
  activeItem: null,
  inv: [],
  panyukan: false,
  toasts: [],
  setScreen: (screen) => set({ screen }),
  setHasSave: (hasSave) => set({ hasSave }),
  setPanel: (panel) => set({ panel }),
  setHud: (h) => set((s) => ({ hud: { ...s.hud, ...h } })),
  setTool: (tool) => set({ tool }),
  setActiveItem: (activeItem) => set({ activeItem }),
  setInv: (inv) => set({ inv }),
  setPanyukan: (panyukan) => set({ panyukan }),
  pushToast: (text) =>
    set((s) => {
      toastId += 1
      const id = toastId
      return { toasts: [...s.toasts.slice(-3), { id, text }] }
    }),
  dropToast: (id) => set((s) => ({ toasts: s.toasts.filter((t) => t.id !== id) })),
}))
