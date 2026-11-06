local DuniaLogic = {}

DuniaLogic.Ttl = 90
DuniaLogic.Heartbeat = 30
DuniaLogic.SaveEvery = 60
DuniaLogic.MaxPlots = 500
DuniaLogic.MaxMeja = 6

function DuniaLogic.keyFor(userId: number): string
	return "d_" .. tostring(userId)
end

function DuniaLogic.modeOf(joinData: any): string
	if
		type(joinData) == "table"
		and joinData.md == "dunia"
		and type(joinData.pemilik) == "number"
		and joinData.pemilik > 0
	then
		return "dunia"
	end
	return "hub"
end

function DuniaLogic.ownerOf(joinData: any): number
	if DuniaLogic.modeOf(joinData) == "dunia" then
		return joinData.pemilik
	end
	return 0
end

function DuniaLogic.roleFor(userId: number, ownerId: number): string
	if ownerId > 0 and userId == ownerId then
		return "pemilik"
	end
	return "tamu"
end

function DuniaLogic.fresh(rec: any, now: number): boolean
	if type(rec) ~= "table" or type(rec.t) ~= "number" then
		return false
	end
	local age = now - rec.t
	return age < DuniaLogic.Ttl and age >= -5
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
