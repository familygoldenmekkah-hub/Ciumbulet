--!nonstrict
--[[
        Remotes.luau - registry RemoteEvent/RemoteFunction Dunia Akiomida v2.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = {}

local FOLDER_NAME = "Remotes"

local DEFINITIONS = {
        Notify = "RemoteEvent", -- server -> client: toast
        StateSync = "RemoteEvent", -- server -> client: snapshot data lengkap
        OpenShop = "RemoteEvent", -- server -> client: buka panel toko (shopId)
        OpenPlant = "RemoteEvent", -- server -> client: buka panel pilih bibit (plot, tile)
        OpenQuiz = "RemoteEvent", -- server -> client: buka panel kuis opsional
        GetState = "RemoteFunction", -- client -> server: minta snapshot
        BuyItem = "RemoteFunction", -- client -> server: beli item toko
        SellItem = "RemoteFunction", -- client -> server: jual barang (kind, id, all)
        SellAll = "RemoteFunction", -- client -> server: jual semua isi tas
        PlantSeed = "RemoteFunction", -- client -> server: tanam bibit di petak
        EquipPet = "RemoteFunction", -- client -> server: pakai/lepas peliharaan
        QuizRequest = "RemoteFunction", -- client -> server: minta soal kuis opsional
        QuizAnswer = "RemoteFunction", -- client -> server: jawab soal
        RedeemDevCode = "RemoteFunction", -- client -> server: kode penjelajah
        GetLeaderboard = "RemoteFunction", -- client -> server: papan juara
        -- v3: kombat, craft, peralatan, tugas, dagang
        Attack = "RemoteFunction", -- client -> server: serang monster (monsterId)
        Craft = "RemoteFunction", -- client -> server: buat item dari resep
        Equip = "RemoteFunction", -- client -> server: pakai/lepas senjata-zirah
        UseItem = "RemoteFunction", -- client -> server: makan makanan/ramuan
        AllocStat = "RemoteFunction", -- client -> server: tambah poin stat
        QuestAction = "RemoteFunction", -- client -> server: list/accept/claim tugas
        TradeAction = "RemoteFunction", -- client -> server: invite/offer/coin/ready/cancel
        OpenCraft = "RemoteEvent", -- server -> client: buka panel tempa/dapur
        OpenQuest = "RemoteEvent", -- server -> client: buka papan tugas
        OpenTrade = "RemoteEvent", -- server -> client: buka panel dagang
        OpenChar = "RemoteEvent", -- server -> client: buka panel karakter
        BossState = "RemoteEvent", -- server -> semua: status boss raid
        TradeSync = "RemoteEvent", -- server -> kedua pihak: snapshot dagang
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
