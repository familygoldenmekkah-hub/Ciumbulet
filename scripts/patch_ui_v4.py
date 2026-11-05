p = "/home/z/my-project/download/dunia-akiomida/src/Client/UIController.luau"
src = open(p).read()

import re
def T8(txt):
    # convert leading tabs (1 level) to the file's 8-space unit
    return re.sub(r"^(\t+)", lambda m: " " * 8 * len(m.group(1)), txt, flags=re.M)


# ---------- 1) PALET MINIMAL FLAT (profesional, tidak anak-anak) ----------
old = """local T = {
\tBg = Color3.fromRGB(20, 24, 34),
\tPanel = Color3.fromRGB(30, 36, 50),
\tPanelLight = Color3.fromRGB(44, 52, 70),
\tGold = Color3.fromRGB(255, 209, 102),
\tGreen = Color3.fromRGB(88, 200, 130),
\tRed = Color3.fromRGB(235, 100, 100),
\tBlue = Color3.fromRGB(99, 200, 255),
\tText = Color3.fromRGB(238, 238, 246),
\tTextDim = Color3.fromRGB(170, 176, 192),
\tDisabled = Color3.fromRGB(80, 86, 100),
}"""
new = """-- v4 TEMMINIMAL: satu aksen emas, panel gelap flat, tanpa warna-warni pelangi
local T = {
\tBg = Color3.fromRGB(14, 16, 20),
\tPanel = Color3.fromRGB(22, 25, 32),
\tPanelLight = Color3.fromRGB(36, 40, 50),
\tGold = Color3.fromRGB(233, 196, 106),
\tGreen = Color3.fromRGB(96, 200, 140),
\tRed = Color3.fromRGB(228, 104, 104),
\tBlue = Color3.fromRGB(122, 168, 226),
\tText = Color3.fromRGB(232, 234, 240),
\tTextDim = Color3.fromRGB(138, 144, 158),
\tDisabled = Color3.fromRGB(70, 75, 88),
}"""
old = T8(old); assert old in src, "palette"
src = src.replace(T8(old), T8(new), 1)

# ---------- 2) Ikon Micda: $ -> M ----------
old = '\t\tText = "$",'
old = T8(old); assert old in src, "coin icon"
src = src.replace(old, T8('\t\tText = "M",'), 1)

# ---------- 3) Tombol aksi seragam + Pasar ----------
old = """\tlocal actions = {
\t\t{ name = "Tas", label = "Tas", color = T.Gold, cb = function()
\t\t\tself:renderInv()
\t\t\tself:showPanel("Inv")
\t\tend },
\t\t{ name = "Kar", label = "Kar", color = T.Blue, cb = function()
\t\t\tself:renderChar()
\t\t\tself:showPanel("Char")
\t\tend },
\t\t{ name = "Tugas", label = "Tugas", color = T.Green, cb = function()
\t\t\tself:renderQuest()
\t\t\tself:showPanel("Quest")
\t\tend },
\t\t{ name = "Dagang", label = "Dagang", color = Color3.fromRGB(224, 140, 190), cb = function()
\t\t\tself:renderTrade()
\t\t\tself:showPanel("Trade")
\t\tend },
\t\t{ name = "Kode", label = "Kode", color = T.Blue, cb = function()
\t\t\tself:showPanel("Code")
\t\tend },
\t\t{ name = "Bantuan", label = "?", color = T.Green, cb = function()
\t\t\tself:showPanel("Help")
\t\tend },
\t}
\tlocal i = 0
\tfor _, act in actions do
\t\ti += 1
\t\tlocal rowIdx = math.floor((i - 1) / 3)
\t\tlocal colIdx = (i - 1) % 3
\t\tbtn({
\t\t\tparent = self.gui,
\t\t\tName = "Btn" .. act.name,
\t\t\tAnchorPoint = Vector2.new(1, 0),
\t\t\tPosition = UDim2.new(1, -16 - colIdx * 92, 0, 14 + rowIdx * 50),
\t\t\tSize = UDim2.fromOffset(84, 42),
\t\t\tBackgroundColor3 = act.color,
\t\t\tTextColor3 = Color3.fromRGB(30, 30, 36),
\t\t\tText = act.label,
\t\t\t_radius = 12,
\t\t}).Activated:Connect(act.cb)
\tend"""
new = """\tlocal actions = {
\t\t{ name = "Tas", label = "Tas", cb = function()
\t\t\tself:renderInv()
\t\t\tself:showPanel("Inv")
\t\tend },
\t\t{ name = "Kar", label = "Kar", cb = function()
\t\t\tself:renderChar()
\t\t\tself:showPanel("Char")
\t\tend },
\t\t{ name = "Tugas", label = "Tugas", cb = function()
\t\t\tself:renderQuest()
\t\t\tself:showPanel("Quest")
\t\tend },
\t\t{ name = "Dagang", label = "Dagang", cb = function()
\t\t\tself:renderTrade()
\t\t\tself:showPanel("Trade")
\t\tend },
\t\t{ name = "Pasar", label = "Pasar", cb = function()
\t\t\tself:showPanel("Market")
\t\t\tself:refreshMarket()
\t\tend },
\t\t{ name = "Kode", label = "Kode", cb = function()
\t\t\tself:showPanel("Code")
\t\tend },
\t\t{ name = "Bantuan", label = "?", cb = function()
\t\t\tself:showPanel("Help")
\t\tend },
\t}
\tlocal i = 0
\tfor _, act in actions do
\t\ti += 1
\t\tlocal rowIdx = math.floor((i - 1) / 4)
\t\tlocal colIdx = (i - 1) % 4
\t\tlocal b = btn({
\t\t\tparent = self.gui,
\t\t\tName = "Btn" .. act.name,
\t\t\tAnchorPoint = Vector2.new(1, 0),
\t\t\tPosition = UDim2.new(1, -16 - colIdx * 84, 0, 14 + rowIdx * 50),
\t\t\tSize = UDim2.fromOffset(76, 42),
\t\t\tBackgroundColor3 = T.Panel,
\t\t\tBackgroundTransparency = 0.12,
\t\t\tTextColor3 = T.Text,
\t\t\tText = act.label,
\t\t\t_radius = 8,
\t\t})
\t\tb.Activated:Connect(act.cb)
\tend"""
old = T8(old); assert old in src, "actions"
src = src.replace(T8(old), T8(new), 1)

# ---------- 4) showPanel: tambah Market ----------
old = '''for _, n in { "Shop", "Plant", "Inv", "Quiz", "Code", "Help", "Char", "Craft", "Quest", "Trade" } do'''
old = T8(old); assert old in src, "showPanel"
src = src.replace(T8(old), '''for _, n in { "Shop", "Plant", "Inv", "Quiz", "Code", "Help", "Char", "Craft", "Quest", "Trade", "Market" } do''', 1)

# ---------- 5) new(): state market + buildMarketPanel ----------
old = """\tself.tradeSnap = nil
\tself.inviteFrom = nil
\tself.bossInfo = nil
"""
new = """\tself.tradeSnap = nil
\tself.inviteFrom = nil
\tself.bossInfo = nil
\tself.marketTab = "papan"
\tself.marketSnap = nil
"""
old = T8(old); assert old in src, "new state"
src = src.replace(T8(old), T8(new), 1)

old = """\tself:buildTradePanel()
\tself:wireRemotes()"""
new = """\tself:buildTradePanel()
\tself:buildMarketPanel()
\tself:wireRemotes()"""
old = T8(old); assert old in src, "new build"
src = src.replace(T8(old), T8(new), 1)

# ---------- 6) TIPS diperbarui ----------
old = '''"Klaim ladang GRATIS di Kawasan Ladang (Utara), lalu tanami bibit!",'''
new = '''"Ladang pertama GRATIS! Ladang lain dibeli lunas pakai Micda di Kawasan Ladang (Utara).",'''
old = T8(old); assert old in src, "tip1"
src = src.replace(T8(old), T8(new), 1)

old = '''"Serang Gelatin Hijau di Padang Timur untuk Gelatin - bahan Zirah Kulit!",'''
new = '''"Monster berwujud ANGKA dengan AURA berkeliaran - lawan Angka Satu di Padang Timur!",'''
old = T8(old); assert old in src, "tip2"
src = src.replace(T8(old), T8(new), 1)

old = '''"Dagang aman antar pemain: tombol Dagang, dekati partner, undang & SIAP!",'''
new = '''"Dagang aman antar pemain: tombol Dagang, dekati partner, undang & SIAP!",\n\t"PAPAN JUAL di alun-alun: pasang barang, pemain lain beli - Micda masuk walau kamu offline!",'''
old = T8(old); assert old in src, "tip3"
src = src.replace(T8(old), T8(new), 1)

old = '''"BOSS RAID: Raja Golem muncul di Arena Timur - serang bersama semua pemain!",'''
new = '''"BOSS RAID: Angka Sang Raja (9) muncul di Arena Timur - serang bersama semua pemain!",'''
old = T8(old); assert old in src, "tip4"
src = src.replace(T8(old), T8(new), 1)

# ---------- 7) PANEL PAPAN JUAL (insert sebelum renderTrade) ----------
anchor = "function UIController:renderTrade()"
assert anchor in src, "renderTrade anchor"
market = '''--------------------------------------------------------------------
-- PANEL PAPAN JUAL (v4): pasar antar pemain, mata uang MICDA
--   Harga pasang bebas; biaya jasa pasar 2% (min 1 Micda) transparan.
--------------------------------------------------------------------

function UIController:buildMarketPanel()
\tlocal frame = self:panelFrame("Market", 0.62, 0.74)
\tUtil.create("TextLabel", {
\t\tName = "Judul",
\t\tSize = UDim2.new(1, -60, 0, 36),
\t\tPosition = UDim2.fromOffset(18, 10),
\t\tBackgroundTransparency = 1,
\t\tFont = Enum.Font.GothamBlack,
\t\tTextScaled = true,
\t\tTextColor3 = T.Gold,
\t\tTextXAlignment = Enum.TextXAlignment.Left,
\t\tText = "Papan Jual - Micda",
\t}, frame)
\tbtn({
\t\tparent = frame,
\t\tName = "Tutup",
\t\tAnchorPoint = Vector2.new(1, 0),
\t\tPosition = UDim2.new(1, -12, 0, 10),
\t\tSize = UDim2.fromOffset(40, 34),
\t\tBackgroundColor3 = T.Red,
\t\tTextColor3 = Color3.new(1, 1, 1),
\t\tText = "X",
\t\t_radius = 8,
\t}).Activated:Connect(function()
\t\tself:showPanel(nil)
\tend)

\t-- tab strip minimal
\tlocal strip = Util.create("Frame", {
\t\tPosition = UDim2.fromOffset(18, 52),
\t\tSize = UDim2.new(1, -36, 0, 34),
\t\tBackgroundTransparency = 1,
\t}, frame)
\tUtil.create("UIListLayout", {
\t\tFillDirection = Enum.FillDirection.Horizontal,
\t\tPadding = UDim.new(0, 8),
\t}, strip)
\tself.marketTabBtns = {}
\tfor _, tb in { { id = "papan", label = "Papan" }, { id = "jual", label = "Jual Barang" }, { id = "ku", label = "Lelanganku" } } do
\t\tself.marketTabBtns[tb.id] = btn({
\t\t\tparent = strip,
\t\t\tSize = UDim2.fromOffset(116, 32),
\t\t\tBackgroundColor3 = T.PanelLight,
\t\t\tTextColor3 = T.TextDim,
\t\t\tText = tb.label,
\t\t\t_radius = 8,
\t\t})
\t\tself.marketTabBtns[tb.id].Activated:Connect(function()
\t\t\tself.marketTab = tb.id
\t\t\tself:renderMarket()
\t\tend)
\tend

\tlocal scroll = Util.create("ScrollingFrame", {
\t\tName = "List",
\t\tPosition = UDim2.fromOffset(18, 94),
\t\tSize = UDim2.new(1, -36, 1, -112),
\t\tBackgroundTransparency = 1,
\t\tBorderSizePixel = 0,
\t\tCanvasSize = UDim2.new(),
\t\tAutomaticCanvasSize = Enum.AutomaticSize.Y,
\t\tScrollBarThickness = 6,
\t}, frame)
\tUtil.create("UIListLayout", { Padding = UDim.new(0, 8) }, scroll)
\tself.marketList = scroll
end

function UIController:refreshMarket()
\ttask.spawn(function()
\t\tlocal ok, res = pcall(function()
\t\t\treturn Remotes.get("MarketAction"):InvokeServer({ action = "browse" })
\t\tend)
\t\tif ok and type(res) == "table" and res.ok then
\t\t\tself.marketSnap = res
\t\t\tif self.activePanel == "Market" then
\t\t\t\tself:renderMarket()
\t\t\tend
\t\tend
\tend)
end

function UIController:renderMarket()
\tlocal list = self.marketList
\tfor _, child in list:GetChildren() do
\t\tif child:IsA("Frame") then
\t\t\tchild:Destroy()
\t\tend
\tend
\tfor id, b in pairs(self.marketTabBtns or {}) do
\t\tb.BackgroundColor3 = (self.marketTab == id) and T.PanelLight or T.Panel
\t\tb.TextColor3 = (self.marketTab == id) and T.Gold or T.TextDim
\tend
\tlocal snap = self.marketSnap or { listings = {}, mine = {}, feeRate = 0.02, feeMin = 1 }

\tif self.marketTab == "papan" then
\t\tUtil.create("TextLabel", {
\t\t\tSize = UDim2.new(1, -8, 0, 30),
\t\t\tBackgroundTransparency = 1,
\t\t\tFont = Enum.Font.Gotham,
\t\t\tTextScaled = true,
\t\t\tTextColor3 = T.TextDim,
\t\t\tTextXAlignment = Enum.TextXAlignment.Left,
\t\t\tText = "Barang pemain lain. Bayar penuh sekali - tanpa biaya tersembunyi.",
\t\t}, list)
\t\tlocal any = false
\t\tfor _, l in ipairs(snap.listings or {}) do
\t\t\tany = true
\t\t\tlocal r = row(list, 56)
\t\t\tUtil.create("TextLabel", {
\t\t\t\tPosition = UDim2.fromOffset(12, 8),
\t\t\t\tSize = UDim2.new(1, -230, 0, 40),
\t\t\t\tBackgroundTransparency = 1,
\t\t\t\tFont = Enum.Font.GothamBold,
\t\t\t\tTextScaled = true,
\t\t\t\tTextColor3 = T.Text,
\t\t\t\tTextXAlignment = Enum.TextXAlignment.Left,
\t\t\t\tText = itemNameOf(l.kind, l.id) .. " x" .. l.count .. "  -  " .. l.sellerName,
\t\t\t}, r)
\t\t\tUtil.create("TextLabel", {
\t\t\t\tAnchorPoint = Vector2.new(1, 0),
\t\t\t\tPosition = UDim2.new(1, -118, 0, 8),
\t\t\t\tSize = UDim2.fromOffset(100, 40),
\t\t\t\tBackgroundTransparency = 1,
\t\t\t\tFont = Enum.Font.GothamBlack,
\t\t\t\tTextScaled = true,
\t\t\t\tTextColor3 = T.Gold,
\t\t\t\tTextXAlignment = Enum.TextXAlignment.Right,
\t\t\t\tText = Util.formatNumber(l.price),
\t\t\t}, r)
\t\t\tbtn({
\t\t\t\tparent = r,
\t\t\t\tAnchorPoint = Vector2.new(1, 0),
\t\t\t\tPosition = UDim2.new(1, -8, 0, 10),
\t\t\t\tSize = UDim2.fromOffset(96, 36),
\t\t\t\tBackgroundColor3 = T.Green,
\t\t\t\tTextColor3 = Color3.fromRGB(20, 32, 26),
\t\t\t\tText = "Beli",
\t\t\t\t_radius = 8,
\t\t\t}).Activated:Connect(function()
\t\t\t\tlocal res = Remotes.get("MarketAction"):InvokeServer({ action = "buy", lid = l.lid })
\t\t\t\tself:handleResult(res)
\t\t\t\tself:refreshMarket()
\t\t\tend)
\t\tend
\t\tif not any then
\t\t\tlocal r = row(list, 60)
\t\t\tUtil.create("TextLabel", {
\t\t\t\tSize = UDim2.fromScale(1, 1),
\t\t\t\tBackgroundTransparency = 1,
\t\t\t\tFont = Enum.Font.Gotham,
\t\t\t\tTextScaled = true,
\t\t\t\tTextColor3 = T.TextDim,
\t\t\t\tText = "Papan masih kosong - jadilah penjual pertama di tab Jual Barang!",
\t\t\t}, r)
\t\tend
\t\treturn
\tend

\tif self.marketTab == "jual" then
\t\tUtil.create("TextLabel", {
\t\t\tSize = UDim2.new(1, -8, 0, 30),
\t\t\tBackgroundTransparency = 1,
\t\t\tFont = Enum.Font.Gotham,
\t\t\tTextScaled = true,
\t\t\tTextColor3 = T.TextDim,
\t\t\tTextXAlignment = Enum.TextXAlignment.Left,
\t\t\tText = "Tentukan harga (Micda). Jasa pasar " .. math.floor((snap.feeRate or 0.02) * 100) .. "% dipotong dari hasil jualmu.",
\t\t}, list)
\t\tlocal s = self.state
\t\tif s then
\t\t\tlocal sections = {
\t\t\t\t{ kind = "seed", data = s.Seeds },
\t\t\t\t{ kind = "crop", data = s.Crops },
\t\t\t\t{ kind = "bag", data = s.Bag },
\t\t\t\t{ kind = "fish", data = s.Fish },
\t\t\t\t{ kind = "equip", data = s.Equips },
\t\t\t\t{ kind = "use", data = s.Usables },
\t\t\t}
\t\t\tlocal any = false
\t\t\tfor _, section in sections do
\t\t\t\tfor id, count in section.data do
\t\t\t\t\tif count <= 0 then
\t\t\t\t\t\tcontinue
\t\t\t\t\tend
\t\t\t\t\tany = true
\t\t\t\t\tlocal r = row(list, 56)
\t\t\t\t\tUtil.create("TextLabel", {
\t\t\t\t\t\tPosition = UDim2.fromOffset(12, 8),
\t\t\t\t\t\tSize = UDim2.new(1, -300, 0, 40),
\t\t\t\t\t\tBackgroundTransparency = 1,
\t\t\t\t\t\tFont = Enum.Font.GothamBold,
\t\t\t\t\t\tTextScaled = true,
\t\t\t\t\t\tTextColor3 = T.Text,
\t\t\t\t\t\tTextXAlignment = Enum.TextXAlignment.Left,
\t\t\t\t\t\tText = itemNameOf(section.kind, id) .. " x" .. count,
\t\t\t\t\t}, r)
\t\t\t\t\tlocal priceBox = Util.create("TextBox", {
\t\t\t\t\t\tAnchorPoint = Vector2.new(1, 0),
\t\t\t\t\t\tPosition = UDim2.new(1, -118, 0, 10),
\t\t\t\t\t\tSize = UDim2.fromOffset(110, 36),
\t\t\t\t\t\tBackgroundColor3 = T.PanelLight,
\t\t\t\t\t\tTextColor3 = T.Gold,
\t\t\t\t\t\tFont = Enum.Font.GothamBold,
\t\t\t\t\t\tTextScaled = true,
\t\t\t\t\t\tPlaceholderText = "Harga",
\t\t\t\t\t\tClearTextOnFocus = true,
\t\t\t\t\t\tText = "",
\t\t\t\t\t}, r)
\t\t\t\t\tcorner(priceBox, 8)
\t\t\t\t\tbtn({
\t\t\t\t\t\tparent = r,
\t\t\t\t\t\tAnchorPoint = Vector2.new(1, 0),
\t\t\t\t\t\tPosition = UDim2.new(1, -8, 0, 10),
\t\t\t\t\t\tSize = UDim2.fromOffset(100, 36),
\t\t\t\t\t\tBackgroundColor3 = T.Gold,
\t\t\t\t\t\tTextColor3 = Color3.fromRGB(40, 30, 10),
\t\t\t\t\t\tText = "Pasang",
\t\t\t\t\t\t_radius = 8,
\t\t\t\t\t}).Activated:Connect(function()
\t\t\t\t\t\tlocal price = tonumber(priceBox.Text)
\t\t\t\t\t\tif not price or price < 1 then
\t\t\t\t\t\t\tself:toast("Papan Jual", "Tulis harga dulu (Micda).", T.Red)
\t\t\t\t\t\t\treturn
\t\t\t\t\t\tend
\t\t\t\t\t\tlocal res = Remotes.get("MarketAction"):InvokeServer({ action = "list", kind = section.kind, id = id, count = count, price = math.floor(price) })
\t\t\t\t\t\tself:handleResult(res)
\t\t\t\t\t\tself:refreshMarket()
\t\t\t\t\tend)
\t\t\t\tend
\t\t\tend
\t\t\tif not any then
\t\t\t\tlocal r = row(list, 60)
\t\t\t\tUtil.create("TextLabel", {
\t\t\t\t\tSize = UDim2.fromScale(1, 1),
\t\t\t\t\tBackgroundTransparency = 1,
\t\t\t\t\tFont = Enum.Font.Gotham,
\t\t\t\t\tTextScaled = true,
\t\t\t\t\tTextColor3 = T.TextDim,
\t\t\t\t\tText = "Tasmu kosong. Panen, tambang, memancing, atau kalahkan monster dulu!",
\t\t\t\t}, r)
\t\t\tend
\t\tend
\t\treturn
\tend

\t-- LELANGANKU
\tUtil.create("TextLabel", {
\t\tSize = UDim2.new(1, -8, 0, 30),
\t\tBackgroundTransparency = 1,
\t\tFont = Enum.Font.Gotham,
\t\tTextScaled = true,
\t\tTextColor3 = T.TextDim,
\t\tTextXAlignment = Enum.TextXAlignment.Left,
\t\tText = "Barangmu yang sedang dipajang:",
\t}, list)
\tlocal any = false
\tfor _, l in ipairs(snap.mine or {}) do
\t\tany = true
\t\tlocal r = row(list, 56)
\t\tUtil.create("TextLabel", {
\t\t\tPosition = UDim2.fromOffset(12, 8),
\t\t\tSize = UDim2.new(1, -220, 0, 40),
\t\t\tBackgroundTransparency = 1,
\t\t\tFont = Enum.Font.GothamBold,
\t\t\tTextScaled = true,
\t\t\tTextColor3 = T.Text,
\t\t\tTextXAlignment = Enum.TextXAlignment.Left,
\t\t\tText = itemNameOf(l.kind, l.id) .. " x" .. l.count .. "  @  " .. Util.formatNumber(l.price),
\t\t}, r)
\t\tbtn({
\t\t\tparent = r,
\t\t\tAnchorPoint = Vector2.new(1, 0),
\t\t\tPosition = UDim2.new(1, -8, 0, 10),
\t\t\tSize = UDim2.fromOffset(120, 36),
\t\t\tBackgroundColor3 = T.Red,
\t\t\tTextColor3 = Color3.new(1, 1, 1),
\t\t\tText = "Tarik",
\t\t\t_radius = 8,
\t\t}).Activated:Connect(function()
\t\t\tlocal res = Remotes.get("MarketAction"):InvokeServer({ action = "cancel", lid = l.lid })
\t\t\tself:handleResult(res)
\t\t\tself:refreshMarket()
\t\tend)
\tend
\tif not any then
\t\tlocal r = row(list, 60)
\t\tUtil.create("TextLabel", {
\t\t\tSize = UDim2.fromScale(1, 1),
\t\t\tBackgroundTransparency = 1,
\t\t\tFont = Enum.Font.Gotham,
\t\t\tTextScaled = true,
\t\t\tTextColor3 = T.TextDim,
\t\t\tText = "Belum ada barang dipajang. Hasil jual diantar walau kamu offline!",
\t\t}, r)
\tend
end

'''
src = src.replace(anchor, market + anchor, 1)

# ---------- 8) wireRemotes: OpenMarket + MarketSync ----------
old = """\tRemotes.get("OpenTrade").OnClientEvent:Connect(function()
\t\tself:renderTrade()
\t\tself:showPanel("Trade")
\tend)"""
new = """\tRemotes.get("OpenTrade").OnClientEvent:Connect(function()
\t\tself:renderTrade()
\t\tself:showPanel("Trade")
\tend)

\t-- v4: papan jual antar pemain
\tRemotes.get("OpenMarket").OnClientEvent:Connect(function()
\t\tself:showPanel("Market")
\t\tself:refreshMarket()
\tend)

\tRemotes.get("MarketSync").OnClientEvent:Connect(function(snap)
\t\tif type(snap) == "table" then
\t\t\tself.marketSnap = snap
\t\t\tif self.activePanel == "Market" then
\t\t\t\tself:renderMarket()
\t\t\tend
\t\tend
\tend)"""
old = T8(old); assert old in src, "wireRemotes"
src = src.replace(T8(old), T8(new), 1)

open(p, "w").write(src)
print("UIController v4 done")
