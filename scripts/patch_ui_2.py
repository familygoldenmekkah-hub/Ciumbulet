P = '/home/z/my-project/download/dunia-akiomida/src/Client/UIController.luau'
s = open(P).read()

def ganti(lama, baru):
    global s
    lama = lama.expandtabs(8)
    baru = baru.expandtabs(8)
    if lama not in s:
        raise SystemExit("TIDAK KETEMU: " + lama[:90])
    s = s.replace(lama, baru, 1)

ganti(
"""local semaiDim = mk("Frame", { Name = "ModalSemai",""",
"""local semaiDim = mk("Frame", { Name = "ModalSemai",""")

import re
rxM = re.compile(
    'local m = mk\\("Frame", \\{ Size = UDim2\\.new\\(0, 28, 0, 28\\), Position = UDim2\\.new\\(0, 6, 0, (5|4)\\), BackgroundColor3 = warna\\(UIStyle\\.Aksen\\) \\}, row\\)\\n(\\s*)mk\\("UICorner", \\{ CornerRadius = UDim\\.new\\(0\\.5, 0\\) \\}, m\\)\\n\\s*mk\\("TextLabel", \\{ Size = UDim2\\.fromScale\\(1, 1\\), BackgroundTransparency = 1, Text = "M", Font = FONTB, TextSize = UIStyle\\.UkuranKecil, TextColor3 = warna\\(UIStyle\\.Latar\\), ZIndex = 2 \\}, m\\)'
)
def gantiM(mo):
    return 'local m = IkonKoin.buat(row, 28)\n' + mo.group(2) + 'm.Position = UDim2.new(0, 6, 0, ' + mo.group(1) + ')'
s, nM = rxM.subn(gantiM, s)
if nM != 2:
    raise SystemExit("blok ikon M tidak tepat 2: " + str(nM))

ganti(
"""local jualPreview = mk("TextLabel", { Size = UDim2.new(1, -24, 0, 24), Position = UDim2.new(0, 12, 0, 140), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Aksen), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, jualBox)""",
"""local jualBaris = mk("Frame", { Size = UDim2.new(1, -24, 0, 24), Position = UDim2.new(0, 12, 0, 140), BackgroundTransparency = 1 }, jualBox)
	mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }, jualBaris)
	IkonKoin.buat(jualBaris, 20).LayoutOrder = 1
	local jualPreview = mk("TextLabel", { LayoutOrder = 2, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Aksen), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, jualBaris)""")

ganti(
"""mk("TextLabel", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = "Harga: " .. fmt(pack.price) .. " Micda", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Aksen), TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 3 }, modalIsi)""",
"""local hargaRow = mk("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, LayoutOrder = 3 }, modalIsi)
mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }, hargaRow)
IkonKoin.buat(hargaRow, 20).LayoutOrder = 1
mk("TextLabel", { LayoutOrder = 2, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, Text = "Harga: " .. fmt(pack.price) .. " Micda", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Aksen), TextXAlignment = Enum.TextXAlignment.Left }, hargaRow)""")

ganti(
"""local tanamTab = mk("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = true }, tanamBody)
mk("TextLabel", { Size = UDim2.new(0.55, 0, 0, 18), Position = UDim2.new(0, 2, 0, 0), BackgroundTransparency = 1, Text = "Pilih benih untuk ditanam", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, tanamTab)
local jumlahLabel = mk("TextLabel", { Size = UDim2.new(0.45, -4, 0, 18), Position = UDim2.new(0.55, 4, 0, 0), BackgroundTransparency = 1, Text = "Jumlah: -", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Aksen), TextXAlignment = Enum.TextXAlignment.Right }, tanamTab)
local tanamList = mk("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -118), Position = UDim2.new(0, 0, 0, 22), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, tanamTab)
mk("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, tanamList)
local tanamFeedback = mk("TextLabel", { Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 2, 1, -98), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, tanamTab)

local angkaRow = mk("Frame", { Size = UDim2.new(1, 0, 0, 34), Position = UDim2.new(0, 0, 1, -78), BackgroundTransparency = 1 }, tanamTab)
mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, angkaRow)""",
"""local tanamTab = mk("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = true }, tanamBody)
mk("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, tanamTab)
local kepalaTanam = mk("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, LayoutOrder = 1 }, tanamTab)
mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder }, kepalaTanam)
mk("TextLabel", { Size = UDim2.new(0.55, 0, 1, 0), BackgroundTransparency = 1, Text = "Pilih benih untuk ditanam", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = 1 }, kepalaTanam)
local jumlahLabel = mk("TextLabel", { Size = UDim2.new(0.45, -4, 1, 0), BackgroundTransparency = 1, Text = "Jumlah: -", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Aksen), TextXAlignment = Enum.TextXAlignment.Right, LayoutOrder = 2 }, kepalaTanam)
local tanamList = mk("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -118), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0), LayoutOrder = 2 }, tanamTab)
mk("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, tanamList)
mk("UIFlexItem", { FlexMode = Enum.UIFlexMode.Grow }, tanamList)
local tanamFeedback = mk("TextLabel", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = 3 }, tanamTab)

local angkaRow = mk("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, LayoutOrder = 4 }, tanamTab)
mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, angkaRow)""")

ganti(
"""local mulaiBtn = mk("TextButton", { Size = UDim2.new(1, 0, 0, 36), Position = UDim2.new(0, 0, 1, -38), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Mulai Tanam", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1) }, tanamTab)
round(mulaiBtn)""",
"""local mulaiBtn = mk("TextButton", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Mulai Tanam", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1), LayoutOrder = 5 }, tanamTab)
round(mulaiBtn)""")

ganti(
"""local soalView = mk("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false }, tanamBody)
local soalNomor = mk("TextLabel", { Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 2, 0, 0), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left }, soalView)
local soalTeks = mk("TextLabel", { Size = UDim2.new(1, 0, 0, 58), Position = UDim2.new(0, 0, 0, 24), BackgroundColor3 = warna(UIStyle.Permukaan), Text = "?", TextSize = UIStyle.UkuranJudul, Font = FONTB, TextColor3 = warna(UIStyle.Teks) }, soalView)
round(soalTeks)
local soalJawab = mk("TextBox", { Size = UDim2.new(0.6, 0, 0, 42), Position = UDim2.new(0.2, 0, 0, 92), BackgroundColor3 = warna(UIStyle.Permukaan), Text = "", PlaceholderText = "Tulis jawaban angka", TextSize = UIStyle.UkuranIsi, Font = FON, TextColor3 = warna(UIStyle.Teks), ClearTextOnFocus = true }, soalView)
round(soalJawab, UIStyle.SudutKecil)
local soalBtn = mk("TextButton", { Size = UDim2.new(0.6, 0, 0, 38), Position = UDim2.new(0.2, 0, 0, 140), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Jawab", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1) }, soalView)
round(soalBtn)
local soalFeedback = mk("TextLabel", { Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 2, 0, 186), BackgroundTransparency = 1, Text = "", TextWrapped = true, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left }, soalView)
local batalBtn = mk("TextButton", { AnchorPoint = Vector2.new(0.5, 1), Size = UDim2.new(0.6, 0, 0, 26), Position = UDim2.new(0.5, 0, 1, -2), BackgroundTransparency = 1, Text = "Batalkan Sesi Tanam", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Merah) }, soalView)""",
"""local soalView = mk("ScrollingFrame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, tanamBody)
mk("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center }, soalView)
mk("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4) }, soalView)
local progresRow = mk("Frame", { Size = UDim2.new(1, -20, 0, 22), BackgroundTransparency = 1, LayoutOrder = 1 }, soalView)
mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }, progresRow)
local progresBar = mk("Frame", { Size = UDim2.new(0.62, -10, 1, -6), BackgroundColor3 = warna(UIStyle.PermukaanAktif), LayoutOrder = 1 }, progresRow)
round(progresBar, 5)
local progresIsi = mk("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = warna(UIStyle.Aksen), BorderSizePixel = 0 }, progresBar)
round(progresIsi, 5)
local progresTeks = mk("TextLabel", { Size = UDim2.new(0.38, -10, 1, 0), BackgroundTransparency = 1, Text = "0/0", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2 }, progresRow)
local soalTeks = mk("TextLabel", { Size = UDim2.new(1, -20, 0, 58), BackgroundColor3 = warna(UIStyle.Permukaan), Text = "?", TextSize = UIStyle.UkuranJudul, Font = FONTB, TextColor3 = warna(UIStyle.Teks), LayoutOrder = 2 }, soalView)
round(soalTeks)
local soalJawab = mk("TextBox", { Size = UDim2.new(1, -20, 0, 44), BackgroundColor3 = warna(UIStyle.Permukaan), Text = "", PlaceholderText = "Tulis jawaban angka", TextSize = UIStyle.UkuranIsi, Font = FON, TextColor3 = warna(UIStyle.Teks), ClearTextOnFocus = true, LayoutOrder = 3 }, soalView)
round(soalJawab, UIStyle.SudutKecil)
local soalSkala = mk("UIScale", { Scale = 1 }, soalJawab)
local soalBtn = mk("TextButton", { Size = UDim2.new(1, -20, 0, 44), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Jawab", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1), LayoutOrder = 4 }, soalView)
round(soalBtn)
local batalBtn = mk("TextButton", { Size = UDim2.new(1, -20, 0, 44), BackgroundColor3 = warna(UIStyle.Permukaan), Text = "Batalkan Sesi Tanam", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Merah), LayoutOrder = 5 }, soalView)
round(batalBtn, UIStyle.SudutKecil)""")

open(P, 'w').write(s)
print("patch tahap 2a selesai")
