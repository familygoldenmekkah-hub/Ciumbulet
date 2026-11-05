--!nonstrict
--[[
        GatherService.luau - aktivitas mengumpulkan sumber daya:
          Hutan Kayu   : tebang pohon -> Kayu (+Apel keberuntungan)
          Tambang (Pulau Panen) : tambang Batu (belik lv1), Besi (lv2), Kristal (lv3)
          Danau Tenang : memancing (butuh Pancing Ajaib)
        Semua node respawn otomatis supaya dunia tetap hidup.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Remotes)

local DataService = require(script.Parent.DataService)
local QuestService = require(script.Parent.QuestService)

local GatherService = {}

local RESPAWN_TREE = 90
local RESPAWN_ROCK = 120
local FISH_COOLDOWN = 4

local resourceById: { [string]: any } = {}
for _, res in ipairs(Config.Resources) do
        resourceById[res.id] = res
end
local fishById: { [string]: any } = {}
for _, fish in ipairs(Config.Fish) do
        fishById[fish.id] = fish
end

-- tier bijih: batu=1, besi=2, kristal=3 (butuh belik setingkat itu)
local ROCK_TIER: { [string]: number } = { batu = 1, besi = 2, kristal = 3 }

local fishCooldown: { [Player]: number } = {}

local function world(): Folder
        local f = workspace:FindFirstChild("AKM_Dunia")
        if not f then
                f = Instance.new("Folder")
                f.Name = "AKM_Dunia"
                f.Parent = workspace
        end
        return f :: Folder
end

local function part(props): Part
        local p = Instance.new("Part")
        p.Anchored = true
        p.TopSurface = Enum.SurfaceType.Smooth
        p.BottomSurface = Enum.SurfaceType.Smooth
        for k, v in props do
                (p :: any)[k] = v
        end
        p.Parent = world()
        return p
end

local function notify(player: Player, title: string, text: string)
        Remotes.get("Notify"):FireClient(player, title, text)
end

--------------------------------------------------------------------
-- TEbang POHON
--------------------------------------------------------------------

function GatherService.buildTree(position: Vector3, seed: number?)
        local rng = Random.new(seed or tick() * 1000)
        local trunkH = rng:NextNumber(8, 12)
        local parts = {}

        local trunk = part({
                Name = "PohonBatang",
                Size = Vector3.new(2, trunkH, 2),
                CFrame = CFrame.new(position + Vector3.new(0, trunkH / 2, 0)) * CFrame.Angles(0, rng:NextNumber(0, math.pi), 0),
                Color = Color3.fromRGB(105, 74, 46),
                Material = Enum.Material.Wood,
        })
        table.insert(parts, trunk)

        for i = 1, 3 do
                local canopy = part({
                        Name = "PohonDaun" .. i,
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(1, 1, 1) * rng:NextNumber(6, 9),
                        CFrame = CFrame.new(position + Vector3.new(rng:NextNumber(-1.6, 1.6), trunkH + rng:NextNumber(-1, 2.4), rng:NextNumber(-1.6, 1.6))),
                        Color = Color3.fromRGB(rng:NextInteger(52, 84), rng:NextInteger(140, 175), rng:NextInteger(74, 100)),
                        Material = Enum.Material.Grass,
                })
                table.insert(parts, canopy)
        end

        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Tebang"
        prompt.ObjectText = "Pohon Kayu"
        prompt.MaxActivationDistance = 10
        prompt.HoldDuration = 1
        prompt.Parent = trunk

        local node = { alive = true, parts = parts, prompt = prompt }

        prompt.Triggered:Connect(function(player)
                if not node.alive or not DataService.has(player) then
                        return
                end
                node.alive = false
                local amount = rng:NextInteger(1, 2)
                DataService.giveItem(player, "bag", "kayu", amount)
                DataService.addXP(player, 3)
                QuestService.progress(player, "chop", 1)
                if rng:NextNumber() < 0.2 then
                        DataService.giveItem(player, "bag", "apel", 1)
                        notify(player, "Keberuntungan!", "Apel jatuh dari pohon! +" .. amount .. " Kayu, +1 Apel")
                else
                        notify(player, "Menebang", "+" .. amount .. " Kayu")
                end
                DataService.push(player)

                for _, p in parts do
                        p.Transparency = 1
                        p.CanCollide = false
                end
                prompt.Enabled = false
                task.delay(RESPAWN_TREE, function()
                        for _, p in parts do
                                p.Transparency = 0
                                p.CanCollide = true
                        end
                        node.alive = true
                        prompt.Enabled = true
                end)
        end)
end

--------------------------------------------------------------------
-- TAMBAANG BIJIH
--------------------------------------------------------------------

local function rockVisual(position: Vector3, tier: number, seed: number)
        local rng = Random.new(seed)
        local parts = {}

        local baseColor
        local material
        if tier == 1 then
                baseColor = Color3.fromRGB(120, 120, 125)
                material = Enum.Material.Slate
        elseif tier == 2 then
                baseColor = Color3.fromRGB(158, 108, 78)
                material = Enum.Material.Rock
        else
                baseColor = Color3.fromRGB(105, 88, 150)
                material = Enum.Material.Slate
        end

        local main = part({
                Name = "BatuUtan",
                Shape = Enum.PartType.Ball,
                Size = Vector3.new(1, 1, 1) * rng:NextNumber(4.5, 6.5),
                CFrame = CFrame.new(position + Vector3.new(0, 1.6, 0)) * CFrame.Angles(0, rng:NextNumber(0, math.pi), math.rad(rng:NextNumber(-8, 8))),
                Color = baseColor,
                Material = material,
        })
        table.insert(parts, main)

        if tier >= 2 then
                local oreColor = tier == 2 and Color3.fromRGB(230, 160, 90) or Color3.fromRGB(190, 120, 255)
                for i = 1, tier + 1 do
                        local ore = part({
                                Name = "Bijih" .. i,
                                Size = Vector3.new(rng:NextNumber(0.9, 1.6), rng:NextNumber(0.9, 1.6), rng:NextNumber(0.9, 1.6)),
                                CFrame = CFrame.new(position + Vector3.new(rng:NextNumber(-1.8, 1.8), rng:NextNumber(1.4, 3), rng:NextNumber(-1.8, 1.8)))
                                        * CFrame.Angles(rng:NextNumber(0, math.pi), rng:NextNumber(0, math.pi), 0),
                                Color = oreColor,
                                Material = tier == 3 and Enum.Material.Neon or Enum.Material.CorrodedMetal,
                        })
                        table.insert(parts, ore)
                end
        end
        return parts
end

function GatherService.buildRock(position: Vector3, resourceId: string, seed: number?)
        local tier = ROCK_TIER[resourceId] or 1
        local rng = Random.new(seed or tick() * 1000)
        local parts = rockVisual(position, tier, rng:NextInteger(1, 1e6))

        local res = resourceById[resourceId]
        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Tambang " .. (res and res.name or resourceId)
        prompt.ObjectText = tier == 1 and "Batu Biasa" or (tier == 2 and "Bijih Besi" or "Kristal Langka")
        prompt.MaxActivationDistance = 10
        prompt.HoldDuration = tier == 3 and 2 or 1.2
        prompt.Parent = parts[1]

        local node = { alive = true, parts = parts, prompt = prompt }

        prompt.Triggered:Connect(function(player)
                if not node.alive or not DataService.has(player) then
                        return
                end
                local data = DataService.get(player)
                if data.Tools.pickTier < tier then
                        notify(player, "Belik Kurang Bagus",
                                tier == 2 and "Butuh Belik Batu dari Toko Alat untuk menambang Besi."
                                        or "Butuh Belik Baja dari Toko Alat untuk menambang Kristal.")
                        return
                end
                node.alive = false
                local amount = rng:NextInteger(1, tier == 1 and 2 or 1)
                DataService.giveItem(player, "bag", resourceId, amount)
                DataService.addXP(player, 4)
                QuestService.progress(player, "mine", 1)
                notify(player, "Menambang", "+" .. amount .. " " .. (res and res.name or resourceId))
                DataService.push(player)

                for _, p in parts do
                        p.Transparency = 1
                        p.CanCollide = false
                end
                prompt.Enabled = false
                task.delay(RESPAWN_ROCK, function()
                        for _, p in parts do
                                p.Transparency = 0
                                p.CanCollide = true
                        end
                        node.alive = true
                        prompt.Enabled = true
                end)
        end)
end

--------------------------------------------------------------------
-- MEMANCING
--------------------------------------------------------------------

function GatherService.buildPier(basePosition: Vector3, direction: Vector3)
        -- dermaga: papan jalan ke danau + tiang
        local planks = part({
                Name = "DermagaPapan",
                Size = Vector3.new(14, 0.5, 4),
                CFrame = CFrame.new(basePosition + Vector3.new(0, 1.2, 0)) * CFrame.Angles(0, math.atan2(direction.X, direction.Z) + math.rad(90), 0),
                Color = Color3.fromRGB(146, 106, 66),
                Material = Enum.Material.WoodPlanks,
        })
        for i = -1, 1 do
                part({
                        Name = "DermagaTiang" .. i,
                        Size = Vector3.new(0.8, 3, 0.8),
                        CFrame = CFrame.new(basePosition + Vector3.new(i * 5.5, 0.4, 0) - direction * 0),
                        Color = Color3.fromRGB(110, 80, 50),
                        Material = Enum.Material.Wood,
                })
        end

        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Pancing Ikan"
        prompt.ObjectText = "Danau Tenang"
        prompt.MaxActivationDistance = 10
        prompt.HoldDuration = 2.5 -- merasakan tarikan pancing...
        prompt.Parent = planks

        prompt.Triggered:Connect(function(player)
                if not DataService.has(player) then
                        return
                end
                local now = time()
                if fishCooldown[player] and now - fishCooldown[player] < FISH_COOLDOWN then
                        return
                end
                fishCooldown[player] = now

                local data = DataService.get(player)
                if not data.Tools.rod then
                        notify(player, "Butuh Pancing", "Beli Pancing Ajaib di Toko Alat (Pasar Timur) untuk memancing.")
                        return
                end

                local roll = math.random()
                local acc = 0
                local caught = Config.Fish[#Config.Fish]
                for _, fish in Config.Fish do
                        acc += fish.chance
                        if roll <= acc then
                                caught = fish
                                break
                        end
                end

                DataService.giveItem(player, "fish", caught.id, 1)
                DataService.addXP(player, 5)
                if caught.id ~= "sepatu" then
                        QuestService.progress(player, "fish", 1)
                end
                if caught.id == "sepatu" then
                        notify(player, "Tidak Nyangka...", "Kamu menarik Sepatu Bot Tua?! Tetap dijual saja.")
                else
                        notify(player, "Dapat Ikan!", "+" .. caught.name .. " - jual di Pasar!")
                end
                DataService.push(player)
        end)
end

function GatherService.init()
        local Players = game:GetService("Players")
        Players.PlayerRemoving:Connect(function(player)
                fishCooldown[player] = nil
        end)
end

return GatherService
