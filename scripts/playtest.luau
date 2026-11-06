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
                if d:IsA("TextLabel") and d.Text and string.match(d.Text, "^%d+ [%+%-%*x] %d+ = %?$") then
                        return d
                end
        end
        return nil
end

local function pilihBenih(root, nama)
        for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("TextButton") and d.Text == "" then
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

local function jawabSoal(gui)
        local soalTeks = findSoalTeks(gui)
        if not soalTeks then
                return false, "soal hilang"
        end
        local teks = soalTeks.Text
        local a, op, b = string.match(teks, "^(%d+) (.+) (%d+) = %?$")
        local hasil
        if op == "+" then
                hasil = tonumber(a) + tonumber(b)
        elseif op == "-" then
                hasil = tonumber(a) - tonumber(b)
        elseif op == "*" or op == "x" then
                hasil = tonumber(a) * tonumber(b)
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

print("=== PLAYTEST DUNIA AKIOMIDA (revisi final tanam-panen) ===")
Stub.Scheduler.advance(0.05)

section("Booting server")
script = Stub.serverScript()
RUN_init_server()
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

local teksTerlarang = {}
if dunia then
        for _, d in ipairs(dunia:GetDescendants()) do
                if d:IsA("TextLabel") and type(d.Text) == "string" then
                        local t = string.lower(d.Text)
                        if string.find(t, "panduan") or string.find(t, "dekati papan") or string.find(t, "tanam lewat") or string.find(t, "setor 1-250") or string.find(t, "pukul hasil") then
                                table.insert(teksTerlarang, d.Text)
                        end
                end
        end
end
check("Tidak ada teks instruksi tanam-panen di dunia", #teksTerlarang == 0, table.concat(teksTerlarang, " | "))
check("Tidak ada BillboardGui / teks melayang di dunia", countClass(dunia, "BillboardGui") == 0, tostring(countClass(dunia, "BillboardGui")))

section("Pemain utama masuk")
local profStore = Stub.Services.DataStoreService:GetDataStore("AKM_T1")
profStore.__data["u_1001"] = {
        m = 900000,
        t = {
                { kind = "benih", id = "wortel", count = 25 },
                { kind = "benih", id = "pisang", count = 2 },
                { kind = "benih", id = "jeruk_mandarin", count = 2 },
                { kind = "benih", id = "grapefruit", count = 2 },
                { kind = "benih", id = "bayam", count = 10 },
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
check("leaderstats Micda dibuat", ls ~= nil and ls:FindFirstChild("Micda") ~= nil)
check("Micda awal 900.000", ls and ls:FindFirstChild("Micda") and ls:FindFirstChild("Micda").Value == 900000, tostring(ls and ls:FindFirstChild("Micda").Value))

section("Booting UI klien")
local pg = Instance.new("Folder")
pg.Name = "PlayerGui"
pg.Parent = P1
__SIM_IS_SERVER = false
script = Stub.clientScript()
Stub.setLocalPlayer(P1)
RUN_init_client()
Stub.Scheduler.advance(0.2)

local gui = pg:FindFirstChild("DuniaAkiomida")
check("GUI utama dibuat (UI benar-benar dimuat)", gui ~= nil)

local punchUI = findGui(gui, "TextButton", "PUNCH")
check("Tombol PUNCH permanen ada di layar", punchUI ~= nil and punchUI.Visible == true, punchUI and tostring(punchUI.Visible) or "hilang")

local popupPlot = findGui(gui, "TextLabel", "Plot Tanam")
check("Tidak ada popup Plot Tanam", popupPlot == nil, popupPlot and popupPlot.Text or "-")
local instruksiGabung = findGui(gui, "TextLabel", "gabung benih terjadi")
check("Tidak ada teks instruksi gabung di panel tas", instruksiGabung == nil, instruksiGabung and instruksiGabung.Text or "-")

section("Toko Benih: konfirmasi dulu, struk kemudian")
moveTo(P1, 8, 4, -46)
local kasirFired = firePrompt(dunia, { object = "Kasir" }, P1)
check("Prompt kasir toko bisa dipicu", kasirFired)
Stub.Scheduler.advance(0.1)
local buyCommon = findGui(gui, "TextButton", "Pack Common")
check("Tombol beli Pack Common tampil", buyCommon ~= nil)
if buyCommon then
        buyCommon.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
check("Popup konfirmasi muncul (tidak langsung beli)", findGui(gui, "TextLabel", "Konfirmasi Pembelian") ~= nil, "-")
check("Isi pack & harga tampil di konfirmasi", findGui(gui, "TextLabel", "3 benih acak") ~= nil and findGui(gui, "TextLabel", "Harga: 2.400 Micda") ~= nil, "-")
check("Micda belum terpotong sebelum Ya", ls and ls:FindFirstChild("Micda").Value == 900000, tostring(ls and ls:FindFirstChild("Micda").Value))
local batalBtn = findGui(gui, "TextButton", "Batal")
check("Tombol Batal tersedia", batalBtn ~= nil)
if batalBtn then
        batalBtn.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
check("Batal = konfirmasi hilang & saldo utuh", findGui(gui, "TextLabel", "Konfirmasi Pembelian") == nil and ls and ls:FindFirstChild("Micda").Value == 900000, "-")
if buyCommon then
        buyCommon.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
local yaBtn = findGui(gui, "TextButton", "Ya, Beli")
check("Tombol Ya, Beli tersedia", yaBtn ~= nil)
if yaBtn then
        yaBtn.Activated:Fire()
        Stub.Scheduler.advance(0.2)
end
local micdaAfterBuy = ls and ls:FindFirstChild("Micda") and ls:FindFirstChild("Micda").Value
check("Beli setelah Ya (900.000 - 2.400 = 897.600)", micdaAfterBuy == 897600, tostring(micdaAfterBuy))
check("Popup struk isi benih muncul", findGui(gui, "TextLabel", "Pembelian Berhasil") ~= nil, "-")
check("Struk memuat daftar benih & total", findGui(gui, "TextLabel", "Total 2.400 Micda") ~= nil and (function()
        local m = gui:FindFirstChild("ModalBeli")
        if not m then
                return false
        end
        for _, d in ipairs(m:GetDescendants()) do
                if d:IsA("TextLabel") and string.match(d.Text, "^x%d+$") then
                        return true
                end
        end
        return false
end)(), "-")
local okeBtn = findGui(gui, "TextButton", "Oke")
check("Tombol Oke struk tersedia", okeBtn ~= nil)
if okeBtn then
        okeBtn.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
check("Struk tertutup setelah Oke", findGui(gui, "TextLabel", "Pembelian Berhasil") == nil, "-")
check("3 benih acak masuk tas", tasCount(P1, "benih", "wortel") >= 25 and (function()
        local st = serverCall("GetState", P1)
        local n = 0
        for _, s in ipairs(st.tas) do
                if s.kind == "benih" then
                        n += s.count
                end
        end
        return n == 41 + 3
end)(), "-")

section("Gerbang Dunia: masuk ke lahan lewat UI")
moveTo(P1, 0, 5, 20)
firePrompt(dunia, { action = "Dunia-ku" }, P1)
Stub.Scheduler.advance(0.1)
local dimKota = gui:FindFirstChild("DimLayar")
check("Pop up Gerbang Dunia terbuka", dimKota ~= nil and dimKota.Visible == true, dimKota and tostring(dimKota.Visible) or "DimLayar hilang")
local masukBtn = dimKota and findGui(dimKota, "TextButton", "Masuk Dunia-ku")
check("Tombol Masuk Dunia-ku tampil di panel", masukBtn ~= nil)
if masukBtn then
        masukBtn.Activated:Fire()
        Stub.Scheduler.advance(0.5)
end
check("Pop up gerbang langsung hilang setelah pilih", dimKota ~= nil and dimKota.Visible == false, dimKota and tostring(dimKota.Visible) or "-")
local r1 = rootOf(P1)
check("Pemain terbangun instan di dunia lahan (X > 5000)", r1 and r1.Position.X > 5000, r1 and tostring(r1.Position) or "tanpa karakter")
local st = serverCall("GetState", P1)
check("Zona aktif = dunia milik sendiri", st and st.zone == "dunia" and st.role == "pemilik", st and (st.zone .. "/" .. tostring(st.role)) or "tidak ada state")

section("Grid plot di dunia lahan")
local grid = dunia and dunia:FindFirstChild("PlotGrid_1", true)
check("PlotGrid_1 dibuat di dunia lahan", grid ~= nil)
check("Jumlah plot 500", grid and #grid:GetChildren() == 500, grid and tostring(#grid:GetChildren()) or "-")

section("Papan Tanam: panel 3 tab terbuka")
moveTo(P1, 5085, 5, 18)
local papanFired = firePrompt(dunia, { object = "Papan Tanam" }, P1)
check("Prompt Papan Tanam bisa dipicu", papanFired)
Stub.Scheduler.advance(0.1)
check("Judul panel Papan Tanam tampil", findGui(gui, "TextLabel", "Papan Tanam") ~= nil, "-")
check("Tab Tanam ada", findGui(gui, "TextButton", "Tanam") ~= nil, "-")
check("Tab Combine Seed ada", findGui(gui, "TextButton", "Combine Seed") ~= nil, "-")
check("Tab Status ada", findGui(gui, "TextButton", "Status") ~= nil, "-")
check("Panel punya safe area atas (UIPadding >= 48)", (function()
        for _, d in ipairs(gui:GetDescendants()) do
                if d:IsA("UIPadding") and d.PaddingTop and d.PaddingTop.Offset and d.PaddingTop.Offset >= 48 then
                        return true
                end
        end
        return false
end)(), "-")
check("Panel berbasis skala + batas ukuran (UISizeConstraint)", (function()
        for _, d in ipairs(gui:GetDescendants()) do
                if d:IsA("UISizeConstraint") then
                        return true
                end
        end
        return false
end)(), "-")
check("Tombol angka 1/50/100/250/Maks tampil di tab Tanam", findGui(gui, "TextButton", "1") ~= nil and findGui(gui, "TextButton", "50") ~= nil and findGui(gui, "TextButton", "100") ~= nil and findGui(gui, "TextButton", "250") ~= nil and findGui(gui, "TextButton", "Maks") ~= nil, "-")
check("Tab Combine: tombol Gabung tersembunyi saat tab Tanam", (function()
        local g = findGui(gui, "TextButton", "Gabung")
        while g and g.Parent do
                if g.Visible == false then
                        return true
                end
                g = g.Parent
        end
        return false
end)(), "-")
local tabGabungUI = findGui(gui, "TextButton", "Combine Seed")
if tabGabungUI then
        tabGabungUI.Activated:Fire()
        Stub.Scheduler.advance(0.05)
end
check("Tab Combine: baris Benih A & B tampil", findGui(gui, "TextLabel", "Benih A") ~= nil and findGui(gui, "TextLabel", "Benih B") ~= nil, "-")
check("Tab Combine: Mulai Tanam tersembunyi", (function()
        local m = findGui(gui, "TextButton", "Mulai Tanam")
        while m and m.Parent do
                if m.Visible == false then
                        return true
                end
                m = m.Parent
        end
        return false
end)(), "-")
local tabTanamUI
for _, d in ipairs(gui:GetDescendants()) do
        if d:IsA("TextButton") and d.Text == "Tanam" then
                tabTanamUI = d
                break
        end
end
if tabTanamUI then
        tabTanamUI.Activated:Fire()
        Stub.Scheduler.advance(0.05)
end
check("Kembali ke tab Tanam: Mulai Tanam tampil lagi (daftar segar)", (function()
        local m = findGui(gui, "TextButton", "Mulai Tanam")
        while m and m.Parent do
                if m.Visible == false then
                        return false
                end
                m = m.Parent
        end
        return m ~= nil
end)(), "-")

section("Tanam lewat papan: 10 plot per soal, salah tertahan")
check("Pilih benih Wortel di daftar (klik baris)", pilihBenih(gui, "Wortel"), "-")
local angka10 = findGui(gui, "TextButton", "10")
check("Tombol angka 10 tampil", angka10 ~= nil)
if angka10 then
        angka10.Activated:Fire()
end
local mulaiBtn = findGui(gui, "TextButton", "Mulai Tanam")
check("Tombol Mulai Tanam tampil", mulaiBtn ~= nil)
burn(1.2)
if mulaiBtn then
        mulaiBtn.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
local soal1 = findSoalTeks(gui)
check("Soal matematika muncul di papan", soal1 ~= nil, soal1 and soal1.Text or "hilang")

local label0 = findGui(dunia, "TextLabel", "TERTANAM 0/500")
check("Papan menampilkan TERTANAM 0/500 sebelum jawab", label0 ~= nil, "-")

if soal1 then
        local box = findTextBoxByPlaceholder(gui, "Tulis jawaban angka")
        box.Text = "999999"
        local jawabBtn = findGui(gui, "TextButton", "Jawab")
        jawabBtn.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
local salah = findGui(gui, "TextLabel", "Salah")
check("Jawaban salah tertahan (pesan di dalam papan)", salah ~= nil, salah and salah.Text or "-")
local masih0 = findGui(dunia, "TextLabel", "TERTANAM 0/500")
check("Jawaban salah tidak membuka plot", masih0 ~= nil, "-")

burn(1.2)
local okJ1, detJ1 = jawabSoal(gui)
Stub.Scheduler.advance(0.1)
check("Jawaban benar diterima server", okJ1 == true, tostring(detJ1))
local label10 = findGui(dunia, "TextLabel", "TERTANAM 10/500")
check("10 plot terisi setelah 1 soal benar", label10 ~= nil, label10 and label10.Text or "-")
local t1 = grid and grid:FindFirstChild("Tanaman_0", true)
check("Tanaman_0 muncul di plot", t1 ~= nil, "-")
local adaBuah = false
if t1 then
        for _, d in ipairs(t1:GetDescendants()) do
                if d:IsA("BasePart") and d:GetAttribute("Buah") then
                        adaBuah = true
                end
        end
end
check("Tanaman punya bagian buah (bentuk unik per jenis)", adaBuah, "-")
check("Benih wortel berkurang 10 (sisa 15)", tasCount(P1, "benih", "wortel") == 15, tostring(tasCount(P1, "benih", "wortel")))

section("Warna siap panen beda dari masih tumbuh")
Stub.Scheduler.advance(3.6)
local siapOk = false
if t1 then
        local tr, tg, tb = 232 / 255, 112 / 255, 44 / 255
        for _, d in ipairs(t1:GetDescendants()) do
                if d:IsA("BasePart") and d:GetAttribute("Buah") then
                        if math.abs(d.Color.r - tr) < 0.02 and math.abs(d.Color.g - tg) < 0.02 and math.abs(d.Color.b - tb) < 0.02 then
                                siapOk = true
                        end
                end
        end
end
check("Buah berubah ke warna siap setelah matang", siapOk, "-")

section("Punch presisi: tombol PUNCH asli + drop bentuk tanaman")
burn(1.2)
moveTo(P1, 5013, 5, 38)
Stub.Scheduler.advance(0.25)
local tombolPunch = findGui(gui, "TextButton", "PUNCH")
check("Tombol PUNCH bisa memukul tanaman di depan", tombolPunch ~= nil)
if tombolPunch then
        tombolPunch.Activated:Fire()
        Stub.Scheduler.advance(0.5)
end
local drops = dunia and dunia:FindFirstChild("Drops_1", true)
check("Tombol PUNCH memberi drop", drops ~= nil and #drops:GetChildren() >= 1, drops and tostring(#drops:GetChildren()) or "-")
local dropModel = drops and drops:GetChildren()[1]
local dropRoot = dropModel and dropModel:FindFirstChild("Hasil")
check("Drop berupa model tanaman Hasil_wortel (bukan kotak)", dropModel ~= nil and dropModel:IsA("Model") and dropModel.Name == "Hasil_wortel" and dropRoot ~= nil, dropModel and dropModel.Name or "-")
check("Drop wortel multi bagian sesuai bentuk", dropModel ~= nil and #dropModel:GetChildren() >= 3, dropModel and tostring(#dropModel:GetChildren()) or "-")
check("Drop berisi atribut CropId", dropRoot ~= nil and dropRoot:GetAttribute("CropId") == "wortel", dropRoot and tostring(dropRoot:GetAttribute("CropId")) or "-")
check("Warna drop = warna siap wortel", (function()
        if not dropRoot then
                return false
        end
        return math.abs(dropRoot.Color.r - 232 / 255) < 0.02 and math.abs(dropRoot.Color.g - 112 / 255) < 0.02 and math.abs(dropRoot.Color.b - 44 / 255) < 0.02
end)(), "-")
check("Drop tanpa label teks melayang", dropModel ~= nil and countClass(dropModel, "BillboardGui") == 0, "-")
local wortelHasilSebelum = tasCount(P1, "hasil", "wortel")
if dropRoot then
        dropRoot.Touched:Fire(rootOf(P1))
        Stub.Scheduler.advance(1)
end
local wortelHasilSesudah = tasCount(P1, "hasil", "wortel")
check("Drop masuk tas setelah disentuh", wortelHasilSesudah > wortelHasilSebelum, tostring(wortelHasilSebelum) .. " -> " .. tostring(wortelHasilSesudah))
moveTo(P1, 5019, 5, 38)
Stub.Scheduler.advance(0.15)
local okPunch, msgPunch = serverCall("PlotAct", P1, 1, "punch")
check("Punch presisi pindah sasaran tetap jalan", okPunch == true, tostring(msgPunch))
local dropsSisa = dunia and dunia:FindFirstChild("Drops_1", true)
local rootSisa = dropsSisa and dropsSisa:GetChildren()[1]
rootSisa = rootSisa and rootSisa:FindFirstChild("Hasil")
if rootSisa then
        rootSisa.Touched:Fire(rootOf(P1))
        Stub.Scheduler.advance(1)
end
check("Semua drop sudah dipungut (folder drop kembali kosong)", dropsSisa ~= nil and #dropsSisa:GetChildren() == 0, dropsSisa and tostring(#dropsSisa:GetChildren()) or "-")

section("Punch masih tumbuh: 5x beruntun hancur, tanpa drop")
moveTo(P1, 5085, 5, 18)
check("Pilih benih Bayam", pilihBenih(gui, "Bayam"), "-")
mulaiBtn = findGui(gui, "TextButton", "Mulai Tanam")
burn(1.2)
if mulaiBtn then
        mulaiBtn.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
burn(1.2)
local okJ4, detJ4 = jawabSoal(gui)
Stub.Scheduler.advance(0.1)
check("Sesi bayam: 1 soal benar -> TERTANAM 18/500", okJ4 == true and findGui(dunia, "TextLabel", "TERTANAM 18/500") ~= nil, tostring(detJ4))
check("Benih bayam habis (10)", tasCount(P1, "benih", "bayam") == 0, tostring(tasCount(P1, "benih", "bayam")))
local bayam1 = grid and grid:FindFirstChild("Tanaman_10", true)
check("Tanaman_10 (bayam) ada dan masih tumbuh", bayam1 ~= nil, "-")
moveTo(P1, 5073, 5, 38)
local okPg, msgPg
for _ = 1, 5 do
        burn(1.2)
        okPg, msgPg = serverCall("PlotAct", P1, 10, "punch")
        Stub.Scheduler.advance(0.05)
end
local bayamHilang = grid and grid:FindFirstChild("Tanaman_10", true) == nil
check("5x pukul menghancurkan tanaman tumbuh", bayamHilang, tostring(msgPg))
local dropsBayam = dunia and dunia:FindFirstChild("Drops_1", true)
check("Pukul tanaman tumbuh tidak memberi drop", dropsBayam ~= nil and #dropsBayam:GetChildren() == 0, dropsBayam and tostring(#dropsBayam:GetChildren()) or "-")

section("Drop tiap arketipe bentuk tanaman (8 jenis)")
local arketipe = {
        { "pisang", 491 },
        { "gandum", 492 },
        { "kedelai", 493 },
        { "labu_moschata", 494 },
        { "arachis_duranensis", 495 },
        { "jamur", 496 },
        { "tetsukabuto", 497 },
        { "bayam", 498 },
}
for _, a in ipairs(arketipe) do
        local okF = MOD_PlotService.fillPlot(1, a[2], a[1])
        check("Tanam langsung " .. a[1] .. " di plot " .. a[2], okF == true, tostring(okF))
end
Stub.Scheduler.advance(3.8)
for _, a in ipairs(arketipe) do
        local id, idx = a[1], a[2]
        local lx, lz = MOD_Layout.plotLocal(idx)
        moveTo(P1, 5000 + lx, 5, lz + 5)
        Stub.Scheduler.advance(0.15)
        local okP2, msgP2 = serverCall("PlotAct", P1, idx, "punch")
        local model = dunia and dunia:FindFirstChild("Hasil_" .. id, true)
        local rootP = model and model:FindFirstChild("Hasil")
        local b = MOD_CropData.Bentuk[id]
        check("Punch " .. id .. " memberi drop", okP2 == true and model ~= nil, tostring(msgP2))
        check("Drop " .. id .. " bentuk " .. b.jenis .. " (>= 2 bagian)", model ~= nil and #model:GetChildren() >= 2, model and tostring(#model:GetChildren()) or "-")
        check("Warna drop " .. id .. " = warna siap", (function()
                if not rootP then
                        return false
                end
                return math.abs(rootP.Color.r - b.siap[1] / 255) < 0.02 and math.abs(rootP.Color.g - b.siap[2] / 255) < 0.02 and math.abs(rootP.Color.b - b.siap[3] / 255) < 0.02
        end)(), "-")
        burn(1.0)
end

section("Combine Seed di papan: resep cocok, salah ditolak")
moveTo(P1, 5085, 5, 18)
burn(1.2)
local okG1, msgG1 = serverCall("TanamAct", P1, "gabung", "pisang", "wortel")
check("Kombinasi tanpa resep ditolak", okG1 == false and msgG1 == "Tidak bisa di-combine", tostring(okG1) .. "/" .. tostring(msgG1))
check("Benih tidak terpakai saat ditolak", tasCount(P1, "benih", "pisang") == 2, tostring(tasCount(P1, "benih", "pisang")))
burn(1.2)
local okG2, msgG2 = serverCall("TanamAct", P1, "gabung", "jeruk_mandarin", "grapefruit")
check("Jeruk mandarin + grapefruit = benih Tangelo", okG2 == true and string.find(tostring(msgG2), "Tangelo", 1, true) ~= nil, tostring(msgG2))
check("Bahan resep berkurang 1 masing-masing", tasCount(P1, "benih", "jeruk_mandarin") == 1 and tasCount(P1, "benih", "grapefruit") == 1, "-")
check("Benih hybrid masuk tas", tasCount(P1, "benih", "tangelo") == 1, tostring(tasCount(P1, "benih", "tangelo")))

section("Status papan: siap panen vs masih tumbuh")
burn(1.2)
local okS, resS = serverCall("TanamAct", P1, "status")
check("Status bisa diambil dari papan", okS == true and type(resS) == "table", tostring(okS))
check("Tertanam total 17 (20 tanam - 2 panen - 1 hancur)", resS and resS.tertanamTotal == 17, resS and tostring(resS.tertanamTotal) or "-")
local adaWortelRow, adaBayamRow = false, false
if resS and type(resS.status) == "table" then
        for _, row in ipairs(resS.status) do
                if row.id == "wortel" then
                        adaWortelRow = true
                end
                if row.id == "bayam" then
                        adaBayamRow = true
                end
        end
end
check("Status memuat baris wortel & bayam", adaWortelRow and adaBayamRow, "-")

section("Gudang: 250 per tampungan (999 lalu 998)")
burn(1.2)
moveTo(P1, 5205, 5, 181)
local okD1, msgD1 = serverCall("GudangAct", P1, "simpan", "pisang", 250)
check("Setor 250 pisang = 1 tampungan (sisa 999)", okD1 == true and string.find(tostring(msgD1), "999", 1, true) ~= nil, tostring(msgD1))
burn(1.2)
local okD2, msgD2 = serverCall("GudangAct", P1, "simpan", "wortel")
check("Setor sisanya = tampungan ke-2 (sisa 998)", okD2 == true and string.find(tostring(msgD2), "998", 1, true) ~= nil, tostring(msgD2))
burn(1.2)
local okA1, msgA1 = serverCall("GudangAct", P1, "ambil", 2)
check("Ambil kembali dari gudang", okA1 == true, tostring(msgA1))

section("Tamu berkunjung: papan kirim pemberitahuan tamu, aksi ditolak")
local P2 = Stub.addPlayer(2002, "tamu")
Stub.giveCharacter(P2, 0, 6, 44)
Players.PlayerAdded:Fire(P2)
Stub.Scheduler.advance(0.3)
burn(1.2)
local okV, msgV = serverCall("DuniaAct", P2, "kunjungi", "akiomida")
check("Tamu bisa berkunjung ke dunia akiomida", okV == true, tostring(msgV))
local r4 = rootOf(P2)
check("Tamu tiba di dunia lahan", r4 and r4.Position.X > 5000, r4 and tostring(r4.Position) or "-")
local tamuPayload = nil
Stub.setLocalPlayer(P2)
local connOpen = getRemote("OpenPanel").OnClientEvent:Connect(function(name, payload)
        if name == "tanam" then
                tamuPayload = payload
        end
end)
moveTo(P2, 5085, 5, 18)
firePrompt(dunia, { object = "Papan Tanam" }, P2)
Stub.Scheduler.advance(0.1)
connOpen:Disconnect()
Stub.setLocalPlayer(P1)
check("Papan kirim pemberitahuan tamu (tampil di dalam panel)", tamuPayload ~= nil and tamuPayload.tamu == true, tostring(tamuPayload and tamuPayload.tamu))
burn(1.2)
local okTamuTanam = serverCall("TanamAct", P2, "start", "pisang", 1)
check("Tamu tidak bisa mulai tanam", okTamuTanam == false, tostring(okTamuTanam))
burn(1.2)
moveTo(P2, 5013, 5, 38)
local okTamuPunch = serverCall("PlotAct", P2, 1, "punch")
check("Tamu tidak bisa punch tanaman orang lain", okTamuPunch == false, tostring(okTamuPunch))

section("Pulang ke kota lalu balik lagi ke lahan")
__SIM_IS_SERVER = true
Stub.setLocalPlayer(P1)
local zona = dunia and dunia:FindFirstChild("Zona_1", true)
local pulangFired = zona and firePrompt(zona, { action = "Pulang ke Kota" }, P1)
check("Gerbang pulang di lahan bisa dipicu", pulangFired == true)
Stub.Scheduler.advance(0.5)
local r2 = rootOf(P1)
check("Sampai pusat kota lagi", r2 and math.abs(r2.Position.X) < 3 and math.abs(r2.Position.Z - 44) < 4, r2 and tostring(r2.Position) or "-")
burn(1.2)
firePrompt(dunia, { action = "Dunia-ku" }, P1)
Stub.Scheduler.advance(0.1)
local dimBalik = gui:FindFirstChild("DimLayar")
check("Panel gerbang terbuka lagi", dimBalik ~= nil and dimBalik.Visible == true, dimBalik and tostring(dimBalik.Visible) or "DimLayar hilang")
masukBtn = dimBalik and findGui(dimBalik, "TextButton", "Masuk Dunia-ku")
check("Panel gerbang terbuka lagi dengan tombol masuk", masukBtn ~= nil)
if masukBtn then
        masukBtn.Activated:Fire()
        Stub.Scheduler.advance(0.6)
end
check("Pop up gerbang tertutup lagi setelah balik dunia", dimBalik ~= nil and dimBalik.Visible == false, dimBalik and tostring(dimBalik.Visible) or "-")
local r3 = rootOf(P1)
check("BALIK ke dunia lahan sukses", r3 and r3.Position.X > 5000, r3 and tostring(r3.Position) or "-")
local labelBalik = findGui(dunia, "TextLabel", "TERTANAM 17/500")
check("Papan tetap menunjukkan progres terakhir (17/500)", labelBalik ~= nil, labelBalik and labelBalik.Text or "-")

section("Simpan data saat keluar")
Players.PlayerRemoving:Fire(P1)
Stub.Scheduler.advance(0.3)
local duniaStore = Stub.stores["AKM_Dunia"]
check("Dunia pemain tersimpan (d_1001)", duniaStore and duniaStore.__data["d_1001"] ~= nil)
local t1store = Stub.stores["AKM_T1"]
check("Profil pemain tersimpan (u_1001)", t1store and t1store.__data["u_1001"] ~= nil)

section("Bersih dari error runtime")
check("Tidak ada error runtime tersembunyi", #__SIM_ERRORS == 0, table.concat(__SIM_ERRORS, " | "))

print(string.format("HASIL PLAYTEST: %d PASS, %d FAIL", passed, failed))
if failed > 0 then
        error(string.format("%d tahap playtest gagal", failed))
end
