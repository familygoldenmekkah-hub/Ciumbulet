local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropData = require(ReplicatedStorage.Shared.CropData)
local Recipes = require(ReplicatedStorage.Shared.Recipes)

local CombineService = {}

local Tas
local combinePoint: Vector3? = nil

function CombineService.bind(deps)
        Tas = deps.Tas
end

function CombineService.setCombinePoint(pos: Vector3)
        combinePoint = pos
end

function CombineService.combine(player, idA: any, idB: any): (boolean, string)
        if type(idA) ~= "string" or type(idB) ~= "string" then
                return false, "Permintaan tidak sah."
        end
        if not CropData.byId[idA] or not CropData.byId[idB] then
                return false, "Benih tidak dikenal."
        end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not root or not combinePoint or (root.Position - combinePoint).Magnitude > 24 then
                return false, "Gabung benih hanya di Meja Gabung Pusat Kota."
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
