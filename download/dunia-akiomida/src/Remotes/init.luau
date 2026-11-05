--!nonstrict
--[[
	Remotes.luau - registry RemoteEvent/RemoteFunction Dunia Akiomida.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = {}

local FOLDER_NAME = "Remotes"

local DEFINITIONS = {
	StateSync = "RemoteEvent", -- server -> client: progres penuh
	Notify = "RemoteEvent", -- server -> client: toast
	ZoneEntered = "RemoteEvent", -- server -> client: info zona saat mendekat
	RequestStory = "RemoteFunction", -- client -> server: halaman cerita NPC zona
	StartQuiz = "RemoteFunction", -- client -> server: minta soal baru
	AnswerQuiz = "RemoteFunction", -- client -> server: jawab soal aktif
	ReadTopic = "RemoteFunction", -- client -> server: tandai bahasan dibaca
	RedeemDevCode = "RemoteFunction", -- client -> server: kode penjelajah
	GetLeaderboard = "RemoteFunction", -- client -> server: top XP
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
