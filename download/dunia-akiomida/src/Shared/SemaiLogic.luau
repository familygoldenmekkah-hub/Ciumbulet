local SemaiLogic = {}

SemaiLogic.KabelMin = 4
SemaiLogic.KabelMaks = 6
SemaiLogic.WarnaKabel = {
        { 214, 64, 56 },
        { 76, 168, 82 },
        { 58, 122, 214 },
        { 240, 196, 60 },
        { 168, 92, 224 },
        { 240, 138, 44 },
        { 60, 190, 190 },
        { 232, 92, 150 },
}

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

function SemaiLogic.gulung(rng: any, cfg: any, jumlah: number): { micda: number, benih: number, blok: number }
        local jml = math.max(1, math.floor(jumlah))
        local mMin = 1
        local mMax = 1
        local pBenih = 0
        local pBlok = 0
        if type(cfg) == "table" then
                mMin = type(cfg.micdaMin) == "number" and math.max(0, cfg.micdaMin) or 1
                mMax = type(cfg.micdaMax) == "number" and math.max(mMin, cfg.micdaMax) or mMin
                pBenih = type(cfg.seed) == "number" and cfg.seed or 0
                pBlok = type(cfg.blok) == "number" and cfg.blok or 0
        end
        local micda = 0
        local benih = 0
        local blok = 0
        for _ = 1, jml do
                micda += rng:NextInteger(mMin, mMax)
                if rng:NextNumber() < pBenih then
                        benih += 1
                end
                if rng:NextNumber() < pBlok then
                        blok += 1
                end
        end
        return { micda = micda, benih = benih, blok = blok }
end

local function acakUrutan(rng: any, daftar: { number }): { number }
        local out = {}
        for i, v in ipairs(daftar) do
                out[i] = v
        end
        for i = #out, 2, -1 do
                local j = rng:NextInteger(1, i)
                local tmp = out[i]
                out[i] = out[j]
                out[j] = tmp
        end
        return out
end

function SemaiLogic.buatKabel(rng: any): { n: number, kiri: { number }, kanan: { number } }
        local palet = {}
        for i = 1, #SemaiLogic.WarnaKabel do
                table.insert(palet, i)
        end
        local pilihan = acakUrutan(rng, palet)
        local n = rng:NextInteger(SemaiLogic.KabelMin, SemaiLogic.KabelMaks)
        if n > #pilihan then
                n = #pilihan
        end
        local kiri = {}
        for i = 1, n do
                kiri[i] = pilihan[i]
        end
        local kanan = acakUrutan(rng, kiri)
        return { n = n, kiri = kiri, kanan = kanan }
end

function SemaiLogic.saringSambung(kabel: any, masuk: any): { [number]: number }?
        if type(kabel) ~= "table" or type(masuk) ~= "table" then
                return nil
        end
        local n = kabel.n
        if type(n) ~= "number" or n ~= n or n % 1 ~= 0 or n < 1 then
                return nil
        end
        local out = {}
        for i = 1, n do
                local t = masuk[i]
                if type(t) ~= "number" or t ~= t or t % 1 ~= 0 or t < 1 or t > n then
                        return nil
                end
                out[i] = t
        end
        return out
end

function SemaiLogic.putuskanKabel(kabel: any, masuk: any, salah: number, rng: any): (string, any, number)
        local hitung = type(salah) == "number" and salah or 0
        local sambung = SemaiLogic.saringSambung(kabel, masuk)
        if sambung and SemaiLogic.kabelSelesai(kabel, sambung) then
                return "jodoh", kabel, 0
        end
        hitung += 1
        if hitung >= 3 then
                return "acak_ulang", SemaiLogic.buatKabel(rng), 0
        end
        return "salah", kabel, hitung
end

function SemaiLogic.kabelSelesai(kabel: any, sambung: any): boolean
        if type(kabel) ~= "table" or type(sambung) ~= "table" then
                return false
        end
        local kiri = kabel.kiri
        local kanan = kabel.kanan
        if type(kiri) ~= "table" or type(kanan) ~= "table" or kabel.n ~= #kiri or kabel.n ~= #kanan or kabel.n < 1 then
                return false
        end
        local dipakai = {}
        for i = 1, kabel.n do
                local t = sambung[i]
                if type(t) ~= "number" or t ~= math.floor(t) or t < 1 or t > kabel.n or dipakai[t] then
                        return false
                end
                if kiri[i] ~= kanan[t] then
                        return false
                end
                dipakai[t] = true
        end
        return true
end

return SemaiLogic
