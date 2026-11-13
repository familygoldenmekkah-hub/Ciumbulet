'use client'

/**
 * Miodakali — Akar Game
 * Memasang engine canvas dan seluruh antarmuka (HUD, panel, kontrol sentuh).
 */
import { useEffect, useRef } from 'react'
import { Engine, engineHolder } from '@/lib/miodakali/engine'
import { useGameStore } from '@/lib/miodakali/store'
import HUD from './HUD'
import Hotbar from './Hotbar'
import TouchControls from './TouchControls'
import { CookPanel, HelpPanel, InventoryPanel, ShopPanel, WardrobePanel } from './Panels'
import CharacterCreator from './CharacterCreator'

export default function GameRoot() {
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const screen = useGameStore((s) => s.screen)
  const panel = useGameStore((s) => s.panel)

  useEffect(() => {
    if (!canvasRef.current) return
    const engine = new Engine(canvasRef.current)
    engineHolder.current = engine
    ;(window as unknown as { __miodakali?: Engine }).__miodakali = engine
    useGameStore.getState().setHasSave(engine.punyaSimpanan())
    engine.start()
    return () => {
      engine.stop()
      engineHolder.current = null
    }
  }, [])

  return (
    <div className="fixed inset-0 select-none overflow-hidden bg-[#2c2416]">
      <canvas ref={canvasRef} className="absolute inset-0 h-full w-full touch-none" />

      {screen === 'game' && (
        <>
          <HUD />
          <Hotbar />
          <TouchControls />
          {panel === 'shop' && <ShopPanel />}
          {panel === 'cook' && <CookPanel />}
          {panel === 'wardrobe' && <WardrobePanel />}
          {panel === 'inv' && <InventoryPanel />}
          {panel === 'help' && <HelpPanel />}
        </>
      )}

      {screen === 'creator' && <CharacterCreator />}
    </div>
  )
}
