local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropData = require(ReplicatedStorage.Shared.CropData)
local Recipes = require(ReplicatedStorage.Shared.Recipes)

local CombineService = {}

local Land, Tas

function CombineService.bind(deps)
	Land = deps.Land
	Tas = deps.Tas
end

function CombineService.combine(player, idA: any, idB: any): (boolean, string)
	if type(idA) ~= "string" or type(idB) ~= "string" then
		return false, "Permintaan tidak sah."
	end
	if not CropData.byId[idA] or not CropData.byId[idB] then
		return false, "Benih tidak dikenal."
	end
	local index = Land.landOf(player)
	if not index then
		return false, "Kamu tidak punya lahan."
	end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root or not Land.isInside(index, root.Position, 8) then
		return false, "Gabung benih hanya di lahanmu sendiri."
	end
	local out = Recipes.find(idA, idB)
	if not out then
		return false, "Kombinasi ini tidak menghasilkan apa pun."
	end
	if Tas.count(player, "benih", idA) < 1 or Tas.count(player, "benih", idB) < 1 then
		return false, "Benih tidak cukup."
	end
	if Tas.roomFor(player, "benih", out, 1) < 1 then
		return false, "Tas penuh! Kosongkan slot dulu."
	end
	Tas.remove(player, "benih", idA, 1)
	Tas.remove(player, "benih", idB, 1)
	Tas.add(player, "benih", out, 1)
	return true, "Berhasil: " .. CropData.byId[out].nama .. "!"
end

return CombineService
