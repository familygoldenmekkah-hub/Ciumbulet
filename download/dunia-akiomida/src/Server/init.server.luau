local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UangLogic = require(ReplicatedStorage.Shared.UangLogic)
local Net = require(ReplicatedStorage.Remotes)

local Modules = script.Modules
local DevCodeVault = require(Modules.DevCodeVault)
local RateLimit = require(Modules.RateLimit)
local AuditService = require(Modules.AuditService)
local DataService = require(Modules.DataService)
local CurrencyService = require(Modules.CurrencyService)
local TasService = require(Modules.TasService)
local LandService = require(Modules.LandService)
local PlotService = require(Modules.PlotService)
local MesinSemaiService = require(Modules.MesinSemaiService)
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

CurrencyService.bind({ Data = DataService, Audit = AuditService })
AuditService.bind({
        Data = DataService,
        Simpan = function(p: Player)
                DataService.markDirty(p)
                DataService.save(p)
        end,
})

local function denganTransaksi(player: Player, fn)
        AuditService.transaksiMulai(player)
        local ok, a, b, c = pcall(fn)
        AuditService.transaksiSelesai(player)
        if not ok then
                return false, "Terjadi galat. Coba lagi."
        end
        return a, b, c
end

local deps = {
        Land = LandService,
        Tas = TasService,
        Data = DataService,
        Uang = CurrencyService,
        Audit = AuditService,
        Net = Net,
        Notify = notify,
        Plot = PlotService,
        Mesin = MesinSemaiService,
        World = ZonaService,
        Tanam = TanamService,
        Gudang = GudangService,
        Drop = DropService,
}
TasService.bind(DataService)
PlotService.bind(deps)
MesinSemaiService.bind(deps)
ShopService.bind(deps)
ZonaService.bind(deps)
TanamService.bind(deps)
GudangService.bind(deps)
DropService.bind(deps)

local function openSemai(player: Player, lahanIdx: number)
        if LandService.ownerOf(lahanIdx) ~= player.UserId then
                notify(player, "Semai Panen", "Hanya pemilik dunia yang bisa memakai mesin ini.")
                return
        end
        MesinSemaiService.syncTo(player, lahanIdx)
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
        onTuasPrompt = function(player: Player, _lahanIdx: number, sisi: string)
                local ok, msg = MesinSemaiService.tekan(player, sisi)
                if not ok then
                        notify(player, "Mesin Semai", tostring(msg))
                end
        end,
        onShopPrompt = openShop,
        onGerbangDunia = function(player: Player)
                Net.get("OpenPanel"):FireClient(player, "gerbang", {})
        end,
        onPulang = function(player: Player)
                ZonaService.pulang(player)
        end,
        onPapanPrompt = openTanam,
        onGudangPrompt = openGudang,
        registerMesin = MesinSemaiService.registerMesin,
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
DataService.setLahanProvider(LandService.landOf)

WorldBuilder.buildHub(hooks)

local function applySpawn(player: Player)
        local target = LandService.kotaSpawn() or LandService.umumSpawn()
        if target then
                player.RespawnLocation = target
        end
end

local function enterServer(player: Player)
        print("DEBUG-enterServer", player.Name)
        local ok, alasan, dibuang = DataService.load(player)
        print("DEBUG-load", player.Name, ok, alasan)
        local d = DataService.get(player)
        local leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        local micda = Instance.new("IntValue")
        micda.Name = "Micda"
        micda.Value = d and UangLogic.saldo(d.u) or 0
        micda.Parent = leaderstats
        leaderstats.Parent = player
        print("DEBUG-leaderstats", player.Name)
        applySpawn(player)
        DataService.push(player)
        task.delay(4, function()
                if player.Parent then
                        if dibuang and dibuang > 0 then
                                notify(player, "Tas Dibersihkan", tostring(dibuang) .. " item lama yang tidak dipakai sudah dibuang otomatis dari tas.")
                        end
                        if ok then
                                notify(player, "Pusat Kota", "Selamat datang! Lewati Gerbang Dunia atau tombol Masuk untuk ke duniamu.")
                        else
                                if alasan == "kunci" then
                                        AuditService.catat(player, "sesi_ganda", "load")
                                end
                                notify(player, "Sinkronisasi", "Data kamu sedang disinkronkan — progres kamu aman.")
                                task.spawn(function()
                                        while player.Parent and not DataService.bolehSimpan(player) do
                                                task.wait(8)
                                                if DataService.cobaSinkron(player) and player.Parent then
                                                        notify(player, "Sinkronisasi", "Data kamu sudah tersinkron. Selamat bermain!")
                                                end
                                        end
                                end)
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

local function tutupSesi(player: Player)
        TanamService.leave(player)
        ZonaService.leaveGame(player)
        DataService.save(player)
        RateLimit.clear(player.UserId)
        AuditService.bersih(player.UserId)
        DataService.drop(player)
end

Players.PlayerRemoving:Connect(tutupSesi)

game:BindToClose(function()
        ZonaService.shutdown()
        for _, p in ipairs(Players:GetPlayers()) do
                tutupSesi(p)
        end
end)

local function lajuDitolak(player: Player, kunci: string)
        AuditService.catat(player, "laju", kunci)
        return false, "Terlalu cepat."
end

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
                micda = UangLogic.saldo(d.u),
                tas = d.t,
                lahan = lahan,
                zone = zone,
                role = role,
                dunia = dunia,
        }
end

Net.get("DuniaAct").OnServerInvoke = function(player, action, arg)
        if not RateLimit.allow(player.UserId, "dunia", 2, 3) then
                return lajuDitolak(player, "dunia")
        end
        if action == "masuk" then
                return ZonaService.masuk(player)
        elseif action == "kunjungi" then
                if type(arg) ~= "string" then
                        AuditService.catat(player, "argumen", "kunjungi")
                        return false, "Nama tidak sah."
                end
                return ZonaService.visit(player, arg)
        elseif action == "pulang" then
                return ZonaService.pulang(player)
        end
        AuditService.catat(player, "argumen", "dunia:" .. tostring(action))
        return false, "Aksi tidak dikenal."
end

Net.get("PlotAct").OnServerInvoke = function(player, idx, action)
        if not RateLimit.allow(player.UserId, "punch", 12, 18) then
                return lajuDitolak(player, "punch")
        end
        if action == "punch" then
                return denganTransaksi(player, function()
                        return PlotService.punch(player, idx)
                end)
        end
        AuditService.catat(player, "argumen", "plot:" .. tostring(action))
        return false, "Aksi tidak dikenal."
end

Net.get("TanamAct").OnServerInvoke = function(player, action, a, b)
        if not RateLimit.allow(player.UserId, "tanam", 6, 10) then
                return lajuDitolak(player, "tanam")
        end
        if action == "start" then
                return denganTransaksi(player, function()
                        return TanamService.start(player, a, b)
                end)
        elseif action == "jawab" then
                return denganTransaksi(player, function()
                        return TanamService.jawab(player, a)
                end)
        elseif action == "gabung" then
                return denganTransaksi(player, function()
                        return TanamService.gabung(player, a, b)
                end)
        elseif action == "status" then
                return true, TanamService.statusPayload(player)
        elseif action == "batal" then
                return TanamService.batal(player)
        end
        AuditService.catat(player, "argumen", "tanam:" .. tostring(action))
        return false, "Aksi tidak dikenal."
end

Net.get("GudangAct").OnServerInvoke = function(player, action, a, b)
        if not RateLimit.allow(player.UserId, "gudang", 6, 10) then
                return lajuDitolak(player, "gudang")
        end
        if action == "simpan" then
                return denganTransaksi(player, function()
                        return GudangService.simpan(player, a, b)
                end)
        elseif action == "ambil" then
                return denganTransaksi(player, function()
                        return GudangService.ambil(player, a, b)
                end)
        end
        AuditService.catat(player, "argumen", "gudang:" .. tostring(action))
        return false, "Aksi tidak dikenal."
end

Net.get("SemaiAct").OnServerInvoke = function(player, action, a, b)
        if not RateLimit.allow(player.UserId, "semai", 8, 12) then
                return lajuDitolak(player, "semai")
        end
        local deny = ZonaService.mutationDeny(player)
        if deny then
                return false, deny
        end
        if action == "atur" then
                return denganTransaksi(player, function()
                        return MesinSemaiService.atur(player, a, b)
                end)
        elseif action == "tuas" then
                return denganTransaksi(player, function()
                        return MesinSemaiService.tekan(player, a)
                end)
        elseif action == "klaim" then
                return denganTransaksi(player, function()
                        return MesinSemaiService.klaim(player)
                end)
        end
        AuditService.catat(player, "argumen", "semai:" .. tostring(action))
        return false, "Aksi tidak dikenal."
end

Net.get("ShopAct").OnServerInvoke = function(player, action, a, b)
        if not RateLimit.allow(player.UserId, "shop", 8, 14) then
                return lajuDitolak(player, "shop")
        end
        if action == "buy" then
                return denganTransaksi(player, function()
                        return ShopService.buy(player, a)
                end)
        elseif action == "sell" then
                return denganTransaksi(player, function()
                        return ShopService.sell(player, a, b)
                end)
        end
        AuditService.catat(player, "argumen", "shop:" .. tostring(action))
        return false, "Aksi tidak dikenal."
end

Net.get("RedeemDevCode").OnServerInvoke = function(player, code)
        local d = DataService.get(player)
        if not d then
                return false, "Data belum siap."
        end
        if type(code) ~= "string" or code ~= DevCodeVault.CODE then
                AuditService.catat(player, "argumen", "kode_salah")
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
CurrencyService.startIntegritas()

print("[AKIOMIDA] Server-authoritative: ekonomi 1000T, deteksi anomali tanpa batas angka tetap, transaksi terjaga, kick aman-data siap.")
