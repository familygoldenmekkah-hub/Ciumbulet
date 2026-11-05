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

-- v6 event dunia
local eventActive = false
local eventEndsAt = 0

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
-- MODEL MONSTER "ANGKA BERSAURA" (karya original Dunia Akiomida)
--   Monster berwujud ANGKA raksasa (susunan balok gaya tujuh-segmen)
--   dikelilingi AURA bercahaya + cincin lantai + percikan halus.
--   Angka-angka ini PUNYA DAMAGE: mereka mengejar & menyerang pemain.
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

-- layout segmen angka (gaya tujuh-segmen): tiap segmen balok original
local SEG = {
        a = { horiz = true, x = 0, y = 0.5 },
        g = { horiz = true, x = 0, y = 0 },
        d = { horiz = true, x = 0, y = -0.5 },
        f = { horiz = false, x = -0.5, y = 0.25 },
        b = { horiz = false, x = 0.5, y = 0.25 },
        e = { horiz = false, x = -0.5, y = -0.25 },
        c = { horiz = false, x = 0.5, y = -0.25 },
}

local DIGIT_SEGMENTS: { [string]: string } = {
        ["1"] = "bc", ["2"] = "abged", ["3"] = "abgcd", ["4"] = "fgbc",
        ["5"] = "afgcd", ["6"] = "afgecd", ["7"] = "abc", ["9"] = "abcdfg",
}

local function buildMonsterModel(def: any, position: Vector3, isBoss: boolean): (Model, Part)
        local model = Instance.new("Model")
        model.Name = isBoss and "AngkaRaja" or ("Angka_" .. tostring(def.body.digit or "1"))

        local bodyColor = Color3.fromRGB(def.body.color[1], def.body.color[2], def.body.color[3])
        local auraColor = Color3.fromRGB(def.body.aura[1], def.body.aura[2], def.body.aura[3])
        local size = def.body.size
        local digit = tostring(def.body.digit or "1")

        -- dimensi angka: tinggi = size, lebar = 62%, tebal balok = 18%
        local H = size
        local W = H * 0.62
        local t = math.max(0.5, H * 0.18)
        local depth = math.max(0.6, t * 0.9)

        -- AKAR: part tak terlihat sebagai acuan gerak & penempel prompt/HP
        local root = part({
                Name = "Badan",
                Size = Vector3.new(W + 2, H + 2, depth + 2),
                CFrame = CFrame.new(position + Vector3.new(0, H / 2, 0)),
                Transparency = 1,
                CanCollide = true,
        })
        root.Parent = model
        model.PrimaryPart = root

        -- segmen angka + aura neon mengelilingi tiap balok
        local segs = DIGIT_SEGMENTS[digit] or "bc"
        for i = 1, #segs do
                local s = SEG[string.sub(segs, i, i)]
                local barSize = s.horiz and Vector3.new(W, t, depth) or Vector3.new(t, H / 2, depth)
                local offset = Vector3.new(s.x * W, s.y * H, 0)
                part({
                        Name = "Angka" .. i,
                        Size = barSize,
                        CFrame = root.CFrame * CFrame.new(offset),
                        Color = bodyColor,
                        Material = isBoss and Enum.Material.Neon or Enum.Material.SmoothPlastic,
                        CanCollide = false,
                }).Parent = model
                part({
                        Name = "Aura" .. i,
                        Size = s.horiz and Vector3.new(W + t * 1.2, t * 2.1, depth * 0.8) or Vector3.new(t * 2.1, H / 2 + t * 1.2, depth * 0.8),
                        CFrame = root.CFrame * CFrame.new(offset),
                        Color = auraColor,
                        Material = Enum.Material.Neon,
                        Transparency = 0.68,
                        CanCollide = false,
                }).Parent = model
        end

        -- mata kecil di atas angka supaya terlihat hidup
        local eyeZ = -(depth / 2 + 0.05)
        local eyeSize = math.max(0.35, t * 0.5)
        for side = -1, 1, 2 do
                part({
                        Name = "Mata" .. side,
                        Shape = Enum.PartType.Ball,
                        Size = Vector3.new(1, 1, 1) * eyeSize,
                        CFrame = root.CFrame * CFrame.new(Vector3.new(side * W * 0.18, H * 0.36, eyeZ)),
                        Color = isBoss and Color3.fromRGB(255, 80, 60) or Color3.fromRGB(26, 26, 32),
                        Material = Enum.Material.Neon,
                        CanCollide = false,
                }).Parent = model
        end

        -- cincin aura di tanah + percikan halus (ringan untuk mobile)
        part({
                Name = "CincinAura",
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(0.18, W * 2.6, W * 2.6),
                CFrame = CFrame.new(position + Vector3.new(0, 0.12, 0)) * CFrame.Angles(0, 0, math.rad(90)),
                Color = auraColor,
                Material = Enum.Material.Neon,
                Transparency = 0.55,
                CanCollide = false,
        }).Parent = model

        local spark = Instance.new("ParticleEmitter")
        spark.Rate = isBoss and 8 or 3
        spark.Lifetime = NumberRange.new(0.5, 0.9)
        spark.Speed = NumberRange.new(0.6, 1.6)
        spark.Size = NumberSequence.new(0.28)
        spark.Color = ColorSequence.new(auraColor)
        spark.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(1, 1) })
        spark.Enabled = true
        spark.Parent = root

        if isBoss then
                local light = Instance.new("PointLight")
                light.Color = auraColor
                light.Range = 30
                light.Brightness = 1.4
                light.Parent = root
        end

        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Serang"
        prompt.ObjectText = def.name
        prompt.MaxActivationDistance = 9
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.Parent = root

        return model, root
end

-- v5: suara posisional bawaan platform (original, ringan)
local function playSound(root: BasePart, soundName: string, pitch: number?, volume: number?)
        local s = Instance.new("Sound")
        s.SoundId = "rbxasset://sounds/" .. soundName
        s.Volume = volume or 0.5
        s.PlaybackSpeed = pitch or 1
        s.Parent = root
        s:Play()
        task.delay(3, function()
                if s.Parent then
                        s:Destroy()
                end
        end)
end

--------------------------------------------------------------------
-- v20 FASE MURKA BOSS: pada HP <= 50% sang raja mengamuk
--   (gaya mekanik bos MMO: aura merah, gerak & serangan naik, diumumkan)
--------------------------------------------------------------------

local function maybeEnrage(entity: any)
        if not entity.isBoss or entity.enraged or not entity.alive then
                return
        end
        if entity.hp > entity.maxHp * (Balance.Boss.enrageAt or 0.5) then
                return
        end
        entity.enraged = true
        local aura = Balance.Boss.enrageAura or { 255, 60, 50 }
        local c = Color3.fromRGB(aura[1], aura[2], aura[3])
        for _, p in entity.model:GetDescendants() do
                if p:IsA("BasePart") and (string.sub(p.Name, 1, 4) == "Aura" or p.Name == "CincinAura") then
                        p.Color = c
                elseif p:IsA("ParticleEmitter") then
                        p.Color = ColorSequence.new(c)
                elseif p:IsA("PointLight") then
                        p.Color = c
                end
        end
        Util.burst(entity.body, c, 24, 12)
        playSound(entity.body, "impact_water.mp3", 0.55, 0.8)
        Remotes.get("BossState"):FireAllClients({
                active = true, name = Balance.Boss.name,
                hp = math.max(1, entity.hp), maxHp = entity.maxHp,
                zone = "Arena Timur", enraged = true,
        })
        for _, player in Players:GetPlayers() do
                notify(player, "MURKA!", Balance.Boss.name .. " mengamuk! Gerak & serangannya menguat - berhati-hatilah!")
        end
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
        local model = entity.model
        do
                -- ledakan aura saat tumbang
                local root = entity.body
                if root and root.Parent then
                        local burst = Instance.new("ParticleEmitter")
                        burst.Rate = 0
                        burst.Speed = NumberRange.new(8, 14)
                        burst.Lifetime = NumberRange.new(0.4, 0.8)
                        burst.SpreadAngle = Vector2.new(180, 180)
                        local c = Color3.fromRGB(def.body.aura[1], def.body.aura[2], def.body.aura[3])
                        burst.Color = ColorSequence.new(c)
                        burst.Size = NumberSequence.new(0.4)
                        burst.Parent = root
                        burst:Emit(20)
                end
        end
        task.spawn(function()
                for t = 1, 10 do
                        if model.Parent then
                                model:PivotTo(model:GetPivot() - Vector3.new(0, 0.25, 0))
                                for _, p in model:GetDescendants() do
                                        if p:IsA("BasePart") and p.Transparency < 1 then
                                                p.Transparency = math.min(1, t / 8)
                                        end
                                end
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
-- ANGKA DAMAGE MELAYANG (biar serangan terasa "sakit")
--------------------------------------------------------------------

local function damageTag(entity: any, dmg: number, crit: boolean, killed: boolean)
        local root = entity.body
        if not root or not root.Parent then
                return
        end
        local gui = Instance.new("BillboardGui")
        gui.Size = UDim2.new(0, 130, 0, 46)
        gui.StudsOffset = Vector3.new(rng:NextNumber(-1.4, 1.4), rng:NextNumber(3.4, 5.4), 0)
        gui.AlwaysOnTop = true
        gui.MaxDistance = 130
        gui.Parent = root
        local label = Util.create("TextLabel", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = killed and Color3.fromRGB(255, 120, 90)
                        or (crit and Color3.fromRGB(255, 214, 90) or Color3.fromRGB(255, 255, 255)),
                TextStrokeTransparency = 0.35,
                Text = (crit and "KRITIS -" or "-") .. dmg,
        }, gui)
        playSound(root, "swordslash.wav", crit and 1.15 or 1, 0.45)
        if killed then
                playSound(root, "impact_water.mp3", 0.8, 0.6)
        end
        task.spawn(function()
                for i = 1, 14 do
                        if gui.Parent then
                                gui.StudsOffset += Vector3.new(0, 0.16, 0)
                                label.TextTransparency = i / 14
                                label.TextStrokeTransparency = math.min(1, 0.35 + i / 14)
                        end
                        task.wait(0.05)
                end
                gui:Destroy()
        end)
end

--------------------------------------------------------------------
-- SKILL SENJATA (v5)
--------------------------------------------------------------------

local lastSkill: { [Player]: { [string]: number } } = {}

local function findNearestMonster(player: Player, maxDist: number)
        local root = player.Character and player.Character.PrimaryPart
        if not root then
                return nil
        end
        local best, bestDist = nil, maxDist
        for _, e in monsters do
                if e.alive and e.body.Parent then
                        local d = (e.body.Position - root.Position).Magnitude
                        if d < bestDist then
                                best, bestDist = e, d
                        end
                end
        end
        return best
end

local function hitEntity(player: Player, entity: any, mult: number, stats: any, level: number): number
        local atk = Balance.playerAttack({
                weaponAtk = EquipService.weaponAtk(player),
                str = stats.str,
                dex = stats.dex,
                int = stats.int,
                level = level,
        })
        atk = math.floor(atk * mult)
        if rng:NextNumber() < Balance.critChance(stats.dex) then
                atk = math.floor(atk * Balance.CritMult + 0.5)
        end
        local def = entity.def.def or 0
        local dmg = math.max(1, math.floor(atk * (1 - def / (def + 60)) + 0.5))
        entity.hp -= dmg
        -- v20: partikel tebasan skill + cek fase murka boss
        if mult > 1.6 and entity.body.Parent then
                local aura = entity.def.body and entity.def.body.aura
                Util.burst(entity.body, aura and Color3.fromRGB(aura[1], aura[2], aura[3]) or Color3.fromRGB(255, 230, 120), 8, 8)
        end
        maybeEnrage(entity)
        local bb = entity.bb
        bb.bar.Size = UDim2.fromScale(math.clamp(entity.hp / entity.maxHp, 0, 1), 1)
        bb.label.Text = math.max(0, entity.hp) .. " / " .. entity.maxHp
        if entity.isBoss then
                bossCredits[player] = (bossCredits[player] or 0) + dmg
        end
        local killed = entity.hp <= 0
        damageTag(entity, dmg, mult > 1.6, killed)
        if killed then
                CombatService.onKill(player, entity)
                if entity.isBoss then
                        CombatService.finishBoss()
                end
                monsterDie(entity, player)
        else
                entity.target = player
        end
        return dmg
end

function CombatService.useSkill(player: Player, payload: any)
        if not DataService.has(player) or type(payload) ~= "table" then
                return { ok = false, msg = "Tidak valid." }
        end
        if not isAliveCharacter(player) then
                return { ok = false, msg = "Kamu tidak bisa bertarung sekarang." }
        end
        local skill = nil
        for _, s in ipairs(Balance.Skills) do
                if s.id == payload.skillId then
                        skill = s
                        break
                end
        end
        if not skill then
                return { ok = false, msg = "Skill tidak dikenal." }
        end
        if DataService.levelOf(player) < skill.level then
                return { ok = false, msg = "Skill terbuka di level " .. skill.level .. "." }
        end
        if EquipService.weaponAtk(player) <= 0 then
                return { ok = false, msg = skill.name .. " butuh PEDANG - tempa dulu di Pak Tempa!" }
        end
        local now = os.clock()
        lastSkill[player] = lastSkill[player] or {}
        local readyAt = lastSkill[player][skill.id] or 0
        if now < readyAt then
                return { ok = false, msg = skill.name .. " belum siap (" .. math.ceil(readyAt - now) .. "s).", cd = math.ceil(readyAt - now) }
        end
        local stats = statsOf(player)
        local level = DataService.levelOf(player)
        local char = player.Character
        if not char or not char.PrimaryPart then
                return { ok = false, msg = "Karakter belum siap." }
        end

        if skill.aoe then
                local root = char.PrimaryPart
                local hits = 0
                local total = 0
                for _, e in monsters do
                        if e.alive and e.body.Parent and (e.body.Position - root.Position).Magnitude <= 16 then
                                total += hitEntity(player, e, skill.mult, stats, level)
                                hits += 1
                        end
                end
                if hits == 0 then
                        return { ok = false, msg = "Tidak ada angka di sekitarmu." }
                end
                lastSkill[player][skill.id] = now + skill.cooldown
                playSound(char.PrimaryPart, "swordlunge.wav", 1, 0.6)
                DataService.push(player)
                return { ok = true, msg = skill.name .. " menghantam " .. hits .. " angka! Total " .. total .. " damage." }
        end

        local target = findNearestMonster(player, 16)
        if not target then
                return { ok = false, msg = "Tidak ada angka di dekatmu." }
        end
        local dmg = hitEntity(player, target, skill.mult, stats, level)
        lastSkill[player][skill.id] = now + skill.cooldown
        playSound(char.PrimaryPart, "swordlunge.wav", 1.1, 0.55)
        DataService.push(player)
        return { ok = true, msg = skill.name .. "! " .. dmg .. " damage ke " .. target.def.name .. "." }
end

Players.PlayerRemoving:Connect(function(player)
        lastSkill[player] = nil
end)

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
        maybeEnrage(entity) -- v20: boss bisa memasuki fase murka dari serangan biasa
        local bb = entity.bb
        bb.bar.Size = UDim2.fromScale(math.clamp(entity.hp / entity.maxHp, 0, 1), 1)
        bb.label.Text = math.max(0, entity.hp) .. " / " .. entity.maxHp

        -- krediting boss raid
        if entity.isBoss then
                bossCredits[player] = (bossCredits[player] or 0) + dmg
        end

        local killed = entity.hp <= 0
        damageTag(entity, dmg, crit, killed)

        -- recoil visual: angka tersentak sedikit (juice)
        do
                local rootPart = entity.body
                if rootPart and rootPart.Parent and not killed then
                        local dir = (rootPart.Position - root.Position)
                        dir = Vector3.new(dir.X, 0, dir.Z)
                        if dir.Magnitude > 0.1 then
                                dir = dir.Unit
                        else
                                dir = root.CFrame.LookVector * -1
                        end
                        local base = rootPart.Position
                        entity.model:PivotTo(CFrame.new(base + dir * 1.1))
                        task.delay(0.12, function()
                                if entity.alive and entity.model.Parent and entity.body.Parent then
                                        entity.model:PivotTo(CFrame.new(base))
                                end
                        end)
                end
        end

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

        -- XP & Micda (ganda saat PESTA PANEN)
        local xpGain, coinGain = def.xp, rng:NextInteger(def.coin[1], def.coin[2])
        if eventActive then
                xpGain = math.floor(xpGain * Balance.Event.xpMult)
                coinGain = math.floor(coinGain * Balance.Event.coinMult)
        end
        local before = DataService.levelOf(player)
        DataService.addXP(player, xpGain)
        DataService.addCoins(player, coinGain, true)
        if DataService.levelOf(player) > before then
                Remotes.get("Notify"):FireClient(player, "LEVEL NAIK!",
                        "Level " .. DataService.levelOf(player) .. "! Dapat 2 poin stat - bagikan di panel Kar.")
        end

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

        local msg = def.name .. " dikalahkan! +" .. xpGain .. " XP, +" .. coinGain .. " Micda"
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
        -- v20: fase murka mempercepat gerak boss
        local speed = def.speed * (entity.enraged and (Balance.Boss.enrageSpeed or 1) or 1)

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
                                -- v20: serangan boss menguat saat murka
                                local rawAtk = def.atk * (entity.enraged and (Balance.Boss.enrageAtk or 1) or 1)
                                local taken = Balance.damageTaken(rawAtk, defense)
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
                -- v4: pindahkan SELURUH model (angka, aura, mata) supaya tidak
                -- ada part tertinggal berserakan (penyebab dunia terlihat kotor)
                entity.model:PivotTo(CFrame.lookAt(newPos, newPos + dir))
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
                notify(entry.player, "BOSS DIKALAHKAN!", rank == 1 and ("KAU PENYERANG TERAKHIR/TERBESAR! +" .. coin .. " Micda" .. extra)
                        or ("Kontribusi " .. math.floor(share * 100) .. "% - +" .. coin .. " Micda, +" .. xp .. " XP"))
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
                                Remotes.get("Notify"):FireAllClients("Boss Pergi", "Angka Sang Raja kembali ke tanah. Hati-hati, ia akan bangkit lagi!")
                        else
                                Remotes.get("BossState"):FireAllClients({
                                        active = true, name = Balance.Boss.name,
                                        hp = math.max(0, boss.hp), maxHp = boss.maxHp,
                                        zone = "Arena Timur", enraged = boss.enraged == true,
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

-- v6: loop event PESTA PANEN (aktivitas multiplayer terjadwal & terumumkan)
local function eventLoop()
        while true do
                task.wait(Balance.Event.period)
                eventActive = true
                eventEndsAt = os.time() + Balance.Event.duration
                Remotes.get("EventState"):FireAllClients({
                        active = true, name = Balance.Event.name,
                        endsAt = eventEndsAt,
                        note = "Micda & XP dari monster x" .. Balance.Event.coinMult .. "!",
                })
                Remotes.get("Notify"):FireAllClients(Balance.Event.name,
                        "Dimulai! " .. Balance.Event.coinMult .. "x Micda & XP dari semua angka selama " .. math.floor(Balance.Event.duration / 60) .. " menit - kumpulkan semuanya!")
                task.wait(Balance.Event.duration)
                eventActive = false
                Remotes.get("EventState"):FireAllClients({ active = false, name = Balance.Event.name })
                Remotes.get("Notify"):FireAllClients("Pesta Usai", "Pesta Panen selesai. Sampai pesta berikutnya!")
        end
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
        task.spawn(eventLoop)
end

return CombatService
