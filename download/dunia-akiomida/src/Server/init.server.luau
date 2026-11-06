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
local CombineService = require(Modules.CombineService)
local ShopService = require(Modules.ShopService)
local GateService = require(Modules.GateService)
local WorldBuilder = require(Modules.WorldBuilder)

Net.init()

local function notify(player: Player, title: string, msg: string)
        Net.get("Notify"):FireClient(player, title, msg)
end

local deps = { Land = LandService, Tas = TasService, Data = DataService, Net = Net, Notify = notify }
TasService.bind(DataService)
PlotService.bind(deps)
SmashService.bind(deps)
CombineService.bind(deps)
ShopService.bind(deps)
GateService.bind(deps)

local function openSemai(player: Player, lahanIdx: number)
        if LandService.ownerOf(lahanIdx) ~= player.UserId then
                notify(player, "Semai Panen", "Hanya pemilik lahan yang bisa memakai meja ini.")
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

WorldBuilder.build({
        onSemaiPrompt = openSemai,
        onShopPrompt = openShop,
        registerTable = SmashService.registerTable,
        setShopPoint = ShopService.setShopPoint,
        registerUmum = LandService.registerUmum,
        onGate = function(player: Player, target: string)
                GateService.travel(player, target)
        end,
})

Net.get("GetState").OnServerInvoke = function(player)
        local d = DataService.get(player)
        if not d then
                return nil
        end
        return {
                micda = math.floor(d.m),
                tas = d.t,
                lahan = LandService.landOf(player),
                zone = GateService.zoneOf(player),
        }
end

Net.get("PlotAct").OnServerInvoke = function(player, idx, action, cropId)
        if not RateLimit.allow(player.UserId, "plot", 6, 8) then
                return false, "Terlalu cepat."
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

local function applySpawn(player: Player)
        local zone = GateService.zoneOf(player)
        local target: SpawnLocation? = nil
        if zone == "kota" then
                target = LandService.kotaSpawn()
        else
                local idx = LandService.landOf(player)
                if idx then
                        target = LandService.spawnOf(idx)
                end
                if not target then
                        target = LandService.umumSpawn()
                end
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

local function onPlayerAdded(player: Player)
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

        GateService.setZone(player, "lahan")
        local idx = LandService.assign(player)
        if idx > 0 then
                PlotService.buildGrid(idx)
                local sp = LandService.spawnOf(idx)
                if sp then
                        sp.Enabled = true
                end
                SmashService.syncTo(player, idx)
                notify(player, "Lahan " .. idx, "Lahan ini milikmu. Kamu selalu lahir kembali di sini.")
        else
                notify(player, "Lahan Penuh", "Semua lahan sedang dipakai. Kamu masih bisa berkunjung.")
        end
        applySpawn(player)
        DataService.push(player)
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
                PlotService.clearGrid(idx)
                local sp = LandService.spawnOf(idx)
                if sp then
                        sp.Enabled = false
                end
                LandService.release(player)
        end
        GateService.clear(player)
        RateLimit.clear(player.UserId)
        DataService.drop(player)
end)

DataService.startLoops()

print("[AKIOMIDA] Tahap 1 siap: lahan, pusat kota, semai panen, combine seed.")
