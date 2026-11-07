local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropData = require(ReplicatedStorage.Shared.CropData)
local StrukBeli = require(ReplicatedStorage.Shared.StrukBeli)
local UangLogic = require(ReplicatedStorage.Shared.UangLogic)

local ShopService = {}

local Uang, Tas
local rng = Random.new()
local shopPoint: Vector3? = nil

function ShopService.bind(deps)
        Uang = deps.Uang
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

function ShopService.buy(player, packId: any): (boolean, string, { any }?)
        if type(packId) ~= "string" then
                return false, "Permintaan tidak sah."
        end
        local pack = CropData.Packs[packId]
        if not pack then
                return false, "Pack tidak dikenal."
        end
        if not ShopService.near(player, 45) then
                return false, "Dekati kasir Toko Benih dulu."
        end
        if not Uang or Uang.GetMicda(player) < pack.price then
                return false, "Micda tidak cukup."
        end
        local pool = CropData.byRarity(packId)
        local items = {}
        local picks = {}
        for _ = 1, pack.count do
                local pick = pool[rng:NextInteger(1, #pool)]
                table.insert(items, { kind = "benih", id = pick.id, count = 1 })
                table.insert(picks, pick.id)
        end
        if not Tas.canFitBatch(player, items) then
                return false, "Tas penuh! Kosongkan slot dulu."
        end
        local okBayar = Uang.SpendMicda(player, pack.price, "beli_benih")
        if not okBayar then
                return false, "Micda tidak cukup."
        end
        local nama = {}
        for _, it in ipairs(items) do
                Tas.add(player, it.kind, it.id, it.count)
                table.insert(nama, CropData.byId[it.id].nama)
        end
        return true, "Pack " .. packId .. ": " .. table.concat(nama, ", "), StrukBeli.rangkum(picks, CropData.byId)
end

function ShopService.sell(player, cropId: any, count: any): (boolean, string)
        if type(cropId) ~= "string" or not CropData.byId[cropId] then
                return false, "Barang tidak dikenal."
        end
        if not ShopService.near(player, 45) then
                return false, "Dekati kasir Toko Benih dulu."
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
        local ruang = Uang and Uang.RuangMicda and Uang.RuangMicda(player) or math.huge
        if total > ruang then
                return false, "Ruangan Micda rekeningmu tinggal " .. UangLogic.format(ruang) .. "! Jual dalam bagian lebih kecil."
        end
        local diambil = Tas.remove(player, "hasil", cropId, n)
        if diambil < 1 then
                return false, "Hasil panen tidak bisa diambil dari tas."
        end
        local okUang = Uang and Uang.AddMicda(player, total, "jual_hasil")
        if not okUang then
                Tas.add(player, "hasil", cropId, diambil)
                return false, "Penjualan ditunda sebentar. Barangmu dikembalikan utuh ke tas."
        end
        return true, "Terjual " .. diambil .. " " .. info.nama .. " (+" .. UangLogic.format(total) .. " Micda)."
end

return ShopService
