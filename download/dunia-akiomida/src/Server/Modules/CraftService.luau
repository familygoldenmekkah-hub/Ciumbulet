--!nonstrict
--[[
        CraftService.luau - v3 "Toram-grade" profesing crafting:
          - Stasiun TEMPAA (anvil Pak Tempa): smelting balok besi/kristal,
            senjata (pedang kayu/besi/kristal), zirah (kulit/besi/kristal)
          - Stasiun DAPUR (api unggun Bu Masak): makanan buff & ramuan
          - Resep dari Balance.Recipes: objek alam -> bahan -> peralatan
          - XP craft + hook tugas (craft / cook)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Remotes)
local Balance = require(ReplicatedStorage.Shared.Balance)
local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)

local DataService = require(script.Parent.DataService)
local QuestService = require(script.Parent.QuestService)

local CraftService = {}

local STATION_TITLES = {
        tempa = "Pandai Besi - Pak Tempa",
        dapur = "Dapur Alam - Bu Masak",
}

local function nameOf(kind: string, id: string): string
        if kind == "equip" then
                for _, eq in ipairs(Balance.Equipment) do
                        if eq.id == id then
                                return eq.name
                        end
                end
        elseif kind == "use" then
                for _, u in ipairs(Balance.Usables) do
                        if u.id == id then
                                return u.name
                        end
                end
        else
                for _, res in ipairs(Config.Resources) do
                        if res.id == id then
                                return res.name
                        end
                end
                for _, crop in ipairs(Config.Crops) do
                        if crop.id == id then
                                return crop.name
                        end
                end
                for _, fish in ipairs(Config.Fish) do
                        if fish.id == id then
                                return fish.name
                        end
                end
        end
        return id
end

local function recipeLabel(r: any): string
        local parts = {}
        for matId, count in pairs(r.recipe) do
                table.insert(parts, count .. "x " .. nameOf("bag", matId))
        end
        table.sort(parts)
        return table.concat(parts, " + ")
end

-- label resep untuk client (satu kali saja, dipasangkan via provider)
local recipeLabels: { [string]: string } = {}
for _, r in ipairs(Balance.Recipes) do
        recipeLabels[r.id] = recipeLabel(r)
end

--------------------------------------------------------------------
-- JALANKAN RESEP
--------------------------------------------------------------------

local function onCraft(player: Player, recipeId: any)
        if not DataService.has(player) or type(recipeId) ~= "string" then
                return { ok = false, msg = "Permintaan tidak valid." }
        end
        local recipe = nil
        for _, r in ipairs(Balance.Recipes) do
                if r.id == recipeId then
                        recipe = r
                        break
                end
        end
        if not recipe then
                return { ok = false, msg = "Resep tidak dikenal." }
        end
        if DataService.levelOf(player) < recipe.level then
                return { ok = false, msg = "Butuh level " .. recipe.level .. " untuk resep ini." }
        end
        -- cek bahan
        for matId, count in pairs(recipe.recipe) do
                if DataService.countItem(player, "bag", matId) < count then
                        return { ok = false, msg = "Bahan kurang: " .. nameOf("bag", matId) .. " x" .. count }
                end
        end
        -- potong bahan
        local data = DataService.get(player)
        for matId, count in pairs(recipe.recipe) do
                DataService.takeItem(player, "bag", matId, count)
        end
        DataService.giveItem(player, recipe.kind, recipe.out, recipe.count)
        -- v10 mastery: tiap 10x resep sama menaikkan bonus XP (maks +50%)
        local prevCount = (data.CraftCount and data.CraftCount[recipe.id]) or 0
        data.CraftCount[recipe.id] = prevCount + 1
        local gainedXp = Balance.craftXpWithMastery(recipe.xp, prevCount + 1)
        DataService.addXP(player, gainedXp)
        local masteryLevel = Balance.craftMasteryLevel(prevCount + 1)
        if masteryLevel > Balance.craftMasteryLevel(prevCount) then
                Remotes.get("Notify"):FireClient(player, "MASTERY NAIK!",
                        nameOf(recipe.kind, recipe.out) .. " mastery " .. masteryLevel .. " - XP craft +" .. math.floor((Balance.CraftMasteryXpMult - 1) * math.min(masteryLevel, 3) * 100) .. "%!")
        end

        local hook = recipe.station == "tempa" and "craft" or "cook"
        QuestService.progress(player, hook, 1)

        -- v20: percikan tempa di tangan pembuat (sekali pakai, ringan mobile)
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
                local sparkColor = recipe.station == "tempa"
                        and Color3.fromRGB(255, 170, 90)
                        or Color3.fromRGB(250, 140, 150)
                Util.burst(root, sparkColor, 12, 7)
        end

        DataService.push(player)
        return {
                ok = true,
                msg = recipe.count .. "x " .. nameOf(recipe.kind, recipe.out) .. " selesai! (+" .. gainedXp .. " XP"
                        .. (masteryLevel > 0 and ("  M" .. masteryLevel) or "") .. ")",
        }
end

--------------------------------------------------------------------
-- STASIUN DI DUNIA
--------------------------------------------------------------------

function CraftService.bindStation(prompt: ProximityPrompt, station: string)
        prompt.ActionText = "Buat"
        prompt.ObjectText = STATION_TITLES[station] or "Stasiun"
        prompt.MaxActivationDistance = 11
        prompt.HoldDuration = 0
        prompt.Triggered:Connect(function(player)
                if DataService.has(player) then
                        Remotes.get("OpenCraft"):FireClient(player, station)
                end
        end)
end

-- daftar resep per stasiun untuk snapshot client
function CraftService.recipesFor(station: string)
        local out = {}
        for _, r in ipairs(Balance.Recipes) do
                if r.station == station then
                        table.insert(out, {
                                id = r.id,
                                out = r.out,
                                kind = r.kind,
                                name = nameOf(r.kind, r.out),
                                label = recipeLabels[r.id],
                                level = r.level,
                                xp = r.xp,
                                count = r.count,
                        })
                end
        end
        table.sort(out, function(a, b)
                return a.level < b.level
        end)
        return out
end

function CraftService.init()
        Remotes.get("Craft").OnServerInvoke = onCraft
        DataService.registerProvider("recipes", function()
                return {
                        tempa = CraftService.recipesFor("tempa"),
                        dapur = CraftService.recipesFor("dapur"),
                }
        end)
end

return CraftService
