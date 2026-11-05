local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = {}

local FOLDER_NAME = "Remotes"

local DEFINITIONS = {
        Notify = "RemoteEvent",
        StateSync = "RemoteEvent",
        OpenFarm = "RemoteEvent",
        OpenToko = "RemoteEvent",
        OpenKoperasi = "RemoteEvent",
        OpenCraft = "RemoteEvent",
        OpenChar = "RemoteEvent",
        OpenLandBoard = "RemoteEvent",
        GetState = "RemoteFunction",
        FarmAct = "RemoteFunction",
        TokoAct = "RemoteFunction",
        KoperasiAct = "RemoteFunction",
        Craft = "RemoteFunction",
        Equip = "RemoteFunction",
        UseItem = "RemoteFunction",
        AllocStat = "RemoteFunction",
        LandBoard = "RemoteFunction",
        RedeemDevCode = "RemoteFunction",
        GetLeaderboard = "RemoteFunction",
        Attack = "RemoteFunction",
        Skill = "RemoteFunction",
        EquipUpgrade = "RemoteFunction",
        BossState = "RemoteEvent",
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

function Remotes.get(name: string): any
        assert(DEFINITIONS[name], "Unknown remote: " .. tostring(name))
        local f = folder()
        if RunService:IsServer() then
                return f:FindFirstChild(name) or error("Remote not initialized: " .. name)
        end
        return f:WaitForChild(name, 30) or error("Remote never arrived: " .. name)
end

return Remotes
