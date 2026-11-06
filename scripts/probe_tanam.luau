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

local dunia = Workspace:FindFirstChild("Dunia")
print("dunia ok:", dunia ~= nil)

__SIM_IS_SERVER = true
local function serverCall(name, player, ...)
        local f = Workspace and Services.ReplicatedStorage:FindFirstChild("Remotes")
        local r = f and f:FindFirstChild(name)
        return r.OnServerInvoke(player, ...)
end

local masuk = serverCall("DuniaAct", P1, "masuk")
print("masuk:", masuk)
Stub.Scheduler.advance(0.3)

local root = P1.Character and P1.Character:FindFirstChild("HumanoidRootPart")
root.CFrame = CFrame.new(5085, 5, 18)
Stub.Scheduler.advance(0.1)
print("pos:", root.Position.X)

local ok, msg = serverCall("TanamAct", P1, "start", "wortel", 50)
print("start:", ok, msg)
Stub.Scheduler.advance(0.1)

for i = 1, 6 do
        local okS, res = serverCall("TanamAct", P1, "status")
        local t = okS and res or {}
        local soal = t.soal and t.soal.teks or "tidak ada soal"
        print("iter", i, "tertanam:", t.tertanam, "aktif:", tostring(t.aktif), "soal:", soal, "nomor:", t.soal and t.soal.nomor)
        if t.soal and t.soal.teks then
                local a, op, b = string.match(t.soal.teks, "^(%d+) (.+) (%d+) = %?$")
                local hasil = 0
                local x, y = tonumber(a), tonumber(b)
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
                print("   jawab", hasil, "->", okJ, msgJ)
        end
        Stub.Scheduler.advance(1.3)
end

local okS2, res2 = serverCall("TanamAct", P1, "status")
print("akhir: tertanam", okS2 and res2.tertanam, "aktif:", tostring(okS2 and res2.aktif))
