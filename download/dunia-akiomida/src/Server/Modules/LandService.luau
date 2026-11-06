local Layout = require(game:GetService("ReplicatedStorage").Shared.Layout)

local LandService = {}

local ownerOf: { [number]: number } = {}
local landOf: { [number]: number } = {}
local spawnOf: { [number]: SpawnLocation } = {}
local umumSpawn: SpawnLocation? = nil
local kotaSpawn: SpawnLocation? = nil

function LandService.registerSpawn(index: number, spawn: SpawnLocation)
	spawnOf[index] = spawn
end

function LandService.registerUmum(spawn: SpawnLocation)
	umumSpawn = spawn
end

function LandService.registerKota(spawn: SpawnLocation)
	kotaSpawn = spawn
end

function LandService.origin(index: number): Vector3
	local x, z = Layout.cellOrigin(index)
	return Vector3.new(x, 0, z)
end

function LandService.ownerOf(index: number): number?
	return ownerOf[index]
end

function LandService.landOf(player): number?
	return landOf[player.UserId]
end

function LandService.spawnOf(index: number): SpawnLocation?
	return spawnOf[index]
end

function LandService.umumSpawn(): SpawnLocation?
	return umumSpawn
end

function LandService.kotaSpawn(): SpawnLocation?
	return kotaSpawn
end

function LandService.assign(player): number
	for i = 1, Layout.LahanCount do
		if not ownerOf[i] then
			ownerOf[i] = player.UserId
			landOf[player.UserId] = i
			return i
		end
	end
	return 0
end

function LandService.release(player): number
	local idx = landOf[player.UserId]
	if idx and ownerOf[idx] == player.UserId then
		ownerOf[idx] = nil
		landOf[player.UserId] = nil
	end
	return idx or 0
end

function LandService.isInside(index: number, position: Vector3, margin: number): boolean
	local o = LandService.origin(index)
	local p = position - o
	return p.X >= -margin and p.X <= Layout.SizeX + margin and p.Z >= -margin and p.Z <= Layout.SizeZ + margin
end

return LandService
