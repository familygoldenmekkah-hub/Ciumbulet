local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Remotes)

local Modules = script.Modules
local DevCodeVault = require(Modules.DevCodeVault)
local RateLimit = require(Modules.RateLimit)
local DataService = require(Modules.DataService)
local TasService = require(Modules.TasService)
local LandService = require(Modules.LandService)
local PlotService = require(Modules.PlotService)
local SmashService = require(Modules.SmashService)
local ShopService = require(Modules.ShopService)
local ZonaService = require(Modules.ZonaService)
local TanamService = require(Modules.TanamService)
local GudangService = require(Modules.GudangService)
local DropService = require(Modules.DropService)
local WorldBuilder = require(Modules.WorldBuilder)

Net.init()

local function notify(player: Player, title: string, msg: string)
        Net.get("Notify"):FireClient(player, title, msg)
end

local deps = {
        Land = LandService,
        Tas = TasService,
        Data = DataService,
        Net = Net,
        Notify = notify,
        Plot = PlotService,
        Smash = SmashService,
        World = ZonaService,
        Tanam = TanamService,
        Gudang = GudangService,
        Drop = DropService,
}
TasService.bind(DataService)
PlotService.bind(deps)
SmashService.bind(deps)
ShopService.bind(deps)
ZonaService.bind(deps)
TanamService.bind(deps)
GudangService.bind(deps)
DropService.bind(deps)

local function openSemai(player: Player, lahanIdx: number)
        if LandService.ownerOf(lahanIdx) ~= player.UserId then
                notify(player, "Semai Panen", "Hanya pemilik dunia yang bisa memakai meja ini.")
                return
        end
        SmashService.syncTo(player, lahanIdx)
        Net.get("OpenPanel"):FireClient(player, "semai", { lahan = lahanIdx })
end

local function openTanam(player: Player, lahanIdx: number)
        if LandService.ownerOf(lahanIdx) ~= player.UserId then
                Net.get("OpenPanel"):FireClient(player, "tanam", { tamu = true })
                return
        end
        TanamService.syncTo(player)
        Net.get("OpenPanel"):FireClient(player, "tanam", {})
end

local function openGudang(player: Player, lahanIdx: number)
        if LandService.ownerOf(lahanIdx) ~= player.UserId then
                notify(player, "Gudang", "Hanya pemilik dunia yang bisa memakai gudang ini.")
                return
        end
        GudangService.syncTo(player, lahanIdx)
        Net.get("OpenPanel"):FireClient(player, "gudang", {})
end

local function openShop(player: Player)
        if not ShopService.near(player, 45) then
                notify(player, "Toko Benih", "Dekati kasir atau rak benih dulu.")
                return
        end
        Net.get("OpenPanel"):FireClient(player, "toko", {})
end

local hooks = {
        onSemaiPrompt = openSemai,
        onShopPrompt = openShop,
        onGerbangDunia = function(player: Player)
                Net.get("OpenPanel"):FireClient(player, "gerbang", {})
        end,
        onPulang = function(player: Player)
                ZonaService.pulang(player)
        end,
        onPapanPrompt = openTanam,
        onGudangPrompt = openGudang,
        registerTable = SmashService.registerTable,
        setShopPoint = ShopService.setShopPoint,
        registerBoard = function(index: number, label: TextLabel, pos: Vector3)
                PlotService.setBoard(index, label)
                TanamService.setPoint(index, pos)
        end,
        setGudangPoint = GudangService.setPoint,
        registerKota = LandService.registerKota,
        registerUmum = LandService.registerUmum,
}
ZonaService.setHooks(hooks)
DataService.setZoneProvider(ZonaService.zoneOf)

WorldBuilder.buildHub(hooks)

local function applySpawn(player: Player)
        local target = LandService.kotaSpawn() or LandService.umumSpawn()
        if target then
                player.RespawnLocation = target
        end
end

local function enterServer(player: Player)
        local ok = DataService.load(player)
        local leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        local micda = Instance.new("IntValue")
        micda.Name = "Micda"
        local d = DataService.get(player)
        micda.Value = d and math.floor(d.m) or 0
        micda.Parent = leaderstats
        leaderstats.Parent = player
        applySpawn(player)
        DataService.push(player)
        task.delay(4, function()
                if player.Parent then
                        if ok then
                                notify(player, "Pusat Kota", "Selamat datang! Lewati Gerbang Dunia atau tombol Masuk untuk ke duniamu.")
                        else
                                notify(player, "Mode Sesi", "Progres sementara hanya tersimpan di sesi ini.")
                        end
                end
        end)
end

local function onPlayerAdded(player: Player)
        enterServer(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, p in ipairs(Players:GetPlayers()) do
        task.spawn(onPlayerAdded, p)
end

Players.PlayerRemoving:Connect(function(player)
        TanamService.leave(player)
        ZonaService.leaveGame(player)
        DataService.save(player)
        RateLimit.clear(player.UserId)
        DataService.drop(player)
end)

game:BindToClose(function()
        ZonaService.shutdown()
        for _, p in ipairs(Players:GetPlayers()) do
                DataService.save(p)
        end
end)

Net.get("GetState").OnServerInvoke = function(player)
        local d = DataService.get(player)
        if not d then
                return nil
        end
        local zone, dunia = ZonaService.zoneOf(player)
        local lahan = LandService.landOf(player)
        local role = "hub"
        if zone == "dunia" then
                role = lahan and "pemilik" or "tamu"
        end
        return {
                micda = math.floor(d.m),
                tas = d.t,
                lahan = lahan,
                zone = zone,
                role = role,
                dunia = dunia,
        }
end

Net.get("DuniaAct").OnServerInvoke = function(player, action, arg)
        if not RateLimit.allow(player.UserId, "dunia", 2, 3) then
                return false, "Terlalu cepat."
        end
        if action == "masuk" then
                return ZonaService.masuk(player)
        elseif action == "kunjungi" then
                return ZonaService.visit(player, arg)
        elseif action == "pulang" then
                return ZonaService.pulang(player)
        end
        return false, "Aksi tidak dikenal."
end

Net.get("PlotAct").OnServerInvoke = function(player, idx, action)
        if not RateLimit.allow(player.UserId, "punch", 10, 14) then
                return false, "Terlalu cepat."
        end
        if action == "punch" then
                return PlotService.punch(player, idx)
        end
        return false, "Aksi tidak dikenal."
end

Net.get("TanamAct").OnServerInvoke = function(player, action, a, b)
        if not RateLimit.allow(player.UserId, "tanam", 3, 6) then
                return false, "Terlalu cepat."
        end
        if action == "start" then
                return TanamService.start(player, a, b)
        elseif action == "jawab" then
                return TanamService.jawab(player, a)
        elseif action == "gabung" then
                return TanamService.gabung(player, a, b)
        elseif action == "status" then
                return true, TanamService.statusPayload(player)
        elseif action == "batal" then
                return TanamService.batal(player)
        end
        return false, "Aksi tidak dikenal."
end

Net.get("GudangAct").OnServerInvoke = function(player, action, a, b)
        if not RateLimit.allow(player.UserId, "gudang", 3, 6) then
                return false, "Terlalu cepat."
        end
        if action == "simpan" then
                return GudangService.simpan(player, a, b)
        elseif action == "ambil" then
                return GudangService.ambil(player, a, b)
        end
        return false, "Aksi tidak dikenal."
end

Net.get("SmashAct").OnServerInvoke = function(player, action, arg)
        if not RateLimit.allow(player.UserId, "smash", 5, 8) then
                return false, "Terlalu cepat."
        end
        local deny = ZonaService.mutationDeny(player)
        if deny then
                return false, deny
        end
        if action == "place" then
                return SmashService.place(player, arg)
        elseif action == "hit" then
                return SmashService.hit(player, arg)
        elseif action == "take" then
                return SmashService.take(player, arg)
        end
        return false, "Aksi tidak dikenal."
end

Net.get("ShopAct").OnServerInvoke = function(player, action, a, b)
        if not RateLimit.allow(player.UserId, "shop", 5, 10) then
                return false, "Terlalu cepat."
        end
        if action == "buy" then
                return ShopService.buy(player, a)
        elseif action == "sell" then
                return ShopService.sell(player, a, b)
        end
        return false, "Aksi tidak dikenal."
end

Net.get("RedeemDevCode").OnServerInvoke = function(player, code)
        local d = DataService.get(player)
        if not d then
                return false, "Data belum siap."
        end
        if type(code) ~= "string" or code ~= DevCodeVault.CODE then
                return false, "Kode salah."
        end
        if d.dev then
                return false, "Kode sudah pernah dipakai."
        end
        d.dev = true
        DataService.markDirty(player)
        DataService.push(player)
        return true, "Status dev aktif. Terima kasih, pemilik dunia!"
end

DataService.startLoops()
ZonaService.startLoops()

print("[AKIOMIDA] Papan Tanam, Combine Seed, panen Punch, dan Gudang siap dalam satu server.")
