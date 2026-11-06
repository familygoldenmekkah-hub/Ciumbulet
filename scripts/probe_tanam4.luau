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

local function tampakVis(d)
	local cur = d
	while cur and cur.Parent do
		if cur.Visible == false then
			return false
		end
		cur = cur.Parent
	end
	return true
end

local function findGui(root, class, textMatch)
	if not root then
		return nil
	end
	for _, d in ipairs(root:GetDescendants()) do
		if d:IsA(class) and d.Text and (not textMatch or string.find(d.Text, textMatch, 1, true)) then
			return d
		end
	end
	return nil
end

local function serverCall(name, player, ...)
	local f = Services.ReplicatedStorage:FindFirstChild("Remotes")
	local r = f and f:FindFirstChild(name)
	return r.OnServerInvoke(player, ...)
end

local function moveTo(P, x, y, z)
	local r = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
	if r then
		r.CFrame = CFrame.new(x, y, z)
	end
end

local function firePrompt(P, dunia, match)
	for _, d in ipairs(dunia:GetDescendants()) do
		if d:IsA("ProximityPrompt") then
			local okA = not match.action or d.ActionText == match.action
			local okO = not match.object or d.ObjectText == match.object
			if okA and okO then
				d.Triggered:Fire(P)
				return true
			end
		end
	end
	return false
end

local function pilihBarisTeks(gui, teks)
	for _, d in ipairs(gui:GetDescendants()) do
		if d:IsA("TextLabel") and d.Text and string.find(d.Text, teks, 1, true) and d.Parent and d.Parent:IsA("TextButton") and d.Parent.Text == "" and tampakVis(d.Parent) then
			d.Parent.Activated:Fire()
			return true
		end
	end
	return false
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
		{ kind = "hasil", id = "wortel", count = 10 },
	},
	dev = false,
}
local P1 = Stub.addPlayer(1001, "akiomida")
Stub.giveCharacter(P1, 0, 6, 44)
Players.PlayerAdded:Fire(P1)
Stub.Scheduler.advance(0.5)

local pg = Instance.new("Folder")
pg.Name = "PlayerGui"
pg.Parent = P1
__SIM_IS_SERVER = false
Stub.setLocalPlayer(P1)
script = Stub.clientScript()
RUN_init_client()
Stub.Scheduler.advance(0.2)

local gui = pg:FindFirstChild("DuniaAkiomida")
local dunia = Workspace:FindFirstChild("Dunia")
__SIM_IS_SERVER = true

local function masukDunia()
	moveTo(P1, 0, 5, 20)
	firePrompt(P1, dunia, { action = "Dunia-ku" })
	Stub.Scheduler.advance(0.1)
	local dimM = gui:FindFirstChild("DimLayar")
	local masukBtn = dimM and findGui(dimM, "TextButton", "Masuk Dunia-ku") or nil
	if masukBtn then
		masukBtn.Activated:Fire()
		Stub.Scheduler.advance(0.5)
	end
end

masukDunia()
do local rc = P1.Character and P1.Character:FindFirstChild("HumanoidRootPart") print("di dunia:", rc ~= nil and rc.Position.X > 5000) end

local function statusTeks(tag)
	local okS, res = serverCall("TanamAct", P1, "status")
	print(tag, "aktif:", okS and tostring(res.aktif), "tertanam:", okS and tostring(res.tertanam), "jumlah:", okS and tostring(res.jumlah), "soal:", okS and res.soal and res.soal.teks)
end

local function tanamSatu()
	moveTo(P1, 5085, 5, 18)
	Stub.Scheduler.advance(0.1)
	firePrompt(P1, dunia, { object = "Papan Tanam" })
	Stub.Scheduler.advance(0.1)
	print("  panel papan:", findGui(gui, "TextLabel", "Papan Tanam") ~= nil)
	print("  pilih wortel:", pilihBarisTeks(gui, "Wortel"))
	for _, d in ipairs(gui:GetDescendants()) do
		if d:IsA("TextButton") and d.Text == "1" and tampakVis(d) then
			d.Activated:Fire()
			break
		end
	end
	Stub.Scheduler.advance(0.05)
	local mulai = findGui(gui, "TextButton", "Mulai Tanam")
	burn(1.2)
	if mulai then
		mulai.Activated:Fire()
		Stub.Scheduler.advance(0.1)
	end
	statusTeks("  setelah mulai:")
	burn(1.2)
	local st
	local okS, res = serverCall("TanamAct", P1, "status")
	st = okS and res
	if st and st.soal and st.soal.teks then
		local a, op, b = string.match(st.soal.teks, "^(%d+) (.+) (%d+) = %?$")
		local x, y = tonumber(a), tonumber(b)
		local hasil = op == "+" and (x + y) or (op == "-" and (x - y) or (op == "x" and (x * y) or math.floor(x / y)))
		local box = nil
		for _, d in ipairs(gui:GetDescendants()) do
			if d:IsA("TextBox") and d.PlaceholderText == "Tulis jawaban angka" and tampakVis(d) then
				box = d
			end
		end
		box.Text = tostring(hasil)
		local btn = findGui(gui, "TextButton", "Jawab")
		btn.Activated:Fire()
		Stub.Scheduler.advance(0.1)
		local okJ, msgJ = "via UI", ""
		statusTeks("  setelah jawab:")
	else
		print("  SOAL HILANG!")
	end
	local ada0 = false
	for _, f in ipairs(dunia:GetDescendants()) do
		if f:IsA("Folder") and string.sub(f.Name, 1, 9) == "PlotGrid_" then
			for _, m in ipairs(f:GetChildren()) do
				if m:IsA("Model") and m.Name == "Tanaman_0" then
					ada0 = true
				end
			end
		end
	end
	print("  Tanaman_0 ada:", ada0)
end

print("--- tanam 1 sebelum mesin ---")
tanamSatu()

print("--- MESIN: atur 10 wortel via UI ---")
moveTo(P1, 5185, 5, 50)
Stub.Scheduler.advance(0.1)
firePrompt(P1, dunia, { action = "Semai Panen", object = "Mesin Semai" })
Stub.Scheduler.advance(0.2)
print("panel mesin:", findGui(gui, "TextLabel", "Mesin Semai Panen") ~= nil)
print("pilih baris wortel:", pilihBarisTeks(gui, "Wortel"))
for _, d in ipairs(gui:GetDescendants()) do
	if d:IsA("TextButton") and d.Text == "10" and tampakVis(d) then
		d.Activated:Fire()
		break
	end
end
Stub.Scheduler.advance(0.05)
local isi = findGui(gui, "TextButton", "Isi Mesin Semai")
if isi then
	isi.Activated:Fire()
	Stub.Scheduler.advance(0.3)
end
print("modal kabel:", findGui(gui, "TextLabel", "Sambungkan Kabel Mesin") ~= nil)
local okK, msgK = serverCall("SemaiAct", P1, "kabel")
print("kabel jadi:", okK, msgK)
Stub.Scheduler.advance(3.5)
print("papan tuntas:", findGui(dunia, "TextLabel", "SEMAI TUNTAS - KLAIM HASIL") ~= nil)
local klaim = findGui(gui, "TextButton", "Klaim Semua")
print("klaim btn:", klaim ~= nil)
if klaim then
	klaim.Activated:Fire()
	Stub.Scheduler.advance(0.3)
end
print("struk:", findGui(gui, "TextLabel", "Hasil Diklaim") ~= nil)

print("--- tanam 1 setelah mesin (replikasi fase tas penuh) ---")
local st = serverCall("GetState", P1)
for _, slot in ipairs(st.tas) do
	print("  tas:", slot.kind, slot.id, slot.count)
end
tanamSatu()
