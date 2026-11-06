local DuniaLogic = {}

DuniaLogic.SaveEvery = 60
DuniaLogic.MaxPlots = 500
DuniaLogic.MaxMeja = 6

function DuniaLogic.keyFor(userId: number): string
	return "d_" .. tostring(userId)
end

function DuniaLogic.cleanName(nama: any): string?
	if type(nama) ~= "string" then
		return nil
	end
	local n = nama:gsub("^%s+", ""):gsub("%s+$", "")
	if #n < 1 or #n > 30 then
		return nil
	end
	return n
end

function DuniaLogic.serPlots(planted: any): { [number]: { c: string, r: number } }
	local out = {}
	if type(planted) ~= "table" then
		return out
	end
	for idx, rec in pairs(planted) do
		if
			type(idx) == "number"
			and idx >= 0
			and idx < DuniaLogic.MaxPlots
			and idx == math.floor(idx)
			and type(rec) == "table"
			and type(rec.crop) == "string"
			and #rec.crop <= 40
			and type(rec.readyAt) == "number"
			and rec.readyAt == rec.readyAt
		then
			out[idx] = { c = rec.crop, r = math.floor(rec.readyAt) }
		end
	end
	return out
end

function DuniaLogic.desPlots(arr: any): { [number]: { c: string, r: number } }
	local out = {}
	if type(arr) ~= "table" then
		return out
	end
	for idx, rec in pairs(arr) do
		if
			type(idx) == "number"
			and idx >= 0
			and idx < DuniaLogic.MaxPlots
			and idx == math.floor(idx)
			and type(rec) == "table"
			and type(rec.c) == "string"
			and #rec.c <= 40
			and type(rec.r) == "number"
			and rec.r == rec.r
		then
			out[idx] = { c = rec.c, r = math.floor(rec.r) }
		end
	end
	return out
end

function DuniaLogic.serMeja(slots: any): { { c: string, h: number } }
	local out = {}
	if type(slots) ~= "table" then
		return out
	end
	for i, s in ipairs(slots) do
		if #out >= DuniaLogic.MaxMeja then
			break
		end
		if type(s) == "table" and type(s.crop) == "string" and #s.crop <= 40 and type(s.hitsLeft) == "number" then
			table.insert(out, { c = s.crop, h = math.max(1, math.floor(s.hitsLeft)) })
		end
	end
	return out
end

function DuniaLogic.desMeja(arr: any): { { c: string, h: number } }
	local out = {}
	if type(arr) ~= "table" then
		return out
	end
	for _, s in ipairs(arr) do
		if #out >= DuniaLogic.MaxMeja then
			break
		end
		if type(s) == "table" and type(s.c) == "string" and #s.c <= 40 and type(s.h) == "number" then
			table.insert(out, { c = s.c, h = math.max(1, math.floor(s.h)) })
		end
	end
	return out
end

return DuniaLogic
