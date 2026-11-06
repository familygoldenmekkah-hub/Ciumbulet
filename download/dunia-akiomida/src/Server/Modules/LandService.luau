local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Layout = require(ReplicatedStorage.Shared.Layout)

local LandService = {}

local ownerOf: { [number]: number } = {}
local landOf: { [number]: number } = {}
local umumSpawn: SpawnLocation? = nil
local kotaSpawn: SpawnLocation? = nil

function LandService.registerUmum(spawn: SpawnLocation)
        umumSpawn = spawn
end

function LandService.registerKota(spawn: SpawnLocation)
        kotaSpawn = spawn
end

function LandService.origin(index: number): Vector3
        local x, z = Layout.cellOrigin(index)
        return Vector3.new(x + Layout.duniaOffsetX(), 0, z)
end

function LandService.ownerOf(index: number): number?
        return ownerOf[index]
end

function LandService.landOf(player): number?
        return landOf[player.UserId]
end

function LandService.umumSpawn(): SpawnLocation?
        return umumSpawn
end

function LandService.kotaSpawn(): SpawnLocation?
        return kotaSpawn
end

function LandService.claimFree(userId: number, isTaken: (number) -> boolean): number
        for i = 1, Layout.LahanCount do
                if not ownerOf[i] and not isTaken(i) then
                        ownerOf[i] = userId
                        landOf[userId] = i
                        return i
                end
        end
        return 0
end

function LandService.firstFree(isTaken: (number) -> boolean): number
        for i = 1, Layout.LahanCount do
                if not ownerOf[i] and not isTaken(i) then
                        return i
                end
        end
        return 0
end

function LandService.reserve(index: number, userId: number): boolean
        if ownerOf[index] then
                return false
        end
        ownerOf[index] = userId
        return true
end

function LandService.claim(index: number, userId: number): boolean
        if ownerOf[index] and ownerOf[index] ~= userId then
                return false
        end
        ownerOf[index] = userId
        landOf[userId] = index
        return true
end

function LandService.free(index: number, userId: number)
        if ownerOf[index] == userId then
                ownerOf[index] = nil
                if landOf[userId] == index then
                        landOf[userId] = nil
                end
        end
end

function LandService.isInside(index: number, position: Vector3, margin: number): boolean
        local o = LandService.origin(index)
        local p = position - o
        return p.X >= -margin and p.X <= Layout.SizeX + margin and p.Z >= -margin and p.Z <= Layout.SizeZ + margin
end

return LandService
