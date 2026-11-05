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
local Balance = require(ReplicatedStorage.Shared.Balance)
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
        self.craftStation = nil
        self.tradeSnap = nil
        self.inviteFrom = nil
        self.bossInfo = nil

        self:buildGui()
        self:buildHud()
        self:buildShopPanel()
        self:buildPlantPanel()
        self:buildInvPanel()
        self:buildQuizPanel()
        self:buildCodePanel()
        self:buildHelpPanel()
        self:buildCharPanel()
        self:buildCraftPanel()
        self:buildQuestPanel()
        self:buildTradePanel()
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
        for _, n in { "Shop", "Plant", "Inv", "Quiz", "Code", "Help", "Char", "Craft", "Quest", "Trade" } do
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

        ---------------------------------------------------------------- chip HP (v3)
        local hpChip = Util.create("Frame", {
                Name = "HpChip",
                Position = UDim2.fromOffset(16, 130),
                Size = UDim2.fromOffset(170, 46),
                BackgroundColor3 = T.Bg,
                BackgroundTransparency = 0.15,
                BorderSizePixel = 0,
        }, self.gui)
        corner(hpChip, 12)
        self.hpText = Util.create("TextLabel", {
                Position = UDim2.fromOffset(10, 3),
                Size = UDim2.new(1, -20, 0, 22),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextScaled = true,
                TextColor3 = T.Red,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "HP 100/100",
        }, hpChip)
        local hpBg = Util.create("Frame", {
                Position = UDim2.fromOffset(10, 28),
                Size = UDim2.new(1, -20, 0, 12),
                BackgroundColor3 = T.PanelLight,
                BorderSizePixel = 0,
        }, hpChip)
        corner(hpBg, 6)
        self.hpBar = Util.create("Frame", {
                Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = Color3.fromRGB(235, 90, 90),
                BorderSizePixel = 0,
        }, hpBg)
        corner(self.hpBar, 6)

        ---------------------------------------------------------------- chip tugas aktif (v3)
        self.questChip = Util.create("TextLabel", {
                Name = "QuestChip",
                Position = UDim2.fromOffset(16, 182),
                Size = UDim2.fromOffset(240, 54),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                TextScaled = true,
                TextColor3 = T.Gold,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextStrokeTransparency = 0.8,
                Text = "",
                Visible = false,
        }, self.gui)

        ---------------------------------------------------------------- bar boss raid (v3, atas tengah)
        local bossBar = Util.create("Frame", {
                Name = "BossBar",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(0.5, 0, 0, 12),
                Size = UDim2.fromOffset(430, 62),
                BackgroundColor3 = T.Bg,
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                Visible = false,
        }, self.gui)
        corner(bossBar, 12)
        self.bossTitle = Util.create("TextLabel", {
                Size = UDim2.new(1, -16, 0, 24),
                Position = UDim2.fromOffset(8, 4),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = Color3.fromRGB(255, 90, 90),
                Text = "RAJA GOLEM",
        }, bossBar)
        local bossBg = Util.create("Frame", {
                Position = UDim2.fromOffset(12, 32),
                Size = UDim2.new(1, -24, 0, 20),
                BackgroundColor3 = Color3.fromRGB(60, 20, 20),
                BorderSizePixel = 0,
        }, bossBar)
        corner(bossBg, 8)
        self.bossHp = Util.create("Frame", {
                Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = Color3.fromRGB(255, 80, 80),
                BorderSizePixel = 0,
        }, bossBg)
        corner(self.bossHp, 8)
        self.bossBar = bossBar

        ---------------------------------------------------------------- tombol kanan atas
        local actions = {
                { name = "Tas", label = "Tas", color = T.Gold, cb = function()
                        self:renderInv()
                        self:showPanel("Inv")
                end },
                { name = "Kar", label = "Kar", color = T.Blue, cb = function()
                        self:renderChar()
                        self:showPanel("Char")
                end },
                { name = "Tugas", label = "Tugas", color = T.Green, cb = function()
                        self:renderQuest()
                        self:showPanel("Quest")
                end },
                { name = "Dagang", label = "Dagang", color = Color3.fromRGB(224, 140, 190), cb = function()
                        self:renderTrade()
                        self:showPanel("Trade")
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
                local rowIdx = math.floor((i - 1) / 3)
                local colIdx = (i - 1) % 3
                btn({
                        parent = self.gui,
                        Name = "Btn" .. act.name,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -16 - colIdx * 92, 0, 14 + rowIdx * 50),
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
        "Tempa balok besi dari bijih di PAK TEMPA, lalu buat Pedang Besi & Zirah!",
        "Serang Gelatin Hijau di Padang Timur untuk Gelatin - bahan Zirah Kulit!",
        "BOSS RAID: Raja Golem muncul di Arena Timur - serang bersama semua pemain!",
        "Naik level dapat 2 poin stat - buka panel Kar dan bagikan ke STR/VIT/AGI!",
        "Makan Roti Aktif dari Bu Masak untuk lari lebih cepat 12%!",
        "Dagang aman antar pemain: tombol Dagang, dekati partner, undang & SIAP!",
        "Papan Tugas Harian di alun-alun memberi koin & XP besar - ambil tiap hari!",
        "Kucing Koin memberi +10% harga jual. Lihat Toko Peliharaan!",
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

        self:renderHudExtras()

        -- refresh panel terbuka supaya harga/inv tetap segar
        if self.activePanel == "Shop" and self.shopId then
                self:renderShop()
        elseif self.activePanel == "Plant" and self.pendingPlant then
                self:renderPlantPanel()
        elseif self.activePanel == "Inv" then
                self:renderInv()
        elseif self.activePanel == "Char" then
                self:renderChar()
        elseif self.activePanel == "Craft" then
                self:renderCraft()
        elseif self.activePanel == "Quest" then
                self:renderQuest()
        end
end

--------------------------------------------------------------------
-- HP / TUGAS / BOSS: pembaruan HUD tiap state
--------------------------------------------------------------------

function UIController:renderHudExtras()
        local s = self.state
        if not s then
                return
        end

        -- tugas aktif
        local q = s.Quest
        if q and q.id ~= "" then
                local def = nil
                for _, d in ipairs(Balance.Quests) do
                        if d.id == q.id then
                                def = d
                                break
                        end
                end
                if def then
                        self.questChip.Visible = true
                        self.questChip.Text = (q.done and "[SIAP KLAIM] " or "Tugas: ") .. def.title .. " "
                                .. math.min(q.prog, def.goal.count) .. "/" .. def.goal.count
                        self.questChip.TextColor3 = q.done and T.Green or T.Gold
                end
        else
                self.questChip.Visible = false
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

        -- peralatan tempaan (v3): pakai cepat dari tas
        for _, eq in ipairs(Balance.Equipment) do
                local count = s.Equips[eq.id] or 0
                if count > 0 then
                        local equipped = s.Equipped[eq.kind] == eq.id
                        local statText = eq.kind == "weapon" and ("ATK +" .. eq.atk) or ("DEF +" .. eq.def)
                        invRow(eq.name .. " x" .. count .. (equipped and "  [TERPAKAI]" or ""),
                                statText .. " - Lv " .. eq.level .. " | " .. (eq.desc or "Peralatan tempaan"),
                                Color3.fromRGB(eq.color[1], eq.color[2], eq.color[3]),
                                equipped and "Lepas" or "Pakai",
                                function()
                                        local res = Remotes.get("Equip"):InvokeServer(eq.kind, equipped and "" or eq.id)
                                        self:handleResult(res)
                                        self:renderInv()
                                end)
                end
        end

        -- makanan & ramuan (v3): makan langsung
        for _, u in ipairs(Balance.Usables) do
                local count = s.Usables[u.id] or 0
                if count > 0 then
                        invRow(u.name .. " x" .. count, u.desc .. " - jual @" .. self:clientPrice(u.sell, u.id) .. " koin",
                                Color3.fromRGB(u.color[1], u.color[2], u.color[3]),
                                "Makan",
                                function()
                                        local res = Remotes.get("UseItem"):InvokeServer(u.id)
                                        self:handleResult(res)
                                        self:renderInv()
                                end)
                end
        end
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
                        "1. KUMPUL: tanam & panen (Ladang Utara), tebang pohon (Hutan), tambang bijih (Tambang, perlu Belik), mancing (Danau, perlu Pancing).",
                        "2. JUAL: Bu Laris di Pasar Pengepul - harga naik-turun tiap 10 menit, jual saat permintaan tinggi!",
                        "3. KOMBAT: dekati monster (Gelatin/Serigala/Golem) lalu tekan E untuk menyerang. Monster membalas - makan ramuan bila HP tipis!",
                        "4. TEMPAA: kumpulkan bahan, buat Balok Besi di PAK TEMPA, lalu tempa Pedang & Zirah. Pakai di panel Kar.",
                        "5. STAT: tiap naik level = 2 poin. Panel Kar: STR (serangan), VIT (HP), AGI (lari), INT (ramuan), DEX (kritikal).",
                        "6. MASAK: Bu Masak menjual resep - Roti Aktif (lari cepat), Sate Ikan & Ramuan (pulihkan HP).",
                        "7. BOSS: Raja Golem muncul di Arena Timur tiap ±15 menit. Serang bersama - hadiah sesuai kontribusi, teratas dapat bonus besar!",
                        "8. TUGAS: Papan Tugas di alun-alun - rotasi harian, hadiah koin+XP besar.",
                        "9. DAGANG: tombol Dagang, dekati pemain lain, undang, tawar barang/koin, keduanya SIAP -> tukar aman.",
                        "10. LEVEL membuka bibit mahal & resep tempaa. Semua aktivitas memberi XP!",
                        "11. KUIS Kak Pintar opsional: +20 koin per jawaban benar. Diabaikan juga tidak apa-apa.",
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

        ---------------------------------------------------------------- v3
        Remotes.get("OpenCraft").OnClientEvent:Connect(function(station)
                self.craftStation = station
                self:renderCraft()
                self:showPanel("Craft")
        end)

        Remotes.get("OpenQuest").OnClientEvent:Connect(function()
                self:renderQuest()
                self:showPanel("Quest")
        end)

        Remotes.get("OpenChar").OnClientEvent:Connect(function()
                self:renderChar()
                self:showPanel("Char")
        end)

        Remotes.get("OpenTrade").OnClientEvent:Connect(function()
                self:renderTrade()
                self:showPanel("Trade")
        end)

        Remotes.get("BossState").OnClientEvent:Connect(function(info)
                if info.active then
                        self.bossBar.Visible = true
                        self.bossTitle.Text = info.name .. " - " .. (info.zone or "Arena")
                        self.bossHp.Size = UDim2.fromScale(math.clamp((info.hp or 1) / (info.maxHp or 1), 0.02, 1), 1)
                else
                        self.bossBar.Visible = false
                        if info.killed then
                                self:toast("BOSS DIKALAHKAN!", info.name .. " tumbang berkat kerja sama tim!", T.Red)
                                makeSound(1.4):Play()
                        end
                end
        end)

        Remotes.get("TradeSync").OnClientEvent:Connect(function(snap)
                if snap.inviteFrom then
                        self.inviteFrom = snap.inviteFrom
                        if self.activePanel == "Trade" then
                                self:renderTrade()
                        end
                        return
                end
                self.inviteFrom = nil
                self.tradeSnap = snap
                if self.activePanel == "Trade" then
                        self:renderTrade()
                end
        end)

        -- detak HP: ikat humanoid lokal
        task.spawn(function()
                local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if not humanoid then
                        humanoid = player.CharacterAdded:Wait():FindFirstChildOfClass("Humanoid")
                end
                local function refreshHp()
                        if self.hpText and self.hpBar then
                                self.hpText.Text = "HP " .. math.ceil(humanoid.Health) .. "/" .. math.ceil(humanoid.MaxHealth)
                                self.hpBar.Size = UDim2.fromScale(math.clamp(humanoid.Health / math.max(1, humanoid.MaxHealth), 0.02, 1), 1)
                        end
                end
                humanoid.HealthChanged:Connect(refreshHp)
                humanoid.Changed:Connect(function(prop)
                        if prop == "MaxHealth" or prop == "Health" then
                                refreshHp()
                        end
                end)
                refreshHp()
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

--------------------------------------------------------------------
-- PANEL KARAKTER (v3): stat, poin, peralatan
--------------------------------------------------------------------

function UIController:buildCharPanel()
        local frame = self:panelFrame("Char", 0.5, 0.66)
        Util.create("TextLabel", {
                Name = "Judul",
                Size = UDim2.new(1, -60, 0, 36),
                Position = UDim2.fromOffset(18, 10),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = T.Blue,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "Karakter & Peralatan",
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

        self.charPoints = Util.create("TextLabel", {
                Name = "Poin",
                Position = UDim2.fromOffset(18, 50),
                Size = UDim2.new(1, -36, 0, 26),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextScaled = true,
                TextColor3 = T.Gold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "Poin stat: 0",
        }, frame)

        local scroll = Util.create("ScrollingFrame", {
                Name = "List",
                Position = UDim2.fromOffset(18, 80),
                Size = UDim2.new(1, -36, 1, -98),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                CanvasSize = UDim2.new(),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 6,
        }, frame)
        Util.create("UIListLayout", { Padding = UDim.new(0, 8) }, scroll)
        self.charList = scroll
end

function UIController:renderChar()
        local s = self.state
        local list = self.charList
        for _, child in list:GetChildren() do
                if child:IsA("Frame") then
                        child:Destroy()
                end
        end
        if not s then
                return
        end
        self.charPoints.Text = "Poin stat tersisa: " .. (s.StatPoints or 0)
                .. "  |  Level " .. (s.Level or 1)

        -- atribut
        for _, stat in ipairs(Balance.Stats) do
                local value = (s.Stats and s.Stats[stat.id]) or 0
                local r = row(list, 60)
                swatch(r, T.Blue, string.upper(stat.id))
                Util.create("TextLabel", {
                        Position = UDim2.fromOffset(62, 6),
                        Size = UDim2.new(1, -180, 0, 26),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextScaled = true,
                        TextColor3 = T.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = stat.name .. ": " .. value,
                }, r)
                Util.create("TextLabel", {
                        Position = UDim2.fromOffset(62, 32),
                        Size = UDim2.new(1, -180, 0, 22),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.Gotham,
                        TextScaled = true,
                        TextColor3 = T.TextDim,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = stat.desc,
                }, r)
                local plus = btn({
                        parent = r,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -8, 0, 12),
                        Size = UDim2.fromOffset(64, 36),
                        BackgroundColor3 = (s.StatPoints or 0) > 0 and value < Balance.MaxStatPerStat and T.Green or T.Disabled,
                        TextColor3 = Color3.fromRGB(24, 30, 26),
                        Text = "+1",
                        _radius = 8,
                })
                plus.Activated:Connect(function()
                        local res = Remotes.get("AllocStat"):InvokeServer(stat.id)
                        self:handleResult(res)
                end)
        end

        -- peralatan terpakai
        for _, kind in { "weapon", "armor" } do
                local eqId = s.Equipped[kind]
                local eq = nil
                for _, e in ipairs(Balance.Equipment) do
                        if e.id == eqId then
                                eq = e
                                break
                        end
                end
                local r = row(list, 56)
                swatch(r, eq and Color3.fromRGB(eq.color[1], eq.color[2], eq.color[3]) or T.Disabled,
                        kind == "weapon" and "S" or "Z")
                local label = kind == "weapon" and "Senjata: " or "Zirah: "
                local statText = ""
                if eq then
                        statText = kind == "weapon" and ("ATK +" .. eq.atk) or ("DEF +" .. eq.def)
                end
                Util.create("TextLabel", {
                        Position = UDim2.fromOffset(62, 8),
                        Size = UDim2.new(1, -170, 0, 40),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextScaled = true,
                        TextColor3 = eq and T.Text or T.TextDim,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = label .. (eq and (eq.name .. "  (" .. statText .. ")") or "- belum pakai -"),
                }, r)
                if eq then
                        btn({
                                parent = r,
                                AnchorPoint = Vector2.new(1, 0),
                                Position = UDim2.new(1, -8, 0, 10),
                                Size = UDim2.fromOffset(80, 34),
                                BackgroundColor3 = T.Red,
                                TextColor3 = Color3.new(1, 1, 1),
                                Text = "Lepas",
                                _radius = 8,
                        }).Activated:Connect(function()
                                local res = Remotes.get("Equip"):InvokeServer(kind, "")
                                self:handleResult(res)
                        end)
                end
        end
end

--------------------------------------------------------------------
-- PANEL CRAFT (v3): stasiun tempa / dapur
--------------------------------------------------------------------

function UIController:buildCraftPanel()
        local frame = self:panelFrame("Craft", 0.5, 0.64)
        Util.create("TextLabel", {
                Name = "Judul",
                Size = UDim2.new(1, -60, 0, 36),
                Position = UDim2.fromOffset(18, 10),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = Color3.fromRGB(255, 150, 90),
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "Stasiun Kerja",
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
        self.craftList = scroll
end

local function countBag(s: any, id: string): number
        return (s and s.Bag and s.Bag[id]) or 0
end

local MAT_LOOKUPS = {}
for _, res in ipairs(Config.Resources) do
        MAT_LOOKUPS[res.id] = res.name
end
for _, crop in ipairs(Config.Crops) do
        MAT_LOOKUPS[crop.id] = crop.name
end
for _, fish in ipairs(Config.Fish) do
        MAT_LOOKUPS[fish.id] = fish.name
end

function UIController:matNameOf(id: string): string
        return MAT_LOOKUPS[id] or id
end

function UIController:renderCraft()
        local s = self.state
        local list = self.craftList
        for _, child in list:GetChildren() do
                if child:IsA("Frame") then
                        child:Destroy()
                end
        end
        if not s then
                return
        end

        local judul = self.gui:FindFirstChild("Craft") and self.gui.Craft:FindFirstChild("Judul") :: TextLabel?
        local titles = { tempa = "Pandai Besi - Pak Tempa", dapur = "Dapur Alam - Bu Masak" }
        if judul then
                judul.Text = titles[self.craftStation] or "Stasiun Kerja"
        end

        for _, recipe in ipairs(Balance.Recipes) do
                if recipe.station ~= self.craftStation then
                        continue
                end
                local outName = recipe.out
                local count = 0
                if recipe.kind == "equip" then
                        for _, eq in ipairs(Balance.Equipment) do
                                if eq.id == recipe.out then
                                        outName = eq.name .. " (" .. (recipe.station == "tempa" and "Senjata" or "Zirah") .. ")"
                                        count = s.Equips[eq.id] or 0
                                        break
                                end
                        end
                elseif recipe.kind == "use" then
                        for _, u in ipairs(Balance.Usables) do
                                if u.id == recipe.out then
                                        outName = u.name
                                        count = s.Usables[u.id] or 0
                                        break
                                end
                        end
                end
                -- cek bahan
                local canCraft = s.Level >= recipe.level
                local mats = {}
                for matId, need in pairs(recipe.recipe) do
                        local have = countBag(s, matId)
                        if have < need then
                                canCraft = false
                        end
                        table.insert(mats, self:matNameOf(matId) .. " " .. have .. "/" .. need)
                end
                table.sort(mats)

                local r = row(list, 72)
                Util.create("TextLabel", {
                        Position = UDim2.fromOffset(12, 6),
                        Size = UDim2.new(1, -140, 0, 28),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextScaled = true,
                        TextColor3 = T.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = outName .. (count > 0 and "  x" .. count or ""),
                }, r)
                Util.create("TextLabel", {
                        Position = UDim2.fromOffset(12, 36),
                        Size = UDim2.new(1, -140, 0, 28),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.Gotham,
                        TextScaled = true,
                        TextColor3 = canCraft and T.Green or T.TextDim,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = "Bahan: " .. table.concat(mats, ", ") .. " | Lv " .. recipe.level .. " | +" .. recipe.xp .. " XP",
                }, r)
                btn({
                        parent = r,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -8, 0, 16),
                        Size = UDim2.fromOffset(96, 40),
                        BackgroundColor3 = canCraft and T.Gold or T.Disabled,
                        TextColor3 = canCraft and Color3.fromRGB(40, 30, 10) or T.Text,
                        Text = canCraft and "Buat" or "Lv " .. recipe.level,
                        _radius = 8,
                }).Activated:Connect(function()
                        local res = Remotes.get("Craft"):InvokeServer(recipe.id)
                        self:handleResult(res)
                end)
        end
end

--------------------------------------------------------------------
-- PANEL TUGAS (v3): papan tugas harian
--------------------------------------------------------------------

function UIController:buildQuestPanel()
        local frame = self:panelFrame("Quest", 0.46, 0.62)
        Util.create("TextLabel", {
                Name = "Judul",
                Size = UDim2.new(1, -60, 0, 36),
                Position = UDim2.fromOffset(18, 10),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = T.Green,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "Papan Tugas Harian",
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
        self.questList = scroll
end

function UIController:renderQuest()
        local s = self.state
        local list = self.questList
        for _, child in list:GetChildren() do
                if child:IsA("Frame") then
                        child:Destroy()
                end
        end
        if not s then
                return
        end

        -- tugas aktif
        local q = s.Quest
        if q and q.id ~= "" then
                local def = nil
                for _, d in ipairs(Balance.Quests) do
                        if d.id == q.id then
                                def = d
                                break
                        end
                end
                if def then
                        local r = row(list, 88)
                        r.BackgroundColor3 = q.done and Color3.fromRGB(40, 70, 50) or T.PanelLight
                        Util.create("TextLabel", {
                                Position = UDim2.fromOffset(12, 6),
                                Size = UDim2.new(1, -130, 0, 28),
                                BackgroundTransparency = 1,
                                Font = Enum.Font.GothamBold,
                                TextScaled = true,
                                TextColor3 = T.Gold,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Text = "AKTIF: " .. def.title .. (q.done and "  [SELESAI]" or ""),
                        }, r)
                        Util.create("TextLabel", {
                                Position = UDim2.fromOffset(12, 34),
                                Size = UDim2.new(1, -130, 0, 24),
                                BackgroundTransparency = 1,
                                Font = Enum.Font.Gotham,
                                TextScaled = true,
                                TextColor3 = T.Text,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Text = def.desc .. " - " .. math.min(q.prog, def.goal.count) .. "/" .. def.goal.count
                                        .. " | hadiah " .. def.reward.coins .. " koin +" .. def.reward.xp .. " XP",
                        }, r)
                        if q.done then
                                btn({
                                        parent = r,
                                        AnchorPoint = Vector2.new(1, 0),
                                        Position = UDim2.new(1, -8, 0, 24),
                                        Size = UDim2.fromOffset(110, 40),
                                        BackgroundColor3 = T.Gold,
                                        TextColor3 = Color3.fromRGB(40, 30, 10),
                                        Text = "Klaim",
                                        _radius = 8,
                                }).Activated:Connect(function()
                                        local res = Remotes.get("QuestAction"):InvokeServer("claim")
                                        self:handleResult(res)
                                end)
                        end
                end
        end

        -- penawaran hari ini
        local offered = Balance.todayQuestIds()
        for _, id in offered do
                if q and q.id == id then
                        continue
                end
                local def = nil
                for _, d in ipairs(Balance.Quests) do
                        if d.id == id then
                                def = d
                                break
                        end
                end
                if def then
                        local locked = q and q.id ~= "" and not q.done
                        local r = row(list, 80)
                        Util.create("TextLabel", {
                                Position = UDim2.fromOffset(12, 6),
                                Size = UDim2.new(1, -130, 0, 28),
                                BackgroundTransparency = 1,
                                Font = Enum.Font.GothamBold,
                                TextScaled = true,
                                TextColor3 = T.Text,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Text = def.title,
                        }, r)
                        Util.create("TextLabel", {
                                Position = UDim2.fromOffset(12, 34),
                                Size = UDim2.new(1, -130, 0, 38),
                                BackgroundTransparency = 1,
                                Font = Enum.Font.Gotham,
                                TextScaled = true,
                                TextColor3 = T.TextDim,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Text = def.desc .. " | hadiah " .. def.reward.coins .. " koin +" .. def.reward.xp .. " XP",
                        }, r)
                        btn({
                                parent = r,
                                AnchorPoint = Vector2.new(1, 0),
                                Position = UDim2.new(1, -8, 0, 20),
                                Size = UDim2.fromOffset(110, 40),
                                BackgroundColor3 = locked and T.Disabled or T.Green,
                                TextColor3 = locked and T.Text or Color3.fromRGB(24, 30, 26),
                                Text = locked and "Selesaikan yang aktif" or "Terima",
                                _radius = 8,
                        }).Activated:Connect(function()
                                local res = Remotes.get("QuestAction"):InvokeServer("accept", def.id)
                                self:handleResult(res)
                        end)
                end
        end
end

--------------------------------------------------------------------
-- PANEL DAGANG (v3): undang partner + sesi tukar barang
--------------------------------------------------------------------

function UIController:buildTradePanel()
        local frame = self:panelFrame("Trade", 0.56, 0.7)
        Util.create("TextLabel", {
                Name = "Judul",
                Size = UDim2.new(1, -60, 0, 36),
                Position = UDim2.fromOffset(18, 10),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = Color3.fromRGB(224, 140, 190),
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "Dagang Pemain",
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
        self.tradeList = scroll
end

local function itemNameOf(kind: string, id: string): string
        local lookups = { crop = Config.Crops, bag = Config.Resources, fish = Config.Fish }
        for _, def in ipairs(lookups[kind] or {}) do
                if def.id == id then
                        return def.name
                end
        end
        if kind == "equip" then
                for _, eq in ipairs(Balance.Equipment) do
                        if eq.id == id then
                                return eq.name
                        end
                end
        elseif kind == "use" then
                for _, u in ipairs(Balance.Usables) do
                        if u.id == id then
                                return u.name
                        end
                end
        end
        return id
end

function UIController:renderTrade()
        local s = self.state
        local list = self.tradeList
        for _, child in list:GetChildren() do
                if child:IsA("Frame") then
                        child:Destroy()
                end
        end

        -- undangan masuk
        if self.inviteFrom then
                local r = row(list, 60)
                r.BackgroundColor3 = Color3.fromRGB(50, 40, 60)
                Util.create("TextLabel", {
                        Position = UDim2.fromOffset(12, 8),
                        Size = UDim2.new(1, -230, 0, 44),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextScaled = true,
                        TextColor3 = T.Gold,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = "Undangan dagang dari " .. self.inviteFrom .. "!",
                }, r)
                btn({
                        parent = r,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -100, 0, 12),
                        Size = UDim2.fromOffset(88, 36),
                        BackgroundColor3 = T.Green,
                        TextColor3 = Color3.fromRGB(24, 30, 26),
                        Text = "Terima",
                        _radius = 8,
                }).Activated:Connect(function()
                        local res = Remotes.get("TradeAction"):InvokeServer({ action = "accept", from = self.inviteFrom })
                        self:handleResult(res)
                end)
                btn({
                        parent = r,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -8, 0, 12),
                        Size = UDim2.fromOffset(80, 36),
                        BackgroundColor3 = T.Red,
                        TextColor3 = Color3.new(1, 1, 1),
                        Text = "Tolak",
                        _radius = 8,
                }).Activated:Connect(function()
                        local res = Remotes.get("TradeAction"):InvokeServer({ action = "decline" })
                        self.inviteFrom = nil
                        self:handleResult(res)
                        self:renderTrade()
                end)
        end

        -- sesi dagang aktif
        if self.tradeSnap then
                local snap = self.tradeSnap
                -- dua kolom ringkas
                local header = row(list, 40)
                Util.create("TextLabel", {
                        Position = UDim2.fromOffset(12, 6),
                        Size = UDim2.fromScale(0.5, 1),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBlack,
                        TextScaled = true,
                        TextColor3 = T.Gold,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = "TAWARANMU" .. (snap.me.ready and "  [SIAP]" or ""),
                }, header)
                Util.create("TextLabel", {
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -12, 0, 6),
                        Size = UDim2.fromScale(0.5, 1),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBlack,
                        TextScaled = true,
                        TextColor3 = T.Blue,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Text = (snap.partner.name or "?") .. (snap.partner.ready and "  [SIAP]" or ""),
                }, header)

                -- barangmu
                for kind, items in pairs(snap.me.items) do
                        for id, count in pairs(items) do
                                if count > 0 then
                                        local r2 = row(list, 52)
                                        Util.create("TextLabel", {
                                                Position = UDim2.fromOffset(12, 8),
                                                Size = UDim2.new(1, -110, 0, 36),
                                                BackgroundTransparency = 1,
                                                Font = Enum.Font.Gotham,
                                                TextScaled = true,
                                                TextColor3 = T.Text,
                                                TextXAlignment = Enum.TextXAlignment.Left,
                                                Text = "Kamu tawar: " .. itemNameOf(kind, id) .. " x" .. count,
                                        }, r2)
                                        btn({
                                                parent = r2,
                                                AnchorPoint = Vector2.new(1, 0),
                                                Position = UDim2.new(1, -8, 0, 8),
                                                Size = UDim2.fromOffset(92, 34),
                                                BackgroundColor3 = T.Red,
                                                TextColor3 = Color3.new(1, 1, 1),
                                                Text = "Batal",
                                                _radius = 8,
                                        }).Activated:Connect(function()
                                                local res = Remotes.get("TradeAction"):InvokeServer({ action = "offer", kind = kind, id = id, count = 0 })
                                                self:handleResult(res)
                                        end)
                                end
                        end
                end
                -- barang partner
                for kind, items in pairs(snap.partner.items) do
                        for id, count in pairs(items) do
                                if count > 0 then
                                        local r2 = row(list, 52)
                                        Util.create("TextLabel", {
                                                Position = UDim2.fromOffset(12, 8),
                                                Size = UDim2.fromScale(1, 1),
                                                BackgroundTransparency = 1,
                                                Font = Enum.Font.Gotham,
                                                TextScaled = true,
                                                TextColor3 = T.Blue,
                                                TextXAlignment = Enum.TextXAlignment.Left,
                                                Text = (snap.partner.name or "?") .. " tawar: " .. itemNameOf(kind, id) .. " x" .. count,
                                        }, r2)
                                end
                        end
                end
                -- koin
                local coinRow = row(list, 56)
                Util.create("TextLabel", {
                        Position = UDim2.fromOffset(12, 8),
                        Size = UDim2.new(0.5, 0, 0, 40),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextScaled = true,
                        TextColor3 = T.Gold,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = "Koinmu: " .. Util.formatNumber(snap.me.coins or 0),
                }, coinRow)
                Util.create("TextLabel", {
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -12, 0, 8),
                        Size = UDim2.new(0.5, 0, 0, 40),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextScaled = true,
                        TextColor3 = T.Blue,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Text = "Koin lawan: " .. Util.formatNumber(snap.partner.coins or 0),
                }, coinRow)
                local coinInput = Util.create("TextBox", {
                        Position = UDim2.fromOffset(12, 8),
                        Size = UDim2.fromOffset(120, 40),
                        BackgroundColor3 = T.PanelLight,
                        TextColor3 = T.Text,
                        Font = Enum.Font.GothamBold,
                        TextScaled = true,
                        PlaceholderText = "koin...",
                        ClearTextOnFocus = true,
                        Text = "",
                }, coinRow)
                corner(coinInput, 8)
                coinInput.FocusLost:Connect(function()
                        local amount = tonumber(coinInput.Text)
                        if amount and amount > 0 then
                                local res = Remotes.get("TradeAction"):InvokeServer({ action = "coin", amount = math.floor(amount) })
                                self:handleResult(res)
                        end
                end)

                -- inventaris tersedia untuk ditawarkan
                Util.create("TextLabel", {
                        Size = UDim2.new(1, -8, 0, 28),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextScaled = true,
                        TextColor3 = T.TextDim,
                        Text = "TAWARKAN DARI TASMU:",
                }, list)
                if s then
                        local invSections = {
                                { kind = "crop", data = s.Crops, lookup = Config.Crops },
                                { kind = "bag", data = s.Bag, lookup = Config.Resources },
                                { kind = "fish", data = s.Fish, lookup = Config.Fish },
                                { kind = "equip", data = s.Equips, lookup = nil },
                                { kind = "use", data = s.Usables, lookup = nil },
                        }
                        for _, section in invSections do
                                for id, count in section.data do
                                        if count <= 0 then
                                                continue
                                        end
                                        local name = nil
                                        if section.lookup then
                                                for _, d in ipairs(section.lookup) do
                                                        if d.id == id then
                                                                name = d.name
                                                                break
                                                        end
                                                end
                                        else
                                                name = itemNameOf(section.kind, id)
                                        end
                                        if name then
                                                local r2 = row(list, 52)
                                                Util.create("TextLabel", {
                                                        Position = UDim2.fromOffset(12, 8),
                                                        Size = UDim2.new(1, -200, 0, 36),
                                                        BackgroundTransparency = 1,
                                                        Font = Enum.Font.Gotham,
                                                        TextScaled = true,
                                                        TextColor3 = T.Text,
                                                        TextXAlignment = Enum.TextXAlignment.Left,
                                                        Text = name .. " x" .. count,
                                                }, r2)
                                                btn({
                                                        parent = r2,
                                                        AnchorPoint = Vector2.new(1, 0),
                                                        Position = UDim2.new(1, -8, 0, 8),
                                                        Size = UDim2.fromOffset(180, 34),
                                                        BackgroundColor3 = T.Gold,
                                                        TextColor3 = Color3.fromRGB(40, 30, 10),
                                                        Text = "Tawar Semua",
                                                        _radius = 8,
                                                }).Activated:Connect(function()
                                                        local res = Remotes.get("TradeAction"):InvokeServer({ action = "offer", kind = section.kind, id = id, count = count })
                                                        self:handleResult(res)
                                                end)
                                        end
                                end
                        end
                end

                -- tombol aksi sesi
                local actionRow = row(list, 60)
                local readyBtn = btn({
                        parent = actionRow,
                        Position = UDim2.fromOffset(12, 12),
                        Size = UDim2.fromOffset(170, 36),
                        BackgroundColor3 = snap.me.ready and T.Green or T.PanelLight,
                        TextColor3 = Color3.fromRGB(24, 30, 26),
                        Text = snap.me.ready and "SIAP (batal)" or "SIAP",
                        _radius = 8,
                })
                readyBtn.Activated:Connect(function()
                        local res = Remotes.get("TradeAction"):InvokeServer({ action = "ready", value = not snap.me.ready })
                        self:handleResult(res)
                end)
                local cancelBtn = btn({
                        parent = actionRow,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -12, 0, 12),
                        Size = UDim2.fromOffset(170, 36),
                        BackgroundColor3 = T.Red,
                        TextColor3 = Color3.new(1, 1, 1),
                        Text = "Batalkan Dagang",
                        _radius = 8,
                })
                cancelBtn.Activated:Connect(function()
                        local res = Remotes.get("TradeAction"):InvokeServer({ action = "cancel" })
                        self:handleResult(res)
                        self.tradeSnap = nil
                        self:renderTrade()
                end)
                return
        end

        -- daftar pemain untuk mengundang
        Util.create("TextLabel", {
                Size = UDim2.new(1, -8, 0, 30),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextScaled = true,
                TextColor3 = T.TextDim,
                Text = "Pemain di server ini (dekati untuk mengundang):",
        }, list)
        for _, other in Players:GetPlayers() do
                if other ~= player then
                        local r = row(list, 56)
                        Util.create("TextLabel", {
                                Position = UDim2.fromOffset(12, 8),
                                Size = UDim2.new(1, -120, 0, 40),
                                BackgroundTransparency = 1,
                                Font = Enum.Font.GothamBold,
                                TextScaled = true,
                                TextColor3 = T.Text,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Text = other.DisplayName,
                        }, r)
                        btn({
                                parent = r,
                                AnchorPoint = Vector2.new(1, 0),
                                Position = UDim2.new(1, -8, 0, 10),
                                Size = UDim2.fromOffset(100, 36),
                                BackgroundColor3 = T.Gold,
                                TextColor3 = Color3.fromRGB(40, 30, 10),
                                Text = "Undang",
                                _radius = 8,
                        }).Activated:Connect(function()
                                local res = Remotes.get("TradeAction"):InvokeServer({ action = "invite", target = other.Name })
                                self:handleResult(res)
                        end)
                end
        end
end

return UIController
