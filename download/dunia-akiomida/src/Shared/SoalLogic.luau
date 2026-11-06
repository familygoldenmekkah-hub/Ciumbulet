local SoalLogic = {}

local function sig(op: string, a: number, b: number): string
	return op .. ":" .. a .. ":" .. b
end

function SoalLogic.buat(rng: Random, nomor: number, used: { [string]: boolean }): { teks: string, jawab: number, op: string, a: number, b: number }
	local op: string
	if nomor <= 20 then
		op = rng:NextNumber() < 0.5 and "tambah" or "kurang"
	elseif nomor <= 35 then
		op = "kali"
	else
		op = "bagi"
	end
	local a, b, jawab = 2, 2, 4
	for _ = 1, 80 do
		if op == "tambah" then
			a = rng:NextInteger(12, 99)
			b = rng:NextInteger(7, 99)
			jawab = a + b
		elseif op == "kurang" then
			a = rng:NextInteger(25, 99)
			b = rng:NextInteger(6, a - 2)
			jawab = a - b
		elseif op == "kali" then
			a = rng:NextInteger(3, 15)
			b = rng:NextInteger(3, 12)
			jawab = a * b
		else
			b = rng:NextInteger(3, 12)
			local hasil = rng:NextInteger(3, 15)
			a = b * hasil
			jawab = hasil
		end
		if not used[sig(op, a, b)] then
			used[sig(op, a, b)] = true
			break
		end
	end
	local tanda = "+"
	if op == "kurang" then
		tanda = "-"
	elseif op == "kali" then
		tanda = "×"
	elseif op == "bagi" then
		tanda = "÷"
	end
	return { teks = tostring(a) .. " " .. tanda .. " " .. tostring(b) .. " = ?", jawab = jawab, op = op, a = a, b = b }
end

return SoalLogic
