--!nonstrict
--[[
        UIController.luau
        Builds the whole game UI in code (no uploaded assets):
          - top coin counter (+ per second)
          - big circular click button with floating "+N" popups
          - shop with 3 tabs: Upgrades / Pets / Robux
          - rebirth button, global leaderboard panel, toast notifications
        All purchases go through the Purchase RemoteFunction; the server
        validates everything.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Remotes)
local Util = require(ReplicatedStorage.Shared.Util)

local UIController = {}
UIController.__index = UIController

--------------------------------------------------------------------
-- THEME
--------------------------------------------------------------------
local T = {
        Bg = Color3.fromRGB(18, 20, 28),
        Panel = Color3.fromRGB(30, 33, 45),
        PanelLight = Color3.fromRGB(42, 46, 62),
        Gold = Color3.fromRGB(255, 196, 37),
        Green = Color3.fromRGB(80, 200, 120),
        Red = Color3.fromRGB(235, 90, 90),
        Blue = Color3.fromRGB(90, 140, 255),
        Text = Color3.fromRGB(235, 235, 245),
        TextDim = Color3.fromRGB(160, 165, 180),
        Disabled = Color3.fromRGB(70, 74, 88),
}

local player = Players.LocalPlayer

--------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------

local function corner(parent, radius)
        return Util.create("UICorner", { CornerRadius = UDim.new(0, radius or 10) }, parent)
end

local function makeSound()
        local s = Util.create("Sound", {
                SoundId = "rbxasset://sounds/electronicpingshort.wav",
                Volume = 0.4,
        }, SoundService)
        return s
end

--------------------------------------------------------------------
-- CONSTRUCTION
--------------------------------------------------------------------

function UIController.new()
        local self = setmetatable({}, UIController)

        self.state = nil
        self.sound = makeSound()

        self:buildRoot()
        self:buildCoinCounter()
        self:buildClickButton()
        self:buildSideButtons()
        self:buildShop()
        self:buildLeaderboardPanel()
        self:buildNotifyContainer()
        self:wireRemotes()

        return self
end

function UIController:buildRoot()
        self.gui = Util.create("ScreenGui", {
                Name = "CoinRushUI",
                ResetOnSpawn = false,
                IgnoreGuiInset = true,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        }, player:WaitForChild("PlayerGui"))
end

function UIController:buildCoinCounter()
        local panel = Util.create("Frame", {
                Name = "CoinPanel",
                Position = UDim2.new(0.5, -140, 0, 12),
                Size = UDim2.new(0, 280, 0, 64),
                BackgroundColor3 = T.Panel,
                Parent = self.gui,
        })
        corner(panel, 16)

        local coin = Util.create("Frame", {
                Position = UDim2.new(0, 12, 0.5, -19),
                Size = UDim2.new(0, 38, 0, 38),
                BackgroundColor3 = T.Gold,
                Parent = panel,
        })
        corner(coin, 19)
        Util.create("TextLabel", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                Text = "C",
                TextScaled = true,
                TextColor3 = T.Bg,
                Parent = coin,
        })

        self.coinsLabel = Util.create("TextLabel", {
                Position = UDim2.new(0, 60, 0, 8),
                Size = UDim2.new(1, -70, 0, 30),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                Text = "0",
                TextXAlignment = Enum.TextXAlignment.Left,
                TextScaled = true,
                TextColor3 = T.Text,
                Parent = panel,
        })

        self.perSecLabel = Util.create("TextLabel", {
                Position = UDim2.new(0, 60, 0, 38),
                Size = UDim2.new(1, -70, 0, 18),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = "+0 /s",
                TextXAlignment = Enum.TextXAlignment.Left,
                TextScaled = true,
                TextColor3 = T.TextDim,
                Parent = panel,
        })
end

function UIController:buildClickButton()
        local btn = Util.create("TextButton", {
                Name = "ClickButton",
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.new(0.5, 0, 1, -24),
                Size = UDim2.new(0, 120, 0, 120),
                BackgroundColor3 = T.Gold,
                Font = Enum.Font.GothamBlack,
                Text = "CLICK!\n+1",
                TextScaled = false,
                TextSize = 22,
                TextColor3 = T.Bg,
                AutoButtonColor = true,
                Parent = self.gui,
        })
        corner(btn, 60)
        Util.create("UIStroke", { Color = Color3.fromRGB(255, 230, 150), Thickness = 3 }, btn)
        self.clickButton = btn

        self.floatLayer = Util.create("Frame", {
                Name = "FloatLayer",
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Parent = self.gui,
        })

        btn.Activated:Connect(function()
                self:onClicked()
        end)
end

function UIController:buildSideButtons()
        self.shopBtn = Util.create("TextButton", {
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(0, 20, 1, -40),
                Size = UDim2.new(0, 120, 0, 48),
                BackgroundColor3 = T.Blue,
                Font = Enum.Font.GothamBlack,
                Text = "SHOP",
                TextSize = 22,
                TextColor3 = T.Text,
                Parent = self.gui,
        })
        corner(self.shopBtn, 12)
        self.shopBtn.Activated:Connect(function()
                self:setShopOpen(not self.shopOpen)
        end)

        self.rebirthBtn = Util.create("TextButton", {
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(0, 20, 1, -100),
                Size = UDim2.new(0, 120, 0, 48),
                BackgroundColor3 = T.PanelLight,
                Font = Enum.Font.GothamBlack,
                Text = "REBIRTH",
                TextSize = 18,
                TextColor3 = T.Text,
                Parent = self.gui,
        })
        corner(self.rebirthBtn, 12)
        self.rebirthBtn.Activated:Connect(function()
                if self.state then
                        Remotes.get("Purchase"):InvokeServer("rebirth")
                end
        end)

        self.lbBtn = Util.create("TextButton", {
                Position = UDim2.new(1, -140, 0, 12),
                Size = UDim2.new(0, 120, 0, 40),
                BackgroundColor3 = T.Panel,
                Font = Enum.Font.GothamBlack,
                Text = "TOP 10",
                TextSize = 18,
                TextColor3 = T.Text,
                Parent = self.gui,
        })
        corner(self.lbBtn, 12)
        self.lbBtn.Activated:Connect(function()
                self:setLeaderboardOpen(not self.lbOpen)
        end)
end

--------------------------------------------------------------------
-- SHOP
--------------------------------------------------------------------

function UIController:buildShop()
        local frame = Util.create("Frame", {
                Name = "Shop",
                Visible = false,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.new(0, 460, 0, 420),
                BackgroundColor3 = T.Bg,
                BackgroundTransparency = 0.06,
                Parent = self.gui,
        })
        corner(frame, 18)
        Util.create("UIStroke", { Color = T.PanelLight, Thickness = 2 }, frame)
        self.shopFrame = frame

        Util.create("TextLabel", {
                Position = UDim2.new(0, 16, 0, 10),
                Size = UDim2.new(1, -60, 0, 30),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                Text = "SHOP",
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 22,
                TextColor3 = T.Gold,
                Parent = frame,
        })

        local close = Util.create("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -12, 0, 10),
                Size = UDim2.new(0, 30, 0, 30),
                BackgroundColor3 = T.Red,
                Font = Enum.Font.GothamBlack,
                Text = "X",
                TextSize = 16,
                TextColor3 = T.Text,
                Parent = frame,
        })
        corner(close, 8)
        close.Activated:Connect(function()
                self:setShopOpen(false)
        end)

        -- Tabs
        self.tabs = {}
        local tabNames = { "Upgrades", "Pets", "Robux" }
        for i, name in tabNames do
                local tab = Util.create("TextButton", {
                        Position = UDim2.new((i - 1) / 3, 4, 0, 46),
                        Size = UDim2.new(1 / 3, -8, 0, 34),
                        BackgroundColor3 = T.PanelLight,
                        Font = Enum.Font.GothamBold,
                        Text = name,
                        TextSize = 16,
                        TextColor3 = T.Text,
                        Parent = frame,
                })
                corner(tab, 8)
                self.tabs[name] = tab
                tab.Activated:Connect(function()
                        self:setTab(name)
                end)
        end

        -- Tab content: scrolling frames
        self.tabFrames = {}
        for _, name in tabNames do
                local scroll = Util.create("ScrollingFrame", {
                        Visible = false,
                        Position = UDim2.new(0, 12, 0, 90),
                        Size = UDim2.new(1, -24, 1, -104),
                        BackgroundTransparency = 1,
                        ScrollBarThickness = 4,
                        ScrollBarImageColor3 = T.PanelLight,
                        CanvasSize = UDim2.new(0, 0, 0, 0),
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        Parent = frame,
                })
                Util.create("UIListLayout", {
                        Padding = UDim.new(0, 8),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                }, scroll)
                self.tabFrames[name] = scroll
        end

        self:populateUpgrades()
        self:populatePets()
        self:populateRobux()
        self:setTab("Upgrades")
end

local function newRow(parent): (Frame, TextLabel, TextLabel, TextButton)
        local row = Util.create("Frame", {
                Size = UDim2.new(1, -8, 0, 58),
                BackgroundColor3 = T.Panel,
                Parent = parent,
        })
        corner(row, 10)

        local nameLabel = Util.create("TextLabel", {
                Position = UDim2.new(0, 12, 0, 8),
                Size = UDim2.new(1, -140, 0, 22),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = "Item",
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 17,
                TextColor3 = T.Text,
                Parent = row,
        })

        local subLabel = Util.create("TextLabel", {
                Position = UDim2.new(0, 12, 0, 32),
                Size = UDim2.new(1, -140, 0, 18),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = "",
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 14,
                TextColor3 = T.TextDim,
                Parent = row,
        })

        local buy = Util.create("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.new(0, 110, 0, 38),
                BackgroundColor3 = T.Green,
                Font = Enum.Font.GothamBlack,
                Text = "BUY",
                TextSize = 15,
                TextColor3 = T.Text,
                Parent = row,
        })
        corner(buy, 8)
        return row, nameLabel, subLabel, buy
end

function UIController:populateUpgrades()
        local scroll = self.tabFrames.Upgrades
        self.upgradeRows = {}
        for index, def in Config.Upgrades do
                local row, nameLabel, subLabel, buy = newRow(scroll)
                nameLabel.Text = def.name
                self.upgradeRows[def.id] = { sub = subLabel, button = buy, def = def }
                buy.Activated:Connect(function()
                        Remotes.get("Purchase"):InvokeServer("upgrade", def.id)
                end)
                row.LayoutOrder = index
        end
end

function UIController:populatePets()
        local scroll = self.tabFrames.Pets
        self.petRows = {}
        for index, def in Config.Pets do
                local row, nameLabel, subLabel, buy = newRow(scroll)
                nameLabel.Text = def.name .. "  (+" .. def.income .. "/s)"
                self.petRows[def.id] = { sub = subLabel, button = buy, def = def }
                buy.Activated:Connect(function()
                        local st = self.state
                        if st and table.find(st.Pets, def.id) then
                                if table.find(st.Equipped, def.id) then
                                        Remotes.get("Purchase"):InvokeServer("pet_unequip", def.id)
                                else
                                        Remotes.get("Purchase"):InvokeServer("pet_equip", def.id)
                                end
                        else
                                Remotes.get("Purchase"):InvokeServer("pet_buy", def.id)
                        end
                end)
                row.LayoutOrder = index
        end

        self.petCapLabel = Util.create("TextLabel", {
                Size = UDim2.new(1, -8, 0, 24),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = "Equipped: 0/3",
                TextSize = 14,
                TextColor3 = T.TextDim,
                Parent = scroll,
        })
        self.petCapLabel.LayoutOrder = 999
end

function UIController:populateRobux()
        local scroll = self.tabFrames.Robux

        local function card(order, titleText, subText, priceText, onClick, active: boolean)
                local row = Util.create("Frame", {
                        Size = UDim2.new(1, -8, 0, 62),
                        BackgroundColor3 = T.Panel,
                        Parent = scroll,
                })
                corner(row, 10)
                row.LayoutOrder = order

                Util.create("TextLabel", {
                        Position = UDim2.new(0, 12, 0, 9),
                        Size = UDim2.new(1, -150, 0, 22),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        Text = titleText,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextSize = 17,
                        TextColor3 = T.Text,
                        Parent = row,
                })
                Util.create("TextLabel", {
                        Position = UDim2.new(0, 12, 0, 33),
                        Size = UDim2.new(1, -150, 0, 18),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.Gotham,
                        Text = subText,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextSize = 13,
                        TextColor3 = T.TextDim,
                        Parent = row,
                })

                local buy = Util.create("TextButton", {
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, -10, 0.5, 0),
                        Size = UDim2.new(0, 110, 0, 40),
                        BackgroundColor3 = active and T.Gold or T.Disabled,
                        Font = Enum.Font.GothamBlack,
                        Text = active and ("R$ " .. priceText) or "SOON",
                        TextSize = 14,
                        TextColor3 = active and T.Bg or T.TextDim,
                        Parent = row,
                })
                corner(buy, 8)
                if active then
                        buy.Activated:Connect(onClick)
                end
        end

        for key, def in Config.Gamepasses do
                local active = def.id and def.id > 0
                card(
                        1,
                        def.name,
                        def.desc,
                        tostring(def.price),
                        function()
                                MarketplaceService:PromptGamePassPurchase(player, def.id)
                        end,
                        active
                )
        end

        for key, def in Config.Products do
                local active = def.id and def.id > 0
                card(
                        2,
                        def.name,
                        "Instant coin pack",
                        tostring(def.price),
                        function()
                                MarketplaceService:PromptProductPurchase(player, def.id)
                        end,
                        active
                )
        end
end

--------------------------------------------------------------------
-- LEADERBOARD PANEL + NOTIFY
--------------------------------------------------------------------

function UIController:buildLeaderboardPanel()
        local frame = Util.create("Frame", {
                Name = "Leaderboard",
                Visible = false,
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -14, 0, 60),
                Size = UDim2.new(0, 260, 0, 320),
                BackgroundColor3 = T.Bg,
                BackgroundTransparency = 0.06,
                Parent = self.gui,
        })
        corner(frame, 14)
        Util.create("UIStroke", { Color = T.PanelLight, Thickness = 2 }, frame)
        self.lbFrame = frame

        Util.create("TextLabel", {
                Position = UDim2.new(0, 12, 0, 8),
                Size = UDim2.new(1, -24, 0, 26),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                Text = "TOP COIN EARNERS",
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 16,
                TextColor3 = T.Gold,
                Parent = frame,
        })

        self.lbList = Util.create("Frame", {
                Position = UDim2.new(0, 12, 0, 40),
                Size = UDim2.new(1, -24, 1, -52),
                BackgroundTransparency = 1,
                Parent = frame,
        })
        Util.create("UIListLayout", {
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder,
        }, self.lbList)
end

function UIController:buildNotifyContainer()
        self.notifyFrame = Util.create("Frame", {
                Name = "Notify",
                AnchorPoint = Vector2.new(1, 1),
                Position = UDim2.new(1, -16, 1, -160),
                Size = UDim2.new(0, 260, 0, 140),
                BackgroundTransparency = 1,
                Parent = self.gui,
        })
        Util.create("UIListLayout", {
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
        }, self.notifyFrame)
end

--------------------------------------------------------------------
-- BEHAVIOUR
--------------------------------------------------------------------

function UIController:onClickSound()
        self.sound.PlaybackSpeed = 0.9 + math.random() * 0.3
        self.sound:Play()
end

function UIController:spawnFloat(text: string)
        local btn = self.clickButton
        local pos = btn.AbsolutePosition + btn.AbsoluteSize / 2
        local label = Util.create("TextLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0, pos.X + math.random(-30, 30), 0, pos.Y - 20),
                Size = UDim2.new(0, 120, 0, 26),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                Text = text,
                TextSize = 20,
                TextColor3 = T.Gold,
                Parent = self.floatLayer,
        })
        local goal = {
                Position = label.Position - UDim2.fromOffset(0, 60),
                TextTransparency = 1,
        }
        local tween = TweenService:Create(label, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
        tween:Play()
        tween.Completed:Connect(function()
                label:Destroy()
        end)
end

function UIController:onClicked()
        self:onClickSound()
        Remotes.get("Click"):FireServer()
        if self.state then
                self:spawnFloat("+" .. Util.formatNumber(self.state.ClickValue))
        end
end

function UIController:setShopOpen(open: boolean)
        self.shopOpen = open
        self.shopFrame.Visible = open
end

function UIController:setLeaderboardOpen(open: boolean)
        self.lbOpen = open
        self.lbFrame.Visible = open
        if open then
                self:refreshLeaderboard()
        end
end

function UIController:setTab(name: string)
        for tabName, frame in self.tabFrames do
                frame.Visible = tabName == name
        end
        for tabName, tab in self.tabs do
                tab.BackgroundColor3 = tabName == name and T.Blue or T.PanelLight
        end
end

function UIController:refreshLeaderboard()
        task.spawn(function()
                local ok, rows = pcall(function()
                        return Remotes.get("GetLeaderboard"):InvokeServer()
                end)
                if not ok or not rows then
                        return
                end
                for _, child in self.lbList:GetChildren() do
                        if child:IsA("TextLabel") then
                                child:Destroy()
                        end
                end
                if #rows == 0 then
                        Util.create("TextLabel", {
                                Size = UDim2.new(1, 0, 0, 24),
                                BackgroundTransparency = 1,
                                Font = Enum.Font.Gotham,
                                Text = "No entries yet - be the first!",
                                TextSize = 14,
                                TextColor3 = T.TextDim,
                                Parent = self.lbList,
                        })
                        return
                end
                for i, entry in rows do
                        Util.create("TextLabel", {
                                Size = UDim2.new(1, 0, 0, 24),
                                BackgroundTransparency = 1,
                                Font = Enum.Font.GothamBold,
                                Text = i .. ". " .. entry.name .. "  -  " .. Util.formatNumber(entry.value),
                                TextXAlignment = Enum.TextXAlignment.Left,
                                TextSize = 15,
                                TextColor3 = i <= 3 and T.Gold or T.Text,
                                Parent = self.lbList,
                        })
                end
        end)
end

--------------------------------------------------------------------
-- STATE -> UI
--------------------------------------------------------------------

function UIController:applyState(state)
        self.state = state

        self.coinsLabel.Text = Util.formatNumber(state.Coins)
        self.perSecLabel.Text = "+" .. Util.formatNumber(state.PerSecond) .. " /s"
        self.clickButton.Text = "CLICK!\n+" .. Util.formatNumber(state.ClickValue)

        local canRebirth = state.Coins >= state.RebirthCost
        self.rebirthBtn.Text = "REBIRTH\n" .. Util.formatNumber(state.RebirthCost)
        self.rebirthBtn.BackgroundColor3 = canRebirth and T.Green or T.PanelLight

        for id, row in self.upgradeRows do
                local level = state.Upgrades[id] or 0
                local maxed = level >= row.def.max
                local cost = maxed and 0 or math.floor(row.def.base * row.def.growth ^ level + 0.5)
                row.sub.Text = maxed and ("Lv " .. level .. "/" .. row.def.max .. "  -  MAXED")
                        or ("Lv " .. level .. "/" .. row.def.max .. "  -  " .. Util.formatNumber(cost) .. " coins")
                local afford = not maxed and state.Coins >= cost
                row.button.Text = maxed and "MAX" or "BUY"
                row.button.BackgroundColor3 = maxed and T.Disabled or (afford and T.Green or T.PanelLight)
        end

        local equippedCount = #state.Equipped
        for id, row in self.petRows do
                local owned = table.find(state.Pets, id) ~= nil
                local equipped = table.find(state.Equipped, id) ~= nil
                if equipped then
                        row.sub.Text = "EQUIPPED  -  +" .. row.def.income .. "/s"
                        row.button.Text = "UNEQUIP"
                        row.button.BackgroundColor3 = T.Red
                elseif owned then
                        row.sub.Text = "Owned  -  +" .. row.def.income .. "/s"
                        row.button.Text = "EQUIP"
                        row.button.BackgroundColor3 = T.Blue
                else
                        row.sub.Text = row.def.price .. " coins  -  +" .. row.def.income .. "/s"
                        row.button.Text = "BUY"
                        row.button.BackgroundColor3 = state.Coins >= row.def.price and T.Green or T.PanelLight
                end
        end
        self.petCapLabel.Text = "Equipped: " .. equippedCount .. "/" .. state.EquipCap
end

--------------------------------------------------------------------
-- REMOTES
--------------------------------------------------------------------

function UIController:wireRemotes()
        local stateSync = Remotes.get("StateSync")
        stateSync.OnClientEvent:Connect(function(state)
                self:applyState(state)
        end)

        local notify = Remotes.get("Notify")
        notify.OnClientEvent:Connect(function(title: string, message: string)
                self:toast(title, message)
        end)

        -- periodic leaderboard refresh while open
        task.spawn(function()
                while true do
                        task.wait(20)
                        if self.lbOpen then
                                self:refreshLeaderboard()
                        end
                end
        end)
end

function UIController:toast(title: string, message: string)
        local card = Util.create("Frame", {
                Size = UDim2.new(1, 0, 0, 52),
                BackgroundColor3 = T.Panel,
                BackgroundTransparency = 0.1,
                Parent = self.notifyFrame,
        })
        corner(card, 10)

        Util.create("TextLabel", {
                Position = UDim2.new(0, 10, 0, 6),
                Size = UDim2.new(1, -20, 0, 18),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                Text = title,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 14,
                TextColor3 = T.Gold,
                Parent = card,
        })
        Util.create("TextLabel", {
                Position = UDim2.new(0, 10, 0, 26),
                Size = UDim2.new(1, -20, 0, 20),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = message,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextScaled = true,
                TextColor3 = T.Text,
                Parent = card,
        })

        task.delay(3.2, function()
                local tween = TweenService:Create(
                        card,
                        TweenInfo.new(0.4),
                        { BackgroundTransparency = 1 }
                )
                tween:Play()
                tween.Completed:Wait()
                card:Destroy()
        end)
end

return UIController
