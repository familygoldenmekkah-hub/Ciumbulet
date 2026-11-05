local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Remotes)

local DataService = require(script.Parent.DataService)

local GatherService = {}

local FISH_COOLDOWN = 4
local fishCooldown: { [Player]: number } = {}

local worldFolder: Folder? = nil

local function world(): Folder
	local f = worldFolder
	if not f then
		f = workspace:FindFirstChild("AKM_Dunia") :: Folder?
		if not f then
			f = Instance.new("Folder")
			f.Name = "AKM_Dunia"
			f.Parent = workspace
		end
		worldFolder = f
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

function GatherService.buildPier(basePosition: Vector3, direction: Vector3)
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
			CFrame = CFrame.new(basePosition + Vector3.new(i * 5.5, 0.4, 0)),
			Color = Color3.fromRGB(110, 80, 50),
			Material = Enum.Material.Wood,
		})
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Pancing Ikan"
	prompt.ObjectText = "Kolam Memancing"
	prompt.MaxActivationDistance = 10
	prompt.HoldDuration = 2.5
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
		if caught.id == "sepatu" then
			notify(player, "Tidak Nyangka...", "Kamu menarik Sepatu Bot Tua?! Tetap dijual saja di koperasi.")
		else
			notify(player, "Dapat Ikan!", "+" .. caught.name .. " - jual di koperasi lahanku!")
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
