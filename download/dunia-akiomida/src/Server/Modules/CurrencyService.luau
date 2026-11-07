local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UangLogic = require(ReplicatedStorage.Shared.UangLogic)

local CurrencyService = {}

local Data, Audit
local clock = os.time

function CurrencyService.bind(deps)
	Data = deps.Data
	Audit = deps.Audit
end

function CurrencyService.setClock(fn)
	clock = fn
end

local function st(player)
	return Data.uangState(player)
end

function CurrencyService.GetMicda(player: Player): number
	local s = st(player)
	if not s then
		return 0
	end
	return UangLogic.saldo(s)
end

function CurrencyService.RuangMicda(player: Player): number
	local s = st(player)
	if not s then
		return 0
	end
	return UangLogic.ruangSisa(s)
end

function CurrencyService.AddMicda(player: Player, amountRaw: any, reason: any): (boolean, string)
	local s = st(player)
	if not s then
		return false, "Data belum siap."
	end
	local ok, msg = UangLogic.tambah(s, amountRaw, reason, clock())
	if not ok then
		if Audit then
			Audit.catat(player, "micda_tolak", tostring(reason) .. "|" .. tostring(amountRaw))
		end
		return false, msg
	end
	Data.markDirty(player)
	Data.push(player)
	return true, "ok"
end

function CurrencyService.SpendMicda(player: Player, amountRaw: any, reason: any): (boolean, string)
	local s = st(player)
	if not s then
		return false, "Data belum siap."
	end
	local ok, msg = UangLogic.bayar(s, amountRaw, reason, clock())
	if not ok then
		if Audit then
			Audit.catat(player, "micda_tolak", tostring(reason) .. "|" .. tostring(amountRaw))
		end
		return false, msg
	end
	Data.markDirty(player)
	Data.push(player)
	return true, "ok"
end

function CurrencyService.ledgerOf(player: Player): { any }
	local s = st(player)
	if not s then
		return {}
	end
	return UangLogic.ledgerOf(s)
end

function CurrencyService.startIntegritas()
	task.spawn(function()
		while true do
			task.wait(45)
			for _, p in ipairs(Players:GetPlayers()) do
				local s = st(p)
				if s then
					local m = UangLogic.saldo(s)
					if m ~= m or m < 0 then
						s.m = 0
						Data.markDirty(p)
						Data.push(p)
						if Audit then
							Audit.anomali(p, "uang_korup", "saldo " .. tostring(m))
						end
					elseif m > UangLogic.MaksSaldo then
						s.m = UangLogic.MaksSaldo
						Data.markDirty(p)
						Data.push(p)
						if Audit then
							Audit.anomali(p, "uang_lebih", "saldo " .. UangLogic.format(m))
						end
					end
				end
			end
		end
	end)
end

return CurrencyService
