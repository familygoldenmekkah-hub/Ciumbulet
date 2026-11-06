local rawreq = require
local Stub = rawreq("./sim/roblox_stub")
Stub.install()

require = function(arg)
	if type(arg) == "table" and arg.__requirePath then
		return rawreq(arg.__requirePath)
	end
	return rawreq(arg)
end

local Services = Stub.Services
local Players = Services.Players
local Workspace = Services.Workspace

local function burn(t)
	local tgt = os.clock() + t
	while os.clock() < tgt do
	end
end

Stub.Scheduler.advance(0.05)
script = Stub.serverScript()
RUN_init_server()
Stub.Scheduler.advance(0.2)

local profStore = Stub.Services.DataStoreService:GetDataStore("AKM_T1")
profStore.__data["u_1001"] = {
	m = 900000,
	t = {
		{ kind = "benih", id = "wortel", count = 55 },
	},
	dev = false,
}
local P1 = Stub.addPlayer(1001, "akiomida")
Stub.giveCharacter(P1, 0, 6, 44)
Players.PlayerAdded:Fire(P1)
Stub.Scheduler.advance(0.5)

local function serverCall(name, player, ...)
	local f = Services.ReplicatedStorage:FindFirstChild("Remotes")
	local r = f and f:FindFirstChild(name)
	return r.OnServerInvoke(player, ...)
end

serverCall("DuniaAct", P1, "masuk")
Stub.Scheduler.advance(0.3)
local root = P1.Character and P1.Character:FindFirstChild("HumanoidRootPart")
root.CFrame = CFrame.new(5085, 5, 18)
Stub.Scheduler.advance(0.1)

local ok, msg = serverCall("TanamAct", P1, "start", "wortel", 50)
print("start:", ok, msg)
Stub.Scheduler.advance(0.1)

for i = 1, 5 do
	burn(1.2)
	local okS, res = serverCall("TanamAct", P1, "status")
	local t = okS and res or {}
	if t.soal and t.soal.teks then
		local a, op, b = string.match(t.soal.teks, "^(%d+) (.+) (%d+) = %?$")
		local x, y = tonumber(a), tonumber(b)
		local hasil = 0
		if op == "+" then
			hasil = x + y
		elseif op == "-" then
			hasil = x - y
		elseif op == "x" then
			hasil = x * y
		elseif op == ":" then
			hasil = math.floor(x / y)
		end
		local okJ, msgJ = serverCall("TanamAct", P1, "jawab", hasil)
		print("jawab", i, t.soal.teks, "->", hasil, "ok:", okJ, "|", msgJ)
	else
		print("iter", i, "soal hilang; aktif:", tostring(t.aktif), "tertanam:", tostring(t.tertanam))
	end
	Stub.Scheduler.advance(0.1)
end

local okS2, res2 = serverCall("TanamAct", P1, "status")
print("akhir: tertanam", okS2 and res2.tertanam)
local ls = P1:FindFirstChild("leaderstats")
print("benih wortel sisa:")
for _, s in ipairs((okS2 and res2) and {} or {}) do
end
local st = serverCall("GetState", P1)
for _, slot in ipairs(st.tas) do
	if slot.id == "wortel" then
		print("  wortel", slot.kind, slot.count)
	end
end
