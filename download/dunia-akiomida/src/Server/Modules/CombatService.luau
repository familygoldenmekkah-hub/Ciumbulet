--!nonstrict
--[[
        CombatService.luau - v3 "Toram-grade" kombat dunia terbuka:
          - 4 makhluk original: Gelatin Hijau, Serigala Bayang, Golem Batu,
            Gelatin Raksasa (elite) + BOSS RAID "Raja Golem" di Arena Timur
          - AI: berkeliaran, mengejar pemain dalam radius aggro, menyerang balik
          - Serang lewat ProximityPrompt "Serang" + validasi jarak di server
          - Damage dari STR/DEX/INT/level + senjata tempaan (EquipService)
          - Drop material -> bahan tempa (objek jadi bahan!)
          - Boss raid kooperatif: semua pemain memukul bersama, hadiah
            dibagi menurut kontribusi damage. Broadcast BossState ke UI.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = require(ReplicatedStorage.Remotes)
local Balance = require(ReplicatedStorage.Shared.Balance)
local Util = require(ReplicatedStorage.Shared.Util)

local DataService = require(script.Parent.DataService)
local EquipService = require(script.Parent.EquipService)
local QuestService = require(script.Parent.QuestService)

local CombatService = {}

--------------------------------------------------------------------
-- STATE
--------------------------------------------------------------------

local monsterFolder: Folder? = nil
local monsters: { [string]: any } = {} -- id unik -> entitas
local monsterSeq = 0
local lastAttack: { [Player]: number } = {}
local rng = Random.new(tick() * 1000)

local boss: any = nil
local bossCredits: { [Player]: number } = {}
local bossNextSpawn = 0

--------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------

local function notify(player: Player, title: string, text: string)
        Remotes.get("Notify"):FireClient(player, title, text)
end

local function statsOf(player: Player)
        return EquipService.statsOf(player)
end

local function isAliveCharacter(player: Player): boolean
        local character = player.Character
        if not character or not character.Parent then
                return false
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        return humanoid ~= nil and humanoid.Health > 0 and character.PrimaryPart ~= nil
end

--------------------------------------------------------------------
-- MODEL MONSTER (karya original: badan + mata + inti)
--------------------------------------------------------------------

local function part(props): Part
        local p = Instance.new("Part")
        p.Anchored = true
        p.TopSurface = Enum.SurfaceType.Smooth
        p.BottomSurface = Enum.SurfaceType.Smooth
        for k, v in props do
                (p :: any)[k] = v
        end
        p.Parent = monsterFolder
        return p
end

local function hpBillboard(body: Part, name: string, hp: number, maxHp: number, isBoss: boolean)
        local gui = Instance.new("BillboardGui")
        gui.Name = "HPBar"
        gui.Size = isBoss and UDim2.new(0, 260, 0, 54) or UDim2.new(0, 150, 0, 40)
        gui.StudsOffset = Vector3.new(0, (isBoss and 12 or 7), 0)
        gui.AlwaysOnTop = true
        gui.MaxDistance = 140
        gui.Parent = body

        local nameLabel = Util.create("TextLabel", {
                Size = UDim2.new(1, 0, 0, isBoss and 26 or 18),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = isBoss and Color3.fromRGB(255, 90, 90) or Color3.fromRGB(255, 230, 160),
                TextStrokeTransparency = 0.4,
                Text = name,
        }, gui)

        local barBg = Util.create("Frame", {
                Position = UDim2.new(0, 8, 0, isBoss and 28 or 20),
                Size = UDim2.new(1, -16, 0, isBoss and 16 or 12),
                BackgroundColor3 = Color3.fromRGB(40, 20, 20),
                BorderSizePixel = 0,
        }, gui)
        Util.create("UICorner", { CornerRadius = UDim.new(0, 6) }, barBg)
        local bar = Util.create("Frame", {
                Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = isBoss and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(90, 220, 120),
                BorderSizePixel = 0,
        }, barBg)
        Util.create("UICorner", { CornerRadius = UDim.new(0, 6) }, bar)

        local hpLabel = Util.create("TextLabel", {
                Position = UDim2.new(0, 0, 0, isBoss and 44 or 32),
                Size = UDim2.new(1, 0, 0, 10),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                TextScaled = true,
                TextColor3 = Color3.fromRGB(230, 230, 235),
                Text = hp .. " / " .. maxHp,
        }, gui)

        return { gui = gui, bar = bar, label = hpLabel, name = nameLabel }
end

local function buildMonsterModel(def: any, position: Vector3, isBoss: boolean): (Model, Part)
        local model = Instance.new("Model")
        model.Name = isBoss and "RajaGolem" or ("Monster_" .. def.id)

        local bodyColor = Color3.fromRGB(def.body.color[1], def.body.color[2], def.body.color[3])
        local size = def.body.size
        local body: Part

        if def.body.shape == "ball" then
                body = part({
                        Name = "Badan",
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(1, 1, 1) * size,
                        CFrame = CFrame.new(position + Vector3.new(0, size / 2, 0)),
                        Color = bodyColor,
                        Material = Enum.Material.SmoothPlastic,
                        Transparency = 0.12,
                })
        else
                body = part({
                        Name = "Badan",
                        Size = Vector3.new(size * 0.9, size * 0.8, size * 0.9),
                        CFrame = CFrame.new(position + Vector3.new(0, size * 0.4, 0)),
                        Color = bodyColor,
                        Material = Enum.Material.Slate,
                })
        end
        body.Parent = model
        model.PrimaryPart = body

        -- mata (dua titik gelap) supaya terlihat hidup
        local eyeColor = Color3.fromRGB(30, 30, 36)
        local eyeZ = -(size * 0.42)
        local eyeSize = math.max(0.5, size * 0.14)
        for side = -1, 1, 2 do
                local eye = part({
                        Name = "Mata" .. side,
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(1, 1, 1) * eyeSize,
                        CFrame = body.CFrame * CFrame.new(Vector3.new(side * eyeSize, size * 0.16, eyeZ)),
                        Color = isBoss and Color3.fromRGB(255, 80, 60) or eyeColor,
                        Material = isBoss and Enum.Material.Neon or Enum.Material.SmoothPlastic,
                        CanCollide = false,
                })
                eye.Parent = model
        end

        if def.body.shape == "box" then
                -- inti bercahaya di dada (golem/wolf)
                local core = part({
                        Name = "Inti",
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(1, 1, 1) * size * 0.22,
                        CFrame = body.CFrame * CFrame.new(0, size * 0.08, size * 0.48),
                        Color = isBoss and Color3.fromRGB(255, 120, 60) or Color3.fromRGB(255, 170, 90),
                        Material = Enum.Material.Neon,
                        CanCollide = false,
                })
                core.Parent = model
        end

        if isBoss then
                -- mahkota duri raja
                for i = 1, 5 do
                        local spike = part({
                                Name = "Duri" .. i,
                                Size = Vector3.new(1.2, 4, 1.2),
                                CFrame = body.CFrame * CFrame.new((i - 3) * 2.4, size * 0.62, 0) * CFrame.Angles(math.rad(rng:NextNumber(-12, 12)), 0, math.rad(rng:NextNumber(-12, 12))),
                                Color = Color3.fromRGB(70, 70, 82),
                                Material = Enum.Material.Rock,
                                CanCollide = false,
                        })
                        spike.Parent = model
                end
                local light = Instance.new("PointLight")
                light.Color = Color3.fromRGB(255, 110, 60)
                light.Range = 34
                light.Brightness = 1.6
                light.Parent = body
        end

        body.CanCollide = true

        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Serang"
        prompt.ObjectText = def.name
        prompt.MaxActivationDistance = 9
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.Parent = body

        return model, body
end

--------------------------------------------------------------------
-- SPAWN & AI
--------------------------------------------------------------------

local function zoneCenter(zoneId: string): Vector3
        for _, zone in ipairs(Balance.Zones) do
                if zone.id == zoneId then
                        return Vector3.new(zone.center[1], zone.center[2], zone.center[3])
                end
        end
        return Vector3.new(0, 0, 0)
end

local function spawnMonster(def: any, zoneId: string, isBoss: boolean?)
        local center = zoneCenter(zoneId)
        local offset = Vector3.new(rng:NextNumber(-1, 1) * 12, 0, rng:NextNumber(-1, 1) * 12)
        local position = center + offset
        local model, body = buildMonsterModel(def, position, isBoss == true)

        local maxHp = def.hp
        local bb = hpBillboard(body, def.name, maxHp, maxHp, isBoss == true)

        local entity = {
                def = def,
                zone = zoneId,
                model = model,
                body = body,
                bb = bb,
                hp = maxHp,
                maxHp = maxHp,
                alive = true,
                home = position,
                target = nil :: Player?,
                lastHit = 0,
                lastMove = 0,
                wanderTo = position,
                isBoss = isBoss == true,
                unique = 0,
        }
        monsterSeq += 1
        entity.unique = monsterSeq

        local prompt = body:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
                prompt.Triggered:Connect(function(player)
                        if entity.alive then
                                task.spawn(CombatService.playerAttack, player, entity)
                        end
                end)
        end

        monsters["m" .. entity.unique] = entity
        return entity
end

local function disablePrompt(p: Part)
        local pr = p:FindFirstChildOfClass("ProximityPrompt")
        if pr then
                pr.Enabled = false
        end
end

local function monsterDie(entity: any, byPlayer: Player?)
        entity.alive = false
        local def = entity.def

        -- animasi kematian sederhana: tenggelam & hilang
        for _, p in entity.model:GetChildren() do
                if p:IsA("BasePart") then
                        p.CanCollide = false
                        disablePrompt(p)
                end
        end
        local body = entity.body
        body.Anchored = true
        task.spawn(function()
                for t = 1, 10 do
                        if body.Parent then
                                body.CFrame = body.CFrame - Vector3.new(0, 0.25, 0)
                                body.Transparency = t / 10
                        end
                        task.wait(0.05)
                end
                if entity.model.Parent then
                        entity.model:Destroy()
                end
        end)

        monsters["m" .. entity.unique] = nil

        if entity.isBoss then
                boss = nil
                return -- boss tidak respawn otomatis (diatur bossLoop)
        end

        -- respawn di zona setelah jeda
        task.delay(def.respawn, function()
                if monsterFolder and monsterFolder.Parent then
                        spawnMonster(def, entity.zone)
                end
        end)
end

--------------------------------------------------------------------
-- SERANGAN PEMAIN
--------------------------------------------------------------------

function CombatService.playerAttack(player: Player, entity: any)
        if not entity or not entity.alive or not DataService.has(player) then
                return { ok = false, msg = "Target tidak valid." }
        end
        if not isAliveCharacter(player) then
                return { ok = false, msg = "Kamu tidak bisa menyerang sekarang." }
        end
        -- jarak server-side
        local root = player.Character and player.Character.PrimaryPart
        if not root or (root.Position - entity.body.Position).Magnitude > 14 then
                return { ok = false, msg = "Terlalu jauh!" }
        end
        -- jeda serangan (AGI mempercepat)
        local now = os.clock()
        local cd = Balance.attackCooldown(statsOf(player).agi)
        if lastAttack[player] and now - lastAttack[player] < cd then
                return { ok = false, msg = "Serangan belum siap." }
        end
        lastAttack[player] = now

        local stats = statsOf(player)
        local level = DataService.levelOf(player)
        local atk = Balance.playerAttack({
                weaponAtk = EquipService.weaponAtk(player),
                str = stats.str,
                dex = stats.dex,
                int = stats.int,
                level = level,
        })
        local crit = rng:NextNumber() < Balance.critChance(stats.dex)
        if crit then
                atk = math.floor(atk * Balance.CritMult + 0.5)
        end
        -- kurva pelunakan dengan pertahanan monster
        local def = entity.def.def or 0
        local dmg = math.max(1, math.floor(atk * (1 - def / (def + 60)) + 0.5))

        entity.hp -= dmg
        local bb = entity.bb
        bb.bar.Size = UDim2.fromScale(math.clamp(entity.hp / entity.maxHp, 0, 1), 1)
        bb.label.Text = math.max(0, entity.hp) .. " / " .. entity.maxHp

        -- krediting boss raid
        if entity.isBoss then
                bossCredits[player] = (bossCredits[player] or 0) + dmg
        end

        local killed = entity.hp <= 0

        if killed then
                CombatService.onKill(player, entity)
                if entity.isBoss then
                        -- bagi hadiah raid SEBELUM boss dibersihkan
                        CombatService.finishBoss()
                end
                monsterDie(entity, player)
        else
                -- monster berbalik mengejar penyerang
                entity.target = player
        end

        DataService.push(player)
        return { ok = true, dmg = dmg, crit = crit, killed = killed, name = entity.def.name }
end

function CombatService.onKill(player: Player, entity: any)
        local def = entity.def

        -- XP & koin
        DataService.addXP(player, def.xp)
        local coin = rng:NextInteger(def.coin[1], def.coin[2])
        DataService.addCoins(player, coin, true)

        -- progres tugas "kalahkan monster"
        QuestService.progress(player, "kill", 1)

        -- drop material -> bahan craft
        local dropTexts = {}
        for _, drop in ipairs(def.drops) do
                if rng:NextNumber() <= drop.chance then
                        local n = rng:NextInteger(drop.min, drop.max)
                        DataService.giveItem(player, "bag", drop.id, n)
                        table.insert(dropTexts, "+" .. n .. " " .. drop.id)
                end
        end

        local msg = def.name .. " dikalahkan! +" .. def.xp .. " XP, +" .. coin .. " koin"
        if #dropTexts > 0 then
                msg = msg .. " (" .. table.concat(dropTexts, ", ") .. ")"
        end
        notify(player, "KOMBAT!", msg)

        -- boss raid: broadcast peristiwa
        if entity.isBoss then
                Remotes.get("BossState"):FireAllClients({ active = false, killed = true, name = def.name })
        end
end

--------------------------------------------------------------------
-- AI LOOP (wander / chase / attack)
--------------------------------------------------------------------

local function stepMonster(entity: any, dt: number)
        if not entity.alive or not entity.body.Parent then
                return
        end
        local def = entity.def

        -- validasi target
        local targetPlayer = entity.target
        if targetPlayer then
                local valid = targetPlayer.Parent ~= nil and isAliveCharacter(targetPlayer)
                if valid then
                        local root = targetPlayer.Character.PrimaryPart
                        local dist = (root.Position - entity.home).Magnitude
                        if dist > def.aggro * 2.2 then
                                valid = false -- terlalu jauh dari rumahnya, pulang
                        end
                end
                if not valid then
                        entity.target = nil
                end
        end

        -- cari target baru dalam radius aggro
        if not entity.target then
                for _, player in Players:GetPlayers() do
                        if isAliveCharacter(player) and DataService.has(player) then
                                local root = player.Character.PrimaryPart
                                if (root.Position - entity.body.Position).Magnitude <= def.aggro then
                                        entity.target = player
                                        break
                                end
                        end
                end
        end

        local bodyPos = entity.body.Position
        local goal: Vector3
        local speed = def.speed

        if entity.target then
                local root = entity.target.Character.PrimaryPart
                local dist = (root.Position - bodyPos).Magnitude
                if dist > 5 then
                        goal = root.Position
                else
                        goal = bodyPos -- dekat: berhenti & serang
                        local now = os.clock()
                        if now - entity.lastHit >= 1.5 then
                                entity.lastHit = now
                                -- damage ke pemain dengan pertahanan zirah + VIT
                                local pstats = statsOf(entity.target)
                                local defense = Balance.playerDefense(EquipService.armorDef(entity.target), pstats.vit)
                                local taken = Balance.damageTaken(def.atk, defense)
                                local humanoid = entity.target.Character:FindFirstChildOfClass("Humanoid")
                                if humanoid then
                                        humanoid:TakeDamage(taken)
                                end
                        end
                end
        else
                -- berkeliaran di sekitar rumah
                if (bodyPos - entity.wanderTo).Magnitude < 3 then
                        entity.wanderTo = entity.home + Vector3.new(rng:NextNumber(-12, 12), 0, rng:NextNumber(-12, 12))
                        return
                end
                goal = entity.wanderTo
                speed = def.speed * 0.45
        end

        local dir = (goal - bodyPos) * Vector3.new(1, 0, 1)
        if dir.Magnitude > 0.4 then
                dir = dir.Unit
                local step = math.min(speed * dt, dir.Magnitude * 99)
                local newPos = bodyPos + dir * step
                entity.body.CFrame = CFrame.lookAt(newPos, newPos + dir)
        end
end

RunService.Heartbeat:Connect(function(dt)
        for _, entity in monsters do
                pcall(stepMonster, entity, dt)
        end
end)

--------------------------------------------------------------------
-- BOSS RAID (kooperatif - kegiatan multiplayer terancang)
--------------------------------------------------------------------

function CombatService.startBoss()
        if boss then
                return
        end
        local def = Balance.Boss
        local center = zoneCenter("arena")
        local model, body = buildMonsterModel({ id = def.id, name = def.name, body = def.body }, center + Vector3.new(0, 2, 0), true)
        local maxHp = def.hp
        local bb = hpBillboard(body, def.name, maxHp, maxHp, true)

        boss = {
                def = def,
                zone = "arena",
                model = model,
                body = body,
                bb = bb,
                hp = maxHp,
                maxHp = maxHp,
                alive = true,
                home = center,
                target = nil,
                lastHit = 0,
                wanderTo = center,
                isBoss = true,
                unique = 0,
                spawnedAt = os.clock(),
        }
        monsterSeq += 1
        boss.unique = monsterSeq
        bossCredits = {}

        local prompt = body:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
                prompt.Triggered:Connect(function(player)
                        if boss and boss.alive then
                                task.spawn(CombatService.playerAttack, player, boss)
                        end
                end)
        end
        monsters["m" .. boss.unique] = boss

        Remotes.get("BossState"):FireAllClients({
                active = true, name = def.name, hp = maxHp, maxHp = maxHp,
                zone = "Arena Timur",
        })
        for _, player in Players:GetPlayers() do
                notify(player, "BOSS RAID!", def.name .. " muncul di Arena Timur! Serang bersama untuk hadiah besar!")
        end
end

function CombatService.finishBoss()
        if not boss then
                return
        end
        local def = Balance.Boss
        local participants = {}
        local totalDmg = 0
        for player, dmg in bossCredits do
                if player.Parent then
                        table.insert(participants, { player = player, dmg = dmg })
                        totalDmg += dmg
                end
        end
        table.sort(participants, function(a, b)
                return a.dmg > b.dmg
        end)

        for rank, entry in participants do
                local share = entry.dmg / math.max(1, totalDmg)
                local coin = math.floor(def.participationCoin + share * (rng:NextInteger(def.coin[1], def.coin[2])))
                local xp = math.max(def.participationXp, math.floor(def.xp * share))
                DataService.addCoins(entry.player, coin, true)
                DataService.addXP(entry.player, xp)
                local extra = ""
                if rank == 1 then
                        DataService.addCoins(entry.player, def.topBonusCoin, true)
                        for _, drop in ipairs(def.drops) do
                                local n = rng:NextInteger(drop.min, drop.max)
                                DataService.giveItem(entry.player, "bag", drop.id, n)
                                extra = extra .. " +" .. n .. " " .. drop.id
                        end
                end
                notify(entry.player, "BOSS DIKALAHKAN!", rank == 1 and ("KAU PENYERANG TERAKHIR/TERBESAR! +" .. coin .. " koin" .. extra)
                        or ("Kontribusi " .. math.floor(share * 100) .. "% - +" .. coin .. " koin, +" .. xp .. " XP"))
                DataService.push(entry.player)
        end
        bossCredits = {}
end

local function bossLoop()
        while true do
                task.wait(5)
                local now = os.clock()
                if not boss and now >= bossNextSpawn then
                        CombatService.startBoss()
                end
                if boss and boss.alive then
                        -- despawn kalau terlalu lama tak dibunuh
                        if now - boss.spawnedAt > Balance.Boss.despawn then
                                bossCredits = {}
                                monsterDie(boss)
                                boss = nil
                                Remotes.get("BossState"):FireAllClients({ active = false, name = Balance.Boss.name })
                                Remotes.get("Notify"):FireAllClients("Boss Pergi", "Raja Golem kembali ke tanah. Hati-hati, ia akan bangkit lagi!")
                        else
                                Remotes.get("BossState"):FireAllClients({
                                        active = true, name = Balance.Boss.name,
                                        hp = math.max(0, boss.hp), maxHp = boss.maxHp,
                                        zone = "Arena Timur",
                                })
                        end
                end
                if not boss then
                        bossNextSpawn = math.max(bossNextSpawn, now + Balance.Boss.respawn)
                end
        end
end

--------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------

function CombatService.spawnMonsters()
        for _, zone in ipairs(Balance.Zones) do
                for _, spec in ipairs(zone.monsters) do
                        local def = nil
                        for _, m in ipairs(Balance.Monsters) do
                                if m.id == spec.id then
                                        def = m
                                        break
                                end
                        end
                        if def then
                                for _ = 1, spec.count do
                                        spawnMonster(def, zone.id)
                                end
                        end
                end
        end
        print("[AKIOMIDA] Monster dikerahkan di 4 zona.")
end

function CombatService.init()
        local newFolder = Instance.new("Folder")
        newFolder.Name = "AKM_Monster"
        newFolder.Parent = workspace
        monsterFolder = newFolder

        Remotes.get("Attack").OnServerInvoke = function(player, monsterId)
                if type(monsterId) ~= "string" then
                        return { ok = false, msg = "Tidak valid." }
                end
                local entity = monsters[monsterId] or boss
                if not entity or not entity.alive or ("m" .. entity.unique) ~= monsterId then
                        return { ok = false, msg = "Target tidak ada." }
                end
                return CombatService.playerAttack(player, entity)
        end

        Players.PlayerRemoving:Connect(function(player)
                lastAttack[player] = nil
                bossCredits[player] = nil
        end)

        -- boss pertama muncul 6 menit setelah server hidup (biar pemain sempat latihan)
        bossNextSpawn = os.clock() + 360
        task.spawn(bossLoop)
end

return CombatService
