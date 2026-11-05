local TasLogic = {}

TasLogic.MAX_SLOTS = 50
TasLogic.MAX_STACK = 250

function TasLogic.usedSlots(seeds: { [string]: number }, crops: { [string]: number }): number
	local used = 0
	for _ in pairs(seeds) do
		used += 1
	end
	for _ in pairs(crops) do
		used += 1
	end
	return used
end

function TasLogic.roomFor(seeds: { [string]: number }, crops: { [string]: number }, kind: string, id: string, count: number): number
	if count <= 0 then
		return 0
	end
	local own = 0
	if kind == "seed" then
		own = seeds[id] or 0
	elseif kind == "crop" then
		own = crops[id] or 0
	else
		return 0
	end
	local cap = TasLogic.MAX_STACK - own
	if cap <= 0 then
		return 0
	end
	if own > 0 then
		return math.min(count, cap)
	end
	if TasLogic.usedSlots(seeds, crops) >= TasLogic.MAX_SLOTS then
		return 0
	end
	return math.min(count, cap)
end

function TasLogic.slotView(seeds: { [string]: number }, crops: { [string]: number }): { { kind: string, id: string, n: number } }
	local out = {}
	for id, n in pairs(seeds) do
		table.insert(out, { kind = "seed", id = id, n = n })
	end
	for id, n in pairs(crops) do
		table.insert(out, { kind = "crop", id = id, n = n })
	end
	table.sort(out, function(a, b)
		if a.kind ~= b.kind then
			return a.kind < b.kind
		end
		return a.id < b.id
	end)
	return out
end

function TasLogic.canFitBatch(seeds: { [string]: number }, crops: { [string]: number }, items: { { kind: string, id: string, n: number } }): boolean
	local simS, simC = {}, {}
	for id, n in pairs(seeds) do
		simS[id] = n
	end
	for id, n in pairs(crops) do
		simC[id] = n
	end
	for _, item in ipairs(items) do
		local room = TasLogic.roomFor(simS, simC, item.kind, item.id, item.n)
		if room < item.n then
			return false
		end
		if item.kind == "seed" then
			simS[item.id] = (simS[item.id] or 0) + item.n
		else
			simC[item.id] = (simC[item.id] or 0) + item.n
		end
	end
	return true
end

return TasLogic
