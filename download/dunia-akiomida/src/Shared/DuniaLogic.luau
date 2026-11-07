local DuniaLogic = {}

DuniaLogic.SaveEvery = 60
DuniaLogic.MaxPlots = 500
DuniaLogic.MaxMeja = 6
DuniaLogic.MaxDrops = 80
DuniaLogic.MaksPukulSimpan = 5

function DuniaLogic.keyFor(userId: number): string
        return "d_" .. tostring(userId)
end

function DuniaLogic.cleanName(nama: any): string?
        if type(nama) ~= "string" then
                return nil
        end
        local n = nama:gsub("^%s+", ""):gsub("%s+$", "")
        if #n < 1 or #n > 30 then
                return nil
        end
        return n
end

-- Format v61: ARRAY berurutan 1..n (kunci JSON aman). DataStore mengubah key angka
-- non-1..n menjadi string ("0","5",...) sehingga format kamus lama LULUS mati saat
-- round-trip — pohon hilang tiap rejoin. Sekarang idx dibawa DI DALAM item (i).
function DuniaLogic.serPlots(planted: any): { { i: number, c: string, r: number, h: number, l: number } }
        local daftar = {}
        if type(planted) ~= "table" then
                return daftar
        end
        for idx, rec in pairs(planted) do
                if
                        type(idx) == "number"
                        and idx >= 0
                        and idx < DuniaLogic.MaxPlots
                        and idx == math.floor(idx)
                        and type(rec) == "table"
                        and type(rec.crop) == "string"
                        and #rec.crop <= 40
                        and type(rec.readyAt) == "number"
                        and rec.readyAt == rec.readyAt
                then
                        local h = type(rec.hits) == "number" and rec.hits or 0
                        local l = type(rec.lastHit) == "number" and rec.lastHit or 0
                        h = math.clamp(math.floor(h), 0, DuniaLogic.MaksPukulSimpan)
                        l = (l == l and l >= 0 and l ~= math.huge) and math.floor(l) or 0
                        table.insert(daftar, { i = idx, c = rec.crop, r = math.floor(rec.readyAt), h = h, l = l })
                end
        end
        table.sort(daftar, function(a, b)
                return a.i < b.i
        end)
        return daftar
end

function DuniaLogic.desSatuPlot(c: any, r: any, h: any, l: any): any
        if type(c) ~= "string" or #c > 40 or type(r) ~= "number" or r ~= r then
                return nil
        end
        h = type(h) == "number" and h or 0
        l = type(l) == "number" and l or 0
        h = math.clamp(math.floor(h), 0, DuniaLogic.MaksPukulSimpan)
        l = (l == l and l >= 0 and l ~= math.huge) and math.floor(l) or 0
        return { c = c, r = math.floor(r), h = h, l = l }
end

function DuniaLogic.desPlots(arr: any): { [number]: { c: string, r: number, h: number, l: number } }
        local out = {}
        if type(arr) ~= "table" then
                return out
        end
        -- Format baru v61: array { { i = idx, c = .., r = .., h = .., l = .. } }
        for _, rec in ipairs(arr) do
                if
                        type(rec) == "table"
                        and type(rec.i) == "number"
                        and rec.i >= 0
                        and rec.i < DuniaLogic.MaxPlots
                        and rec.i == math.floor(rec.i)
                then
                        local d = DuniaLogic.desSatuPlot(rec.c, rec.r, rec.h, rec.l)
                        if d then
                                out[rec.i] = d
                        end
                end
        end
        if next(out) ~= nil then
                return out
        end
        -- Format lama: kamus dengan key angka ATAU key STRING sisa JSON ("0".."499").
        -- Membaca kembali data lama yang sebelumnya "hilang" saat dimuat.
        for k, rec in pairs(arr) do
                if type(rec) == "table" and type(rec.i) ~= "number" then
                        local idx = nil
                        if type(k) == "number" and k == math.floor(k) then
                                idx = k
                        elseif type(k) == "string" then
                                idx = tonumber(k)
                        end
                        if type(idx) == "number" and idx >= 0 and idx < DuniaLogic.MaxPlots and idx == math.floor(idx) then
                                local d = DuniaLogic.desSatuPlot(rec.c or rec.crop, rec.r or rec.readyAt, rec.h or rec.hits, rec.l or rec.lastHit)
                                if d then
                                        out[idx] = d
                                end
                        end
                end
        end
        return out
end

function DuniaLogic.serDrops(items: any): { any }
        local out = {}
        if type(items) ~= "table" then
                return out
        end
        for _, d in ipairs(items) do
                if #out >= DuniaLogic.MaxDrops then
                        break
                end
                if
                        type(d) == "table"
                        and type(d.id) == "string"
                        and #d.id <= 24
                        and type(d.crop) == "string"
                        and #d.crop <= 40
                        and type(d.count) == "number"
                        and d.count == d.count
                        and d.count >= 1
                        and d.count <= 250
                        and d.count == math.floor(d.count)
                        and type(d.pos) == "table"
                        and type(d.pos.x) == "number"
                        and type(d.pos.y) == "number"
                        and type(d.pos.z) == "number"
                        and d.pos.x == d.pos.x
                        and d.pos.y == d.pos.y
                        and d.pos.z == d.pos.z
                then
                        table.insert(out, {
                                i = d.id,
                                c = d.crop,
                                n = math.floor(d.count),
                                p = { x = d.pos.x, y = d.pos.y, z = d.pos.z },
                        })
                end
        end
        return out
end

function DuniaLogic.desDrops(arr: any): { any }
        local out = {}
        if type(arr) ~= "table" then
                return out
        end
        for _, d in ipairs(arr) do
                if #out >= DuniaLogic.MaxDrops then
                        break
                end
                if
                        type(d) == "table"
                        and type(d.i) == "string"
                        and #d.i <= 24
                        and type(d.c) == "string"
                        and #d.c <= 40
                        and type(d.n) == "number"
                        and d.n == d.n
                        and d.n >= 1
                        and d.n <= 250
                        and d.n == math.floor(d.n)
                        and type(d.p) == "table"
                        and type(d.p.x) == "number"
                        and type(d.p.y) == "number"
                        and type(d.p.z) == "number"
                        and d.p.x == d.p.x
                        and d.p.y == d.p.y
                        and d.p.z == d.p.z
                then
                        table.insert(out, {
                                id = d.i,
                                crop = d.c,
                                count = math.floor(d.n),
                                pos = { x = d.p.x, y = d.p.y, z = d.p.z },
                        })
                end
        end
        return out
end

function DuniaLogic.serMesin(batch: any): { { c: string, j: number, m: number, b: number, k: number } }
        local out = {}
        if type(batch) ~= "table" then
                return out
        end
        if type(batch.c) == "string" and #batch.c <= 40 and type(batch.j) == "number" then
                table.insert(out, {
                        c = batch.c,
                        j = math.max(1, math.floor(batch.j)),
                        m = type(batch.m) == "number" and math.max(0, math.floor(batch.m)) or 0,
                        b = type(batch.b) == "number" and math.max(0, math.floor(batch.b)) or 0,
                        k = type(batch.k) == "number" and math.max(0, math.floor(batch.k)) or 0,
                })
        end
        return out
end

function DuniaLogic.desMesin(arr: any): { { c: string, j: number?, m: number?, b: number?, k: number?, h: number? } }
        local out = {}
        if type(arr) ~= "table" then
                return out
        end
        for _, s in ipairs(arr) do
                if #out < 1 and type(s) == "table" then
                        if type(s.c) == "string" and #s.c <= 40 and type(s.j) == "number" then
                                table.insert(out, {
                                        c = s.c,
                                        j = math.max(1, math.floor(s.j)),
                                        m = type(s.m) == "number" and math.max(0, math.floor(s.m)) or nil,
                                        b = type(s.b) == "number" and math.max(0, math.floor(s.b)) or nil,
                                        k = type(s.k) == "number" and math.max(0, math.floor(s.k)) or nil,
                                })
                        elseif type(s.c) == "string" and #s.c <= 40 and type(s.h) == "number" then
                                table.insert(out, { c = s.c, j = 1, h = math.max(1, math.floor(s.h)) })
                        end
                end
        end
        return out
end

return DuniaLogic
