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

local passed, failed = 0, 0
local function check(name, ok, detail)
        if ok then
                passed += 1
                print("  PASS  " .. name)
        else
                failed += 1
                print("  FAIL  " .. name .. (detail and ("  -> " .. detail) or ""))
        end
end

local function section(t)
        print("-- " .. t)
end

local function getRemote(name)
        local f = ReplicatedStorage:FindFirstChild("Remotes")
        return f and f:FindFirstChild(name)
end

local function serverCall(name, player, ...)
        local r = getRemote(name)
        if not r or not r.OnServerInvoke then
                return nil, "remote tidak siap"
        end
        return r.OnServerInvoke(player, ...)
end

local function findPrompts(root)
        local out = {}
        for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("ProximityPrompt") then
                        table.insert(out, d)
                end
        end
        return out
end

local function firePrompt(root, match, player)
        for _, p in ipairs(findPrompts(root)) do
                local okA = not match.action or p.ActionText == match.action
                local okO = not match.object or p.ObjectText == match.object
                if okA and okO then
                        p.Triggered:Fire(player)
                        return true
                end
        end
        return false
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

local function countClass(root, class)
        local n = 0
        for _, d in ipairs(root:GetDescendants()) do
                if d:IsA(class) then
                        n += 1
                end
        end
        return n
end

local function rootOf(p)
        local c = p.Character
        return c and c:FindFirstChild("HumanoidRootPart")
end

local function moveTo(p, x, y, z)
        local r = rootOf(p)
        if r then
                r.CFrame = CFrame.new(x, y, z)
        end
end

local function burn(t)
        local tgt = os.clock() + t
        while os.clock() < tgt do
        end
end

print("=== PLAYTEST DUNIA AKIOMIDA (simulasi server + klien) ===")
Stub.Scheduler.advance(0.05)

section("Booting server")
local serverScript = Stub.serverScript()
script = serverScript
rawreq("./../download/dunia-akiomida/src/Server/init.server")
Stub.Scheduler.advance(0.2)

local dunia = Workspace:FindFirstChild("Dunia")
check("Workspace.Dunia dibuat saat boot", dunia ~= nil)

local modelNames = {}
if dunia then
        for _, d in ipairs(dunia:GetDescendants()) do
                if d:IsA("Model") then
                        table.insert(modelNames, d.Name)
                end
        end
        table.sort(modelNames)
end
check("Pusat kota hanya punya satu bangunan: TokoBenih", #modelNames == 1 and modelNames[1] == "TokoBenih", table.concat(modelNames, ","))

local gabungFound = {}
if dunia then
        for _, d in ipairs(dunia:GetDescendants()) do
                local t = d.Name or ""
                if type(d.Text) == "string" then
                        t = t .. " " .. d.Text
                end
                if type(d.ActionText) == "string" then
                        t = t .. " " .. d.ActionText
                end
                if type(d.ObjectText) == "string" then
                        t = t .. " " .. d.ObjectText
                end
                if string.find(string.lower(t), "gabung") then
                        table.insert(gabungFound, t)
                end
        end
end
check("Tidak ada fitur/bangunan gabung benih di pusat kota", #gabungFound == 0, table.concat(gabungFound, " | "))

local toko = dunia and dunia:FindFirstChild("TokoBenih", true)
check("Model TokoBenih ada", toko ~= nil)
local partToko = toko and countClass(toko, "BasePart") or 0
check("Interior toko penuh pernak-pernik (>=90 bagian)", partToko >= 90, "jumlah bagian: " .. tostring(partToko))

local doors = {}
if toko then
        for _, d in ipairs(toko:GetDescendants()) do
                if d:IsA("BasePart") and d:GetAttribute("PintuDaun") == true then
                        table.insert(doors, d)
                end
        end
end
check("Toko punya pintu sungguhan 2 daun (bukan melompong)", #doors == 2, "daun pintu: " .. tostring(#doors))
if #doors == 2 then
        local d1 = doors[1]
        local prompt = d1:FindFirstChildWhichIsA("ProximityPrompt")
        check("Pintu punya prompt buka/tutup", prompt ~= nil)
        if prompt then
                local closed = d1.CFrame
                prompt.Triggered:Fire(nil)
                Stub.Scheduler.advance(0.6)
                local opened = d1.CFrame
                check("Pintu bisa dibuka (berputar)", (opened.Position - closed.Position).Magnitude > 0.5, tostring((opened.Position - closed.Position).Magnitude))
                prompt.Triggered:Fire(nil)
                Stub.Scheduler.advance(0.6)
                check("Pintu bisa ditutup lagi", (d1.CFrame.Position - closed.Position).Magnitude < 0.2, tostring((d1.CFrame.Position - closed.Position).Magnitude))
        end
end

section("Pemain utama masuk")
local profStore = Stub.Services.DataStoreService:GetDataStore("AKM_T1")
profStore.__data["u_1001"] = {
        m = 900000,
        t = {
                { kind = "benih", id = "wortel", count = 5 },
                { kind = "benih", id = "jeruk_mandarin", count = 2 },
                { kind = "benih", id = "grapefruit", count = 2 },
                { kind = "benih", id = "pisang", count = 2 },
        },
        dev = false,
}
local P1 = Stub.addPlayer(1001, "akiomida")
Stub.giveCharacter(P1, 0, 6, 44)
Players.PlayerAdded:Fire(P1)
Stub.Scheduler.advance(0.5)

local ls = P1:FindFirstChild("leaderstats")
check("leaderstats Micda dibuat", ls ~= nil and ls:FindFirstChild("Micda") ~= nil)
check("Micda awal 900.000", ls and ls:FindFirstChild("Micda") and ls:FindFirstChild("Micda").Value == 900000, ls and ls:FindFirstChild("Micda") and tostring(ls:FindFirstChild("Micda").Value))

section("Booting UI klien")
local pg = Instance.new("Folder")
pg.Name = "PlayerGui"
pg.Parent = P1
__SIM_IS_SERVER = false
script = Stub.clientScript()
Stub.setLocalPlayer(P1)
rawreq("./../download/dunia-akiomida/src/Client/init.client")
Stub.Scheduler.advance(0.2)

local gui = pg:FindFirstChild("DuniaAkiomida")
check("GUI utama dibuat (UI benar-benar dimuat)", gui ~= nil)
check("Label Micda terisi dari GetState", findGui(gui, "TextLabel", "Micda") ~= nil)
check("Label Micda menunjukkan 900.000", (findGui(gui, "TextLabel", "900.000 Micda") ~= nil), findGui(gui, "TextLabel", "Micda") and findGui(gui, "TextLabel", "Micda").Text or "tidak ada")

section("Toko Benih: buka panel dan beli benih")
moveTo(P1, 8, 4, -46)
local kasirFired = firePrompt(dunia, { object = "Kasir" }, P1)
check("Prompt kasir toko bisa dipicu", kasirFired)
Stub.Scheduler.advance(0.1)

local buyCommon = findGui(gui, "TextButton", "Pack Common")
check("Tombol beli Pack Common tampil", buyCommon ~= nil)
local buyRare = findGui(gui, "TextButton", "Pack Rare")
check("Tombol beli Pack Rare tampil", buyRare ~= nil)

local st0 = serverCall("GetState", P1)
local benihSebelum = 0
if st0 then
        for _, s in ipairs(st0.tas) do
                if s.kind == "benih" then
                        benihSebelum += s.count
                end
        end
end

if buyCommon then
        buyCommon.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
local micdaAfterBuy = ls and ls:FindFirstChild("Micda") and ls:FindFirstChild("Micda").Value
check("Beli Pack Common berhasil (900.000 - 2.400 = 897.600)", micdaAfterBuy == 897600, tostring(micdaAfterBuy))

local st = serverCall("GetState", P1)
local nBenih = 0
if st then
        for _, s in ipairs(st.tas) do
                if s.kind == "benih" then
                        nBenih += s.count
                end
        end
end
check("3 benih acak masuk tas", nBenih == benihSebelum + 3, tostring(nBenih) .. " vs " .. tostring(benihSebelum + 3))

if buyRare then
        buyRare.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
check("Beli Pack Rare berhasil (897.600 - 9.000 = 888.600)", ls:FindFirstChild("Micda").Value == 888600, tostring(ls:FindFirstChild("Micda").Value))

local okBuyFake, msgFake = serverCall("ShopAct", P1, "buy", "epic")
check("Pack tidak dikenal ditolak", okBuyFake == false, tostring(msgFake))

local toastLabel = findGui(gui, "TextLabel", "Pack rare")
check("Toast hasil pembelian tampil di UI", toastLabel ~= nil)

section("Gerbang Dunia: masuk ke lahan lewat UI")
moveTo(P1, 0, 5, 20)
local gerbangFired = firePrompt(dunia, { action = "Dunia-ku" }, P1)
check("Gerbang Dunia di kota bisa dipicu", gerbangFired)
Stub.Scheduler.advance(0.1)

local masukBtn = findGui(gui, "TextButton", "Masuk Dunia")
check("Tombol Masuk Dunia-ku tampil di panel", masukBtn ~= nil)
if masukBtn then
        masukBtn.Activated:Fire()
        Stub.Scheduler.advance(0.5)
end
local r1 = rootOf(P1)
check("Pemain terbangun instan di dunia lahan (X > 5000)", r1 and r1.Position.X > 5000, r1 and tostring(r1.Position) or "tanpa karakter")

st = serverCall("GetState", P1)
check("Zona aktif = dunia milik sendiri", st and st.zone == "dunia" and st.role == "pemilik", st and (st.zone .. "/" .. tostring(st.role)) or "tidak ada state")

section("Grid plot di dunia lahan")
local grid = dunia and dunia:FindFirstChild("PlotGrid_1", true)
check("PlotGrid_1 dibuat di dunia lahan", grid ~= nil)
local nPlot = grid and #grid:GetChildren() or 0
check("Jumlah plot 500", nPlot == 500, tostring(nPlot))
local nyasar = 0
if grid then
        for _, p in ipairs(grid:GetChildren()) do
                if p.Position.X < 5000 then
                        nyasar += 1
                end
        end
end
check("Semua plot berada di dalam dunia lahan, bukan nyasar ke kota", grid ~= nil and nyasar == 0, tostring(nyasar) .. " plot nyasar")

section("Tanam & gabung benih di plot lahan")
moveTo(P1, 5013, 5, 38)
local okP, msgP = serverCall("PlotAct", P1, 0, "plant", "wortel")
check("Tanam wortel di plot 1", okP == true, tostring(msgP))

moveTo(P1, 5019, 5, 38)
okP, msgP = serverCall("PlotAct", P1, 1, "plant", "jeruk_mandarin")
check("Tanam jeruk mandarin di plot 2", okP == true, tostring(msgP))

okP, msgP = serverCall("PlotAct", P1, 1, "plant", "grapefruit")
check("Gabung di plot yang sama: jeruk_mandarin + grapefruit = tangelo", okP == true and string.find(tostring(msgP), "Tangelo", 1, true) ~= nil, tostring(msgP))

okP, msgP = serverCall("PlotAct", P1, 0, "plant", "pisang")
check("Gabung tanpa resep ditolak (benih tidak terpakai)", okP == false, tostring(msgP))

Stub.Scheduler.advance(3.6)
local tanaman = grid and grid:FindFirstChild("Tanaman_1", true)
local kepala = tanaman and tanaman:FindFirstChild("Kepala")
check("Tanaman gabung membesar saat siap panen", kepala ~= nil and kepala.Size == Vector3.new(3, 2, 3), kepala and tostring(kepala.Size) or "tanaman hilang")

okP, msgP = serverCall("PlotAct", P1, 1, "harvest")
check("Panen hasil gabung tangelo", okP == true and string.find(tostring(msgP), "Tangelo", 1, true) ~= nil, tostring(msgP))

st = serverCall("GetState", P1)
local adaTangelo = false
if st then
        for _, s in ipairs(st.tas) do
                if s.kind == "hasil" and s.id == "tangelo" then
                        adaTangelo = true
                end
        end
end
check("Tangelo hasil gabung masuk tas", adaTangelo)

section("Pulang ke kota lalu balik lagi ke lahan")
local zona = dunia and dunia:FindFirstChild("Zona_1", true)
local pulangFired = zona and firePrompt(zona, { action = "Pulang ke Kota" }, P1)
check("Gerbang pulang di lahan bisa dipicu", pulangFired == true)
Stub.Scheduler.advance(0.5)
local r2 = rootOf(P1)
check("Sampai pusat kota lagi", r2 and math.abs(r2.Position.X) < 3 and math.abs(r2.Position.Z - 44) < 4, r2 and tostring(r2.Position) or "-")

local kotaFired = firePrompt(dunia, { action = "Dunia-ku" }, P1)
Stub.Scheduler.advance(0.1)
masukBtn = findGui(gui, "TextButton", "Masuk Dunia")
check("Panel gerbang terbuka lagi dengan tombol masuk", masukBtn ~= nil)
if masukBtn then
        masukBtn.Activated:Fire()
        Stub.Scheduler.advance(0.6)
end
local r3 = rootOf(P1)
check("BALIK ke dunia lahan sukses (bug user teratasi)", r3 and r3.Position.X > 5000, r3 and tostring(r3.Position) or "-")

section("Tamu berkunjung, tidak bisa mengubah")
local P2 = Stub.addPlayer(2002, "tamu")
Stub.giveCharacter(P2, 0, 6, 44)
Players.PlayerAdded:Fire(P2)
Stub.Scheduler.advance(0.3)
local okV, msgV = serverCall("DuniaAct", P2, "kunjungi", "akiomida")
check("Tamu bisa berkunjung ke dunia akiomida", okV == true, tostring(msgV))
local r4 = rootOf(P2)
check("Tamu tiba di dunia lahan", r4 and r4.Position.X > 5000, r4 and tostring(r4.Position) or "-")
Stub.Scheduler.advance(0.3)
moveTo(P2, 5013, 5, 38)
local okDeny = serverCall("PlotAct", P2, 0, "plant", "wortel")
check("Tamu dilarang menanam di lahan orang lain", okDeny == false, tostring(okDeny))

section("Jual hasil & pukul di meja semai")
burn(1.2)
moveTo(P1, 8, 4, -46)
local okSell, msgSell = serverCall("ShopAct", P1, "sell", "tangelo", 1)
check("Jual tangelo = +17 Micda", okSell == true and string.find(tostring(msgSell), "17", 1, true) ~= nil, tostring(msgSell))

burn(1.2)
moveTo(P1, 5013, 5, 38)
local okH, msgH = serverCall("PlotAct", P1, 0, "harvest")
check("Panen wortel", okH == true, tostring(msgH))

burn(1.2)
moveTo(P1, 5185, 5, 56)
local okPlace, msgPlace = serverCall("SmashAct", P1, "place", "wortel")
check("Letakkan hasil di meja semai", okPlace == true, tostring(msgPlace))
local micdaSebelum = ls:FindFirstChild("Micda").Value
local okHit, msgHit
for _ = 1, 5 do
        okHit, msgHit = serverCall("SmashAct", P1, "hit", 1)
        if not okHit then
                break
        end
        Stub.Scheduler.advance(0.05)
        burn(0.35)
end
check("Pukul hasil sampai hancur", okHit == true, tostring(msgHit))
local micdaSesudah = ls:FindFirstChild("Micda").Value
check("Pukul memberi Micda", micdaSesudah > micdaSebelum, tostring(micdaSebelum) .. " -> " .. tostring(micdaSesudah))

section("Simpan data saat keluar")
Players.PlayerRemoving:Fire(P1)
Stub.Scheduler.advance(0.3)
local duniaStore = Stub.stores["AKM_Dunia"]
check("Dunia pemain tersimpan (d_1001)", duniaStore and duniaStore.__data["d_1001"] ~= nil)
local t1 = Stub.stores["AKM_T1"]
check("Profil pemain tersimpan (u_1001)", t1 and t1.__data["u_1001"] ~= nil)

section("Bersih dari error runtime")
check("Tidak ada error runtime tersembunyi", #__SIM_ERRORS == 0, table.concat(__SIM_ERRORS, " | "))

print(string.format("HASIL PLAYTEST: %d PASS, %d FAIL", passed, failed))
if failed > 0 then
        error(string.format("%d tahap playtest gagal", failed))
end
