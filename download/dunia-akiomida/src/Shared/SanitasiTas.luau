local SanitasiTas = {}

local MAX_SLOT = 50
local MAX_STACK = 250
local KIND_OK = { benih = true, hasil = true }

function SanitasiTas.bersih(raw: any, byId: any): ({ any }, number)
	local out = {}
	local dibuang = 0
	if type(byId) ~= "table" then
		if type(raw) == "table" then
			for _ in ipairs(raw) do
				dibuang += 1
			end
		end
		return out, dibuang
	end
	if type(raw) ~= "table" then
		return out, dibuang
	end
	for _, s in ipairs(raw) do
		local ok = false
		if #out < MAX_SLOT and type(s) == "table" and KIND_OK[s.kind] and type(s.id) == "string" and byId[s.id] then
			local n = tonumber(s.count)
			if n and n == n and n >= 1 then
				table.insert(out, { kind = s.kind, id = s.id, count = math.min(MAX_STACK, math.floor(n)) })
				ok = true
			end
		end
		if not ok then
			dibuang += 1
		end
	end
	return out, dibuang
end

function SanitasiTas.slotValid(s: any, byId: any): boolean
	if type(byId) ~= "table" then
		return false
	end
	if type(s) ~= "table" then
		return false
	end
	if s.kind ~= "benih" and s.kind ~= "hasil" then
		return false
	end
	if type(s.id) ~= "string" or not byId[s.id] then
		return false
	end
	local n = tonumber(s.count)
	return n ~= nil and n == n and n >= 1 and n <= MAX_STACK and n == math.floor(n)
end

return SanitasiTas
