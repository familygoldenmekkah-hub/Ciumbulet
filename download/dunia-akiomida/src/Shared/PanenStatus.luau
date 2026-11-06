local PanenStatus = {}

function PanenStatus.hitung(records: any, t: number): { { id: string, siap: number, tumbuh: number } }
        local per: { [string]: { id: string, siap: number, tumbuh: number } } = {}
        local urut: { { id: string, siap: number, tumbuh: number } } = {}
        if type(records) ~= "table" then
                return urut
        end
        for _, rec in pairs(records) do
                if type(rec) == "table" and type(rec.crop) == "string" and #rec.crop <= 40 then
                        local key = rec.crop
                        local entri = per[key]
                        if not entri then
                                entri = { id = key, siap = 0, tumbuh = 0 }
                                per[key] = entri
                                table.insert(urut, entri)
                        end
                        local siap = type(rec.readyAt) == "number" and t >= rec.readyAt
                        if siap then
                                entri.siap += 1
                        else
                                entri.tumbuh += 1
                        end
                end
        end
        return urut
end

return PanenStatus
