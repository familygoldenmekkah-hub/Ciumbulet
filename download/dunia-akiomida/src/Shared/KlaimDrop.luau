local KlaimDrop = {}

KlaimDrop.JarakAmbil = 14

function KlaimDrop.baru(owner: number): any
        return { owner = owner, status = "ada", id = nil }
end

function KlaimDrop.valid(rec: any): boolean
        return type(rec) == "table" and rec.status == "ada"
end

function KlaimDrop.coba(rec: any, userId: number, dist: number): (boolean, string)
        if type(rec) ~= "table" then
                return false, "rusak"
        end
        if rec.owner ~= userId then
                return false, "bukan_milik"
        end
        if rec.status ~= "ada" then
                return false, "sudah_diambil"
        end
        if type(dist) ~= "number" or dist ~= dist or dist > KlaimDrop.JarakAmbil then
                return false, "jarak"
        end
        rec.status = "proses"
        return true, "ok"
end

function KlaimDrop.selesai(rec: any, userId: number): boolean
        if type(rec) ~= "table" or rec.status ~= "proses" or rec.owner ~= userId then
                return false
        end
        rec.status = "ambil"
        return true
end

function KlaimDrop.batalkan(rec: any, userId: number): boolean
        if type(rec) ~= "table" or rec.status ~= "proses" or rec.owner ~= userId then
                return false
        end
        rec.status = "ada"
        return true
end

return KlaimDrop
