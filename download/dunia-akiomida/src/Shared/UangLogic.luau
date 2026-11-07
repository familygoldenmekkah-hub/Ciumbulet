local UangLogic = {}

UangLogic.MaksSaldo = 1000000000000000
UangLogic.BatasLedger = 24

UangLogic.Alasan = {
        jual_hasil = true,
        beli_benih = true,
        semai_hasil = true,
        hadiah = true,
        trade = true,
}

function UangLogic.baru(saldoAwal: number): any
        local m = math.max(0, math.floor(tonumber(saldoAwal) or 0))
        if m > UangLogic.MaksSaldo then
                m = UangLogic.MaksSaldo
        end
        return {
                m = m,
                ledger = {},
        }
end

function UangLogic.sah(nilai: any): boolean
        if type(nilai) ~= "number" or nilai ~= nilai or nilai == math.huge or nilai == -math.huge then
                return false
        end
        if nilai <= 0 or nilai ~= math.floor(nilai) then
                return false
        end
        return true
end

function UangLogic.alasanOk(reason: any): boolean
        if type(reason) ~= "string" then
                return false
        end
        return UangLogic.Alasan[reason] == true
end

function UangLogic.format(n: number): string
        if type(n) ~= "number" or n ~= n or n == math.huge or n == -math.huge then
                return tostring(n)
        end
        local neg = n < 0
        local v = math.floor(math.abs(n))
        local parts = {}
        repeat
                table.insert(parts, 1, string.format("%03d", v % 1000))
                v = math.floor(v / 1000)
        until v == 0
        parts[1] = tostring(tonumber(parts[1]))
        return (neg and "-" or "") .. table.concat(parts, ".")
end

function UangLogic.saldo(st: any): number
        if type(st) ~= "table" or type(st.m) ~= "number" then
                return 0
        end
        return st.m
end

function UangLogic.ruangSisa(st: any): number
        local sisa = UangLogic.MaksSaldo - UangLogic.saldo(st)
        if sisa < 0 then
                return 0
        end
        return sisa
end

local function catat(st: any, now: number, delta: number, reason: string)
        table.insert(st.ledger, { t = math.floor(now), d = delta, r = reason, s = "ok" })
        while #st.ledger > UangLogic.BatasLedger do
                table.remove(st.ledger, 1)
        end
end

local function gerbang(st: any, amount: any, reason: any, arah: string): (boolean, string)
        if not UangLogic.sah(amount) then
                return false, "Jumlah Micda tidak sah."
        end
        if not UangLogic.alasanOk(reason) then
                return false, "Alasan transaksi tidak sah."
        end
        if arah == "masuk" then
                local sisa = UangLogic.ruangSisa(st)
                if sisa < 1 then
                        return false, "Rekening Micda sudah penuh! Batas maksimal " .. UangLogic.format(UangLogic.MaksSaldo) .. " Micda (1000 T)."
                end
                if amount > sisa then
                        return false, "Ruangan Micda tinggal " .. UangLogic.format(sisa) .. "! Lakukan dalam bagian lebih kecil."
                end
        else
                if UangLogic.saldo(st) < amount then
                        return false, "Micda tidak cukup."
                end
        end
        return true, "ok"
end

function UangLogic.tambah(st: any, amount: any, reason: any, now: number): (boolean, string)
        local ok, msg = gerbang(st, amount, reason, "masuk")
        if not ok then
                return false, msg
        end
        st.m += amount
        catat(st, now, amount, tostring(reason))
        return true, "ok"
end

function UangLogic.bayar(st: any, amount: any, reason: any, now: number): (boolean, string)
        local ok, msg = gerbang(st, amount, reason, "keluar")
        if not ok then
                return false, msg
        end
        st.m -= amount
        catat(st, now, -amount, tostring(reason))
        return true, "ok"
end

function UangLogic.ledgerOf(st: any): { any }
        local out = {}
        for _, l in ipairs(st.ledger) do
                table.insert(out, { t = l.t, d = l.d, r = l.r, s = l.s })
        end
        return out
end

return UangLogic
