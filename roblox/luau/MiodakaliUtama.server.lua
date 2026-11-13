--!strict
-- Miodakali — Sistem Utama (server)
-- Skema real-time ala permainan tani modern: tanaman tumbuh mengikuti
-- waktu nyata (tanpa siram/tidur), tenaga pulih bertahap, XP & level petani,
-- ekspansi petak kebun, ternak ber-timer di kandang, tebang & tambang dengan
-- respawn waktu nyata, kios beli-jual, dan rantai tugas pembuka.
-- Seluruh nama & sistem adalah karya asli Miodakali.

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Konfig = require(ReplicatedStorage:WaitForChild("KonfigurasiMiodakali"))
local KiosEvent = ReplicatedStorage:WaitForChild("KiosEvent")

-- ============================== PEMAIN ==============================

type DataPemain = {
	kirupi: IntValue,
	tenaga: IntValue,
	level: IntValue,
	pengalaman: IntValue,
	kantong: Folder,
	tugasIdx: IntValue,
	statistik: Folder,
	regenTerakhir: number,
}

local dataPemain: {[Player]: DataPemain} = {}

local function statKantong(d: DataPemain, nama: string): IntValue
	local nilai = d.kantong:FindFirstChild(nama)
	if nilai and nilai:IsA("IntValue") then
		return nilai
	end
	local baru = Instance.new("IntValue")
	baru.Name = nama
	baru.Value = 0
	baru.Parent = d.kantong
	return baru
end

local function milik(player: Player, nama: string): number
	local d = dataPemain[player]
	if not d then
		return 0
	end
	return statKantong(d, nama).Value
end

local function beri(player: Player, nama: string, delta: number)
	local d = dataPemain[player]
	if not d then
		return
	end
	local nilai = statKantong(d, nama)
	nilai.Value = math.max(0, nilai.Value + delta)
end

local function levelDariXp(xp: number): number
	local level = 1
	local sisa = math.max(0, math.floor(xp))
	while level <= #Konfig.XPButuh and sisa >= Konfig.XPButuh[level] do
		sisa -= Konfig.XPButuh[level]
		level += 1
	end
	return level
end

local function levelPemain(player: Player): number
	local d = dataPemain[player]
	return d and d.level.Value or 1
end

local function energiMaks(player: Player): number
	return Konfig.EnergiMaksDasar + (levelPemain(player) - 1) * Konfig.EnergiPerLevel
end

local function pakaiTenaga(player: Player, biaya: number): boolean
	local d = dataPemain[player]
	if not d then
		return false
	end
	if d.tenaga.Value < biaya then
		return false
	end
	d.tenaga.Value -= biaya
	return true
end

local function terapkanXp(player: Player, jumlah: number)
	local d = dataPemain[player]
	if not d then
		return
	end
	d.pengalaman.Value += math.max(0, math.floor(jumlah))
	local baru = levelDariXp(d.pengalaman.Value)
	if baru > d.level.Value then
		d.level.Value = baru
		d.tenaga.Value = math.min(energiMaks(player), d.tenaga.Value + 20)
	end
end

-- ============================== TUGAS ==============================

local function syaratTugas(player: Player, id: string): boolean
	local d = dataPemain[player]
	if not d then
		return false
	end
	local fungsi: {[string]: () -> boolean} = {
		tanam = function()
			return statKantong(d, "StatTanam").Value >= 1
		end,
		panen = function()
			return statKantong(d, "StatPanen").Value >= 1
		end,
		jual = function()
			return statKantong(d, "StatJual").Value >= 1
		end,
		beli = function()
			return statKantong(d, "StatBeliBenih").Value >= 3
		end,
		tebas = function()
			return statKantong(d, "StatTebas").Value >= 1
		end,
		tambang = function()
			return statKantong(d, "StatTambang").Value >= 1
		end,
		ternak = function()
			return statKantong(d, "StatPakanu").Value >= 1
		end,
		petak = function()
			return statKantong(d, "StatPetak").Value >= 1
		end,
		masak = function()
			return true -- dapur menyusul di kerangka berikutnya
		end,
		pancing = function()
			return statKantong(d, "StatPancing").Value >= 1
		end,
		lv3 = function()
			return levelPemain(player) >= 3
		end,
	}
	local cek = fungsi[id]
	return cek and cek() or true
end

local function cekTugas(player: Player)
	local d = dataPemain[player]
	if not d then
		return
	end
	while d.tugasIdx.Value <= #Konfig.Tugas do
		local t = Konfig.Tugas[d.tugasIdx.Value]
		if not syaratTugas(player, t.id) then
			break
		end
		d.tugasIdx.Value += 1
		beri(player, "Kirupi", t.uang)
		terapkanXp(player, t.xp)
	end
end

Players.PlayerAdded:Connect(function(player)
	local leader = Instance.new("Folder")
	leader.Name = "leaderstats"
	leader.Parent = player

	local kirupi = Instance.new("IntValue")
	kirupi.Name = "Kirupi"
	kirupi.Value = Konfig.UangAwal
	kirupi.Parent = leader

	local level = Instance.new("IntValue")
	level.Name = "LevelPetani"
	level.Value = 1
	level.Parent = leader

	local kantong = Instance.new("Folder")
	kantong.Name = "Kantong"
	kantong.Parent = player

	local tenaga = Instance.new("IntValue")
	tenaga.Name = "Tenaga"
	tenaga.Value = Konfig.EnergiMaksDasar
	tenaga.Parent = player

	local pengalaman = Instance.new("IntValue")
	pengalaman.Name = "Pengalaman"
	pengalaman.Parent = player

	local tugasIdx = Instance.new("IntValue")
	tugasIdx.Name = "TugasKe"
	tugasIdx.Value = 0
	tugasIdx.Parent = player

	local statistik = Instance.new("Folder")
	statistik.Name = "Statistik"
	statistik.Parent = player
	for _, k in { "StatTanam", "StatPanen", "StatJual", "StatBeliBenih", "StatTebas", "StatTambang", "StatPakanu", "StatPetak", "StatPancing" } do
		local v = Instance.new("IntValue")
		v.Name = k
		v.Parent = statistik
	end

	local d: DataPemain = {
		kirupi = kirupi,
		tenaga = tenaga,
		level = level,
		pengalaman = pengalaman,
		kantong = kantong,
		tugasIdx = tugasIdx,
		statistik = statistik,
		regenTerakhir = os.clock(),
	}
	dataPemain[player] = d

	-- benih awal ala permainan tani modern: 3 petak & 3 benih
	beri(player, "BenihLumira", 3)

	kirupi.Changed:Connect(function()
		cekTugas(player)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	dataPemain[player] = nil
end)

-- Pemulihan tenaga waktu-nyata
task.spawn(function()
	while true do
		task.wait(1)
		for player, d in dataPemain do
			local maks = Konfig.EnergiMaksDasar + (d.level.Value - 1) * Konfig.EnergiPerLevel
			if d.tenaga.Value < maks then
				local lewat = os.clock() - d.regenTerakhir
				if lewat >= Konfig.RegenTenagaDetik then
					local pulih = math.floor(lewat / Konfig.RegenTenagaDetik)
					d.tenaga.Value = math.min(maks, d.tenaga.Value + pulih)
					d.regenTerakhir += pulih * Konfig.RegenTenagaDetik
				end
			else
				d.regenTerakhir = os.clock()
			end
		end
	end
end)

-- ============================== LADANG ==============================

type Petak = {
	part: Part,
	prompt: ProximityPrompt,
	buka: boolean,
	tanaman: string?, -- nama hasil
	tanamAt: number?,
	matang: boolean,
}

local petakList: {Petak} = {}

local function defTanaman(nama: string): any
	for _, t in Konfig.Tanaman :: {any} do
		if t.nama == nama then
			return t
		end
	end
	return nil
end

local function petakDibeli(): number
	local n = 0
	for _, p in petakList do
		if p.buka then
			n += 1
		end
	end
	return math.max(0, n - Konfig.PetakAwal)
end

local function segarkanPromptPetak(p: Petak)
	if not p.buka then
		local biaya = Konfig.BiayaPetak(petakDibeli())
		p.prompt.ActionText = ("Beli Petak (%d Kirupi + %d Balanu + %d Batuku)"):format(biaya.uang, biaya.balanu, biaya.batuku)
		p.prompt.ObjectText = "Ekspansi Kebun"
		return
	end
	if p.tanaman then
		if p.matang then
			p.prompt.ActionText = "Panen " .. p.tanaman
		else
			local def = defTanaman(p.tanaman)
			local sisa = def and math.ceil(def.detikTumbuh - (os.clock() - (p.tanamAt or 0))) or 0
			p.prompt.ActionText = ("%s matang dalam %d dtk"):format(p.tanaman, math.max(0, sisa))
		end
		p.prompt.ObjectText = "Petak Ladang"
	elseif p.part.Color == Color3.fromRGB(163, 113, 75) then
		p.prompt.ActionText = "Tanam Benih"
		p.prompt.ObjectText = "Petak Ladang"
	else
		p.prompt.ActionText = "Gemburkan Tanah"
		p.prompt.ObjectText = "Petak Ladang"
	end
end

local function perbaruiWarna(p: Petak)
	if not p.buka then
		p.part.Color = Color3.fromRGB(96, 138, 62)
		p.part.Material = Enum.Material.Grass
		return
	end
	p.part.Material = Enum.Material.Ground
	if p.tanaman then
		if p.matang then
			p.part.Color = Color3.fromRGB(214, 176, 66)
		else
			p.part.Color = Color3.fromRGB(150, 102, 66)
		end
	elseif p.part.Color == Color3.fromRGB(163, 113, 75) or p.part.Color == Color3.fromRGB(214, 176, 66) then
		p.part.Color = Color3.fromRGB(163, 113, 75)
	else
		p.part.Color = Color3.fromRGB(106, 158, 68)
	end
end

local ladangFolder = Workspace:WaitForChild("Ladang")
local urutan = 0
for _, anak in ladangFolder:GetChildren() do
	if anak:IsA("BasePart") then
		local prompt = anak:FindFirstChildWhichIsA("ProximityPrompt")
		if prompt then
			urutan += 1
			local p: Petak = {
				part = anak,
				prompt = prompt,
				buka = urutan <= Konfig.PetakAwal,
				tanaman = nil,
				tanamAt = nil,
				matang = false,
			}
			table.insert(petakList, p)
			perbaruiWarna(p)
			segarkanPromptPetak(p)
			prompt.Triggered:Connect(function(player)
				if not p.buka then
					local biaya = Konfig.BiayaPetak(petakDibeli())
					if
						milik(player, "Kirupi") >= biaya.uang
						and milik(player, "Balanu") >= biaya.balanu
						and milik(player, "Batuku") >= biaya.batuku
					then
						beri(player, "Kirupi", -biaya.uang)
						beri(player, "Balanu", -biaya.balanu)
						beri(player, "Batuku", -biaya.batuku)
						beri(player, "StatPetak", 1)
						p.buka = true
						perbaruiWarna(p)
						segarkanPromptPetak(p)
						cekTugas(player)
					end
					return
				end
				if p.tanaman then
					if p.matang then
						local def = defTanaman(p.tanaman)
						if def and pakaiTenaga(player, Konfig.BiayaTenaga.panen) then
							beri(player, p.tanaman or "", 1)
							beri(player, "StatPanen", 1)
							terapkanXp(player, def.xpPanen)
							p.tanaman = nil
							p.tanamAt = nil
							p.matang = false
							cekTugas(player)
						end
					end
					perbaruiWarna(p)
					segarkanPromptPetak(p)
					return
				end
				if p.part.Color == Color3.fromRGB(163, 113, 75) then
					-- tanah sudah gembur: tanam benih level tertinggi yang dimiliki
					local pilihan = nil
					for _, t in Konfig.Tanaman :: {any} do
						if milik(player, t.benih) > 0 and levelPemain(player) >= t.levelButuh then
							if not pilihan or t.hargaBenih > pilihan.hargaBenih then
								pilihan = t
							end
						end
					end
					if pilihan and pakaiTenaga(player, Konfig.BiayaTenaga.tanam) then
						beri(player, pilihan.benih, -1)
						p.tanaman = pilihan.nama
						p.tanamAt = os.clock()
						p.matang = false
						beri(player, "StatTanam", 1)
						terapkanXp(player, Konfig.XpAksi.tanam)
						cekTugas(player)
					end
				else
					if pakaiTenaga(player, Konfig.BiayaTenaga.gembur) then
						p.part.Color = Color3.fromRGB(163, 113, 75)
						terapkanXp(player, Konfig.XpAksi.gembur)
					end
				end
				perbaruiWarna(p)
				segarkanPromptPetak(p)
			end)
		end
	end
end

-- Pertumbuhan waktu-nyata: periksa tiap detik
task.spawn(function()
	while true do
		task.wait(1)
		for _, p in petakList do
			if p.tanaman and not p.matang and p.tanamAt then
				local def = defTanaman(p.tanaman)
				if def and os.clock() - p.tanamAt >= def.detikTumbuh then
					p.matang = true
					perbaruiWarna(p)
				end
			end
			segarkanPromptPetak(p)
		end
	end
end)

-- ============================== KANDANG TERNAK ==============================

type SlotTernak = {
	model: Model,
	prompt: ProximityPrompt,
	jenis: string, -- "Ayumi" | "Sapiyu"
	jenisAktif: string?, -- nil = kosong (bisa dibeli)
	siapAt: number?,
	bagian: {BasePart},
}

local slotList: {SlotTernak} = {}

local ternakFolder = Workspace:FindFirstChild("HewanTernak")
if ternakFolder then
	for _, model in ternakFolder:GetChildren() do
		if model:IsA("Model") then
			local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
			if prompt then
				local jenis = if string.find(string.lower(model.Name), "ayumi") then "Ayumi" else "Sapiyu"
				local bagian: {BasePart} = {}
				for _, b in model:GetDescendants() do
					if b:IsA("BasePart") then
						table.insert(bagian, b)
					end
				end
				local s: SlotTernak = {
					model = model,
					prompt = prompt,
					jenis = jenis,
					jenisAktif = nil,
					siapAt = nil,
					bagian = bagian,
				}
				table.insert(slotList, s)
			end
		end
	end
end

local function segarkanPromptTernak(s: SlotTernak)
	local def = Konfig.Ternak[s.jenis] :: any
	if not s.jenisAktif then
		s.prompt.ActionText = ("Beli %s (%d Kirupi)"):format(s.jenis, def.harga)
		s.prompt.ObjectText = "Kandang — slot kosong"
	elseif s.siapAt and os.clock() >= s.siapAt then
		s.prompt.ActionText = "Ambil " .. def.hasil
		s.prompt.ObjectText = s.jenis
	elseif s.siapAt then
		s.prompt.ActionText = ("%s — siap %d dtk lagi"):format(s.jenis, math.ceil(s.siapAt - os.clock()))
		s.prompt.ObjectText = s.jenis
	else
		s.prompt.ActionText = "Beri Pakanu (" .. s.jenis .. ")"
		s.prompt.ObjectText = s.jenis
	end
end

local function tampakTernak(s: SlotTernak, ada: boolean)
	for _, b in s.bagian do
		b.Transparency = if ada then 0 else 1
		b.CanCollide = ada
	end
end

for _, s in slotList do
	tampakTernak(s, false)
	segarkanPromptTernak(s)
	s.prompt.Triggered:Connect(function(player)
		local def = Konfig.Ternak[s.jenis] :: any
		if not s.jenisAktif then
			if levelPemain(player) < def.levelButuh then
				s.prompt.ActionText = ("%s terbuka di Level %d"):format(s.jenis, def.levelButuh)
				task.wait(1.2)
				segarkanPromptTernak(s)
				return
			end
			if milik(player, "Kirupi") >= def.harga then
				beri(player, "Kirupi", -def.harga)
				s.jenisAktif = s.jenis
				s.siapAt = nil
				tampakTernak(s, true)
				segarkanPromptTernak(s)
			end
			return
		end
		if s.siapAt and os.clock() >= s.siapAt then
			if pakaiTenaga(player, Konfig.BiayaTenaga.ambil) then
				beri(player, def.hasil, 1)
				terapkanXp(player, Konfig.XpAksi.ambil)
				s.siapAt = nil
				cekTugas(player)
			end
			segarkanPromptTernak(s)
			return
		end
		if not s.siapAt then
			if milik(player, "Pakanu") > 0 and pakaiTenaga(player, Konfig.BiayaTenaga.pakanu) then
				beri(player, "Pakanu", -1)
				s.siapAt = os.clock() + def.detikProduksi
				beri(player, "StatPakanu", 1)
				terapkanXp(player, Konfig.XpAksi.pakanu)
				cekTugas(player)
			else
				s.prompt.ActionText = "Butuh Pakanu — beli di Kios!"
				task.wait(1.2)
			end
			segarkanPromptTernak(s)
		end
	end)
end

-- Timer ternak waktu-nyata
task.spawn(function()
	while true do
		task.wait(1)
		for _, s in slotList do
			segarkanPromptTernak(s)
		end
	end
end)

-- ============================== POHON & BATU ==============================

type Sumber = {
	prompt: ProximityPrompt,
	bagian: {BasePart},
	hidup: boolean,
	nyawa: number,
	respawnAt: number,
	jenis: string, -- "kayanu" | "batuku"
}

local sumberList: {Sumber} = {}

for namaFolder, jenis in { Kayanu = "kayanu", Batu = "batuku" } :: {any} do
	local f = Workspace:FindFirstChild(namaFolder)
	if f then
		for _, model in f:GetChildren() do
			if model:IsA("Model") then
				local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
				if prompt then
					local s: Sumber = {
						prompt = prompt,
						bagian = {},
						hidup = true,
						nyawa = 3,
						respawnAt = 0,
						jenis = jenis,
					}
					for _, b in model:GetDescendants() do
						if b:IsA("BasePart") then
							table.insert(s.bagian, b)
						end
					end
					table.insert(sumberList, s)
					prompt.ObjectText = if jenis == "kayanu" then "Kayanu" else "Batuku"
					prompt.ActionText = if jenis == "kayanu" then "Tebang" else "Pecahkan"
				end
			end
		end
	end
end

for _, s in sumberList do
	s.prompt.Triggered:Connect(function(player)
		if not s.hidup then
			return
		end
		local biaya = if s.jenis == "kayanu" then Konfig.BiayaTenaga.tebang else Konfig.BiayaTenaga.pecah
		if not pakaiTenaga(player, biaya) then
			return
		end
		terapkanXp(player, if s.jenis == "kayanu" then Konfig.XpAksi.tebang else Konfig.XpAksi.pecah)
		s.nyawa -= 1
		if s.nyawa <= 0 then
			s.hidup = false
			s.respawnAt = os.clock() + Konfig.RespawnDetik
			for _, b in s.bagian do
				b.Transparency = 1
				b.CanCollide = false
			end
			beri(player, if s.jenis == "kayanu" then "Balanu" else "Batuku", 2)
			beri(player, if s.jenis == "kayanu" then "StatTebas" else "StatTambang", 1)
			s.prompt.Enabled = false
			cekTugas(player)
		else
			s.prompt.ActionText = string.format(
				"%s (%d lagi)",
				if s.jenis == "kayanu" then "Tebang" else "Pecahkan",
				s.nyawa
			)
		end
	end)
end

-- Respawn pohon & batu waktu-nyata
task.spawn(function()
	while true do
		task.wait(1)
		for _, s in sumberList do
			if not s.hidup and s.respawnAt > 0 and os.clock() >= s.respawnAt then
				s.hidup = true
				s.nyawa = 3
				s.respawnAt = 0
				for _, b in s.bagian do
					b.Transparency = 0
					b.CanCollide = true
				end
				s.prompt.Enabled = true
				s.prompt.ActionText = if s.jenis == "kayanu" then "Tebang" else "Pecahkan"
			end
		end
	end
end)

-- ============================== KIOS DESA ==============================

local pintuKios = Workspace:FindFirstChild("PintuKios", true)
if pintuKios then
	local prompt = pintuKios:FindFirstChildWhichIsA("ProximityPrompt")
	if prompt then
		prompt.Triggered:Connect(function(player)
			KiosEvent:FireClient(player)
		end)
	end
end

KiosEvent.OnServerEvent:Connect(function(player, aksi: string, nama: string, jumlah: number)
	if typeof(aksi) ~= "string" or typeof(nama) ~= "string" or typeof(jumlah) ~= "number" then
		return
	end
	jumlah = math.floor(math.max(1, jumlah))
	local d = dataPemain[player]
	if not d then
		return
	end

	if aksi == "beli" then
		local harga = nil
		local levelButuh = 1
		if nama == "Pakanu" then
			harga = Konfig.HargaPakanu
		elseif nama == "Panyukan" then
			harga = Konfig.HargaPanyukan
			levelButuh = Konfig.LevelPanyukan
		else
			for _, t in Konfig.Tanaman :: {any} do
				if t.benih == nama then
					harga = t.hargaBenih
					levelButuh = t.levelButuh
					break
				end
			end
		end
		if harga and levelPemain(player) >= levelButuh then
			local total = harga * jumlah
			if milik(player, "Kirupi") >= total then
				beri(player, "Kirupi", -total)
				beri(player, nama, jumlah)
				if string.sub(nama, 1, 5) == "Benih" then
					beri(player, "StatBeliBenih", jumlah)
					cekTugas(player)
				end
			end
		end
	elseif aksi == "jual" then
		local harga = nil
		for _, t in Konfig.Tanaman :: {any} do
			if t.nama == nama then
				harga = t.hargaJual
				break
			end
		end
		if not harga then
			harga = Konfig.HargaJualLain[nama]
		end
		if harga and milik(player, nama) >= jumlah then
			beri(player, nama, -jumlah)
			beri(player, "Kirupi", harga * jumlah)
			beri(player, "StatJual", jumlah)
			cekTugas(player)
		end
	end
end)

-- ============================== PENCAHAYAAN HARIAN SANTAI ==============================

-- Pencahayaan mengikuti jam dunia nyata (skema real-time, tanpa tidur)
task.spawn(function()
	while true do
		local jam = (os.time() % 86400) / 3600 -- 0..24 UTC
		Lighting.ClockTime = (jam + 7) % 24 -- geser ke waktu Indonesia barat
		task.wait(30)
	end
end)
