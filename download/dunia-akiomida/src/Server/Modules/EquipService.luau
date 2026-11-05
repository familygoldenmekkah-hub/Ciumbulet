--!nonstrict
--[[
	EquipService.luau - v3 "Toram-grade":
	  - Pakai/lepas senjata & zirah tempaan
	  - Terapkan stat ke humanoid: HP (VIT), laju lari (AGI/bike)
	  - Visual senjata kayu (pedang original dari part) di tangan
	  - Makan makanan (buff laju) & ramuan (pulihkan HP)
	  - Bagi poin stat (STR/VIT/AGI/INT/DEX)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Remotes)
local Balance = require(ReplicatedStorage.Shared.Balance)

local DataService = require(script.Parent.DataService)

local EquipService = {}

local equipById: { [string]: any } = {}
for _, eq in ipairs(Balance.Equipment) do
	equipById[eq.id] = eq
end
local usableById: { [string]: any } = {}
for _, u in ipairs(Balance.Usables) do
	usableById[u.id] = u
end

--------------------------------------------------------------------
-- STAT READERS
--------------------------------------------------------------------

function EquipService.statsOf(player: Player)
	local data = DataService.get(player)
	return data.Stats or { str = 0, vit = 0, agi = 0, int = 0, dex = 0 }
end

function EquipService.weaponAtk(player: Player): number
	local data = DataService.get(player)
	local id = data.Equipped.weapon
	if id == "" then
		return 0
	end
	local eq = equipById[id]
	return eq and eq.atk or 0
end

function EquipService.armorDef(player: Player): number
	local data = DataService.get(player)
	local id = data.Equipped.armor
	if id == "" then
		return 0
	end
	local eq = equipById[id]
	return eq and eq.def or 0
end

--------------------------------------------------------------------
-- TERAPKAN KE HUMANOID
--------------------------------------------------------------------

local function buildWeaponTool(equipId: string): Tool
	local eq = equipById[equipId]
	local color = Color3.fromRGB(eq.color[1], eq.color[2], eq.color[3])

	local tool = Instance.new("Tool")
	tool.Name = eq.name
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	tool.ToolTip = "ATK +" .. eq.atk

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.5, 5.2, 0.5)
	handle.Color = color
	handle.Material = Enum.Material.Metal
	handle.CanCollide = false
	handle.Parent = tool

	-- gagang kayu di bawah bilah
	local grip = Instance.new("Part")
	grip.Name = "Grip"
	grip.Size = Vector3.new(0.6, 2, 0.6)
	grip.Color = Color3.fromRGB(105, 74, 46)
	grip.Material = Enum.Material.Wood
	grip.CanCollide = false
	local weld = Instance.new("Weld")
	weld.Part0 = handle
	weld.Part1 = grip
	weld.C0 = CFrame.new(0, -2.4, 0)
	grip.Parent = tool
	weld.Parent = handle

	-- pelindung tangan
	local guard = Instance.new("Part")
	guard.Name = "Guard"
	guard.Size = Vector3.new(1.6, 0.4, 1.6)
	guard.Color = Color3.fromRGB(255, 209, 102)
	guard.Material = Enum.Material.Metal
	guard.CanCollide = false
	local weld2 = Instance.new("Weld")
	weld2.Part0 = handle
	weld2.Part1 = guard
	weld2.C0 = CFrame.new(0, 0.6, 0)
	guard.Parent = tool
	weld2.Parent = handle

	if eq.kind == "weapon" and eq.atk >= 26 then
		-- pedang kristal: kilau neon tipis
		local glow = Instance.new("PointLight")
		glow.Color = color
		glow.Range = 8
		glow.Brightness = 0.8
		glow.Parent = handle
	end

	return tool
end

--- Terapkan HP/laju + beri visual senjata sesuai data.
function EquipService.apply(player: Player)
	local character = player.Character
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	local data = DataService.get(player)
	local stats = EquipService.statsOf(player)

	local maxHp = Balance.maxHp(stats.vit)
	humanoid.MaxHealth = maxHp
	if humanoid.Health > maxHp then
		humanoid.Health = maxHp
	end

	local speed = Balance.walkSpeed(stats.agi)
	if data.Tools.bike then
		speed = math.max(speed, 26)
	end
	-- buff makanan: laju
	if data.Buff.kind == "speed" and os.time() < (data.Buff.expiry or 0) then
		speed = speed * (1 + 0.12)
	end
	humanoid.WalkSpeed = speed

	-- visual senjata: hapus lama, beri baru
	local backpack = player:FindFirstChild("Backpack")
	if backpack then
		local old = backpack:FindFirstChild("AKM_Senjata")
		if old then
			old:Destroy()
		end
	end
	local carried = character:FindFirstChild("AKM_Senjata")
	if carried then
		carried:Destroy()
	end
	local weaponId = data.Equipped.weapon
	if weaponId ~= "" and equipById[weaponId] and backpack then
		local tool = buildWeaponTool(weaponId)
		tool.Name = "AKM_Senjata"
		tool.ToolTip = equipById[weaponId].name
		tool.Parent = backpack
	end
end

--------------------------------------------------------------------
-- PAKAI / LEPAS PERALATAN
--------------------------------------------------------------------

local function onEquip(player: Player, kind: any, id: any)
	if not DataService.has(player) or type(kind) ~= "string" or type(id) ~= "string" then
		return { ok = false, msg = "Permintaan tidak valid." }
	end
	local data = DataService.get(player)
	if id ~= "" then
		local eq = equipById[id]
		if not eq or eq.kind ~= kind then
			return { ok = false, msg = "Peralatan tidak dikenal." }
		end
		if (data.Equips[id] or 0) <= 0 then
			return { ok = false, msg = "Kamu belum punya " .. eq.name .. ". Tempa di Pak Tempa!" }
		end
		if DataService.levelOf(player) < eq.level then
			return { ok = false, msg = "Butuh level " .. eq.level .. " untuk memakai " .. eq.name .. "." }
		end
		data.Equipped[kind] = id
		EquipService.apply(player)
		DataService.markDirty(player)
		DataService.push(player)
		return { ok = true, msg = eq.name .. " dipakai! " .. (kind == "weapon" and ("ATK +" .. eq.atk) or ("DEF +" .. eq.def)) }
	else
		-- lepas
		if data.Equipped[kind] == "" then
			return { ok = false, msg = "Tidak ada yang dilepas." }
		end
		data.Equipped[kind] = ""
		EquipService.apply(player)
		DataService.markDirty(player)
		DataService.push(player)
		return { ok = true, msg = "Peralatan dilepas." }
	end
end

--------------------------------------------------------------------
-- MAKAN / RAMUAN
--------------------------------------------------------------------

local function onUseItem(player: Player, id: any)
	if not DataService.has(player) or type(id) ~= "string" then
		return { ok = false, msg = "Permintaan tidak valid." }
	end
	local data = DataService.get(player)
	if (data.Usables[id] or 0) <= 0 then
		return { ok = false, msg = "Kamu tidak punya barang itu." }
	end
	local u = usableById[id]
	if not u then
		return { ok = false, msg = "Item tidak dikenal." }
	end
	DataService.takeItem(player, "use", id, 1)

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if u.effect == "heal" and humanoid then
		local boost = 1 + EquipService.statsOf(player).int * 0.01 -- INT memperkuat ramuan
		local heal = math.floor(humanoid.MaxHealth * math.min(1, u.power * boost))
		humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + heal)
		DataService.push(player)
		return { ok = true, msg = u.name .. " dimakan! HP +" .. heal }
	elseif u.effect == "speed" then
		data.Buff = { kind = "speed", expiry = os.time() + u.duration }
		DataService.markDirty(player)
		EquipService.apply(player)
		DataService.push(player)
		return { ok = true, msg = u.name .. " dimakan! Lari +12% selama " .. math.floor(u.duration / 60) .. " menit." }
	end
	DataService.push(player)
	return { ok = true, msg = u.name .. " dimakan." }
end

--------------------------------------------------------------------
-- POIN STAT
--------------------------------------------------------------------

local function onAllocStat(player: Player, statId: any)
	if not DataService.has(player) or type(statId) ~= "string" then
		return { ok = false, msg = "Permintaan tidak valid." }
	end
	local valid = false
	for _, s in ipairs(Balance.Stats) do
		if s.id == statId then
			valid = true
			break
		end
	end
	if not valid then
		return { ok = false, msg = "Stat tidak dikenal." }
	end
	local data = DataService.get(player)
	if data.StatPoints <= 0 then
		return { ok = false, msg = "Poin stat habis. Naik level untuk lebih banyak poin!" }
	end
	if data.Stats[statId] >= Balance.MaxStatPerStat then
		return { ok = false, msg = "Atribut ini sudah maksimum (60)." }
	end
	data.StatPoints -= 1
	data.Stats[statId] += 1
	DataService.markDirty(player)
	EquipService.apply(player)
	DataService.push(player)
	return { ok = true, msg = "Poin diterapkan!" }
end

--------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------

function EquipService.init()
	Remotes.get("Equip").OnServerInvoke = onEquip
	Remotes.get("UseItem").OnServerInvoke = onUseItem
	Remotes.get("AllocStat").OnServerInvoke = onAllocStat

	-- respawn: terapkan ulang stat & senjata
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			task.wait(0.4)
			if DataService.has(player) then
				EquipService.apply(player)
			end
		end)
	end)
	for _, player in Players:GetPlayers() do
		player.CharacterAdded:Connect(function()
			task.wait(0.4)
			if DataService.has(player) then
				EquipService.apply(player)
			end
		end)
	end
end

return EquipService
