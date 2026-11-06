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
        if not root then
                return 0
        end
        for _, d in ipairs(root:GetDescendants()) do
                if d:IsA(class) then
                        n += 1
                end
        end
        return n
end

local function findTextBoxByPlaceholder(root, placeholder)
        if not root then
                return nil
        end
        for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("TextBox") and d.PlaceholderText == placeholder then
                        return d
                end
        end
        return nil
end

local function findSoalTeks(root)
        if not root then
                return nil
        end
        for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("TextLabel") and d.Text and string.match(d.Text, "^%d+ .+ %d+ = %?$") then
                        return d
                end
        end
        return nil
end

local function tampakPenuh(d)
        local cur = d
        while cur and cur.Parent do
                if cur.Visible == false then
                        return false
                end
                cur = cur.Parent
        end
        return true
end

local function pilihBenih(root, nama)
        for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("TextButton") and d.Text == "" and tampakPenuh(d) then
                        for _, c in ipairs(d:GetChildren()) do
                                if c:IsA("TextLabel") and c.Text and string.find(c.Text, nama, 1, true) then
                                        d.Activated:Fire()
                                        return true
                                end
                        end
                end
        end
        return false
end

local function pilihBaris(root, nama, keN)
        local n = 0
        for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("TextButton") and d.Text == "" and tampakPenuh(d) then
                        for _, c in ipairs(d:GetChildren()) do
                                if c:IsA("TextLabel") and c.Text and string.find(c.Text, nama, 1, true) then
                                        n += 1
                                        if n == keN then
                                                d.Activated:Fire()
                                                return true
                                        end
                                        break
                                end
                        end
                end
        end
        return false
end

local function tombolJumlah(root, teks)
        for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("TextButton") and d.Text == teks and tampakPenuh(d) then
                        d.Activated:Fire()
                        return true
                end
        end
        return false
end

local function jawabSoal(gui)
        local soalTeks = findSoalTeks(gui)
        if not soalTeks then
                return false, "soal hilang"
        end
        local teks = soalTeks.Text
        local a, op, b = string.match(teks, "^(%d+) (.+) (%d+) = %?$")
        if not a then
                return false, "soal tak terbaca: " .. teks
        end
        local x, y = tonumber(a), tonumber(b)
        local hasil
        if op == "+" then
                hasil = x + y
        elseif op == "-" then
                hasil = x - y
        elseif op == "*" or op == "x" or op == "×" then
                hasil = x * y
        elseif op == "/" or op == "÷" then
                hasil = x / y
        else
                return false, "operator tak dikenal: " .. tostring(op)
        end
        local box = findTextBoxByPlaceholder(gui, "Tulis jawaban angka")
        if not box then
                return false, "kotak jawaban hilang"
        end
        box.Text = tostring(hasil)
        local btn = findGui(gui, "TextButton", "Jawab")
        if not btn then
                return false, "tombol jawab hilang"
        end
        btn.Activated:Fire()
        return true, tostring(hasil)
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

local function menghadap(p, x, y, z, rotY)
        local r = rootOf(p)
        if r then
                r.CFrame = CFrame.new(x, y, z) * CFrame.Angles(0, rotY or 0, 0)
        end
end

local function kembaliTabTanam(gui)
        local tab = nil
        for _, d in ipairs(gui:GetDescendants()) do
                if d:IsA("TextButton") and d.Text == "Tanam" then
                        tab = d
                end
        end
        if tab then
                tab.Activated:Fire()
                Stub.Scheduler.advance(0.05)
        end
end

local function burn(t)
        local tgt = os.clock() + t
        while os.clock() < tgt do
        end
end

local function tasCount(player, kind, id)
        local st = serverCall("GetState", player)
        if not st then
                return -1
        end
        local n = 0
        for _, s in ipairs(st.tas) do
                if s.kind == kind and s.id == id then
                        n += s.count
                end
        end
        return n
end

local function dropsFolder(dunia)
        return dunia and dunia:FindFirstChild("Drops_1", true)
end

local function gridOf(dunia)
        return dunia and dunia:FindFirstChild("PlotGrid_1", true)
end

local function tanaman(grid, idx)
        return grid and grid:FindFirstChild("Tanaman_" .. idx, true)
end

local function buahWarna(model)
        for _, d in ipairs(model:GetDescendants()) do
                if d:IsA("BasePart") and d:GetAttribute("Buah") then
                        return d.Color
                end
        end
        return nil
end

local function warnaSama(c, r, g, b)
        if not c then
                return false
        end
        return math.abs(c.r - r / 255) < 0.03 and math.abs(c.g - g / 255) < 0.03 and math.abs(c.b - b / 255) < 0.03
end

print("=== UJIAN MASSA PANEN: tanam -> tunggu matang -> panen punch -> combine ===")
Stub.Scheduler.advance(0.05)

section("Booting server")
script = Stub.serverScript()
RUN_init_server()
Stub.Scheduler.advance(0.2)

local dunia = Workspace:FindFirstChild("Dunia")
check("Workspace.Dunia dibuat", dunia ~= nil)

section("Pemain masuk dengan perbekalan benih lengkap")
local profStore = Stub.Services.DataStoreService:GetDataStore("AKM_T1")
profStore.__data["u_1001"] = {
        m = 900000,
        t = {
                { kind = "benih", id = "wortel", count = 55 },
                { kind = "benih", id = "bayam", count = 10 },
                { kind = "benih", id = "pisang", count = 5 },
                { kind = "benih", id = "gandum", count = 3 },
                { kind = "benih", id = "rye", count = 3 },
                { kind = "benih", id = "brassica_rapa", count = 2 },
                { kind = "benih", id = "brassica_oleracea", count = 2 },
                { kind = "benih", id = "jeruk_mandarin", count = 2 },
                { kind = "benih", id = "grapefruit", count = 2 },
                { kind = "benih", id = "plum", count = 3 },
                { kind = "benih", id = "aprikot", count = 2 },
                { kind = "benih", id = "nektarin", count = 2 },
                { kind = "benih", id = "ceri", count = 2 },
                { kind = "benih", id = "labu_maxima", count = 2 },
                { kind = "benih", id = "labu_moschata", count = 2 },
                { kind = "benih", id = "arachis_duranensis", count = 2 },
                { kind = "benih", id = "arachis_ipaensis", count = 2 },
                { kind = "hasil", id = "wortel", count = 10 },
                { kind = "hasil", id = "pisang", count = 250 },
        },
        dev = false,
}
local P1 = Stub.addPlayer(1001, "akiomida")
Stub.giveCharacter(P1, 0, 6, 44)
Players.PlayerAdded:Fire(P1)
Stub.Scheduler.advance(0.5)

local ls = P1:FindFirstChild("leaderstats")
check("Micda 900.000 siap", ls and ls:FindFirstChild("Micda") and ls:FindFirstChild("Micda").Value == 900000, "-")

section("UI klien hidup + tombol PUNCH permanen")
local pg = Instance.new("Folder")
pg.Name = "PlayerGui"
pg.Parent = P1
__SIM_IS_SERVER = false
script = Stub.clientScript()
Stub.setLocalPlayer(P1)
RUN_init_client()
Stub.Scheduler.advance(0.2)

local gui = pg:FindFirstChild("DuniaAkiomida")
check("GUI utama dibuat", gui ~= nil)
local punchBtn = gui:FindFirstChild("TombolPunch")
check("Tombol punch permanen terlihat (ikon, tanpa tulisan)", punchBtn ~= nil and punchBtn:IsA("TextButton") and punchBtn.Text == "" and punchBtn.Visible == true, "-")

section("Masuk dunia lahan")
__SIM_IS_SERVER = true
Stub.setLocalPlayer(P1)
local gsRemote = getRemote("GetState")
local asliGs = gsRemote.OnServerInvoke
local gsCount = 0
gsRemote.OnServerInvoke = function(p)
        gsCount += 1
        return asliGs(p)
end
moveTo(P1, 0, 5, 20)
firePrompt(dunia, { action = "Dunia-ku" }, P1)
Stub.Scheduler.advance(0.1)
local dimM = gui:FindFirstChild("DimLayar")
local masukBtn = dimM and findGui(dimM, "TextButton", "Masuk Dunia-ku") or nil
if masukBtn then
        masukBtn.Activated:Fire()
        Stub.Scheduler.advance(0.5)
end
check("Pop up gerbang tertutup setelah masuk", dimM ~= nil and dimM.Visible == false, "-")
local r1 = rootOf(P1)
check("Pemain di dunia lahan (X > 5000)", r1 and r1.Position.X > 5000, "-")
local st0 = serverCall("GetState", P1)
check("Zona dunia milik sendiri", st0 and st0.zone == "dunia" and st0.role == "pemilik", "-")

section("TANAM MASSA: 50 wortel lewat Papan Tanam (5 soal)")
moveTo(P1, 5085, 5, 18)
firePrompt(dunia, { object = "Papan Tanam" }, P1)
Stub.Scheduler.advance(0.1)
check("Panel Papan Tanam terbuka", findGui(gui, "TextLabel", "Papan Tanam") ~= nil, "-")
check("Pilih benih Wortel", pilihBenih(gui, "Wortel"), "-")
check("Tombol jumlah 50 ada", tombolJumlah(gui, "50"), "-")
local mulaiBtn = findGui(gui, "TextButton", "Mulai Tanam")
burn(1.2)
if mulaiBtn then
        mulaiBtn.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
check("Soal 1 dari 5 tampil", findGui(gui, "TextLabel", "Soal 1 dari 5") ~= nil, "-")
check("Papan fisik TERTANAM 0/500", findGui(dunia, "TextLabel", "TERTANAM 0/500") ~= nil, "-")

for i = 1, 5 do
        burn(1.2)
        local okJ, detJ = jawabSoal(gui)
        Stub.Scheduler.advance(0.1)
        if i < 5 then
                check("Soal " .. i .. " benar -> 10 plot terisi", okJ and findGui(dunia, "TextLabel", "TERTANAM " .. (i * 10) .. "/500") ~= nil, tostring(detJ))
        else
                check("Soal 5 benar -> 50 plot terisi penuh", okJ and findGui(dunia, "TextLabel", "TERTANAM 50/500") ~= nil, tostring(detJ))
        end
end
check("Benih wortel sisa 5", tasCount(P1, "benih", "wortel") == 5, tostring(tasCount(P1, "benih", "wortel")))
local grid = gridOf(dunia)
local hitungTanaman = 0
if grid then
        for _, m in ipairs(grid:GetChildren()) do
                if m:IsA("Model") then
                        hitungTanaman += 1
                end
        end
end
check("50 model tanaman berdiri di plot", hitungTanaman == 50, tostring(hitungTanaman))

section("Sebelum matang: status Masih Tumbuh + warna tumbuh")
burn(1.2)
local tabStatusBtn = nil
for _, d in ipairs(gui:GetDescendants()) do
        if d:IsA("TextButton") and d.Text == "Status" then
                tabStatusBtn = d
        end
end
if tabStatusBtn then
        tabStatusBtn.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
check("Status tab: ringkasan Tertanam 50/500", findGui(gui, "TextLabel", "Tertanam 50/500") ~= nil, "-")
check("Status: Wortel masih tumbuh 50", findGui(gui, "TextLabel", "Tumbuh 50") ~= nil, "-")
check("Status: tidak ada yang siap panen", findGui(gui, "TextLabel", "Siap 0") ~= nil, "-")
local t0 = tanaman(grid, 0)
check("Tanaman_0 ada", t0 ~= nil, "-")
check("Model belum bertanda Siap", t0 and t0:GetAttribute("Siap") == nil, "-")
check("Warna buah = warna tumbuh (224,178,120)", warnaSama(buahWarna(t0), 224, 178, 120), buahWarna(t0) and tostring(buahWarna(t0)) or "-")

section("TUNGGU MASSA PANEN: waktu jalan sampai semua matang")
Stub.Scheduler.advance(4.5)
check("Model bertanda Siap setelah 3+ detik", t0 and t0:GetAttribute("Siap") == true, "-")
check("Warna buah berubah ke warna siap (232,112,44)", warnaSama(buahWarna(t0), 232, 112, 44), buahWarna(t0) and tostring(buahWarna(t0)) or "-")
burn(1.2)
if tabStatusBtn then
        tabStatusBtn.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
check("Status: Wortel siap panen 50", findGui(gui, "TextLabel", "Siap 50") ~= nil, "-")
check("Status: masih tumbuh 0", findGui(gui, "TextLabel", "Tumbuh 0") ~= nil, "-")

section("PANEN MASSA dengan PUNCH: tombol layar asli untuk pukulan pertama")
menghadap(P1, 5013, 5, 27, math.pi)
Stub.Scheduler.advance(0.25)
local probeFolder = Workspace:FindFirstChild("Dunia"):FindFirstChild("PlotGrid_1", true)
local probeHit = nil
for _, m in ipairs(probeFolder:GetChildren()) do
        if m:IsA("Model") and string.sub(m.Name, 1, 8) == "Tanaman_" then
                probeHit = m.Name .. " jarak " .. string.format("%.1f", (m:GetPivot().Position - rootOf(P1).Position).Magnitude)
                break
        end
end
check("Penarget PUNCH menemukan tanaman terdekat", probeHit ~= nil and string.find(probeHit, "Tanaman_0", 1, true) ~= nil, tostring(probeHit))
local plotRemote = getRemote("PlotAct")
local asliInvoke = plotRemote.OnServerInvoke
local dipanggil = nil
plotRemote.OnServerInvoke = function(p, idx, act)
        dipanggil = tostring(idx) .. "/" .. tostring(act)
        return asliInvoke(p, idx, act)
end
local dropSebelum1 = dropsFolder(dunia) and #dropsFolder(dunia):GetChildren() or 0
punchBtn.InputBegan:Fire({ UserInputType = Enum.UserInputType.MouseButton1, UserInputState = Enum.UserInputState.Begin })
punchBtn.InputEnded:Fire({ UserInputType = Enum.UserInputType.MouseButton1, UserInputState = Enum.UserInputState.End })
check("Efek kick kamera saat punch", Workspace.CurrentCamera.FieldOfView == 75, tostring(Workspace.CurrentCamera.FieldOfView))
Stub.Scheduler.advance(0.15)
check("Tombol punch memanggil server dengan plot 0", dipanggil == "0/punch", tostring(dipanggil))
Stub.Scheduler.advance(0.1)
plotRemote.OnServerInvoke = asliInvoke
local drops = dropsFolder(dunia)
check("Tombol PUNCH menghasilkan drop", drops ~= nil and #drops:GetChildren() == dropSebelum1 + 1, tostring(drops and #drops:GetChildren()))
local d1 = drops and drops:GetChildren()[1]
local d1root = d1 and d1:FindFirstChild("Hasil")
check("Pukulan pertama: tanaman_0 lenyap", tanaman(grid, 0) == nil, "-")
check("Drop model hasil wortel dengan atribut server", d1root ~= nil and d1.Name == "Hasil_wortel" and type(d1root:GetAttribute("DropId")) == "string", "-")
check("Drop tanpa teks melayang", d1 and countClass(d1, "BillboardGui") == 0, "-")
check("Drop punya efek partikel & suara", d1 and countClass(d1, "ParticleEmitter") >= 1 and countClass(d1, "Sound") >= 1, "-")

section("Panen 49 plot sisanya: kombo menaikkan tier efek")
local okN = 0
local msgPertama = nil
Stub.Scheduler.advance(0.4)
for i = 2, 50 do
        local row = math.floor((i - 1) / 25)
        local col = (i - 1) % 25
        burn(0.17)
        menghadap(P1, 5013 + 6 * col, 5, 27 + 6 * row, math.pi)
        local okP, msgP = serverCall("PlotAct", P1, i - 1, "punch")
        if okP then
                okN += 1
        elseif not msgPertama then
                msgPertama = "plot " .. tostring(i - 1) .. ": " .. tostring(msgP)
        end
        Stub.Scheduler.advance(0.4)
end
check("49 pukulan lanjutan sukses semua", okN == 49, tostring(msgPertama) .. " | ERR: " .. table.concat(__SIM_ERRORS, " || "))
check("Semua tanaman wortel habis (grid tinggal 0 model)", grid and (function()
        local n = 0
        for _, m in ipairs(grid:GetChildren()) do
                if m:IsA("Model") then
                        n += 1
                end
        end
        return n
end)() == 0, tostring(grid and (function()
        local n = 0
        for _, m in ipairs(grid:GetChildren()) do
                if m:IsA("Model") then
                        n += 1
                end
        end
        return n
end)() or -1))
check("Papan kembali ke TERTANAM 0/500 setelah panen raya", findGui(dunia, "TextLabel", "TERTANAM 0/500") ~= nil, "-")
local totalDrop = drops and #drops:GetChildren() or 0
check("50 drop melayang menunggu disentuh", totalDrop == 50, tostring(totalDrop))
local d2, d5, d9
local function rootDrops(dp)
        return dp and dp:FindFirstChild("Hasil")
end
for k, dp in ipairs(drops and drops:GetChildren() or {}) do
        if k == 2 then
                d2 = dp
        end
        if k == 5 then
                d5 = dp
        end
        if k == 9 then
                d9 = dp
        end
end
check("Ukuran drop tier 1 konsisten (pukulan 1 & 2)", d1root and rootDrops(d2) and math.abs(d1root.Size.X - rootDrops(d2).Size.X) < 0.01, d1root and tostring(d1root.Size.X) or "-")
check("Ukuran drop tier 2 di pukulan ke-5 (rasio x1.28/x1.14)", d5 and rootDrops(d2) and math.abs(rootDrops(d5).Size.X - rootDrops(d2).Size.X * 1.28 / 1.14) < 0.02, d5 and tostring(rootDrops(d5).Size.X) or "-")
check("Ukuran drop tier 3 di pukulan ke-9 (rasio x1.42/x1.14)", d9 and rootDrops(d2) and math.abs(rootDrops(d9).Size.X - rootDrops(d2).Size.X * 1.42 / 1.14) < 0.02, d9 and tostring(rootDrops(d9).Size.X) or "-")
local wortelSebelumSentuh = tasCount(P1, "hasil", "wortel")
for _, dp in ipairs(drops and drops:GetChildren() or {}) do
        local rp = rootDrops(dp)
        if rp then
                local posisi = rp.Position
                menghadap(P1, posisi.X, 5, posisi.Z - 6, math.pi)
                Stub.Scheduler.advance(0.05)
                rp.Touched:Fire(rootOf(P1))
                Stub.Scheduler.advance(0.05)
        end
end
Stub.Scheduler.advance(1)
check("Semua drop habis setelah disentuh", drops and #drops:GetChildren() == 0, tostring(drops and #drops:GetChildren()))
local wortelSesudahSentuh = tasCount(P1, "hasil", "wortel")
check("Total buah 50 tanaman masuk tas dalam rentang wajar (>=50, <=500)", wortelSesudahSentuh - wortelSebelumSentuh >= 50 and wortelSesudahSentuh - wortelSebelumSentuh <= 500, tostring(wortelSesudahSentuh - wortelSebelumSentuh))

section("Efektivitas punch: jarak & plot kosong ditolak")
moveTo(P1, 0, 5, 44)
burn(0.2)
local okJauh, msgJauh = serverCall("PlotAct", P1, 1, "punch")
check("Punch dari kota ditolak (terlalu jauh)", okJauh == false, tostring(msgJauh))
Stub.Scheduler.advance(0.4)
menghadap(P1, 5013, 5, 38, 0)
Stub.Scheduler.advance(0.15)
local okKosong, msgKosong = serverCall("PlotAct", P1, 300, "punch")
check("Punch tanpa tanaman di depan ditolak", okKosong == false and tostring(msgKosong) == "Tidak ada tanaman di depanmu.", tostring(msgKosong))

section("Punch tanaman masih tumbuh: beruntun dalam jendela, 5x hancur, tanpa drop")
moveTo(P1, 5085, 5, 18)
kembaliTabTanam(gui)
check("Pilih benih Bayam", pilihBenih(gui, "Bayam"), "-")
tombolJumlah(gui, "10")
mulaiBtn = findGui(gui, "TextButton", "Mulai Tanam")
burn(2.5)
if mulaiBtn then
        mulaiBtn.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
burn(2.5)
local okB, detB = jawabSoal(gui)
Stub.Scheduler.advance(0.1)
check("Bayam tertanam -> TERTANAM 10/500", okB and findGui(dunia, "TextLabel", "TERTANAM 10/500") ~= nil, tostring(detB))
local bayam = tanaman(grid, 0)
check("Tanaman_0 bayam berdiri (plot pertama kosong)", bayam ~= nil, "-")
menghadap(P1, 5013, 5, 27, math.pi)
Stub.Scheduler.advance(0.25)
local pesanPukul
for _ = 1, 3 do
        burn(0.17)
        _, pesanPukul = serverCall("PlotAct", P1, 0, "punch")
        Stub.Scheduler.advance(0.36)
end
check("3x pukul: tanaman masih hidup (3/5)", tanaman(grid, 0) ~= nil and pesanPukul == "Pukulan 3/5", tostring(pesanPukul))
Stub.Scheduler.advance(1.0)
burn(0.17)
_, pesanPukul = serverCall("PlotAct", P1, 0, "punch")
Stub.Scheduler.advance(0.36)
check("Beruntun bertahan dalam jendela (4/5), masih tumbuh", pesanPukul == "Pukulan 4/5" and tanaman(grid, 0) ~= nil, tostring(pesanPukul))
burn(0.17)
_, pesanPukul = serverCall("PlotAct", P1, 0, "punch")
Stub.Scheduler.advance(0.05)
check("5x beruntun -> tanaman hancur", tanaman(grid, 0) == nil, tostring(pesanPukul))
check("Tanpa drop dari tanaman tumbuh", drops and #drops:GetChildren() == 0, tostring(drops and #drops:GetChildren()))
burn(1.2)
if tabStatusBtn then
        tabStatusBtn.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
check("Status: Bayam masih tumbuh 9", findGui(gui, "TextLabel", "Tumbuh 9") ~= nil, "-")
check("Status: siap panen 0", findGui(gui, "TextLabel", "Siap 0") ~= nil, "-")

section("COMBINE SEED lewat papan GUI: cocok jadi Triticale")
moveTo(P1, 5085, 5, 18)
burn(1.2)
local tabGabungBtn = nil
for _, d in ipairs(gui:GetDescendants()) do
        if d:IsA("TextButton") and d.Text == "Combine Seed" then
                tabGabungBtn = d
        end
end
check("Tab Combine Seed ada", tabGabungBtn ~= nil, "-")
if tabGabungBtn then
        tabGabungBtn.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
local gabungTab = nil
if tabGabungBtn then
        for _, d in ipairs(gui:GetDescendants()) do
                if d:IsA("TextButton") and d.Text == "Gabung" then
                        gabungTab = d.Parent
                end
        end
end
check("Tab isi combine terbuka", gabungTab ~= nil, "-")
check("Slot A bisa pilih Gandum", gabungTab and pilihBaris(gabungTab, "Gandum", 1), "-")
check("Slot B bisa pilih Rye", gabungTab and pilihBaris(gabungTab, "Rye", 2), "-")
local gabungBtn = findGui(gui, "TextButton", "Gabung")
check("Tombol Gabung ada", gabungBtn ~= nil, "-")
local gandumAwal = tasCount(P1, "benih", "gandum")
local ryeAwal = tasCount(P1, "benih", "rye")
if gabungBtn then
        gabungBtn.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
local feedback = findGui(gui, "TextLabel", "Combine berhasil")
check("Papan menampilkan keberhasilan combine", feedback ~= nil, "-")
check("Benih Triticale masuk tas", tasCount(P1, "benih", "triticale") == 1, tostring(tasCount(P1, "benih", "triticale")))
check("Bahan terpakai 1+1", tasCount(P1, "benih", "gandum") == gandumAwal - 1 and tasCount(P1, "benih", "rye") == ryeAwal - 1, "-")

section("COMBINE ditolak: tanpa resep & benih utuh")
if gabungBtn then
        pilihBaris(gabungTab, "Pisang", 1)
        pilihBaris(gabungTab, "Wortel", 2)
        gabungBtn.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
local tolakLabel = findGui(gui, "TextLabel", "Tidak bisa di-combine")
check("Papan menolak dengan TIDAK BISA DI-COMBINE", tolakLabel ~= nil, "-")
check("Benih pisang utuh", tasCount(P1, "benih", "pisang") == 5, tostring(tasCount(P1, "benih", "pisang")))
check("Benih wortel utuh", tasCount(P1, "benih", "wortel") == 5, tostring(tasCount(P1, "benih", "wortel")))
if gabungBtn then
        pilihBaris(gabungTab, "Pisang", 1)
        pilihBaris(gabungTab, "Pisang", 2)
        gabungBtn.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
check("Benih sama pun ditolak", findGui(gui, "TextLabel", "Tidak bisa di-combine") ~= nil, "-")
check("Pisang tetap utuh setelah ditolak dua kali", tasCount(P1, "benih", "pisang") == 5, tostring(tasCount(P1, "benih", "pisang")))

section("8 resep rahasia server: semua jadi, urutan bebas")
local resep = {
        { "gandum", "rye", "triticale", "Triticale" },
        { "brassica_rapa", "brassica_oleracea", "canola", "Canola" },
        { "jeruk_mandarin", "grapefruit", "tangelo", "Tangelo" },
        { "plum", "aprikot", "plumcot", "Plumcot" },
        { "nektarin", "plum", "nectaplum", "Nectaplum" },
        { "ceri", "plum", "pluerry", "Pluerry" },
        { "labu_maxima", "labu_moschata", "tetsukabuto", "Tetsukabuto" },
        { "arachis_duranensis", "arachis_ipaensis", "kacang_tanah", "Kacang Tanah" },
}
local gagalResep = 0
for _, r in ipairs(resep) do
        burn(1.2)
        local okR, msgR = serverCall("TanamAct", P1, "gabung", r[1], r[2])
        if not (okR and string.find(tostring(msgR), r[4], 1, true) ~= nil) then
                gagalResep += 1
                print("    resep gagal: " .. r[1] .. " x " .. r[2] .. " -> " .. tostring(msgR))
        end
end
check("8 resep cocok semuanya", gagalResep == 0, tostring(gagalResep))
check("8 benih hibrida masuk tas", tasCount(P1, "benih", "triticale") == 2 and tasCount(P1, "benih", "canola") == 1 and tasCount(P1, "benih", "tangelo") == 1 and tasCount(P1, "benih", "plumcot") == 1 and tasCount(P1, "benih", "nectaplum") == 1 and tasCount(P1, "benih", "pluerry") == 1 and tasCount(P1, "benih", "tetsukabuto") == 1 and tasCount(P1, "benih", "kacang_tanah") == 1, "-")
burn(1.2)
local okSwap1, msgSwap1 = serverCall("TanamAct", P1, "gabung", "rye", "gandum")
check("Urutan dibalik (Rye x Gandum) tetap jadi", okSwap1 and string.find(tostring(msgSwap1), "Triticale", 1, true) ~= nil, tostring(msgSwap1))
burn(1.2)
local okSwap2, msgSwap2 = serverCall("TanamAct", P1, "gabung", "arachis_ipaensis", "arachis_duranensis")
check("Urutan dibalik (Ipaensis x Duranensis) tetap jadi", okSwap2 and string.find(tostring(msgSwap2), "Kacang Tanah", 1, true) ~= nil, tostring(msgSwap2))

section("Benih hibrida bisa ditanam: Tangelo bentuk pohon sendiri")
moveTo(P1, 5085, 5, 18)
burn(1.2)
kembaliTabTanam(gui)
check("Pilih benih Tangelo", pilihBenih(gui, "Tangelo"), "-")
tombolJumlah(gui, "1")
mulaiBtn = findGui(gui, "TextButton", "Mulai Tanam")
burn(2.5)
if mulaiBtn then
        mulaiBtn.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
burn(2.5)
local okT, detT = jawabSoal(gui)
Stub.Scheduler.advance(0.1)
local tangelo = tanaman(grid, 0)
check("Tangelo tertanam di plot 0 (1 plot + 1 soal)", okT and tangelo ~= nil, tostring(detT))
check("Bentuk Tangelo beda dari Wortel (pohon vs akar)", tangelo and (function()
        local n = 0
        for _, p2 in ipairs(tangelo:GetDescendants()) do
                if p2:IsA("BasePart") then
                        n += 1
                end
        end
        return n
end)() >= 6, "-")
Stub.Scheduler.advance(4.5)
check("Tangelo matang: warna siap (244,120,52)", warnaSama(buahWarna(tangelo), 244, 120, 52), buahWarna(tangelo) and tostring(buahWarna(tangelo)) or "-")
burn(0.3)
Stub.Scheduler.advance(0.4)
menghadap(P1, 5013, 5, 27, math.pi)
Stub.Scheduler.advance(0.15)
local okPT, msgPT = serverCall("PlotAct", P1, 0, "punch")
Stub.Scheduler.advance(0.05)
check("Punch Tangelo siap memberi drop", okPT and drops and #drops:GetChildren() == 1, tostring(msgPT))
local dt = drops and drops:GetChildren()[1]
check("Drop Tangelo model + atribut server benar", dt and dt.Name == "Hasil_tangelo" and dt:FindFirstChild("Hasil") ~= nil, "-")
if dt then
        dt:FindFirstChild("Hasil").Touched:Fire(rootOf(P1))
        Stub.Scheduler.advance(1)
end
check("Hasil Tangelo masuk tas lewat sentuhan", tasCount(P1, "hasil", "tangelo") >= 1, tostring(tasCount(P1, "hasil", "tangelo")))

section("MESIN SEMAI: atur jumlah -> tuas kanan -> tuas kiri -> klaim")
moveTo(P1, 5185, 5, 50)
Stub.Scheduler.advance(0.1)
firePrompt(dunia, { action = "Semai Panen", object = "Mesin Semai" }, P1)
Stub.Scheduler.advance(0.2)
check("Panel Mesin Semai Panen terbuka", findGui(gui, "TextLabel", "Mesin Semai Panen") ~= nil, "-")
local stSemai0 = serverCall("GetState", P1)
local hasilWortel0 = 0
local adaBlokPanen = false
for _, slot in ipairs(stSemai0.tas) do
	if slot.kind == "hasil" and slot.id == "wortel" then
		hasilWortel0 += slot.count
	end
	if slot.id == "blok_panen" then
		adaBlokPanen = true
	end
end
check("Item bug blok_panen tidak ada di tas", not adaBlokPanen, "-")
check("Ada hasil wortel untuk mesin", hasilWortel0 >= 10, tostring(hasilWortel0))
check("Baris hasil wortel bisa dipilih", pilihBenih(gui, "Wortel"), "-")
check("Preset jumlah 10 diklik", tombolJumlah(gui, "10"), "-")
local isiBtn = findGui(gui, "TextButton", "Isi Mesin Semai")
check("Tombol Isi Mesin Semai ada", isiBtn ~= nil, "-")
if isiBtn then
	isiBtn.Activated:Fire()
	Stub.Scheduler.advance(0.3)
end
check("Papan mesin minta dua tuas", findGui(dunia, "TextLabel", "TEKAN TUAS KANAN LALU KIRI") ~= nil, "-")
check("Panel menampilkan langkah Tuas KANAN", findGui(gui, "TextLabel", "Tuas KANAN — Pinggir kanan mesin") ~= nil, "-")
check("Panel menampilkan langkah Tuas KIRI", findGui(gui, "TextLabel", "Tuas KIRI — Pinggir kiri mesin") ~= nil, "-")
local tolak1, tolakMsg1 = serverCall("SemaiAct", P1, "tuas")
check("Tekan tuas tanpa sisi DITOLAK server", tolak1 == false and type(tolakMsg1) == "string", tostring(tolakMsg1))
local tolak2, tolakMsg2 = serverCall("SemaiAct", P1, "tuas", "kiri")
check("Tuas KIRI sebelum KANAN DITOLAK server", tolak2 == false and string.find(tostring(tolakMsg2), "KANAN", 1, true) ~= nil, tostring(tolakMsg2))
local promptKanan, promptKiri
for _, p in ipairs(findPrompts(dunia)) do
	if p.ActionText == "Tekan Tuas" and p.ObjectText == "Tuas Kanan" then
		promptKanan = p
	end
	if p.ActionText == "Tekan Tuas" and p.ObjectText == "Tuas Kiri" then
		promptKiri = p
	end
end
check("Dua prompt Tekan Tuas ada di mesin", promptKanan ~= nil and promptKiri ~= nil, "-")
local tolak1, tolakMsg1 = serverCall("SemaiAct", P1, "tuas")
check("Tekan tuas tanpa sisi DITOLAK server", tolak1 == false and type(tolakMsg1) == "string", tostring(tolakMsg1))
local tolak2, tolakMsg2 = serverCall("SemaiAct", P1, "tuas", "kiri")
check("Tuas KIRI sebelum KANAN DITOLAK server", tolak2 == false and string.find(tostring(tolakMsg2), "KANAN", 1, true) ~= nil, tostring(tolakMsg2))
local promptKanan, promptKiri
for _, p in ipairs(findPrompts(dunia)) do
	if p.ActionText == "Tekan Tuas" and p.ObjectText == "Tuas Kanan" then
		promptKanan = p
	end
	if p.ActionText == "Tekan Tuas" and p.ObjectText == "Tuas Kiri" then
		promptKiri = p
	end
end
check("Dua prompt Tekan Tuas ada di mesin", promptKanan ~= nil and promptKiri ~= nil, "-")
local jmlMesin, jmlPromptTuas = 0, 0
for _, d in ipairs(dunia:GetDescendants()) do
	if d:IsA("Model") and d.Name == "MesinSemaiPanen" then
		jmlMesin += 1
	end
	if d:IsA("ProximityPrompt") and d.ActionText == "Tekan Tuas" then
		jmlPromptTuas += 1
	end
end
print("  DEBUG mesin=" .. tostring(jmlMesin) .. " promptTuas=" .. tostring(jmlPromptTuas) .. " kananEnabled=" .. tostring(promptKanan and promptKanan.Enabled) .. " kiriEnabled=" .. tostring(promptKiri and promptKiri.Enabled) .. " kananObj=" .. tostring(promptKanan and promptKanan.ObjectText))
local mesinModel
for _, d in ipairs(dunia:GetDescendants()) do
	if d:IsA("Model") and d.Name == "MesinSemaiPanen" then
		mesinModel = d
		break
	end
end
local armK = mesinModel and mesinModel:FindFirstChild("TuasKananArm", true)
local pedK = mesinModel and mesinModel:FindFirstChild("TuasKananPedestal", true)
print("  DEBUG2 arm=" .. tostring(armK ~= nil) .. " cfNaik=" .. tostring(armK and armK:GetAttribute("CFNaik") ~= nil) .. " ped=" .. tostring(pedK ~= nil) .. " promptAnak=" .. tostring(pedK and pedK:FindFirstChild("PromptTuasKanan") ~= nil) .. " promptAttr=" .. tostring(promptKanan and promptKanan:GetAttribute("x") ~= nil))
if armK then
	local n = 0
	for _, c in ipairs(pedK:GetChildren()) do n += 1 end
	print("  DEBUG3 pedAnak=" .. tostring(n))
end
check("Prompt tuas KANAN aktif duluan", promptKanan ~= nil and promptKanan.Enabled == true and promptKiri ~= nil and promptKiri.Enabled == false, "-")
if promptKanan then
	promptKanan.Triggered:Fire(P1)
	Stub.Scheduler.advance(0.3)
end
check("Tuas KANAN ditekan dari dunia -> prompt pindah ke KIRI", promptKanan ~= nil and promptKanan.Enabled == false and promptKiri ~= nil and promptKiri.Enabled == true, "-")
local tolak3, tolakMsg3 = serverCall("SemaiAct", P1, "tuas", "kanan")
check("Tuas KANAN ditekan dua kali DITOLAK server", tolak3 == false, tostring(tolakMsg3))
if promptKiri then
	promptKiri.Triggered:Fire(P1)
	Stub.Scheduler.advance(0.3)
end
check("Kedua tuas selesai -> mesin langsung MENGGILING", findGui(dunia, "TextLabel", "MENGGILING...") ~= nil, "-")
Stub.Scheduler.advance(3.5)
local stSemai1 = serverCall("GetState", P1)
check("Batch mesin tercatat di papan", findGui(dunia, "TextLabel", "SEMAI TUNTAS - KLAIM HASIL") ~= nil, "-")
local klaimBtn = findGui(gui, "TextButton", "Klaim Semua")
check("Tombol Klaim Semua tampil setelah tuntas", klaimBtn ~= nil and tampakPenuh(klaimBtn), "-")
local function micdaOf(pl)
	local ls = pl:FindFirstChild("leaderstats")
	local mv = ls and ls:FindFirstChild("Micda")
	return mv and mv.Value or 0
end
local micda0 = micdaOf(P1)
if klaimBtn then
	klaimBtn.Activated:Fire()
	Stub.Scheduler.advance(0.3)
end
check("Struk klaim tampil", findGui(gui, "TextLabel", "Hasil Diklaim") ~= nil, "-")
local micda1 = micdaOf(P1)
check("Micda bertambah setelah klaim", micda1 > micda0, tostring(micda0) .. "->" .. tostring(micda1))
local stSemai2 = serverCall("GetState", P1)
local hasilWortel1 = 0
local blokWortel = 0
adaBlokPanen = false
for _, slot in ipairs(stSemai2.tas) do
	if slot.kind == "hasil" and slot.id == "wortel" then
		hasilWortel1 += slot.count
	end
	if slot.kind == "blok" and slot.id == "blok_wortel" then
		blokWortel += slot.count
	end
	if slot.id == "blok_panen" then
		adaBlokPanen = true
	end
end
check("10 wortel hasil dipakai mesin", hasilWortel1 == hasilWortel0 - 10, tostring(hasilWortel0) .. "->" .. tostring(hasilWortel1))
check("Hasil blok sesuai tanaman (blok_wortel)", blokWortel >= 0 and not adaBlokPanen, tostring(blokWortel))
check("Papan mesin kembali NONAKTIF setelah klaim", findGui(dunia, "TextLabel", "NONAKTIF") ~= nil, "-")
local okeStruk = findGui(gui, "TextButton", "Oke")
if okeStruk and tampakPenuh(okeStruk) then
	okeStruk.Activated:Fire()
	Stub.Scheduler.advance(0.1)
end
local tutupPanel = findGui(gui, "TextButton", "X")
if tutupPanel and tampakPenuh(tutupPanel) then
	tutupPanel.Activated:Fire()
	Stub.Scheduler.advance(0.1)
end

section("Gudang: 250 -> 999 -> 998 tetap presisi")
burn(1.2)
moveTo(P1, 5205, 5, 181)
local okD1, msgD1 = serverCall("GudangAct", P1, "simpan", "pisang", 250)
check("Setor 250 pisang -> sisa 999", okD1 and string.find(tostring(msgD1), "999", 1, true) ~= nil, tostring(msgD1))
burn(1.2)
local okD2, msgD2 = serverCall("GudangAct", P1, "simpan", "wortel", 250)
check("Setor 250 wortel -> sisa 998", okD2 and string.find(tostring(msgD2), "998", 1, true) ~= nil, tostring(msgD2))

section("Tas penuh: drop melayang tidak bisa diambil sampai ada ruang")
local dta = MOD_DataService.get(P1)
local penuh = { { kind = "hasil", id = "wortel", count = 250 } }
for i = 1, 48 do
        table.insert(penuh, { kind = "benih", id = "rongsok" .. i, count = 1 })
end
table.insert(penuh, { kind = "benih", id = "wortel", count = 4 })
dta.t = penuh
MOD_DataService.push(P1)
check("Tas diset penuh 50 slot", #dta.t == 50, tostring(#dta.t))
moveTo(P1, 5085, 5, 18)
burn(1.2)
firePrompt(dunia, { object = "Papan Tanam" }, P1)
Stub.Scheduler.advance(0.1)
kembaliTabTanam(gui)
check("Pilih benih Wortel lagi", pilihBenih(gui, "Wortel"), "-")
tombolJumlah(gui, "1")
mulaiBtn = findGui(gui, "TextButton", "Mulai Tanam")
burn(2.5)
if mulaiBtn then
        mulaiBtn.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
burn(2.5)
local okW, detW = jawabSoal(gui)
Stub.Scheduler.advance(0.1)
check("Wortel terakhir tertanam", okW and tanaman(grid, 0) ~= nil, tostring(detW))
Stub.Scheduler.advance(4.5)
burn(0.3)
menghadap(P1, 5013, 5, 27, math.pi)
Stub.Scheduler.advance(0.15)
local okPW, msgPW = serverCall("PlotAct", P1, 0, "punch")
Stub.Scheduler.advance(0.1)
local dropPenuh = drops and drops:GetChildren()[1]
check("Punch tetap menjatuhkan drop saat tas penuh", okPW and dropPenuh ~= nil, tostring(msgPW))
local wortelTasKunci = tasCount(P1, "hasil", "wortel")
if dropPenuh then
        dropPenuh:FindFirstChild("Hasil").Touched:Fire(rootOf(P1))
        Stub.Scheduler.advance(0.3)
end
check("Drop tidak masuk tas saat penuh", tasCount(P1, "hasil", "wortel") == wortelTasKunci, tostring(tasCount(P1, "hasil", "wortel")))
check("Drop melayang (terkunci di udara)", dropPenuh ~= nil and dropPenuh:FindFirstChild("Hasil").Anchored == true, "-")
MOD_TasService.remove(P1, "benih", "rongsok1", 1)
burn(1.2)
if dropPenuh then
        dropPenuh:FindFirstChild("Hasil").Touched:Fire(rootOf(P1))
        Stub.Scheduler.advance(1)
end
check("Setelah ada ruang, sentuhan memasukkan drop", tasCount(P1, "hasil", "wortel") > wortelTasKunci, tostring(tasCount(P1, "hasil", "wortel")))
check("Drop lenyap setelah diambil", dropPenuh == nil or dropPenuh.Parent == nil, "-")

section("Dunia tetap bersih dari teks melayang")
check("Nol BillboardGui di seluruh dunia", countClass(dunia, "BillboardGui") == 0, tostring(countClass(dunia, "BillboardGui")))

section("Bersih dari error runtime")
check("Tidak ada error runtime tersembunyi", #__SIM_ERRORS == 0, table.concat(__SIM_ERRORS, " | "))

print(string.format("HASIL UJIAN MASSA PANEN: %d PASS, %d FAIL", passed, failed))
if failed > 0 then
        error(string.format("%d tahap ujian massa panen gagal", failed))
end
