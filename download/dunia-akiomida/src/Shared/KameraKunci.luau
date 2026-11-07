local KameraKunci = {}

local JARAK_MIN = 0.5
local JARAK_MAKS = 128

function KameraKunci.batas(): (number, number)
	return JARAK_MIN, JARAK_MAKS
end

function KameraKunci.jepit(jarak: any): number
	if type(jarak) ~= "number" or jarak ~= jarak then
		return JARAK_MIN
	end
	if jarak < JARAK_MIN then
		return JARAK_MIN
	end
	if jarak > JARAK_MAKS then
		return JARAK_MAKS
	end
	return jarak
end

function KameraKunci.kunci(minLama: any, maxLama: any, jarak: any): (number, number, { any })
	local j = KameraKunci.jepit(jarak)
	local simpan = {
		min = KameraKunci.jepit(minLama),
		max = KameraKunci.jepit(maxLama),
	}
	if simpan.max < simpan.min then
		simpan.max = simpan.min
	end
	return j, j, simpan
end

function KameraKunci.buka(tersimpan: any): (number, number)
	if type(tersimpan) == "table" and type(tersimpan.min) == "number" and type(tersimpan.max) == "number" then
		local mn = KameraKunci.jepit(tersimpan.min)
		local mx = KameraKunci.jepit(tersimpan.max)
		if mx < mn then
			mx = mn
		end
		return mn, mx
	end
	return JARAK_MIN, JARAK_MAKS
end

return KameraKunci
