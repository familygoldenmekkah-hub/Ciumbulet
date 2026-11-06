local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DuniaLogic = require(ReplicatedStorage.Shared.DuniaLogic)
local WorldBuilder = require(script.Parent.WorldBuilder)

local ZonaService = {}

local Land, Plot, Mesin, Data, Notify, Hooks, Gudang, Drop
local store = DataStoreService:GetDataStore("AKM_Dunia")

type Seksi = {
        idx: number,
        ownerId: number,
        ownerName: string,
        ghost: boolean,
        savedOk: boolean,
        canSave: boolean,
        dirty: boolean,
        model: Model,
        lastSeen: number,
}

local seksi: { [number]: Seksi } = {}
local byOwner: { [number]: number } = {}
local zoneOf: { [number]: { zone: string, dunia: string? } } = {}

function ZonaService.bind(deps)
        Land = deps.Land
        Plot = deps.Plot
        Mesin = deps.Mesin
        Data = deps.Data
        Notify = deps.Notify
        Gudang = deps.Gudang
        Drop = deps.Drop
end

function ZonaService.setHooks(hooks)
        Hooks = hooks
end

local function taken(idx: number): boolean
        return seksi[idx] ~= nil
end

local function ownerSection(userId: number): Seksi?
        for _, s in pairs(seksi) do
                if s.ownerId == userId then
                        return s
                end
        end
        return nil
end

local function arrivalPos(idx: number): Vector3
        local o = Land.origin(idx)
        return Vector3.new(o.X + 120, 4, o.Z + 12)
end

local function kotaPos(): Vector3
        local sp = Land.kotaSpawn() or Land.umumSpawn()
        return sp and (sp.Position + Vector3.new(0, 3, 0)) or Vector3.new(0, 6, 44)
end

local function watchVoid(player: Player, homePos: Vector3)
        task.spawn(function()
                for _ = 1, 60 do
                        task.wait(0.25)
                        local char = player.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
                        if not root then
                                return
                        end
                        if root.Position.Y < -20 then
                                root.Anchored = false
                                root.CFrame = CFrame.new(homePos + Vector3.new(0, 4, 0))
                        end
                end
        end)
end

local function placeAt(player: Player, pos: Vector3, zone: string, dunia: string?): boolean
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not root then
                return false
        end
        zoneOf[player.UserId] = { zone = zone, dunia = dunia }
        root.Anchored = true
        root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        task.spawn(function()
                pcall(function()
                        Workspace:RequestStreamAroundAsync(pos, 4)
                end)
                task.delay(0.8, function()
                        if root.Parent then
                                root.Anchored = false
                        end
                end)
        end)
        task.delay(8, function()
                if root.Parent and root.Anchored then
                        root.Anchored = false
                end
        end)
        watchVoid(player, pos)
        Data.push(player)
        return true
end

local function placeWait(player: Player, pos: Vector3, zone: string, dunia: string?): boolean
        for _ = 1, 12 do
                if placeAt(player, pos, zone, dunia) then
                        return true
                end
                task.wait(0.5)
        end
        return false
end

function ZonaService.zoneOf(player: Player): (string, string?)
        local z = zoneOf[player.UserId]
        if z then
                return z.zone, z.dunia
        end
        return "kota", nil
end

function ZonaService.touch(index: number)
        local s = seksi[index]
        if s and s.canSave then
                s.dirty = true
        end
end

local function payloadOf(s: Seksi, leaving: boolean?)
        local p = {
                n = s.ownerName,
                pl = DuniaLogic.serPlots(Plot.serialize(s.idx)),
                mj = DuniaLogic.serMesin(Mesin.serializeLahan(s.idx)),
                gd = Gudang and Gudang.serLahan(s.idx) or {},
                dr = Drop and DuniaLogic.serDrops(Drop.serLahan(s.idx)) or {},
                t = os.time(),
        }
        if leaving then
                p.lt = os.time()
        end
        return p
end

local function simpanSekali(s: Seksi, leaving: boolean?): boolean
        local hasil = false
        local ok = pcall(function()
                store:UpdateAsync(DuniaLogic.keyFor(s.ownerId), function()
                        hasil = true
                        return payloadOf(s, leaving)
                end)
        end)
        return ok and hasil
end

local function saveSeksi(s: Seksi, force: boolean, leaving: boolean?)
        if s.ghost or not s.canSave or (not s.dirty and not force) then
                return
        end
        for i = 1, 3 do
                if simpanSekali(s, leaving) then
                        s.dirty = false
                        return
                end
                task.wait(0.4 * i)
        end
end

local function loadWorld(ownerId: number): (boolean, string?, any, any, any, any, any)
        local ok, data = pcall(function()
                return store:GetAsync(DuniaLogic.keyFor(ownerId))
        end)
        if not ok then
                return false, nil, {}, {}, nil, {}, nil
        end
        if type(data) ~= "table" then
                return true, nil, {}, {}, nil, {}, nil
        end
        return true, DuniaLogic.cleanName(data.n), DuniaLogic.desPlots(data.pl), DuniaLogic.desMesin(data.mj), data.gd, data.dr, data.lt
end

local function buildSection(idx: number, ownerId: number, nama: string, ghost: boolean, savedOk: boolean, plots: any, meja: any, gd: any, dr: any, lt: any): Seksi
        local model = WorldBuilder.buildLahan(Hooks, idx, nama)
        Plot.buildGrid(idx, model)
        Plot.restore(idx, plots)
        Plot.startLoop(idx)
        Mesin.restoreLahan(idx, meja, ownerId)
        if Gudang then
                Gudang.restoreLahan(idx, gd)
        end
        if Drop then
                Drop.restoreLahan(idx, dr, lt)
        end
        local s: Seksi = {
                idx = idx,
                ownerId = ownerId,
                ownerName = nama,
                ghost = ghost,
                savedOk = savedOk,
                canSave = savedOk and not ghost,
                dirty = false,
                model = model,
                lastSeen = os.clock(),
        }
        seksi[idx] = s
        return s
end

local function destroySection(idx: number)
        local s = seksi[idx]
        if not s then
                return
        end
        Plot.clearGrid(idx)
        Mesin.clearLahan(idx)
        if Drop then
                Drop.clearLahan(idx)
        end
        if Gudang then
                Gudang.clearLahan(idx)
        end
        s.model:Destroy()
        seksi[idx] = nil
        if byOwner[s.ownerId] == idx then
                byOwner[s.ownerId] = nil
        end
        Land.free(idx, s.ownerId)
end

function ZonaService.masuk(player: Player): (boolean, string)
        local s = ownerSection(player.UserId)
        if s and not s.ghost then
                if placeWait(player, arrivalPos(s.idx), "dunia", s.ownerName) then
                        return true, "Kamu kembali ke duniamu."
                end
                return false, "Karakter belum siap. Coba lagi sebentar."
        end
        if s and s.ghost then
                s.ghost = false
                s.canSave = s.savedOk
                s.dirty = false
                byOwner[player.UserId] = s.idx
                Land.claim(s.idx, player.UserId)
                if placeWait(player, arrivalPos(s.idx), "dunia", s.ownerName) then
                        return true, "Kamu kembali ke duniamu."
                end
                return false, "Karakter belum siap. Coba lagi sebentar."
        end
        local loadOk, namaTersimpan, plots, meja, gd, dr, lt = loadWorld(player.UserId)
        local nama = namaTersimpan or player.Name
        local idx = Land.claimFree(player.UserId, taken)
        if idx <= 0 then
                return false, "Semua petak dunia di server ini sedang terpakai. Coba lagi sebentar."
        end
        buildSection(idx, player.UserId, nama, false, loadOk, plots, meja, gd, dr, lt)
        byOwner[player.UserId] = idx
        if placeWait(player, arrivalPos(idx), "dunia", nama) then
                return true, "Duniamu siap. Masuk dan pulang kini tanpa loading."
        end
        return false, "Karakter belum siap. Duniamu sudah dibuat, coba masuk lagi."
end

function ZonaService.visit(player: Player, namaRaw: any): (boolean, string)
        local nama = DuniaLogic.cleanName(namaRaw)
        if not nama then
                return false, "Nama pemain tidak sah."
        end
        if nama == player.Name then
                return ZonaService.masuk(player)
        end
        for _, p in ipairs(Players:GetPlayers()) do
                if p.Name == nama then
                        local s = ownerSection(p.UserId)
                        if s then
                                if placeWait(player, arrivalPos(s.idx), "dunia", s.ownerName) then
                                        Notify(p, "Tamu Datang", player.Name .. " sedang berkunjung ke duniamu.")
                                        return true, "Kamu berkunjung ke dunia " .. s.ownerName .. ". Semua aksi perubahan terkunci."
                                end
                                return false, "Karakter belum siap. Coba lagi sebentar."
                        end
                        break
                end
        end
        local okId, targetId = pcall(function()
                return Players:GetUserIdFromNameAsync(nama)
        end)
        if not okId or type(targetId) ~= "number" or targetId <= 0 then
                return false, "Nama pemain tidak ditemukan."
        end
        local s = ownerSection(targetId)
        if s then
                if placeWait(player, arrivalPos(s.idx), "dunia", s.ownerName) then
                        return true, "Kamu berkunjung ke dunia " .. s.ownerName .. "."
                end
                return false, "Karakter belum siap. Coba lagi sebentar."
        end
        local loadOk, namaTersimpan, plots, meja, gd, dr, lt = loadWorld(targetId)
        if not loadOk then
                return false, "Dunia " .. nama .. " tidak bisa dikunjungi sekarang."
        end
        if next(plots) == nil and next(meja) == nil and not namaTersimpan then
                return false, nama .. " belum punya dunia."
        end
        local idx = Land.firstFree(taken)
        if idx <= 0 then
                return false, "Semua petak dunia di server ini sedang terpakai."
        end
        if not Land.reserve(idx, targetId) then
                return false, "Petak dunia habis. Coba lagi sebentar."
        end
        local namaDunia = namaTersimpan or nama
        buildSection(idx, targetId, namaDunia, true, loadOk, plots, meja, gd, dr, lt)
        if placeWait(player, arrivalPos(idx), "dunia", namaDunia) then
                return true, "Kamu berkunjung ke dunia " .. namaDunia .. " (salinan tersimpan)."
        end
        return false, "Karakter belum siap. Coba lagi sebentar."
end

function ZonaService.pulang(player: Player): (boolean, string)
        if placeWait(player, kotaPos(), "kota", nil) then
                return true, "Kembali ke Pusat Kota."
        end
        return false, "Karakter belum siap. Coba lagi sebentar."
end

function ZonaService.mutationDeny(player: Player): string?
        if Land.landOf(player) then
                return nil
        end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if root then
                for _, s in pairs(seksi) do
                        if Land.isInside(s.idx, root.Position, 8) then
                                return "Dunia ini milik " .. s.ownerName .. ". Kamu sedang berkunjung."
                        end
                end
        end
        return nil
end

local function insideCount(s: Seksi): number
        local n = 0
        for _, p in ipairs(Players:GetPlayers()) do
                local char = p.Character
                local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
                if root and Land.isInside(s.idx, root.Position, 30) then
                        n += 1
                end
        end
        return n
end

function ZonaService.leaveGame(player: Player)
        zoneOf[player.UserId] = nil
        local idx = byOwner[player.UserId]
        if not idx then
                return
        end
        local s = seksi[idx]
        if s then
                saveSeksi(s, true, true)
        end
        destroySection(idx)
end

function ZonaService.startLoops()
        task.spawn(function()
                local t = 0
                while true do
                        task.wait(20)
                        t += 20
                        for _, s in pairs(seksi) do
                                if s.ghost then
                                        if insideCount(s) > 0 then
                                                s.lastSeen = os.clock()
                                        elseif os.clock() - s.lastSeen > 120 then
                                                destroySection(s.idx)
                                        end
                                end
                        end
                        if t >= DuniaLogic.SaveEvery then
                                t = 0
                                for _, s in pairs(seksi) do
                                        if not s.ghost then
                                                saveSeksi(s, false)
                                        end
                                end
                        end
                end
        end)
end

function ZonaService.shutdown()
        for _, s in pairs(seksi) do
                if not s.ghost then
                        saveSeksi(s, true)
                end
        end
end

return ZonaService
