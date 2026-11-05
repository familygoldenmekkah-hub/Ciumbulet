#!/usr/bin/env python3
"""Patch UIController.luau with v3 Toram-grade panels (Char/Craft/Quest/Trade + HUD upgrades)."""
import sys

PATH = "/home/z/my-project/download/dunia-akiomida/src/Client/UIController.luau"
src = open(PATH).read()

def rep(old, new, count=1):
    global src
    assert src.count(old) == count, f"MATCH FAIL ({src.count(old)} != {count}): {old[:80]!r}"
    src = src.replace(old, new)

# ---------------------------------------------------------------- 1. header requires
rep("""local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Remotes)
local Util = require(ReplicatedStorage.Shared.Util)""",
"""local Config = require(ReplicatedStorage.Shared.Config)
local Balance = require(ReplicatedStorage.Shared.Balance)
local Remotes = require(ReplicatedStorage.Remotes)
local Util = require(ReplicatedStorage.Shared.Util)""")

# ---------------------------------------------------------------- 2. new() init + build calls
rep("""        self.state = nil
        self.activePanel = nil
        self.shopId = nil
        self.shopTab = "beli"
        self.pendingPlant = nil

        self:buildGui()
        self:buildHud()
        self:buildShopPanel()
        self:buildPlantPanel()
        self:buildInvPanel()
        self:buildQuizPanel()
        self:buildCodePanel()
        self:buildHelpPanel()
        self:wireRemotes()
        self:startTips()""",
"""        self.state = nil
        self.activePanel = nil
        self.shopId = nil
        self.shopTab = "beli"
        self.pendingPlant = nil
        self.craftStation = nil
        self.tradeSnap = nil
        self.inviteFrom = nil
        self.bossInfo = nil

        self:buildGui()
        self:buildHud()
        self:buildShopPanel()
        self:buildPlantPanel()
        self:buildInvPanel()
        self:buildQuizPanel()
        self:buildCodePanel()
        self:buildHelpPanel()
        self:buildCharPanel()
        self:buildCraftPanel()
        self:buildQuestPanel()
        self:buildTradePanel()
        self:wireRemotes()
        self:startTips()""")

# ---------------------------------------------------------------- 3. showPanel list
rep("""        for _, n in { "Shop", "Plant", "Inv", "Quiz", "Code", "Help" } do""",
"""        for _, n in { "Shop", "Plant", "Inv", "Quiz", "Code", "Help", "Char", "Craft", "Quest", "Trade" } do""")

# ---------------------------------------------------------------- 4. HP bar + quest chip + boss bar
rep("""        self.xpBar = Util.create("Frame", {
                Size = UDim2.fromScale(0, 1),
                BackgroundColor3 = T.Blue,
                BorderSizePixel = 0,
        }, barBg)
        corner(self.xpBar, 7)""",
"""        self.xpBar = Util.create("Frame", {
                Size = UDim2.fromScale(0, 1),
                BackgroundColor3 = T.Blue,
                BorderSizePixel = 0,
        }, barBg)
        corner(self.xpBar, 7)

        ---------------------------------------------------------------- chip HP (v3)
        local hpChip = Util.create("Frame", {
                Name = "HpChip",
                Position = UDim2.fromOffset(16, 130),
                Size = UDim2.fromOffset(170, 46),
                BackgroundColor3 = T.Bg,
                BackgroundTransparency = 0.15,
                BorderSizePixel = 0,
        }, self.gui)
        corner(hpChip, 12)
        self.hpText = Util.create("TextLabel", {
                Position = UDim2.fromOffset(10, 3),
                Size = UDim2.new(1, -20, 0, 22),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextScaled = true,
                TextColor3 = T.Red,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "HP 100/100",
        }, hpChip)
        local hpBg = Util.create("Frame", {
                Position = UDim2.fromOffset(10, 28),
                Size = UDim2.new(1, -20, 0, 12),
                BackgroundColor3 = T.PanelLight,
                BorderSizePixel = 0,
        }, hpChip)
        corner(hpBg, 6)
        self.hpBar = Util.create("Frame", {
                Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = Color3.fromRGB(235, 90, 90),
                BorderSizePixel = 0,
        }, hpBg)
        corner(self.hpBar, 6)

        ---------------------------------------------------------------- chip tugas aktif (v3)
        self.questChip = Util.create("TextLabel", {
                Name = "QuestChip",
                Position = UDim2.fromOffset(16, 182),
                Size = UDim2.fromOffset(240, 54),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                TextScaled = true,
                TextColor3 = T.Gold,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextStrokeTransparency = 0.8,
                Text = "",
                Visible = false,
        }, self.gui)

        ---------------------------------------------------------------- bar boss raid (v3, atas tengah)
        local bossBar = Util.create("Frame", {
                Name = "BossBar",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(0.5, 0, 0, 12),
                Size = UDim2.fromOffset(430, 62),
                BackgroundColor3 = T.Bg,
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                Visible = false,
        }, self.gui)
        corner(bossBar, 12)
        self.bossTitle = Util.create("TextLabel", {
                Size = UDim2.new(1, -16, 0, 24),
                Position = UDim2.fromOffset(8, 4),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = Color3.fromRGB(255, 90, 90),
                Text = "RAJA GOLEM",
        }, bossBar)
        local bossBg = Util.create("Frame", {
                Position = UDim2.fromOffset(12, 32),
                Size = UDim2.new(1, -24, 0, 20),
                BackgroundColor3 = Color3.fromRGB(60, 20, 20),
                BorderSizePixel = 0,
        }, bossBar)
        corner(bossBg, 8)
        self.bossHp = Util.create("Frame", {
                Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = Color3.fromRGB(255, 80, 80),
                BorderSizePixel = 0,
        }, bossBg)
        corner(self.bossHp, 8)
        self.bossBar = bossBar""")

# ---------------------------------------------------------------- 5. tombol kanan atas: 6 tombol 2 baris
rep("""        local actions = {
                { name = "Tas", label = "Tas", color = T.Gold, cb = function()
                        self:renderInv()
                        self:showPanel("Inv")
                end },
                { name = "Kode", label = "Kode", color = T.Blue, cb = function()
                        self:showPanel("Code")
                end },
                { name = "Bantuan", label = "?", color = T.Green, cb = function()
                        self:showPanel("Help")
                end },
        }
        local i = 0
        for _, act in actions do
                i += 1
                btn({
                        parent = self.gui,
                        Name = "Btn" .. act.name,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -16 - (i - 1) * 92, 0, 14),
                        Size = UDim2.fromOffset(84, 42),
                        BackgroundColor3 = act.color,
                        TextColor3 = Color3.fromRGB(30, 30, 36),
                        Text = act.label,
                        _radius = 12,
                }).Activated:Connect(act.cb)
        end""",
"""        local actions = {
                { name = "Tas", label = "Tas", color = T.Gold, cb = function()
                        self:renderInv()
                        self:showPanel("Inv")
                end },
                { name = "Kar", label = "Kar", color = T.Blue, cb = function()
                        self:renderChar()
                        self:showPanel("Char")
                end },
                { name = "Tugas", label = "Tugas", color = T.Green, cb = function()
                        self:renderQuest()
                        self:showPanel("Quest")
                end },
                { name = "Dagang", label = "Dagang", color = Color3.fromRGB(224, 140, 190), cb = function()
                        self:renderTrade()
                        self:showPanel("Trade")
                end },
                { name = "Kode", label = "Kode", color = T.Blue, cb = function()
                        self:showPanel("Code")
                end },
                { name = "Bantuan", label = "?", color = T.Green, cb = function()
                        self:showPanel("Help")
                end },
        }
        local i = 0
        for _, act in actions do
                i += 1
                local rowIdx = math.floor((i - 1) / 3)
                local colIdx = (i - 1) % 3
                btn({
                        parent = self.gui,
                        Name = "Btn" .. act.name,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -16 - colIdx * 92, 0, 14 + rowIdx * 50),
                        Size = UDim2.fromOffset(84, 42),
                        BackgroundColor3 = act.color,
                        TextColor3 = Color3.fromRGB(30, 30, 36),
                        Text = act.label,
                        _radius = 12,
                }).Activated:Connect(act.cb)
        end""")

# ---------------------------------------------------------------- 6. renderState refresh + HUD extras
rep("""        -- refresh panel terbuka supaya harga/inv tetap segar
        if self.activePanel == "Shop" and self.shopId then
                self:renderShop()
        elseif self.activePanel == "Plant" and self.pendingPlant then
                self:renderPlantPanel()
        elseif self.activePanel == "Inv" then
                self:renderInv()
        end
end""",
"""        self:renderHudExtras()

        -- refresh panel terbuka supaya harga/inv tetap segar
        if self.activePanel == "Shop" and self.shopId then
                self:renderShop()
        elseif self.activePanel == "Plant" and self.pendingPlant then
                self:renderPlantPanel()
        elseif self.activePanel == "Inv" then
                self:renderInv()
        elseif self.activePanel == "Char" then
                self:renderChar()
        elseif self.activePanel == "Craft" then
                self:renderCraft()
        elseif self.activePanel == "Quest" then
                self:renderQuest()
        end
end

--------------------------------------------------------------------
-- HP / TUGAS / BOSS: pembaruan HUD tiap state
--------------------------------------------------------------------

function UIController:renderHudExtras()
        local s = self.state
        if not s then
                return
        end

        -- tugas aktif
        local q = s.Quest
        if q and q.id ~= "" then
                local def = nil
                for _, d in ipairs(Balance.Quests) do
                        if d.id == q.id then
                                def = d
                                break
                        end
                end
                if def then
                        self.questChip.Visible = true
                        self.questChip.Text = (q.done and "[SIAP KLAIM] " or "Tugas: ") .. def.title .. " "
                                .. math.min(q.prog, def.goal.count) .. "/" .. def.goal.count
                        self.questChip.TextColor3 = q.done and T.Green or T.Gold
                end
        else
                self.questChip.Visible = false
        end
end""")

open(PATH, "w").write(src)
print("patch part 1 OK")
