--!nonstrict
--[[
        UIController.luau - seluruh UI Dunia Akiomida v2 (dibangun lewat kode):
          HUD   : koin, level + bar XP, tombol Tas / Kode / Bantuan, tips, toast
          Toko  : tab Beli (bibit/alat/pet) & Jual (harga pasar dinamis)
          Tas   : bibit, hasil panen, sumber daya, ikan, alat, peliharaan
          Tanam : pilih bibit untuk petak ladang
          Kuis  : OPSIONAL - hanya muncul jika pemain menemui Kak Pintar
        Tidak ada popup paksa. Semua panel tertutup saat pemain menjelajah.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Remotes)
local Util = require(ReplicatedStorage.Shared.Util)

local UIController = {}
UIController.__index = UIController

local T = {
        Bg = Color3.fromRGB(20, 24, 34),
        Panel = Color3.fromRGB(30, 36, 50),
        PanelLight = Color3.fromRGB(44, 52, 70),
        Gold = Color3.fromRGB(255, 209, 102),
        Green = Color3.fromRGB(88, 200, 130),
        Red = Color3.fromRGB(235, 100, 100),
        Blue = Color3.fromRGB(99, 200, 255),
        Text = Color3.fromRGB(238, 238, 246),
        TextDim = Color3.fromRGB(170, 176, 192),
        Disabled = Color3.fromRGB(80, 86, 100),
}

local player = Players.LocalPlayer

local function corner(parent, radius)
        return Util.create("UICorner", { CornerRadius = UDim.new(0, radius or 10) }, parent)
end

local function makeSound(pitch: number?): Sound
        local s = Util.create("Sound", {
                SoundId = "rbxasset://sounds/electronicpingshort.wav",
                Volume = 0.3,
                PlaybackSpeed = pitch or 1,
        }, SoundService)
        return s :: Sound
end

local function btn(props): TextButton
        local b = Util.create("TextButton", {
                Font = Enum.Font.GothamBold,
                TextColor3 = T.Text,
                TextScaled = true,
                AutoButtonColor = true,
                BackgroundColor3 = T.PanelLight,
                BorderSizePixel = 0,
        }, props.parent)
        for k, v in props do
                if k ~= "parent" and k ~= "_radius" then
                        (b :: any)[k] = v
                end
        end
        corner(b, props._radius or 8)
        return b
end

function UIController.new()
        local self = setmetatable({}, UIController)

        self.state = nil
        self.activePanel = nil
        self.shopId = nil
        self.shopTab = "beli"
        self.pendingPlant = nil

        self:buildGui()
        self:buildHud()
        self:buildShopPanel()
        self:buildPlantPanel()
        self:buildInvPanel()
        self:buildQuizPanel()
        self:buildCodePanel()
        self:buildHelpPanel()
        self:wireRemotes()
        self:startTips()

        return self
end

--------------------------------------------------------------------
-- GUI DASAR
--------------------------------------------------------------------

function UIController:buildGui()
        self.gui = Util.create("ScreenGui", {
                Name = "AKM_HUD",
                ResetOnSpawn = false,
                IgnoreGuiInset = true,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        }, player:WaitForChild("PlayerGui"))
end

function UIController:panelFrame(name: string, sizeScale: number, heightScale: number): Frame
        local frame = Util.create("Frame", {
                Name = name,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(sizeScale, heightScale),
                BackgroundColor3 = T.Panel,
                BorderSizePixel = 0,
                Visible = false,
        }, self.gui)
        corner(frame, 14)
        Util.create("UISizeConstraint", { MinSize = Vector2.new(430, 360) }, frame)
        return frame
end

function UIController:showPanel(name: string?)
        for _, n in { "Shop", "Plant", "Inv", "Quiz", "Code", "Help" } do
                local f = self.gui:FindFirstChild(n)
                if f then
                        (f :: Frame).Visible = (n == name)
                end
        end
        self.activePanel = name
end

--------------------------------------------------------------------
-- HUD
--------------------------------------------------------------------

function UIController:buildHud()
        ---------------------------------------------------------------- chip koin
        local coinChip = Util.create("Frame", {
                Name = "KoinChip",
                Position = UDim2.fromOffset(16, 14),
                Size = UDim2.fromOffset(170, 46),
                BackgroundColor3 = T.Bg,
                BackgroundTransparency = 0.15,
                BorderSizePixel = 0,
        }, self.gui)
        corner(coinChip, 12)
        local coinIcon = Util.create("Frame", {
                Position = UDim2.fromOffset(7, 7),
                Size = UDim2.fromOffset(32, 32),
                BackgroundColor3 = T.Gold,
                BorderSizePixel = 0,
        }, coinChip)
        corner(coinIcon, 16)
        Util.create("TextLabel", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = Color3.fromRGB(120, 86, 20),
                Text = "$",
        }, coinIcon)
        self.coinText = Util.create("TextLabel", {
                Position = UDim2.fromOffset(44, 0),
                Size = UDim2.new(1, -50, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = T.Gold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "0",
        }, coinChip)

        ---------------------------------------------------------------- chip level + XP
        local levelChip = Util.create("Frame", {
                Name = "LevelChip",
                Position = UDim2.fromOffset(16, 66),
                Size = UDim2.fromOffset(170, 58),
                BackgroundColor3 = T.Bg,
                BackgroundTransparency = 0.15,
                BorderSizePixel = 0,
        }, self.gui)
        corner(levelChip, 12)
        self.levelText = Util.create("TextLabel", {
                Position = UDim2.fromOffset(10, 4),
                Size = UDim2.new(1, -20, 0, 26),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextScaled = true,
                TextColor3 = T.Blue,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "Level 1",
        }, levelChip)
        local barBg = Util.create("Frame", {
                Position = UDim2.fromOffset(10, 34),
                Size = UDim2.new(1, -20, 0, 14),
                BackgroundColor3 = T.PanelLight,
                BorderSizePixel = 0,
        }, levelChip)
        corner(barBg, 7)
        self.xpBar = Util.create("Frame", {
                Size = UDim2.fromScale(0, 1),
                BackgroundColor3 = T.Blue,
                BorderSizePixel = 0,
        }, barBg)
        corner(self.xpBar, 7)

        ---------------------------------------------------------------- tombol kanan atas
        local actions = {
                { name = "Tas", label = "Tas", color = T.Gold, cb = function()
                        self:renderInv()
                        self:showPanel("Inv")
                end },
                { name = "Kode", label = "Kode", color = T.Blue, cb = function()
                        self:showPanel("Code")
                end },
                { name = "Bantuan", label = "?", color = T.Green, cb = function()
                        self:showPanel("Help")
                end },
        }
        local i = 0
        for _, act in actions do
                i += 1
                btn({
                        parent = self.gui,
                        Name = "Btn" .. act.name,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -16 - (i - 1) * 92, 0, 14),
                        Size = UDim2.fromOffset(84, 42),
                        BackgroundColor3 = act.color,
                        TextColor3 = Color3.fromRGB(30, 30, 36),
                        Text = act.label,
                        _radius = 12,
                }).Activated:Connect(act.cb)
        end

        ---------------------------------------------------------------- tips bawah
        self.tipLabel = Util.create("TextLabel", {
                Name = "Tips",
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.new(0.5, 0, 1, -14),
                Size = UDim2.fromOffset(640, 34),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextScaled = true,
                TextColor3 = T.TextDim,
                TextStrokeTransparency = 0.7,
                Text = "",
        }, self.gui)

        ---------------------------------------------------------------- kontainer toast
        self.toastHolder = Util.create("Frame", {
                Name = "Toasts",
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.new(0.5, 0, 1, -56),
                Size = UDim2.fromOffset(460, 150),
                BackgroundTransparency = 1,
        }, self.gui)
        Util.create("UIListLayout", {
                Padding = UDim.new(0, 6),
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
        }, self.toastHolder)
end

local TIPS = {
        "Klaim ladang GRATIS di Kawasan Ladang (Utara), lalu tanami bibit!",
        "Jual hasil panen ke Bu Laris di Pasar Pengepul - harga pasar berubah tiap 10 menit!",
        "Tebang pohon di Hutan Kayu untuk Kayu, dan tambang bijih di Tambang Selatan.",
        "Kucing Koin memberi +10% harga jual. Lihat Toko Peliharaan!",
        "Crops tumbuh nyata waktu - tanam lalu jelajahi dunia sambil menunggu.",
        "Pakai Kaleng Siram supaya tanaman tumbuh 25% lebih cepat.",
        "Bonus login harian 100 koin. Datang lagi besok!",
        "Kuis Kak Pintar di alun-alun memberi koin bonus - sepenuhnya opsional.",
}

function UIController:startTips()
        task.spawn(function()
                local idx = 0
                while true do
                        idx += 1
                        local tip = TIPS[(idx - 1) % #TIPS + 1]
                        if self.tipLabel then
                                self.tipLabel.Text = tip
                        end
                        task.wait(14)
                end
        end)
end

function UIController:toast(title: string, text: string, color: Color3?)
        local c = color or T.Gold
        local toast = Util.create("Frame", {
                Size = UDim2.new(1, 0, 0, 52),
                BackgroundColor3 = T.Bg,
                BackgroundTransparency = 0.12,
                BorderSizePixel = 0,
        }, self.toastHolder)
        corner(toast, 10)
        Util.create("Frame", {
                Size = UDim2.fromOffset(6, 36),
                Position = UDim2.fromOffset(8, 8),
                BackgroundColor3 = c,
                BorderSizePixel = 0,
        }, toast)
        Util.create("TextLabel", {
                Position = UDim2.fromOffset(22, 3),
                Size = UDim2.new(1, -30, 0, 20),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextScaled = true,
                TextColor3 = c,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = title,
        }, toast)
        Util.create("TextLabel", {
                Position = UDim2.fromOffset(22, 24),
                Size = UDim2.new(1, -30, 0, 26),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                TextScaled = true,
                TextColor3 = T.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = text,
        }, toast)

        task.delay(4.5, function()
                if toast.Parent then
                        toast:Destroy()
                end
        end)
end

--------------------------------------------------------------------
-- STATE -> HUD
--------------------------------------------------------------------

function UIController:renderState()
        local s = self.state
        if not s then
                return
        end
        self.coinText.Text = Util.formatNumber(s.Coins)
        self.levelText.Text = "Level " .. s.Level .. (s.Dev and "  [DEV]" or "")
        self.xpBar.Size = UDim2.fromScale(math.clamp(s.LevelPct, 0.02, 1), 1)

        -- refresh panel terbuka supaya harga/inv tetap segar
        if self.activePanel == "Shop" and self.shopId then
                self:renderShop()
        elseif self.activePanel == "Plant" and self.pendingPlant then
                self:renderPlantPanel()
        elseif self.activePanel == "Inv" then
                self:renderInv()
        end
end

--------------------------------------------------------------------
-- PANEL TOKO
--------------------------------------------------------------------

function UIController:buildShopPanel()
        local frame = self:panelFrame("Shop", 0.46, 0.62)
        self.shopFrame = frame

        Util.create("TextLabel", {
                Name = "Judul",
                Size = UDim2.new(1, -60, 0, 40),
                Position = UDim2.fromOffset(18, 10),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = T.Gold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "Toko",
        }, frame)

        btn({
                parent = frame,
                Name = "Tutup",
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -12, 0, 10),
                Size = UDim2.fromOffset(40, 34),
                BackgroundColor3 = T.Red,
                TextColor3 = Color3.new(1, 1, 1),
                Text = "X",
                _radius = 8,
        }).Activated:Connect(function()
                self:showPanel(nil)
        end)

        local tabBeli = btn({
                parent = frame,
                Name = "TabBeli",
                Position = UDim2.fromOffset(18, 56),
                Size = UDim2.fromOffset(110, 34),
                BackgroundColor3 = T.Green,
                TextColor3 = Color3.fromRGB(24, 30, 26),
                Text = "Beli",
                _radius = 8,
        })
        local tabJual = btn({
                parent = frame,
                Name = "TabJual",
                Position = UDim2.fromOffset(134, 56),
                Size = UDim2.fromOffset(110, 34),
                BackgroundColor3 = T.PanelLight,
                TextColor3 = T.Text,
                Text = "Jual",
                _radius = 8,
        })
        tabBeli.Activated:Connect(function()
                self.shopTab = "beli"
                self:renderShop()
        end)
        tabJual.Activated:Connect(function()
                self.shopTab = "jual"
                self:renderShop()
        end)
        self.tabBeliBtn = tabBeli
        self.tabJualBtn = tabJual

        local scroll = Util.create("ScrollingFrame", {
                Name = "List",
                Position = UDim2.fromOffset(18, 98),
                Size = UDim2.new(1, -36, 1, -116),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                CanvasSize = UDim2.new(),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 6,
        }, frame)
        Util.create("UIListLayout", { Padding = UDim.new(0, 8) }, scroll)
        self.shopList = scroll
end

local function row(parent, height: number): Frame
        local r = Util.create("Frame", {
                Size = UDim2.new(1, -8, 0, height),
                BackgroundColor3 = T.PanelLight,
                BorderSizePixel = 0,
        }, parent)
        corner(r, 10)
        return r
end

local function swatch(parent: Frame, color: Color3, label: string?)
        local icon = Util.create("Frame", {
                Position = UDim2.fromOffset(10, 10),
                Size = UDim2.fromOffset(44, 44),
                BackgroundColor3 = color,
                BorderSizePixel = 0,
        }, parent)
        corner(icon, 10)
        if label then
                Util.create("TextLabel", {
                        Size = UDim2.fromScale(1, 1),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBlack,
                        TextScaled = true,
                        TextColor3 = Color3.fromRGB(40, 36, 26),
                        Text = label,
                }, icon)
        end
        return icon
end

function UIController:shopItemsFor(shopId: string)
        if shopId == "bibit" then
                return Config.Crops
        elseif shopId == "alat" then
                return Config.Tools
        elseif shopId == "pet" then
                return Config.Pets
        end
        return {}
end

function UIController:petBonus(): number
        local s = self.state
        if not s or s.ActivePet == "" then
                return 0
        end
        for _, pet in Config.Pets do
                if pet.id == s.ActivePet then
                        return pet.bonus
                end
        end
        return 0
end

function UIController:clientPrice(baseSell: number, itemId: string): number
        local s = self.state
        local demand = (s and s.Demand and s.Demand[itemId]) or 1
        local price = baseSell * demand * (1 + self:petBonus())
        return math.max(1, math.floor(price + 0.5))
end

function UIController:renderShop()
        local s = self.state
        local list = self.shopList
        for _, child in list:GetChildren() do
                if child:IsA("Frame") then
                        child:Destroy()
                end
        end
        if not s then
                return
        end

        local titles = { bibit = "Toko Bibit - Kak Tani", alat = "Toko Alat - Pak Bang", pet = "Toko Peliharaan - Mbah Sekar", jual = "Pasar Pengepul - Bu Laris" }
        local judul = self.shopFrame:FindFirstChild("Judul") :: TextLabel?
        if judul then
                judul.Text = titles[self.shopId] or "Toko"
        end

        self.tabBeliBtn.Visible = self.shopId ~= "jual"
        self.tabJualBtn.Visible = self.shopId == "jual"
        self.tabBeliBtn.BackgroundColor3 = self.shopTab == "beli" and T.Green or T.PanelLight
        self.tabJualBtn.BackgroundColor3 = self.shopTab == "jual" and T.Green or T.PanelLight

        ---------------------------------------------------------------- tab jual
        if self.shopId == "jual" then
                local any = false
                local sections = {
                        { kind = "crop", data = s.Crops, lookup = Config.Crops, label = "PANEN" },
                        { kind = "bag", data = s.Bag, lookup = Config.Resources, label = "SUMBER DAYA" },
                        { kind = "fish", data = s.Fish, lookup = Config.Fish, label = "IKAN" },
                }
                for _, section in sections do
                        for id, count in section.data do
                                if count <= 0 then
                                        continue
                                end
                                local def = nil
                                for _, d in section.lookup do
                                        if d.id == id then
                                                def = d
                                                break
                                        end
                                end
                                if not def then
                                        continue
                                end
                                any = true
                                local unit = self:clientPrice(def.sell, id)
                                local r = row(list, 66)
                                local color = (def.color and Color3.fromRGB(def.color[1], def.color[2], def.color[3])) or T.Blue
                                swatch(r, color)
                                Util.create("TextLabel", {
                                        Position = UDim2.fromOffset(62, 6),
                                        Size = UDim2.new(1, -240, 0, 28),
                                        BackgroundTransparency = 1,
                                        Font = Enum.Font.GothamBold,
                                        TextScaled = true,
                                        TextColor3 = T.Text,
                                        TextXAlignment = Enum.TextXAlignment.Left,
                                        Text = def.name .. " x" .. count .. "  (@" .. unit .. " koin)",
                                }, r)
                                Util.create("TextLabel", {
                                        Position = UDim2.fromOffset(62, 36),
                                        Size = UDim2.new(1, -240, 0, 22),
                                        BackgroundTransparency = 1,
                                        Font = Enum.Font.Gotham,
                                        TextScaled = true,
                                        TextColor3 = T.TextDim,
                                        TextXAlignment = Enum.TextXAlignment.Left,
                                        Text = section.label .. " - permintaan pasar x" .. ((s.Demand and s.Demand[id]) or 1),
                                }, r)
                                btn({
                                        parent = r,
                                        AnchorPoint = Vector2.new(1, 0),
                                        Position = UDim2.new(1, -66, 0, 14),
                                        Size = UDim2.fromOffset(56, 38),
                                        BackgroundColor3 = T.Gold,
                                        TextColor3 = Color3.fromRGB(40, 30, 10),
                                        Text = "1x",
                                        _radius = 8,
                                }).Activated:Connect(function()
                                        local res = Remotes.get("SellItem"):InvokeServer(section.kind, id, false)
                                        self:handleResult(res)
                                end)
                                btn({
                                        parent = r,
                                        AnchorPoint = Vector2.new(1, 0),
                                        Position = UDim2.new(1, -8, 0, 14),
                                        Size = UDim2.fromOffset(52, 38),
                                        BackgroundColor3 = T.Green,
                                        TextColor3 = Color3.fromRGB(24, 30, 26),
                                        Text = "Semua",
                                        _radius = 8,
                                }).Activated:Connect(function()
                                        local res = Remotes.get("SellItem"):InvokeServer(section.kind, id, true)
                                        self:handleResult(res)
                                end)
                        end
                end
                if not any then
                        local r = row(list, 60)
                        Util.create("TextLabel", {
                                Size = UDim2.fromScale(1, 1),
                                BackgroundTransparency = 1,
                                Font = Enum.Font.GothamBold,
                                TextScaled = true,
                                TextColor3 = T.TextDim,
                                Text = "Tasmu masih kosong - tanam, tebang, atau mancing dulu!",
                        }, r)
                end
                -- tombol jual semua
                local sellAll = btn({
                        parent = list,
                        Size = UDim2.new(1, -8, 0, 44),
                        BackgroundColor3 = T.Gold,
                        TextColor3 = Color3.fromRGB(40, 30, 10),
                        Text = "JUAL SEMUA ISI TAS",
                        _radius = 10,
                })
                sellAll.Activated:Connect(function()
                        local res = Remotes.get("SellAll"):InvokeServer()
                        self:handleResult(res)
                end)
                return
        end

        ---------------------------------------------------------------- tab beli
        for _, item in self:shopItemsFor(self.shopId) do
                local isCrop = self.shopId == "bibit"
                local isTool = self.shopId == "alat"
                local isPet = self.shopId == "pet"
                local owned = false
                if isTool then
                        local t = s.Tools
                        if item.id == "pick2" then
                                owned = t.pickTier >= 2
                        elseif item.id == "pick3" then
                                owned = t.pickTier >= 3
                        else
                                owned = t[item.id] == true
                        end
                elseif isPet then
                        owned = s.Pets[item.id] == true
                end
                local locked = isCrop and s.Level < item.level
                local r = row(list, 66)
                local color = (item.color and Color3.fromRGB(item.color[1], item.color[2], item.color[3])) or T.Blue
                swatch(r, color, isCrop and "B" or nil)
                Util.create("TextLabel", {
                        Position = UDim2.fromOffset(62, 6),
                        Size = UDim2.new(1, -240, 0, 28),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextScaled = true,
                        TextColor3 = T.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = (isCrop and "Bibit " or "") .. item.name .. (owned and "  [DIMILIKI]" or ""),
                }, r)
                Util.create("TextLabel", {
                        Position = UDim2.fromOffset(62, 36),
                        Size = UDim2.new(1, -240, 0, 22),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.Gotham,
                        TextScaled = true,
                        TextColor3 = T.TextDim,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = isCrop and ("Tumbuh " .. item.grow .. "s - jual " .. self:clientPrice(item.sell, item.id) .. " koin")
                                or (item.desc or ""),
                }, r)
                local buyBtn = btn({
                        parent = r,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -8, 0, 14),
                        Size = UDim2.fromOffset(96, 38),
                        BackgroundColor3 = owned and T.Disabled or T.Gold,
                        TextColor3 = owned and T.Text or Color3.fromRGB(40, 30, 10),
                        Text = owned and "Milikmu" or (locked and "Lv " .. item.level or item.cost .. " koin"),
                        _radius = 8,
                })
                buyBtn.Activated:Connect(function()
                        if isPet and owned then
                                local res = Remotes.get("EquipPet"):InvokeServer(item.id)
                                self:handleResult(res)
                                return
                        end
                        if owned then
                                return
                        end
                        local res = Remotes.get("BuyItem"):InvokeServer(self.shopId, item.id)
                        self:handleResult(res)
                end)
        end
end

--------------------------------------------------------------------
-- PANEL TANAM
--------------------------------------------------------------------

function UIController:buildPlantPanel()
        local frame = self:panelFrame("Plant", 0.36, 0.52)
        Util.create("TextLabel", {
                Name = "Judul",
                Size = UDim2.new(1, -60, 0, 36),
                Position = UDim2.fromOffset(18, 10),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = T.Green,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "Pilih Bibit",
        }, frame)
        btn({
                parent = frame,
                Name = "Tutup",
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -12, 0, 10),
                Size = UDim2.fromOffset(40, 34),
                BackgroundColor3 = T.Red,
                TextColor3 = Color3.new(1, 1, 1),
                Text = "X",
                _radius = 8,
        }).Activated:Connect(function()
                self:showPanel(nil)
        end)

        local scroll = Util.create("ScrollingFrame", {
                Name = "List",
                Position = UDim2.fromOffset(18, 54),
                Size = UDim2.new(1, -36, 1, -72),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                CanvasSize = UDim2.new(),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 6,
        }, frame)
        Util.create("UIListLayout", { Padding = UDim.new(0, 8) }, scroll)
        self.plantList = scroll
end

function UIController:renderPlantPanel()
        local s = self.state
        local list = self.plantList
        for _, child in list:GetChildren() do
                if child:IsA("Frame") then
                        child:Destroy()
                end
        end
        if not s or not self.pendingPlant then
                return
        end
        local any = false
        for _, crop in Config.Crops do
                local count = s.Seeds[crop.id] or 0
                if count <= 0 then
                        continue
                end
                any = true
                local locked = s.Level < crop.level
                local r = row(list, 66)
                local color = Color3.fromRGB(crop.color[1], crop.color[2], crop.color[3])
                swatch(r, color)
                Util.create("TextLabel", {
                        Position = UDim2.fromOffset(62, 6),
                        Size = UDim2.new(1, -170, 0, 28),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextScaled = true,
                        TextColor3 = T.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = "Bibit " .. crop.name .. " x" .. count,
                }, r)
                Util.create("TextLabel", {
                        Position = UDim2.fromOffset(62, 36),
                        Size = UDim2.new(1, -170, 0, 22),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.Gotham,
                        TextScaled = true,
                        TextColor3 = T.TextDim,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = "Tumbuh " .. crop.grow .. "s - jual " .. self:clientPrice(crop.sell, crop.id) .. " koin",
                }, r)
                btn({
                        parent = r,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -8, 0, 14),
                        Size = UDim2.fromOffset(86, 38),
                        BackgroundColor3 = locked and T.Disabled or T.Green,
                        TextColor3 = locked and T.Text or Color3.fromRGB(24, 30, 26),
                        Text = locked and "Lv " .. crop.level or "Tanam",
                        _radius = 8,
                }).Activated:Connect(function()
                        local pp = self.pendingPlant
                        if not pp then
                                return
                        end
                        local res = Remotes.get("PlantSeed"):InvokeServer(pp.plot, pp.tile, crop.id)
                        self:handleResult(res)
                        if res and res.ok then
                                self:showPanel(nil)
                        end
                end)
        end
        if not any then
                local r = row(list, 60)
                Util.create("TextLabel", {
                        Size = UDim2.fromScale(1, 1),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextScaled = true,
                        TextColor3 = T.TextDim,
                        Text = "Tidak ada bibit. Beli di Toko Bibit (Pasar Timur)!",
                }, r)
        end
end

--------------------------------------------------------------------
-- PANEL TAS
--------------------------------------------------------------------

function UIController:buildInvPanel()
        local frame = self:panelFrame("Inv", 0.42, 0.6)
        Util.create("TextLabel", {
                Name = "Judul",
                Size = UDim2.new(1, -60, 0, 36),
                Position = UDim2.fromOffset(18, 10),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = T.Gold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "Tas Petualang",
        }, frame)
        btn({
                parent = frame,
                Name = "Tutup",
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -12, 0, 10),
                Size = UDim2.fromOffset(40, 34),
                BackgroundColor3 = T.Red,
                TextColor3 = Color3.new(1, 1, 1),
                Text = "X",
                _radius = 8,
        }).Activated:Connect(function()
                self:showPanel(nil)
        end)

        local scroll = Util.create("ScrollingFrame", {
                Name = "List",
                Position = UDim2.fromOffset(18, 54),
                Size = UDim2.new(1, -36, 1, -72),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                CanvasSize = UDim2.new(),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 6,
        }, frame)
        Util.create("UIListLayout", { Padding = UDim.new(0, 8) }, scroll)
        self.invList = scroll
end

function UIController:renderInv()
        local s = self.state
        local list = self.invList
        for _, child in list:GetChildren() do
                if child:IsA("Frame") then
                        child:Destroy()
                end
        end
        if not s then
                return
        end

        local function invRow(labelText: string, subText: string, color: Color3, actionText: string?, actionCb)
                local r = row(list, 60)
                swatch(r, color)
                Util.create("TextLabel", {
                        Position = UDim2.fromOffset(62, 6),
                        Size = UDim2.new(1, actionText and -170 or -80, 0, 26),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextScaled = true,
                        TextColor3 = T.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = labelText,
                }, r)
                Util.create("TextLabel", {
                        Position = UDim2.fromOffset(62, 32),
                        Size = UDim2.new(1, actionText and -170 or -80, 0, 22),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.Gotham,
                        TextScaled = true,
                        TextColor3 = T.TextDim,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = subText,
                }, r)
                if actionText and actionCb then
                        btn({
                                parent = r,
                                AnchorPoint = Vector2.new(1, 0),
                                Position = UDim2.new(1, -8, 0, 12),
                                Size = UDim2.fromOffset(90, 36),
                                BackgroundColor3 = T.Green,
                                TextColor3 = Color3.fromRGB(24, 30, 26),
                                Text = actionText,
                                _radius = 8,
                        }).Activated:Connect(actionCb)
                end
        end

        -- alat
        local t = s.Tools
        local toolList = {}
        if t.can then
                table.insert(toolList, "Kaleng Siram")
        end
        if t.rod then
                table.insert(toolList, "Pancing Ajaib")
        end
        if t.bike then
                table.insert(toolList, "Sepeda Angin")
        end
        table.insert(toolList, "Belik Tingkat " .. t.pickTier)
        invRow("Alat", table.concat(toolList, ", "), T.Blue)

        -- peliharaan
        local petNames = {}
        for _, pet in Config.Pets do
                if s.Pets[pet.id] then
                        table.insert(petNames, pet.name)
                end
        end
        if #petNames > 0 then
                local activeName = "-"
                for _, pet in Config.Pets do
                        if pet.id == s.ActivePet then
                                activeName = pet.name
                        end
                end
                invRow("Peliharaan: " .. activeName, "Koleksi: " .. table.concat(petNames, ", "), T.Gold,
                        s.ActivePet ~= "" and "Istirahat" or nil,
                        function()
                                local res = Remotes.get("EquipPet"):InvokeServer("")
                                self:handleResult(res)
                        end)
        else
                invRow("Peliharaan", "Belum punya - lihat Toko Peliharaan!", T.Gold)
        end

        -- ladang
        local plotText = "Belum klaim - ambil alih gratis di Kawasan Ladang!"
        if s.Plot.claimed then
                local ready = 0
                local growing = 0
                for _, tile in s.Plot.tiles do
                        if tile.state == "ready" then
                                ready += 1
                        elseif tile.state == "growing" then
                                growing += 1
                        end
                end
                plotText = "Ladang " .. (s.Plot.index or "?") .. " - tumbuh: " .. growing .. ", siap panen: " .. ready
        end
        invRow("Ladang", plotText, T.Green)

        -- inventaris
        local sections = {
                { title = "BIBIT", data = s.Seeds, lookup = Config.Crops, kind = "seed" },
                { title = "HASIL PANEN", data = s.Crops, lookup = Config.Crops, kind = "crop" },
                { title = "SUMBER DAYA", data = s.Bag, lookup = Config.Resources, kind = "bag" },
                { title = "IKAN", data = s.Fish, lookup = Config.Fish, kind = "fish" },
        }
        for _, section in sections do
                local any = false
                for id, count in section.data do
                        if count <= 0 then
                                continue
                        end
                        local def = nil
                        for _, d in section.lookup do
                                if d.id == id then
                                        def = d
                                        break
                                end
                        end
                        if def then
                                any = true
                                local color = (def.color and Color3.fromRGB(def.color[1], def.color[2], def.color[3])) or T.Blue
                                invRow(def.name .. " x" .. count,
                                        section.title .. " - jual @" .. self:clientPrice(def.sell, id) .. " koin",
                                        color)
                        end
                end
                if not any then
                        invRow(section.title, "- kosong -", T.Disabled)
                end
        end
end

--------------------------------------------------------------------
-- PANEL KUIS (opsional, via Kak Pintar)
--------------------------------------------------------------------

function UIController:buildQuizPanel()
        local frame = self:panelFrame("Quiz", 0.4, 0.5)
        Util.create("TextLabel", {
                Name = "Judul",
                Size = UDim2.new(1, -60, 0, 36),
                Position = UDim2.fromOffset(18, 10),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = T.Green,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "Kuis Bonus Kak Pintar",
        }, frame)
        btn({
                parent = frame,
                Name = "Tutup",
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -12, 0, 10),
                Size = UDim2.fromOffset(40, 34),
                BackgroundColor3 = T.Red,
                TextColor3 = Color3.new(1, 1, 1),
                Text = "X",
                _radius = 8,
        }).Activated:Connect(function()
                self:showPanel(nil)
        end)

        self.quizQuestion = Util.create("TextLabel", {
                Name = "Soal",
                Position = UDim2.fromOffset(18, 52),
                Size = UDim2.new(1, -36, 0, 64),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextScaled = true,
                TextColor3 = T.Text,
                TextWrapped = true,
                Text = "",
        }, frame)

        local scroll = Util.create("ScrollingFrame", {
                Name = "List",
                Position = UDim2.fromOffset(18, 124),
                Size = UDim2.new(1, -36, 1, -190),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                CanvasSize = UDim2.new(),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 6,
        }, frame)
        Util.create("UIListLayout", { Padding = UDim.new(0, 8) }, scroll)
        self.quizList = scroll

        self.quizFeedback = Util.create("TextLabel", {
                Name = "Feedback",
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(0, 18, 1, -12),
                Size = UDim2.new(1, -36, 0, 52),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                TextScaled = true,
                TextColor3 = T.TextDim,
                TextWrapped = true,
                Text = "",
        }, frame)
end

function UIController:requestQuiz()
        local list = self.quizList
        for _, child in list:GetChildren() do
                if child:IsA("TextButton") or child:IsA("Frame") then
                        child:Destroy()
                end
        end
        self.quizQuestion.Text = ""
        self.quizFeedback.Text = ""
        local res = Remotes.get("QuizRequest"):InvokeServer()
        if not res then
                return
        end
        if res.cooldown then
                self.quizFeedback.Text = "Sabar - kuis berikutnya bisa dalam " .. res.cooldown .. " detik."
                return
        end
        self.quizQuestion.Text = res.t
        for i, opsi in res.opsi do
                local answerBtn = btn({
                        parent = list,
                        Size = UDim2.new(1, -8, 0, 46),
                        BackgroundColor3 = T.PanelLight,
                        TextColor3 = T.Text,
                        Text = opsi,
                        _radius = 10,
                })
                answerBtn.Activated:Connect(function()
                        local result = Remotes.get("QuizAnswer"):InvokeServer(res.qid, i)
                        if not result then
                                return
                        end
                        if result.correct then
                                self.quizFeedback.Text = "BENAR! " .. result.msg
                                self:toast("Kuis Bonus", "+" .. result.reward .. " koin!", T.Green)
                                makeSound(1.3):Play()
                        else
                                self.quizFeedback.Text = result.msg or "Belum tepat - coba lagi nanti."
                        end
                        for _, child2 in list:GetChildren() do
                                if child2:IsA("TextButton") then
                                        child2.BackgroundColor3 = T.Disabled
                                end
                        end
                end)
        end
end

--------------------------------------------------------------------
-- PANEL KODE + BANTUAN
--------------------------------------------------------------------

function UIController:buildCodePanel()
        local frame = self:panelFrame("Code", 0.3, 0.3)
        Util.create("TextLabel", {
                Name = "Judul",
                Size = UDim2.new(1, -60, 0, 36),
                Position = UDim2.fromOffset(18, 10),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = T.Blue,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "Kode Penjelajah",
        }, frame)
        btn({
                parent = frame,
                Name = "Tutup",
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -12, 0, 10),
                Size = UDim2.fromOffset(40, 34),
                BackgroundColor3 = T.Red,
                TextColor3 = Color3.new(1, 1, 1),
                Text = "X",
                _radius = 8,
        }).Activated:Connect(function()
                self:showPanel(nil)
        end)

        local input = Util.create("TextBox", {
                Name = "Input",
                Position = UDim2.fromOffset(18, 56),
                Size = UDim2.new(1, -120, 0, 42),
                BackgroundColor3 = T.PanelLight,
                TextColor3 = T.Text,
                Font = Enum.Font.GothamBold,
                TextScaled = true,
                PlaceholderText = "Tulis kode di sini...",
                ClearTextOnFocus = false,
                Text = "",
        }, frame)
        corner(input, 8)
        btn({
                parent = frame,
                Name = "Tukar",
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -14, 0, 56),
                Size = UDim2.fromOffset(96, 42),
                BackgroundColor3 = T.Gold,
                TextColor3 = Color3.fromRGB(40, 30, 10),
                Text = "Tukar",
                _radius = 8,
        }).Activated:Connect(function()
                local code = input.Text
                if code == "" then
                        return
                end
                local ok, msg = Remotes.get("RedeemDevCode"):InvokeServer(code)
                if ok then
                        self:toast("Kode Diterima", msg or "Hadiah masuk!", T.Green)
                        self:showPanel(nil)
                else
                        self:toast("Kode Salah", msg or "Coba kode lain.", T.Red)
                end
        end)
end

function UIController:buildHelpPanel()
        local frame = self:panelFrame("Help", 0.44, 0.58)
        Util.create("TextLabel", {
                Name = "Judul",
                Size = UDim2.new(1, -60, 0, 36),
                Position = UDim2.fromOffset(18, 10),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = T.Green,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "Cara Hidup di Dunia Akiomida",
        }, frame)
        btn({
                parent = frame,
                Name = "Tutup",
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -12, 0, 10),
                Size = UDim2.fromOffset(40, 34),
                BackgroundColor3 = T.Red,
                TextColor3 = Color3.new(1, 1, 1),
                Text = "X",
                _radius = 8,
        }).Activated:Connect(function()
                self:showPanel(nil)
        end)

        Util.create("TextLabel", {
                Name = "Isi",
                Position = UDim2.fromOffset(18, 54),
                Size = UDim2.new(1, -36, 1, -72),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                TextScaled = true,
                TextColor3 = T.Text,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                Text = table.concat({
                        "1. KLAIM LADANG (utara): dekati papan Ladang, tekan Ambil Alih. Gratis!",
                        "2. BELI BIBIT (Pasar Timur): Kak Tani menjual bibit wortel s/d melon bintang.",
                        "3. TANAM: dekati petak tanah coklat, tekan E, pilih bibit.",
                        "4. TUMBUH NYATA WAKTU: tanaman tumbuh saat kamu menjelajah. Siram dengan Kaleng Siram untuk +25% kecepatan.",
                        "5. PANEN: petak bercahaya = siap. Tekan E untuk panen.",
                        "6. JUAL: Bu Laris di Pasar Pengepul. Harga pasar naik-turun tiap 10 menit - jual saat permintaan tinggi!",
                        "7. KUMPUL: tebang pohon di Hutan Kayu, tambang batu/besi/kristal di Tambang Selatan (perlu Belik), mancing di Danau Tenang (perlu Pancing).",
                        "8. KAYA: beli peliharaan (bonus jual), Sepeda Angin (lari cepat), upgrade belik.",
                        "9. LEVEL: semua aktivitas memberi XP. Level tinggi membuka bibit mahal.",
                        "10. KUIS Kak Pintar opsional: +20 koin per jawaban benar. Diabaikan juga tidak apa-apa.",
                }, "\n"),
        }, frame)
end

--------------------------------------------------------------------
-- REMOTES & RESULT
--------------------------------------------------------------------

function UIController:handleResult(res)
        if not res then
                return
        end
        if res.ok then
                self:toast("Berhasil", res.msg or "", T.Green)
                makeSound(1.2):Play()
        else
                self:toast("Gagal", res.msg or "Coba lagi.", T.Red)
                makeSound(0.8):Play()
        end
end

function UIController:wireRemotes()
        Remotes.get("StateSync").OnClientEvent:Connect(function(state)
                self.state = state
                self:renderState()
        end)

        Remotes.get("Notify").OnClientEvent:Connect(function(title, text)
                self:toast(title, text, T.Gold)
        end)

        Remotes.get("OpenShop").OnClientEvent:Connect(function(shopId)
                self.shopId = shopId
                self.shopTab = (shopId == "jual") and "jual" or "beli"
                self:renderShop()
                self:showPanel("Shop")
        end)

        Remotes.get("OpenPlant").OnClientEvent:Connect(function(plotIndex, tileIndex)
                self.pendingPlant = { plot = plotIndex, tile = tileIndex }
                self:renderPlantPanel()
                self:showPanel("Plant")
        end)

        Remotes.get("OpenQuiz").OnClientEvent:Connect(function()
                self:showPanel("Quiz")
                self:requestQuiz()
        end)

        -- minta state awal (fallback kalau StateSync pertama terlewat)
        task.spawn(function()
                task.wait(2)
                local ok, state = pcall(function()
                        return Remotes.get("GetState"):InvokeServer()
                end)
                if ok and state then
                        self.state = state
                        self:renderState()
                end
        end)
end

return UIController
