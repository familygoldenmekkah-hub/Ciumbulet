local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local CropData = require(ReplicatedStorage.Shared.CropData)
local Net = require(ReplicatedStorage.Remotes)

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

local KIND_COLOR = {
        benih = Color3.fromRGB(122, 85, 52),
        hasil = Color3.fromRGB(72, 130, 62),
        blok = Color3.fromRGB(96, 98, 104),
}
local PANEL_TITLES = {
        tas = "Tas (50 slot, maks 250 per slot)",
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
        mk("UICorner", { CornerRadius = UDim.new(0, r or 8) }, inst)
end

local gui = mk("ScreenGui", {
        Name = "DuniaAkiomida",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local hud = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 52), Position = UDim2.new(0, 0, 0, 8) }, gui)

local micdaFrame = mk("Frame", { Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0, 190, 0, 44), BackgroundColor3 = Color3.fromRGB(18, 20, 24), BackgroundTransparency = 0.15 }, hud)
round(micdaFrame)
mk("TextLabel", { Size = UDim2.new(0, 40, 1, 0), BackgroundTransparency = 1, Text = "M", TextScaled = true, Font = Enum.Font.GothamBlack, TextColor3 = Color3.fromRGB(255, 208, 96) }, micdaFrame)
local micdaLabel = mk("TextLabel", { Position = UDim2.new(0, 46, 0, 0), Size = UDim2.new(1, -54, 1, 0), BackgroundTransparency = 1, Text = "0 Micda", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(240, 240, 240), TextXAlignment = Enum.TextXAlignment.Left }, micdaFrame)

local travelBtn = mk("TextButton", { Position = UDim2.new(0, 12, 0, 52), Size = UDim2.new(0, 170, 0, 40), BackgroundColor3 = Color3.fromRGB(58, 84, 138), Text = "Masuk Dunia-ku", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, gui)
round(travelBtn)

local tasBtn = mk("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 0), Size = UDim2.new(0, 150, 0, 44), BackgroundColor3 = Color3.fromRGB(46, 110, 62), Text = "Tas", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, hud)
round(tasBtn)

local punchBtn = mk("TextButton", { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -26, 1, -30), Size = UDim2.new(0, 116, 0, 116), BackgroundColor3 = Color3.fromRGB(196, 96, 48), Text = "PUNCH", TextScaled = true, Font = Enum.Font.GothamBlack, TextColor3 = Color3.new(1, 1, 1), Visible = true }, gui)
round(punchBtn, 58)
mk("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 3, Transparency = 0.2 }, punchBtn)

local toastHolder = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 66), Size = UDim2.new(0, 470, 0, 220), BackgroundTransparency = 1 }, gui)
mk("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center }, toastHolder)

local zonaLabel = mk("TextLabel", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 8), Size = UDim2.new(0, 260, 0, 24), BackgroundColor3 = Color3.fromRGB(18, 20, 24), BackgroundTransparency = 0.25, Text = "Pusat Kota", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255, 214, 110) }, gui)
round(zonaLabel, 6)

local toastOrder = 0
local function toast(title: string, msg: string)
        toastOrder += 1
        local f = mk("Frame", { Size = UDim2.new(1, 0, 0, 58), BackgroundColor3 = Color3.fromRGB(18, 20, 24), BackgroundTransparency = 0.12, LayoutOrder = -toastOrder }, toastHolder)
        round(f)
        mk("TextLabel", { Size = UDim2.new(1, -16, 0, 22), Position = UDim2.new(0, 8, 0, 4), BackgroundTransparency = 1, Text = title, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255, 214, 110), TextScaled = true, TextXAlignment = Enum.TextXAlignment.Left }, f)
        mk("TextLabel", { Size = UDim2.new(1, -16, 0, 26), Position = UDim2.new(0, 8, 0, 28), BackgroundTransparency = 1, Text = msg, Font = Enum.Font.Gotham, TextColor3 = Color3.new(1, 1, 1), TextScaled = true, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true }, f)
        task.delay(3.2, function()
                f:Destroy()
        end)
end

local dim = mk("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, Visible = false }, gui)
local panelHolder = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 580, 0, 420), BackgroundColor3 = Color3.fromRGB(22, 24, 30) }, dim)
round(panelHolder, 12)
local panelTitle = mk("TextLabel", { Size = UDim2.new(1, -70, 0, 40), Position = UDim2.new(0, 14, 0, 8), BackgroundTransparency = 1, Text = "", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left }, panelHolder)
local closeBtn = mk("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 8), Size = UDim2.new(0, 44, 0, 40), BackgroundColor3 = Color3.fromRGB(140, 60, 56), Text = "X", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, panelHolder)
round(closeBtn)

local panels = {}
local currentPanel: string? = nil

local function closePanel()
        dim.Visible = false
        currentPanel = nil
end

local function makePanel(name: string): Frame
        local f = mk("Frame", { Size = UDim2.new(1, -24, 1, -66), Position = UDim2.new(0, 12, 0, 52), BackgroundTransparency = 1, Visible = false }, panelHolder)
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

local tasPanel = makePanel("tas")
local tasGrid = mk("ScrollingFrame", { Size = UDim2.new(1, -16, 1, -58), Position = UDim2.new(0, 8, 0, 8), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, tasPanel)
mk("UIGridLayout", { CellSize = UDim2.new(0, 96, 0, 76), CellPadding = UDim2.new(0, 6, 0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, tasGrid)
local slotFrames = {}
for i = 1, 50 do
        local cell = mk("Frame", { BackgroundColor3 = Color3.fromRGB(34, 38, 46), LayoutOrder = i }, tasGrid)
        round(cell, 6)
        local nama = mk("TextLabel", { Size = UDim2.new(1, -8, 0, 36), Position = UDim2.new(0, 4, 0, 4), BackgroundTransparency = 1, Text = "", TextWrapped = true, TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.new(1, 1, 1) }, cell)
        local count = mk("TextLabel", { Size = UDim2.new(1, -8, 0, 22), Position = UDim2.new(0, 4, 1, -26), BackgroundTransparency = 1, Text = "", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255, 214, 110) }, cell)
        slotFrames[i] = { frame = cell, nama = nama, count = count }
end
local tasUsedLabel = mk("TextLabel", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 8, 1, -6), Size = UDim2.new(0.5, 0, 0, 28), BackgroundTransparency = 1, Text = "0/50 slot", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(200, 200, 205), TextXAlignment = Enum.TextXAlignment.Left }, tasPanel)

local function refreshTas()
        local used = #state.tas
        for i = 1, 50 do
                local s = state.tas[i]
                local slot = slotFrames[i]
                if s then
                        local info = CropData.byId[s.id]
                        slot.frame.BackgroundColor3 = KIND_COLOR[s.kind] or Color3.fromRGB(60, 60, 66)
                        slot.nama.Text = s.kind == "blok" and "Blok Panen" or (info and info.nama or s.id)
                        slot.count.Text = "x" .. s.count
                else
                        slot.frame.BackgroundColor3 = Color3.fromRGB(34, 38, 46)
                        slot.nama.Text = ""
                        slot.count.Text = ""
                end
        end
        tasUsedLabel.Text = used .. "/50 slot terpakai"
end

local gerbangPanel = makePanel("gerbang")
mk("TextLabel", { Size = UDim2.new(1, -16, 0, 56), Position = UDim2.new(0, 8, 0, 4), BackgroundTransparency = 1, Text = "Duniamu terbuka seketika tanpa loading dan tanpa ID. Tamu bisa berkunjung dan tidak bisa mengubah apa pun. Tombol kiri atas juga bisa dipakai untuk pergi-pulang.", TextWrapped = true, TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(200, 200, 205), TextXAlignment = Enum.TextXAlignment.Left }, gerbangPanel)
local masukBtn = mk("TextButton", { Size = UDim2.new(1, -16, 0, 52), Position = UDim2.new(0, 8, 0, 68), BackgroundColor3 = Color3.fromRGB(46, 110, 62), Text = "Masuk Dunia-ku", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, gerbangPanel)
round(masukBtn)
local pulangBtn = mk("TextButton", { Size = UDim2.new(1, -16, 0, 44), Position = UDim2.new(0, 8, 0, 128), BackgroundColor3 = Color3.fromRGB(150, 116, 58), Text = "Pulang ke Pusat Kota", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, gerbangPanel)
round(pulangBtn)
mk("TextLabel", { Size = UDim2.new(1, -16, 0, 26), Position = UDim2.new(0, 8, 0, 180), BackgroundTransparency = 1, Text = "Kunjungi dunia pemain lain:", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255, 214, 110), TextXAlignment = Enum.TextXAlignment.Left }, gerbangPanel)
local kunjungiNama = mk("TextBox", { Size = UDim2.new(1, -16, 0, 44), Position = UDim2.new(0, 8, 0, 208), BackgroundColor3 = Color3.fromRGB(30, 33, 40), Text = "", PlaceholderText = "Ketik nama pemain...", TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.new(1, 1, 1), ClearTextOnFocus = false }, gerbangPanel)
round(kunjungiNama, 6)
local kunjungiBtn = mk("TextButton", { Size = UDim2.new(1, -16, 0, 44), Position = UDim2.new(0, 8, 0, 260), BackgroundColor3 = Color3.fromRGB(58, 84, 138), Text = "Kunjungi", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, gerbangPanel)
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
                        micdaLabel.Text = fmt(state.micda) .. " Micda"
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
mk("TextLabel", { Size = UDim2.new(1, -16, 0, 30), Position = UDim2.new(0, 8, 0, 2), BackgroundTransparency = 1, Text = "Letakkan hasil panen di meja, lalu pukul hingga hancur untuk Micda + peluang benih & blok panen.", TextWrapped = true, TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(200, 200, 205), TextXAlignment = Enum.TextXAlignment.Left }, semaiPanel)
local semaiLeft = mk("ScrollingFrame", { Size = UDim2.new(0.5, -14, 1, -80), Position = UDim2.new(0, 8, 0, 44), BackgroundColor3 = Color3.fromRGB(30, 33, 40), ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, semaiPanel)
local semaiRight = mk("ScrollingFrame", { Size = UDim2.new(0.5, -14, 1, -80), Position = UDim2.new(0.5, 6, 0, 44), BackgroundColor3 = Color3.fromRGB(30, 33, 40), ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, semaiPanel)
mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, semaiLeft)
mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, semaiRight)

local function actionBtn(parent, text: string, order: number)
        local holder = mk("Frame", { Size = UDim2.new(1, -8, 0, 64), BackgroundColor3 = Color3.fromRGB(38, 42, 52), LayoutOrder = order }, parent)
        round(holder, 6)
        mk("TextLabel", { Size = UDim2.new(1, -12, 0, 24), Position = UDim2.new(0, 6, 0, 3), BackgroundTransparency = 1, Text = text, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left }, holder)
        return holder
end

local function subBtn(parent: Frame, text: string, posX: number, width: number, color: Color3, onAct)
        local btn = mk("TextButton", { Position = UDim2.new(posX, 0, 1, -30), Size = UDim2.new(width, -6, 0, 26), BackgroundColor3 = color, Text = text, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, parent)
        round(btn, 6)
        btn.Activated:Connect(onAct)
        return btn
end

local function refreshSemai()
        for _, col in ipairs({ semaiLeft, semaiRight }) do
                for _, c in ipairs(col:GetChildren()) do
                        if c:IsA("Frame") or c:IsA("TextLabel") then
                                c:Destroy()
                        end
                end
        end
        local order = 0
        local adaHasil = false
        for _, s in ipairs(state.tas) do
                if s.kind == "hasil" then
                        adaHasil = true
                        order += 1
                        local info = CropData.byId[s.id]
                        local holder = actionBtn(semaiLeft, (info and info.nama or s.id) .. " x" .. s.count, order)
                        subBtn(holder, "Letakkan 1", 0.5, 0.5, Color3.fromRGB(46, 110, 62), function()
                                local ok, msg = Net.get("SmashAct"):InvokeServer("place", s.id)
                                toast(ok and "Meja" or "Gagal", msg)
                        end)
                end
        end
        if not adaHasil then
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "Tidak ada hasil panen di tas.", TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(150, 150, 155), LayoutOrder = 1 }, semaiLeft)
        end
        if #state.semai == 0 then
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "Meja kosong.", TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(150, 150, 155), LayoutOrder = 1 }, semaiRight)
        end
        for i, slot in ipairs(state.semai) do
                local info = CropData.byId[slot.crop]
                local cfg = info and CropData.Smash[info.rarity]
                local holder = actionBtn(semaiRight, (info and info.nama or slot.crop) .. " — pukul " .. tostring(slot.hits) .. "/" .. tostring(cfg and cfg.hits or "?"), i)
                subBtn(holder, "Pukul", 0, 0.5, Color3.fromRGB(196, 96, 48), function()
                        local ok, msg = Net.get("SmashAct"):InvokeServer("hit", i)
                        toast(ok and "Pukul" or "Gagal", msg)
                end)
                subBtn(holder, "Ambil", 0.5, 0.5, Color3.fromRGB(90, 90, 100), function()
                        local ok, msg = Net.get("SmashAct"):InvokeServer("take", i)
                        toast(ok and "Meja" or "Gagal", msg)
                end)
        end
end

local tokoPanel = makePanel("toko")
mk("TextLabel", { Size = UDim2.new(1, -16, 0, 30), Position = UDim2.new(0, 8, 0, 2), BackgroundTransparency = 1, Text = "Ambil pack benih lewat kasir atau rak berisi benih. Pack berisi 3 benih acak; toko juga membeli hasil panenmu.", TextWrapped = true, TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(200, 200, 205), TextXAlignment = Enum.TextXAlignment.Left }, tokoPanel)
local tokoBuy = mk("Frame", { Size = UDim2.new(1, -16, 0, 100), Position = UDim2.new(0, 8, 0, 38), BackgroundColor3 = Color3.fromRGB(30, 33, 40) }, tokoPanel)
round(tokoBuy, 8)
local tokoSell = mk("ScrollingFrame", { Size = UDim2.new(1, -16, 1, -160), Position = UDim2.new(0, 8, 0, 146), BackgroundColor3 = Color3.fromRGB(30, 33, 40), ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, tokoPanel)
mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, tokoSell)

local function refreshToko()
        for _, c in ipairs(tokoSell:GetChildren()) do
                if c:IsA("Frame") or c:IsA("TextLabel") then
                        c:Destroy()
                end
        end
        local order = 0
        local ada = false
        for _, s in ipairs(state.tas) do
                if s.kind == "hasil" then
                        ada = true
                        order += 1
                        local info = CropData.byId[s.id]
                        local holder = actionBtn(tokoSell, (info and info.nama or s.id) .. " x" .. s.count .. " — " .. (info and info.jual or 0) .. " Micda/unit", order)
                        subBtn(holder, "Jual 1", 0, 0.34, Color3.fromRGB(46, 110, 62), function()
                                local ok, msg = Net.get("ShopAct"):InvokeServer("sell", s.id, 1)
                                toast(ok and "Terjual" or "Gagal", msg)
                        end)
                        subBtn(holder, "Jual Semua", 0.34, 0.33, Color3.fromRGB(46, 110, 62), function()
                                local ok, msg = Net.get("ShopAct"):InvokeServer("sell", s.id)
                                toast(ok and "Terjual" or "Gagal", msg)
                        end)
                end
        end
        if not ada then
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "Tidak ada hasil panen untuk dijual.", TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(150, 150, 155), LayoutOrder = 1 }, tokoSell)
        end
end

local function buyBtn(parent: Frame, text: string, posX: number, packId: string)
        local btn = mk("TextButton", { Position = UDim2.new(posX, 6, 0, 10), Size = UDim2.new(0.5, -18, 0, 80), BackgroundColor3 = Color3.fromRGB(46, 110, 62), Text = text, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, parent)
        round(btn, 8)
        btn.Activated:Connect(function()
                local ok, msg = Net.get("ShopAct"):InvokeServer("buy", packId)
                toast(ok and "Pembelian" or "Gagal", msg)
        end)
end

buyBtn(tokoBuy, "Pack Common\n2.400 Micda\n3 benih acak", 0, "common")
buyBtn(tokoBuy, "Pack Rare\n9.000 Micda\n3 benih acak", 0.5, "rare")

local tanamPanel = makePanel("tanam")
local tamuMode = false

local tamuNotice = mk("TextLabel", { Size = UDim2.new(1, -16, 1, -16), Position = UDim2.new(0, 8, 0, 8), BackgroundTransparency = 1, Text = "Hanya pemilik dunia yang bisa memakai papan ini.", TextWrapped = true, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(230, 190, 120), Visible = false }, tanamPanel)

local tabRow = mk("Frame", { Size = UDim2.new(1, -16, 0, 38), Position = UDim2.new(0, 8, 0, 4), BackgroundTransparency = 1 }, tanamPanel)
local tabTanamBtn = mk("TextButton", { Size = UDim2.new(1 / 3, -6, 1, 0), BackgroundColor3 = Color3.fromRGB(46, 110, 62), Text = "Tanam", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, tabRow)
round(tabTanamBtn, 6)
local tabGabungBtn = mk("TextButton", { Position = UDim2.new(1 / 3, 3, 0, 0), Size = UDim2.new(1 / 3, -6, 1, 0), BackgroundColor3 = Color3.fromRGB(58, 84, 138), Text = "Combine Seed", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, tabRow)
round(tabGabungBtn, 6)
local tabStatusBtn = mk("TextButton", { Position = UDim2.new(2 / 3, 9, 0, 0), Size = UDim2.new(1 / 3, -6, 1, 0), BackgroundColor3 = Color3.fromRGB(58, 84, 138), Text = "Status", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, tabRow)
round(tabStatusBtn, 6)

local tanamBody = mk("Frame", { Size = UDim2.new(1, -16, 1, -52), Position = UDim2.new(0, 8, 0, 48), BackgroundTransparency = 1 }, tanamPanel)

local tanamTab = mk("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = true }, tanamBody)
local tanamInfo = mk("TextLabel", { Size = UDim2.new(1, -16, 0, 36), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = "", TextWrapped = true, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255, 214, 110), TextXAlignment = Enum.TextXAlignment.Left }, tanamTab)
local tanamList = mk("ScrollingFrame", { Size = UDim2.new(1, -16, 1, -206), Position = UDim2.new(0, 8, 0, 40), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, tanamTab)
mk("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, tanamList)
local jumlahBox = mk("TextBox", { Size = UDim2.new(0, 118, 0, 40), Position = UDim2.new(0, 8, 1, -92), BackgroundColor3 = Color3.fromRGB(30, 33, 40), Text = "", PlaceholderText = "Jumlah", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), ClearTextOnFocus = true }, tanamTab)
round(jumlahBox, 6)
local selectedSeed: string? = nil

local function presetBtn(posX: number, width: number, teks: string, nilai: number?)
        local btn = mk("TextButton", { Position = UDim2.new(posX, 0, 1, -92), Size = UDim2.new(width, -4, 0, 40), BackgroundColor3 = Color3.fromRGB(58, 84, 138), Text = teks, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, tanamTab)
        round(btn, 6)
        btn.Activated:Connect(function()
                if nilai then
                        jumlahBox.Text = tostring(nilai)
                else
                        for _, s in ipairs(state.tas) do
                                if s.kind == "benih" and s.id == selectedSeed then
                                        jumlahBox.Text = tostring(s.count)
                                        break
                                end
                        end
                end
        end)
        return btn
end
presetBtn(0.22, 0.1, "10", 10)
presetBtn(0.32, 0.1, "50", 50)
presetBtn(0.42, 0.1, "100", 100)
presetBtn(0.52, 0.1, "250", 250)
presetBtn(0.62, 0.1, "Maks", nil)

local mulaiBtn = mk("TextButton", { Position = UDim2.new(0.72, 0, 1, -92), Size = UDim2.new(0.28, -8, 0, 40), BackgroundColor3 = Color3.fromRGB(46, 110, 62), Text = "Mulai Tanam", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, tanamTab)
round(mulaiBtn, 6)
local tanamFeedback = mk("TextLabel", { Size = UDim2.new(1, -16, 0, 38), Position = UDim2.new(0, 8, 1, -46), BackgroundTransparency = 1, Text = "", TextWrapped = true, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left }, tanamTab)

local soalView = mk("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false }, tanamBody)
local soalNomor = mk("TextLabel", { Size = UDim2.new(1, -16, 0, 28), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = "", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255, 214, 110), TextXAlignment = Enum.TextXAlignment.Left }, soalView)
local soalTeks = mk("TextLabel", { Size = UDim2.new(1, -16, 0, 78), Position = UDim2.new(0, 8, 0, 34), BackgroundColor3 = Color3.fromRGB(30, 33, 40), Text = "?", TextScaled = true, Font = Enum.Font.GothamBlack, TextColor3 = Color3.new(1, 1, 1) }, soalView)
round(soalTeks, 10)
local soalJawab = mk("TextBox", { Size = UDim2.new(0, 240, 0, 46), Position = UDim2.new(0.5, -120, 0, 122), BackgroundColor3 = Color3.fromRGB(40, 44, 54), Text = "", PlaceholderText = "Tulis jawaban angka", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), ClearTextOnFocus = true }, soalView)
round(soalJawab, 8)
local soalBtn = mk("TextButton", { Size = UDim2.new(0, 240, 0, 44), Position = UDim2.new(0.5, -120, 0, 176), BackgroundColor3 = Color3.fromRGB(46, 110, 62), Text = "Jawab", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, soalView)
round(soalBtn, 8)
local soalFeedback = mk("TextLabel", { Size = UDim2.new(1, -16, 0, 42), Position = UDim2.new(0, 8, 0, 228), BackgroundTransparency = 1, Text = "", TextWrapped = true, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left }, soalView)
local batalBtn = mk("TextButton", { Size = UDim2.new(1, -16, 0, 40), Position = UDim2.new(0, 8, 1, -44), BackgroundColor3 = Color3.fromRGB(140, 60, 56), Text = "Batalkan Sesi Tanam", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, soalView)
round(batalBtn, 6)

local gabungTab = mk("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false }, tanamBody)
mk("TextLabel", { Size = UDim2.new(0.5, -14, 0, 26), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = "Benih A", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255, 214, 110), TextXAlignment = Enum.TextXAlignment.Left }, gabungTab)
mk("TextLabel", { Size = UDim2.new(0.5, -14, 0, 26), Position = UDim2.new(0.5, 6, 0, 0), BackgroundTransparency = 1, Text = "Benih B", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255, 214, 110), TextXAlignment = Enum.TextXAlignment.Left }, gabungTab)
local slotAList = mk("ScrollingFrame", { Size = UDim2.new(0.5, -14, 1, -168), Position = UDim2.new(0, 8, 0, 30), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, gabungTab)
mk("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, slotAList)
local slotBList = mk("ScrollingFrame", { Size = UDim2.new(0.5, -14, 1, -168), Position = UDim2.new(0.5, 6, 0, 30), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, gabungTab)
mk("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, slotBList)
local slotA: string? = nil
local slotB: string? = nil
local gabungBtn = mk("TextButton", { Size = UDim2.new(0, 240, 0, 44), Position = UDim2.new(0.5, -120, 1, -118), BackgroundColor3 = Color3.fromRGB(46, 110, 62), Text = "Gabung", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, gabungTab)
round(gabungBtn, 8)
local gabungFeedback = mk("TextLabel", { Size = UDim2.new(1, -16, 0, 56), Position = UDim2.new(0, 8, 1, -58), BackgroundTransparency = 1, Text = "", TextWrapped = true, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left }, gabungTab)

local statusTab = mk("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false }, tanamBody)
local statusSummary = mk("TextLabel", { Size = UDim2.new(1, -146, 0, 30), Position = UDim2.new(0, 8, 0, 2), BackgroundTransparency = 1, Text = "", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255, 214, 110), TextXAlignment = Enum.TextXAlignment.Left }, statusTab)
local statusRefresh = mk("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 2), Size = UDim2.new(0, 130, 0, 30), BackgroundColor3 = Color3.fromRGB(58, 84, 138), Text = "Perbarui", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, statusTab)
round(statusRefresh, 6)
local statusList = mk("ScrollingFrame", { Size = UDim2.new(1, -16, 1, -44), Position = UDim2.new(0, 8, 0, 38), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, statusTab)
mk("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, statusList)

local function muatStatus()
        task.spawn(function()
                local ok, res = Net.get("TanamAct"):InvokeServer("status")
                if not ok or type(res) ~= "table" then
                        return
                end
                statusSummary.Text = "Tertanam " .. tostring(res.tertanamTotal or 0) .. "/" .. tostring(res.plotTotal or 500)
                for _, c in ipairs(statusList:GetChildren()) do
                        if c:IsA("Frame") or c:IsA("TextLabel") then
                                c:Destroy()
                        end
                end
                local daftar = res.status or {}
                if #daftar == 0 then
                        mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "Belum ada tanaman di lahan.", TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(150, 150, 155), LayoutOrder = 1 }, statusList)
                        return
                end
                local order = 0
                for _, row in ipairs(daftar) do
                        order += 1
                        local holder = mk("Frame", { Size = UDim2.new(1, -8, 0, 44), BackgroundColor3 = Color3.fromRGB(34, 38, 46), LayoutOrder = order }, statusList)
                        round(holder, 6)
                        mk("TextLabel", { Size = UDim2.new(0.34, -8, 1, -8), Position = UDim2.new(0, 8, 0, 4), BackgroundTransparency = 1, Text = row.nama or row.id, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left }, holder)
                        mk("TextLabel", { Size = UDim2.new(0.33, -8, 1, -8), Position = UDim2.new(0.34, 8, 0, 4), BackgroundTransparency = 1, Text = "Siap Panen: " .. tostring(row.siap or 0), TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(150, 200, 130), TextXAlignment = Enum.TextXAlignment.Left }, holder)
                        mk("TextLabel", { Size = UDim2.new(0.33, -8, 1, -8), Position = UDim2.new(0.67, 8, 0, 4), BackgroundTransparency = 1, Text = "Masih Tumbuh: " .. tostring(row.tumbuh or 0), TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(230, 170, 120), TextXAlignment = Enum.TextXAlignment.Left }, holder)
                end
        end)
end

local tabAktif = "tanam"
local function refreshGabung()
        for _, col in ipairs({ slotAList, slotBList }) do
                for _, c in ipairs(col:GetChildren()) do
                        if c:IsA("Frame") then
                                c:Destroy()
                        end
                end
        end
        local order = 0
        for _, s in ipairs(state.tas) do
                if s.kind == "benih" then
                        order += 1
                        local info = CropData.byId[s.id]
                        local nama = info and info.nama or s.id
                        local rowA = mk("Frame", { Size = UDim2.new(1, -8, 0, 46), BackgroundColor3 = s.id == slotA and Color3.fromRGB(52, 78, 122) or Color3.fromRGB(34, 38, 46), LayoutOrder = order }, slotAList)
                        round(rowA, 6)
                        mk("TextLabel", { Size = UDim2.new(0.5, -8, 1, -8), Position = UDim2.new(0, 8, 0, 4), BackgroundTransparency = 1, Text = nama .. " x" .. s.count, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left }, rowA)
                        local pilihA = mk("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -6, 0, 4), Size = UDim2.new(0.24, -6, 1, -8), BackgroundColor3 = Color3.fromRGB(58, 84, 138), Text = "Pilih", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, rowA)
                        round(pilihA, 6)
                        pilihA.Activated:Connect(function()
                                slotA = s.id
                                refreshGabung()
                        end)
                        local rowB = mk("Frame", { Size = UDim2.new(1, -8, 0, 46), BackgroundColor3 = s.id == slotB and Color3.fromRGB(52, 78, 122) or Color3.fromRGB(34, 38, 46), LayoutOrder = order }, slotBList)
                        round(rowB, 6)
                        mk("TextLabel", { Size = UDim2.new(0.5, -8, 1, -8), Position = UDim2.new(0.5, 6, 0, 4), BackgroundTransparency = 1, Text = nama .. " x" .. s.count, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left }, rowB)
                        local pilihB = mk("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -6, 0, 4), Size = UDim2.new(0.24, -6, 1, -8), BackgroundColor3 = Color3.fromRGB(58, 84, 138), Text = "Pilih", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, rowB)
                        round(pilihB, 6)
                        pilihB.Activated:Connect(function()
                                slotB = s.id
                                refreshGabung()
                        end)
                end
        end
        if order == 0 then
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "Tidak ada benih di tas.", TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(150, 150, 155), LayoutOrder = 1 }, slotAList)
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "Tidak ada benih di tas.", TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(150, 150, 155), LayoutOrder = 1 }, slotBList)
        end
end
local function setTab(nama: string)
        tabAktif = nama
        tanamTab.Visible = nama == "tanam"
        gabungTab.Visible = nama == "gabung"
        statusTab.Visible = nama == "status"
        local aktif = Color3.fromRGB(46, 110, 62)
        local non = Color3.fromRGB(58, 84, 138)
        tabTanamBtn.BackgroundColor3 = nama == "tanam" and aktif or non
        tabGabungBtn.BackgroundColor3 = nama == "gabung" and aktif or non
        tabStatusBtn.BackgroundColor3 = nama == "status" and aktif or non
        if nama == "status" then
                muatStatus()
        elseif nama == "gabung" then
                refreshGabung()
        end
end

tabTanamBtn.Activated:Connect(function()
        setTab("tanam")
end)
tabGabungBtn.Activated:Connect(function()
        setTab("gabung")
end)
tabStatusBtn.Activated:Connect(function()
        setTab("status")
end)

local function refreshTanam()
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
        if aktif then
                tanamInfo.Text = "Sesi " .. tostring(t.nama) .. ": tertanam " .. tostring(t.tertanam) .. "/" .. tostring(t.jumlah)
        else
                tanamInfo.Text = "Pilih benih, tentukan jumlah, lalu Mulai Tanam."
                tanamFeedback.Text = ""
        end
        for _, c in ipairs(tanamList:GetChildren()) do
                if c:IsA("Frame") then
                        c:Destroy()
                end
        end
        local order = 0
        for _, s in ipairs(state.tas) do
                if s.kind == "benih" then
                        order += 1
                        local info = CropData.byId[s.id]
                        local row = mk("Frame", { Size = UDim2.new(1, -8, 0, 46), BackgroundColor3 = s.id == selectedSeed and Color3.fromRGB(52, 78, 122) or Color3.fromRGB(34, 38, 46), LayoutOrder = order }, tanamList)
                        round(row, 6)
                        mk("TextLabel", { Size = UDim2.new(0.5, -8, 1, -8), Position = UDim2.new(0, 8, 0, 4), BackgroundTransparency = 1, Text = (info and info.nama or s.id) .. " x" .. s.count, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left }, row)
                        local pilih = mk("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -6, 0, 4), Size = UDim2.new(0.24, -6, 1, -8), BackgroundColor3 = Color3.fromRGB(58, 84, 138), Text = "Pilih", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, row)
                        round(pilih, 6)
                        pilih.Activated:Connect(function()
                                selectedSeed = s.id
                                refreshTanam()
                        end)
                end
        end
        if order == 0 then
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "Tidak ada benih di tas. Beli pack benih di Toko Benih, Pusat Kota.", TextWrapped = true, TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(230, 170, 120), LayoutOrder = 1 }, tanamList)
        end
        if aktif and t.soal then
                soalNomor.Text = "Soal " .. tostring(t.soal.nomor) .. " dari " .. tostring(t.totalSoal) .. " — tertanam " .. tostring(t.tertanam) .. "/" .. tostring(t.jumlah)
                soalTeks.Text = t.soal.teks
        end
end

mulaiBtn.Activated:Connect(function()
        if not selectedSeed then
                tanamFeedback.TextColor3 = Color3.fromRGB(240, 130, 110)
                tanamFeedback.Text = "Pilih benih dulu di daftar."
                return
        end
        local jumlah = tonumber(jumlahBox.Text) or 0
        local ok, msg = Net.get("TanamAct"):InvokeServer("start", selectedSeed, jumlah)
        tanamFeedback.TextColor3 = ok and Color3.fromRGB(150, 200, 130) or Color3.fromRGB(240, 130, 110)
        tanamFeedback.Text = msg
        if ok then
                refreshTanam()
        end
end)

soalBtn.Activated:Connect(function()
        local n = tonumber(soalJawab.Text)
        if not n then
                soalFeedback.TextColor3 = Color3.fromRGB(240, 130, 110)
                soalFeedback.Text = "Masukkan angka dulu."
                return
        end
        local ok, msg = Net.get("TanamAct"):InvokeServer("jawab", n)
        soalFeedback.TextColor3 = ok and Color3.fromRGB(150, 200, 130) or Color3.fromRGB(240, 130, 110)
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
                gabungFeedback.TextColor3 = Color3.fromRGB(240, 130, 110)
                gabungFeedback.Text = "Pilih benih untuk kedua slot."
                return
        end
        local ok, msg = Net.get("TanamAct"):InvokeServer("gabung", slotA, slotB)
        gabungFeedback.TextColor3 = ok and Color3.fromRGB(150, 200, 130) or Color3.fromRGB(240, 130, 110)
        gabungFeedback.Text = msg
        if ok then
                refreshGabung()
        end
end)

statusRefresh.Activated:Connect(function()
        muatStatus()
end)

local gudangPanel = makePanel("gudang")
local gudangTampungan = mk("TextLabel", { Size = UDim2.new(1, -16, 0, 34), Position = UDim2.new(0, 8, 0, 4), BackgroundTransparency = 1, Text = "", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255, 214, 110), TextXAlignment = Enum.TextXAlignment.Left }, gudangPanel)
mk("TextLabel", { Size = UDim2.new(1, -16, 0, 24), Position = UDim2.new(0, 8, 0, 40), BackgroundTransparency = 1, Text = "Kiri: hasil panen di tas — setor ke gudang. Kanan: isi gudang — ambil kembali ke tas.", TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(170, 170, 178), TextXAlignment = Enum.TextXAlignment.Left }, gudangPanel)
local gudangLeft = mk("ScrollingFrame", { Size = UDim2.new(0.5, -14, 1, -102), Position = UDim2.new(0, 8, 0, 70), BackgroundColor3 = Color3.fromRGB(30, 33, 40), ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, gudangPanel)
local gudangRight = mk("ScrollingFrame", { Size = UDim2.new(0.5, -14, 1, -102), Position = UDim2.new(0.5, 6, 0, 70), BackgroundColor3 = Color3.fromRGB(30, 33, 40), ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, gudangPanel)
mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, gudangLeft)
mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, gudangRight)

local function refreshGudang()
        local g = state.gudang
        if not g then
                return
        end
        gudangTampungan.Text = "Tampungan gudang: " .. tostring(g.terpakai) .. "/" .. tostring(g.maks) .. " (sisa " .. tostring(g.maks - g.terpakai) .. ") — satu setor 1-250 buah = 1 tampungan."
        for _, col in ipairs({ gudangLeft, gudangRight }) do
                for _, c in ipairs(col:GetChildren()) do
                        if c:IsA("Frame") or c:IsA("TextLabel") then
                                c:Destroy()
                        end
                end
        end
        local order = 0
        for _, s in ipairs(state.tas) do
                if s.kind == "hasil" then
                        order += 1
                        local info = CropData.byId[s.id]
                        local holder = actionBtn(gudangLeft, (info and info.nama or s.id) .. " x" .. s.count, order)
                        subBtn(holder, "Setor 250", 0, 0.5, Color3.fromRGB(46, 110, 62), function()
                                local ok, msg = Net.get("GudangAct"):InvokeServer("simpan", s.id, 250)
                                toast(ok and "Gudang" or "Gagal", msg)
                        end)
                        subBtn(holder, "Setor Semua", 0.5, 0.5, Color3.fromRGB(58, 84, 138), function()
                                local ok, msg = Net.get("GudangAct"):InvokeServer("simpan", s.id)
                                toast(ok and "Gudang" or "Gagal", msg)
                        end)
                end
        end
        if order == 0 then
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "Tidak ada hasil panen di tas untuk disimpan.", TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(150, 150, 155), LayoutOrder = 1 }, gudangLeft)
        end
        local order2 = 0
        for _, slot in ipairs(g.slots or {}) do
                order2 += 1
                local info = CropData.byId[slot.id]
                local holder = actionBtn(gudangRight, "Slot " .. slot.i .. ": " .. (info and info.nama or slot.id) .. " x" .. slot.count, order2)
                subBtn(holder, "Ambil Semua", 0, 0.5, Color3.fromRGB(46, 110, 62), function()
                        local ok, msg = Net.get("GudangAct"):InvokeServer("ambil", slot.i)
                        toast(ok and "Gudang" or "Gagal", msg)
                end)
                subBtn(holder, "Ambil 100", 0.5, 0.5, Color3.fromRGB(58, 84, 138), function()
                        local ok, msg = Net.get("GudangAct"):InvokeServer("ambil", slot.i, 100)
                        toast(ok and "Gudang" or "Gagal", msg)
                end)
        end
        if order2 == 0 then
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "Gudang masih kosong.", TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(150, 150, 155), LayoutOrder = 1 }, gudangRight)
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

local camera = Workspace.CurrentCamera
local punchTarget: number? = nil

punchBtn.Activated:Connect(function()
        task.spawn(function()
                local awal = camera.FieldOfView
                camera.FieldOfView = awal + 6
                task.wait(0.09)
                camera.FieldOfView = awal
        end)
        if punchTarget == nil then
                return
        end
        Net.get("PlotAct"):InvokeServer(punchTarget, "punch")
end)

task.spawn(function()
        while true do
                task.wait(0.2)
                local target = nil
                if state.zone == "dunia" and state.lahan then
                        local char = player.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
                        local grid = Workspace:FindFirstChild("Dunia")
                        local folder = grid and grid:FindFirstChild("PlotGrid_" .. state.lahan, true)
                        if root and folder then
                                local best = 26
                                for _, m in ipairs(folder:GetChildren()) do
                                        if m:IsA("Model") and string.sub(m.Name, 1, 8) == "Tanaman_" then
                                                local d = (m:GetPivot().Position - root.Position).Magnitude
                                                if d < best then
                                                        best = d
                                                        target = m:GetAttribute("PlotIdx")
                                                end
                                        end
                                end
                        end
                end
                punchTarget = target
        end
end)

Net.get("Sync").OnClientEvent:Connect(function(payload)
        state.micda = payload.micda
        state.tas = payload.tas or {}
        micdaLabel.Text = fmt(state.micda) .. " Micda"
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
                refreshTanam()
                if tabAktif == "gabung" then
                        refreshGabung()
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
                refreshTanam()
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
                refreshTanam()
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
                micdaLabel.Text = fmt(state.micda) .. " Micda"
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
