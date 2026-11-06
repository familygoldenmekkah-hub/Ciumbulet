local TeleportService = game:GetService("TeleportService")

local PlaceConfig = require(script.Parent.PlaceConfig)

local GateService = {}

local Land, Notify
local zoneOf: { [number]: string } = {}

function GateService.bind(deps)
        Land = deps.Land
        Notify = deps.Notify
end

function GateService.zoneOf(player): string
        return zoneOf[player.UserId] or "lahan"
end

function GateService.setZone(player, zone: string)
        zoneOf[player.UserId] = zone
end

function GateService.clear(player)
        zoneOf[player.UserId] = nil
end

local function destinationSpawn(target: string, player): (Vector3, SpawnLocation?)
        if target == "kota" then
                local sp = Land.kotaSpawn()
                if sp then
                        return sp.Position + Vector3.new(0, 4, 0), sp
                end
                return Vector3.new(0, 6, 0), nil
        end
        local index = Land.landOf(player)
        if index then
                local sp = Land.spawnOf(index)
                if sp then
                        return sp.Position + Vector3.new(0, 4, 0), sp
                end
        end
        local umum = Land.umumSpawn()
        if umum then
                return umum.Position + Vector3.new(0, 4, 0), umum
        end
        return Vector3.new(0, 6, 0), nil
end

function GateService.travel(player: Player, target: string)
        if target == "kota" and PlaceConfig.useTeleport() then
                TeleportService:TeleportAsync(PlaceConfig.KotaPlaceId, { player })
                return
        end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not root then
                return
        end
        local pos, sp = destinationSpawn(target, player)
        GateService.setZone(player, target)
        if sp then
                player.RespawnLocation = sp
        end
        root.CFrame = CFrame.new(pos)
        if target == "kota" then
                Notify(player, "Pusat Kota", "Selamat datang di Pusat Kota. Gerbang di dekatmu kembali ke lahan.")
        else
                Notify(player, "Lahan", "Kamu kembali di lahanku.")
        end
end

function GateService.attach(framePart: BasePart, target: string, label: string)
        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = label
        prompt.ObjectText = "Gerbang"
        prompt.HoldDuration = 0.4
        prompt.MaxActivationDistance = 14
        prompt.RequiresLineOfSight = false
        prompt.Parent = framePart
        prompt.Triggered:Connect(function(player)
                GateService.travel(player, target)
        end)
end

return GateService
