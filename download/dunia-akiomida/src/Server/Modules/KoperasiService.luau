local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Remotes)
local Util = require(ReplicatedStorage.Shared.Util)
local CropConfig = require(ReplicatedStorage.Shared.CropConfig)
local Config = require(ReplicatedStorage.Shared.Config)

local DataService = require(script.Parent.DataService)

local KoperasiService = {}

local KINDS = {
        { kind = "crop", list = nil, priceOf = function(id)
                return CropConfig.sellOf(id)
        end, nameOf = function(id)
                return CropConfig.nameOf(id)
        end },
        { kind = "bag", list = Config.Resources, priceOf = function(res)
                return res.sell
        end, nameOf = function(res)
                return res.name
        end },
        { kind = "fish", list = Config.Fish, priceOf = function(res)
                return res.sell
        end, nameOf = function(res)
                return res.name
        end },
}

function KoperasiService.priceOf(kind: string, id: string): number
        for _, entry in ipairs(KINDS) do
                if entry.kind == kind then
                        if entry.list then
                                for _, res in ipairs(entry.list) do
                                        if res.id == id then
                                                return entry.priceOf(res)
                                        end
                                end
                        elseif kind == "crop" then
                                return entry.priceOf(id)
                        end
                end
        end
        return 0
end

function KoperasiService.nameOf(kind: string, id: string): string
        for _, entry in ipairs(KINDS) do
                if entry.kind == kind then
                        if entry.list then
                                for _, res in ipairs(entry.list) do
                                        if res.id == id then
                                                return entry.nameOf(res)
                                        end
                                end
                        elseif kind == "crop" then
                                return entry.nameOf(id)
                        end
                end
        end
        return id
end

local function offerCount(player: Player, kind: string, id: string): number
        return DataService.countItem(player, kind, id)
end

function KoperasiService.offers(player: Player): { any }
        local out = {}
        for _, entry in ipairs(KINDS) do
                if entry.list then
                        for _, res in ipairs(entry.list) do
                                local n = offerCount(player, entry.kind, res.id)
                                if n > 0 then
                                        table.insert(out, { kind = entry.kind, id = res.id, name = entry.nameOf(res), price = entry.priceOf(res), count = n })
                                end
                        end
                elseif entry.kind == "crop" then
                        local crops = DataService.get(player).Crops
                        local ids = {}
                        for id in pairs(crops) do
                                table.insert(ids, id)
                        end
                        table.sort(ids)
                        for _, id in ipairs(ids) do
                                local n = crops[id] or 0
                                if n > 0 then
                                        table.insert(out, { kind = "crop", id = id, name = CropConfig.nameOf(id), price = CropConfig.sellOf(id), count = n })
                                end
                        end
                end
        end
        return out
end

local function sell(player: Player, kind: string, id: string, wantAll: boolean)
        local price = KoperasiService.priceOf(kind, id)
        if price <= 0 then
                return { ok = false, msg = "Item tidak bisa dijual." }
        end
        local have = offerCount(player, kind, id)
        if have < 1 then
                return { ok = false, msg = "Kamu tidak punya item itu." }
        end
        local n = wantAll and have or 1
        local total = price * n
        DataService.takeItem(player, kind, id, n)
        DataService.addCoins(player, total, true)
        DataService.push(player)
        return { ok = true, msg = "Terjual " .. n .. "x " .. KoperasiService.nameOf(kind, id) .. " = " .. Util.formatNumber(total) .. " Micda." }
end

local function sellEverything(player: Player)
        local total = 0
        local parts = {}
        for _, entry in ipairs(KINDS) do
                if entry.list then
                        for _, res in ipairs(entry.list) do
                                local have = offerCount(player, entry.kind, res.id)
                                if have > 0 then
                                        local earned = entry.priceOf(res) * have
                                        DataService.takeItem(player, entry.kind, res.id, have)
                                        DataService.addCoins(player, earned, true)
                                        total += earned
                                        table.insert(parts, have .. "x " .. entry.nameOf(res))
                                end
                        end
                elseif entry.kind == "crop" then
                        local crops = DataService.get(player).Crops
                        local ids = {}
                        for id in pairs(crops) do
                                table.insert(ids, id)
                        end
                        table.sort(ids)
                        for _, id in ipairs(ids) do
                                local have = crops[id] or 0
                                if have > 0 then
                                        local earned = CropConfig.sellOf(id) * have
                                        DataService.takeItem(player, "crop", id, have)
                                        DataService.addCoins(player, earned, true)
                                        total += earned
                                        table.insert(parts, have .. "x " .. CropConfig.nameOf(id))
                                end
                        end
                end
        end
        table.sort(parts)
        DataService.push(player)
        if total == 0 then
                return { ok = false, msg = "Tidak ada yang bisa dijual." }
        end
        return { ok = true, msg = "Terjual semuanya (" .. table.concat(parts, ", ") .. ") = " .. Util.formatNumber(total) .. " Micda!" }
end

function KoperasiService.init()
        Remotes.get("KoperasiAct").OnServerInvoke = function(player, payload)
                if not DataService.has(player) or type(payload) ~= "table" then
                        return { ok = false, msg = "Permintaan tidak valid." }
                end
                if payload.action == "offers" then
                        return { ok = true, offers = KoperasiService.offers(player) }
                elseif payload.action == "sell" then
                        return sell(player, tostring(payload.kind or ""), tostring(payload.id or ""), payload.all == true)
                elseif payload.action == "sellAll" then
                        return sellEverything(player)
                end
                return { ok = false, msg = "Aksi tidak dikenal." }
        end
end

return KoperasiService
