local GudangLogic = {}

GudangLogic.MaksSlot = 1000
GudangLogic.MaksIsi = 250

function GudangLogic.baru(): { s: { { id: string, count: number } } }
        return { s = {} }
end

function GudangLogic.terpakai(gd: any): number
        if type(gd) ~= "table" or type(gd.s) ~= "table" then
                return 0
        end
        return #gd.s
end

function GudangLogic.simpan(gd: any, id: any, n: any, byId: any?): (boolean, string)
        if type(id) ~= "string" or #id == 0 or #id > 40 or (byId ~= nil and type(byId) == "table" and not byId[id]) then
                return false, "Barang tidak sah."
        end
        if type(n) ~= "number" or n ~= n or n % 1 ~= 0 or n < 1 or n > GudangLogic.MaksIsi then
                return false, "Jumlah setor harus 1 sampai 250."
        end
        if GudangLogic.terpakai(gd) >= GudangLogic.MaksSlot then
                return false, "Gudang penuh! Tampungan 1000 sudah habis."
        end
        table.insert(gd.s, { id = id, count = n })
        return true, "Tampungan terpakai " .. GudangLogic.terpakai(gd) .. "/" .. GudangLogic.MaksSlot .. " (sisa " .. GudangLogic.MaksSlot - GudangLogic.terpakai(gd) .. ")."
end

function GudangLogic.ambil(gd: any, i: any, n: any): (boolean, string, number)
        if type(i) ~= "number" or i ~= i or i % 1 ~= 0 or i < 1 or i > GudangLogic.terpakai(gd) then
                return false, "Slot gudang tidak ada.", 0
        end
        local s = gd.s[i]
        if type(n) ~= "number" or n ~= n or n % 1 ~= 0 or n < 1 then
                n = s.count
        end
        n = math.max(1, math.min(math.floor(n), s.count, GudangLogic.MaksIsi))
        return true, "OK", n
end

function GudangLogic.kurangi(gd: any, i: number, n: number)
        local s = gd.s[i]
        if not s then
                return
        end
        s.count -= n
        if s.count <= 0 then
                table.remove(gd.s, i)
        end
end

function GudangLogic.ser(gd: any, byId: any?): { { id: string, count: number } }
        local out = {}
        if type(gd) ~= "table" or type(gd.s) ~= "table" then
                return out
        end
        for _, s in ipairs(gd.s) do
                if #out >= GudangLogic.MaksSlot then
                        break
                end
                if type(s) == "table" and type(s.id) == "string" and #s.id <= 40 and type(s.count) == "number" and s.count == s.count and s.count >= 1 and (byId == nil or type(byId) ~= "table" or byId[s.id] ~= nil) then
                        table.insert(out, { id = s.id, count = math.min(GudangLogic.MaksIsi, math.floor(s.count)) })
                end
        end
        return out
end

function GudangLogic.des(x: any, byId: any?): { s: { { id: string, count: number } } }
        local gd = GudangLogic.baru()
        if type(x) ~= "table" then
                return gd
        end
        for _, s in ipairs(x) do
                if #gd.s >= GudangLogic.MaksSlot then
                        break
                end
                if type(s) == "table" and type(s.id) == "string" and #s.id <= 40 and type(s.count) == "number" and s.count == s.count and s.count >= 1 and (byId == nil or type(byId) ~= "table" or byId[s.id] ~= nil) then
                        table.insert(gd.s, { id = s.id, count = math.min(GudangLogic.MaksIsi, math.floor(s.count)) })
                end
        end
        return gd
end

return GudangLogic
