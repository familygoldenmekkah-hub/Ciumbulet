local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Balance = require(ReplicatedStorage.Shared.Balance)
local Remotes = require(ReplicatedStorage.Remotes)
local Util = require(ReplicatedStorage.Shared.Util)
local CropConfig = require(ReplicatedStorage.Shared.CropConfig)
local TasLogic = require(ReplicatedStorage.Shared.TasLogic)
local Ambience = require(script.Parent.Ambience)

local UIController = {}
UIController.__index = UIController

local T = {
	Bg = Color3.fromRGB(14, 16, 20),
	Panel = Color3.fromRGB(22, 25, 32),
	PanelLight = Color3.fromRGB(36, 40, 50),
	Gold = Color3.fromRGB(233, 196, 106),
	Green = Color3.fromRGB(96, 200, 140),
	Red = Color3.fromRGB(228, 104, 104),
	Blue = Color3.fromRGB(122, 168, 226),
	Text = Color3.fromRGB(232, 234, 240),
	TextDim = Color3.fromRGB(138, 144, 158),
	Disabled = Color3.fromRGB(70, 75, 88),
}

local RARITY_COLOR = {}
for _, r in ipairs(CropConfig.Rarities) do
	RARITY_COLOR[r.id] = Color3.fromRGB(r.color[1], r.color[2], r.color[3])
end

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

local PANEL_NAMES = { "Tas", "Toko", "Kebun", "Koperasi", "Char", "Craft", "Code", "Help", "Nama" }

function UIController.new()
	local self = setmetatable({}, UIController)

	self.state = nil
	self.activePanel = nil
	self.craftStation = nil
	self.bossInfo = nil
	self.tokoTab = "pack"
	self.farmSnap = nil
	self.farmSeed = ""
	self.koperasiName = ""
	self.koperasiOffers = {}

	self:buildGui()
	self:buildHud()
	self:buildTasPanel()
	self:buildTokoPanel()
	self:buildKebunPanel()
	self:buildKoperasiPanel()
	self:buildCharPanel()
	self:buildCraftPanel()
	self:buildCodePanel()
	self:buildHelpPanel()
	self:buildNamaPanel()
	self:wireRemotes()
	self:startTips()
	Ambience.start()

	return self
end

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

function UIController:panelHeader(frame: Frame, title: string, color: Color3): TextLabel
	local label = Util.create("TextLabel", {
		Name = "Judul",
		Size = UDim2.new(1, -60, 0, 36),
		Position = UDim2.fromOffset(18, 10),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBlack,
		TextScaled = true,
		TextColor3 = color,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = title,
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
	return label
end

function UIController:scrollArea(frame: Frame, top: number): ScrollingFrame
	local scroll = Util.create("ScrollingFrame", {
		Name = "List",
		Position = UDim2.fromOffset(18, top),
		Size = UDim2.new(1, -36, 1, -(top + 18)),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 6,
	}, frame)
	Util.create("UIListLayout", { Padding = UDim.new(0, 8) }, scroll)
	return scroll
end

function UIController:showPanel(name: string?)
	for _, n in PANEL_NAMES do
		local f = self.gui:FindFirstChild(n)
		if f then
			(f :: Frame).Visible = (n == name)
		end
	end
	if self.navHolder then
		self.navHolder.Visible = (name == nil)
	end
	if name then
		local f = self.gui:FindFirstChild(name)
		if f and f:IsA("Frame") then
			f.Size = UDim2.fromScale(f.Size.X.Scale * 0.94, f.Size.Y.Scale * 0.94)
			TweenService:Create(f, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.fromScale(f.Size.X.Scale / 0.94, f.Size.Y.Scale / 0.94),
			}):Play()
		end
	end
	self.activePanel = name
end

function UIController:buildHud()
	local coinChip = Util.create("Frame", {
		Name = "MicdaChip",
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
		Text = "M",
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
		Text = "ANGKA SANG RAJA",
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

	local actions = {
		{ name = "Tas", label = "Tas", cb = function()
			self:renderTas()
			self:showPanel("Tas")
		end },
		{ name = "Kar", label = "Kar", cb = function()
			self:renderChar()
			self:showPanel("Char")
		end },
		{ name = "Musik", label = "Musik", cb = function()
			local on = Ambience.toggle()
			self:toast("Musik Latar", on and "Musik dinyalakan." or "Musik dimatikan.", T.Gold)
		end },
		{ name = "Kode", label = "Kode", cb = function()
			self:showPanel("Code")
		end },
		{ name = "Bantuan", label = "?", cb = function()
			self:showPanel("Help")
		end },
	}
	local i = 0
	for _, act in actions do
		i += 1
		local rowIdx = math.floor((i - 1) / 4)
		local colIdx = (i - 1) % 4
		local b = btn({
			parent = self.gui,
			Name = "Btn" .. act.name,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -16 - colIdx * 84, 0, 14 + rowIdx * 50),
			Size = UDim2.fromOffset(76, 42),
			BackgroundColor3 = T.Panel,
			BackgroundTransparency = 0.12,
			TextColor3 = T.Text,
			Text = act.label,
			_radius = 8,
		})
		b.Activated:Connect(act.cb)
	end

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

	self.navRows = {}
	self.navTargets = {
		{ name = "Toko Benih", pos = Vector3.new(-46, 0, -28) },
		{ name = "Padang Liar", pos = Vector3.new(640, 0, -320) },
		{ name = "Hutan Bayang", pos = Vector3.new(640, 0, 60) },
		{ name = "Negeri Baja", pos = Vector3.new(760, 0, 560) },
		{ name = "Arena Boss", pos = Vector3.new(760, 0, 650) },
	}
	local navHolder = Util.create("Frame", {
		Name = "Kompas",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 12, 1, -150),
		Size = UDim2.fromOffset(190, 6 * 30),
		BackgroundTransparency = 1,
		Visible = false,
	}, self.gui)
	Util.create("UIListLayout", { Padding = UDim.new(0, 4) }, navHolder)
	for _, nt in self.navTargets do
		local chip = Util.create("Frame", {
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundColor3 = T.Panel,
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
		}, navHolder)
		corner(chip, 6)
		Util.create("TextLabel", {
			Position = UDim2.fromOffset(8, 0),
			Size = UDim2.new(0.55, 0, 1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextScaled = true,
			TextColor3 = T.TextDim,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = nt.name,
		}, chip)
		local dist = Util.create("TextLabel", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -8, 0, 0),
			Size = UDim2.new(0.4, 0, 1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextScaled = true,
			TextColor3 = T.Gold,
			TextXAlignment = Enum.TextXAlignment.Right,
			Text = "-",
		}, chip)
		self.navRows[nt.name] = { label = dist, pos = nt.pos }
	end
	self.navHolder = navHolder

	task.spawn(function()
		while true do
			local char = player.Character
			local root = char and char.PrimaryPart
			if root then
				local homeId = self.state and self.state.HomeId or 0
				if homeId >= 1 and not self.navRows["Lahanku"] then
					local hx, hz = Balance.homeCenter(homeId)
					local chip = Util.create("Frame", {
						Size = UDim2.new(1, 0, 0, 26),
						BackgroundColor3 = T.Panel,
						BackgroundTransparency = 0.25,
						BorderSizePixel = 0,
					}, self.navHolder)
					corner(chip, 6)
					Util.create("TextLabel", {
						Position = UDim2.fromOffset(8, 0),
						Size = UDim2.new(0.55, 0, 1, 0),
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamBold,
						TextScaled = true,
						TextColor3 = T.Green,
						TextXAlignment = Enum.TextXAlignment.Left,
						Text = "Lahanku",
					}, chip)
					local dist = Util.create("TextLabel", {
						AnchorPoint = Vector2.new(1, 0),
						Position = UDim2.new(1, -8, 0, 0),
						Size = UDim2.new(0.4, 0, 1, 0),
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamBold,
						TextScaled = true,
						TextColor3 = T.Gold,
						TextXAlignment = Enum.TextXAlignment.Right,
						Text = "-",
					}, chip)
					self.navRows["Lahanku"] = { label = dist, pos = Vector3.new(hx + 84, 0, hz + 10) }
					self.navHolder.Size = UDim2.fromOffset(190, 6 * 30 + 30)
				end
				for name, nav in pairs(self.navRows) do
					nav.label.Text = math.floor((nav.pos - root.Position).Magnitude) .. "m"
				end
			end
			task.wait(0.5)
		end
	end)

	self.skillBtns = {}
	for idx, sk in ipairs(Balance.Skills) do
		local b = btn({
			parent = self.gui,
			Name = "Skill" .. sk.id,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -16, 1, -108 - (idx - 1) * 56),
			Size = UDim2.fromOffset(200, 46),
			BackgroundColor3 = T.Panel,
			BackgroundTransparency = 0.12,
			TextColor3 = T.Gold,
			Text = sk.name,
			_radius = 8,
			Visible = false,
		})
		b.Activated:Connect(function()
			local res = Remotes.get("Skill"):InvokeServer({ skillId = sk.id })
			self:handleResult(res)
			if res and res.ok then
				b.TextColor3 = T.Disabled
				task.spawn(function()
					for t = sk.cooldown, 1, -1 do
						if not b.Parent then
							return
						end
						b.Text = sk.name .. " (" .. t .. "s)"
						task.wait(1)
					end
					if b.Parent then
						b.Text = sk.name
						b.TextColor3 = T.Gold
					end
				end)
			end
		end)
		self.skillBtns[sk.id] = b
	end

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
	"Lahanku otomatis jadi titik lahir: ada rumah 3 lantai, kebun 500 petak, kolam & 4 ruang fungsi!",
	"Isi PAPAN NAMA lahanku supaya pengunjung tahu pemiliknya!",
	"Beli Pack Benih di TOKO BENIH, Pusat Kota: Common 400 / Rare 1.500 / Epic 3.500 Micda (3 benih acak)!",
	"Tanam benihmu di kebun 500 petak - tumbuh 3 detik, panen 1-4 hasil per petak!",
	"GABUNG BENIH di Toko Benih: Tangelo = Mandarin + Grapefruit, dan 7 resep rahasia lainnya!",
	"Tas kapasitas 50 slot - satu jenis item per slot, maksimal 250 per slot!",
	"Jual hasil panen & ikan ke KOPERASI di lahanku - harga tetap & transparan!",
	"Monster berwujud ANGKA hanya ada di PULAU MONSTER - lawan Angka Satu di Padang Liar!",
	"BOSS RAID: Angka Sang Raja (9) muncul di Arena tiap +-15 menit - serang bersama!",
	"Tempa Pedang & Zirah dari drop monster di Pandai Besi, Negeri Baja & Kristal!",
	"Masak makanan buff di Dapur Alam - Roti Aktif dari 3 Wortel bikin lari lebih cepat!",
	"Naik level dapat 2 poin stat - bagikan ke STR/VIT/AGI/INT/DEX di panel Kar!",
	"Bonus login harian 100 Micda + bonus streak. Datang lagi besok!",
	"Rumahmu punya rooftop terrace - naik tangga sampai paling atas untuk pemandangan!",
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

function UIController:renderState()
	local s = self.state
	if not s then
		return
	end
	self.coinText.Text = Util.formatNumber(s.Coins)
	self.levelText.Text = "Level " .. s.Level .. (s.Dev and "  [DEV]" or "")
	self.xpBar.Size = UDim2.fromScale(math.clamp(s.LevelPct, 0.02, 1), 1)

	for _, sk in ipairs(Balance.Skills) do
		local b = self.skillBtns[sk.id]
		if b then
			b.Visible = s.Level >= sk.level
		end
	end

	if self.activePanel == "Tas" then
		self:renderTas()
	elseif self.activePanel == "Toko" then
		self:renderToko()
	elseif self.activePanel == "Kebun" then
		self:renderKebun()
	elseif self.activePanel == "Koperasi" then
		self:renderKoperasi()
	elseif self.activePanel == "Char" then
		self:renderChar()
	elseif self.activePanel == "Craft" then
		self:renderCraft()
	end
end

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

function UIController:buildTasPanel()
	local frame = self:panelFrame("Tas", 0.52, 0.68)
	self:panelHeader(frame, "Tas Petani", T.Gold)
	self.tasTitle = Util.create("TextLabel", {
		Name = "Info",
		Position = UDim2.fromOffset(18, 48),
		Size = UDim2.new(1, -36, 0, 24),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextScaled = true,
		TextColor3 = T.TextDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "0/50 slot",
	}, frame)
	self.tasList = self:scrollArea(frame, 76)
end

function UIController:renderTas()
	local s = self.state
	local list = self.tasList
	for _, child in list:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	if not s then
		return
	end
	local slots = TasLogic.slotView(s.Seeds or {}, s.Crops or {})
	self.tasTitle.Text = "Slot terpakai: " .. #slots .. "/50  |  maks 250 per slot  |  jual di Koperasi lahanku"

	for _, slot in ipairs(slots) do
		local crop = CropConfig.byId(slot.id)
		local rColor = RARITY_COLOR[crop and crop.rarity or "common"] or T.TextDim
		local r = row(list, 58)
		Util.create("Frame", {
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.new(0, 6, 1, 0),
			BackgroundColor3 = rColor,
			BorderSizePixel = 0,
		}, r)
		local tag = slot.kind == "seed" and "BENIH" or "HASIL"
		swatch(r, rColor, string.sub(tag, 1, 1))
		Util.create("TextLabel", {
			Position = UDim2.fromOffset(62, 6),
			Size = UDim2.new(1, -240, 0, 26),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextScaled = true,
			TextColor3 = T.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = (slot.kind == "seed" and "Benih " or "") .. (crop and crop.name or slot.id),
		}, r)
		Util.create("TextLabel", {
			Position = UDim2.fromOffset(62, 32),
			Size = UDim2.new(1, -240, 0, 20),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextScaled = true,
			TextColor3 = T.TextDim,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = tag .. " " .. (crop and string.upper(crop.rarity) or "") .. (slot.kind == "crop" and ("  |  jual " .. CropConfig.sellOf(slot.id) .. " Micda/pcs") or ""),
		}, r)
		Util.create("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -66, 0.5, 0),
			Size = UDim2.fromOffset(110, 40),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBlack,
			TextScaled = true,
			TextColor3 = rColor,
			Text = slot.n .. "/250",
		}, r)
	end

	local bagCount = 0
	for _ in pairs(s.Bag or {}) do
		bagCount += 1
	end
	local fishCount = 0
	for _ in pairs(s.Fish or {}) do
		fishCount += 1
	end
	if bagCount > 0 or fishCount > 0 then
		Util.create("TextLabel", {
			Size = UDim2.new(1, -8, 0, 30),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBlack,
			TextScaled = true,
			TextColor3 = T.TextDim,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = "Bahan tempa & ikan (di luar slot tas):",
		}, list)
		local ids = {}
		for id in pairs(s.Bag or {}) do
			table.insert(ids, { kind = "bag", id = id })
		end
		for id in pairs(s.Fish or {}) do
			table.insert(ids, { kind = "fish", id = id })
		end
		table.sort(ids, function(a, b)
			return a.id < b.id
		end)
		local lookup = {}
		for _, res in ipairs(Config.Resources) do
			lookup[res.id] = res.name
		end
		for _, res in ipairs(Config.Fish) do
			lookup[res.id] = res.name
		end
		for _, entry in ipairs(ids) do
			local n = entry.kind == "bag" and (s.Bag[entry.id] or 0) or (s.Fish[entry.id] or 0)
			local r = row(list, 44)
			Util.create("TextLabel", {
				Position = UDim2.fromOffset(14, 4),
				Size = UDim2.new(1, -140, 0, 36),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				TextScaled = true,
				TextColor3 = T.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = lookup[entry.id] or entry.id,
			}, r)
			Util.create("TextLabel", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -12, 0.5, 0),
				Size = UDim2.fromOffset(90, 30),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBlack,
				TextScaled = true,
				TextColor3 = T.Gold,
				Text = "x" .. n,
			}, r)
		end
	end
end

function UIController:buildTokoPanel()
	local frame = self:panelFrame("Toko", 0.55, 0.7)
	self.tokoHeader = self:panelHeader(frame, "Toko Benih", T.Green)

	local tabs = {
		{ id = "pack", label = "Pack Benih" },
		{ id = "gabung", label = "Gabung Benih" },
	}
	self.tokoTabs = {}
	for i, tab in ipairs(tabs) do
		local b = btn({
			parent = frame,
			Name = "Tab" .. tab.id,
			Position = UDim2.new(0, 18 + (i - 1) * 150, 0, 50),
			Size = UDim2.fromOffset(140, 34),
			BackgroundColor3 = self.tokoTab == tab.id and T.Green or T.PanelLight,
			TextColor3 = self.tokoTab == tab.id and Color3.fromRGB(20, 30, 22) or T.Text,
			Text = tab.label,
			_radius = 8,
		})
		b.Activated:Connect(function()
			self.tokoTab = tab.id
			self:renderToko()
		end)
		self.tokoTabs[tab.id] = b
	end
	self.tokoList = self:scrollArea(frame, 94)
end

function UIController:renderToko()
	local s = self.state
	local list = self.tokoList
	for _, child in list:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	if not s then
		return
	end
	for id, b in pairs(self.tokoTabs) do
		b.BackgroundColor3 = self.tokoTab == id and T.Green or T.PanelLight
		b.TextColor3 = self.tokoTab == id and Color3.fromRGB(20, 30, 22) or T.Text
	end

	if self.tokoTab == "pack" then
		for _, pack in ipairs(CropConfig.Packs) do
			local rColor = RARITY_COLOR[pack.rarity] or T.TextDim
			local r = row(list, 92)
			Util.create("Frame", {
				Size = UDim2.new(0, 6, 1, 0),
				BackgroundColor3 = rColor,
				BorderSizePixel = 0,
			}, r)
			Util.create("TextLabel", {
				Position = UDim2.fromOffset(16, 8),
				Size = UDim2.new(1, -200, 0, 30),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBlack,
				TextScaled = true,
				TextColor3 = rColor,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = pack.name,
			}, r)
			Util.create("TextLabel", {
				Position = UDim2.fromOffset(16, 40),
				Size = UDim2.new(1, -200, 0, 22),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				TextScaled = true,
				TextColor3 = T.TextDim,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = "Berisi 3 benih acak kategori " .. string.upper(pack.rarity) .. " (kategori dijamin, jenisnya kejutan!)",
			}, r)
			Util.create("TextLabel", {
				Position = UDim2.fromOffset(16, 62),
				Size = UDim2.new(1, -200, 0, 24),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				TextScaled = true,
				TextColor3 = T.Gold,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = Util.formatNumber(pack.price) .. " Micda",
			}, r)
			btn({
				parent = r,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(110, 44),
				BackgroundColor3 = s.Coins >= pack.price and T.Gold or T.Disabled,
				TextColor3 = s.Coins >= pack.price and Color3.fromRGB(40, 30, 10) or T.Text,
				Text = "Beli",
				_radius = 8,
			}).Activated:Connect(function()
				local res = Remotes.get("TokoAct"):InvokeServer({ action = "buyPack", pack = pack.id })
				self:handleResult(res)
				self:renderToko()
			end)
		end
		Util.create("TextLabel", {
			Size = UDim2.new(1, -8, 0, 40),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextWrapped = true,
			TextColor3 = T.TextDim,
			Text = "Tips: benih hasil gabungan hanya bisa didapat lewat tab Gabung Benih!",
		}, list)
	else
		for _, recipe in ipairs(CropConfig.Recipes) do
			local a, b = CropConfig.byId(recipe.inputs[1]), CropConfig.byId(recipe.inputs[2])
			local out = CropConfig.byId(recipe.out)
			local nA = (s.Seeds and s.Seeds[recipe.inputs[1]]) or 0
			local nB = (s.Seeds and s.Seeds[recipe.inputs[2]]) or 0
			local can = nA >= 1 and nB >= 1
			local r = row(list, 84)
			local rColor = RARITY_COLOR[out.rarity] or T.TextDim
			Util.create("Frame", {
				Size = UDim2.new(0, 6, 1, 0),
				BackgroundColor3 = rColor,
				BorderSizePixel = 0,
			}, r)
			Util.create("TextLabel", {
				Position = UDim2.fromOffset(16, 8),
				Size = UDim2.new(1, -160, 0, 30),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBlack,
				TextScaled = true,
				TextColor3 = rColor,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = "Benih " .. a.name .. " + Benih " .. b.name,
			}, r)
			Util.create("TextLabel", {
				Position = UDim2.fromOffset(16, 40),
				Size = UDim2.new(1, -160, 0, 22),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				TextScaled = true,
				TextColor3 = T.Green,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = "= Benih " .. out.name .. " (" .. out.sell .. " Micda/hasil)",
			}, r)
			Util.create("TextLabel", {
				Position = UDim2.fromOffset(16, 62),
				Size = UDim2.new(1, -160, 0, 18),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				TextScaled = true,
				TextColor3 = T.TextDim,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = "Punya: " .. nA .. " & " .. nB,
			}, r)
			btn({
				parent = r,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(120, 44),
				BackgroundColor3 = can and T.Gold or T.Disabled,
				TextColor3 = can and Color3.fromRGB(40, 30, 10) or T.Text,
				Text = "Gabung",
				_radius = 8,
			}).Activated:Connect(function()
				local res = Remotes.get("TokoAct"):InvokeServer({ action = "combine", a = recipe.inputs[1], b = recipe.inputs[2] })
				self:handleResult(res)
				self:renderToko()
			end)
		end
		Util.create("TextLabel", {
			Size = UDim2.new(1, -8, 0, 36),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextWrapped = true,
			TextColor3 = T.TextDim,
			Text = "Hanya 8 kombinasi ini yang bisa digabung - kombinasi lain tidak akan berhasil!",
		}, list)
	end
end

function UIController:buildKebunPanel()
	local frame = self:panelFrame("Kebun", 0.6, 0.72)
	self.kebunHeader = self:panelHeader(frame, "Kebun 500 Petak", T.Green)
	self.kebunStats = Util.create("TextLabel", {
		Name = "Stats",
		Position = UDim2.fromOffset(18, 48),
		Size = UDim2.new(1, -36, 0, 24),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextScaled = true,
		TextColor3 = T.TextDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "Kosong - | Tumbuh - | Siap -",
	}, frame)

	local seedRow = Util.create("Frame", {
		Name = "SeedRow",
		Position = UDim2.fromOffset(18, 76),
		Size = UDim2.new(1, -36, 0, 40),
		BackgroundTransparency = 1,
	}, frame)
	Util.create("UIListLayout", {
		Padding = UDim.new(0, 6),
		FillDirection = Enum.FillDirection.Horizontal,
	}, seedRow)
	self.seedRow = seedRow
	self.seedButtons = {}

	local actions = {
		{ label = "Tanam 1", cb = function()
			self:sendFarm({ action = "plant", plot = self:firstEmptyPlot(), seed = self.farmSeed })
		end },
		{ label = "Tanam Semua", cb = function()
			self:sendFarm({ action = "plantAll", seed = self.farmSeed })
		end },
		{ label = "Panen Semua", cb = function()
			self:sendFarm({ action = "harvestAll" })
		end },
		{ label = "Segarkan", cb = function()
			self:sendFarm({ action = "info" })
		end },
	}
	for i, act in ipairs(actions) do
		btn({
			parent = frame,
			Name = "FarmAct" .. i,
			Position = UDim2.new(0, 18 + (i - 1) * 152, 0, 124),
			Size = UDim2.fromOffset(142, 38),
			BackgroundColor3 = i == 3 and T.Gold or T.PanelLight,
			TextColor3 = i == 3 and Color3.fromRGB(40, 30, 10) or T.Text,
			Text = act.label,
			_radius = 8,
		}).Activated:Connect(act.cb)
	end

	local gridHolder = Util.create("Frame", {
		Name = "Grid",
		Position = UDim2.fromOffset(18, 172),
		Size = UDim2.new(1, -36, 1, -192),
		BackgroundColor3 = T.Bg,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
	}, frame)
	corner(gridHolder, 10)
	self.farmGrid = gridHolder
end

function UIController:firstEmptyPlot(): number
	if self.farmSnap and self.farmSnap.states then
		for i, st in ipairs(self.farmSnap.states) do
			if st == 0 then
				return i
			end
		end
	end
	return 1
end

function UIController:sendFarm(payload: { [string]: any })
	payload.lahan = self.state and self.state.HomeId or 0
	local res = Remotes.get("FarmAct"):InvokeServer(payload)
	self:handleResult(res)
	local info = Remotes.get("FarmAct"):InvokeServer({ lahan = payload.lahan, action = "info" })
	if info and info.ok and info.farm then
		self.farmSnap = info.farm
	end
	self:renderKebun()
end

function UIController:renderKebun()
	local s = self.state
	if not s then
		return
	end
	if not self.farmSnap then
		self.farmSnap = s.Farm and s.Farm.lahan == s.HomeId and s.Farm or nil
	end
	local snap = self.farmSnap
	if snap then
		self.kebunStats.Text = "Kosong " .. snap.kosong .. "  |  Tumbuh " .. snap.tumbuh .. "  |  Siap Panen " .. snap.siap
	end

	for _, child in self.seedRow:GetChildren() do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	self.seedButtons = {}
	local seedIds = {}
	for id, n in pairs(s.Seeds or {}) do
		if n > 0 then
			table.insert(seedIds, id)
		end
	end
	table.sort(seedIds, function(a, b)
		return CropConfig.nameOf(a) < CropConfig.nameOf(b)
	end)
	if #seedIds == 0 then
		Util.create("TextLabel", {
			Size = UDim2.new(0, 420, 1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextScaled = true,
			TextColor3 = T.Red,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = "Tidak ada benih! Beli Pack Benih di Toko Benih (Pusat Kota).",
		}, self.seedRow)
	else
		if self.farmSeed == "" or not s.Seeds[self.farmSeed] then
			self.farmSeed = seedIds[1]
		end
		for _, id in ipairs(seedIds) do
			local crop = CropConfig.byId(id)
			local sel = id == self.farmSeed
			local b = btn({
				parent = self.seedRow,
				Name = "Seed" .. id,
				Size = UDim2.fromOffset(150, 40),
				BackgroundColor3 = sel and T.Green or T.PanelLight,
				TextColor3 = sel and Color3.fromRGB(20, 30, 22) or T.Text,
				Text = crop.name .. " x" .. (s.Seeds[id] or 0),
				_radius = 8,
			})
			b.Activated:Connect(function()
				self.farmSeed = id
				self:renderKebun()
			end)
			table.insert(self.seedButtons, b)
		end
	end

	for _, child in self.farmGrid:GetChildren() do
		child:Destroy()
	end
	if not snap or not snap.states then
		return
	end
	local cols, rows = 25, 20
	local cellW = 15
	local cellH = 8
	for plotNo = 1, math.min(#snap.states, cols * rows) do
		local st = snap.states[plotNo]
		local col = (plotNo - 1) % cols
		local r = math.floor((plotNo - 1) / cols)
		local cell = Util.create("Frame", {
			Position = UDim2.fromOffset(6 + col * cellW, 5 + r * cellH),
			Size = UDim2.fromOffset(cellW - 2, cellH - 2),
			BackgroundColor3 = st == 2 and T.Gold or (st == 1 and T.Green or Color3.fromRGB(92, 72, 52)),
			BorderSizePixel = 0,
		}, self.farmGrid)
		corner(cell, 2)
	end
end

function UIController:buildKoperasiPanel()
	local frame = self:panelFrame("Koperasi", 0.55, 0.7)
	self.koperasiHeader = self:panelHeader(frame, "Koperasi", T.Gold)
	self.koperasiInfo = Util.create("TextLabel", {
		Name = "Info",
		Position = UDim2.fromOffset(18, 48),
		Size = UDim2.new(1, -36, 0, 24),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextScaled = true,
		TextColor3 = T.TextDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "Harga tetap & transparan",
	}, frame)
	btn({
		parent = frame,
		Name = "JualSemua",
		Position = UDim2.new(1, -250, 0, 46),
		Size = UDim2.fromOffset(220, 36),
		BackgroundColor3 = T.Gold,
		TextColor3 = Color3.fromRGB(40, 30, 10),
		Text = "Jual Semua Isi Tas",
		_radius = 8,
	}).Activated:Connect(function()
		local res = Remotes.get("KoperasiAct"):InvokeServer({ action = "sellAll" })
		self:handleResult(res)
		self:refreshKoperasi()
	end)
	self.koperasiList = self:scrollArea(frame, 90)
end

function UIController:refreshKoperasi()
	local res = Remotes.get("KoperasiAct"):InvokeServer({ action = "offers" })
	if res and res.ok and res.offers then
		self.koperasiOffers = res.offers
	end
	self:renderKoperasi()
end

function UIController:renderKoperasi()
	local s = self.state
	local list = self.koperasiList
	for _, child in list:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	if self.koperasiName ~= "" then
		self.koperasiHeader.Text = "Koperasi " .. self.koperasiName
	end
	if not s then
		return
	end
	if #self.koperasiOffers == 0 then
		Util.create("TextLabel", {
			Size = UDim2.new(1, -8, 0, 60),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextWrapped = true,
			TextColor3 = T.TextDim,
			Text = "Belum ada barang untuk dijual. Panen tanaman / pancing ikan / kalahkan monster dulu!",
		}, list)
		return
	end
	for _, offer in ipairs(self.koperasiOffers) do
		local r = row(list, 60)
		Util.create("TextLabel", {
			Position = UDim2.fromOffset(14, 6),
			Size = UDim2.new(1, -320, 0, 26),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextScaled = true,
			TextColor3 = T.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = offer.name,
		}, r)
		Util.create("TextLabel", {
			Position = UDim2.fromOffset(14, 32),
			Size = UDim2.new(1, -320, 0, 22),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextScaled = true,
			TextColor3 = T.TextDim,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = "Punya " .. offer.count .. "  |  " .. offer.price .. " Micda/pcs  =  " .. Util.formatNumber(offer.price * offer.count),
		}, r)
		btn({
			parent = r,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(92, 38),
			BackgroundColor3 = T.Gold,
			TextColor3 = Color3.fromRGB(40, 30, 10),
			Text = "Jual Semua",
			_radius = 8,
		}).Activated:Connect(function()
			local res = Remotes.get("KoperasiAct"):InvokeServer({ action = "sell", kind = offer.kind, id = offer.id, all = true })
			self:handleResult(res)
			self:refreshKoperasi()
		end)
		btn({
			parent = r,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -110, 0.5, 0),
			Size = UDim2.fromOffset(92, 38),
			BackgroundColor3 = T.PanelLight,
			TextColor3 = T.Text,
			Text = "Jual 1",
			_radius = 8,
		}).Activated:Connect(function()
			local res = Remotes.get("KoperasiAct"):InvokeServer({ action = "sell", kind = offer.kind, id = offer.id, all = false })
			self:handleResult(res)
			self:refreshKoperasi()
		end)
	end
end

function UIController:buildCharPanel()
	local frame = self:panelFrame("Char", 0.5, 0.66)
	self:panelHeader(frame, "Karakter & Peralatan", T.Blue)
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
	self.charList = self:scrollArea(frame, 80)
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
		local star = (s.EquipStars and s.EquipStars[eqId]) or 0
		local statText = ""
		if eq then
			local base = kind == "weapon" and eq.atk or eq.def
			statText = (kind == "weapon" and "ATK +" or "DEF +") .. Balance.starScaled(base, star)
				.. (star > 0 and ("  +" .. star) or "")
		end
		Util.create("TextLabel", {
			Position = UDim2.fromOffset(62, 8),
			Size = UDim2.new(1, -250, 0, 40),
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
			if star < Balance.MaxStar then
				local micda = select(1, Balance.upgradeCost(star))
				btn({
					parent = r,
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, -96, 0, 10),
					Size = UDim2.fromOffset(84, 34),
					BackgroundColor3 = T.Gold,
					TextColor3 = Color3.fromRGB(40, 30, 10),
					Text = "Naik +" .. (star + 1),
					_radius = 8,
				}).Activated:Connect(function()
					local res = Remotes.get("EquipUpgrade"):InvokeServer(eqId)
					self:handleResult(res)
					self:renderChar()
				end)
				Util.create("TextLabel", {
					AnchorPoint = Vector2.new(1, 1),
					Position = UDim2.new(1, -96, 1, 0),
					Size = UDim2.fromOffset(84, 14),
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham,
					TextScaled = true,
					TextColor3 = T.TextDim,
					Text = micda .. " Micda + balok",
				}, r)
			end
		end
	end

	for _, eq in ipairs(Balance.Equipment) do
		if (s.Equips and s.Equips[eq.id]) or 0 > 0 and s.Equipped[eq.kind] ~= eq.id then
			local r = row(list, 52)
			swatch(r, Color3.fromRGB(eq.color[1], eq.color[2], eq.color[3]), eq.kind == "weapon" and "S" or "Z")
			Util.create("TextLabel", {
				Position = UDim2.fromOffset(62, 6),
				Size = UDim2.new(1, -180, 0, 40),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				TextScaled = true,
				TextColor3 = T.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = eq.name .. " x" .. (s.Equips[eq.id] or 0)
					.. "  (" .. (eq.kind == "weapon" and "ATK +" or "DEF +") .. eq[eq.kind == "weapon" and "atk" or "def"] .. ")",
			}, r)
			btn({
				parent = r,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -8, 0, 9),
				Size = UDim2.fromOffset(84, 34),
				BackgroundColor3 = T.Green,
				TextColor3 = Color3.fromRGB(24, 30, 26),
				Text = "Pakai",
				_radius = 8,
			}).Activated:Connect(function()
				local res = Remotes.get("Equip"):InvokeServer(eq.kind, eq.id)
				self:handleResult(res)
				self:renderChar()
			end)
		end
	end
end

local MAT_LOOKUPS = {}
for _, res in ipairs(Config.Resources) do
	MAT_LOOKUPS[res.id] = res.name
end
for _, crop in ipairs(CropConfig.Crops) do
	MAT_LOOKUPS[crop.id] = crop.name
end
for _, fish in ipairs(Config.Fish) do
	MAT_LOOKUPS[fish.id] = fish.name
end

function UIController:buildCraftPanel()
	local frame = self:panelFrame("Craft", 0.5, 0.64)
	self.craftHeader = self:panelHeader(frame, "Stasiun Kerja", Color3.fromRGB(255, 150, 90))
	self.craftList = self:scrollArea(frame, 54)
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

	local titles = { tempa = "Pandai Besi - Pak Tempa", dapur = "Dapur Alam - Bu Masak" }
	self.craftHeader.Text = titles[self.craftStation] or "Stasiun Kerja"

	for _, recipe in ipairs(Balance.Recipes) do
		if recipe.station ~= self.craftStation then
			continue
		end
		local outName = recipe.out
		local count = 0
		if recipe.kind == "equip" then
			for _, eq in ipairs(Balance.Equipment) do
				if eq.id == recipe.out then
					outName = eq.name
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
		else
			for _, res in ipairs(Config.Resources) do
				if res.id == recipe.out then
					outName = res.name
					count = s.Bag[recipe.out] or 0
					break
				end
			end
		end
		local canCraft = s.Level >= recipe.level
		local mats = {}
		for matId, need in pairs(recipe.recipe) do
			local have = ((s.Bag or {})[matId] or 0) + ((s.Crops or {})[matId] or 0) + ((s.Fish or {})[matId] or 0)
			if have < need then
				canCraft = false
			end
			table.insert(mats, (MAT_LOOKUPS[matId] or matId) .. " " .. have .. "/" .. need)
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
			Text = "Bahan: " .. table.concat(mats, ", ") .. " | Lv " .. recipe.level .. " | +"
			.. Balance.craftXpWithMastery(recipe.xp, (s.CraftCount and s.CraftCount[recipe.id]) or 0) .. " XP"
			.. (((s.CraftCount and s.CraftCount[recipe.id]) or 0) >= Balance.CraftMasterySteps
				and ("  M" .. Balance.craftMasteryLevel((s.CraftCount and s.CraftCount[recipe.id]) or 0)) or ""),
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

function UIController:buildCodePanel()
	local frame = self:panelFrame("Code", 0.3, 0.3)
	self:panelHeader(frame, "Kode Penjelajah", T.Blue)
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
	local frame = self:panelFrame("Help", 0.46, 0.6)
	self:panelHeader(frame, "Cara Hidup di Dunia Akiomida", T.Green)
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
			"1. LAHAN: setiap pemain punya SATU lahan otomatis - titik lahir & respawnmu. Isi: rumah 3 lantai + rooftop, kebun 500 petak, kolam air, ruang Bedah/Sains/Startopia/Pancing, koperasi & papan nama.",
			"2. BENIH: beli Pack di TOKO BENIH (Pusat Kota) - Common 400 / Rare 1.500 / Epic 3.500 Micda, isi 3 benih acak per kategori.",
			"3. TANAM: kebun 500 petak, tumbuh 3 detik, panen 1-4 hasil acak per petak. Gunakan Tanam Semua & Panen Semua!",
			"4. GABUNG: 8 resep gabung benih di Toko Benih - contoh Tangelo = Mandarin + Grapefruit.",
			"5. TAS: 50 slot, satu jenis per slot, maksimal 250 per slot. Tas penuh = tidak bisa panen!",
			"6. JUAL: koperasi di lahanku membeli panen, ikan & bahan monster dengan harga tetap transparan.",
			"7. KOMBAT: monster ANGKA hanya di pulau monster. Pukulan lemah - tempa pedang supaya sakit!",
			"8. TEMPAA: kumpulkan drop monster, buat Balok Besi lalu Pedang & Zirah di Pandai Besi (Negeri Baja).",
			"9. MASAK: Dapur Alam (Padang Liar) - makanan buff & ramuan dari hasil panenmu!",
			"10. BOSS: Angka Sang Raja (9) di Arena tiap +-15 menit. Hadiah sesuai kontribusi!",
			"11. STAT: tiap naik level = 2 poin. STR serangan, VIT HP, AGI lari, INT sihir, DEX kritikal.",
		}, "\n"),
	}, frame)
end

function UIController:buildNamaPanel()
	local frame = self:panelFrame("Nama", 0.34, 0.34)
	self:panelHeader(frame, "Papan Nama Lahan", T.Green)
	Util.create("TextLabel", {
		Name = "Ket",
		Position = UDim2.fromOffset(18, 50),
		Size = UDim2.new(1, -36, 0, 40),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextScaled = true,
		TextColor3 = T.TextDim,
		TextWrapped = true,
		Text = "Wajib diisi! 3-20 huruf/angka. Nama ini tampil di papan lahanmu.",
	}, frame)
	local input = Util.create("TextBox", {
		Name = "Input",
		Position = UDim2.fromOffset(18, 94),
		Size = UDim2.new(1, -120, 0, 42),
		BackgroundColor3 = T.PanelLight,
		TextColor3 = T.Text,
		Font = Enum.Font.GothamBold,
		TextScaled = true,
		PlaceholderText = "Nama lahanku...",
		ClearTextOnFocus = false,
		Text = "",
	}, frame)
	corner(input, 8)
	btn({
		parent = frame,
		Name = "Simpan",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 94),
		Size = UDim2.fromOffset(96, 42),
		BackgroundColor3 = T.Gold,
		TextColor3 = Color3.fromRGB(40, 30, 10),
		Text = "Simpan",
		_radius = 8,
	}).Activated:Connect(function()
		local text = input.Text
		if text == "" then
			return
		end
		local ok, msg = Remotes.get("LandBoard"):InvokeServer(text)
		if ok then
			self:toast("Papan Nama", msg or "Tersimpan!", T.Green)
			self:showPanel(nil)
		else
			self:toast("Nama Tidak Valid", msg or "Coba nama lain.", T.Red)
		end
	end)
end

function UIController:wireRemotes()
	Remotes.get("StateSync").OnClientEvent:Connect(function(state)
		self.state = state
		self:renderState()
	end)

	Remotes.get("Notify").OnClientEvent:Connect(function(title, text)
		self:toast(title, text, T.Gold)
	end)

	Remotes.get("OpenFarm").OnClientEvent:Connect(function(lahanIndex)
		local info = Remotes.get("FarmAct"):InvokeServer({ lahan = lahanIndex, action = "info" })
		if info and info.ok and info.farm then
			self.farmSnap = info.farm
		end
		self:renderKebun()
		self:showPanel("Kebun")
	end)

	Remotes.get("OpenToko").OnClientEvent:Connect(function()
		self.tokoTab = "pack"
		self:renderToko()
		self:showPanel("Toko")
	end)

	Remotes.get("OpenKoperasi").OnClientEvent:Connect(function(koperasiName)
		self.koperasiName = type(koperasiName) == "string" and koperasiName or ""
		self:refreshKoperasi()
		self:showPanel("Koperasi")
	end)

	Remotes.get("OpenCraft").OnClientEvent:Connect(function(station)
		self.craftStation = station
		self:renderCraft()
		self:showPanel("Craft")
	end)

	Remotes.get("OpenChar").OnClientEvent:Connect(function()
		self:renderChar()
		self:showPanel("Char")
	end)

	Remotes.get("OpenLandBoard").OnClientEvent:Connect(function()
		local f = self.gui:FindFirstChild("Nama")
		if f and self.state and self.state.LandName and self.state.LandName ~= "" then
			local input = f:FindFirstChild("Input")
			if input and input:IsA("TextBox") then
				input.Text = self.state.LandName
			end
		end
		self:showPanel("Nama")
	end)

	Remotes.get("BossState").OnClientEvent:Connect(function(info)
		if info.active then
			self.bossBar.Visible = true
			self.bossTitle.Text = info.name .. " - " .. (info.zone or "Arena") .. (info.enraged and " - MURKA!" or "")
			self.bossHp.Size = UDim2.fromScale(math.clamp((info.hp or 1) / (info.maxHp or 1), 0.02, 1), 1)
		else
			self.bossBar.Visible = false
			if info.killed then
				self:toast("BOSS DIKALAHKAN!", info.name .. " tumbang berkat kerja sama tim!", T.Red)
				makeSound(1.4):Play()
			end
		end
	end)

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
