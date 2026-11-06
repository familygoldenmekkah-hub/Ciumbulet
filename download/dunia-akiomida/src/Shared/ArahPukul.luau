local ArahPukul = {}

ArahPukul.Jangkauan = 14
ArahPukul.Radius = 2.6
ArahPukul.JarakMin = 1.2

local function sub(a, b)
	return { x = a.x - b.x, y = a.y - b.y, z = a.z - b.z }
end

local function dot(a, b)
	return a.x * b.x + a.y * b.y + a.z * b.z
end

local function mag(a)
	return math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
end

function ArahPukul.pilih(asal, arah, daftar, jangkauan: number?, radius: number?, jarakMin: number?)
	local j = type(jangkauan) == "number" and jangkauan or ArahPukul.Jangkauan
	local r = type(radius) == "number" and radius or ArahPukul.Radius
	local m = type(jarakMin) == "number" and jarakMin or ArahPukul.JarakMin
	local pan = mag(arah)
	if pan <= 0 then
		return nil
	end
	local nx, ny, nz = arah.x / pan, arah.y / pan, arah.z / pan
	local terbaik = nil
	local terdekat = math.huge
	for _, k in ipairs(daftar) do
		if type(k) == "table" and type(k.pos) == "table" and k.idx ~= nil then
			local rel = sub(k.pos, asal)
			local f = rel.x * nx + rel.y * ny + rel.z * nz
			if f >= m and f <= j then
				local sx = rel.x - nx * f
				local sy = rel.y - ny * f
				local sz = rel.z - nz * f
				local sisi = math.sqrt(sx * sx + sy * sy + sz * sz)
				local batas = (type(k.radius) == "number" and k.radius or r)
				if sisi <= batas and f < terdekat then
					terdekat = f
					terbaik = {
						idx = k.idx,
						jarak = f,
						titik = { x = asal.x + nx * f, y = asal.y + ny * f, z = asal.z + nz * f },
					}
				end
			end
		end
	end
	return terbaik
end

function ArahPukul.titikPukul(asal, arah, jarak: number)
	local pan = mag(arah)
	if pan <= 0 then
		return { x = asal.x, y = asal.y, z = asal.z }
	end
	local f = jarak
	if f < 0 then
		f = 0
	end
	return { x = asal.x + (arah.x / pan) * f, y = asal.y + (arah.y / pan) * f, z = asal.z + (arah.z / pan) * f }
end

function ArahPukul.diDepan(asal, arah, pos, kosMin: number?): boolean
	local rel = sub(pos, asal)
	local pan = mag(arah)
	if pan <= 0 then
		return false
	end
	local panRel = mag(rel)
	if panRel <= 0 then
		return false
	end
	local kos = dot(rel, arah) / (pan * panRel)
	return kos >= (type(kosMin) == "number" and kosMin or 0.4)
end

return ArahPukul
