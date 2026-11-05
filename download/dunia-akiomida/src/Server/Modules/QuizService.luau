--!nonstrict
--[[
	QuizService.luau - KUIS OPSIONAL.
	Kuis BUKAN lagi inti gameplay: tidak ada popup paksa, tidak ada zona
	terkunci. Hanya Kak Pintar di alun-alun yang menawarkan soal bonus -
	penjumlahan buatan sendiri (original) dengan hadiah Micda. Pemain yang
	hanya mau bertani/mengelana bisa mengabaikannya sepenuhnya.
	Juga menangani kode penjelajah (server-only via DevCodeVault).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage.Shared.Config)
local MathGen = require(ReplicatedStorage.Shared.MathGen)
local Remotes = require(ReplicatedStorage.Remotes)

local DataService = require(script.Parent.DataService)
local DevCodeVault = require(script.Parent.DevCodeVault)

local QuizService = {}

local active: { [Player]: { qid: string, benar: number, betul: string, salah: string, born: number } } = {}
local lastRequest: { [Player]: number } = {}

--------------------------------------------------------------------
-- NPC KAK PINTAR -> panel opsional
--------------------------------------------------------------------

function QuizService.bindPrompt(prompt: ProximityPrompt)
	prompt.ActionText = "Ikut Kuis Bonus"
	prompt.ObjectText = "Kak Pintar"
	prompt.MaxActivationDistance = 11
	prompt.HoldDuration = 0
	prompt.Triggered:Connect(function(player)
		if DataService.has(player) then
			Remotes.get("OpenQuiz"):FireClient(player)
		end
	end)
end

--------------------------------------------------------------------
-- MINTA SOAL
--------------------------------------------------------------------

local function onQuizRequest(player: Player)
	if not DataService.has(player) then
		return nil
	end
	local now = time()
	if lastRequest[player] and now - lastRequest[player] < Config.Economy.QuizCooldown then
		return { cooldown = math.ceil(Config.Economy.QuizCooldown - (now - lastRequest[player])) }
	end
	lastRequest[player] = now

	-- tingkat soal mengikuti level pemain (1-6)
	local level = math.clamp(DataService.levelOf(player), 1, 6)
	local q = MathGen.generate(level)
	local qid = tostring(math.random(1, 1e9)) .. "-" .. tostring(os.clock())
	active[player] = {
		qid = qid,
		benar = q.benar,
		betul = q.betul,
		salah = q.salah,
		born = now,
	}
	return {
		qid = qid,
		t = q.t,
		opsi = q.opsi,
		reward = Config.Economy.QuizRewardCoins,
		-- kunci jawaban TIDAK dikirim ke client
	}
end

--------------------------------------------------------------------
-- JAWAB SOAL
--------------------------------------------------------------------

local function onQuizAnswer(player: Player, qid: any, choice: any)
	if not DataService.has(player) or type(choice) ~= "number" then
		return nil
	end
	local current = active[player]
	if not current or type(qid) ~= "string" or qid ~= current.qid then
		return nil
	end
	if time() - current.born > 60 then
		active[player] = nil
		return { correct = false, msg = "Waktu habis - soal kedaluwarsa." }
	end
	active[player] = nil

	local correct = math.floor(choice) == current.benar
	if not correct then
		DataService.markDirty(player)
		return { correct = false, msg = current.salah }
	end

	DataService.addCoins(player, Config.Economy.QuizRewardCoins, true)
	DataService.addXP(player, Config.Economy.QuizRewardXp)
	DataService.push(player)
	return {
		correct = true,
		msg = current.betul,
		reward = Config.Economy.QuizRewardCoins,
	}
end

--------------------------------------------------------------------
-- KODE PENJELAJAH (dev)
--------------------------------------------------------------------

local function onRedeemDevCode(player: Player, code: any)
	if type(code) ~= "string" or not DataService.has(player) then
		return false, "Kode tidak valid."
	end
	if code ~= DevCodeVault.CODE then
		return false, "Kode salah."
	end
	local data = DataService.get(player)
	if data.Dev then
		return true, "Kode sudah aktif sebelumnya."
	end
	data.Dev = true
	DataService.addCoins(player, 5000, false)
	DataService.addXP(player, 500)
	DataService.markDirty(player)
	DataService.push(player)
	Remotes.get("Notify"):FireClient(player, "Penjelajah Dev",
		"Kode diterima! +5.000 Micda & +500 XP. Selamat datang kembali, pembuat dunia!")
	return true, "Kode diterima! Hadiah dev masuk."
end

--------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------

function QuizService.init()
	Remotes.get("QuizRequest").OnServerInvoke = onQuizRequest
	Remotes.get("QuizAnswer").OnServerInvoke = onQuizAnswer
	Remotes.get("RedeemDevCode").OnServerInvoke = onRedeemDevCode

	Players.PlayerRemoving:Connect(function(player)
		active[player] = nil
		lastRequest[player] = nil
	end)
end

return QuizService
