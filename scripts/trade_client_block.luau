do
-- ================== TRADE ANTAR PEMAIN ==================
-- Alur: ketuk karakter pemain lain -> obeng muncul di atas kepalanya ->
-- ketuk obeng -> popup "Trade dengan (nama)?" Ya/Tidak -> server membuat
-- sesi -> Trade Window (4 slot item + 1 slot Micda, realtime) -> Accept
-- kedua sisi -> dialog Konfirmasi (Batal/Konfirmasi saja) -> eksekusi atomik.

local TradeLogic = require(ReplicatedStorage.Shared.TradeLogic)
local UserInputService = game:GetService("UserInputService")

local obengGui: BillboardGui? = nil
local obengTarget: Player? = nil
local obengSampai: number? = nil
local tradeToken: string? = nil
local tanyaLokalTarget: Player? = nil
local tanyaHingga: number? = nil
local bukaTanyaTrade: ((Player) -> ())? = nil

local function namaOf(p: Player): string
        return p.DisplayName ~= "" and p.DisplayName or p.Name
end

local function namaItem(kind: string, id: string): string
        local info = CropData.byId[id]
        if not info then
                return id
        end
        if kind == "benih" then
                return "Benih " .. info.nama
        end
        return info.nama
end

-- ===== POPUP PERMINTAAN TRADE =====

local tradeTanyaDim = mk("Frame", { Name = "TradeTanya", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, Visible = false, Active = true, ZIndex = 36 }, gui)
local tradeTanya = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0.88, 0, 0, 178), BackgroundColor3 = warna(UIStyle.Latar), Active = true, ZIndex = 37 }, tradeTanyaDim)
round(tradeTanya, 12)
mk("UISizeConstraint", { MinSize = Vector2.new(280, 170), MaxSize = Vector2.new(430, 240) }, tradeTanya)
local tanyaJudul = mk("TextLabel", { Size = UDim2.new(1, -24, 0, 26), Position = UDim2.new(0, 12, 0, 12), BackgroundTransparency = 1, Text = "Permintaan Trade", TextSize = UIStyle.UkuranJudul, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 38 }, tradeTanya)
local tanyaNama = mk("TextLabel", { Size = UDim2.new(1, -24, 0, 40), Position = UDim2.new(0, 12, 0, 44), BackgroundTransparency = 1, Text = "Trade dengan ...?", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Aksen), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, ZIndex = 38 }, tradeTanya)
local tanyaInfo = mk("TextLabel", { Size = UDim2.new(1, -24, 0, 34), Position = UDim2.new(0, 12, 0, 88), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, ZIndex = 38 }, tradeTanya)
local tanyaYa = mk("TextButton", { Size = UDim2.new(0.5, -9, 0, 44), Position = UDim2.new(0, 12, 1, -56), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Ya", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1), ZIndex = 38 }, tradeTanya)
round(tanyaYa, UIStyle.SudutKecil)
local tanyaTidak = mk("TextButton", { Size = UDim2.new(0.5, -9, 0, 44), Position = UDim2.new(0.5, 9, 1, -56), BackgroundColor3 = warna(UIStyle.Merah), Text = "Tidak", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1), ZIndex = 38 }, tradeTanya)
round(tanyaTidak, UIStyle.SudutKecil)

local function sembunyiTanya()
        tradeToken = nil
        tanyaLokalTarget = nil
        tanyaHingga = nil
        tradeTanyaDim.Visible = false
end

tanyaTidak.Activated:Connect(function()
        local token = tradeToken
        sembunyiTanya()
        if token then
                task.spawn(function()
                        pcall(function()
                                Net.get("TradeAct"):InvokeServer("tolak", token)
                        end)
                end)
        end
end)

tanyaYa.Activated:Connect(function()
        local token = tradeToken
        local target = tanyaLokalTarget
        sembunyiTanya()
        task.spawn(function()
                if token then
                        local ok, msg = false, ""
                        pcall(function()
                                ok, msg = Net.get("TradeAct"):InvokeServer("terima", token)
                        end)
                        if ok == false then
                                toast("Trade", tostring(msg))
                        end
                elseif target and target.Parent then
                        local ok, msg = false, ""
                        pcall(function()
                                ok, msg = Net.get("TradeAct"):InvokeServer("ajak", target.UserId)
                        end)
                        toast(ok == true and "Trade" or "Gagal", tostring(msg))
                end
        end)
end)

-- ===== PANEL TRADE =====

local tradePanel = makePanel("trade")
local tradeScroll = mk("ScrollingFrame", { Size = UDim2.new(1, -8, 1, -8), Position = UDim2.new(0, 4, 0, 4), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, tradePanel)
mk("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, tradeScroll)

local tradeKolom = mk("Frame", { Size = UDim2.new(1, 0, 0, 198), BackgroundTransparency = 1, LayoutOrder = 1 }, tradeScroll)
local kiri = mk("Frame", { Size = UDim2.new(0.5, -6, 1, 0), BackgroundTransparency = 1 }, tradeKolom)
local kanan = mk("Frame", { Position = UDim2.new(0.5, 6, 0, 0), Size = UDim2.new(0.5, -6, 1, 0), BackgroundTransparency = 1 }, tradeKolom)

local function buatSisi(induk: Frame): any
        local judul = mk("TextLabel", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left }, induk)
        local grid = mk("Frame", { Size = UDim2.new(1, 0, 0, 100), Position = UDim2.new(0, 0, 0, 24), BackgroundTransparency = 1 }, induk)
        mk("UIGridLayout", { CellSize = UDim2.new(0.5, -4, 0, 48), CellPadding = UDim2.new(0, 4, 0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, grid)
        local slot = {}
        for i = 1, 4 do
                local cell = mk("TextButton", { BackgroundColor3 = warna(UIStyle.Permukaan), Text = "", AutoButtonColor = false, LayoutOrder = i }, grid)
                round(cell, UIStyle.SudutKecil)
                local nama = mk("TextLabel", { Size = UDim2.new(1, -44, 0, 22), Position = UDim2.new(0, 38, 0, 4), BackgroundTransparency = 1, Text = "", TextWrapped = true, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left }, cell)
                local count = mk("TextLabel", { Size = UDim2.new(1, -44, 0, 18), Position = UDim2.new(0, 38, 1, -22), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Aksen), TextXAlignment = Enum.TextXAlignment.Left }, cell)
                slot[i] = { btn = cell, nama = nama, count = count }
        end
        local micdaBtn = mk("TextButton", { Size = UDim2.new(1, 0, 0, 38), Position = UDim2.new(0, 0, 0, 128), BackgroundColor3 = warna(UIStyle.Permukaan), Text = "", AutoButtonColor = false }, induk)
        round(micdaBtn, UIStyle.SudutKecil)
        local mIkon = IkonKoin.buat(micdaBtn, 22)
        mIkon.Position = UDim2.new(0, 8, 0, 8)
        local micdaLabel = mk("TextLabel", { Size = UDim2.new(1, -52, 1, -10), Position = UDim2.new(0, 40, 0, 5), BackgroundTransparency = 1, Text = "Micda: 0", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left }, micdaBtn)
        local status = mk("TextLabel", { Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 1, -18), BackgroundTransparency = 1, Text = "Belum siap", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left }, induk)
        return { judul = judul, slot = slot, micdaBtn = micdaBtn, micdaLabel = micdaLabel, status = status }
end

local kiriSisi = buatSisi(kiri)
local kananSisi = buatSisi(kanan)

local tradeInfo = mk("TextLabel", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = "Ketuk item di bawah untuk menawarkan. Perubahan me-reset persetujuan.", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, LayoutOrder = 2 }, tradeScroll)

local tradeBarisAksi = mk("Frame", { Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1, LayoutOrder = 3 }, tradeScroll)
local tradeSiapBtn = mk("TextButton", { Size = UDim2.new(0.6, -6, 1, 0), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Terima Tawaran", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1) }, tradeBarisAksi)
round(tradeSiapBtn, UIStyle.SudutKecil)
local tradeWaktu = mk("TextLabel", { Size = UDim2.new(0.4, -6, 1, 0), Position = UDim2.new(0.6, 6, 0, 0), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center }, tradeBarisAksi)

local pickerJudul = mk("TextLabel", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = "Tas kamu (ketuk untuk menawarkan):", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 4 }, tradeScroll)
local tradeTas = mk("ScrollingFrame", { Size = UDim2.new(1, 0, 0, 132), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0), LayoutOrder = 5 }, tradeScroll)
mk("UIGridLayout", { CellSize = UDim2.new(0.32, -4, 0, 40), CellPadding = UDim2.new(0, 4, 0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, tradeTas)

-- ===== POPUP JUMLAH ITEM =====

local tradeQtyDim = mk("Frame", { Name = "TradeQty", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.5, Visible = false, Active = true, ZIndex = 30 }, gui)
local tradeQtyBox = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0.88, 0, 0, 260), BackgroundColor3 = warna(UIStyle.Latar), Active = true, ZIndex = 31 }, tradeQtyDim)
round(tradeQtyBox, 12)
mk("UISizeConstraint", { MinSize = Vector2.new(280, 250), MaxSize = Vector2.new(420, 400) }, tradeQtyBox)
local qtyJudul = mk("TextLabel", { Size = UDim2.new(1, -24, 0, 28), Position = UDim2.new(0, 12, 0, 10), BackgroundTransparency = 1, Text = "Tawarkan Item", TextSize = UIStyle.UkuranJudul, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 32 }, tradeQtyBox)
local qtyItem = mk("TextLabel", { Size = UDim2.new(1, -24, 0, 40), Position = UDim2.new(0, 12, 0, 40), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Aksen), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, ZIndex = 32 }, tradeQtyBox)
local qtyAngka = mk("TextLabel", { Size = UDim2.new(1, -24, 0, 42), Position = UDim2.new(0, 12, 0, 84), BackgroundColor3 = warna(UIStyle.Permukaan), Text = "1", TextSize = UIStyle.UkuranJudul, Font = FONTB, TextColor3 = warna(UIStyle.Teks), ZIndex = 32 }, tradeQtyBox)
round(qtyAngka, UIStyle.SudutKecil)
local qtyRow = mk("Frame", { Size = UDim2.new(1, -24, 0, 40), Position = UDim2.new(0, 12, 0, 132), BackgroundTransparency = 1, ZIndex = 31 }, tradeQtyBox)
mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, qtyRow)

local qtyKey: any? = nil
local qtyDraft = 1

local function tersediaAku(kind: string, id: string, editLama: number?): number
        local total = 0
        for _, s in ipairs(state.tas) do
                if s.kind == kind and s.id == id then
                        total += s.count
                end
        end
        local tawar = 0
        if state.trade then
                for _, s in ipairs(state.trade.aku.items) do
                        if s.kind == kind and s.id == id then
                                tawar += s.count
                        end
                end
        end
        if editLama and editLama > 0 then
                tawar -= editLama
        end
        local bebas = total - tawar
        if bebas < 0 then
                bebas = 0
        end
        return bebas
end

local function qtySet(n: number)
        if not qtyKey then
                return
        end
        if n < 1 then
                n = 1
        end
        if n > qtyKey.maks then
                n = qtyKey.maks
        end
        qtyDraft = n
        qtyAngka.Text = tostring(n)
end

for _, delta in ipairs({ -100, -10, -1, 1, 10, 100 }) do
        local b = mk("TextButton", { Size = UDim2.new(0, 52, 1, 0), BackgroundColor3 = warna(UIStyle.PermukaanAktif), Text = (delta > 0 and "+" or "") .. tostring(delta), TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), LayoutOrder = 3 + delta }, qtyRow)
        round(b, UIStyle.SudutKecil)
        b.Activated:Connect(function()
                qtySet(qtyDraft + delta)
        end)
end
local qtyMaks = mk("TextButton", { Size = UDim2.new(0, 52, 1, 0), BackgroundColor3 = warna(UIStyle.PermukaanAktif), Text = "Maks", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Teks), LayoutOrder = 9 }, qtyRow)
round(qtyMaks, UIStyle.SudutKecil)
qtyMaks.Activated:Connect(function()
        if qtyKey then
                qtySet(qtyKey.maks)
        end
end)

local qtyHapus = mk("TextButton", { Size = UDim2.new(0.5, -9, 0, 42), Position = UDim2.new(0, 12, 1, -54), BackgroundColor3 = warna(UIStyle.Merah), Text = "Hapus dari Tawaran", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = Color3.new(1, 1, 1), Visible = false, ZIndex = 32 }, tradeQtyBox)
round(qtyHapus, UIStyle.SudutKecil)
local qtyBatal = mk("TextButton", { Size = UDim2.new(0.5, -9, 0, 42), Position = UDim2.new(0.5, 9, 1, -54), BackgroundColor3 = warna(UIStyle.PermukaanAktif), Text = "Batal", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), ZIndex = 32 }, tradeQtyBox)
round(qtyBatal, UIStyle.SudutKecil)
local qtyOke = mk("TextButton", { Size = UDim2.new(1, -24, 0, 42), Position = UDim2.new(0, 12, 1, -54), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Tawarkan", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1), ZIndex = 32 }, tradeQtyBox)
round(qtyOke, UIStyle.SudutKecil)

local function bukaQty(kind: string, id: string, editLama: number?)
        if not state.trade or state.trade.fase ~= "tawar" then
                return
        end
        local maks = tersediaAku(kind, id, editLama)
        if maks < 1 then
                toast("Trade", "Semua item itu sudah dipakai di tawaranmu.")
                return
        end
        qtyKey = { kind = kind, id = id, maks = maks, edit = editLama or 0 }
        qtyDraft = (editLama and editLama > 0) and editLama or 1
        if qtyDraft > maks then
                qtyDraft = maks
        end
        qtyJudul.Text = (editLama and editLama > 0) and "Ubah Tawaran" or "Tawarkan Item"
        qtyItem.Text = namaItem(kind, id) .. "  -  bebas ditawarkan: " .. tostring(maks)
        qtyAngka.Text = tostring(qtyDraft)
        local modeEdit = (editLama and editLama > 0) == true
        qtyHapus.Visible = modeEdit
        qtyOke.Visible = not modeEdit
        tradeQtyDim.Visible = true
end

qtyBatal.Activated:Connect(function()
        qtyKey = nil
        tradeQtyDim.Visible = false
end)

qtyOke.Activated:Connect(function()
        local k = qtyKey
        if not k then
                return
        end
        qtyKey = nil
        tradeQtyDim.Visible = false
        task.spawn(function()
                pcall(function()
                        Net.get("TradeAct"):InvokeServer("sisip", k.kind, k.id, qtyDraft)
                end)
        end)
end)

qtyHapus.Activated:Connect(function()
        local k = qtyKey
        if not k then
                return
        end
        qtyKey = nil
        tradeQtyDim.Visible = false
        task.spawn(function()
                pcall(function()
                        Net.get("TradeAct"):InvokeServer("hapus", k.kind, k.id)
                end)
        end)
end)

-- ===== POPUP MICDA =====

local tradeMicdaDim = mk("Frame", { Name = "TradeMicda", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.5, Visible = false, Active = true, ZIndex = 30 }, gui)
local tradeMicdaBox = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0.88, 0, 0, 250), BackgroundColor3 = warna(UIStyle.Latar), Active = true, ZIndex = 31 }, tradeMicdaDim)
round(tradeMicdaBox, 12)
mk("UISizeConstraint", { MinSize = Vector2.new(280, 240), MaxSize = Vector2.new(420, 380) }, tradeMicdaBox)
local micdaJudul = mk("TextLabel", { Size = UDim2.new(1, -24, 0, 28), Position = UDim2.new(0, 12, 0, 10), BackgroundTransparency = 1, Text = "Tawarkan Micda", TextSize = UIStyle.UkuranJudul, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 32 }, tradeMicdaBox)
local micdaInfo = mk("TextLabel", { Size = UDim2.new(1, -24, 0, 20), Position = UDim2.new(0, 12, 0, 42), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 32 }, tradeMicdaBox)
local micdaKotak = mk("TextBox", { Size = UDim2.new(1, -24, 0, 44), Position = UDim2.new(0, 12, 0, 66), BackgroundColor3 = warna(UIStyle.Permukaan), Text = "0", PlaceholderText = "Jumlah Micda", TextSize = UIStyle.UkuranJudul, Font = FONTB, TextColor3 = warna(UIStyle.Teks), ClearTextOnFocus = false, ZIndex = 32 }, tradeMicdaBox)
round(micdaKotak, UIStyle.SudutKecil)
local micdaRow = mk("Frame", { Size = UDim2.new(1, -24, 0, 40), Position = UDim2.new(0, 12, 0, 116), BackgroundTransparency = 1, ZIndex = 31 }, tradeMicdaBox)
mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, micdaRow)

local function micdaParse(teks: any): number
        if type(teks) ~= "string" then
                return 0
        end
        local bersih = teks:gsub("[^0-9]", "")
        local n = tonumber(bersih)
        if not n then
                return 0
        end
        return math.floor(n)
end

local micdaDraft = 0

local function micdaSet(n: number)
        if not state.trade then
                return
        end
        local saldo = state.micda or 0
        if n < 0 then
                n = 0
        end
        if n > saldo then
                n = saldo
        end
        micdaDraft = n
        micdaKotak.Text = tostring(n)
end

for _, langkah in ipairs({ -100000000, -1000000, -10000, -1000, 1000, 10000, 1000000, 100000000 }) do
        local label = "+" .. UangSingkat.singkat(langkah)
        if langkah < 0 then
                label = "-" .. UangSingkat.singkat(-langkah)
        end
        local b = mk("TextButton", { Size = UDim2.new(0, 72, 1, 0), BackgroundColor3 = warna(UIStyle.PermukaanAktif), Text = label, TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Teks), LayoutOrder = 4 + langkah }, micdaRow)
        round(b, UIStyle.SudutKecil)
        b.Activated:Connect(function()
                micdaSet(micdaDraft + langkah)
        end)
end
local micdaNol = mk("TextButton", { Size = UDim2.new(0, 72, 1, 0), BackgroundColor3 = warna(UIStyle.PermukaanAktif), Text = "Kosong", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Teks), LayoutOrder = 99 }, micdaRow)
round(micdaNol, UIStyle.SudutKecil)
micdaNol.Activated:Connect(function()
        micdaSet(0)
end)

local micdaBatal = mk("TextButton", { Size = UDim2.new(0.5, -9, 0, 42), Position = UDim2.new(0, 12, 1, -54), BackgroundColor3 = warna(UIStyle.PermukaanAktif), Text = "Batal", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), ZIndex = 32 }, tradeMicdaBox)
round(micdaBatal, UIStyle.SudutKecil)
local micdaOke = mk("TextButton", { Size = UDim2.new(0.5, -9, 0, 42), Position = UDim2.new(0.5, 9, 1, -54), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Tawarkan", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1), ZIndex = 32 }, tradeMicdaBox)
round(micdaOke, UIStyle.SudutKecil)

local function bukaMicda()
        if not state.trade or state.trade.fase ~= "tawar" then
                return
        end
        micdaDraft = state.trade.aku.micda or 0
        micdaKotak.Text = tostring(micdaDraft)
        micdaInfo.Text = "Saldo kamu: " .. fmt(state.micda or 0) .. " Micda - yang ditawarkan terkunci"
        tradeMicdaDim.Visible = true
end

micdaKotak.FocusLost:Connect(function()
        micdaSet(micdaParse(micdaKotak.Text))
end)
micdaBatal.Activated:Connect(function()
        tradeMicdaDim.Visible = false
end)
micdaOke.Activated:Connect(function()
        tradeMicdaDim.Visible = false
        task.spawn(function()
                pcall(function()
                        Net.get("TradeAct"):InvokeServer("micda", micdaDraft)
                end)
        end)
end)

-- ===== DIALOG KONFIRMASI TERAKHIR =====

local tradeKonfirmDim = mk("Frame", { Name = "TradeKonfirm", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.55, Visible = false, Active = true, ZIndex = 34 }, gui)
local tradeKonfirmBox = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0.9, 0, 0, 300), BackgroundColor3 = warna(UIStyle.Latar), Active = true, ZIndex = 35 }, tradeKonfirmDim)
round(tradeKonfirmBox, 12)
mk("UISizeConstraint", { MinSize = Vector2.new(290, 280), MaxSize = Vector2.new(440, 420) }, tradeKonfirmBox)
local konfirmJudul = mk("TextLabel", { Size = UDim2.new(1, -24, 0, 28), Position = UDim2.new(0, 12, 0, 10), BackgroundTransparency = 1, Text = "Konfirmasi Terakhir", TextSize = UIStyle.UkuranJudul, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 36 }, tradeKonfirmBox)
local konfirmSub = mk("TextLabel", { Size = UDim2.new(1, -24, 0, 20), Position = UDim2.new(0, 12, 0, 40), BackgroundTransparency = 1, Text = "Tawaran sudah terkunci. Cek sekali lagi - setelah ini tidak bisa diubah.", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, ZIndex = 36 }, tradeKonfirmBox)
local konfirmKirim = mk("TextLabel", { Size = UDim2.new(1, -24, 0, 44), Position = UDim2.new(0, 12, 0, 66), BackgroundColor3 = warna(UIStyle.Permukaan), Text = "", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, ZIndex = 36 }, tradeKonfirmBox)
round(konfirmKirim, UIStyle.SudutKecil)
local konfirmTerima = mk("TextLabel", { Size = UDim2.new(1, -24, 0, 44), Position = UDim2.new(0, 12, 0, 116), BackgroundColor3 = warna(UIStyle.PermukaanAktif), Text = "", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, ZIndex = 36 }, tradeKonfirmBox)
round(konfirmTerima, UIStyle.SudutKecil)
local konfirmStatus = mk("TextLabel", { Size = UDim2.new(1, -24, 0, 24), Position = UDim2.new(0, 12, 0, 166), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Kuning), TextXAlignment = Enum.TextXAlignment.Left, Visible = false, ZIndex = 36 }, tradeKonfirmBox)
local konfirmBatal = mk("TextButton", { Size = UDim2.new(0.5, -9, 0, 46), Position = UDim2.new(0, 12, 1, -58), BackgroundColor3 = warna(UIStyle.Merah), Text = "Batal Trade", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1), ZIndex = 36 }, tradeKonfirmBox)
round(konfirmBatal, UIStyle.SudutKecil)
local konfirmYa = mk("TextButton", { Size = UDim2.new(0.5, -9, 0, 46), Position = UDim2.new(0.5, 9, 1, -58), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Sudah, Konfirmasi", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = Color3.new(1, 1, 1), ZIndex = 36 }, tradeKonfirmBox)
round(konfirmYa, UIStyle.SudutKecil)

local function sembunyiKonfirmasi()
        tradeKonfirmDim.Visible = false
end

local function tampilKonfirmasi()
        if not state.trade or state.trade.fase ~= "konfirmasi" then
                sembunyiKonfirmasi()
                return
        end
        local t = state.trade
        konfirmKirim.Text = "Kamu kirim: " .. TradeLogic.ringkas({ items = t.aku.items, micda = t.aku.micda }, CropData.byId)
        konfirmTerima.Text = "Kamu terima: " .. TradeLogic.ringkas({ items = t.lawan.items, micda = t.lawan.micda }, CropData.byId)
        konfirmYa.Visible = not t.aku.konfirm
        konfirmBatal.Visible = not t.aku.konfirm
        konfirmStatus.Visible = t.aku.konfirm == true
        konfirmStatus.Text = "Menunggu " .. UIStyle.potong(t.lawanNama, 14) .. " konfirmasi..."
        tradeKonfirmDim.Visible = true
end

konfirmYa.Activated:Connect(function()
        if not state.trade then
                return
        end
        state.trade.aku.konfirm = true
        konfirmYa.Visible = false
        konfirmBatal.Visible = false
        konfirmStatus.Visible = true
        task.spawn(function()
                pcall(function()
                        Net.get("TradeAct"):InvokeServer("konfirm")
                end)
        end)
end)

konfirmBatal.Activated:Connect(function()
        task.spawn(function()
                pcall(function()
                        Net.get("TradeAct"):InvokeServer("batal")
                end)
        end)
end)

-- ===== RENDER =====

local function renderSisi(sisi: any, susunan: any)
        for i = 1, 4 do
                local cell = susunan.slot[i]
                local it = sisi.items[i]
                if it then
                        cell.btn.BackgroundColor3 = warna(it.kind == "benih" and UIStyle.Permukaan or UIStyle.PermukaanAktif)
                        cell.nama.Text = UIStyle.potong(namaItem(it.kind, it.id))
                        cell.count.Text = "x" .. tostring(it.count)
                        ikonSlot(cell.btn, it)
                else
                        cell.btn.BackgroundColor3 = warna(UIStyle.Permukaan)
                        cell.nama.Text = ""
                        cell.count.Text = ""
                        ikonSlot(cell.btn, nil)
                end
        end
        susunan.micdaLabel.Text = "Micda: " .. fmt(sisi.micda or 0)
        if sisi.konfirm then
                susunan.status.Text = "Sudah dikonfirmasi"
                susunan.status.TextColor3 = Color3.fromRGB(120, 220, 140)
        elseif sisi.siap then
                susunan.status.Text = "Siap"
                susunan.status.TextColor3 = warna(UIStyle.Kuning)
        else
                susunan.status.Text = "Belum siap"
                susunan.status.TextColor3 = warna(UIStyle.Abu)
        end
end

local function isiTradeTas()
        for _, c in ipairs(tradeTas:GetChildren()) do
                if c:IsA("TextButton") then
                        c:Destroy()
                end
        end
        local agregat: { [string]: any } = {}
        local urutan = {}
        for _, s in ipairs(state.tas) do
                local k = s.kind .. "\1" .. s.id
                if not agregat[k] then
                        agregat[k] = { kind = s.kind, id = s.id, total = 0 }
                        table.insert(urutan, k)
                end
                agregat[k].total += s.count
        end
        local n = 0
        for _, k in ipairs(urutan) do
                local a = agregat[k]
                local bebas = tersediaAku(a.kind, a.id, nil)
                if bebas > 0 then
                        n += 1
                        local chip = mk("TextButton", { BackgroundColor3 = warna(a.kind == "benih" and UIStyle.Permukaan or UIStyle.PermukaanAktif), Text = "", AutoButtonColor = false, LayoutOrder = n }, tradeTas)
                        round(chip, UIStyle.SudutKecil)
                        ikonSlot(chip, { kind = a.kind, id = a.id, count = bebas })
                        mk("TextLabel", { Size = UDim2.new(1, -40, 0, 20), Position = UDim2.new(0, 34, 0, 2), BackgroundTransparency = 1, Text = UIStyle.potong(namaItem(a.kind, a.id), 16), TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, chip)
                        mk("TextLabel", { Size = UDim2.new(1, -40, 0, 16), Position = UDim2.new(0, 34, 1, -18), BackgroundTransparency = 1, Text = "x" .. tostring(bebas), TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Aksen), TextXAlignment = Enum.TextXAlignment.Left }, chip)
                        chip.Activated:Connect(function()
                                bukaQty(a.kind, a.id, nil)
                        end)
                end
        end
end

local function refreshTrade()
        if not state.trade then
                return
        end
        local t = state.trade
        panelTitle.Text = "Trade dengan " .. UIStyle.potong(t.lawanNama)
        kiriSisi.judul.Text = "Kamu"
        kananSisi.judul.Text = UIStyle.potong(t.lawanNama, 14)
        renderSisi(t.aku, kiriSisi)
        renderSisi(t.lawan, kananSisi)
        tradeWaktu.Text = "Auto-batal " .. tostring(t.sisa or 0) .. "s"
        if t.fase == "konfirmasi" then
                tradeSiapBtn.Visible = false
                tradeTas.Visible = false
                pickerJudul.Text = "Tawaran terkunci - lanjut ke konfirmasi di bawah."
                isiTradeTas()
                tampilKonfirmasi()
        else
                tradeSiapBtn.Visible = true
                tradeSiapBtn.Text = t.aku.siap and "Batal Siap" or "Terima Tawaran"
                tradeSiapBtn.BackgroundColor3 = warna(t.aku.siap and UIStyle.PermukaanAktif or UIStyle.Hijau)
                tradeTas.Visible = true
                pickerJudul.Text = "Tas kamu (ketuk untuk menawarkan):"
                isiTradeTas()
                sembunyiKonfirmasi()
        end
end

for i, cell in ipairs(kiriSisi.slot) do
        cell.btn.Activated:Connect(function()
                if not state.trade or state.trade.fase ~= "tawar" then
                        return
                end
                local it = state.trade.aku.items[i]
                if it then
                        bukaQty(it.kind, it.id, it.count)
                end
        end)
end
kiriSisi.micdaBtn.Activated:Connect(bukaMicda)

tradeSiapBtn.Activated:Connect(function()
        if not state.trade or state.trade.fase ~= "tawar" then
                return
        end
        task.spawn(function()
                pcall(function()
                        Net.get("TradeAct"):InvokeServer("siap", not state.trade.aku.siap)
                end)
        end)
end)

-- ===== OBENG DI ATAS KEPALA =====

local function sembunyiObeng()
        if obengGui then
                obengGui:Destroy()
                obengGui = nil
        end
        obengTarget = nil
        obengSampai = nil
end

local function tampilObeng(target: Player)
        if obengTarget == target and obengGui then
                obengSampai = os.clock() + 7
                return
        end
        sembunyiObeng()
        local char = target.Character
        local kepala = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
        if not kepala or not kepala:IsA("BasePart") then
                return
        end
        local g = Instance.new("BillboardGui")
        g.Name = "ObengTrade"
        g.Adornee = kepala
        g.Size = UDim2.fromOffset(64, 64)
        g.StudsOffset = Vector3.new(0, 2.8, 0)
        g.MaxDistance = 60
        g.AlwaysOnTop = true
        local btn = mk("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = warna(UIStyle.PermukaanAktif), BackgroundTransparency = 0.08, Text = "", AutoButtonColor = true, BorderSizePixel = 0, ZIndex = 2 }, g)
        round(btn, 32)
        mk("UIStroke", { Color = warna(UIStyle.Aksen), Thickness = 2, Transparency = 0.2 }, btn)
        local gagang = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.57, 0.57), Size = UDim2.fromScale(0.14, 0.5), BackgroundColor3 = warna(UIStyle.Teks), BorderSizePixel = 0, Rotation = 45, ZIndex = 3 }, btn)
        mk("UICorner", { CornerRadius = UDim.new(0.5, 0) }, gagang)
        local kepalaObeng = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.44, 0.44), Size = UDim2.fromScale(0.42, 0.42), BackgroundColor3 = warna(UIStyle.Teks), BorderSizePixel = 0, Rotation = 45, ZIndex = 3 }, btn)
        mk("UICorner", { CornerRadius = UDim.new(0.5, 0) }, kepalaObeng)
        local celah = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.36, 0.52), Size = UDim2.fromScale(0.28, 0.09), BackgroundColor3 = warna(UIStyle.PermukaanAktif), BorderSizePixel = 0, Rotation = 45, ZIndex = 4 }, btn)
        mk("UICorner", { CornerRadius = UDim.new(0.5, 0) }, celah)
        btn.Activated:Connect(function()
                if obengTarget and obengTarget.Parent and bukaTanyaTrade then
                        bukaTanyaTrade(obengTarget)
                end
        end)
        g.Parent = playerGui
        obengGui = g
        obengTarget = target
        obengSampai = os.clock() + 7
end

-- ===== KETUK DUNIA -> PILIH PEMAIN =====

local function pemainDariTap(px: number, py: number): Player?
        local ok, ray = pcall(function()
                return camera:ScreenPointToRay(px, py)
        end)
        if not ok or not ray then
                return nil
        end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local exclude: { Instance } = { camera }
        if player.Character then
                table.insert(exclude, player.Character)
        end
        params.FilterDescendantsInstances = exclude
        params.IgnoreWater = true
        local hit = Workspace:Raycast(ray.Origin, ray.Direction * 60, params)
        if not hit then
                return nil
        end
        local m: Instance? = hit.Instance
        while m and m.Parent do
                local p = Players:GetPlayerFromCharacter(m)
                if p and p ~= player then
                        return p
                end
                m = m.Parent
        end
        return nil
end

local function padaTapDunia(px: number, py: number, diproses: boolean)
        if diproses then
                return
        end
        if dim.Visible or modalDim.Visible or tradeTanyaDim.Visible or tradeQtyDim.Visible or tradeMicdaDim.Visible then
                return
        end
        if state.trade then
                return
        end
        local target = pemainDariTap(px, py)
        if target then
                tampilObeng(target)
        end
end

UserInputService.TouchTapInWorld:Connect(function(pos: Vector2, diproses: boolean)
        padaTapDunia(pos.X, pos.Y, diproses)
end)

UserInputService.InputBegan:Connect(function(input: InputObject, diproses: boolean)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local m = UserInputService:GetMouseLocation()
                padaTapDunia(m.X, m.Y, diproses)
        end
end)

bukaTanyaTrade = function(target: Player)
        if state.trade or dim.Visible or modalDim.Visible or tradeTanyaDim.Visible then
                return
        end
        tradeToken = nil
        tanyaLokalTarget = target
        tanyaNama.Text = "Trade dengan " .. UIStyle.potong(namaOf(target)) .. "?"
        tanyaInfo.Text = "Permintaan akan dikirim. Trade baru jalan kalau dia setuju juga."
        tanyaHingga = os.clock() + 15
        tradeTanyaDim.Visible = true
end

-- ===== SINKRON DARI SERVER =====

Net.get("TradeSync").OnClientEvent:Connect(function(kejadian: any, payload: any)
        if kejadian == "permintaan" then
                if state.trade or type(payload) ~= "table" or type(payload.token) ~= "string" then
                        return
                end
                tradeToken = payload.token
                tanyaLokalTarget = nil
                tanyaNama.Text = "Trade dengan " .. UIStyle.potong(tostring(payload.nama)) .. "?"
                tanyaInfo.Text = "Hangus otomatis dalam " .. tostring(payload.expDetik or 30) .. " detik."
                tanyaHingga = os.clock() + (tonumber(payload.expDetik) or 30) + 0.5
                tradeTanyaDim.Visible = true
        elseif kejadian == "buka" then
                if type(payload) ~= "table" then
                        return
                end
                sembunyiTanya()
                sembunyiObeng()
                state.trade = payload
                openPanel("trade")
                refreshTrade()
        elseif kejadian == "tutup" then
                state.trade = nil
                sembunyiTanya()
                sembunyiKonfirmasi()
                sembunyiObeng()
                if currentPanel == "trade" then
                        closePanel()
                end
                toast("Trade", (type(payload) == "table" and payload.pesan) and tostring(payload.pesan) or "Trade selesai.")
                syncState()
        end
end)

-- ===== LINGKARAN PEMBERSIH =====

task.spawn(function()
        while true do
                task.wait(1)
                if obengGui then
                        if dim.Visible or modalDim.Visible or (obengSampai and os.clock() > obengSampai) or not obengTarget or not obengTarget.Parent then
                                sembunyiObeng()
                        end
                end
                if tradeTanyaDim.Visible and tanyaHingga and os.clock() > tanyaHingga then
                        sembunyiTanya()
                end
                if state.trade and currentPanel == "trade" then
                        local sisa = state.trade.sisa
                        if type(sisa) == "number" and sisa > 0 then
                                state.trade.sisa = sisa - 1
                                tradeWaktu.Text = "Auto-batal " .. tostring(sisa - 1) .. "s"
                        end
                end
        end
end)
end
