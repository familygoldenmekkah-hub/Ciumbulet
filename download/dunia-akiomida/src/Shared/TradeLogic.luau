-- TradeLogic: logika murni trade antar pemain (tanpa API Roblox).
-- Semua angka yang masuk divalidasi di sini supaya server tidak pernah
-- menerima offer kosong/negatif/NaN/ID tak dikenal dari client.

-- Di Roblox, modul tetangga dimuat lewat Instance; di CLI uji (luau) lewat
-- path relatif terhadap file ini.
local TasLogic, UangLogic
if script and script.Parent then
        TasLogic = require(script.Parent.TasLogic)
        UangLogic = require(script.Parent.UangLogic)
else
        TasLogic = require("./TasLogic")
        UangLogic = require("./UangLogic")
end

local TradeLogic = {}

TradeLogic.SLOT_MAKS = 4 -- maks jenis item per tawaran (1 slot Micda terpisah)
TradeLogic.UNDAANGAN_UMUR = 30 -- detik popup permintaan trade
TradeLogic.TAWAR_UMUR = 180 -- detik fase tawar, diperpanjang tiap aktivitas
TradeLogic.KONFIRM_UMUR = 25 -- detik fase konfirmasi (keras, demi keamanan)
TradeLogic.JARAK_MAKS = 48 -- studs maksimal saat mengajak trade

local KIND_OK = { benih = true, hasil = true }

function TradeLogic.jumlahSah(n: any, minimal: number?): boolean
        local m = minimal or 1
        if type(n) ~= "number" or n ~= n or n == math.huge or n == -math.huge then
                return false
        end
        if n < m or n ~= math.floor(n) then
                return false
        end
        return true
end

function TradeLogic.offerBaru(): any
        return { items = {}, micda = 0 }
end

function TradeLogic.cariIdx(offer: any, kind: string, id: string): number?
        for i, s in ipairs(offer.items) do
                if s.kind == kind and s.id == id then
                        return i
                end
        end
        return nil
end

-- Sisipkan / ganti jumlah satu jenis item pada offer.
-- tersedia = jumlah tas pemain MINUS jumlah yang sudah terkunci untuk slot lain.
function TradeLogic.sisip(offer: any, kind: any, id: any, n: any, tersedia: number, byId: any): (boolean, string)
        if KIND_OK[kind] ~= true then
                return false, "Jenis item tidak sah."
        end
        if type(id) ~= "string" or type(byId) ~= "table" or not byId[id] then
                return false, "Item tidak dikenal."
        end
        if not TradeLogic.jumlahSah(n) then
                return false, "Jumlah tidak sah."
        end
        if n > tersedia then
                return false, "Jumlah melebihi yang tersedia (yang terkunci untuk trade ini dihitung)."
        end
        if n > TasLogic.MaxStack * TasLogic.MaxSlots then
                return false, "Jumlah terlalu besar."
        end
        local idx = TradeLogic.cariIdx(offer, kind, id)
        if idx then
                offer.items[idx].count = n
                return true, "ok"
        end
        if #offer.items >= TradeLogic.SLOT_MAKS then
                return false, "Slot tawaran penuh (maksimal " .. tostring(TradeLogic.SLOT_MAKS) .. " jenis item)."
        end
        table.insert(offer.items, { kind = kind, id = id, count = n })
        return true, "ok"
end

function TradeLogic.hapus(offer: any, kind: string, id: string): boolean
        local idx = TradeLogic.cariIdx(offer, kind, id)
        if not idx then
                return false
        end
        table.remove(offer.items, idx)
        return true
end

-- n = 0 berarti kosongkan slot Micda.
function TradeLogic.aturMicda(offer: any, n: any, saldo: number): (boolean, string)
        if not TradeLogic.jumlahSah(n, 0) then
                return false, "Jumlah Micda tidak sah."
        end
        if n > saldo then
                return false, "Micda tidak cukup."
        end
        offer.micda = n
        return true, "ok"
end

-- Peta item yang dikunci (tidak bisa dipakai/dijual di tempat lain selama sesi).
function TradeLogic.terkan(offer: any): { [string]: number }
        local peta = {}
        for _, s in ipairs(offer.items) do
                local k = s.kind .. "\1" .. s.id
                peta[k] = (peta[k] or 0) + s.count
        end
        return peta
end

function TradeLogic.totalItem(offer: any): number
        local total = 0
        for _, s in ipairs(offer.items) do
                total += s.count
        end
        return total
end

function TradeLogic.ringkas(offer: any, byId: any): string
        local bagian = {}
        for _, s in ipairs(offer.items) do
                local info = byId and byId[s.id]
                local nama = info and info.nama or s.id
                table.insert(bagian, (s.kind == "benih" and "Benih " or "") .. nama .. " x" .. tostring(s.count))
        end
        if (offer.micda or 0) > 0 then
                table.insert(bagian, UangLogic.format(offer.micda) .. " Micda")
        end
        if #bagian == 0 then
                return "kosong"
        end
        return table.concat(bagian, ", ")
end

-- Simulasi eksekusi penuh SEBELUM menyentuh data asli:
-- barang tawaran dikurangi dari tas pengirim lalu dimasukkan ke tas lawan,
-- Micda dicek dari dua arah (saldo pengirim + ruang rekening penerima).
-- Satu saja kegagalan = seluruh trade batal, tidak ada perubahan parsial.
-- Bila sah, mengembalikan salinan tas akhir kedua sisi (ka, kb) — salinan itu
-- yang dipasang server sekaligus saat eksekusi atomik.
function TradeLogic.validasiEksekusi(offerA: any, offerB: any, tasA: { any }, tasB: { any }, saldoA: number, saldoB: number): (boolean, string, { any }?, { any }?)
        local ka, kb = {}, {}
        for i, s in ipairs(tasA) do
                ka[i] = { kind = s.kind, id = s.id, count = s.count }
        end
        for i, s in ipairs(tasB) do
                kb[i] = { kind = s.kind, id = s.id, count = s.count }
        end
        for _, s in ipairs(offerA.items) do
                if TasLogic.remove(ka, s.kind, s.id, s.count) < s.count then
                        return false, "Barang tawaranmu tidak cukup di tas."
                end
        end
        for _, s in ipairs(offerB.items) do
                if TasLogic.remove(kb, s.kind, s.id, s.count) < s.count then
                        return false, "Barang tawaran lawan tidak cukup di tas."
                end
        end
        for _, s in ipairs(offerA.items) do
                if TasLogic.add(kb, s.kind, s.id, s.count) < s.count then
                        return false, "Tas lawan penuh untuk menerima itemmu."
                end
        end
        for _, s in ipairs(offerB.items) do
                if TasLogic.add(ka, s.kind, s.id, s.count) < s.count then
                        return false, "Tasmu penuh untuk menerima item lawan."
                end
        end
        local mA = offerA.micda or 0
        local mB = offerB.micda or 0
        if mA > 0 then
                if saldoA < mA then
                        return false, "Micda pengirim tidak cukup."
                end
                if UangLogic.ruangSisa({ m = saldoB }) < mA then
                        return false, "Rekening Micda lawan tidak cukup ruang."
                end
        end
        if mB > 0 then
                if saldoB < mB then
                        return false, "Micda pengirim tidak cukup."
                end
                if UangLogic.ruangSisa({ m = saldoA }) < mB then
                        return false, "Rekening Micda-mu tidak cukup ruang."
                end
        end
        return true, "ok", ka, kb
end

function TradeLogic.sisaDetik(exp: number, sekarang: number): number
        local sisa = math.floor(exp - sekarang)
        if sisa < 0 then
                return 0
        end
        return sisa
end

return TradeLogic
