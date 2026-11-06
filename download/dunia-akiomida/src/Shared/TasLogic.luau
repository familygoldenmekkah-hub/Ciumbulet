export type Slot = { kind: string, id: string, count: number }

local TasLogic = {}

TasLogic.MaxSlots = 50
TasLogic.MaxStack = 250

function TasLogic.usedSlots(tas: { any }): number
	return #tas
end

function TasLogic.countOf(tas: { any }, kind: string, id: string): number
	local total = 0
	for _, s in ipairs(tas) do
		if s.kind == kind and s.id == id then
			total += s.count
		end
	end
	return total
end

function TasLogic.roomFor(tas: { any }, kind: string, id: string, want: number): number
	local room = 0
	for _, s in ipairs(tas) do
		if s.kind == kind and s.id == id then
			room += TasLogic.MaxStack - s.count
		end
	end
	local used = #tas
	if used < TasLogic.MaxSlots then
		room += (TasLogic.MaxSlots - used) * TasLogic.MaxStack
	end
	if room > want then
		return want
	end
	return room
end

function TasLogic.add(tas: { any }, kind: string, id: string, count: number): number
	local left = count
	for _, s in ipairs(tas) do
		if left <= 0 then
			break
		end
		if s.kind == kind and s.id == id and s.count < TasLogic.MaxStack then
			local put = math.min(TasLogic.MaxStack - s.count, left)
			s.count += put
			left -= put
		end
	end
	while left > 0 do
		if #tas >= TasLogic.MaxSlots then
			break
		end
		local put = math.min(TasLogic.MaxStack, left)
		table.insert(tas, { kind = kind, id = id, count = put })
		left -= put
	end
	return count - left
end

function TasLogic.remove(tas: { any }, kind: string, id: string, count: number): number
	local left = count
	for i = #tas, 1, -1 do
		if left <= 0 then
			break
		end
		local s = tas[i]
		if s.kind == kind and s.id == id then
			local take = math.min(s.count, left)
			s.count -= take
			left -= take
			if s.count <= 0 then
				table.remove(tas, i)
			end
		end
	end
	return count - left
end

function TasLogic.canFitBatch(tas: { any }, items: { any }): boolean
	local clone = {}
	for i, s in ipairs(tas) do
		clone[i] = { kind = s.kind, id = s.id, count = s.count }
	end
	for _, it in ipairs(items) do
		local put = TasLogic.add(clone, it.kind, it.id, it.count)
		if put < it.count then
			return false
		end
	end
	return true
end

return TasLogic
