local AuditService = {}

local clock = os.time

local JENDELA = 300
local BATAS_KICK = 20
local insiden: { [number]: any } = {}

local JENIS = {
        micda_tolak = true,
        laju = true,
        argumen = true,
        jarak = true,
        milik = true,
        klaim_ganda = true,
        drop_tidak_sah = true,
        sesi_ganda = true,
}

function AuditService.setClock(fn)
        clock = fn
end

local function bersih(userId: number, now: number)
        local arr = insiden[userId]
        if not arr then
                return
        end
        local i = 1
        while i <= #arr do
                if now - arr[i].t > JENDELA then
                        table.remove(arr, i)
                else
                        i += 1
                end
        end
end

function AuditService.catat(player: Player, jenis: string, detail: string)
        if type(jenis) ~= "string" or not JENIS[jenis] then
                return
        end
        if not player or not player.UserId then
                return
        end
        local now = clock()
        local userId = player.UserId
        local arr = insiden[userId]
        if not arr then
                arr = {}
                insiden[userId] = arr
        end
        table.insert(arr, { t = now, k = jenis })
        bersih(userId, now)
        print(string.format("[AUDIT] user=%d jenis=%s detail=%s jumlah5m=%d", userId, jenis, tostring(detail):sub(1, 120), #arr))
        if #arr >= BATAS_KICK then
                local nama = player.Name
                insiden[userId] = {}
                print(string.format("[AUDIT] kick user=%d nama=%s pelanggaran berulang", userId, nama))
                task.spawn(function()
                        pcall(function()
                                player:Kick("Aktivitas tidak sah terdeteksi berulang.")
                        end)
                end)
        end
end

function AuditService.jumlah(userId: number): number
        local arr = insiden[userId]
        if not arr then
                return 0
        end
        bersih(userId, clock())
        arr = insiden[userId]
        return arr and #arr or 0
end

function AuditService.bersih(userId: number)
        insiden[userId] = nil
end

return AuditService
