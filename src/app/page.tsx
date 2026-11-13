'use client'

import dynamic from 'next/dynamic'

function Splash() {
  return (
    <div className="fixed inset-0 flex flex-col items-center justify-center gap-3 bg-[#3a4d2a] text-amber-100">
      <div className="h-10 w-10 animate-spin rounded-full border-4 border-amber-200/30 border-t-amber-300" />
      <p className="text-sm font-semibold tracking-wide">Memuat Desa Miodakali…</p>
    </div>
  )
}

const GameRoot = dynamic(() => import('@/components/miodakali/GameRoot'), {
  ssr: false,
  loading: () => <Splash />,
})

export default function Home() {
  return <GameRoot />
}
