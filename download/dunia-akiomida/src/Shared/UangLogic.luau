local UangLogic = {}

UangLogic.MaksAksi = 25000
UangLogic.BatasPerMenit = 24
UangLogic.JendelaDetik = 60
UangLogic.BatasLedger = 24

UangLogic.Alasan = {
        jual_hasil = true,
        beli_benih = true,
        smash_hasil = true,
        hadiah = true,
}

function UangLogic.baru(saldoAwal: number): any
        return {
                m = math.max(0, math.floor(tonumber(saldoAwal) or 0)),
                ledger = {},
                tick = {},
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

function UangLogic.bersihTick(st: any, now: number)
        local i = 1
        while i <= #st.tick do
                if now - st.tick[i] > UangLogic.JendelaDetik then
                        table.remove(st.tick, i)
                else
                        i += 1
                end
        end
end

local function catat(st: any, now: number, delta: number, reason: string, status: string)
        table.insert(st.ledger, { t = math.floor(now), d = delta, r = reason, s = status })
        while #st.ledger > UangLogic.BatasLedger do
                table.remove(st.ledger, 1)
        end
end

local function gerbang(st: any, amount: any, reason: any, now: number, arah: string): (boolean, string, any)
        if not UangLogic.sah(amount) then
                return false, "Jumlah Micda tidak sah.", nil
        end
        if not UangLogic.alasanOk(reason) then
                return false, "Alasan transaksi tidak sah.", nil
        end
        if amount > UangLogic.MaksAksi then
                return false, "Transaksi melebihi batas atas.", "lonjakan"
        end
        UangLogic.bersihTick(st, now)
        if #st.tick >= UangLogic.BatasPerMenit then
                return false, "Terlalu banyak transaksi. Tunggu sebentar.", "laju"
        end
        if arah == "keluar" and st.m < amount then
                return false, "Micda tidak cukup.", nil
        end
        return true, "ok", nil
end

function UangLogic.tambah(st: any, amount: any, reason: any, now: number): (boolean, string)
        local ok, msg, flag = gerbang(st, amount, reason, now, "masuk")
        if not ok then
                if flag then
                        catat(st, now, 0, tostring(reason), "tolak_" .. flag)
                end
                return false, msg
        end
        st.m += amount
        table.insert(st.tick, now)
        catat(st, now, amount, reason, "ok")
        return true, "ok"
end

function UangLogic.bayar(st: any, amount: any, reason: any, now: number): (boolean, string)
        local ok, msg, flag = gerbang(st, amount, reason, now, "keluar")
        if not ok then
                if flag then
                        catat(st, now, 0, tostring(reason), "tolak_" .. flag)
                end
                return false, msg
        end
        st.m -= amount
        table.insert(st.tick, now)
        catat(st, now, -amount, reason, "ok")
        return true, "ok"
end

function UangLogic.ledgerOf(st: any): { any }
        local out = {}
        for _, l in ipairs(st.ledger) do
                table.insert(out, { t = l.t, d = l.d, r = l.r, s = l.s })
        end
        return out
end

function UangLogic.saldo(st: any): number
        return st.m
end

return UangLogic
