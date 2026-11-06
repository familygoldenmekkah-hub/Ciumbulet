local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local CropData = require(ReplicatedStorage.Shared.CropData)
local Net = require(ReplicatedStorage.Remotes)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local state = {
        micda = 0,
        tas = {},
        lahan = nil,
        plot = {},
        semai = {},
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
local RARITY_COLOR = {
        common = Color3.fromRGB(150, 200, 130),
        rare = Color3.fromRGB(120, 170, 235),
        epic = Color3.fromRGB(200, 140, 240),
}
local PANEL_TITLES = {
        tas = "Tas (50 slot, maks 250 per slot)",
        combine = "Gabung Benih",
        plot = "Plot Tanam",
        semai = "Semai Panen",
        toko = "Toko Benih",
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

local tasBtn = mk("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 0), Size = UDim2.new(0, 150, 0, 44), BackgroundColor3 = Color3.fromRGB(46, 110, 62), Text = "Tas", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, hud)
round(tasBtn)

local toastHolder = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 66), Size = UDim2.new(0, 470, 0, 220), BackgroundTransparency = 1 }, gui)
mk("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center }, toastHolder)

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
local gabungBtn = mk("TextButton", { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -8, 1, -6), Size = UDim2.new(0, 190, 0, 34), BackgroundColor3 = Color3.fromRGB(46, 110, 62), Text = "Gabung Benih", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, tasPanel)
round(gabungBtn)

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

local combinePanel = makePanel("combine")
mk("TextLabel", { Size = UDim2.new(1, -16, 0, 44), Position = UDim2.new(0, 8, 0, 4), BackgroundTransparency = 1, Text = "Pilih 2 benih dari tas. Hanya resep tertentu yang valid, salah resep tidak mengurangi benih.", TextWrapped = true, TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(200, 200, 205), TextXAlignment = Enum.TextXAlignment.Left }, combinePanel)
local colA = mk("ScrollingFrame", { Size = UDim2.new(0.5, -14, 1, -140), Position = UDim2.new(0, 8, 0, 52), BackgroundColor3 = Color3.fromRGB(30, 33, 40), ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, combinePanel)
local colB = mk("ScrollingFrame", { Size = UDim2.new(0.5, -14, 1, -140), Position = UDim2.new(0.5, 6, 0, 52), BackgroundColor3 = Color3.fromRGB(30, 33, 40), ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, combinePanel)
for _, col in ipairs({ colA, colB }) do
        mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, col)
end
local selA: string? = nil
local selB: string? = nil
local selALabel = mk("TextLabel", { Size = UDim2.new(0.5, -14, 0, 30), Position = UDim2.new(0, 8, 1, -78), BackgroundTransparency = 1, Text = "Benih A: -", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255, 214, 110), TextXAlignment = Enum.TextXAlignment.Left }, combinePanel)
local selBLabel = mk("TextLabel", { Size = UDim2.new(0.5, -14, 0, 30), Position = UDim2.new(0.5, 6, 1, -78), BackgroundTransparency = 1, Text = "Benih B: -", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255, 214, 110), TextXAlignment = Enum.TextXAlignment.Left }, combinePanel)
local combineBtn = mk("TextButton", { Size = UDim2.new(1, -16, 0, 40), Position = UDim2.new(0, 8, 1, -34), BackgroundColor3 = Color3.fromRGB(46, 110, 62), Text = "Gabung Sekarang", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, combinePanel)
round(combineBtn)

local function seedList(): { any }
        local out = {}
        for _, s in ipairs(state.tas) do
                if s.kind == "benih" then
                        table.insert(out, s)
                end
        end
        return out
end

local function buildSeedColumn(col: ScrollingFrame, isA: boolean)
        for _, c in ipairs(col:GetChildren()) do
                if c:IsA("TextButton") then
                        c:Destroy()
                end
        end
        local list = seedList()
        for order, s in ipairs(list) do
                local info = CropData.byId[s.id]
                local btn = mk("TextButton", { Size = UDim2.new(1, -8, 0, 34), BackgroundColor3 = Color3.fromRGB(40, 44, 54), Text = (info and info.nama or s.id) .. " x" .. s.count, TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = RARITY_COLOR[info.rarity] or Color3.new(1, 1, 1), LayoutOrder = order }, col)
                round(btn, 6)
                btn.Activated:Connect(function()
                        if isA then
                                selA = s.id
                                selALabel.Text = "Benih A: " .. (info and info.nama or s.id)
                        else
                                selB = s.id
                                selBLabel.Text = "Benih B: " .. (info and info.nama or s.id)
                        end
                end)
        end
        if #list == 0 then
                mk("TextLabel", { Size = UDim2.new(1, -8, 0, 34), BackgroundTransparency = 1, Text = "Tidak ada benih", TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(150, 150, 155), LayoutOrder = 1 }, col)
        end
end

local function refreshCombine()
        selALabel.Text = "Benih A: -"
        selBLabel.Text = "Benih B: -"
        selA = nil
        selB = nil
        buildSeedColumn(colA, true)
        buildSeedColumn(colB, false)
end

combineBtn.Activated:Connect(function()
        if not selA or not selB then
                toast("Gabung Benih", "Pilih dua benih dulu.")
                return
        end
        local ok, msg = Net.get("CombineAct"):InvokeServer(selA, selB)
        toast(ok and "Gabung Berhasil" or "Gabung Gagal", msg)
        if ok then
                closePanel()
        end
end)

local plotPanel = makePanel("plot")
local plotInfo = mk("TextLabel", { Size = UDim2.new(1, -16, 0, 64), Position = UDim2.new(0, 8, 0, 6), BackgroundTransparency = 1, Text = "", TextWrapped = true, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left }, plotPanel)
local plotActions = mk("ScrollingFrame", { Size = UDim2.new(1, -16, 1, -86), Position = UDim2.new(0, 8, 0, 76), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, plotPanel)
mk("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, plotActions)

local plotCtx = { lahan = nil, idx = nil }
local countdownToken = 0

local function refreshPlotPanel()
        countdownToken += 1
        local token = countdownToken
        for _, c in ipairs(plotActions:GetChildren()) do
                if c:IsA("TextButton") or c:IsA("TextLabel") then
                        c:Destroy()
                end
        end
        local lahan, idx = plotCtx.lahan, plotCtx.idx
        if lahan == nil or idx == nil then
                return
        end
        local key = tostring(lahan) .. "_" .. tostring(idx)
        local rec = state.plot[key]
        local st = rec and rec.st or "kosong"
        local info = rec and rec.crop and CropData.byId[rec.crop]
        local nama = info and info.nama or "-"
        if state.lahan ~= lahan then
                plotInfo.Text = "Lahan #" .. lahan .. ", plot #" .. (idx + 1) .. " (" .. st .. ") " .. nama .. "\nIni lahan pemain lain. Pengunjung tidak bisa mengubah isi."
                return
        end
        if st == "kosong" then
                plotInfo.Text = "Lahanmu, plot #" .. (idx + 1) .. " — kosong. Pilih benih untuk menanam:"
                local seeds = seedList()
                if #seeds == 0 then
                        mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "Tidak ada benih di tas. Beli pack benih di Toko Benih, Pusat Kota.", TextWrapped = true, TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(230, 170, 120), LayoutOrder = 1 }, plotActions)
                        return
                end
                for order, s in ipairs(seeds) do
                        local sinfo = CropData.byId[s.id]
                        local btn = mk("TextButton", { Size = UDim2.new(1, -8, 0, 40), BackgroundColor3 = Color3.fromRGB(46, 110, 62), Text = "Tanam " .. (sinfo and sinfo.nama or s.id) .. " x" .. s.count, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), LayoutOrder = order }, plotActions)
                        round(btn, 6)
                        btn.Activated:Connect(function()
                                local ok, msg = Net.get("PlotAct"):InvokeServer(idx, "plant", s.id)
                                toast(ok and "Menanam" or "Gagal Tanam", msg)
                                if ok then
                                        closePanel()
                                end
                        end)
                end
        elseif st == "tumbuh" then
                plotInfo.Text = nama .. " sedang tumbuh (3 detik)."
                local label = mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "...", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255, 214, 110), LayoutOrder = 1 }, plotActions)
                task.spawn(function()
                        while token == countdownToken and currentPanel == "plot" do
                                local r = state.plot[key]
                                if not r or r.st ~= "tumbuh" then
                                        break
                                end
                                local left = math.max(0, (r.readyAt or 0) - Workspace:GetServerTimeNow())
                                label.Text = string.format("Siap panen dalam %.1f detik", left)
                                task.wait(0.2)
                        end
                end)
        else
                plotInfo.Text = nama .. " siap panen!"
                local btn = mk("TextButton", { Size = UDim2.new(1, -8, 0, 46), BackgroundColor3 = Color3.fromRGB(196, 148, 48), Text = "Panen Sekarang", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), LayoutOrder = 1 }, plotActions)
                round(btn, 6)
                btn.Activated:Connect(function()
                        local ok, msg = Net.get("PlotAct"):InvokeServer(idx, "harvest")
                        toast(ok and "Panen" or "Gagal Panen", msg)
                        if ok then
                                closePanel()
                        end
                end)
        end
end

local semaiPanel = makePanel("semai")
mk("TextLabel", { Size = UDim2.new(1, -16, 0, 30), Position = UDim2.new(0, 8, 0, 2), BackgroundTransparency = 1, Text = "Letakkan hasil panen di meja, lalu pukul hingga hancur untuk Micda + peluang benih & blok panen.", TextWrapped = true, TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(200, 200, 205), TextXAlignment = Enum.TextXAlignment.Left }, semaiPanel)
local semaiLeft = mk("ScrollingFrame", { Size = UDim2.new(0.5, -14, 1, -80), Position = UDim2.new(0, 8, 0, 44), BackgroundColor3 = Color3.fromRGB(30, 33, 40), ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, semaiPanel)
local semaiRight = mk("ScrollingFrame", { Size = UDim2.new(0.5, -14, 1, -80), Position = UDim2.new(0.5, 6, 0, 44), BackgroundColor3 = Color3.fromRGB(30, 33, 40), ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, semaiPanel)
mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, semaiLeft)
mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, semaiRight)

local function actionBtn(parent, text: string, color: Color3, order: number, onAct)
        local holder = mk("Frame", { Size = UDim2.new(1, -8, 0, 64), BackgroundColor3 = Color3.fromRGB(38, 42, 52), LayoutOrder = order }, parent)
        round(holder, 6)
        mk("TextLabel", { Size = UDim2.new(1, -12, 0, 24), Position = UDim2.new(0, 6, 0, 3), BackgroundTransparency = 1, Text = text, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left }, holder)
        return holder
end

local function subBtn(parent: Frame, text: string, posX: number, width: number, color: Color3, onAct)
        local btn = mk("TextButton", { Position = UDim2.new(posX, 0, 1, -30), Size = UDim2.new(width, -6, 0, 26), BackgroundColor3 = color, Text = text, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, parent)
        round(btn, 6)
        btn.Activated:Connect(onAct)
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
                        local holder = actionBtn(semaiLeft, (info and info.nama or s.id) .. " x" .. s.count, Color3.new(1, 1, 1), order, function() end)
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
                local holder = actionBtn(semaiRight, (info and info.nama or slot.crop) .. " — pukul " .. tostring(slot.hits) .. "/" .. tostring(cfg and cfg.hits or "?"), RARITY_COLOR[info and info.rarity] or Color3.new(1, 1, 1), i, function() end)
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
mk("TextLabel", { Size = UDim2.new(1, -16, 0, 30), Position = UDim2.new(0, 8, 0, 2), BackgroundTransparency = 1, Text = "Pack berisi 3 benih acak sesuai kategori. Toko juga membeli hasil panenmu.", TextWrapped = true, TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(200, 200, 205), TextXAlignment = Enum.TextXAlignment.Left }, tokoPanel)
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
                        local holder = actionBtn(tokoSell, (info and info.nama or s.id) .. " x" .. s.count .. " — " .. (info and info.jual or 0) .. " Micda/unit", RARITY_COLOR[info and info.rarity] or Color3.new(1, 1, 1), order, function() end)
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

tasBtn.Activated:Connect(function()
        if currentPanel == "tas" then
                closePanel()
                return
        end
        openPanel("tas")
        refreshTas()
end)

gabungBtn.Activated:Connect(function()
        openPanel("combine")
        refreshCombine()
end)

local camera = Workspace.CurrentCamera
local function onTap(inputPos: Vector2)
        if dim.Visible then
                return
        end
        local ray = camera:ViewportPointToRay(inputPos.X, inputPos.Y)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local char = player.Character
        params.FilterDescendantsInstances = char and { char } or {}
        local result = Workspace:Raycast(ray.Origin, ray.Direction * 400, params)
        if result and result.Instance then
                local plotIdx = result.Instance:GetAttribute("PlotIdx")
                local lahanIdx = result.Instance:GetAttribute("LahanIdx")
                if plotIdx ~= nil and lahanIdx ~= nil then
                        plotCtx = { lahan = lahanIdx, idx = plotIdx }
                        openPanel("plot")
                        refreshPlotPanel()
                end
        end
end

UserInputService.InputBegan:Connect(function(input, processed)
        if processed then
                return
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                onTap(Vector2.new(input.Position.X, input.Position.Y))
        end
end)

Net.get("Sync").OnClientEvent:Connect(function(payload)
        state.micda = payload.micda
        state.tas = payload.tas or {}
        micdaLabel.Text = fmt(state.micda) .. " Micda"
        refreshTas()
        if currentPanel == "combine" then
                refreshCombine()
        elseif currentPanel == "semai" then
                refreshSemai()
        elseif currentPanel == "toko" then
                refreshToko()
        end
end)

Net.get("Notify").OnClientEvent:Connect(function(title, msg)
        toast(tostring(title), tostring(msg))
end)

Net.get("PlotSync").OnClientEvent:Connect(function(p)
        state.plot[tostring(p.lahan) .. "_" .. tostring(p.idx)] = { st = p.st, crop = p.crop, readyAt = p.readyAt }
        if currentPanel == "plot" and plotCtx.lahan == p.lahan and plotCtx.idx == p.idx then
                refreshPlotPanel()
        end
end)

Net.get("SmashSync").OnClientEvent:Connect(function(p)
        if p.lahan == state.lahan then
                state.semai = p.slots or {}
                if currentPanel == "semai" then
                        refreshSemai()
                end
        end
end)

Net.get("OpenPanel").OnClientEvent:Connect(function(name)
        if name == "semai" then
                openPanel("semai")
                refreshSemai()
        elseif name == "toko" then
                openPanel("toko")
                refreshToko()
        end
end)

task.spawn(function()
        local st = Net.get("GetState"):InvokeServer()
        if st then
                state.micda = st.micda or 0
                state.tas = st.tas or {}
                state.lahan = st.lahan
                micdaLabel.Text = fmt(state.micda) .. " Micda"
                refreshTas()
        end
end)

print("[AKIOMIDA] UI siap.")
