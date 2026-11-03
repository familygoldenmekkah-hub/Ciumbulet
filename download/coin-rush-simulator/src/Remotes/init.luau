--!nonstrict
--[[
        Remotes.luau
        Central registry of every RemoteEvent / RemoteFunction.
        Server: call Remotes.init() once at boot (creates the folder).
        Client: Remotes.get(name) waits for the remote to exist.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = {}

local FOLDER_NAME = "Remotes"

local DEFINITIONS = {
        StateSync = "RemoteEvent", -- server -> client: full player data snapshot
        Click = "RemoteEvent", -- client -> server: player clicked
        Notify = "RemoteEvent", -- server -> client: toast message
        Purchase = "RemoteFunction", -- client -> server: buy upgrade / pet / rebirth
        GetLeaderboard = "RemoteFunction", -- client -> server: fetch global top 10
}

local function folder(): Folder
        local f = ReplicatedStorage:FindFirstChild(FOLDER_NAME)
        if not f then
                f = Instance.new("Folder")
                f.Name = FOLDER_NAME
                f.Parent = ReplicatedStorage
        end
        return f :: Folder
end

--- Server-only: create every remote instance. Idempotent.
function Remotes.init()
        assert(RunService:IsServer(), "Remotes.init is server-only")
        local f = folder()
        for name, className in DEFINITIONS do
                if not f:FindFirstChild(name) then
                        local remote = Instance.new(className)
                        remote.Name = name
                        remote.Parent = f
                end
        end
end

--- Fetch a remote. Server: errors if missing. Client: waits up to 30s.
--- Typed as any so callers can use FireServer/InvokeServer/OnClientEvent directly.
function Remotes.get(name: string): any
        assert(DEFINITIONS[name], "Unknown remote: " .. tostring(name))
        local f = folder()
        if RunService:IsServer() then
                return f:FindFirstChild(name) or error("Remote not initialized: " .. name)
        end
        return f:WaitForChild(name, 30) or error("Remote never arrived: " .. name)
end

return Remotes
