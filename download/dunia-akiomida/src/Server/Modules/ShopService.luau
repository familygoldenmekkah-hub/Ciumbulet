--!nonstrict
--[[
        ShopService.luau - roda ekonomi dunia:
          Toko Bibit        : jual bibit (syarat level)
          Pasar Pengepul    : beli hasil panen/sumber daya/ikan (harga pasar dinamis)
          Toko Alat         : kaleng siram, pancing, belik, sepeda
          Toko Peliharaan   : pet memberi bonus harga jual
        Permintaan pasar berubah tiap 10 menit (0.8x - 1.35x) - harga hidup.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Remotes)
local Util = require(ReplicatedStorage.Shared.Util)

local DataService = require(script.Parent.DataService)
local PetService = require(script.Parent.PetService)

local ShopService = {}

local cropById, toolById, petById, resById, fishById = {}, {}, {}, {}, {}
for _, crop in ipairs(Config.Crops) do
        cropById[crop.id] = crop
end
for _, tool in ipairs(Config.Tools) do
        toolById[tool.id] = tool
end
for _, pet in ipairs(Config.Pets) do
        petById[pet.id] = pet
end
for _, res in ipairs(Config.Resources) do
        resById[res.id] = res
end
for _, fish in ipairs(Config.Fish) do
        fishById[fish.id] = fish
end

--------------------------------------------------------------------
-- HARGA PASAR DINAMIS (sama untuk semua server: berbasis os.time)
--------------------------------------------------------------------

local function hashString(s: string): number
        local h = 0
        for i = 1, #s do
                h = (h * 31 + string.byte(s, i)) % 1000000007
        end
        return h
end

--- permintaan pasar 0.80 - 1.35 berganti tiap MarketPeriod detik
function ShopService.demandOf(itemId: string): number
        local period = math.floor(os.time() / Config.Economy.MarketPeriod)
        local rng = Random.new(period * 131 + hashString(itemId))
        return math.floor(rng:NextNumber(0.80, 1.35) * 100) / 100
end

function ShopService.getDemand(): { [string]: number }
        local out = {}
        for id in cropById do
                out[id] = ShopService.demandOf(id)
        end
        return out
end

function ShopService.demandSnapshot()
        return ShopService.getDemand()
end

--- harga jual final = dasar x permintaan x bonus peliharaan
function ShopService.sellPrice(player: Player, baseSell: number, itemId: string): number
        local demand = ShopService.demandOf(itemId)
        local bonus = PetService.sellBonus(player)
        return math.max(1, math.floor(baseSell * demand * (1 + bonus) + 0.5))
end

--------------------------------------------------------------------
-- NPC TOKO -> buka panel
--------------------------------------------------------------------

function ShopService.bindPrompt(prompt: ProximityPrompt, shopId: string)
        local titles = {
                bibit = "Toko Bibit",
                jual = "Pasar Pengepul",
                alat = "Toko Alat",
                pet = "Toko Peliharaan",
        }
        prompt.ActionText = "Belanja"
        prompt.ObjectText = titles[shopId] or "Toko"
        prompt.MaxActivationDistance = 11
        prompt.HoldDuration = 0
        prompt.Triggered:Connect(function(player)
                if DataService.has(player) then
                        Remotes.get("OpenShop"):FireClient(player, shopId)
                end
        end)
end

--------------------------------------------------------------------
-- BELI
--------------------------------------------------------------------

local function applySpeed(player: Player)
        local character = player.Character
        if not character then
                return
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
                humanoid.WalkSpeed = DataService.get(player).Tools.bike and 26 or 16
        end
end

local function onBuyItem(player: Player, shopId: any, itemId: any)
        if not DataService.has(player) or type(shopId) ~= "string" or type(itemId) ~= "string" then
                return { ok = false, msg = "Permintaan tidak valid." }
        end

        -------------------------------------------------- TOKO BIBIT
        if shopId == "bibit" then
                local crop = cropById[itemId]
                if not crop then
                        return { ok = false, msg = "Bibit tidak dikenal." }
                end
                local level = DataService.levelOf(player)
                if level < crop.level then
                        return { ok = false, msg = "Butuh level " .. crop.level .. ". Kumpulkan XP dari panen & aktivitas!" }
                end
                if not DataService.spend(player, crop.cost) then
                        return { ok = false, msg = "Micda kurang! Jual hasil panenmu di Pasar Pengepul." }
                end
                DataService.giveItem(player, "seed", itemId, 1)
                DataService.push(player)
                return { ok = true, msg = "Bibit " .. crop.name .. " dibeli!" }

        -------------------------------------------------- TOKO ALAT
        elseif shopId == "alat" then
                local tool = toolById[itemId]
                if not tool then
                        return { ok = false, msg = "Alat tidak dikenal." }
                end
                local data = DataService.get(player)
                if itemId == "pick2" and data.Tools.pickTier >= 2 or itemId == "pick3" and data.Tools.pickTier >= 3 then
                        return { ok = false, msg = "Kamu sudah punya belik yang lebih bagus." }
                end
                if (itemId == "can" and data.Tools.can) or (itemId == "rod" and data.Tools.rod) or (itemId == "bike" and data.Tools.bike) then
                        return { ok = false, msg = "Alat ini sudah kamu miliki." }
                end
                if not DataService.spend(player, tool.cost) then
                        return { ok = false, msg = "Micda kurang! Jual dulu hasil panenmu." }
                end
                if tool.tier then
                        data.Tools.pickTier = tool.tier
                elseif itemId == "can" then
                        data.Tools.can = true
                elseif itemId == "rod" then
                        data.Tools.rod = true
                elseif itemId == "bike" then
                        data.Tools.bike = true
                end
                DataService.markDirty(player)
                applySpeed(player)
                DataService.push(player)
                return { ok = true, msg = tool.name .. " dibeli! " .. tool.desc }

        -------------------------------------------------- TOKO PELIHARAAN
        elseif shopId == "pet" then
                local pet = petById[itemId]
                if not pet then
                        return { ok = false, msg = "Peliharaan tidak dikenal." }
                end
                local data = DataService.get(player)
                if data.Pets[itemId] then
                        DataService.markDirty(player)
                        data.ActivePet = itemId
                        PetService.attach(player)
                        DataService.push(player)
                        return { ok = true, msg = pet.name .. " kembali menemanimu!" }
                end
                if not DataService.spend(player, pet.cost) then
                        return { ok = false, msg = "Micda kurang! Peliharaan ini mahal - kumpulkan hasil panen dulu." }
                end
                data.Pets[itemId] = true
                data.ActivePet = itemId
                DataService.markDirty(player)
                PetService.attach(player)
                DataService.push(player)
                return { ok = true, msg = pet.name .. " ikut bertualang bersamamu! " .. pet.desc }
        end

        return { ok = false, msg = "Toko tidak dikenal." }
end

--------------------------------------------------------------------
-- JUAL
--------------------------------------------------------------------

--- kind: "crop" | "bag" | "fish"
local function baseSellOf(kind: string, id: string): number?
        if kind == "crop" then
                local crop = cropById[id]
                return crop and crop.sell
        elseif kind == "bag" then
                local res = resById[id]
                return res and res.sell
        elseif kind == "fish" then
                local fish = fishById[id]
                return fish and fish.sell
        end
        return nil
end

local function kindLabel(kind: string): string
        if kind == "crop" then
                return "Hasil Panen"
        elseif kind == "bag" then
                return "Sumber Daya"
        elseif kind == "fish" then
                return "Ikan"
        end
        return "Barang"
end

local function onSellItem(player: Player, kind: any, itemId: any, all: any)
        if not DataService.has(player) or type(kind) ~= "string" or type(itemId) ~= "string" then
                return { ok = false, msg = "Permintaan tidak valid." }
        end
        local base = baseSellOf(kind, itemId)
        if not base then
                return { ok = false, msg = "Barang tidak dikenal." }
        end
        local have = DataService.countItem(player, kind, itemId)
        if have <= 0 then
                return { ok = false, msg = "Kamu tidak punya barang itu." }
        end
        local count = (all == true) and have or 1
        local unit = ShopService.sellPrice(player, base, itemId)
        local total = unit * count

        DataService.takeItem(player, kind, itemId, count)
        DataService.addCoins(player, total, true)
        DataService.addXP(player, count)
        DataService.push(player)
        return { ok = true, msg = "Terjual " .. count .. "x - +" .. Util.formatNumber(total) .. " Micda!", total = total }
end

--------------------------------------------------------------------
-- JUAL SEMUA SATU KLIK
--------------------------------------------------------------------

local function onSellAll(player: Player)
        if not DataService.has(player) then
                return { ok = false, msg = "Data belum siap." }
        end
        local data = DataService.get(player)
        local total = 0
        local items = 0

        local function flush(kind: string, tableData: { [string]: number }, lookup: { [string]: any })
                for id, count in tableData do
                        if lookup[id] and count > 0 then
                                local unit = ShopService.sellPrice(player, lookup[id].sell, id)
                                DataService.takeItem(player, kind, id, count)
                                total += unit * count
                                items += count
                        end
                end
        end

        flush("crop", data.Crops, cropById)
        flush("bag", data.Bag, resById)
        flush("fish", data.Fish, fishById)

        if items == 0 then
                return { ok = false, msg = "Tas masih kosong. Tanam, tebang, atau mancing dulu!" }
        end
        DataService.addCoins(player, total, true)
        DataService.addXP(player, items)
        DataService.push(player)
        return { ok = true, msg = items .. " barang terjual - +" .. Util.formatNumber(total) .. " Micda!", total = total }
end

--------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------

function ShopService.init()
        Remotes.get("BuyItem").OnServerInvoke = onBuyItem
        Remotes.get("SellItem").OnServerInvoke = onSellItem
        Remotes.get("SellAll").OnServerInvoke = onSellAll
        -- daftarkan snapshot permintaan pasar ke DataService (tanpa siklus require)
        DataService.registerProvider("demand", function()
                return ShopService.getDemand()
        end)
end

return ShopService
