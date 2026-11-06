local PukulAnim = {}

PukulAnim.Durasi = 0.32
PukulAnim.MomenKena = 0.12
PukulAnim.Ayunan = 1.55

export type Fase = { memukul: boolean, kena: boolean, p: number, sudut: number }

function PukulAnim.fase(t0: number, t: number): Fase
        local dt = t - t0
        if dt < 0 or dt > PukulAnim.Durasi then
                return { memukul = false, kena = false, p = 0, sudut = 0 }
        end
        local p = dt / PukulAnim.Durasi
        local gel = math.sin(p * math.pi)
        return {
                memukul = true,
                kena = dt >= PukulAnim.MomenKena,
                p = p,
                sudut = gel * PukulAnim.Ayunan,
        }
end

function PukulAnim.mulaiUlang(t0Lama: number?, t: number): number
        return t
end

function PukulAnim.getar(tier: number): number
        local t = tier or 1
        if t < 1 then
                t = 1
        elseif t > 3 then
                t = 3
        end
        return 0.35 + 0.25 * (t - 1)
end

return PukulAnim
