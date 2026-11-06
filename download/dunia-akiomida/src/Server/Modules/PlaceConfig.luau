local PlaceConfig = {}

PlaceConfig.LahanPlaceId = 77626159664192
PlaceConfig.KotaPlaceId = 0

function PlaceConfig.currentPlaceId(): number
	local ok, id = pcall(function()
		return game.PlaceId
	end)
	if ok then
		return id
	end
	return 0
end

function PlaceConfig.useTeleport(): boolean
	local id = PlaceConfig.currentPlaceId()
	return PlaceConfig.KotaPlaceId > 0 and PlaceConfig.KotaPlaceId ~= id
end

return PlaceConfig
