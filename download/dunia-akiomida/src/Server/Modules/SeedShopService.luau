local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Remotes)
local Util = require(ReplicatedStorage.Shared.Util)
local CropConfig = require(ReplicatedStorage.Shared.CropConfig)
local TasLogic = require(ReplicatedStorage.Shared.TasLogic)

local DataService = require(script.Parent.DataService)

local SeedShopService = {}

local function rollPack(pack): { { kind: string, id: string, n: number } }
        local pool = CropConfig.byRarity(pack.rarity)
        local out = {}
        for _ = 1, pack.count do
                local crop = pool[math.random(1, #pool)]
                table.insert(out, { kind = "seed", id = crop.id, n = 1 })
        end
        return out
end

local function summarize(items: { { kind: string, id: string, n: number } }): { [string]: number }
        local totals: { [string]: number } = {}
        for _, item in ipairs(items) do
                totals[item.id] = (totals[item.id] or 0) + item.n
        end
        return totals
end

local function buyPack(player: Player, packId: string)
        local pack = CropConfig.packById(packId)
        if not pack then
                return { ok = false, msg = "Pack tidak dikenal." }
        end
        local data = DataService.get(player)
        if data.Coins < pack.price then
                return { ok = false, msg = "Micda kurang! Butuh " .. Util.formatNumber(pack.price) .. ", punya " .. Util.formatNumber(data.Coins) .. "." }
        end
        local rolled = rollPack(pack)
        local seeds, crops = DataService.tasTables(player)
        if not TasLogic.canFitBatch(seeds, crops, rolled) then
                return { ok = false, msg = "TAS PENUH! Kosongkan slot tas dulu (maks 50 slot)." }
        end
        DataService.spend(player, pack.price)
        for _, item in ipairs(rolled) do
                DataService.giveItem(player, "seed", item.id, item.n)
        end
        DataService.push(player)
        local parts = {}
        for id, n in pairs(summarize(rolled)) do
                table.insert(parts, n .. "x Benih " .. CropConfig.nameOf(id))
        end
        table.sort(parts)
        return { ok = true, msg = pack.name .. " berisi: " .. table.concat(parts, ", ") }
end

local function combine(player: Player, idA: string, idB: string)
        if idA == idB then
                return { ok = false, msg = "Gabung butuh dua benih yang berbeda." }
        end
        local recipe = CropConfig.findRecipe(idA, idB)
        if not recipe then
                return { ok = false, msg = "Kombinasi ini tidak ada di daftar resep!" }
        end
        if DataService.countItem(player, "seed", recipe.inputs[1]) < 1
                or DataService.countItem(player, "seed", recipe.inputs[2]) < 1 then
                return { ok = false, msg = "Butuh 1 Benih " .. CropConfig.nameOf(recipe.inputs[1]) .. " + 1 Benih " .. CropConfig.nameOf(recipe.inputs[2]) .. "." }
        end
        DataService.takeItem(player, "seed", recipe.inputs[1], 1)
        DataService.takeItem(player, "seed", recipe.inputs[2], 1)
        local seeds, crops = DataService.tasTables(player)
        if TasLogic.roomFor(seeds, crops, "seed", recipe.out, 1) < 1 then
                DataService.giveItem(player, "seed", recipe.inputs[1], 1)
                DataService.giveItem(player, "seed", recipe.inputs[2], 1)
                return { ok = false, msg = "TAS PENUH! Tidak ada ruang untuk Benih " .. CropConfig.nameOf(recipe.out) .. "." }
        end
        DataService.giveItem(player, "seed", recipe.out, 1)
        DataService.push(player)
        return { ok = true, msg = "GABUNG BERHASIL: Benih " .. CropConfig.nameOf(recipe.inputs[1]) .. " + Benih " .. CropConfig.nameOf(recipe.inputs[2]) .. " = Benih " .. CropConfig.nameOf(recipe.out) .. "!" }
end

function SeedShopService.init()
        Remotes.get("TokoAct").OnServerInvoke = function(player, payload)
                if not DataService.has(player) or type(payload) ~= "table" then
                        return { ok = false, msg = "Permintaan tidak valid." }
                end
                if payload.action == "buyPack" then
                        return buyPack(player, tostring(payload.pack or ""))
                elseif payload.action == "combine" then
                        return combine(player, tostring(payload.a or ""), tostring(payload.b or ""))
                end
                return { ok = false, msg = "Aksi tidak dikenal." }
        end
end

return SeedShopService
