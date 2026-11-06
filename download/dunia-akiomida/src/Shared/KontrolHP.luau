local KontrolHP = {}

KontrolHP.JumpSkala = 0.19
KontrolHP.PunchSkala = 0.175
KontrolHP.RasioPunch = KontrolHP.PunchSkala / KontrolHP.JumpSkala
KontrolHP.InsetSkala = 0.032
KontrolHP.GapSkala = 0.02
KontrolHP.GapMinPx = 12
KontrolHP.GapMaksPx = 20
KontrolHP.Anggaran = 0.45
KontrolHP.AnggaranKeras = 0.62
KontrolHP.BesarMin = 0.8
KontrolHP.BesarMaks = 1.0
KontrolHP.ZonaTanamX = 0.25
KontrolHP.ZonaTanamLebar = 0.35
KontrolHP.ZonaTanamY = 0.2
KontrolHP.ZonaTanamTinggi = 0.6
KontrolHP.ZonaJempolX = 0.45
KontrolHP.ZonaJempolY = 0.55

function KontrolHP.ukuranJump(vpX: number, vpY: number, jumpPx: number?): number
        if type(jumpPx) == "number" and jumpPx > 0 then
                return jumpPx
        end
        return KontrolHP.JumpSkala * math.min(vpX, vpY)
end

function KontrolHP.ukuranGap(vpX: number, vpY: number): number
        local g = KontrolHP.GapSkala * math.min(vpX, vpY)
        return math.clamp(g, KontrolHP.GapMinPx, KontrolHP.GapMaksPx)
end

function KontrolHP.posisiPunch(vpX: number, vpY: number, jumpPx: number?): { [string]: number }
        local j = KontrolHP.ukuranJump(vpX, vpY, jumpPx)
        local p = j * KontrolHP.RasioPunch
        local dasar = math.min(vpX, vpY)
        local inset = KontrolHP.InsetSkala * dasar
        local gap = KontrolHP.ukuranGap(vpX, vpY)
        local anggaran = KontrolHP.Anggaran * vpX
        local dariKanan = inset + j + gap + p
        if dariKanan > anggaran then
                gap = KontrolHP.GapMinPx
                dariKanan = inset + j + gap + p
                if dariKanan > anggaran then
                        local pBaru = math.max(KontrolHP.BesarMin * j, anggaran - inset - j - gap)
                        dariKanan -= p - pBaru
                        p = pBaru
                end
        end
        dariKanan = math.min(dariKanan, KontrolHP.AnggaranKeras * vpX)
        return {
                skalaX = 1 - dariKanan / vpX,
                skalaY = 1 - inset / vpY,
                skalaLebar = p / vpX,
                skalaTinggi = p / vpY,
                gapPx = gap,
                jumpPx = j,
                punchPx = p,
                dariKananPx = dariKanan,
                dariBawahPx = inset,
        }
end

function KontrolHP.rectJump(vpX: number, vpY: number, jumpPx: number?): { [string]: number }
        local j = KontrolHP.ukuranJump(vpX, vpY, jumpPx)
        local inset = KontrolHP.InsetSkala * math.min(vpX, vpY)
        return { x = vpX - inset - j, y = vpY - inset - j, w = j, h = j }
end

function KontrolHP.rectPunch(vpX: number, vpY: number, jumpPx: number?): { [string]: number }
        local pos = KontrolHP.posisiPunch(vpX, vpY, jumpPx)
        return { x = vpX - pos.dariKananPx, y = vpY - pos.dariBawahPx - pos.punchPx, w = pos.punchPx, h = pos.punchPx }
end

function KontrolHP.zonaTanam(vpX: number, vpY: number): { [string]: number }
        return {
                x = KontrolHP.ZonaTanamX * vpX,
                y = KontrolHP.ZonaTanamY * vpY,
                w = KontrolHP.ZonaTanamLebar * vpX,
                h = KontrolHP.ZonaTanamTinggi * vpY,
        }
end

function KontrolHP.tumpangTindih(a: { [string]: number }, b: { [string]: number }): boolean
        return a.x < b.x + b.w and b.x < a.x + a.w and a.y < b.y + b.h and b.y < a.y + a.h
end

function KontrolHP.valid(vpX: number, vpY: number, jumpPx: number?): (boolean, string)
        local pos = KontrolHP.posisiPunch(vpX, vpY, jumpPx)
        local pp = KontrolHP.rectPunch(vpX, vpY, jumpPx)
        local pj = KontrolHP.rectJump(vpX, vpY, jumpPx)
        if pp.x < 0 or pp.y < 0 or pp.x + pp.w > vpX + 0.5 or pp.y + pp.h > vpY + 0.5 then
                return false, "keluar layar"
        end
        local rasio = pos.punchPx / pos.jumpPx
        if rasio < KontrolHP.BesarMin - 0.001 or rasio > KontrolHP.BesarMaks + 0.001 then
                return false, "ukuran punch vs jump"
        end
        if pos.gapPx < KontrolHP.GapMinPx - 0.01 or pos.gapPx > KontrolHP.GapMaksPx + 0.5 then
                return false, "jarak punch-jump"
        end
        if pos.dariKananPx > KontrolHP.AnggaranKeras * vpX + 0.5 then
                return false, "molor dari jempol"
        end
        if KontrolHP.tumpangTindih(pp, pj) then
                return false, "menimpa jump"
        end
        if math.abs((pp.y + pp.h) - (pj.y + pj.h)) > 0.5 then
                return false, "dasar tidak segaris"
        end
        local cx = pp.x + pp.w / 2
        local cy = pp.y + pp.h / 2
        if cx < KontrolHP.ZonaJempolX * vpX or cy < KontrolHP.ZonaJempolY * vpY then
                return false, "di luar area jempol"
        end
        if KontrolHP.tumpangTindih(pp, KontrolHP.zonaTanam(vpX, vpY)) then
                return false, "menutupi area tanam"
        end
        return true, "ok"
end

return KontrolHP
