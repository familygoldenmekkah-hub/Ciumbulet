local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TasLogic = require(ReplicatedStorage.Shared.TasLogic)

local TasService = {}
local dataOf: any = nil

function TasService.bind(dataService)
	dataOf = dataService
end

function TasService.tas(player)
	local d = dataOf.get(player)
	return d and d.t or nil
end

function TasService.roomFor(player, kind: string, id: string, want: number): number
	local tas = TasService.tas(player)
	if not tas then
		return 0
	end
	return TasLogic.roomFor(tas, kind, id, want)
end

function TasService.add(player, kind: string, id: string, count: number): number
	local tas = TasService.tas(player)
	if not tas then
		return 0
	end
	local put = TasLogic.add(tas, kind, id, count)
	if put > 0 then
		dataOf.markDirty(player)
		dataOf.push(player)
	end
	return put
end

function TasService.remove(player, kind: string, id: string, count: number): number
	local tas = TasService.tas(player)
	if not tas then
		return 0
	end
	local took = TasLogic.remove(tas, kind, id, count)
	if took > 0 then
		dataOf.markDirty(player)
		dataOf.push(player)
	end
	return took
end

function TasService.count(player, kind: string, id: string): number
	local tas = TasService.tas(player)
	if not tas then
		return 0
	end
	return TasLogic.countOf(tas, kind, id)
end

function TasService.canFitBatch(player, items): boolean
	local tas = TasService.tas(player)
	if not tas then
		return false
	end
	return TasLogic.canFitBatch(tas, items)
end

return TasService
