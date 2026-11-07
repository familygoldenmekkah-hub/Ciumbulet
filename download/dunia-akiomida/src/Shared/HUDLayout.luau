local HUDLayout = {}

HUDLayout.SaldoSkalaX = 0.012
HUDLayout.SaldoSkalaY = 0.02
HUDLayout.SaldoSkalaLebar = 0.26
HUDLayout.SaldoSkalaTinggi = 0.085
HUDLayout.SaldoLebarMin = 150
HUDLayout.SaldoLebarMaks = 560
HUDLayout.SaldoPadX = 8
HUDLayout.SaldoGapX = 8
HUDLayout.SaldoIkonPx = 26
HUDLayout.SaldoTeksPx = 22
HUDLayout.SaldoSatuanPx = 15
HUDLayout.SaldoEm = 0.62
HUDLayout.IkonSkalaX = 0.035
HUDLayout.IkonSkalaY = 0.14
HUDLayout.IkonSkalaLebar = 0.15
HUDLayout.IkonSkalaTinggi = 0.72
HUDLayout.AngkaSkalaX = 0.215
HUDLayout.AngkaSkalaLebar = 0.53
HUDLayout.SatuanSkalaX = 0.775
HUDLayout.SatuanSkalaLebar = 0.21
HUDLayout.NavSkalaY = 0.125
HUDLayout.NavGapSkala = 0.02
HUDLayout.NavSkalaLebarMin = 0.185
HUDLayout.NavSkalaLebarMaks = 0.34
HUDLayout.NavSkalaTinggi = 0.072
HUDLayout.NavTinggiMin = 26
HUDLayout.NavTinggiMaks = 52
HUDLayout.NavIsiPx = 24
HUDLayout.NavTambahanMaks = 40
HUDLayout.TasSkalaLebar = 0.17
HUDLayout.TasLebarMin = 90
HUDLayout.TasLebarMaks = 200
HUDLayout.TeksMaks = 22
HUDLayout.TeksMin = 11

function HUDLayout.areaAman(vpX: number, vpY: number, insetKiri: number, insetAtas: number): { [string]: number }
        local kiri = math.clamp(insetKiri or 0, 0, vpX)
        local atas = math.clamp(insetAtas or 0, 0, vpY)
        return {
                kiri = kiri,
                atas = atas,
                lebar = math.max(vpX - kiri, 0),
                tinggi = math.max(vpY - atas, 0),
        }
end

function HUDLayout.batasSaldo(aman: { [string]: number }): { [string]: number }
        local lebar = math.clamp(aman.lebar * HUDLayout.SaldoSkalaLebar, HUDLayout.SaldoLebarMin, HUDLayout.SaldoLebarMaks)
        local tinggi = aman.tinggi * HUDLayout.SaldoSkalaTinggi
        return { lebar = lebar, tinggi = tinggi }
end

function HUDLayout.rectSaldo(vpX: number, vpY: number, insetKiri: number, insetAtas: number): { [string]: number }
        local aman = HUDLayout.areaAman(vpX, vpY, insetKiri, insetAtas)
        local b = HUDLayout.batasSaldo(aman)
        return {
                x = aman.kiri + aman.lebar * HUDLayout.SaldoSkalaX,
                y = aman.atas + aman.tinggi * HUDLayout.SaldoSkalaY,
                w = b.lebar,
                h = b.tinggi,
        }
end

function HUDLayout.lebarTeksPx(teks: any, ukuran: number): number
        if type(teks) ~= "string" then
                return 0
        end
        return math.max(1, math.floor(#teks * ukuran * HUDLayout.SaldoEm + 0.5))
end

function HUDLayout.lebarSaldoPx(teksAngka: any, adaSatuan: boolean): number
        local w = HUDLayout.SaldoPadX * 2 + HUDLayout.SaldoIkonPx + HUDLayout.SaldoGapX * 2
                + HUDLayout.lebarTeksPx(teksAngka, HUDLayout.SaldoTeksPx)
        if adaSatuan then
                w += HUDLayout.lebarTeksPx("Micda", HUDLayout.SaldoSatuanPx)
        end
        return math.clamp(w, HUDLayout.SaldoLebarMin, HUDLayout.SaldoLebarMaks)
end

function HUDLayout.muatLayar(vpX: number, teksAngka: any, adaSatuan: boolean, insetKiri: number): boolean
        local kiri = math.clamp(insetKiri or 0, 0, vpX)
        local x0 = kiri + (vpX - kiri) * HUDLayout.SaldoSkalaX
        return x0 + HUDLayout.lebarSaldoPx(teksAngka, adaSatuan) <= vpX + 0.5
end

function HUDLayout.batasNav(aman: { [string]: number }): { [string]: number }
        local minim = aman.lebar * HUDLayout.NavSkalaLebarMin
        local maks = math.max(aman.lebar * HUDLayout.NavSkalaLebarMaks, minim + HUDLayout.NavTambahanMaks)
        local tinggi = math.clamp(aman.tinggi * HUDLayout.NavSkalaTinggi, HUDLayout.NavTinggiMin, HUDLayout.NavTinggiMaks)
        return { minim = minim, maks = maks, tinggi = tinggi }
end

function HUDLayout.batasTas(aman: { [string]: number }): { [string]: number }
        local lebar = math.clamp(aman.lebar * HUDLayout.TasSkalaLebar, HUDLayout.TasLebarMin, HUDLayout.TasLebarMaks)
        return { lebar = lebar, tinggi = aman.tinggi * HUDLayout.SaldoSkalaTinggi }
end

function HUDLayout.rectNav(vpX: number, vpY: number, insetKiri: number, insetAtas: number, teksLebarPx: number): { [string]: number }
        local aman = HUDLayout.areaAman(vpX, vpY, insetKiri, insetAtas)
        local b = HUDLayout.batasNav(aman)
        local w = math.clamp((teksLebarPx or 0) + HUDLayout.NavIsiPx, b.minim, b.maks)
        local terpotong = (teksLebarPx or 0) + HUDLayout.NavIsiPx > b.maks
        return {
                x = aman.kiri + aman.lebar * HUDLayout.SaldoSkalaX,
                y = aman.atas + aman.tinggi * HUDLayout.NavSkalaY,
                w = w,
                h = b.tinggi,
                terpotong = terpotong,
                minim = b.minim,
                maks = b.maks,
        }
end

function HUDLayout.diDalam(dalam: { [string]: number }, luar: { [string]: number }): boolean
        return dalam.x >= luar.x and dalam.y >= luar.y and dalam.x + dalam.w <= luar.x + luar.w and dalam.y + dalam.h <= luar.y + luar.h
end

function HUDLayout.tumpangTindih(a: { [string]: number }, b: { [string]: number }): boolean
        return a.x < b.x + b.w and b.x < a.x + a.w and a.y < b.y + b.h and b.y < a.y + a.h
end

return HUDLayout
