local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropData = require(ReplicatedStorage.Shared.CropData)
local DropBentuk = require(ReplicatedStorage.Shared.DropBentuk)

local DropModels = {}

local function warna3(t: any): Color3
	if type(t) == "table" then
		return Color3.fromRGB(t[1] or 200, t[2] or 200, t[3] or 200)
	end
	return Color3.fromRGB(200, 200, 200)
end

local function bagian(model: Model, ukuran: Vector3, cf: CFrame, warna: Color3, bentuk: Enum.PartType?): Part
	local p = Instance.new("Part")
	p.Size = ukuran
	p.CFrame = cf
	p.Color = warna
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Massless = true
	if bentuk then
		p.Shape = bentuk
	end
	p.Parent = model
	return p
end

local function bundar(model: Model, ukuran: Vector3, cf: CFrame, warna: Color3): Part
	return bagian(model, ukuran, cf, warna, Enum.PartType.Ball)
end

local function batang(model: Model, panjang: number, dia: number, cf: CFrame, warna: Color3): Part
	return bagian(model, Vector3.new(panjang, dia, dia), cf * CFrame.Angles(0, 0, math.rad(90)), warna, Enum.PartType.Cylinder)
end

local PEMBENTUK: { [string]: (Model, Vector3, number, Color3, Color3) -> Part } = {}

PEMBENTUK.akar = function(model, pos, s, buah, aksen)
	local root = bundar(model, Vector3.new(0.9 * s, 0.9 * s, 0.9 * s), CFrame.new(pos + Vector3.new(0, 1.1 * s, 0)), buah)
	bundar(model, Vector3.new(0.6 * s, 0.6 * s, 0.6 * s), CFrame.new(pos + Vector3.new(0, 0.45 * s, 0)), buah)
	bundar(model, Vector3.new(0.36 * s, 0.36 * s, 0.36 * s), CFrame.new(pos + Vector3.new(0, 0.05 * s, 0)), buah)
	batang(model, 0.4 * s, 0.16 * s, CFrame.new(pos + Vector3.new(0, 1.7 * s, 0)), aksen)
	return root
end

PEMBENTUK.kacang = function(model, pos, s, buah, aksen)
	local root = bundar(model, Vector3.new(0.8 * s, 0.8 * s, 0.8 * s), CFrame.new(pos + Vector3.new(0, 1.0 * s, 0)), buah)
	local kiri = bagian(model, Vector3.new(0.9 * s, 0.34 * s, 0.5 * s), CFrame.new(pos + Vector3.new(-0.6 * s, 0.4 * s, 0.1 * s)) * CFrame.Angles(0, 0, math.rad(14)), buah)
	local kanan = bagian(model, Vector3.new(0.9 * s, 0.34 * s, 0.5 * s), CFrame.new(pos + Vector3.new(0.6 * s, 0.4 * s, -0.1 * s)) * CFrame.Angles(0, 0, math.rad(-14)), aksen)
	return root, { kiri, kanan }
end

PEMBENTUK.daun = function(model, pos, s, buah, aksen)
	local root = bundar(model, Vector3.new(0.72 * s, 0.72 * s, 0.72 * s), CFrame.new(pos + Vector3.new(0, 1.0 * s, 0)), buah)
	local atas = bagian(model, Vector3.new(1.15 * s, 0.12 * s, 1.15 * s), CFrame.new(pos + Vector3.new(0, 1.5 * s, 0)) * CFrame.Angles(0, math.rad(24), 0), aksen)
	local bawah = bagian(model, Vector3.new(1.0 * s, 0.12 * s, 1.0 * s), CFrame.new(pos + Vector3.new(0, 0.55 * s, 0)) * CFrame.Angles(0, math.rad(-18), 0), aksen)
	return root, { atas, bawah }
end

PEMBENTUK.bulat = function(model, pos, s, buah, aksen)
	local root = bundar(model, Vector3.new(1.05 * s, 1.05 * s, 1.05 * s), CFrame.new(pos + Vector3.new(0, 1.05 * s, 0)), buah)
	local tangkai = batang(model, 0.42 * s, 0.16 * s, CFrame.new(pos + Vector3.new(0, 1.75 * s, 0)), aksen)
	return root, { tangkai }
end

PEMBENTUK.tangkai = function(model, pos, s, buah, aksen)
	local root = bundar(model, Vector3.new(0.5 * s, 0.5 * s, 0.5 * s), CFrame.new(pos + Vector3.new(0, 1.65 * s, 0)), buah)
	local kiri = batang(model, 1.1 * s, 0.14 * s, CFrame.new(pos + Vector3.new(-0.3 * s, 0.75 * s, 0)) * CFrame.Angles(math.rad(8), 0, math.rad(10)), aksen)
	local kanan = batang(model, 1.1 * s, 0.14 * s, CFrame.new(pos + Vector3.new(0.3 * s, 0.75 * s, 0.05 * s)) * CFrame.Angles(math.rad(-8), 0, math.rad(-10)), aksen)
	local butirKiri = bundar(model, Vector3.new(0.38 * s, 0.38 * s, 0.38 * s), CFrame.new(pos + Vector3.new(-0.42 * s, 1.4 * s, 0)), buah)
	local butirKanan = bundar(model, Vector3.new(0.38 * s, 0.38 * s, 0.38 * s), CFrame.new(pos + Vector3.new(0.42 * s, 1.4 * s, 0.05 * s)), buah)
	return root, { kiri, kanan, butirKiri, butirKanan }
end

PEMBENTUK.pohon = function(model, pos, s, buah, aksen)
	local root = bundar(model, Vector3.new(0.95 * s, 0.95 * s, 0.95 * s), CFrame.new(pos + Vector3.new(0, 1.3 * s, 0.18 * s)), buah)
	local daun = bundar(model, Vector3.new(1.1 * s, 1.1 * s, 1.1 * s), CFrame.new(pos + Vector3.new(0, 1.25 * s, -0.4 * s)), aksen)
	local batok = batang(model, 0.5 * s, 0.2 * s, CFrame.new(pos + Vector3.new(0, 0.45 * s, 0)), aksen)
	return root, { daun, batok }
end

PEMBENTUK.semak = function(model, pos, s, buah, aksen)
	local root = bundar(model, Vector3.new(0.7 * s, 0.7 * s, 0.7 * s), CFrame.new(pos + Vector3.new(0, 1.05 * s, 0)), buah)
	local kiri = bundar(model, Vector3.new(0.52 * s, 0.52 * s, 0.52 * s), CFrame.new(pos + Vector3.new(-0.5 * s, 0.8 * s, 0.1 * s)), buah)
	local kanan = bundar(model, Vector3.new(0.5 * s, 0.5 * s, 0.5 * s), CFrame.new(pos + Vector3.new(0.5 * s, 0.85 * s, -0.1 * s)), buah)
	local dasar = bagian(model, Vector3.new(1.0 * s, 0.14 * s, 1.0 * s), CFrame.new(pos + Vector3.new(0, 0.4 * s, 0)), aksen)
	return root, { kiri, kanan, dasar }
end

PEMBENTUK.cendawan = function(model, pos, s, buah, aksen)
	local root = batang(model, 0.42 * s, 1.0 * s, CFrame.new(pos + Vector3.new(0, 1.25 * s, 0)), buah)
	local badan = batang(model, 0.6 * s, 0.36 * s, CFrame.new(pos + Vector3.new(0, 0.6 * s, 0)), aksen)
	return root, { badan }
end

function DropModels.buat(pos: Vector3, cropId: string, tier: number): Model?
	local info = CropData.byId[cropId]
	if not info then
		return nil
	end
	local b = CropData.Bentuk[cropId]
	if not b then
		return nil
	end
	local spes = DropBentuk.spesifikasi(b)
	if not spes then
		return nil
	end
	local buah = warna3(spes.buah)
	local aksen = warna3(spes.aksen)
	local s = (spes.skala) * (1 + 0.14 * (tier or 1))
	local model = Instance.new("Model")
	model.Name = "Hasil_" .. cropId
	local pembentuk = PEMBENTUK[spes.jenis] or PEMBENTUK.bulat
	local root, ekstra = pembentuk(model, pos, s, buah, aksen)
	root.Name = "Hasil"
	root.CanCollide = true
	root.CanTouch = true
	root.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 1, 1)
	for _, e in ipairs(ekstra or {}) do
		local las = Instance.new("WeldConstraint")
		las.Part0 = root
		las.Part1 = e
		las.Parent = root
	end
	model.PrimaryPart = root
	return model
end

return DropModels
