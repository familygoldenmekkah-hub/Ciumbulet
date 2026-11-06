local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Remotes)
local DuniaLogic = require(ReplicatedStorage.Shared.DuniaLogic)

local Modules = script.Modules
local DevCodeVault = require(Modules.DevCodeVault)
local RateLimit = require(Modules.RateLimit)
local DataService = require(Modules.DataService)
local TasService = require(Modules.TasService)
local LandService = require(Modules.LandService)
local PlotService = require(Modules.PlotService)
local SmashService = require(Modules.SmashService)
local CombineService = require(Modules.CombineService)
local ShopService = require(Modules.ShopService)
local DuniaService = require(Modules.DuniaService)
local WorldBuilder = require(Modules.WorldBuilder)

Net.init()

local serverMode: string? = nil
local duniaReady = false
local hubReady = false

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
        World = DuniaService,
}
TasService.bind(DataService)
PlotService.bind(deps)
SmashService.bind(deps)
CombineService.bind(deps)
ShopService.bind(deps)
DuniaService.bind(deps)

local function openSemai(player: Player, lahanIdx: number)
        if LandService.ownerOf(lahanIdx) ~= player.UserId then
                notify(player, "Semai Panen", "Hanya pemilik dunia yang bisa memakai meja ini.")
                return
        end
        SmashService.syncTo(player, lahanIdx)
        Net.get("OpenPanel"):FireClient(player, "semai", { lahan = lahanIdx })
end

local function openShop(player: Player)
        if not ShopService.near(player, 30) then
                notify(player, "Toko Benih", "Terlalu jauh dari kasir.")
                return
        end
        Net.get("OpenPanel"):FireClient(player, "toko", {})
end

local hooks = {
        onSemaiPrompt = openSemai,
        onShopPrompt = openShop,
        onGabung = function(player: Player)
                Net.get("OpenPanel"):FireClient(player, "combine", {})
        end,
        onGerbangDunia = function(player: Player)
                Net.get("OpenPanel"):FireClient(player, "gerbang", {})
        end,
        onPulang = function(player: Player)
                DuniaService.pulang(player)
        end,
        registerTable = SmashService.registerTable,
        setShopPoint = ShopService.setShopPoint,
        setCombinePoint = CombineService.setCombinePoint,
        registerUmum = LandService.registerUmum,
        registerKota = LandService.registerKota,
        registerSpawn = LandService.registerSpawn,
}

local function setupHub()
        hubReady = true
        WorldBuilder.buildHub(hooks)
end

local function setupDunia(pemilik: number, nama: string?)
        duniaReady = true
        DuniaService.setOwner(pemilik, nama)
        WorldBuilder.buildDunia(hooks, DuniaService.ownerName())
        if not nama or #nama == 0 then
                task.spawn(function()
                        local ok, fetched = pcall(function()
                                return Players:GetNameFromUserIdAsync(pemilik)
                        end)
                        if ok and type(fetched) == "string" then
                                DuniaService.setOwner(pemilik, fetched)
                        end
                end)
        end
        PlotService.buildGrid(1)
        DuniaService.loadWorld()
end

local function applySpawn(player: Player)
        local target: SpawnLocation? = nil
        if serverMode == "dunia" then
                local idx = LandService.landOf(player)
                if idx then
                        target = LandService.spawnOf(idx)
                end
                if not target then
                        target = LandService.umumSpawn()
                end
        else
                target = LandService.kotaSpawn() or LandService.umumSpawn()
        end
        if target then
                player.RespawnLocation = target
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
                if root then
                        root.CFrame = target.CFrame + Vector3.new(0, 4, 0)
                end
        end
end

local function enterHub(player: Player)
        local ok = DataService.load(player)
        if not ok then
                task.delay(5, function()
                        if player.Parent then
                                notify(player, "Mode Sesi", "Progres sementara hanya tersimpan di sesi ini.")
                        end
                end)
        end
        local leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        local micda = Instance.new("IntValue")
        micda.Name = "Micda"
        local d = DataService.get(player)
        micda.Value = d and math.floor(d.m) or 0
        micda.Parent = leaderstats
        leaderstats.Parent = player
        DuniaService.setRole(player, "hub")
        applySpawn(player)
        DataService.push(player)
        notify(player, "Pusat Kota", "Selamat datang! Lewati Gerbang Dunia untuk masuk ke duniamu sendiri.")
end

local function enterDunia(player: Player, pemilik: number)
        local ok = DataService.load(player)
        if not ok then
                task.delay(5, function()
                        if player.Parent then
                                notify(player, "Mode Sesi", "Progres sementara hanya tersimpan di sesi ini.")
                        end
                end)
        end
        local leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        local micda = Instance.new("IntValue")
        micda.Name = "Micda"
        local d = DataService.get(player)
        micda.Value = d and math.floor(d.m) or 0
        micda.Parent = leaderstats
        leaderstats.Parent = player
        if player.UserId == pemilik and pemilik == DuniaService.ownerId() then
                DuniaService.setRole(player, "pemilik")
                local idx = LandService.assign(player)
                if idx > 0 then
                        PlotService.buildGrid(idx)
                        local sp = LandService.spawnOf(idx)
                        if sp then
                                sp.Enabled = true
                        end
                        SmashService.syncTo(player, idx)
                end
                PlotService.startLoop(1)
                notify(player, "Duniamu", "Semua yang ada di sini milikmu. Tamu tidak bisa mengubah apa pun.")
        else
                DuniaService.setRole(player, "tamu")
                notify(player, "Mode Kunjung", "Dunia milik " .. DuniaService.ownerName() .. ". Kamu bisa melihat-lihat, tapi tidak bisa mengubah.")
        end
        DuniaService.startLoops()
        applySpawn(player)
        DataService.push(player)
end

local function onPlayerAdded(player: Player)
        local jd = player:GetJoinData()
        local joinData = (jd :: any).TeleportData
        local mode = DuniaLogic.modeOf(joinData)
        local pemilik = DuniaLogic.ownerOf(joinData)
        local nama = nil
        if type(joinData) == "table" and type(joinData.nama) == "string" then
                nama = joinData.nama
        end

        if serverMode == nil then
                serverMode = mode
        end

        if serverMode == "dunia" then
                if not duniaReady then
                        if pemilik <= 0 then
                                notify(player, "Sambungan Bingung", "Dunia tidak dikenali. Mengembalikanmu ke Pusat Kota.")
                                DuniaService.pulang(player)
                                return
                        end
                        setupDunia(pemilik, nama)
                end
                enterDunia(player, pemilik > 0 and pemilik or DuniaService.ownerId())
        else
                if game.PrivateServerId ~= "" then
                        if duniaReady then
                                enterDunia(player, DuniaService.ownerId())
                        else
                                notify(player, "Sambungan Bingung", "Dunia tidak dikenali. Mengembalikanmu ke Pusat Kota.")
                                DuniaService.pulang(player)
                        end
                        return
                end
                if not hubReady then
                        setupHub()
                end
                enterHub(player)
        end
end

Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
                task.wait(0.1)
                applySpawn(player)
        end)
        onPlayerAdded(player)
end)
for _, p in ipairs(Players:GetPlayers()) do
        p.CharacterAdded:Connect(function()
                task.wait(0.1)
                applySpawn(p)
        end)
        task.spawn(onPlayerAdded, p)
end

Players.PlayerRemoving:Connect(function(player)
        local idx = LandService.landOf(player)
        if idx then
                SmashService.refundLahan(idx, player)
        end
        DataService.save(player)
        if idx then
                SmashService.clearLahan(idx)
                local sp = LandService.spawnOf(idx)
                if sp then
                        sp.Enabled = false
                end
                LandService.release(player)
        end
        DuniaService.forget(player)
        RateLimit.clear(player.UserId)
        DataService.drop(player)
        if serverMode == "dunia" then
                if player.UserId == DuniaService.ownerId() then
                        DuniaService.saveWorld()
                end
                if #Players:GetPlayers() <= 1 then
                        DuniaService.closeWorld()
                end
        end
end)

game:BindToClose(function()
        if serverMode == "dunia" then
                DuniaService.closeWorld()
        end
        for _, p in ipairs(Players:GetPlayers()) do
                DataService.save(p)
        end
end)

Net.get("GetState").OnServerInvoke = function(player)
        local d = DataService.get(player)
        if not d then
                return nil
        end
        return {
                micda = math.floor(d.m),
                tas = d.t,
                lahan = LandService.landOf(player),
                zone = serverMode == "dunia" and "dunia" or "kota",
                role = DuniaService.roleOf(player),
                dunia = serverMode == "dunia" and DuniaService.ownerName() or nil,
        }
end

Net.get("DuniaAct").OnServerInvoke = function(player, action, arg)
        if not RateLimit.allow(player.UserId, "dunia", 2, 3) then
                return false, "Terlalu cepat."
        end
        if action == "masuk" then
                return DuniaService.enter(player)
        elseif action == "kunjungi" then
                return DuniaService.visit(player, arg)
        elseif action == "pulang" then
                return DuniaService.pulang(player)
        end
        return false, "Aksi tidak dikenal."
end

Net.get("PlotAct").OnServerInvoke = function(player, idx, action, cropId)
        if not RateLimit.allow(player.UserId, "plot", 6, 8) then
                return false, "Terlalu cepat."
        end
        if DuniaService.roleOf(player) ~= "pemilik" and serverMode == "dunia" then
                return false, "Dunia ini milik " .. DuniaService.ownerName() .. ". Kamu sedang berkunjung."
        end
        if action == "plant" then
                return PlotService.plant(player, idx, cropId)
        elseif action == "harvest" then
                return PlotService.harvest(player, idx)
        end
        return false, "Aksi tidak dikenal."
end

Net.get("CombineAct").OnServerInvoke = function(player, a, b)
        if not RateLimit.allow(player.UserId, "combine", 2, 3) then
                return false, "Terlalu cepat."
        end
        return CombineService.combine(player, a, b)
end

Net.get("SmashAct").OnServerInvoke = function(player, action, arg)
        if not RateLimit.allow(player.UserId, "smash", 5, 8) then
                return false, "Terlalu cepat."
        end
        if DuniaService.roleOf(player) ~= "pemilik" and serverMode == "dunia" then
                return false, "Dunia ini milik " .. DuniaService.ownerName() .. ". Kamu sedang berkunjung."
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
        if not RateLimit.allow(player.UserId, "shop", 3, 5) then
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

if serverMode == "dunia" then
        print("[AKIOMIDA] Server dunia pribadi siap.")
else
        print("[AKIOMIDA] Pusat Kota siap. Gerbang dunia menunggu pemain.")
end
