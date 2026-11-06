local semaiPanel = makePanel("semai")
mk("TextLabel", { Size = UDim2.new(1, -8, 0, 30), Position = UDim2.new(0, 4, 0, 0), BackgroundTransparency = 1, Text = "Pilih hasil panen, atur jumlah, isi mesin, lalu jodohkan kabel warnanya. Setelah gilingan tuntas, klaim Micda, benih, dan blok hasil semai.", TextWrapped = true, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left }, semaiPanel)
local semaiScroll = mk("ScrollingFrame", { Size = UDim2.new(1, -8, 1, -206), Position = UDim2.new(0, 4, 0, 34), BackgroundTransparency = 1, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0) }, semaiPanel)
mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, semaiScroll)
local semaiAtur = mk("Frame", { Size = UDim2.new(1, -8, 0, 164), Position = UDim2.new(0, 4, 1, -168), BackgroundColor3 = warna(UIStyle.Permukaan) }, semaiPanel)
round(semaiAtur)
mk("TextLabel", { Size = UDim2.new(0, 76, 0, 30), Position = UDim2.new(0, 10, 0, 8), BackgroundTransparency = 1, Text = "Jumlah:", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left }, semaiAtur)
local semaiQty = mk("TextBox", { Size = UDim2.new(0, 86, 0, 30), Position = UDim2.new(0, 86, 0, 8), BackgroundColor3 = warna(UIStyle.PermukaanAktif), Text = "1", PlaceholderText = "1", TextSize = UIStyle.UkuranIsi, Font = FON, TextColor3 = warna(UIStyle.Teks), ClearTextOnFocus = false }, semaiAtur)
round(semaiQty, UIStyle.SudutKecil)
local semaiPresets = mk("Frame", { Size = UDim2.new(1, -196, 0, 30), Position = UDim2.new(0, 182, 0, 8), BackgroundTransparency = 1 }, semaiAtur)
mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, semaiPresets)
for pi, pn in ipairs({ 1, 10, 50, 100, 500 }) do
	local pb = mk("TextButton", { Size = UDim2.new(0.2, -6, 1, 0), BackgroundColor3 = warna(UIStyle.Latar), Text = tostring(pn), TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Teks), LayoutOrder = pi }, semaiPresets)
	round(pb, UIStyle.SudutKecil)
	pb.Activated:Connect(function()
		semaiQty.Text = tostring(pn)
	end)
end
local semaiMaksBtn = mk("TextButton", { Size = UDim2.new(0, 86, 0, 24), Position = UDim2.new(0, 86, 0, 42), BackgroundColor3 = warna(UIStyle.Latar), Text = "Maks", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Teks) }, semaiAtur)
round(semaiMaksBtn, UIStyle.SudutKecil)
local semaiPreview1 = mk("TextLabel", { Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 72), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranKecil, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, semaiAtur)
local semaiPreview2 = mk("TextLabel", { Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 94), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, semaiAtur)
local semaiIsiBtn = mk("TextButton", { Size = UDim2.new(1, -20, 0, 38), Position = UDim2.new(0, 10, 1, -44), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Isi Mesin Semai", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1) }, semaiAtur)
round(semaiIsiBtn, UIStyle.SudutKecil)

local semaiPilih: string? = nil
local bukaKabel: () -> ()
local bukaStrukKlaim: (any) -> ()

local function semaiDimiliki(): number
	if not semaiPilih then
		return 0
	end
	for _, s in ipairs(state.tas) do
		if s.kind == "hasil" and s.id == semaiPilih then
			return s.count
		end
	end
	return 0
end

local function perbaruiSemaiPreview()
	local info = semaiPilih and CropData.byId[semaiPilih]
	local per = 0
	if info then
		per = SemaiLogic.pukulanPerItem(CropData.Giling[info.rarity])
	end
	local dimiliki = semaiDimiliki()
	local n = SemaiLogic.saringJumlah(semaiQty.Text, dimiliki, CropData.MesinSemai.Kapasitas)
	if info and n then
		semaiPreview1.Text = "Pukulan per item: " .. tostring(per) .. " — Total pukulan: " .. tostring(SemaiLogic.pukulanTotal(n, per))
	else
		semaiPreview1.Text = "Pukulan per item: " .. tostring(per)
	end
	semaiPreview2.Text = "Dimiliki: " .. tostring(dimiliki) .. " — Kapasitas mesin: " .. tostring(CropData.MesinSemai.Kapasitas)
end

semaiQty:GetPropertyChangedSignal("Text"):Connect(perbaruiSemaiPreview)
semaiMaksBtn.Activated:Connect(function()
	local dimiliki = semaiDimiliki()
	if dimiliki > 0 then
		semaiQty.Text = tostring(math.min(dimiliki, CropData.MesinSemai.Kapasitas))
	end
end)

local kabelDim = mk("Frame", { Name = "ModalKabel", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.55, Visible = false, ZIndex = 30 }, gui)
local kabelBox = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0.92, 0, 0.82, 0), BackgroundColor3 = warna(UIStyle.Latar), ZIndex = 31 }, kabelDim)
round(kabelBox, 12)
mk("UISizeConstraint", { MinSize = Vector2.new(300, 300), MaxSize = Vector2.new(480, 580) }, kabelBox)
mk("TextLabel", { Size = UDim2.new(1, -56, 0, 28), Position = UDim2.new(0, 12, 0, 8), BackgroundTransparency = 1, Text = "Sambungkan Kabel Mesin", TextSize = UIStyle.UkuranJudul, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 32 }, kabelBox)
mk("TextLabel", { Size = UDim2.new(1, -24, 0, 32), Position = UDim2.new(0, 12, 0, 38), BackgroundTransparency = 1, Text = "Tarik kabel dari soket kiri ke soket warna yang sama di kanan (atau ketuk kiri lalu kanan). Susunan selalu acak.", TextWrapped = true, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 32 }, kabelBox)
local kabelArea = mk("Frame", { Size = UDim2.new(1, -24, 1, -144), Position = UDim2.new(0, 12, 0, 76), BackgroundColor3 = warna(UIStyle.Permukaan), ZIndex = 32 }, kabelBox)
round(kabelArea, UIStyle.SudutKecil)
local kabelGaris = mk("Frame", { Name = "GarisKabel", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 40 }, kabelArea)
local kabelStatus = mk("TextLabel", { Size = UDim2.new(1, -24, 0, 22), Position = UDim2.new(0, 12, 1, -30), BackgroundTransparency = 1, Text = "", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Aksen), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 33 }, kabelBox)
local kabelTutup = mk("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 8), Size = UDim2.new(0, 40, 0, 30), BackgroundColor3 = warna(UIStyle.Permukaan), Text = "X", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), ZIndex = 33 }, kabelBox)
round(kabelTutup, UIStyle.SudutKecil)
local kabelSfx = mk("Sound", { SoundId = "rbxasset://sounds/electronicpingshort.wav", Volume = 0.4, PlaybackSpeed = 1.15 }, gui)

local kabelCfg: any = nil
local kabelSambung: { [number]: number } = {}
local kabelPilihKiri: number? = nil
local kabelDrag: any = nil
local soketKiri: { any } = {}
local soketKanan: { any } = {}

local function warnaKabel(i: number): Color3
	local w = SemaiLogic.WarnaKabel[i] or { 200, 200, 200 }
	return Color3.fromRGB(w[1], w[2], w[3])
end

local function pusatSoket(f: any): (number, number)
	local ap = kabelArea.AbsolutePosition or { X = 0, Y = 0 }
	local fp = f.AbsolutePosition or { X = 0, Y = 0 }
	local fs = f.AbsoluteSize or { X = 48, Y = 48 }
	return fp.X - ap.X + fs.X / 2, fp.Y - ap.Y + fs.Y / 2
end

local function gambarGaris(dariX: number, dariY: number, keX: number, keY: number, color: Color3, tebal: number, transparansi: number): Frame
	local mx, my = (dariX + keX) / 2, (dariY + keY) / 2
	local dx, dy = keX - dariX, keY - dariY
	local panjang = math.sqrt(dx * dx + dy * dy)
	local f = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(mx, my), Size = UDim2.fromOffset(math.max(4, panjang), tebal), BackgroundColor3 = color, BackgroundTransparency = transparansi, BorderSizePixel = 0, ZIndex = 41 }, kabelGaris)
	round(f, math.floor(tebal / 2))
	f.Rotation = math.deg(math.atan2(dy, dx))
	return f
end

local function tandaiPilih()
	for i, s in ipairs(soketKiri) do
		s.frame.BackgroundColor3 = (kabelPilihKiri == i) and warna(UIStyle.PermukaanAktif) or warna(UIStyle.AbuGelap)
		s.inti.BackgroundTransparency = kabelSambung[i] and 0 or 0.35
	end
	for j, s in ipairs(soketKanan) do
		s.inti.BackgroundTransparency = 0.35
		for _, terhubung in pairs(kabelSambung) do
			if terhubung == j then
				s.inti.BackgroundTransparency = 0
			end
		end
	end
end

local function cobaSambung(i: number, j: number)
	if not kabelCfg or kabelSambung[i] then
		return
	end
	if kabelCfg.kiri[i] == kabelCfg.kanan[j] then
		kabelSambung[i] = j
		local sx, sy = pusatSoket(soketKiri[i].frame)
		local tx, ty = pusatSoket(soketKanan[j].frame)
		gambarGaris(sx, sy, tx, ty, warnaKabel(kabelCfg.kiri[i]), 10, 0)
		soketKiri[i].inti.BackgroundTransparency = 0
		soketKanan[j].inti.BackgroundTransparency = 0
		kabelSfx:Play()
		kabelPilihKiri = nil
		tandaiPilih()
		local terhubung = 0
		for _ in pairs(kabelSambung) do
			terhubung += 1
		end
		kabelStatus.TextColor3 = warna(UIStyle.Aksen)
		kabelStatus.Text = "Terhubung " .. tostring(terhubung) .. "/" .. tostring(kabelCfg.n)
		if SemaiLogic.kabelSelesai(kabelCfg, kabelSambung) then
			kabelStatus.Text = "Semua kabel terjodohkan! Mesin aktif..."
			task.delay(0.4, function()
				kabelDim.Visible = false
				task.spawn(function()
					local ok, msg = Net.get("SemaiAct"):InvokeServer("kabel")
					toast(ok and "Mesin Semai" or "Gagal", msg)
				end)
			end)
		end
	else
		kabelStatus.TextColor3 = warna(UIStyle.Merah)
		kabelStatus.Text = "Warna tidak cocok! Jodohkan kabel dengan warna yang sama."
	end
end

local function buatSoket(sisi: string, warnaIdx: number, yf: number, jitter: number): (Frame, Frame, UIStroke)
	local warna = warnaKabel(warnaIdx)
	local f = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = (sisi == "kiri") and UDim2.new(0, 52, yf, jitter) or UDim2.new(1, -52, yf, jitter),
		Size = UDim2.fromOffset(48, 48),
		BackgroundColor3 = warna(UIStyle.AbuGelap),
		ZIndex = 45,
	}, kabelArea)
	round(f, 24)
	local stroke = mk("UIStroke", { Color = warna, Thickness = 3, Transparency = 0.1 }, f)
	local inti = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.52, 0.52), BackgroundColor3 = warna, BackgroundTransparency = 0.35, ZIndex = 46 }, f)
	round(inti, 12)
	return f, inti, stroke
end

local function bangunKabel()
	for _, c in ipairs(kabelGaris:GetChildren()) do
		c:Destroy()
	end
	for _, c in ipairs(kabelArea:GetChildren()) do
		if c ~= kabelGaris then
			c:Destroy()
		end
	end
	soketKiri, soketKanan = {}, {}
	kabelSambung = {}
	kabelPilihKiri = nil
	kabelDrag = nil
	local jr = Random.new()
	for i = 1, kabelCfg.n do
		local yf = (i - 0.5) / kabelCfg.n
		local jKiri = jr:NextNumber() * 16 - 8
		local jKanan = jr:NextNumber() * 16 - 8
		local fk, intiK, _s1 = buatSoket("kiri", kabelCfg.kiri[i], yf, jKiri)
		local fn, intiN, _s2 = buatSoket("kanan", kabelCfg.kanan[i], yf, jKanan)
		soketKiri[i] = { frame = fk, inti = intiK, warna = kabelCfg.kiri[i] }
		soketKanan[i] = { frame = fn, inti = intiN, warna = kabelCfg.kanan[i] }
		fk.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				if input.UserInputState ~= Enum.UserInputState.Begin or kabelSambung[i] then
					return
				end
				kabelDrag = { dari = i }
				kabelPilihKiri = i
				tandaiPilih()
			end
		end)
		fk.Activated:Connect(function()
			if kabelSambung[i] then
				return
			end
			kabelPilihKiri = (kabelPilihKiri == i) and nil or i
			tandaiPilih()
		end)
		fn.Activated:Connect(function()
			if kabelPilihKiri then
				cobaSambung(kabelPilihKiri, i)
			end
		end)
	end
	tandaiPilih()
end

bukaKabel = function()
	if not (state.semai and state.semai.tahap == "kabel") then
		return
	end
	kabelCfg = SemaiLogic.buatKabel(Random.new())
	bangunKabel()
	kabelStatus.TextColor3 = warna(UIStyle.Aksen)
	kabelStatus.Text = "Terhubung 0/" .. tostring(kabelCfg.n)
	kabelDim.Visible = true
end

kabelTutup.Activated:Connect(function()
	kabelDim.Visible = false
end)

UserInputService.InputChanged:Connect(function(input)
	if not kabelDrag then
		return
	end
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		local ap = kabelArea.AbsolutePosition or { X = 0, Y = 0 }
		local x = input.Position.X - ap.X
		local y = input.Position.Y - ap.Y
		if kabelDrag.garis then
			kabelDrag.garis:Destroy()
		end
		local sx, sy = pusatSoket(soketKiri[kabelDrag.dari].frame)
		kabelDrag.garis = gambarGaris(sx, sy, x, y, warnaKabel(kabelCfg.kiri[kabelDrag.dari]), 8, 0.25)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if not kabelDrag then
		return
	end
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		local ap = kabelArea.AbsolutePosition or { X = 0, Y = 0 }
		local x = input.Position.X - ap.X
		local y = input.Position.Y - ap.Y
		local target: number? = nil
		for j, s in ipairs(soketKanan) do
			local cx, cy = pusatSoket(s.frame)
			if math.abs(x - cx) <= 36 and math.abs(y - cy) <= 36 then
				target = j
				break
			end
		end
		if kabelDrag.garis then
			kabelDrag.garis:Destroy()
		end
		local dari = kabelDrag.dari
		kabelDrag = nil
		if target then
			cobaSambung(dari, target :: number)
		end
	end
end)

local function klaimSemai()
	task.spawn(function()
		local ok, msg, struk = Net.get("SemaiAct"):InvokeServer("klaim")
		if ok and type(struk) == "table" then
			syncState()
			bukaStrukKlaim(struk)
			toast("Semai Tuntas", msg)
		else
			toast("Gagal", tostring(msg))
		end
	end)
end

semaiIsiBtn.Activated:Connect(function()
	if not semaiPilih then
		semaiPreview1.TextColor3 = warna(UIStyle.Merah)
		semaiPreview1.Text = "Pilih salah satu hasil panen di daftar dulu."
		task.delay(1.4, function()
			semaiPreview1.TextColor3 = warna(UIStyle.Teks)
			perbaruiSemaiPreview()
		end)
		return
	end
	local dimiliki = semaiDimiliki()
	local n = SemaiLogic.saringJumlah(semaiQty.Text, dimiliki, CropData.MesinSemai.Kapasitas)
	if not n then
		semaiPreview1.TextColor3 = warna(UIStyle.Merah)
		semaiPreview1.Text = "Jumlah harus angka 1 sampai " .. tostring(math.max(1, math.min(dimiliki, CropData.MesinSemai.Kapasitas))) .. "."
		task.delay(1.4, function()
			semaiPreview1.TextColor3 = warna(UIStyle.Teks)
			perbaruiSemaiPreview()
		end)
		return
	end
	task.spawn(function()
		local ok, msg = Net.get("SemaiAct"):InvokeServer("atur", semaiPilih, n)
		toast(ok and "Mesin Semai" or "Gagal", msg)
		if ok then
			syncState()
			for _ = 1, 12 do
				if state.semai and state.semai.tahap == "kabel" then
					break
				end
				task.wait(0.1)
			end
			bukaKabel()
		end
	end)
end)

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
	local b = state.semai
	local adaBatch = type(b) == "table" and b.tahap ~= nil and b.tahap ~= "kosong"
	semaiAtur.Visible = not adaBatch
	bersihkan(semaiScroll)
	if not adaBatch then
		local order = 0
		for _, s in ipairs(state.tas) do
			if s.kind == "hasil" then
				order += 1
				local info = CropData.byId[s.id]
				local cfg = info and CropData.Giling[info.rarity]
				local per = cfg and SemaiLogic.pukulanPerItem(cfg) or 0
				local row = mk("TextButton", { Size = UDim2.new(1, -8, 0, 46), BackgroundColor3 = warna(s.id == semaiPilih and UIStyle.PermukaanAktif or UIStyle.Permukaan), Text = "", AutoButtonColor = true, LayoutOrder = order }, semaiScroll)
				round(row, UIStyle.SudutKecil)
				ikonSlot(row, s)
				if s.id == semaiPilih then
					mk("Frame", { Size = UDim2.new(0, 3, 1, -8), Position = UDim2.new(0, 4, 0, 4), BackgroundColor3 = warna(UIStyle.Aksen), BorderSizePixel = 0, ZIndex = 3 }, row)
				end
				mk("TextLabel", { Size = UDim2.new(0.46, -46, 1, -8), Position = UDim2.new(0, 44, 0, 4), BackgroundTransparency = 1, Text = UIStyle.potong(info and info.nama or s.id), TextSize = UIStyle.UkuranIsi, Font = FON, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, row)
				mk("TextLabel", { Size = UDim2.new(0.2, -8, 1, -8), Position = UDim2.new(0.46, 44, 0, 4), BackgroundTransparency = 1, Text = "x" .. tostring(s.count), TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Aksen), TextXAlignment = Enum.TextXAlignment.Left }, row)
				mk("TextLabel", { Size = UDim2.new(0.3, -10, 1, -8), Position = UDim2.new(0.7, 6, 0, 4), BackgroundTransparency = 1, Text = tostring(per) .. " pukulan/item", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Right }, row)
				row.Activated:Connect(function()
					semaiPilih = s.id
					refreshSemai()
				end)
			end
		end
		if order == 0 then
			mk("TextLabel", { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 1, Text = "Tidak ada hasil panen di tas. Panen tanaman siap dengan tombol Punch dulu.", TextWrapped = true, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), LayoutOrder = 1 }, semaiScroll)
		end
		if semaiPilih and semaiDimiliki() < 1 then
			semaiPilih = nil
		end
		perbaruiSemaiPreview()
		return
	end
	local info = CropData.byId[b.crop]
	local nama = info and info.nama or tostring(b.crop)
	local kepala = mk("Frame", { Size = UDim2.new(1, -8, 0, 40), BackgroundColor3 = warna(UIStyle.PermukaanAktif), LayoutOrder = 1 }, semaiScroll)
	round(kepala, UIStyle.SudutKecil)
	mk("TextLabel", { Size = UDim2.new(0.62, -12, 1, -8), Position = UDim2.new(0, 8, 0, 4), BackgroundTransparency = 1, Text = "Isi mesin: " .. tostring(b.jumlah) .. " x " .. UIStyle.potong(nama, 14), TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, kepala)
	mk("TextLabel", { Size = UDim2.new(0.38, -12, 1, -8), Position = UDim2.new(0.62, 8, 0, 4), BackgroundTransparency = 1, Text = "Total " .. tostring(b.pukulan) .. " pukulan", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Right }, kepala)
	if b.tahap == "kabel" then
		mk("TextLabel", { Size = UDim2.new(1, -8, 0, 34), BackgroundTransparency = 1, Text = "Mesin menunggu kabel. Jodohkan semua kabel warnanya untuk mengaktifkan mesin.", TextWrapped = true, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Kuning), LayoutOrder = 2 }, semaiScroll)
		local btnKabel = mk("TextButton", { Size = UDim2.new(1, -8, 0, 42), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Sambungkan Kabel", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1), LayoutOrder = 3 }, semaiScroll)
		round(btnKabel)
		btnKabel.Activated:Connect(function()
			bukaKabel()
		end)
	elseif b.tahap == "giling" then
		mk("TextLabel", { Size = UDim2.new(1, -8, 0, 34), BackgroundTransparency = 1, Text = "Mesin sedang menggiling " .. tostring(b.jumlah) .. " x " .. UIStyle.potong(nama, 12) .. ". Tunggu sebentar sampai label SEMAI TUNTAS menyala.", TextWrapped = true, TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), LayoutOrder = 2 }, semaiScroll)
	elseif b.tahap == "tuntas" then
		mk("TextLabel", { Size = UDim2.new(1, -8, 0, 26), BackgroundTransparency = 1, Text = "SEMAI TUNTAS! Hasil gilingan siap diambil:", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Kuning), LayoutOrder = 2 }, semaiScroll)
		local urut = 3
		local function barisHasil(ikonData: any?, teks: string, kanan: string)
			local row = mk("Frame", { Size = UDim2.new(1, -8, 0, 38), BackgroundColor3 = warna(UIStyle.Permukaan), LayoutOrder = urut }, semaiScroll)
			urut += 1
			round(row, UIStyle.SudutKecil)
			if ikonData then
				ikonSlot(row, ikonData)
			else
				local m = mk("Frame", { Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(0, 6, 0, 5), BackgroundColor3 = warna(UIStyle.Aksen) }, row)
				mk("UICorner", { CornerRadius = UDim.new(0.5, 0) }, m)
				mk("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "M", Font = FONTB, TextSize = UIStyle.UkuranKecil, TextColor3 = warna(UIStyle.Latar), ZIndex = 2 }, m)
			end
			mk("TextLabel", { Size = UDim2.new(1, -100, 1, -8), Position = UDim2.new(0, 42, 0, 4), BackgroundTransparency = 1, Text = teks, TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, row)
			mk("TextLabel", { Size = UDim2.new(0, 52, 1, -8), Position = UDim2.new(1, -56, 0, 4), BackgroundTransparency = 1, Text = kanan, TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Aksen), TextXAlignment = Enum.TextXAlignment.Right }, row)
		end
		barisHasil(nil, "+" .. fmt(b.micda or 0) .. " Micda", "Micda")
		if (b.benih or 0) > 0 then
			barisHasil({ kind = "benih", id = b.crop, count = b.benih }, "Benih " .. UIStyle.potong(nama, 18), "x" .. tostring(b.benih))
		end
		if (b.blok or 0) > 0 then
			barisHasil({ kind = "blok", id = CropData.blokIdFor(b.crop), count = b.blok }, CropData.blokNamaFor(b.crop), "x" .. tostring(b.blok))
		end
		local btnKlaim = mk("TextButton", { Size = UDim2.new(1, -8, 0, 46), BackgroundColor3 = warna(UIStyle.Hijau), Text = "Klaim Semua", TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = Color3.new(1, 1, 1), LayoutOrder = 9 }, semaiScroll)
		round(btnKlaim)
		btnKlaim.Activated:Connect(klaimSemai)
	end
end
