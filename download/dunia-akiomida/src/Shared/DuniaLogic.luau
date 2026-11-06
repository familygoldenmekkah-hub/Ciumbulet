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

function DuniaLogic.serPlots(planted: any): { [number]: { c: string, r: number, h: number, l: number } }
        local out = {}
        if type(planted) ~= "table" then
                return out
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
                        out[idx] = { c = rec.crop, r = math.floor(rec.readyAt), h = h, l = l }
                end
        end
        return out
end

function DuniaLogic.desPlots(arr: any): { [number]: { c: string, r: number, h: number, l: number } }
        local out = {}
        if type(arr) ~= "table" then
                return out
        end
        for idx, rec in pairs(arr) do
                if
                        type(idx) == "number"
                        and idx >= 0
                        and idx < DuniaLogic.MaxPlots
                        and idx == math.floor(idx)
                        and type(rec) == "table"
                        and type(rec.c) == "string"
                        and #rec.c <= 40
                        and type(rec.r) == "number"
                        and rec.r == rec.r
                then
                        local h = type(rec.h) == "number" and rec.h or 0
                        local l = type(rec.l) == "number" and rec.l or 0
                        h = math.clamp(math.floor(h), 0, DuniaLogic.MaksPukulSimpan)
                        l = (l == l and l >= 0 and l ~= math.huge) and math.floor(l) or 0
                        out[idx] = { c = rec.c, r = math.floor(rec.r), h = h, l = l }
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

function DuniaLogic.serMeja(slots: any): { { c: string, h: number } }
        local out = {}
        if type(slots) ~= "table" then
                return out
        end
        for i, s in ipairs(slots) do
                if #out >= DuniaLogic.MaxMeja then
                        break
                end
                if type(s) == "table" and type(s.crop) == "string" and #s.crop <= 40 and type(s.hitsLeft) == "number" then
                        table.insert(out, { c = s.crop, h = math.max(1, math.floor(s.hitsLeft)) })
                end
        end
        return out
end

function DuniaLogic.desMeja(arr: any): { { c: string, h: number } }
        local out = {}
        if type(arr) ~= "table" then
                return out
        end
        for _, s in ipairs(arr) do
                if #out >= DuniaLogic.MaxMeja then
                        break
                end
                if type(s) == "table" and type(s.c) == "string" and #s.c <= 40 and type(s.h) == "number" then
                        table.insert(out, { c = s.c, h = math.max(1, math.floor(s.h)) })
                end
        end
        return out
end

return DuniaLogic
