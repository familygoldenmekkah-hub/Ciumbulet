local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DuniaLogic = require(ReplicatedStorage.Shared.DuniaLogic)

local DuniaService = {}

local aktif = MemoryStoreService:GetSortedMap("AKM_DuniaAktif")
local store = DataStoreService:GetDataStore("AKM_Dunia")

local Plot, Smash
local roleOf: { [number]: string } = {}
local ownerId = 0
local ownerName = "Petani"
local worldLoaded = false
local worldDirty = false
local loopsOn = false
local lastBeat = 0
local lastSave = 0

function DuniaService.bind(deps)
        Plot = deps.Plot
        Smash = deps.Smash
end

local function now(): number
        return workspace:GetServerTimeNow()
end

local function key(): string
        return DuniaLogic.keyFor(ownerId)
end

function DuniaService.setOwner(id: number, nama: string?)
        ownerId = id
        if nama and #nama > 0 then
                ownerName = nama
        end
end

function DuniaService.ownerId(): number
        return ownerId
end

function DuniaService.ownerName(): string
        return ownerName
end

function DuniaService.roleOf(player: Player): string
        return roleOf[player.UserId] or "hub"
end

function DuniaService.setRole(player: Player, role: string)
        roleOf[player.UserId] = role
end

function DuniaService.forget(player: Player)
        roleOf[player.UserId] = nil
end

function DuniaService.touch()
        worldDirty = true
end

function DuniaService.loadWorld()
        worldLoaded = true
        if ownerId <= 0 then
                return
        end
        local ok, data = pcall(function()
                return store:GetAsync(key())
        end)
        if ok and type(data) == "table" then
                if type(data.n) == "string" and #data.n > 0 and #data.n <= 30 then
                        ownerName = data.n
                end
                Plot.restore(1, DuniaLogic.desPlots(data.pl))
                Smash.restoreLahan(1, DuniaLogic.desMeja(data.mj))
        end
end

function DuniaService.saveWorld()
        if not worldLoaded or ownerId <= 0 or not worldDirty then
                return
        end
        local payload = {
                n = ownerName,
                pl = DuniaLogic.serPlots(Plot.serialize(1)),
                mj = DuniaLogic.serMeja(Smash.serializeLahan(1)),
                t = math.floor(now()),
        }
        local ok = pcall(function()
                store:SetAsync(key(), payload)
        end)
        if ok then
                worldDirty = false
        end
end

local function beat()
        if ownerId <= 0 or game.PrivateServerId == "" then
                return
        end
        pcall(function()
                aktif:SetAsync(key(), { k = game.PrivateServerId, t = math.floor(now()) }, DuniaLogic.Ttl)
        end)
end

function DuniaService.startLoops()
        if loopsOn then
                return
        end
        loopsOn = true
        lastBeat = 0
        lastSave = now()
        task.spawn(function()
                while loopsOn do
                        task.wait(1)
                        local t = now()
                        if t - lastBeat >= DuniaLogic.Heartbeat then
                                lastBeat = t
                                beat()
                        end
                        if t - lastSave >= DuniaLogic.SaveEvery then
                                lastSave = t
                                DuniaService.saveWorld()
                        end
                end
        end)
end

function DuniaService.closeWorld()
        DuniaService.saveWorld()
        if ownerId > 0 then
                pcall(function()
                        aktif:RemoveAsync(key())
                end)
        end
        loopsOn = false
end

function DuniaService.enter(player: Player): (boolean, string)
        if game.PrivateServerId ~= "" then
                return false, "Kamu sedang berada di dalam dunia."
        end
        local pid = game.PlaceId
        if pid <= 0 then
                return false, "Teleport belum tersedia di lingkungan ini."
        end
        local okR, kode = pcall(function()
                return TeleportService:ReserveServer(pid)
        end)
        if not okR or type(kode) ~= "string" or #kode == 0 then
                return false, "Gagal menyiapkan dunia. Coba lagi sebentar."
        end
        pcall(function()
                aktif:SetAsync(DuniaLogic.keyFor(player.UserId), { k = kode, t = math.floor(now()) }, DuniaLogic.Ttl)
        end)
        local opt = Instance.new("TeleportOptions")
        opt:SetReservedServerAccessCode(kode)
        opt:SetTeleportData({ md = "dunia", pemilik = player.UserId, nama = player.Name })
        local okT = pcall(function()
                TeleportService:TeleportAsync(pid, { player }, opt)
        end)
        if not okT then
                return false, "Teleport gagal. Coba lagi sebentar."
        end
        return true, "Membuka duniamu..."
end

function DuniaService.visit(player: Player, namaRaw: any): (boolean, string)
        if type(namaRaw) ~= "string" then
                return false, "Nama tidak sah."
        end
        local nama = namaRaw:gsub("^%s+", ""):gsub("%s+$", "")
        if #nama < 2 or #nama > 30 then
                return false, "Nama pemain tidak sah."
        end
        local pid = game.PlaceId
        if pid <= 0 then
                return false, "Teleport belum tersedia di lingkungan ini."
        end
        local okId, targetId = pcall(function()
                return Players:GetUserIdFromNameAsync(nama)
        end)
        if not okId or type(targetId) ~= "number" or targetId <= 0 then
                return false, "Nama pemain tidak ditemukan."
        end
        if targetId == player.UserId then
                return DuniaService.enter(player)
        end
        local okG, rec = pcall(function()
                return aktif:GetAsync(DuniaLogic.keyFor(targetId))
        end)
        local opt = Instance.new("TeleportOptions")
        local hidup = okG and DuniaLogic.fresh(rec, now()) and type(rec.k) == "string"
        if hidup then
                opt:SetReservedServerAccessCode(rec.k)
        else
                local okR, kode = pcall(function()
                        return TeleportService:ReserveServer(pid)
                end)
                if not okR or type(kode) ~= "string" or #kode == 0 then
                        return false, "Gagal menyiapkan kunjungan. Coba lagi sebentar."
                end
                opt:SetReservedServerAccessCode(kode)
        end
        opt:SetTeleportData({ md = "dunia", pemilik = targetId, nama = nama })
        local okT = pcall(function()
                TeleportService:TeleportAsync(pid, { player }, opt)
        end)
        if not okT then
                return false, "Teleport gagal. Coba lagi sebentar."
        end
        if hidup then
                return true, "Menuju dunia " .. nama .. " yang sedang aktif."
        end
        return true, "Membuka dunia " .. nama .. " dalam mode kunjung."
end

function DuniaService.pulang(player: Player): (boolean, string)
        local ok = pcall(function()
                TeleportService:TeleportAsync(game.PlaceId, { player })
        end)
        if not ok then
                return false, "Teleport gagal. Coba lagi sebentar."
        end
        return true, "Kembali ke Pusat Kota..."
end

return DuniaService
