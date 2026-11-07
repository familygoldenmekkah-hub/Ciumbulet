local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TasLogic = require(ReplicatedStorage.Shared.TasLogic)

local TasService = {}
local dataOf: any = nil
local kunciOf: any = nil -- TradeService: jumlahTerkan(userId, kind, id) -> number

function TasService.bind(dataService)
        dataOf = dataService
end

function TasService.bindTrade(tradeService)
        kunciOf = tradeService
end

local function terkunci(userId: number, kind: string, id: string): number
        if kunciOf and kunciOf.jumlahTerkan then
                local n = kunciOf.jumlahTerkan(userId, kind, id)
                if type(n) == "number" and n == n and n > 0 then
                        return n
                end
        end
        return 0
end

-- Jumlah yang benar-benar bebas dipakai: seluruh isi tas MINUS jumlah yang
-- sedang ditawarkan dalam sesi trade aktif. Semua pemakai item (tanam, jual,
-- gudang, mesin semai) harus lewat sini supaya barang dagangan trade tidak
-- bisa hilang ke jalur lain di tengah sesi.
function TasService.tersedia(player, kind: string, id: string): number
        local tas = TasService.tas(player)
        if not tas then
                return 0
        end
        local total = TasLogic.countOf(tas, kind, id)
        local kunci = terkunci(player.UserId, kind, id)
        local bebas = total - kunci
        if bebas < 0 then
                return 0
        end
        return bebas
end

function TasService.tas(player)
        local d = dataOf.get(player)
        return d and d.t or nil
end

function TasService.roomFor(player, kind: string, id: string, want: number): number
        local tas = TasService.tas(player)
        if not tas then
                return 0
        end
        return TasLogic.roomFor(tas, kind, id, want)
end

function TasService.add(player, kind: string, id: string, count: number): number
        local tas = TasService.tas(player)
        if not tas then
                return 0
        end
        local put = TasLogic.add(tas, kind, id, count)
        if put > 0 then
                dataOf.markDirty(player)
                dataOf.push(player)
        end
        return put
end

function TasService.remove(player, kind: string, id: string, count: number): number
        local tas = TasService.tas(player)
        if not tas then
                return 0
        end
        -- Barang yang sedang ditawarkan di trade tidak boleh dipakai di sini.
        local bebas = TasService.tersedia(player, kind, id)
        local mau = math.min(count, bebas)
        if mau < 1 then
                return 0
        end
        local took = TasLogic.remove(tas, kind, id, mau)
        if took > 0 then
                dataOf.markDirty(player)
                dataOf.push(player)
        end
        return took
end

function TasService.count(player, kind: string, id: string): number
        local tas = TasService.tas(player)
        if not tas then
                return 0
        end
        return TasLogic.countOf(tas, kind, id)
end

function TasService.canFitBatch(player, items): boolean
        local tas = TasService.tas(player)
        if not tas then
                return false
        end
        return TasLogic.canFitBatch(tas, items)
end

return TasService
