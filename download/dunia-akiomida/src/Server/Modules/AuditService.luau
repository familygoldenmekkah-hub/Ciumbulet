local AuditService = {}

local clock = os.time

local AMBANG = 100
local JENDELA = 3600

local Simpan: any = nil
local eksekutor: any = nil

local insiden: { [number]: { any } } = {}
local transaksi: { [number]: number } = {}

AuditService.Bobot = {
        uang_korup = 100,
        uang_lebih = 100,
        sumber_tak_dikenal = 60,
        sesi_anomali = 20,
}

function AuditService.bind(deps)
        Simpan = deps and deps.Simpan or nil
end

function AuditService.setClock(fn)
        clock = fn
end

function AuditService.setEksekutor(fn)
        eksekutor = fn
end

function AuditService.catat(player: Player, jenis: string, detail: string)
        if type(jenis) ~= "string" or not player or not player.UserId then
                return
        end
        print(string.format("[AUDIT] log user=%d jenis=%s detail=%s", player.UserId, jenis, tostring(detail):sub(1, 120)))
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

local function kickAmanInternal(player: Player, alasan: string)
        local userId = player.UserId
        local nama = player.Name
        print(string.format("[AUDIT] kick-aman user=%d nama=%s alasan=%s", userId, nama, tostring(alasan):sub(1, 120)))
        task.spawn(function()
                if Simpan then
                        pcall(Simpan, player)
                end
                local t0 = clock()
                while AuditService.sedangTransaksi(player) and clock() - t0 < 8 do
                        task.wait(0.2)
                end
                if Simpan then
                        pcall(Simpan, player)
                end
                pcall(function()
                        player:Kick("Aktivitas tidak mungkin terdeteksi. Data kamu sudah disimpan dengan aman.")
                end)
        end)
end

function AuditService.anomali(player: Player, jenis: string, detail: string): boolean
        if type(jenis) ~= "string" or not player or not player.UserId then
                return false
        end
        local bobot = AuditService.Bobot[jenis]
        if not bobot then
                return false
        end
        local userId = player.UserId
        local now = clock()
        bersih(userId, now)
        local arr = insiden[userId]
        if not arr then
                arr = {}
                insiden[userId] = arr
        end
        table.insert(arr, { t = now, b = bobot, k = jenis })
        local total = 0
        for _, e in ipairs(arr) do
                total += e.b
        end
        print(string.format("[AUDIT] anomali user=%d jenis=%s detail=%s bobot=%d total=%d", userId, jenis, tostring(detail):sub(1, 120), bobot, total))
        if total >= AMBANG then
                insiden[userId] = {}
                if eksekutor then
                        eksekutor(player, "anomali:" .. jenis)
                else
                        kickAmanInternal(player, "anomali:" .. jenis)
                end
                return true
        end
        return false
end

function AuditService.transaksiMulai(player: Player)
        if player and player.UserId then
                transaksi[player.UserId] = (transaksi[player.UserId] or 0) + 1
        end
end

function AuditService.transaksiSelesai(player: Player)
        if player and player.UserId and transaksi[player.UserId] then
                transaksi[player.UserId] = math.max(0, transaksi[player.UserId] - 1)
        end
end

function AuditService.sedangTransaksi(player: Player): boolean
        if not player or not player.UserId then
                return false
        end
        return (transaksi[player.UserId] or 0) > 0
end

function AuditService.bersih(userId: number)
        insiden[userId] = nil
        transaksi[userId] = nil
end

return AuditService
