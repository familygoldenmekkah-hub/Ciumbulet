local PanenWaktu = {}

PanenWaktu.HARVEST_EXPIRE_SECONDS = 900

function PanenWaktu.masihAman(leaveTime: any, now: number): boolean
        if type(leaveTime) ~= "number" or leaveTime ~= leaveTime or leaveTime <= 0 then
                return true
        end
        return now - leaveTime < PanenWaktu.HARVEST_EXPIRE_SECONDS
end

function PanenWaktu.sisaDetik(leaveTime: any, now: number): number
        if type(leaveTime) ~= "number" or leaveTime ~= leaveTime then
                return -1
        end
        local sisa = PanenWaktu.HARVEST_EXPIRE_SECONDS - (now - leaveTime)
        if sisa < 0 then
                return 0
        end
        return math.floor(sisa)
end

return PanenWaktu
