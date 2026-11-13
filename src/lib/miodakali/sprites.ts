/**
 * Miodakali — Pemodelan Visual (sprite vektor)
 * SEMUA model digambar dari nol dengan kode canvas 2D (bukan pixel art,
 * bukan aset pihak lain). Gaya: kartun flat hangat dengan outline lembut.
 */
import {
  KarakterCfg,
  CropDef,
  ItemId,
  ITEMS,
  KULIT_WARNA,
  GAYA_WARNA,
} from './data'

export type Arah = 0 | 1 | 2 | 3 // 0 bawah, 1 atas, 2 kiri, 3 kanan

function rr(ctx: CanvasRenderingContext2D, x: number, y: number, w: number, h: number, r: number) {
  ctx.beginPath()
  ctx.moveTo(x + r, y)
  ctx.arcTo(x + w, y, x + w, y + h, r)
  ctx.arcTo(x + w, y + h, x, y + h, r)
  ctx.arcTo(x, y + h, x, y, r)
  ctx.arcTo(x, y, x + w, y, r)
  ctx.closePath()
  ctx.fill()
}

function el(ctx: CanvasRenderingContext2D, x: number, y: number, rx: number, ry: number, warna: string, alpha = 1) {
  ctx.save()
  ctx.globalAlpha = alpha
  ctx.fillStyle = warna
  ctx.beginPath()
  ctx.ellipse(x, y, rx, ry, 0, 0, Math.PI * 2)
  ctx.fill()
  ctx.restore()
}

function shade(hex: string, amt: number): string {
  const n = hex.replace('#', '')
  const v = parseInt(n, 16)
  let r = (v >> 16) & 255
  let g = (v >> 8) & 255
  let b = v & 255
  r = Math.max(0, Math.min(255, Math.round(r + amt)))
  g = Math.max(0, Math.min(255, Math.round(g + amt)))
  b = Math.max(0, Math.min(255, Math.round(b + amt)))
  return `rgb(${r},${g},${b})`
}

/* ============================ KARAKTER PEMAIN ============================ */

export function drawCharacter(
  ctx: CanvasRenderingContext2D,
  x: number,
  y: number,
  scale: number,
  arah: Arah,
  langkah: number,
  look: KarakterCfg,
  sedangAksi = false,
) {
  const kulit = KULIT_WARNA[look.kulit] ?? KULIT_WARNA[0]
  const gaya = GAYA_WARNA[look.gaya] ?? GAYA_WARNA[0]
  const wanita = look.kelamin === 'wanita'
  const baju = gaya.baju
  const bajuTua = shade(baju, -28)
  const bawah = gaya.bawah

  ctx.save()
  ctx.translate(x, y)
  ctx.scale(scale, scale)

  // bayangan
  el(ctx, 0, 1, 11, 4, 'rgba(40,30,10,0.22)')

  const ayun = Math.sin(langkah) * 3.2
  const bob = sedangAksi ? 0 : Math.abs(Math.sin(langkah)) * 1.1
  ctx.translate(0, -bob)

  // kaki
  if (wanita) {
    // rok panjang rapi
    ctx.fillStyle = bawah
    ctx.beginPath()
    ctx.moveTo(-6, -14)
    ctx.lineTo(6, -14)
    ctx.lineTo(10, -1)
    ctx.lineTo(-10, -1)
    ctx.closePath()
    ctx.fill()
    // langkah kaki kecil di bawah rok
    el(ctx, -3 + ayun * 0.4, -1, 3.4, 2.2, shade('#e8e0d0', -40))
    el(ctx, 3 - ayun * 0.4, -1, 3.4, 2.2, shade('#e8e0d0', -40))
  } else {
    ctx.fillStyle = bawah
    rr(ctx, -6.5, -14 + Math.max(0, ayun * 0.6), 5, 13 - Math.max(0, ayun * 0.6), 2.4)
    rr(ctx, 1.5, -14 + Math.max(0, -ayun * 0.6), 5, 13 - Math.max(0, -ayun * 0.6), 2.4)
    // sepatu
    ctx.fillStyle = shade(bawah, -35)
    rr(ctx, -7, -2.6, 6, 3, 1.5)
    rr(ctx, 1, -2.6, 6, 3, 1.5)
  }

  // badan — baju lengan panjang menutup
  if (wanita) {
    ctx.fillStyle = baju
    ctx.beginPath()
    ctx.moveTo(-7.5, -28)
    ctx.lineTo(7.5, -28)
    ctx.lineTo(9, -14)
    ctx.lineTo(-9, -14)
    ctx.closePath()
    ctx.fill()
    // lipatan rok
    ctx.fillStyle = bajuTua
    ctx.fillRect(-7.5, -20, 15, 2)
  } else {
    ctx.fillStyle = baju
    rr(ctx, -8, -28, 16, 15.5, 4.5)
    ctx.fillStyle = bajuTua
    ctx.fillRect(-8, -16.5, 16, 1.6)
  }

  // lengan
  ctx.fillStyle = baju
  rr(ctx, -11, -27 + ayun * 0.5, 4.5, 11, 2.2)
  rr(ctx, 6.5, -27 - ayun * 0.5, 4.5, 11, 2.2)
  el(ctx, -8.7, -16 + ayun * 0.5, 2.2, 2.2, kulit)
  el(ctx, 8.7, -16 - ayun * 0.5, 2.2, 2.2, kulit)

  // kepala
  const hy = -36
  if (wanita) {
    // selendang penutup kepala (model mandiri)
    el(ctx, 0, hy, 9.6, 9.2, gaya.tutupWanita)
    ctx.fillStyle = kulit
    ctx.beginPath()
    ctx.ellipse(0, hy + 1.2, 6.6, 7.2, 0, 0, Math.PI * 2)
    ctx.fill()
    // lipatan selendang
    ctx.strokeStyle = shade(gaya.tutupWanita, -30)
    ctx.lineWidth = 1.4
    ctx.beginPath()
    ctx.ellipse(0, hy, 9.6, 9.2, 0, Math.PI * 1.02, Math.PI * 1.98)
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo(-8.6, hy - 2)
    ctx.quadraticCurveTo(-10.5, hy + 8, -6, hy + 12)
    ctx.stroke()
  } else {
    el(ctx, 0, hy, 8, 7.8, kulit)
    // rambut tepi
    ctx.fillStyle = shade('#3a2a1a', 0)
    ctx.beginPath()
    ctx.ellipse(0, hy - 3.2, 8, 5.2, 0, Math.PI, Math.PI * 2)
    ctx.fill()
    // topi rapi
    ctx.fillStyle = gaya.tutup
    ctx.beginPath()
    ctx.ellipse(0, hy - 3.6, 8.4, 5.4, 0, Math.PI, Math.PI * 2)
    ctx.fill()
    ctx.fillRect(-8.4, hy - 4.4, 16.8, 2.4)
  }

  // wajah
  ctx.fillStyle = '#2a2018'
  if (arah === 0) {
    el(ctx, -2.7, hy + 1.6, 1.15, 1.35, '#2a2018')
    el(ctx, 2.7, hy + 1.6, 1.15, 1.35, '#2a2018')
    ctx.strokeStyle = 'rgba(42,32,24,0.8)'
    ctx.lineWidth = 1
    ctx.beginPath()
    ctx.arc(0, hy + 3.4, 2.2, 0.15 * Math.PI, 0.85 * Math.PI)
    ctx.stroke()
  } else if (arah === 2) {
    el(ctx, -4.6, hy + 1.6, 1.15, 1.35, '#2a2018')
  } else if (arah === 3) {
    el(ctx, 4.6, hy + 1.6, 1.15, 1.35, '#2a2018')
  }

  // pipi
  if (arah !== 1) {
    ctx.fillStyle = 'rgba(230,120,110,0.35)'
    if (arah === 0) {
      el(ctx, -4.6, hy + 3.8, 1.7, 1.1, 'rgba(230,120,110,0.35)')
      el(ctx, 4.6, hy + 3.8, 1.7, 1.1, 'rgba(230,120,110,0.35)')
    }
  }

  ctx.restore()
}

/** Gambar perangkat di tangan saat aksi (dipanggil di engine saat animasi aksi) */
export function drawToolSwing(
  ctx: CanvasRenderingContext2D,
  x: number,
  y: number,
  scale: number,
  arah: Arah,
  fase: number,
  tool: string,
) {
  ctx.save()
  ctx.translate(x, y)
  ctx.scale(scale, scale)
  const p = Math.sin(fase * Math.PI)
  // titik pangkal lengan
  const ox = arah === 2 ? -10 : arah === 3 ? 10 : arah === 1 ? 8 : 9
  const oy = arah === 1 ? -30 : -22
  ctx.translate(ox, oy)
  ctx.rotate((arah === 2 ? -1 : 1) * (p * 1.3 - 0.5))
  if (tool === 'cangkur') {
    ctx.fillStyle = '#8a5a33'
    rr(ctx, -1.5, -14, 3, 16, 1.5)
    ctx.fillStyle = '#b0b6bd'
    ctx.beginPath()
    ctx.moveTo(-1.5, -14)
    ctx.quadraticCurveTo(-7, -10, -1.5, -5)
    ctx.quadraticCurveTo(4, -10, 1.5, -14)
    ctx.fill()
  } else if (tool === 'kapura') {
    ctx.fillStyle = '#8a5a33'
    rr(ctx, -1.5, -14, 3, 16, 1.5)
    ctx.fillStyle = '#b8bec5'
    ctx.beginPath()
    ctx.moveTo(0, -14)
    ctx.lineTo(8, -11)
    ctx.lineTo(8, -6)
    ctx.lineTo(0, -8)
    ctx.closePath()
    ctx.fill()
  } else if (tool === 'giliuk') {
    ctx.fillStyle = '#8a5a33'
    rr(ctx, -1.5, -14, 3, 16, 1.5)
    ctx.fillStyle = '#9aa0a8'
    ctx.beginPath()
    ctx.moveTo(0, -15)
    ctx.quadraticCurveTo(9, -13, 6, -8)
    ctx.lineTo(0, -11)
    ctx.quadraticCurveTo(-9, -13, -6, -8)
    ctx.lineTo(0, -11)
    ctx.fill()
  } else if (tool === 'panyukan') {
    ctx.strokeStyle = '#7a6a4f'
    ctx.lineWidth = 2.2
    ctx.beginPath()
    ctx.moveTo(0, 0)
    ctx.lineTo(10, -18)
    ctx.stroke()
    ctx.strokeStyle = 'rgba(240,240,240,0.8)'
    ctx.lineWidth = 1
    ctx.beginPath()
    ctx.moveTo(10, -18)
    ctx.lineTo(11, -4)
    ctx.stroke()
    el(ctx, 11, -2.6, 2.4, 2.4, '#e05a4a')
  }
  ctx.restore()
}

/* ================================ HEWAN ================================ */

export function drawAyumi(ctx: CanvasRenderingContext2D, x: number, y: number, t: number, warna: string) {
  ctx.save()
  ctx.translate(x, y)
  el(ctx, 0, 1, 9, 3.4, 'rgba(40,30,10,0.2)')
  const peck = Math.sin(t * 2.1) > 0.86 ? 1 : 0
  // kaki
  ctx.strokeStyle = '#d99a3c'
  ctx.lineWidth = 1.6
  ctx.beginPath()
  ctx.moveTo(-3, -4); ctx.lineTo(-3, 0)
  ctx.moveTo(3, -4); ctx.lineTo(3, 0)
  ctx.stroke()
  // badan
  el(ctx, 0, -7.5, 7.5, 6, warna)
  el(ctx, 3, -11.5, 4.4, 4, warna) // kepala
  // jengger
  el(ctx, 2.2, -15.2, 1.6, 2, '#d94a3a')
  // paruh
  ctx.fillStyle = '#e8a83c'
  ctx.beginPath()
  ctx.moveTo(7, -11.2)
  ctx.lineTo(10.4 - peck, -10 + peck)
  ctx.lineTo(7, -9.6)
  ctx.closePath()
  ctx.fill()
  // sayap
  ctx.fillStyle = shade(warna, -22)
  ctx.beginPath()
  ctx.ellipse(-1.5, -7, 4.6, 3.2, -0.25, 0, Math.PI * 2)
  ctx.fill()
  // mata
  el(ctx, 5, -12.4, 0.9, 0.9, '#2a2018')
  // ekor
  ctx.fillStyle = shade(warna, -30)
  ctx.beginPath()
  ctx.moveTo(-7, -8)
  ctx.lineTo(-10.5, -11)
  ctx.lineTo(-6.6, -5)
  ctx.closePath()
  ctx.fill()
  ctx.restore()
}

export function drawSapiyu(ctx: CanvasRenderingContext2D, x: number, y: number, t: number, flip: boolean) {
  ctx.save()
  ctx.translate(x, y)
  if (flip) ctx.scale(-1, 1)
  el(ctx, 0, 1, 16, 4.6, 'rgba(40,30,10,0.22)')
  const sway = Math.sin(t) * 0.15
  // kaki
  ctx.fillStyle = '#c8b49a'
  rr(ctx, -11, -8, 4, 8, 1.6)
  rr(ctx, -3, -8, 4, 8, 1.6)
  rr(ctx, 5, -8, 4, 8, 1.6)
  // badan
  ctx.fillStyle = '#f2e8d8'
  ctx.beginPath()
  ctx.ellipse(0, -13, 14, 7.5, 0, 0, Math.PI * 2)
  ctx.fill()
  // bercak
  ctx.fillStyle = '#a9714f'
  el(ctx, -5, -14.5, 4.6, 3, '#a9714f')
  el(ctx, 6, -11.5, 3.4, 2.4, '#a9714f')
  // kepala
  ctx.fillStyle = '#f2e8d8'
  el(ctx, 14, -14, 6, 5.4, '#f2e8d8')
  el(ctx, 17, -10.5, 3.4, 3, '#e8d0b8') // moncong
  el(ctx, 14.5, -16.5, 0.9, 0.9, '#2a2018')
  // tanduk kecil
  ctx.strokeStyle = '#d8c8a8'
  ctx.lineWidth = 2
  ctx.beginPath()
  ctx.moveTo(13, -18.5); ctx.lineTo(11, -21.5)
  ctx.stroke()
  // telinga
  el(ctx, 11, -15.5, 2.4, 1.4, '#e8d0b8')
  // ekor
  ctx.strokeStyle = '#c8b49a'
  ctx.lineWidth = 1.6
  ctx.beginPath()
  ctx.moveTo(-13.5, -13)
  ctx.quadraticCurveTo(-17 + sway * 8, -9, -16 + sway * 10, -4)
  ctx.stroke()
  el(ctx, -16 + sway * 10, -3.4, 1.6, 1.6, '#3a2a1a')
  ctx.restore()
}

export function drawNPC(ctx: CanvasRenderingContext2D, x: number, y: number, t: number) {
  const look: KarakterCfg = { kelamin: 'pria', kulit: 1, gaya: 1 }
  drawCharacter(ctx, x, y, 1, 0, Math.sin(t * 0.6) * 0.4, look)
  // balik barang di tangan
  el(ctx, x + 10, y - 14, 3, 3, '#e8b840')
}

/* ================================ POHON & BATU ================================ */

export function drawTree(
  ctx: CanvasRenderingContext2D,
  x: number,
  y: number,
  t: number,
  seed: number,
  tebas: number, // 0 utuh, 1 setengah (animasi goyang), 2 tunggul
) {
  ctx.save()
  ctx.translate(x, y)
  el(ctx, 0, 2, 13, 4.6, 'rgba(40,30,10,0.22)')
  const sway = Math.sin(t * 1.1 + seed * 3.7) * (tebas === 1 ? 4 : 1.6)
  if (tebas === 2) {
    // tunggul
    ctx.fillStyle = '#8a5a33'
    rr(ctx, -5, -8, 10, 9, 3)
    ctx.fillStyle = '#a9714f'
    el(ctx, 0, -8, 4.6, 2.2, '#c89868')
    ctx.restore()
    return
  }
  // batang
  ctx.fillStyle = '#7a5230'
  ctx.beginPath()
  ctx.moveTo(-3.6, 0)
  ctx.quadraticCurveTo(-2.6, -18, -2.8 - sway * 0.4, -30)
  ctx.lineTo(2.8 - sway * 0.4, -30)
  ctx.quadraticCurveTo(2.6, -18, 3.6, 0)
  ctx.closePath()
  ctx.fill()
  // tajuk tiga lapis
  const h = seed * 6
  const c1 = '#3e7d3a'
  const c2 = '#4f9e4a'
  const c3 = '#66b85e'
  el(ctx, sway, -34 - h, 15, 11, c1)
  el(ctx, sway - 8, -28 - h, 10.5, 8.5, c2)
  el(ctx, sway + 8, -29 - h, 10, 8, c2)
  el(ctx, sway - 2, -38 - h, 9, 7.5, c3)
  el(ctx, sway + 5, -36 - h, 7, 6, shade(c3, 14))
  // buah kecil
  if (seed > 0.5) {
    el(ctx, sway - 6, -32 - h, 1.8, 1.8, '#e8862f')
    el(ctx, sway + 7, -33 - h, 1.8, 1.8, '#e8862f')
  }
  ctx.restore()
}

export function drawRock(ctx: CanvasRenderingContext2D, x: number, y: number, seed: number) {
  ctx.save()
  ctx.translate(x, y)
  el(ctx, 0, 1.5, 11, 3.6, 'rgba(40,30,10,0.2)')
  ctx.fillStyle = '#9a9a94'
  ctx.beginPath()
  ctx.moveTo(-9, 0)
  ctx.quadraticCurveTo(-10, -8 + seed * 3, -3, -10 - seed * 3)
  ctx.quadraticCurveTo(6, -12, 9.5, -5)
  ctx.quadraticCurveTo(11, 0, 9, 1)
  ctx.closePath()
  ctx.fill()
  ctx.fillStyle = '#b4b4ac'
  el(ctx, -2, -6 - seed * 2, 4, 2.6, '#b4b4ac')
  ctx.fillStyle = '#7e7e78'
  el(ctx, 4, -3, 3, 1.6, '#7e7e78')
  ctx.restore()
}

/* ================================ TANAMAN ================================ */

export function drawCropPlant(
  ctx: CanvasRenderingContext2D,
  x: number,
  y: number,
  crop: CropDef,
  stage: number, // 0 kecambah, 1 tumbuh, 2 hampir, 3 matang
  t: number,
) {
  ctx.save()
  ctx.translate(x, y)
  const angin = Math.sin(t * 1.4 + x * 0.05) * 1.4
  const daun = crop.warnaDaun
  const buah = crop.warnaBuah
  if (stage === 0) {
    el(ctx, 0, -2.5, 1.6, 2.6, daun)
    el(ctx, -2.5, -3.5, 1.4, 1.4, shade(daun, 12))
    el(ctx, 2.5, -3.5, 1.4, 1.4, shade(daun, 12))
  } else if (stage === 1) {
    ctx.strokeStyle = daun
    ctx.lineWidth = 1.8
    ctx.beginPath()
    ctx.moveTo(0, 0)
    ctx.quadraticCurveTo(angin, -6, angin, -10)
    ctx.stroke()
    el(ctx, angin - 3, -9, 2.6, 1.8, daun)
    el(ctx, angin + 3, -8, 2.6, 1.8, daun)
  } else if (stage === 2) {
    ctx.strokeStyle = daun
    ctx.lineWidth = 2
    ctx.beginPath()
    ctx.moveTo(0, 0)
    ctx.quadraticCurveTo(angin, -8, angin, -14)
    ctx.stroke()
    el(ctx, angin - 4.5, -12, 3.6, 2.6, daun)
    el(ctx, angin + 4.5, -11, 3.6, 2.6, daun)
    el(ctx, angin, -16, 3.2, 2.4, shade(daun, 16))
    if (crop.hasil !== 'beraka' && crop.hasil !== 'lumira') el(ctx, angin, -10, 2.4, 2.4, buah)
  } else {
    // matang — bentuk khas per tanaman
    ctx.strokeStyle = daun
    ctx.lineWidth = 2.2
    ctx.beginPath()
    ctx.moveTo(0, 0)
    ctx.quadraticCurveTo(angin, -9, angin, -16)
    ctx.stroke()
    if (crop.hasil === 'lumira') {
      for (let i = -2; i <= 2; i++) {
        el(ctx, angin + i * 4, -14 - Math.abs(i) * -2, 3.4, 2.4, i % 2 === 0 ? daun : shade(daun, 18))
      }
      el(ctx, angin, -20, 3.6, 3, shade(buah, 6))
    } else if (crop.hasil === 'beraka') {
      for (let i = -2; i <= 2; i++) {
        el(ctx, angin + i * 3.4, -16 - Math.abs(i) * 1.4, 2.2, 3.4, buah)
      }
    } else if (crop.hasil === 'terunu') {
      el(ctx, 0, -5, 6.5, 5, buah)
      el(ctx, -2, -7, 2.6, 1.8, shade(buah, 26))
      el(ctx, angin - 5, -13, 3.4, 2.4, daun)
      el(ctx, angin + 5, -12, 3.4, 2.4, daun)
    } else if (crop.hasil === 'makira') {
      ctx.fillStyle = buah
      rr(ctx, angin - 3, -19, 6.4, 12, 3.2)
      ctx.fillStyle = shade(buah, -26)
      for (let i = 0; i < 3; i++) ctx.fillRect(angin - 2.6, -17.5 + i * 3.4, 5.4, 1.3)
      el(ctx, angin, -20.5, 2.6, 2, shade(daun, 20))
      el(ctx, angin - 5, -12, 3.4, 2.4, daun)
      el(ctx, angin + 5, -12, 3.4, 2.4, daun)
    } else if (crop.hasil === 'kopanu') {
      for (let i = -1; i <= 1; i++) {
        ctx.save()
        ctx.translate(angin + i * 5, -13 - Math.abs(i) * 2)
        ctx.rotate(i * 0.7)
        ctx.fillStyle = buah
        rr(ctx, -1.8, -5, 3.6, 10, 1.8)
        ctx.restore()
      }
      el(ctx, angin, -18, 3.4, 2.6, shade(daun, 16))
    } else {
      // sundara
      el(ctx, angin - 3.6, -12, 3, 3, buah)
      el(ctx, angin + 3.8, -15, 3, 3, shade(buah, 14))
      el(ctx, angin, -18.5, 3, 3, buah)
      el(ctx, angin, -21, 2.6, 2.2, shade(daun, 20))
    }
  }
  ctx.restore()
}

/* ================================ BANGUNAN ================================ */

export type JenisBangunan = 'rumah' | 'dapur' | 'kios' | 'kandang' | 'pondok'

export function drawBuilding(
  ctx: CanvasRenderingContext2D,
  bx: number,
  by: number,
  w: number,
  h: number,
  jenis: JenisBangunan,
) {
  // bx,by = pojok kiri atas dalam px; w,h = lebar tinggi px
  ctx.save()
  ctx.translate(bx, by)
  const roofH = h * 0.42
  const dinding = jenis === 'kandang' ? '#c89868' : jenis === 'pondok' ? '#d0a878' : '#efe3c4'
  const atap1 = jenis === 'rumah' ? '#c96f4a' : jenis === 'kios' ? '#b85a3e' : '#8a9e6a'
  const atap2 = shade(atap1, -38)
  const kayu = '#8a5a33'

  // dinding
  ctx.fillStyle = dinding
  ctx.fillRect(0, roofH - 6, w, h - roofH + 6)
  ctx.strokeStyle = 'rgba(90,60,30,0.25)'
  ctx.lineWidth = 2
  ctx.strokeRect(1, roofH - 5, w - 2, h - roofH + 4)

  // papan garis (untuk kandang/pondok)
  if (jenis === 'kandang' || jenis === 'pondok') {
    ctx.strokeStyle = shade(dinding, -30)
    ctx.lineWidth = 1.4
    for (let yy = roofH + 2; yy < h - 2; yy += 7) {
      ctx.beginPath()
      ctx.moveTo(3, yy)
      ctx.lineTo(w - 3, yy)
      ctx.stroke()
    }
  }

  // atap trapesium
  ctx.fillStyle = atap1
  ctx.beginPath()
  ctx.moveTo(-6, roofH)
  ctx.lineTo(w * 0.18, 0)
  ctx.lineTo(w * 0.82, 0)
  ctx.lineTo(w + 6, roofH)
  ctx.closePath()
  ctx.fill()
  ctx.fillStyle = atap2
  ctx.beginPath()
  ctx.moveTo(-6, roofH)
  ctx.lineTo(w + 6, roofH)
  ctx.lineTo(w + 2, roofH + 7)
  ctx.lineTo(-2, roofH + 7)
  ctx.closePath()
  ctx.fill()
  // garis genteng
  ctx.strokeStyle = shade(atap1, -22)
  ctx.lineWidth = 1.4
  for (let i = 1; i <= 3; i++) {
    const yy = (roofH / 4) * i
    ctx.beginPath()
    ctx.moveTo(-4 + i * 1.4, yy)
    ctx.lineTo(w + 4 - i * 1.4, yy)
    ctx.stroke()
  }

  // pintu
  const dw = w * 0.18
  const dx = w / 2 - dw / 2
  const dh = h - roofH - 4
  ctx.fillStyle = '#6b4226'
  rr(ctx, dx, h - dh, dw, dh, 4)
  ctx.fillStyle = shade('#6b4226', 24)
  el(ctx, dx + dw - 4, h - dh / 2 - 2, 1.6, 1.6, '#e8d8a8')

  // jendela
  const winY = roofH + 10
  const winW = w * 0.16
  const winH = h * 0.2
  for (const wx of [w * 0.12, w * 0.72]) {
    ctx.fillStyle = '#8fb8c8'
    rr(ctx, wx, winY, winW, winH, 3)
    ctx.strokeStyle = kayu
    ctx.lineWidth = 2
    ctx.strokeRect(wx, winY, winW, winH)
    ctx.beginPath()
    ctx.moveTo(wx + winW / 2, winY)
    ctx.lineTo(wx + winW / 2, winY + winH)
    ctx.moveTo(wx, winY + winH / 2)
    ctx.lineTo(wx + winW, winY + winH / 2)
    ctx.stroke()
  }

  // cerobong untuk dapur
  if (jenis === 'dapur') {
    ctx.fillStyle = '#9a9a94'
    ctx.fillRect(w * 0.7, -12, 8, 18)
    ctx.fillStyle = '#7e7e78'
    ctx.fillRect(w * 0.69, -14, 10, 4)
  }

  // papan nama
  if (jenis === 'kios') {
    ctx.fillStyle = '#e8d8a8'
    rr(ctx, w * 0.24, roofH - 16, w * 0.52, 14, 3)
    ctx.strokeStyle = kayu
    ctx.lineWidth = 2
    ctx.strokeRect(w * 0.24, roofH - 16, w * 0.52, 14)
    ctx.fillStyle = '#5a3a1a'
    ctx.font = 'bold 9px sans-serif'
    ctx.textAlign = 'center'
    ctx.fillText('KIOS DESA', w / 2, roofH - 5)
  }
  ctx.restore()
}

export function drawFencePost(ctx: CanvasRenderingContext2D, x: number, y: number, horizontal: boolean, t: number) {
  ctx.save()
  ctx.translate(x, y)
  el(ctx, 0, 1, 5, 2, 'rgba(40,30,10,0.18)')
  ctx.fillStyle = '#a97142'
  rr(ctx, -2.2, -16, 4.4, 17, 1.8)
  ctx.strokeStyle = '#8a5a33'
  ctx.lineWidth = 2.4
  if (horizontal) {
    ctx.beginPath()
    ctx.moveTo(-24, -11)
    ctx.lineTo(24, -11)
    ctx.moveTo(-24, -5)
    ctx.lineTo(24, -5)
    ctx.stroke()
  }
  void t
  ctx.restore()
}

/* ================================ IKON ITEM ================================ */

const iconCache = new Map<ItemId, string>()

function paintIcon(ctx: CanvasRenderingContext2D, id: ItemId) {
  ctx.clearRect(0, 0, 64, 64)
  ctx.save()
  ctx.translate(32, 34)
  const C = (n: string) => n
  switch (id) {
    case 'cangkur':
      ctx.fillStyle = '#8a5a33'; rr(ctx, -2, -4, 4, 24, 2)
      ctx.fillStyle = '#b0b6bd'; ctx.beginPath(); ctx.moveTo(-2, -4); ctx.quadraticCurveTo(-12, 2, -2, 8); ctx.quadraticCurveTo(8, 2, 2, -4); ctx.fill()
      break
    case 'kapura':
      ctx.fillStyle = '#8a5a33'; rr(ctx, -2, -6, 4, 26, 2)
      ctx.fillStyle = '#b8bec5'; ctx.beginPath(); ctx.moveTo(0, -6); ctx.lineTo(12, -2); ctx.lineTo(12, 6); ctx.lineTo(0, 2); ctx.closePath(); ctx.fill()
      break
    case 'giliuk':
      ctx.fillStyle = '#8a5a33'; rr(ctx, -2, -6, 4, 26, 2)
      ctx.fillStyle = '#9aa0a8'; ctx.beginPath(); ctx.moveTo(0, -8); ctx.quadraticCurveTo(14, -4, 10, 4); ctx.lineTo(0, 0); ctx.quadraticCurveTo(-14, -4, -10, 4); ctx.lineTo(0, 0); ctx.fill()
      break
    case 'panyukan':
      ctx.strokeStyle = '#7a6a4f'; ctx.lineWidth = 3.4; ctx.beginPath(); ctx.moveTo(-10, 14); ctx.lineTo(10, -16); ctx.stroke()
      ctx.strokeStyle = 'rgba(240,240,240,0.9)'; ctx.lineWidth = 1.6; ctx.beginPath(); ctx.moveTo(10, -16); ctx.lineTo(12, 0); ctx.stroke()
      el(ctx, 12, 3, 3.4, 3.4, '#e05a4a')
      break
    case 'pakanu':
      ctx.fillStyle = '#c9a35a'; rr(ctx, -10, -12, 20, 26, 6)
      ctx.fillStyle = '#a9823c'; ctx.fillRect(-10, -2, 20, 4)
      ctx.fillStyle = '#e8d8a8'; el(ctx, -3, -6, 2.6, 2.6, '#e8d8a8'); el(ctx, 4, -6, 2.6, 2.6, '#e8d8a8')
      break
    case 'telur_ayumi':
      ctx.fillStyle = '#f2e3c2'; ctx.beginPath(); ctx.ellipse(0, 0, 10, 13, 0, 0, Math.PI * 2); ctx.fill()
      el(ctx, -3, -5, 3.4, 4.4, 'rgba(255,255,255,0.75)')
      break
    case 'susu_sapiyu':
      ctx.fillStyle = '#f7f3e8'; rr(ctx, -8, -12, 16, 26, 5)
      ctx.fillStyle = '#e8e0cc'; rr(ctx, -6, -16, 12, 6, 2)
      ctx.fillStyle = '#c96f4a'; ctx.fillRect(-8, 0, 16, 5)
      break
    case 'balanu':
      ctx.fillStyle = '#a97142'; rr(ctx, -14, -5, 28, 10, 5)
      ctx.fillStyle = '#c89868'; el(ctx, 14, 0, 5, 5, '#c89868')
      el(ctx, 14, 0, 2.6, 2.6, '#8a5a33')
      break
    case 'batuku':
      ctx.fillStyle = '#9a9a94'; ctx.beginPath(); ctx.moveTo(-12, 8); ctx.quadraticCurveTo(-14, -6, -2, -10); ctx.quadraticCurveTo(12, -12, 13, 0); ctx.quadraticCurveTo(12, 10, -2, 10); ctx.closePath(); ctx.fill()
      el(ctx, -2, -4, 5, 3.4, '#b4b4ac')
      break
    case 'ikana':
    case 'silara':
    case 'kiraya': {
      const fc = id === 'ikana' ? '#8fa8b8' : id === 'silara' ? '#c8d8e0' : '#e8b840'
      ctx.fillStyle = fc
      ctx.beginPath()
      ctx.ellipse(0, 0, 13, 7.5, 0, 0, Math.PI * 2)
      ctx.fill()
      ctx.beginPath()
      ctx.moveTo(11, 0); ctx.lineTo(18, -6); ctx.lineTo(18, 6); ctx.closePath(); ctx.fill()
      el(ctx, -6, -2, 1.6, 1.6, '#2a2018')
      break
    }
    case 'tumis_lumira':
    case 'sup_sundara':
    case 'bubur_beraka':
    case 'makira_rebus':
    case 'kue_kopanu':
    case 'panggang_terunu': {
      // piring dengan lauk
      el(ctx, 0, 6, 18, 6, '#e8e2d4')
      ctx.fillStyle = ITEMS[id]?.warna ?? '#c8a860'
      el(ctx, 0, 2, 12, 7, C(ctx.fillStyle as string))
      el(ctx, -4, 0, 5, 3, 'rgba(255,255,255,0.35)')
      el(ctx, 5, 3, 3.4, 2.4, 'rgba(0,0,0,0.14)')
      break
    }
    default: {
      const def = ITEMS[id]
      if (!def) break
      if (def.kategori === 'benih') {
        // kantong benih
        ctx.fillStyle = '#d8c8a0'
        ctx.beginPath(); ctx.moveTo(-10, 10); ctx.quadraticCurveTo(-12, -6, 0, -10); ctx.quadraticCurveTo(12, -6, 10, 10); ctx.closePath(); ctx.fill()
        ctx.strokeStyle = '#a9823c'; ctx.lineWidth = 2
        ctx.beginPath(); ctx.moveTo(-9, -6); ctx.quadraticCurveTo(0, -14, 9, -6); ctx.stroke()
        el(ctx, 0, 2, 4, 4.6, def.warna)
        el(ctx, -4.5, 4, 2.4, 2.8, shade(def.warna, -18))
        el(ctx, 4.5, 4, 2.4, 2.8, shade(def.warna, 22))
      } else {
        // hasil panen generik sesuai warna
        ctx.fillStyle = def.warna
        el(ctx, 0, 0, 10.5, 10.5, def.warna)
        el(ctx, -3.5, -3.5, 3.4, 2.6, 'rgba(255,255,255,0.4)')
        if (def.kategori === 'hasil') {
          ctx.strokeStyle = '#4f9e3c'
          ctx.lineWidth = 2.4
          ctx.beginPath(); ctx.moveTo(0, -9); ctx.quadraticCurveTo(4, -14, 8, -14); ctx.stroke()
        }
      }
      break
    }
  }
  ctx.restore()
}

export function itemIconURL(id: ItemId): string {
  const cached = iconCache.get(id)
  if (cached) return cached
  if (typeof document === 'undefined') return ''
  const cv = document.createElement('canvas')
  cv.width = 64
  cv.height = 64
  const ctx = cv.getContext('2d')
  if (!ctx) return ''
  paintIcon(ctx, id)
  const url = cv.toDataURL('image/png')
  iconCache.set(id, url)
  return url
}

/** Pratinjau karakter besar untuk layar pembuatan karakter */
export function drawCharacterPreview(ctx: CanvasRenderingContext2D, w: number, h: number, look: KarakterCfg) {
  ctx.clearRect(0, 0, w, h)
  ctx.fillStyle = '#e9dfc8'
  rr(ctx, 0, 0, w, h, 16)
  ctx.fillStyle = '#d8ccb0'
  el(ctx, w / 2, h - 26, w / 3.2, 12, '#d8ccb0')
  el(ctx, w / 2, h - 34, 3, 3, '#c9a35a')
  el(ctx, w / 2 - 14, h - 30, 3, 3, '#c9a35a')
  el(ctx, w / 2 + 14, h - 30, 3, 3, '#c9a35a')
  drawCharacter(ctx, w / 2, h - 30, 3.4, 0, 0, look)
}
