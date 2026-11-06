local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

local CropData = require(ReplicatedStorage.Shared.CropData)
local Net = require(ReplicatedStorage.Remotes)
local UIStyle = require(ReplicatedStorage.Shared.UIStyle)
local PukulAnim = require(ReplicatedStorage.Shared.PukulAnim)
local ArahPukul = require(ReplicatedStorage.Shared.ArahPukul)
local KontrolHP = require(ReplicatedStorage.Shared.KontrolHP)
local HUDLayout = require(ReplicatedStorage.Shared.HUDLayout)
local DropBentuk = require(ReplicatedStorage.Shared.DropBentuk)
local IkonJempol = require(ReplicatedStorage.Shared.IkonJempol)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local state = {
        micda = 0,
        tas = {},
        lahan = nil,
        semai = {},
        zone = "kota",
        dunia = nil,
        role = "hub",
        gudang = nil,
        tanam = nil,
}

local function fmt(n: number): string
        local s = tostring(math.floor(n))
        local rev = string.reverse(s)
        rev = rev:gsub("(%d%d%d)", "%1.")
        rev = rev:gsub("%.$", "")
        return string.reverse(rev)
end

local function warna(t: { number }): Color3
        return Color3.fromRGB(t[1] or 255, t[2] or 255, t[3] or 255)
end

local function warna3b(t: any): Color3
        if type(t) == "table" then
                return Color3.fromRGB(t[1] or 200, t[2] or 200, t[3] or 200)
        end
        return warna(UIStyle.Abu)
end

local FON = Enum.Font[UIStyle.Font]
local FONTB = Enum.Font[UIStyle.FontTebal]

local PANEL_TITLES = {
        tas = "Tas",
        semai = "Semai Panen",
        toko = "Toko Benih",
        gerbang = "Gerbang Dunia",
        tanam = "Papan Tanam",
        gudang = "Gudang Hasil Panen",
}

local function mk(class: string, props: { [string]: any }, parent: Instance?): Instance
        local inst = Instance.new(class)
        for k, v in props do
                (inst :: any)[k] = v
        end
        inst.Parent = parent
        return inst
end

local function round(inst: Instance, r: number?)
        mk("UICorner", { CornerRadius = UDim.new(0, r or UIStyle.Sudut) }, inst)
end

local gui = mk("ScreenGui", {
        Name = "DuniaAkiomida",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local camera = Workspace.CurrentCamera

local aman = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) }, gui)
local amanPad = mk("UIPadding", { PaddingTop = UDim.new(0, 0), PaddingLeft = UDim.new(0, 0), PaddingRight = UDim.new(0, 0), PaddingBottom = UDim.new(0, 0) }, aman)

local function teksSkala(props: { [string]: any }, parent: Instance): TextLabel
        props.TextScaled = true
        local l = mk("TextLabel", props, parent)
        mk("UITextSizeConstraint", { MaxTextSize = HUDLayout.TeksMaks, MinTextSize = HUDLayout.TeksMin }, l)
        return l :: TextLabel
end

local kolomKiri = mk("Frame", { Name = "KolomKiri", Position = UDim2.fromScale(HUDLayout.SaldoSkalaX, 0), Size = UDim2.fromScale(HUDLayout.SaldoSkalaLebar, 1), BackgroundTransparency = 1 }, aman)
mk("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Left, VerticalAlignment = Enum.VerticalAlignment.Top }, kolomKiri)

local saldo = mk("Frame", { LayoutOrder = 1, Size = UDim2.fromScale(1, HUDLayout.SaldoSkalaTinggi), BackgroundColor3 = warna(UIStyle.Latar), BackgroundTransparency = 0.12 }, kolomKiri)
round(saldo)
local saldoUkuran = mk("UISizeConstraint", { MinSize = Vector2.new(150, 30), MaxSize = Vector2.new(320, 64) }, saldo)

local ikonSaldo = mk("Frame", { Position = UDim2.fromScale(HUDLayout.IkonSkalaX, HUDLayout.IkonSkalaY), Size = UDim2.fromScale(HUDLayout.IkonSkalaLebar, HUDLayout.IkonSkalaTinggi), BackgroundColor3 = warna(UIStyle.Aksen) }, saldo)
mk("UICorner", { CornerRadius = UDim.new(0.5, 0) }, ikonSaldo)
teksSkala({ Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "M", Font = FONTB, TextColor3 = warna(UIStyle.Latar) }, ikonSaldo)
local angkaLabel = teksSkala({ Position = UDim2.fromScale(HUDLayout.AngkaSkalaX, 0), Size = UDim2.fromScale(HUDLayout.AngkaSkalaLebar, 1), BackgroundTransparency = 1, Text = "0", Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left }, saldo)
teksSkala({ Position = UDim2.fromScale(HUDLayout.SatuanSkalaX, 0), Size = UDim2.fromScale(HUDLayout.SatuanSkalaLebar, 1), BackgroundTransparency = 1, Text = "Micda", Font = FONTB, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left }, saldo)

local travelBtn = mk("TextButton", { LayoutOrder = 2, Size = UDim2.fromScale(1, HUDLayout.NavSkalaTinggi), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = warna(UIStyle.Permukaan), Text = "Masuk Dunia-ku", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Center }, kolomKiri)
round(travelBtn)
mk("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, travelBtn)
local navUkuran = mk("UISizeConstraint", { MinSize = Vector2.new(120, 26), MaxSize = Vector2.new(220, 26) }, travelBtn)

local tasBtn = mk("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.992, HUDLayout.SaldoSkalaY), Size = UDim2.fromScale(HUDLayout.TasSkalaLebar, HUDLayout.SaldoSkalaTinggi), BackgroundColor3 = warna(UIStyle.PermukaanAktif), Text = "Tas", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks) }, aman)
round(tasBtn)
local tasUkuran = mk("UISizeConstraint", { MinSize = Vector2.new(90, 30), MaxSize = Vector2.new(200, 64) }, tasBtn)

local punchShadow = mk("Frame", { Name = "BayanganPunch", AnchorPoint = Vector2.new(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.62, BorderSizePixel = 0, ZIndex = 0 }, gui)
round(punchShadow, 46)
local punchBtn = mk("TextButton", {
        Name = "TombolPunch",
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = warna(UIStyle.Hijau),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 2,
}, gui)
round(punchBtn, 46)
mk("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(88, 178, 114), Color3.fromRGB(46, 108, 72)), Rotation = 90 }, punchBtn)
mk("UIStroke", { Color = Color3.fromRGB(214, 226, 218), Thickness = 1.5, Transparency = 0.55 }, punchBtn)
local punchSkalaUI = mk("UIScale", { Scale = 1 }, punchBtn)
local ikonPunch = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.62, 0.62), BackgroundTransparency = 1 }, punchBtn)
for _, g in ipairs(IkonJempol.bagian()) do
        local f = mk("Frame", { Position = UDim2.fromScale(g.dx, g.dy), Size = UDim2.fromScale(g.dw, g.dh), BackgroundColor3 = warna(UIStyle.Teks), BorderSizePixel = 0, ZIndex = 3 }, ikonPunch)
        if g.bentuk == "lingkaran" then
                mk("UICorner", { CornerRadius = UDim.new(1, 0) }, f)
        end
end

local function efekTekan(turun: boolean)
        TweenService:Create(punchSkalaUI, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = turun and 0.9 or 1 }):Play()
end
punchBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                efekTekan(true)
        end
end)
punchBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                efekTekan(false)
        end
end)

local jumpPxNyata: number? = nil
local function aturPunch()
        local vp = camera.ViewportSize
        local pos = KontrolHP.posisiPunch(vp.X, vp.Y, jumpPxNyata)
        punchBtn.Position = UDim2.fromScale(pos.skalaX, pos.skalaY)
        punchBtn.Size = UDim2.fromScale(pos.skalaLebar, pos.skalaTinggi)
        punchShadow.Position = UDim2.new(pos.skalaX, 0, pos.skalaY, 3)
        punchShadow.Size = UDim2.fromScale(pos.skalaLebar, pos.skalaTinggi)
end

local function aturUkuranAman()
        local inset = GuiService.TopbarInset
        amanPad.PaddingTop = UDim.new(0, inset.Min.Y + 10)
        amanPad.PaddingLeft = UDim.new(0, inset.Min.X)
        local vp = camera.ViewportSize
        local a = HUDLayout.areaAman(vp.X, vp.Y, inset.Min.X, inset.Min.Y)
        local bs = HUDLayout.batasSaldo(a)
        saldoUkuran.MinSize = Vector2.new(bs.lebar, bs.tinggi)
        saldoUkuran.MaxSize = Vector2.new(bs.lebar, bs.tinggi)
        local bn = HUDLayout.batasNav(a)
        navUkuran.MinSize = Vector2.new(bn.minim, bn.tinggi)
        navUkuran.MaxSize = Vector2.new(bn.maks, bn.tinggi)
        local bt = HUDLayout.batasTas(a)
        tasUkuran.MinSize = Vector2.new(bt.lebar, bs.tinggi)
        tasUkuran.MaxSize = Vector2.new(bt.lebar, bs.tinggi)
        aturPunch()
end

GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(aturUkuranAman)
camera:GetPropertyChangedSignal("ViewportSize"):Connect(aturUkuranAman)
aturUkuranAman()

task.spawn(function()
        local ui = playerGui:WaitForChild("TouchGui", 8)
        if not ui then
                return
        end
        task.wait(0.1)
        local tcf = ui:FindFirstChild("TouchControlFrame")
        local jump = tcf and tcf:FindFirstChild("JumpButton")
        if not jump or not jump:IsA("GuiObject") then
                return
        end
        jumpPxNyata = jump.AbsoluteSize.X
        aturPunch()
end)

local toastHolder = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.2), Size = UDim2.fromScale(0.7, 0.42), BackgroundTransparency = 1 }, aman)
mk("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center }, toastHolder)

local zonaLabel = teksSkala({ AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, HUDLayout.SaldoSkalaY), Size = UDim2.fromScale(0.24, HUDLayout.NavSkalaTinggi), BackgroundColor3 = warna(UIStyle.Latar), BackgroundTransparency = 0.2, Text = "Pusat Kota", Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextTruncate = Enum.TextTruncate.AtEnd }, aman)
round(zonaLabel, UIStyle.SudutKecil)

local toastOrder = 0
local function toast(title: string, msg: string)
        toastOrder += 1
        local f = mk("Frame", { Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = warna(UIStyle.Latar), BackgroundTransparency = 0.08, LayoutOrder = -toastOrder }, toastHolder)
        round(f)
        mk("TextLabel", { Size = UDim2.new(1, -16, 0, 20), Position = UDim2.new(0, 10, 0, 4), BackgroundTransparency = 1, Text = title, TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left }, f)
        mk("TextLabel", { Size = UDim2.new(1, -20, 0, 26), Position = UDim2.new(0, 10, 0, 24), BackgroundTransparency = 1, Text = msg, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true }, f)
        task.delay(3.2, function()
                f:Destroy()
        end)
end

local dim = mk("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, Visible = false }, gui)
local panelHolder = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.fromScale(0.94, 0.88), BackgroundColor3 = warna(UIStyle.Latar) }, dim)
round(panelHolder, 12)
mk("UISizeConstraint", { MinSize = Vector2.new(300, 240), MaxSize = Vector2.new(UIStyle.LebarPanelMaks, UIStyle.TinggiPanelMaks) }, panelHolder)
mk("UIPadding", {
        PaddingTop = UDim.new(0, UIStyle.AmanAtas),
        PaddingBottom = UDim.new(0, 14),
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
}, panelHolder)

local panelTitle = mk("TextLabel", { Size = UDim2.new(1, -60, 0, 34), Position = UDim2.new(0, 2, 0, 2), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranJudul, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, panelHolder)
local closeBtn = mk("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 44, 0, 36), BackgroundColor3 = warna(UIStyle.Permukaan), Text = "X", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks) }, panelHolder)
round(closeBtn, UIStyle.SudutKecil)

local panels = {}
local currentPanel: string? = nil

local function closePanel()
        dim.Visible = false
        currentPanel = nil
end

local function makePanel(name: string): Frame
        local f = mk("Frame", { Size = UDim2.new(1, 0, 1, -44), Position = UDim2.new(0, 0, 0, 42), BackgroundTransparency = 1, Visible = false }, panelHolder)
        panels[name] = f
        return f
end

local function openPanel(name: string)
        for n, f in pairs(panels) do
                f.Visible = n == name
        end
        panelTitle.Text = PANEL_TITLES[name] or ""
        dim.Visible = true
        currentPanel = name
end

closeBtn.Activated:Connect(closePanel)

local function bersihkan(parent: Instance)
        for _, c in ipairs(parent:GetChildren()) do
                if c:IsA("Frame") or c:IsA("TextLabel") or c:IsA("TextButton") then
                        c:Destroy()
                end
        end
end

local tasPanel = makePanel("tas")
local tasGrid = mk("ScrollingFrame", { Size = UDim2.new(1, -8, 1, -40), Position = UDim2.new(0, 4, 0, 4), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, tasPanel)
mk("UIGridLayout", { CellSize = UDim2.new(0, 96, 0, 88), CellPadding = UDim2.new(0, 8, 0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, tasGrid)
local slotFrames = {}
for i = 1, 50 do
        local cell = mk("Frame", { BackgroundColor3 = warna(UIStyle.Permukaan), LayoutOrder = i }, tasGrid)
        round(cell, UIStyle.SudutKecil)
        local nama = mk("TextLabel", { Size = UDim2.new(1, -10, 0, 28), Position = UDim2.new(0, 5, 0, 36), BackgroundTransparency = 1, Text = "", TextWrapped = true, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Teks) }, cell)
        local count = mk("TextLabel", { Size = UDim2.new(1, -10, 0, 16), Position = UDim2.new(0, 5, 1, -20), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Aksen) }, cell)
        slotFrames[i] = { frame = cell, nama = nama, count = count }
end
local tasUsedLabel = mk("TextLabel", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 4, 1, -2), Size = UDim2.new(0.6, 0, 0, 26), BackgroundTransparency = 1, Text = "0/50 slot", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left }, tasPanel)

local function ikonSlot(cell: Frame, s: any?)
        local lama = cell:FindFirstChild("Ikon")
        if lama then
                lama:Destroy()
        end
        if not s then
                return
        end
        local wadah = mk("Frame", { Name = "Ikon", Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(0, 6, 0, 5), BackgroundTransparency = 1 }, cell)
        if s.kind == "blok" then
                mk("Frame", { Size = UDim2.fromScale(0.62, 0.62), Position = UDim2.fromScale(0.19, 0.19), BackgroundColor3 = warna(UIStyle.AbuGelap), BorderSizePixel = 0 }, wadah)
                return
        end
        local info = CropData.byId[s.id]
        local b = info and CropData.Bentuk[info.id]
        local buahC = warna3b(b and b.siap)
        local aksenC = warna3b(b and b.aksen)
        local bagian = DropBentuk.ikonBagian(b and b.jenis or "daun") or {}
        for _, g in ipairs(bagian) do
                local f = mk("Frame", { Position = UDim2.fromScale(g.dx, g.dy), Size = UDim2.fromScale(g.dw, g.dh), BackgroundColor3 = g.warna == "buah" and buahC or aksenC, BorderSizePixel = 0, ZIndex = 2 }, wadah)
                if g.bentuk == "lingkaran" then
                        mk("UICorner", { CornerRadius = UDim.new(1, 0) }, f)
                elseif g.bentuk == "topi" then
                        mk("UICorner", { CornerRadius = UDim.new(0.5, 0) }, f)
                elseif g.bentuk == "kotak" then
                        f.Rotation = 45
                end
        end
end

local function refreshTas()
        local used = #state.tas
        for i = 1, 50 do
                local s = state.tas[i]
                local slot = slotFrames[i]
                if s then
                        local info = CropData.byId[s.id]
                        slot.frame.BackgroundColor3 = s.kind == "benih" and warna(UIStyle.Permukaan) or warna(UIStyle.PermukaanAktif)
                        slot.nama.Text = UIStyle.potong(s.kind == "blok" and "Blok Panen" or (info and info.nama or s.id))
                        slot.count.Text = "x" .. s.count
                        ikonSlot(slot.frame, s)
                else
                        slot.frame.BackgroundColor3 = warna(UIStyle.Permukaan)
                        slot.nama.Text = ""
                        slot.count.Text = ""
                        ikonSlot(slot.frame, nil)
                end
        end
        tasUsedLabel.Text = used .. "/50 slot terpakai"
end

local gerbangPanel = makePanel("gerbang")
local gerbangScroll = mk("ScrollingFrame", { Size = UDim2.new(1, -8, 1, -8), Position = UDim2.new(0, 4, 0, 4), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, gerbangPanel)
mk("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, gerbangScroll)
mk("TextLabel", { Size = UDim2.new(1, -12, 0, 56), BackgroundTransparency = 1, Text = "Duniamu terbuka seketika tanpa loading dan tanpa ID. Tamu bisa berkunjung dan tidak bisa mengubah apa pun. Tombol kiri atas juga bisa dipakai untuk pergi-pulang.", TextWrapped = true, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1 }, gerbangScroll)
local masukBtn = mk("TextButton", { Size = UDim2.new(1, -12, 0, 46), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Masuk Dunia-ku", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1), LayoutOrder = 2 }, gerbangScroll)
round(masukBtn)
local pulangBtn = mk("TextButton", { Size = UDim2.new(1, -12, 0, 40), BackgroundColor3 = warna(UIStyle.PermukaanAktif), Text = "Pulang ke Pusat Kota", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), LayoutOrder = 3 }, gerbangScroll)
round(pulangBtn)
mk("TextLabel", { Size = UDim2.new(1, -12, 0, 22), BackgroundTransparency = 1, Text = "Kunjungi dunia pemain lain:", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 4 }, gerbangScroll)
local kunjungiNama = mk("TextBox", { Size = UDim2.new(1, -12, 0, 40), BackgroundColor3 = warna(UIStyle.Permukaan), Text = "", PlaceholderText = "Ketik nama pemain...", TextSize = UIStyle.UkuranIsi, Font = FON, TextColor3 = warna(UIStyle.Teks), ClearTextOnFocus = false, LayoutOrder = 5 }, gerbangScroll)
round(kunjungiNama, UIStyle.SudutKecil)
local kunjungiBtn = mk("TextButton", { Size = UDim2.new(1, -12, 0, 40), BackgroundColor3 = warna(UIStyle.PermukaanAktif), Text = "Kunjungi", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), LayoutOrder = 6 }, gerbangScroll)
round(kunjungiBtn)

local function syncState()
        task.spawn(function()
                local st = Net.get("GetState"):InvokeServer()
                if st then
                        state.micda = st.micda or 0
                        state.tas = st.tas or {}
                        state.lahan = st.lahan
                        state.zone = st.zone or "kota"
                        state.dunia = st.dunia
                        state.role = st.role or "hub"
                        angkaLabel.Text = fmt(state.micda)
                        refreshTas()
                end
        end)
end

masukBtn.Activated:Connect(function()
        local ok, msg = Net.get("DuniaAct"):InvokeServer("masuk")
        toast(ok and "Gerbang Dunia" or "Gagal", msg)
        if ok then
                syncState()
        end
end)
pulangBtn.Activated:Connect(function()
        local ok, msg = Net.get("DuniaAct"):InvokeServer("pulang")
        toast(ok and "Pulang" or "Gagal", msg)
        if ok then
                syncState()
        end
end)
kunjungiBtn.Activated:Connect(function()
        local ok, msg = Net.get("DuniaAct"):InvokeServer("kunjungi", kunjungiNama.Text)
        toast(ok and "Kunjungan" or "Gagal", msg)
        if ok then
                syncState()
        end
end)

travelBtn.Activated:Connect(function()
        if state.zone == "dunia" then
                local ok, msg = Net.get("DuniaAct"):InvokeServer("pulang")
                toast(ok and "Pulang" or "Gagal", msg)
                if ok then
                        syncState()
                end
        else
                local ok, msg = Net.get("DuniaAct"):InvokeServer("masuk")
                toast(ok and "Gerbang Dunia" or "Gagal", msg)
                if ok then
                        syncState()
                end
        end
end)

local semaiPanel = makePanel("semai")
mk("TextLabel", { Size = UDim2.new(1, -8, 0, 34), Position = UDim2.new(0, 4, 0, 2), BackgroundTransparency = 1, Text = "Letakkan hasil panen di meja, lalu pukul hingga hancur untuk Micda + peluang benih & blok panen.", TextWrapped = true, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left }, semaiPanel)
local semaiLeft = mk("ScrollingFrame", { Size = UDim2.new(0.5, -10, 1, -52), Position = UDim2.new(0, 4, 0, 42), BackgroundColor3 = warna(UIStyle.Permukaan), ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, semaiPanel)
local semaiRight = mk("ScrollingFrame", { Size = UDim2.new(0.5, -10, 1, -52), Position = UDim2.new(0.5, 6, 0, 42), BackgroundColor3 = warna(UIStyle.Permukaan), ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, semaiPanel)
mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, semaiLeft)
mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, semaiRight)

local function actionBtn(parent, text: string, order: number)
        local holder = mk("Frame", { Size = UDim2.new(1, -8, 0, 60), BackgroundColor3 = warna(UIStyle.Latar), LayoutOrder = order }, parent)
        round(holder, UIStyle.SudutKecil)
        mk("TextLabel", { Size = UDim2.new(1, -12, 0, 24), Position = UDim2.new(0, 8, 0, 3), BackgroundTransparency = 1, Text = text, TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, holder)
        return holder
end

local function subBtn(parent: Frame, text: string, posX: number, width: number, warnaBtn: Color3, onAct)
        local btn = mk("TextButton", { Position = UDim2.new(posX, 0, 1, -28), Size = UDim2.new(width, -6, 0, 24), BackgroundColor3 = warnaBtn, Text = text, TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = Color3.new(1, 1, 1) }, parent)
        round(btn, UIStyle.SudutKecil)
        btn.Activated:Connect(onAct)
        return btn
end

local function refreshSemai()
        for _, col in ipairs({ semaiLeft, semaiRight }) do
                bersihkan(col)
        end
        local order = 0
        local adaHasil = false
        for _, s in ipairs(state.tas) do
                if s.kind == "hasil" then
                        adaHasil = true
                        order += 1
                        local info = CropData.byId[s.id]
                        local holder = actionBtn(semaiLeft, (info and info.nama or s.id) .. " x" .. s.count, order)
                        subBtn(holder, "Letakkan 1", 0.5, 0.5, warna(UIStyle.Hijau), function()
                                local ok, msg = Net.get("SmashAct"):InvokeServer("place", s.id)
                                toast(ok and "Meja" or "Gagal", msg)
                        end)
                end
        end
        if not adaHasil then
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "Tidak ada hasil panen di tas.", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), LayoutOrder = 1 }, semaiLeft)
        end
        if #state.semai == 0 then
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "Meja kosong.", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), LayoutOrder = 1 }, semaiRight)
        end
        for i, slot in ipairs(state.semai) do
                local info = CropData.byId[slot.crop]
                local cfg = info and CropData.Smash[info.rarity]
                local holder = actionBtn(semaiRight, (info and info.nama or slot.crop) .. " — pukul " .. tostring(slot.hits) .. "/" .. tostring(cfg and cfg.hits or "?"), i)
                subBtn(holder, "Pukul", 0, 0.5, warna(UIStyle.Merah), function()
                        local ok, msg = Net.get("SmashAct"):InvokeServer("hit", i)
                        toast(ok and "Pukul" or "Gagal", msg)
                end)
                subBtn(holder, "Ambil", 0.5, 0.5, warna(UIStyle.PermukaanAktif), function()
                        local ok, msg = Net.get("SmashAct"):InvokeServer("take", i)
                        toast(ok and "Meja" or "Gagal", msg)
                end)
        end
end

local tokoPanel = makePanel("toko")
mk("TextLabel", { Size = UDim2.new(1, -8, 0, 30), Position = UDim2.new(0, 4, 0, 2), BackgroundTransparency = 1, Text = "Ambil pack benih lewat kasir atau rak berisi benih. Toko juga membeli hasil panenmu.", TextWrapped = true, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left }, tokoPanel)
local tokoBuy = mk("Frame", { Size = UDim2.new(1, -8, 0, 64), Position = UDim2.new(0, 4, 0, 36), BackgroundColor3 = warna(UIStyle.Permukaan) }, tokoPanel)
round(tokoBuy)
local tokoSell = mk("ScrollingFrame", { Size = UDim2.new(1, -8, 1, -112), Position = UDim2.new(0, 4, 0, 106), BackgroundColor3 = warna(UIStyle.Permukaan), ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, tokoPanel)
mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, tokoSell)

local function refreshToko()
        bersihkan(tokoSell)
        local order = 0
        local ada = false
        for _, s in ipairs(state.tas) do
                if s.kind == "hasil" then
                        ada = true
                        order += 1
                        local info = CropData.byId[s.id]
                        local holder = actionBtn(tokoSell, (info and info.nama or s.id) .. " x" .. s.count .. " — " .. (info and info.jual or 0) .. " Micda/unit", order)
                        subBtn(holder, "Jual 1", 0, 0.34, warna(UIStyle.Hijau), function()
                                local ok, msg = Net.get("ShopAct"):InvokeServer("sell", s.id, 1)
                                toast(ok and "Terjual" or "Gagal", msg)
                        end)
                        subBtn(holder, "Jual Semua", 0.34, 0.33, warna(UIStyle.Hijau), function()
                                local ok, msg = Net.get("ShopAct"):InvokeServer("sell", s.id)
                                toast(ok and "Terjual" or "Gagal", msg)
                        end)
                end
        end
        if not ada then
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "Tidak ada hasil panen untuk dijual.", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), LayoutOrder = 1 }, tokoSell)
        end
end

local function buyBtn(parent: Frame, text: string, posX: number, packId: string)
        local btn = mk("TextButton", { Position = UDim2.new(posX, 6, 0, 8), Size = UDim2.new(0.5, -18, 1, -16), BackgroundColor3 = warna(UIStyle.Hijau), Text = text, TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = Color3.new(1, 1, 1), TextWrapped = true }, parent)
        round(btn, UIStyle.SudutKecil)
        btn.Activated:Connect(function()
                local ok, msg = Net.get("ShopAct"):InvokeServer("buy", packId)
                toast(ok and "Pembelian" or "Gagal", msg)
        end)
end

buyBtn(tokoBuy, "Pack Common\n2.400 Micda (3 benih)", 0, "common")
buyBtn(tokoBuy, "Pack Rare\n9.000 Micda (3 benih)", 0.5, "rare")

local tanamPanel = makePanel("tanam")
local tamuMode = false

local tamuNotice = mk("TextLabel", { Size = UDim2.new(1, -8, 1, -8), Position = UDim2.new(0, 4, 0, 4), BackgroundTransparency = 1, Text = "Hanya pemilik dunia yang bisa memakai papan ini.", TextWrapped = true, TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Abu), Visible = false }, tanamPanel)

local tabRow = mk("Frame", { Size = UDim2.new(1, 0, 0, 34), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, tanamPanel)
mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, tabRow)

local function tabBtn(teks: string, order: number): (TextButton, Frame)
        local b = mk("TextButton", { Size = UDim2.new(1 / 3, -8, 1, 0), BackgroundTransparency = 1, Text = teks, TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Abu), LayoutOrder = order }, tabRow)
        local garis = mk("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -1), Size = UDim2.new(0.7, 0, 0, 2), BackgroundColor3 = warna(UIStyle.Aksen), BorderSizePixel = 0, Visible = false }, b)
        return b, garis
end

local tabTanamBtn, garisTanam = tabBtn("Tanam", 1)
local tabGabungBtn, garisGabung = tabBtn("Combine Seed", 2)
local tabStatusBtn, garisStatus = tabBtn("Status", 3)

local tanamBody = mk("Frame", { Size = UDim2.new(1, 0, 1, -42), Position = UDim2.new(0, 0, 0, 40), BackgroundTransparency = 1 }, tanamPanel)

local tanamTab = mk("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = true }, tanamBody)
mk("TextLabel", { Size = UDim2.new(0.55, 0, 0, 18), Position = UDim2.new(0, 2, 0, 0), BackgroundTransparency = 1, Text = "Pilih benih untuk ditanam", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, tanamTab)
local jumlahLabel = mk("TextLabel", { Size = UDim2.new(0.45, -4, 0, 18), Position = UDim2.new(0.55, 4, 0, 0), BackgroundTransparency = 1, Text = "Jumlah: -", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Aksen), TextXAlignment = Enum.TextXAlignment.Right }, tanamTab)
local tanamList = mk("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -118), Position = UDim2.new(0, 0, 0, 22), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, tanamTab)
mk("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, tanamList)
local tanamFeedback = mk("TextLabel", { Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 2, 1, -98), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, tanamTab)

local angkaRow = mk("Frame", { Size = UDim2.new(1, 0, 0, 34), Position = UDim2.new(0, 0, 1, -78), BackgroundTransparency = 1 }, tanamTab)
mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, angkaRow)
local selectedSeed: string? = nil
local selectedQty: number? = 10
local angkaPilih: { TextButton } = {}
local refreshTanam: () -> ()

local function tombolAngka(teks: string, order: number, nilai: number?): TextButton
        local b = mk("TextButton", { Size = UDim2.new(1 / 6, -6, 1, 0), BackgroundColor3 = warna(UIStyle.Permukaan), Text = teks, TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Teks), LayoutOrder = order }, angkaRow)
        round(b, UIStyle.SudutKecil)
        b.Activated:Connect(function()
                selectedQty = nilai
                refreshTanam()
        end)
        return b
end

local tombolMaks = tombolAngka("Maks", 6, nil)
for i, n in ipairs({ 1, 10, 50, 100, 250 }) do
        angkaPilih[i] = tombolAngka(tostring(n), i + 1, n)
end

local mulaiBtn = mk("TextButton", { Size = UDim2.new(1, 0, 0, 36), Position = UDim2.new(0, 0, 1, -38), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Mulai Tanam", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1) }, tanamTab)
round(mulaiBtn)

local soalView = mk("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false }, tanamBody)
local soalNomor = mk("TextLabel", { Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 2, 0, 0), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left }, soalView)
local soalTeks = mk("TextLabel", { Size = UDim2.new(1, 0, 0, 58), Position = UDim2.new(0, 0, 0, 24), BackgroundColor3 = warna(UIStyle.Permukaan), Text = "?", TextSize = UIStyle.UkuranJudul, Font = FONTB, TextColor3 = warna(UIStyle.Teks) }, soalView)
round(soalTeks)
local soalJawab = mk("TextBox", { Size = UDim2.new(0.6, 0, 0, 42), Position = UDim2.new(0.2, 0, 0, 92), BackgroundColor3 = warna(UIStyle.Permukaan), Text = "", PlaceholderText = "Tulis jawaban angka", TextSize = UIStyle.UkuranIsi, Font = FON, TextColor3 = warna(UIStyle.Teks), ClearTextOnFocus = true }, soalView)
round(soalJawab, UIStyle.SudutKecil)
local soalBtn = mk("TextButton", { Size = UDim2.new(0.6, 0, 0, 38), Position = UDim2.new(0.2, 0, 0, 140), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Jawab", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1) }, soalView)
round(soalBtn)
local soalFeedback = mk("TextLabel", { Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 2, 0, 186), BackgroundTransparency = 1, Text = "", TextWrapped = true, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left }, soalView)
local batalBtn = mk("TextButton", { AnchorPoint = Vector2.new(0.5, 1), Size = UDim2.new(0.6, 0, 0, 26), Position = UDim2.new(0.5, 0, 1, -2), BackgroundTransparency = 1, Text = "Batalkan Sesi Tanam", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Merah) }, soalView)

local gabungTab = mk("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false }, tanamBody)
mk("TextLabel", { Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 2, 0, 0), BackgroundTransparency = 1, Text = "Benih A", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left }, gabungTab)
local slotAList = mk("ScrollingFrame", { Size = UDim2.new(1, 0, 0, 64), Position = UDim2.new(0, 0, 0, 18), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, gabungTab)
mk("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, slotAList)
mk("TextLabel", { Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 2, 0, 88), BackgroundTransparency = 1, Text = "Benih B", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left }, gabungTab)
local slotBList = mk("ScrollingFrame", { Size = UDim2.new(1, 0, 0, 64), Position = UDim2.new(0, 0, 0, 106), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, gabungTab)
mk("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, slotBList)
local slotA: string? = nil
local slotB: string? = nil
local gabungBtn = mk("TextButton", { Size = UDim2.new(1, 0, 0, 36), Position = UDim2.new(0, 0, 1, -52), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Gabung", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1) }, gabungTab)
round(gabungBtn)
local gabungFeedback = mk("TextLabel", { Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 2, 1, -14), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, gabungTab)

local statusTab = mk("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false }, tanamBody)
local statusSummary = mk("TextLabel", { Size = UDim2.new(1, -100, 0, 26), Position = UDim2.new(0, 2, 0, 0), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, statusTab)
local statusRefresh = mk("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 92, 0, 26), BackgroundColor3 = warna(UIStyle.PermukaanAktif), Text = "Perbarui", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Teks) }, statusTab)
round(statusRefresh, UIStyle.SudutKecil)
mk("TextLabel", { Size = UDim2.new(1, -8, 0, 30), Position = UDim2.new(0, 2, 0, 27), BackgroundTransparency = 1, Text = "Ambil hasil panen segera dan jangan biarkan tergeletak terlalu lama karena bisa hilang!", TextWrapped = true, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Kuning), TextXAlignment = Enum.TextXAlignment.Left }, statusTab)
local statusList = mk("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -94), Position = UDim2.new(0, 0, 0, 60), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, statusTab)
mk("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, statusList)

local tabAktif = "tanam"

local function muatStatus()
        task.spawn(function()
                local ok, res = Net.get("TanamAct"):InvokeServer("status")
                if not ok or type(res) ~= "table" then
                        return
                end
                statusSummary.Text = "Tertanam " .. tostring(res.tertanamTotal or 0) .. "/" .. tostring(res.plotTotal or 500)
                bersihkan(statusList)
                local daftar = res.status or {}
                if #daftar == 0 then
                        mk("TextLabel", { Size = UDim2.new(1, -8, 0, 36), BackgroundTransparency = 1, Text = "Belum ada tanaman di lahan.", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), LayoutOrder = 1 }, statusList)
                        return
                end
                local order = 0
                for _, row in ipairs(daftar) do
                        order += 1
                        local holder = mk("Frame", { Size = UDim2.new(1, -8, 0, 38), BackgroundColor3 = warna(UIStyle.Permukaan), LayoutOrder = order }, statusList)
                        round(holder, UIStyle.SudutKecil)
                        mk("TextLabel", { Size = UDim2.new(0.4, -8, 1, -8), Position = UDim2.new(0, 8, 0, 4), BackgroundTransparency = 1, Text = UIStyle.potong(row.nama or row.id), TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, holder)
                        mk("TextLabel", { Size = UDim2.new(0.32, -8, 1, -8), Position = UDim2.new(0.4, 8, 0, 4), BackgroundTransparency = 1, Text = "Siap " .. tostring(row.siap or 0), TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Aksen), TextXAlignment = Enum.TextXAlignment.Left }, holder)
                        mk("TextLabel", { Size = UDim2.new(0.28, -8, 1, -8), Position = UDim2.new(0.72, 8, 0, 4), BackgroundTransparency = 1, Text = "Tumbuh " .. tostring(row.tumbuh or 0), TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left }, holder)
                end
        end)
end

local function refreshGabung()
        for _, col in ipairs({ slotAList, slotBList }) do
                bersihkan(col)
        end
        local order = 0
        for _, s in ipairs(state.tas) do
                if s.kind == "benih" then
                        order += 1
                        local info = CropData.byId[s.id]
                        local nama = info and info.nama or s.id
                        local pilihA = mk("TextButton", { Size = UDim2.new(1, -8, 0, 34), BackgroundColor3 = warna(s.id == slotA and UIStyle.PermukaanAktif or UIStyle.Permukaan), Text = "", AutoButtonColor = true, LayoutOrder = order }, slotAList)
                        round(pilihA, UIStyle.SudutKecil)
                        if s.id == slotA then
                                mk("Frame", { Size = UDim2.new(0, 3, 1, -8), Position = UDim2.new(0, 4, 0, 4), BackgroundColor3 = warna(UIStyle.Aksen), BorderSizePixel = 0 }, pilihA)
                        end
                        mk("TextLabel", { Size = UDim2.new(0.68, -8, 1, -8), Position = UDim2.new(0, 12, 0, 4), BackgroundTransparency = 1, Text = UIStyle.potong(nama), TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, pilihA)
                        mk("TextLabel", { Size = UDim2.new(0.24, -8, 1, -8), Position = UDim2.new(0.68, 8, 0, 4), BackgroundTransparency = 1, Text = "x" .. s.count, TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Right }, pilihA)
                        pilihA.Activated:Connect(function()
                                slotA = s.id
                                refreshGabung()
                        end)
                        local pilihB = mk("TextButton", { Size = UDim2.new(1, -8, 0, 34), BackgroundColor3 = warna(s.id == slotB and UIStyle.PermukaanAktif or UIStyle.Permukaan), Text = "", AutoButtonColor = true, LayoutOrder = order }, slotBList)
                        round(pilihB, UIStyle.SudutKecil)
                        if s.id == slotB then
                                mk("Frame", { Size = UDim2.new(0, 3, 1, -8), Position = UDim2.new(0, 4, 0, 4), BackgroundColor3 = warna(UIStyle.Aksen), BorderSizePixel = 0 }, pilihB)
                        end
                        mk("TextLabel", { Size = UDim2.new(0.68, -8, 1, -8), Position = UDim2.new(0, 12, 0, 4), BackgroundTransparency = 1, Text = UIStyle.potong(nama), TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, pilihB)
                        mk("TextLabel", { Size = UDim2.new(0.24, -8, 1, -8), Position = UDim2.new(0.68, 8, 0, 4), BackgroundTransparency = 1, Text = "x" .. s.count, TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Right }, pilihB)
                        pilihB.Activated:Connect(function()
                                slotB = s.id
                                refreshGabung()
                        end)
                end
        end
        if order == 0 then
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 34), BackgroundTransparency = 1, Text = "Tidak ada benih di tas.", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), LayoutOrder = 1 }, slotAList)
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 34), BackgroundTransparency = 1, Text = "Tidak ada benih di tas.", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), LayoutOrder = 1 }, slotBList)
        end
end

local function setTab(nama: string)
        tabAktif = nama
        bersihkan(tanamList)
        bersihkan(statusList)
        bersihkan(slotAList)
        bersihkan(slotBList)
        tanamTab.Visible = nama == "tanam"
        soalView.Visible = false
        gabungTab.Visible = nama == "gabung"
        statusTab.Visible = nama == "status"
        tabTanamBtn.TextColor3 = warna(nama == "tanam" and UIStyle.Teks or UIStyle.Abu)
        tabGabungBtn.TextColor3 = warna(nama == "gabung" and UIStyle.Teks or UIStyle.Abu)
        tabStatusBtn.TextColor3 = warna(nama == "status" and UIStyle.Teks or UIStyle.Abu)
        garisTanam.Visible = nama == "tanam"
        garisGabung.Visible = nama == "gabung"
        garisStatus.Visible = nama == "status"
        if nama == "status" then
                muatStatus()
        elseif nama == "gabung" then
                refreshGabung()
        else
                refreshTanam()
        end
end

refreshTanam = function()
        tabRow.Visible = not tamuMode
        tanamBody.Visible = not tamuMode
        tamuNotice.Visible = tamuMode
        if tamuMode then
                return
        end
        local t = state.tanam or {}
        local aktif = t.aktif == true
        tanamTab.Visible = not aktif
        soalView.Visible = aktif
        local benihAda = 0
        for _, s in ipairs(state.tas) do
                if s.kind == "benih" and s.id == selectedSeed then
                        benihAda = s.count
                end
        end
        jumlahLabel.Text = selectedQty and ("Jumlah: " .. tostring(selectedQty)) or ("Jumlah: Maks (" .. tostring(benihAda) .. ")")
        for i, n in ipairs({ 1, 10, 50, 100, 250 }) do
                angkaPilih[i].BackgroundColor3 = warna(selectedQty == n and UIStyle.PermukaanAktif or UIStyle.Permukaan)
        end
        tombolMaks.BackgroundColor3 = warna(selectedQty == nil and UIStyle.PermukaanAktif or UIStyle.Permukaan)
        if aktif then
                soalNomor.Text = "Soal " .. tostring(t.soal and t.soal.nomor or 1) .. " dari " .. tostring(t.totalSoal) .. " — tertanam " .. tostring(t.tertanam) .. "/" .. tostring(t.jumlah)
                if t.soal then
                        soalTeks.Text = t.soal.teks
                end
        else
                tanamFeedback.Text = ""
        end
        bersihkan(tanamList)
        local order = 0
        for _, s in ipairs(state.tas) do
                if s.kind == "benih" then
                        order += 1
                        local info = CropData.byId[s.id]
                        local row = mk("TextButton", { Size = UDim2.new(1, -8, 0, 40), BackgroundColor3 = warna(s.id == selectedSeed and UIStyle.PermukaanAktif or UIStyle.Permukaan), Text = "", AutoButtonColor = true, LayoutOrder = order }, tanamList)
                        round(row, UIStyle.SudutKecil)
                        if s.id == selectedSeed then
                                mk("Frame", { Size = UDim2.new(0, 3, 1, -8), Position = UDim2.new(0, 4, 0, 4), BackgroundColor3 = warna(UIStyle.Aksen), BorderSizePixel = 0 }, row)
                        end
                        mk("TextLabel", { Size = UDim2.new(0.66, -8, 1, -8), Position = UDim2.new(0, 12, 0, 4), BackgroundTransparency = 1, Text = UIStyle.potong(info and info.nama or s.id), TextSize = UIStyle.UkuranIsi, Font = FON, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, row)
                        mk("TextLabel", { Size = UDim2.new(0.26, -8, 1, -8), Position = UDim2.new(0.66, 8, 0, 4), BackgroundTransparency = 1, Text = "x" .. s.count, TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Right }, row)
                        row.Activated:Connect(function()
                                selectedSeed = s.id
                                refreshTanam()
                        end)
                end
        end
        if order == 0 then
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 36), BackgroundTransparency = 1, Text = "Tidak ada benih di tas. Beli pack benih di Toko Benih, Pusat Kota.", TextWrapped = true, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), LayoutOrder = 1 }, tanamList)
        end
end

mulaiBtn.Activated:Connect(function()
        if not selectedSeed then
                tanamFeedback.TextColor3 = warna(UIStyle.Merah)
                tanamFeedback.Text = "Pilih benih dulu di daftar."
                return
        end
        local jumlah = selectedQty
        if jumlah == nil then
                for _, s in ipairs(state.tas) do
                        if s.kind == "benih" and s.id == selectedSeed then
                                jumlah = s.count
                                break
                        end
                end
        end
        local ok, msg = Net.get("TanamAct"):InvokeServer("start", selectedSeed, jumlah)
        tanamFeedback.TextColor3 = warna(ok and UIStyle.Aksen or UIStyle.Merah)
        tanamFeedback.Text = msg
        if ok then
                refreshTanam()
        end
end)

soalBtn.Activated:Connect(function()
        local n = tonumber(soalJawab.Text)
        if not n then
                soalFeedback.TextColor3 = warna(UIStyle.Merah)
                soalFeedback.Text = "Masukkan angka dulu."
                return
        end
        local ok, msg = Net.get("TanamAct"):InvokeServer("jawab", n)
        soalFeedback.TextColor3 = warna(ok and UIStyle.Aksen or UIStyle.Merah)
        soalFeedback.Text = msg
        if ok then
                soalJawab.Text = ""
        end
end)

batalBtn.Activated:Connect(function()
        local ok = Net.get("TanamAct"):InvokeServer("batal")
        if ok then
                state.tanam = nil
                refreshTanam()
        end
end)

gabungBtn.Activated:Connect(function()
        if not slotA or not slotB then
                gabungFeedback.TextColor3 = warna(UIStyle.Merah)
                gabungFeedback.Text = "Pilih benih untuk kedua slot."
                return
        end
        local ok, msg = Net.get("TanamAct"):InvokeServer("gabung", slotA, slotB)
        gabungFeedback.TextColor3 = warna(ok and UIStyle.Aksen or UIStyle.Merah)
        gabungFeedback.Text = msg
        if ok then
                refreshGabung()
        end
end)

statusRefresh.Activated:Connect(function()
        muatStatus()
end)

tabTanamBtn.Activated:Connect(function()
        setTab("tanam")
end)
tabGabungBtn.Activated:Connect(function()
        setTab("gabung")
end)
tabStatusBtn.Activated:Connect(function()
        setTab("status")
end)

local gudangPanel = makePanel("gudang")
local gudangTampungan = mk("TextLabel", { Size = UDim2.new(1, -8, 0, 22), Position = UDim2.new(0, 4, 0, 0), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, gudangPanel)
mk("TextLabel", { Size = UDim2.new(1, -8, 0, 16), Position = UDim2.new(0, 4, 0, 24), BackgroundTransparency = 1, Text = "Kiri: setor hasil panen. Kanan: ambil dari gudang.", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, gudangPanel)
local gudangLeft = mk("ScrollingFrame", { Size = UDim2.new(0.5, -10, 1, -52), Position = UDim2.new(0, 4, 0, 46), BackgroundColor3 = warna(UIStyle.Permukaan), ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, gudangPanel)
local gudangRight = mk("ScrollingFrame", { Size = UDim2.new(0.5, -10, 1, -52), Position = UDim2.new(0.5, 6, 0, 46), BackgroundColor3 = warna(UIStyle.Permukaan), ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, gudangPanel)
mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, gudangLeft)
mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, gudangRight)

local function refreshGudang()
        local g = state.gudang
        if not g then
                return
        end
        gudangTampungan.Text = "Tampungan: " .. tostring(g.terpakai) .. "/" .. tostring(g.maks) .. " — 1-250 buah = 1 tampungan"
        for _, col in ipairs({ gudangLeft, gudangRight }) do
                bersihkan(col)
        end
        local order = 0
        for _, s in ipairs(state.tas) do
                if s.kind == "hasil" then
                        order += 1
                        local info = CropData.byId[s.id]
                        local holder = actionBtn(gudangLeft, (info and info.nama or s.id) .. " x" .. s.count, order)
                        subBtn(holder, "Setor 250", 0, 0.5, warna(UIStyle.Hijau), function()
                                local ok, msg = Net.get("GudangAct"):InvokeServer("simpan", s.id, 250)
                                toast(ok and "Gudang" or "Gagal", msg)
                        end)
                        subBtn(holder, "Setor Semua", 0.5, 0.5, warna(UIStyle.PermukaanAktif), function()
                                local ok, msg = Net.get("GudangAct"):InvokeServer("simpan", s.id)
                                toast(ok and "Gudang" or "Gagal", msg)
                        end)
                end
        end
        if order == 0 then
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "Tidak ada hasil panen di tas untuk disimpan.", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), LayoutOrder = 1 }, gudangLeft)
        end
        local order2 = 0
        for _, slot in ipairs(g.slots or {}) do
                order2 += 1
                local info = CropData.byId[slot.id]
                local holder = actionBtn(gudangRight, "Slot " .. slot.i .. ": " .. (info and info.nama or slot.id) .. " x" .. slot.count, order2)
                subBtn(holder, "Ambil Semua", 0, 0.5, warna(UIStyle.Hijau), function()
                        local ok, msg = Net.get("GudangAct"):InvokeServer("ambil", slot.i)
                        toast(ok and "Gudang" or "Gagal", msg)
                end)
                subBtn(holder, "Ambil 100", 0.5, 0.5, warna(UIStyle.PermukaanAktif), function()
                        local ok, msg = Net.get("GudangAct"):InvokeServer("ambil", slot.i, 100)
                        toast(ok and "Gudang" or "Gagal", msg)
                end)
        end
        if order2 == 0 then
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "Gudang masih kosong.", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), LayoutOrder = 1 }, gudangRight)
        end
end

tasBtn.Activated:Connect(function()
        if currentPanel == "tas" then
                closePanel()
                return
        end
        openPanel("tas")
        refreshTas()
end)

local punchTarget: number? = nil
local animT0: number? = nil
local motorSaat: Motor6D? = nil
local shakeT0: number? = nil
local punchN, punchT = 0, 0
local punchTier = 1

local highlight = Instance.new("Highlight")
highlight.FillColor = warna(UIStyle.Aksen)
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.FillTransparency = 0.78
highlight.OutlineTransparency = 0.2
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

local function folderTanaman(): Folder?
        local dunia = Workspace:FindFirstChild("Dunia")
        return dunia and dunia:FindFirstChild("PlotGrid_" .. tostring(state.lahan), true)
end

local function cariModelTanaman(induk: Instance): Model?
        local m = induk
        while m and m.Parent do
                if m:IsA("Model") and string.sub(m.Name, 1, 8) == "Tanaman_" then
                        return m :: Model
                end
                m = m.Parent
        end
        return nil
end

local function kandidat(folder: Folder): { any }
        local daftar = {}
        for _, m in ipairs(folder:GetChildren()) do
                if m:IsA("Model") and string.sub(m.Name, 1, 8) == "Tanaman_" then
                        local pos = m:GetPivot().Position
                        table.insert(daftar, { idx = m:GetAttribute("PlotIdx"), pos = { x = pos.X, y = 0, z = pos.Z }, radius = ArahPukul.Radius })
                end
        end
        return daftar
end

task.spawn(function()
        while true do
                task.wait(0.1)
                local idxBaru: number? = nil
                local modelBaru: Model? = nil
                if state.zone == "dunia" and state.lahan then
                        local char = player.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
                        local folder = folderTanaman()
                        if root and folder then
                                local asal = (root.CFrame * CFrame.new(0, 0.8, 0)).Position
                                local arah = root.CFrame.LookVector
                                local params = RaycastParams.new()
                                params.FilterType = Enum.RaycastFilterType.Include
                                params.FilterDescendantsInstances = { folder }
                                local ray = Workspace:Raycast(asal, arah * ArahPukul.Jangkauan, params)
                                if ray then
                                        modelBaru = cariModelTanaman(ray.Instance)
                                        if modelBaru then
                                                idxBaru = modelBaru:GetAttribute("PlotIdx") :: number?
                                        end
                                end
                                if not modelBaru then
                                        local arahXZ = { x = arah.X, y = 0, z = arah.Z }
                                        local pilih = ArahPukul.pilih({ x = asal.X, y = 0, z = asal.Z }, arahXZ, kandidat(folder))
                                        if pilih and type(pilih.idx) == "number" then
                                                idxBaru = pilih.idx
                                                modelBaru = folder:FindFirstChild("Tanaman_" .. tostring(pilih.idx))
                                        end
                                end
                        end
                end
                punchTarget = idxBaru
                highlight.Parent = modelBaru
        end
end)

RunService.RenderStepped:Connect(function()
        local t = os.clock()
        if shakeT0 and t - shakeT0 < 0.09 then
                local g = PukulAnim.getar(punchTier)
                camera.CFrame = camera.CFrame * CFrame.Angles(0, 0, math.rad((math.random() - 0.5) * 2 * g))
        end
        if animT0 == nil then
                return
        end
        local f = PukulAnim.fase(animT0, t)
        if not f.memukul then
                if motorSaat and motorSaat.Parent then
                        motorSaat.Transform = CFrame.new()
                end
                motorSaat = nil
                animT0 = nil
                return
        end
        if not motorSaat or motorSaat.Parent == nil then
                local char = player.Character
                if char then
                        motorSaat = (char:FindFirstChild("RightShoulder", true) or char:FindFirstChild("Right Shoulder", true)) :: Motor6D?
                end
        end
        if motorSaat then
                if motorSaat.Name == "Right Shoulder" then
                        motorSaat.Transform = CFrame.Angles(0, 0, -f.sudut)
                else
                        motorSaat.Transform = CFrame.Angles(-f.sudut, 0, 0)
                end
        end
end)

punchBtn.Activated:Connect(function()
        local t = os.clock()
        animT0 = PukulAnim.mulaiUlang(animT0, t)
        if t - punchT <= 4 then
                punchN += 1
        else
                punchN = 1
        end
        punchT = t
        punchTier = punchN >= 8 and 3 or (punchN >= 4 and 2 or 1)
        shakeT0 = t
        task.spawn(function()
                local awal = camera.FieldOfView
                camera.FieldOfView = awal + 3 + 2 * punchTier
                task.wait(0.09)
                camera.FieldOfView = awal
        end)
        local target = punchTarget
        task.delay(PukulAnim.MomenKena, function()
                pcall(function()
                        Net.get("PlotAct"):InvokeServer(target, "punch")
                end)
        end)
end)

Net.get("Sync").OnClientEvent:Connect(function(payload)
        state.micda = payload.micda
        state.tas = payload.tas or {}
        angkaLabel.Text = fmt(state.micda)
        if payload.zone then
                state.zone = payload.zone
                state.dunia = payload.dunia
                state.lahan = payload.lahan
                if state.zone == "dunia" then
                        zonaLabel.Text = "Dunia " .. tostring(state.dunia or "Petani")
                        travelBtn.Text = "Pulang ke Kota"
                else
                        zonaLabel.Text = "Pusat Kota"
                        travelBtn.Text = "Masuk Dunia-ku"
                end
        end
        refreshTas()
        if currentPanel == "semai" then
                refreshSemai()
        elseif currentPanel == "toko" then
                refreshToko()
        elseif currentPanel == "tanam" then
                if tabAktif == "gabung" then
                        refreshGabung()
                elseif tabAktif == "status" then
                        muatStatus()
                else
                        refreshTanam()
                end
        elseif currentPanel == "gudang" then
                refreshGudang()
        end
end)

Net.get("Notify").OnClientEvent:Connect(function(title, msg)
        toast(tostring(title), tostring(msg))
end)

Net.get("SmashSync").OnClientEvent:Connect(function(p)
        if p.lahan == state.lahan then
                state.semai = p.slots or {}
                if currentPanel == "semai" then
                        refreshSemai()
                end
        end
end)

Net.get("TanamSync").OnClientEvent:Connect(function(p)
        state.tanam = p
        if currentPanel == "tanam" then
                if tabAktif == "tanam" then
                        refreshTanam()
                elseif tabAktif == "status" then
                        muatStatus()
                end
        end
end)

Net.get("GudangSync").OnClientEvent:Connect(function(p)
        state.gudang = p
        if currentPanel == "gudang" then
                refreshGudang()
        end
end)

Net.get("OpenPanel").OnClientEvent:Connect(function(name, payload)
        if name == "semai" then
                openPanel("semai")
                refreshSemai()
        elseif name == "toko" then
                openPanel("toko")
                refreshToko()
        elseif name == "gerbang" then
                openPanel("gerbang")
        elseif name == "tanam" then
                tamuMode = payload ~= nil and payload.tamu == true
                openPanel("tanam")
                setTab("tanam")
        elseif name == "gudang" then
                openPanel("gudang")
                refreshGudang()
        end
end)

task.spawn(function()
        local st = Net.get("GetState"):InvokeServer()
        if st then
                state.micda = st.micda or 0
                state.tas = st.tas or {}
                state.lahan = st.lahan
                state.zone = st.zone or "kota"
                state.dunia = st.dunia
                state.role = st.role or "hub"
                angkaLabel.Text = fmt(state.micda)
                if state.zone == "dunia" then
                        zonaLabel.Text = "Dunia " .. tostring(state.dunia or "Petani")
                        travelBtn.Text = "Pulang ke Kota"
                else
                        zonaLabel.Text = "Pusat Kota"
                        travelBtn.Text = "Masuk Dunia-ku"
                end
                refreshTas()
        end
end)

print("[AKIOMIDA] UI siap.")

return true
