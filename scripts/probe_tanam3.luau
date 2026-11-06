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
local ReplicatedStorage = Services.ReplicatedStorage

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

local pg = Instance.new("Folder")
pg.Name = "PlayerGui"
pg.Parent = P1
__SIM_IS_SERVER = false
Stub.setLocalPlayer(P1)
script = Stub.clientScript()
RUN_init_client()
Stub.Scheduler.advance(0.2)

local gui = pg:FindFirstChild("DuniaAkiomida")
print("gui:", gui ~= nil)
__SIM_IS_SERVER = true

local dunia = Workspace:FindFirstChild("Dunia")

local function moveTo(x, y, z)
        local r = P1.Character and P1.Character:FindFirstChild("HumanoidRootPart")
        if r then
                r.CFrame = CFrame.new(x, y, z)
        end
end

local function firePrompt(match)
        for _, d in ipairs(dunia:GetDescendants()) do
                if d:IsA("ProximityPrompt") then
                        local okA = not match.action or d.ActionText == match.action
                        local okO = not match.object or d.ObjectText == match.object
                        if okA and okO then
                                d.Triggered:Fire(P1)
                                return true
                        end
                end
        end
        return false
end

moveTo(0, 5, 20)
firePrompt({ action = "Dunia-ku" })
Stub.Scheduler.advance(0.1)
local dimM = gui:FindFirstChild("DimLayar")
local masukBtn = dimM and findGui(dimM, "TextButton", "Masuk Dunia-ku") or nil
if masukBtn then
        masukBtn.Activated:Fire()
        Stub.Scheduler.advance(0.5)
end
local r1 = P1.Character and P1.Character:FindFirstChild("HumanoidRootPart")
print("di dunia:", r1 and r1.Position.X > 5000)

section = nil
moveTo(5085, 5, 18)
firePrompt({ object = "Papan Tanam" })
Stub.Scheduler.advance(0.1)
print("panel papan terbuka:", findGui(gui, "TextLabel", "Papan Tanam") ~= nil)

local pilihOk = false
for _, d in ipairs(gui:GetDescendants()) do
        if d:IsA("TextLabel") and d.Text and string.find(d.Text, "Wortel", 1, true) and d.Parent and d.Parent:IsA("TextButton") then
                d.Parent.Activated:Fire()
                pilihOk = true
                break
        end
end
print("pilih wortel:", pilihOk)
Stub.Scheduler.advance(0.05)

for _, d in ipairs(gui:GetDescendants()) do
        if d:IsA("TextButton") and d.Text == "50" then
                d.Activated:Fire()
                break
        end
end
Stub.Scheduler.advance(0.05)

local mulaiBtn = findGui(gui, "TextButton", "Mulai Tanam")
print("mulai ada:", mulaiBtn ~= nil)
burn(1.2)
if mulaiBtn then
        mulaiBtn.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end

local soalNomor = findGui(gui, "TextLabel", "Soal 1 dari 5")
print("label Soal 1 dari 5:", soalNomor ~= nil)
local tabAktifTanam = findGui(gui, "TextLabel", "Pilih benih untuk ditanam")
print("tanamTab masih tampak:", tabAktifTanam ~= nil)
for _, d in ipairs(gui:GetDescendants()) do
        if d:IsA("TextLabel") and d.Text and string.find(d.Text, "dari", 1, true) and string.find(d.Text, "Soal", 1, true) then
                print("  kandidat label soal:", d.Text)
        end
end

local soalTeks
for _, d in ipairs(gui:GetDescendants()) do
        if d:IsA("TextLabel") and d.Text and string.match(d.Text, "^%d+ .+ %d+ = %?$") then
                soalTeks = d
                break
        end
end
print("soalTeks:", soalTeks and soalTeks.Text)

if soalTeks then
        local a, op, b = string.match(soalTeks.Text, "^(%d+) (.+) (%d+) = %?$")
        local x, y = tonumber(a), tonumber(b)
        local hasil = op == "+" and (x + y) or (op == "-" and (x - y) or (op == "x" and (x * y) or math.floor(x / y)))
        local box = nil
        for _, d in ipairs(gui:GetDescendants()) do
                if d:IsA("TextBox") and d.PlaceholderText == "Tulis jawaban angka" then
                        box = d
                        break
                end
        end
        print("box:", box ~= nil)
        box.Text = tostring(hasil)
        local btn = findGui(gui, "TextButton", "Jawab")
        btn.Activated:Fire()
        Stub.Scheduler.advance(0.1)
        local papan = findGui(dunia, "TextLabel", "TERTANAM")
        print("papan setelah jawab 1:", papan and papan.Text)
        local nomor2 = findGui(gui, "TextLabel", "Soal 2 dari 5")
        print("label Soal 2 dari 5:", nomor2 ~= nil)
        local f2
        for _, d in ipairs(gui:GetDescendants()) do
                if d:IsA("TextLabel") and d.Text and string.match(d.Text, "^%d+ .+ %d+ = %?$") then
                        f2 = d
                        break
                end
        end
        print("soalTeks ke-2:", f2 and f2.Text)
end

print("=== TAS PENUH FLOW ===")
__SIM_IS_SERVER = true
local function serverCall(name, player, ...)
	local f = Services.ReplicatedStorage:FindFirstChild("Remotes")
	local r = f and f:FindFirstChild(name)
	return r.OnServerInvoke(player, ...)
end

local dta = Services.DataStoreService:GetDataStore("AKM_T1")
local data = nil
local function getData(pl)
	return rawreq("./sim/roblox_stub") and nil or nil
end
local MOD_DS = nil

e
local semaiBtn = findGui(gui, "TextButton", "Klaim Semua")
print("semai panel masih berisi:", semaiBtn ~= nil)
local root2 = P1.Character:FindFirstChild("HumanoidRootPart")
root2.CFrame = CFrame.new(5085, 5, 18)
Stub.Scheduler.advance(0.1)
firePrompt({ object = "Papan Tanam" })
Stub.Scheduler.advance(0.1)
print("panel papan terbuka 2:", findGui(gui, "TextLabel", "Papan Tanam") ~= nil)
local pilih2 = false
for _, d in ipairs(gui:GetDescendants()) do
	if d:IsA("TextLabel") and d.Text and string.find(d.Text, "Wortel", 1, true) and d.Parent and d.Parent:IsA("TextButton") and tampakVis(d) then
		d.Parent.Activated:Fire()
		pilih2 = true
		break
	end
end
print("pilih wortel 2:", pilih2)
for _, d in ipairs(gui:GetDescendants()) do
	if d:IsA("TextButton") and d.Text == "1" and tampakVis(d) then
		d.Activated:Fire()
		break
	end
end
Stub.Scheduler.advance(0.05)
local mulai2 = findGui(gui, "TextButton", "Mulai Tanam")
burn(1.2)
if mulai2 then
	mulai2.Activated:Fire()
	Stub.Scheduler.advance(0.1)
end
local okS9, res9 = serverCall("TanamAct", P1, "status")
print("server status setelah mulai: aktif:", okS9 and tostring(res9.aktif), "jumlah:", okS9 and tostring(res9.jumlah), "soal:", okS9 and res9.soal and res9.soal.teks)
if okS9 and res9.soal and res9.soal.teks then
	local a, op, b = string.match(res9.soal.teks, "^(%d+) (.+) (%d+) = %?$")
	local x, y = tonumber(a), tonumber(b)
	local hasil = op == "+" and (x + y) or (op == "-" and (x - y) or (op == "x" and (x * y) or math.floor(x / y)))
	local okJ2, msgJ2 = serverCall("TanamAct", P1, "jawab", hasil)
	print("jawab server:", hasil, okJ2, msgJ2)
end
Stub.Scheduler.advance(0.2)
local grid2 = nil
local d2 = Workspace:FindFirstChild("Dunia")
for _, f in ipairs(d2:GetDescendants()) do
	if f:IsA("Folder") and string.sub(f.Name, 1, 9) == "PlotGrid_" then
		grid2 = f
	end
end
local ada = false
if grid2 then
	for _, m in ipairs(grid2:GetChildren()) do
		if m:IsA("Model") and m.Name == "Tanaman_0" then
			ada = true
		end
	end
end
print("Tanaman_0 ada:", ada)
