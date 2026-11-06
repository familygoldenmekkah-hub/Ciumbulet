local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropData = require(ReplicatedStorage.Shared.CropData)

local ShopService = {}

local Data, Tas
local rng = Random.new()
local shopPoint: Vector3? = nil

function ShopService.bind(deps)
	Data = deps.Data
	Tas = deps.Tas
end

function ShopService.setShopPoint(pos: Vector3)
	shopPoint = pos
end

function ShopService.shopPoint(): Vector3?
	return shopPoint
end

function ShopService.near(player, maxDist: number): boolean
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root or not shopPoint then
		return false
	end
	return (root.Position - shopPoint).Magnitude <= maxDist
end

function ShopService.buy(player, packId: any): (boolean, string)
	if type(packId) ~= "string" then
		return false, "Permintaan tidak sah."
	end
	local pack = CropData.Packs[packId]
	if not pack then
		return false, "Pack tidak dikenal."
	end
	if not ShopService.near(player, 30) then
		return false, "Terlalu jauh dari kasir."
	end
	local d = Data.get(player)
	if not d or d.m < pack.price then
		return false, "Micda tidak cukup."
	end
	local pool = CropData.byRarity(packId)
	local items = {}
	for _ = 1, pack.count do
		local pick = pool[rng:NextInteger(1, #pool)]
		table.insert(items, { kind = "benih", id = pick.id, count = 1 })
	end
	if not Tas.canFitBatch(player, items) then
		return false, "Tas penuh! Kosongkan slot dulu."
	end
	if not Data.trySpend(player, pack.price) then
		return false, "Micda tidak cukup."
	end
	local nama = {}
	for _, it in ipairs(items) do
		Tas.add(player, it.kind, it.id, it.count)
		table.insert(nama, CropData.byId[it.id].nama)
	end
	return true, "Pack " .. packId .. ": " .. table.concat(nama, ", ")
end

function ShopService.sell(player, cropId: any, count: any): (boolean, string)
	if type(cropId) ~= "string" or not CropData.byId[cropId] then
		return false, "Barang tidak dikenal."
	end
	if not ShopService.near(player, 30) then
		return false, "Terlalu jauh dari kasir."
	end
	local ada = Tas.count(player, "hasil", cropId)
	local n
	if count == nil then
		n = ada
	else
		if type(count) ~= "number" or count ~= count or count % 1 ~= 0 then
			return false, "Jumlah tidak sah."
		end
		n = math.floor(count)
	end
	if n <= 0 then
		return false, "Jumlah tidak sah."
	end
	if n > ada then
		n = ada
	end
	if n <= 0 then
		return false, "Tidak ada yang bisa dijual."
	end
	local info = CropData.byId[cropId]
	local total = info.jual * n
	Tas.remove(player, "hasil", cropId, n)
	Data.addMicda(player, total)
	return true, "Terjual " .. n .. " " .. info.nama .. " (+" .. total .. " Micda)."
end

return ShopService
