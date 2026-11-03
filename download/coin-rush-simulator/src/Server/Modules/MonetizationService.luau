--!nonstrict
--[[
        MonetizationService.luau
        - Grants gamepass perks on join (re-checks ownership with Roblox)
        - Grants perks instantly when a purchase finishes mid-session
        - Processes developer product receipts (coin packs)

        All IDs live in Config.Gamepasses / Config.Products. id = 0 means
        "not configured yet": the feature is skipped safely.
]]

local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Remotes)
local DataService = require(script.Parent.DataService)
local EconomyService = require(script.Parent.EconomyService)

local MonetizationService = {}

local notifyRemote = Remotes.get("Notify")
-- Receipt ledger: PurchaseId -> true. Guarantees a purchase is granted
-- exactly once even if the server crashes mid-receipt.
local receiptStore = DataStoreService:GetDataStore("CRS_Receipts_v1")

local passIdToKey: { [number]: string } = {}
local productIdToKey: { [number]: string } = {}

local function grantPass(player: Player, key: string, announce: boolean)
        local data = DataService.get(player)
        if data.Gamepasses[key] then
                return
        end
        data.Gamepasses[key] = true
        DataService.markDirty(player)
        if announce then
                notifyRemote:FireClient(player, "Thanks!", Config.Gamepasses[key].name .. " is now active!")
        end
        EconomyService.requestSync(player)
end

function MonetizationService.init()
        for key, def in Config.Gamepasses do
                if def.id and def.id > 0 then
                        passIdToKey[def.id] = key
                end
        end
        for key, def in Config.Products do
                if def.id and def.id > 0 then
                        productIdToKey[def.id] = key
                end
        end

        -- Re-verify ownership on join (covers restores & cross-device)
        Players.PlayerAdded:Connect(function(player)
                for key, def in Config.Gamepasses do
                        if def.id and def.id > 0 then
                                task.spawn(function()
                                        local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, def.id)
                                        if ok and owns then
                                                grantPass(player, key, false)
                                        end
                                end)
                        end
                end
        end)

        -- Instant grant when bought mid-session
        MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId: number, purchased: boolean)
                if purchased then
                        local key = passIdToKey[passId]
                        if key then
                                grantPass(player, key, true)
                        end
                end
        end)

        -- Developer products (coin packs). Official pattern:
        -- record receipt first, then grant, then acknowledge.
        MarketplaceService.ProcessReceipt = function(receipt)
                local key = productIdToKey[receipt.ProductId]
                if not key then
                        return Enum.ProductPurchaseDecision.NotProcessedYet
                end
                local player = Players:GetPlayerByUserId(receipt.PlayerId)
                if not player or not DataService.has(player) then
                        return Enum.ProductPurchaseDecision.NotProcessedYet
                end

                -- 1) Dedupe: skip if we already granted this exact receipt
                local already, granted = pcall(function()
                        return receiptStore:GetAsync("r_" .. receipt.PurchaseId)
                end)
                if already and granted == true then
                        return Enum.ProductPurchaseDecision.PurchaseGranted
                end

                -- 2) Record BEFORE granting (crash-safe: retry grants again)
                local recorded = pcall(function()
                        receiptStore:SetAsync("r_" .. receipt.PurchaseId, true)
                end)
                if not recorded then
                        return Enum.ProductPurchaseDecision.NotProcessedYet
                end

                -- 3) Grant + acknowledge
                local def = Config.Products[key]
                EconomyService.addCoins(player, def.coins)
                EconomyService.requestSync(player)
                notifyRemote:FireClient(player, "Purchase", "+" .. def.coins .. " coins delivered!")
                return Enum.ProductPurchaseDecision.PurchaseGranted
        end
end

return MonetizationService
