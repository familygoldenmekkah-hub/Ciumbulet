local UangSingkat = {}

local SATUAN = {
	{ ambang = 1000000000000, nama = "T" },
	{ ambang = 1000000000, nama = "M" },
	{ ambang = 1000000, nama = "Jt" },
	{ ambang = 1000, nama = "Rb" },
}

local function bersih(nilai: any): number
	local n = tonumber(nilai)
	if not n or n ~= n or n == math.huge or n == -math.huge or n < 0 then
		return 0
	end
	return math.floor(n)
end

local function bertitik(v: number): string
	local parts = {}
	local x = math.floor(v)
	repeat
		table.insert(parts, 1, string.format("%03d", x % 1000))
		x = math.floor(x / 1000)
	until x == 0
	parts[1] = tostring(tonumber(parts[1]))
	return table.concat(parts, ".")
end

function UangSingkat.penuh(nilai: any): string
	return bertitik(bersih(nilai))
end

function UangSingkat.singkat(nilai: any): string
	local n = bersih(nilai)
	for _, s in ipairs(SATUAN) do
		if n >= s.ambang then
			local utuh = (n - n % s.ambang) / s.ambang
			local sisa = n % s.ambang
			local langkah = s.ambang / 100
			local dua = math.floor((sisa - sisa % langkah) / langkah)
			local des = ""
			if dua > 0 then
				local teks = string.format("%02d", dua)
				while #teks > 1 and string.sub(teks, -1) == "0" do
					teks = string.sub(teks, 1, -2)
				end
				des = "," .. teks
			end
			return bertitik(utuh) .. des .. " " .. s.nama
		end
	end
	return bertitik(n)
end

return UangSingkat
