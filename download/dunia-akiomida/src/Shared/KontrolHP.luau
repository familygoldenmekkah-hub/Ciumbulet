local KontrolHP = {}

KontrolHP.Margin = 24
KontrolHP.DariBawah = 24
KontrolHP.JumpBawaan = 70
KontrolHP.PunchBawaan = 92
KontrolHP.BatasJempol = 380

function KontrolHP.posisiPunch(jumpSize: number?, punchSize: number?, margin: number?): { gap: number, dariKanan: number, dariBawah: number }
        local j = type(jumpSize) == "number" and jumpSize or KontrolHP.JumpBawaan
        local p = type(punchSize) == "number" and punchSize or KontrolHP.PunchBawaan
        local m = type(margin) == "number" and margin or KontrolHP.Margin
        local gap = j
        return { gap = gap, dariKanan = m + j + gap + p, dariBawah = KontrolHP.DariBawah }
end

function KontrolHP.valid(dariKanan: number, jumpSize: number, punchSize: number, margin: number?): boolean
        local m = type(margin) == "number" and margin or KontrolHP.Margin
        local gap = dariKanan - m - jumpSize - punchSize
        if gap < jumpSize then
                return false
        end
        local batas = math.max(KontrolHP.BatasJempol, m + 2 * jumpSize + 2 * punchSize)
        if dariKanan + punchSize > batas then
                return false
        end
        return true
end

function KontrolHP.dariTombol(jumpKiriDariKanan: number, punchSize: number?, jumpSize: number?): number
        local p = type(punchSize) == "number" and punchSize or KontrolHP.PunchBawaan
        local j = type(jumpSize) == "number" and jumpSize or KontrolHP.JumpBawaan
        local gap = math.max(j, KontrolHP.JumpBawaan)
        local dariKanan = jumpKiriDariKanan + gap + p
        if dariKanan + p > KontrolHP.BatasJempol then
                dariKanan = KontrolHP.BatasJempol - p
        end
        return dariKanan
end

return KontrolHP
