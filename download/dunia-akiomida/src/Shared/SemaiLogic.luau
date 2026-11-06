local SemaiLogic = {}

SemaiLogic.UrutanTuas = { "kanan", "kiri" }

function SemaiLogic.saringJumlah(teks: any, dimiliki: any, kapasitas: number): number?
        if type(teks) ~= "string" and type(teks) ~= "number" then
                return nil
        end
        local n = tonumber(teks)
        if not n or n ~= n or n % 1 ~= 0 or n < 1 then
                return nil
        end
        n = math.floor(n)
        if type(dimiliki) ~= "number" or dimiliki < 1 then
                return nil
        end
        local maks = math.floor(dimiliki)
        if type(kapasitas) == "number" and kapasitas >= 1 and maks > kapasitas then
                maks = math.floor(kapasitas)
        end
        if n > maks then
                n = maks
        end
        if n < 1 then
                return nil
        end
        return n
end

function SemaiLogic.pukulanPerItem(cfg: any): number
        if type(cfg) ~= "table" or type(cfg.hits) ~= "number" or cfg.hits < 1 then
                return 1
        end
        return math.floor(cfg.hits)
end

function SemaiLogic.pukulanTotal(jumlah: number, perItem: number): number
        return math.floor(jumlah) * math.floor(perItem)
end

function SemaiLogic.gulung(rng: any, cfg: any, jumlah: number): { micda: number, benih: number }
        local jml = math.max(1, math.floor(jumlah))
        local mMin = 1
        local mMax = 1
        local pBenih = 0
        if type(cfg) == "table" then
                mMin = type(cfg.micdaMin) == "number" and math.max(0, cfg.micdaMin) or 1
                mMax = type(cfg.micdaMax) == "number" and math.max(mMin, cfg.micdaMax) or mMin
                pBenih = type(cfg.seed) == "number" and cfg.seed or 0
        end
        local micda = 0
        local benih = 0
        for _ = 1, jml do
                micda += rng:NextInteger(mMin, mMax)
                if rng:NextNumber() < pBenih then
                        benih += 1
                end
        end
        return { micda = micda, benih = benih }
end

function SemaiLogic.tuasBaru(): { kanan: boolean, kiri: boolean }
        return { kanan = false, kiri = false }
end

function SemaiLogic.saringSisi(sisi: any): string?
        if sisi == "kanan" or sisi == "kiri" then
                return sisi
        end
        return nil
end

function SemaiLogic.tuasBerikut(tuas: any): string?
        if type(tuas) ~= "table" then
                return nil
        end
        if tuas.kanan ~= true then
                return "kanan"
        end
        if tuas.kiri ~= true then
                return "kiri"
        end
        return nil
end

function SemaiLogic.tuasSelesai(tuas: any): boolean
        return type(tuas) == "table" and tuas.kanan == true and tuas.kiri == true
end

function SemaiLogic.prosesTekan(tuas: any, sisi: any): (boolean, string)
        local sisiBersih = SemaiLogic.saringSisi(sisi)
        if not sisiBersih then
                return false, "sisi"
        end
        if type(tuas) ~= "table" then
                return false, "tuas"
        end
        if tuas[sisiBersih] == true then
                return false, "sudah"
        end
        local berikut = SemaiLogic.tuasBerikut(tuas)
        if berikut ~= sisiBersih then
                return false, "urutan"
        end
        tuas[sisiBersih] = true
        return true, "ok"
end

return SemaiLogic
