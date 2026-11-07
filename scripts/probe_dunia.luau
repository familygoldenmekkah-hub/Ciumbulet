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

print("A: boot")
script = Stub.serverScript()
RUN_init_server()
Stub.Scheduler.advance(0.2)
print("B: server hidup")

local duniaStore = Stub.Services.DataStoreService:GetDataStore("AKM_Dunia")
duniaStore.__data["d_1005"] = {
        n = "Dunia Lima",
        pl = { [0] = { c = "wortel", r = os.time() + 600, h = 0, l = 0 } },
        mj = {},
        gd = {},
        dr = {},
}
duniaStore.__failGet = 3

print("C: tambah pemain")
local P5 = Stub.addPlayer(1005, "petani5")
Stub.giveCharacter(P5, 24, 6, 44)
Players.PlayerAdded:Fire(P5)
print("D: PlayerAdded fired (load berjalan)")
Stub.Scheduler.advance(3)
print("E: load selesai")
local r = Stub.Services.ReplicatedStorage:FindFirstChild("Remotes")
local rem = r and r:FindFirstChild("DuniaAct")
print("F: remote DuniaAct =", rem ~= nil, "invoke=", rem and rem.OnServerInvoke ~= nil)
local ok, msg = rem.OnServerInvoke(P5, "masuk", nil)
print("G: masuk returns", ok, msg)
print("H: filledCount(1) =", (require and 0 or 0))
Stub.Scheduler.advance(0.5)
print("I: selesai probe")
