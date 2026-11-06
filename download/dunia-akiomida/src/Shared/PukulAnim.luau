local PukulAnim = {}

PukulAnim.Durasi = 0.32
PukulAnim.MomenKena = 0.12
PukulAnim.Ayunan = 1.85
PukulAnim.Ulang = 0.38

export type Fase = { memukul: boolean, kena: boolean, p: number, sudut: number }

function PukulAnim.fase(t0: number, t: number): Fase
	local dt = t - t0
	if dt < 0 or dt > PukulAnim.Durasi then
		return { memukul = false, kena = false, p = 0, sudut = 0 }
	end
	local p = dt / PukulAnim.Durasi
	local sudut
	if p < 0.24 then
		sudut = -0.45 * PukulAnim.Ayunan * math.sin(math.pi * p / 0.24)
	else
		sudut = PukulAnim.Ayunan * math.sin(math.pi * (p - 0.24) / 0.72)
	end
	return {
		memukul = true,
		kena = dt >= PukulAnim.MomenKena,
		p = p,
		sudut = sudut,
	}
end

function PukulAnim.mulaiUlang(t0Lama: number?, t: number): number
	return t
end

function PukulAnim.getar(tier: number): number
	local t = tier or 1
	if t < 1 then
		t = 1
	elseif t > 3 then
		t = 3
	end
	return 0.35 + 0.25 * (t - 1)
end

return PukulAnim
