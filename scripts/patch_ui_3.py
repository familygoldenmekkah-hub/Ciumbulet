#!/usr/bin/env python3
"""Patch UIController part 3: append Char/Craft/Quest/Trade panel methods."""

PATH = "/home/z/my-project/download/dunia-akiomida/src/Client/UIController.luau"
src = open(PATH).read()

NEW = '''--------------------------------------------------------------------
-- PANEL KARAKTER (v3): stat, poin, peralatan
--------------------------------------------------------------------

function UIController:buildCharPanel()
        local frame = self:panelFrame("Char", 0.5, 0.66)
        Util.create("TextLabel", {
                Name = "Judul",
                Size = UDim2.new(1, -60, 0, 36),
                Position = UDim2.fromOffset(18, 10),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = T.Blue,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "Karakter & Peralatan",
        }, frame)
        btn({
                parent = frame,
                Name = "Tutup",
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -12, 0, 10),
                Size = UDim2.fromOffset(40, 34),
                BackgroundColor3 = T.Red,
                TextColor3 = Color3.new(1, 1, 1),
                Text = "X",
                _radius = 8,
        }).Activated:Connect(function()
                self:showPanel(nil)
        end)

        self.charPoints = Util.create("TextLabel", {
                Name = "Poin",
                Position = UDim2.fromOffset(18, 50),
                Size = UDim2.new(1, -36, 0, 26),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextScaled = true,
                TextColor3 = T.Gold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "Poin stat: 0",
        }, frame)

        local scroll = Util.create("ScrollingFrame", {
                Name = "List",
                Position = UDim2.fromOffset(18, 80),
                Size = UDim2.new(1, -36, 1, -98),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                CanvasSize = UDim2.new(),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 6,
        }, frame)
        Util.create("UIListLayout", { Padding = UDim.new(0, 8) }, scroll)
        self.charList = scroll
end

function UIController:renderChar()
        local s = self.state
        local list = self.charList
        for _, child in list:GetChildren() do
                if child:IsA("Frame") then
                        child:Destroy()
                end
        end
        if not s then
                return
        end
        self.charPoints.Text = "Poin stat tersisa: " .. (s.StatPoints or 0)
                .. "  |  Level " .. (s.Level or 1)

        -- atribut
        for _, stat in ipairs(Balance.Stats) do
                local value = (s.Stats and s.Stats[stat.id]) or 0
                local r = row(list, 60)
                swatch(r, T.Blue, string.upper(stat.id))
                Util.create("TextLabel", {
                        Position = UDim2.fromOffset(62, 6),
                        Size = UDim2.new(1, -180, 0, 26),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextScaled = true,
                        TextColor3 = T.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = stat.name .. ": " .. value,
                }, r)
                Util.create("TextLabel", {
                        Position = UDim2.fromOffset(62, 32),
                        Size = UDim2.new(1, -180, 0, 22),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.Gotham,
                        TextScaled = true,
                        TextColor3 = T.TextDim,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = stat.desc,
                }, r)
                local plus = btn({
                        parent = r,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -8, 0, 12),
                        Size = UDim2.fromOffset(64, 36),
                        BackgroundColor3 = (s.StatPoints or 0) > 0 and value < Balance.MaxStatPerStat and T.Green or T.Disabled,
                        TextColor3 = Color3.fromRGB(24, 30, 26),
                        Text = "+1",
                        _radius = 8,
                })
                plus.Activated:Connect(function()
                        local res = Remotes.get("AllocStat"):InvokeServer(stat.id)
                        self:handleResult(res)
                end)
        end

        -- peralatan terpakai
        for _, kind in { "weapon", "armor" } do
                local eqId = s.Equipped[kind]
                local eq = nil
                for _, e in ipairs(Balance.Equipment) do
                        if e.id == eqId then
                                eq = e
                                break
                        end
                end
                local r = row(list, 56)
                swatch(r, eq and Color3.fromRGB(eq.color[1], eq.color[2], eq.color[3]) or T.Disabled,
                        kind == "weapon" and "S" or "Z")
                local label = kind == "weapon" and "Senjata: " or "Zirah: "
                local statText = ""
                if eq then
                        statText = kind == "weapon" and ("ATK +" .. eq.atk) or ("DEF +" .. eq.def)
                end
                Util.create("TextLabel", {
                        Position = UDim2.fromOffset(62, 8),
                        Size = UDim2.new(1, -170, 0, 40),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextScaled = true,
                        TextColor3 = eq and T.Text or T.TextDim,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = label .. (eq and (eq.name .. "  (" .. statText .. ")") or "- belum pakai -"),
                }, r)
                if eq then
                        btn({
                                parent = r,
                                AnchorPoint = Vector2.new(1, 0),
                                Position = UDim2.new(1, -8, 0, 10),
                                Size = UDim2.fromOffset(80, 34),
                                BackgroundColor3 = T.Red,
                                TextColor3 = Color3.new(1, 1, 1),
                                Text = "Lepas",
                                _radius = 8,
                        }).Activated:Connect(function()
                                local res = Remotes.get("Equip"):InvokeServer(kind, "")
                                self:handleResult(res)
                        end)
                end
        end
end

--------------------------------------------------------------------
-- PANEL CRAFT (v3): stasiun tempa / dapur
--------------------------------------------------------------------

function UIController:buildCraftPanel()
        local frame = self:panelFrame("Craft", 0.5, 0.64)
        Util.create("TextLabel", {
                Name = "Judul",
                Size = UDim2.new(1, -60, 0, 36),
                Position = UDim2.fromOffset(18, 10),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = Color3.fromRGB(255, 150, 90),
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "Stasiun Kerja",
        }, frame)
        btn({
                parent = frame,
                Name = "Tutup",
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -12, 0, 10),
                Size = UDim2.fromOffset(40, 34),
                BackgroundColor3 = T.Red,
                TextColor3 = Color3.new(1, 1, 1),
                Text = "X",
                _radius = 8,
        }).Activated:Connect(function()
                self:showPanel(nil)
        end)

        local scroll = Util.create("ScrollingFrame", {
                Name = "List",
                Position = UDim2.fromOffset(18, 54),
                Size = UDim2.new(1, -36, 1, -72),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                CanvasSize = UDim2.new(),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 6,
        }, frame)
        Util.create("UIListLayout", { Padding = UDim.new(0, 8) }, scroll)
        self.craftList = scroll
end

local function countBag(s: any, id: string): number
        return (s and s.Bag and s.Bag[id]) or 0
end

function UIController:renderCraft()
        local s = self.state
        local list = self.craftList
        for _, child in list:GetChildren() do
                if child:IsA("Frame") then
                        child:Destroy()
                end
        end
        if not s then
                return
        end

        local judul = self.gui:FindFirstChild("Craft") and self.gui.Craft:FindFirstChild("Judul") :: TextLabel?
        local titles = { tempa = "Pandai Besi - Pak Tempa", dapur = "Dapur Alam - Bu Masak" }
        if judul then
                judul.Text = titles[self.craftStation] or "Stasiun Kerja"
        end

        for _, recipe in ipairs(Balance.Recipes) do
                if recipe.station ~= self.craftStation then
                        continue
                end
                local outName = recipe.out
                local count = 0
                if recipe.kind == "equip" then
                        for _, eq in ipairs(Balance.Equipment) do
                                if eq.id == recipe.out then
                                        outName = eq.name .. " (" .. (recipe.station == "tempa" and "Senjata" or "Zirah") .. ")"
                                        count = s.Equips[eq.id] or 0
                                        break
                                end
                        end
                elseif recipe.kind == "use" then
                        for _, u in ipairs(Balance.Usables) do
                                if u.id == recipe.out then
                                        outName = u.name
                                        count = s.Usables[u.id] or 0
                                        break
                                end
                        end
                end
                -- cek bahan
                local canCraft = s.Level >= recipe.level
                local mats = {}
                for matId, need in pairs(recipe.recipe) do
                        local have = countBag(s, matId)
                        if have < need then
                                canCraft = false
                        end
                        table.insert(mats, matId .. " " .. have .. "/" .. need)
                end
                table.sort(mats)

                local r = row(list, 72)
                Util.create("TextLabel", {
                        Position = UDim2.fromOffset(12, 6),
                        Size = UDim2.new(1, -140, 0, 28),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextScaled = true,
                        TextColor3 = T.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = outName .. (count > 0 and "  x" .. count or ""),
                }, r)
                Util.create("TextLabel", {
                        Position = UDim2.fromOffset(12, 36),
                        Size = UDim2.new(1, -140, 0, 28),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.Gotham,
                        TextScaled = true,
                        TextColor3 = canCraft and T.Green or T.TextDim,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = "Bahan: " .. table.concat(mats, ", ") .. " | Lv " .. recipe.level .. " | +" .. recipe.xp .. " XP",
                }, r)
                btn({
                        parent = r,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -8, 0, 16),
                        Size = UDim2.fromOffset(96, 40),
                        BackgroundColor3 = canCraft and T.Gold or T.Disabled,
                        TextColor3 = canCraft and Color3.fromRGB(40, 30, 10) or T.Text,
                        Text = canCraft and "Buat" or "Lv " .. recipe.level,
                        _radius = 8,
                }).Activated:Connect(function()
                        local res = Remotes.get("Craft"):InvokeServer(recipe.id)
                        self:handleResult(res)
                end)
        end
end

--------------------------------------------------------------------
-- PANEL TUGAS (v3): papan tugas harian
--------------------------------------------------------------------

function UIController:buildQuestPanel()
        local frame = self:panelFrame("Quest", 0.46, 0.62)
        Util.create("TextLabel", {
                Name = "Judul",
                Size = UDim2.new(1, -60, 0, 36),
                Position = UDim2.fromOffset(18, 10),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = T.Green,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "Papan Tugas Harian",
        }, frame)
        btn({
                parent = frame,
                Name = "Tutup",
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -12, 0, 10),
                Size = UDim2.fromOffset(40, 34),
                BackgroundColor3 = T.Red,
                TextColor3 = Color3.new(1, 1, 1),
                Text = "X",
                _radius = 8,
        }).Activated:Connect(function()
                self:showPanel(nil)
        end)

        local scroll = Util.create("ScrollingFrame", {
                Name = "List",
                Position = UDim2.fromOffset(18, 54),
                Size = UDim2.new(1, -36, 1, -72),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                CanvasSize = UDim2.new(),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 6,
        }, frame)
        Util.create("UIListLayout", { Padding = UDim.new(0, 8) }, scroll)
        self.questList = scroll
end

function UIController:renderQuest()
        local s = self.state
        local list = self.questList
        for _, child in list:GetChildren() do
                if child:IsA("Frame") then
                        child:Destroy()
                end
        end
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
                        local r = row(list, 88)
                        r.BackgroundColor3 = q.done and Color3.fromRGB(40, 70, 50) or T.PanelLight
                        Util.create("TextLabel", {
                                Position = UDim2.fromOffset(12, 6),
                                Size = UDim2.new(1, -130, 0, 28),
                                BackgroundTransparency = 1,
                                Font = Enum.Font.GothamBold,
                                TextScaled = true,
                                TextColor3 = T.Gold,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Text = "AKTIF: " .. def.title .. (q.done and "  [SELESAI]" or ""),
                        }, r)
                        Util.create("TextLabel", {
                                Position = UDim2.fromOffset(12, 34),
                                Size = UDim2.new(1, -130, 0, 24),
                                BackgroundTransparency = 1,
                                Font = Enum.Font.Gotham,
                                TextScaled = true,
                                TextColor3 = T.Text,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Text = def.desc .. " - " .. math.min(q.prog, def.goal.count) .. "/" .. def.goal.count
                                        .. " | hadiah " .. def.reward.coins .. " koin +" .. def.reward.xp .. " XP",
                        }, r)
                        if q.done then
                                btn({
                                        parent = r,
                                        AnchorPoint = Vector2.new(1, 0),
                                        Position = UDim2.new(1, -8, 0, 24),
                                        Size = UDim2.fromOffset(110, 40),
                                        BackgroundColor3 = T.Gold,
                                        TextColor3 = Color3.fromRGB(40, 30, 10),
                                        Text = "Klaim",
                                        _radius = 8,
                                }).Activated:Connect(function()
                                        local res = Remotes.get("QuestAction"):InvokeServer("claim")
                                        self:handleResult(res)
                                end)
                        end
                end
        end

        -- penawaran hari ini
        local offered = Balance.todayQuestIds()
        for _, id in offered do
                if q and q.id == id then
                        continue
                end
                local def = nil
                for _, d in ipairs(Balance.Quests) do
                        if d.id == id then
                                def = d
                                break
                        end
                end
                if def then
                        local locked = q and q.id ~= "" and not q.done
                        local r = row(list, 80)
                        Util.create("TextLabel", {
                                Position = UDim2.fromOffset(12, 6),
                                Size = UDim2.new(1, -130, 0, 28),
                                BackgroundTransparency = 1,
                                Font = Enum.Font.GothamBold,
                                TextScaled = true,
                                TextColor3 = T.Text,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Text = def.title,
                        }, r)
                        Util.create("TextLabel", {
                                Position = UDim2.fromOffset(12, 34),
                                Size = UDim2.new(1, -130, 0, 38),
                                BackgroundTransparency = 1,
                                Font = Enum.Font.Gotham,
                                TextScaled = true,
                                TextColor3 = T.TextDim,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Text = def.desc .. " | hadiah " .. def.reward.coins .. " koin +" .. def.reward.xp .. " XP",
                        }, r)
                        btn({
                                parent = r,
                                AnchorPoint = Vector2.new(1, 0),
                                Position = UDim2.new(1, -8, 0, 20),
                                Size = UDim2.fromOffset(110, 40),
                                BackgroundColor3 = locked and T.Disabled or T.Green,
                                TextColor3 = locked and T.Text or Color3.fromRGB(24, 30, 26),
                                Text = locked and "Selesaikan yang aktif" or "Terima",
                                _radius = 8,
                        }).Activated:Connect(function()
                                local res = Remotes.get("QuestAction"):InvokeServer("accept", def.id)
                                self:handleResult(res)
                        end)
                end
        end
end

--------------------------------------------------------------------
-- PANEL DAGANG (v3): undang partner + sesi tukar barang
--------------------------------------------------------------------

function UIController:buildTradePanel()
        local frame = self:panelFrame("Trade", 0.56, 0.7)
        Util.create("TextLabel", {
                Name = "Judul",
                Size = UDim2.new(1, -60, 0, 36),
                Position = UDim2.fromOffset(18, 10),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = Color3.fromRGB(224, 140, 190),
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "Dagang Pemain",
        }, frame)
        btn({
                parent = frame,
                Name = "Tutup",
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -12, 0, 10),
                Size = UDim2.fromOffset(40, 34),
                BackgroundColor3 = T.Red,
                TextColor3 = Color3.new(1, 1, 1),
                Text = "X",
                _radius = 8,
        }).Activated:Connect(function()
                self:showPanel(nil)
        end)

        local scroll = Util.create("ScrollingFrame", {
                Name = "List",
                Position = UDim2.fromOffset(18, 54),
                Size = UDim2.new(1, -36, 1, -72),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                CanvasSize = UDim2.new(),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 6,
        }, frame)
        Util.create("UIListLayout", { Padding = UDim.new(0, 8) }, scroll)
        self.tradeList = scroll
end

local function itemNameOf(kind: string, id: string): string
        local lookups = { crop = Config.Crops, bag = Config.Resources, fish = Config.Fish }
        for _, def in ipairs(lookups[kind] or {}) do
                if def.id == id then
                        return def.name
                end
        end
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
        end
        return id
end

function UIController:renderTrade()
        local s = self.state
        local list = self.tradeList
        for _, child in list:GetChildren() do
                if child:IsA("Frame") then
                        child:Destroy()
                end
        end

        -- undangan masuk
        if self.inviteFrom then
                local r = row(list, 60)
                r.BackgroundColor3 = Color3.fromRGB(50, 40, 60)
                Util.create("TextLabel", {
                        Position = UDim2.fromOffset(12, 8),
                        Size = UDim2.new(1, -230, 0, 44),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextScaled = true,
                        TextColor3 = T.Gold,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = "Undangan dagang dari " .. self.inviteFrom .. "!",
                }, r)
                btn({
                        parent = r,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -100, 0, 12),
                        Size = UDim2.fromOffset(88, 36),
                        BackgroundColor3 = T.Green,
                        TextColor3 = Color3.fromRGB(24, 30, 26),
                        Text = "Terima",
                        _radius = 8,
                }).Activated:Connect(function()
                        local res = Remotes.get("TradeAction"):InvokeServer({ action = "accept", from = self.inviteFrom })
                        self:handleResult(res)
                end)
                btn({
                        parent = r,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -8, 0, 12),
                        Size = UDim2.fromOffset(80, 36),
                        BackgroundColor3 = T.Red,
                        TextColor3 = Color3.new(1, 1, 1),
                        Text = "Tolak",
                        _radius = 8,
                }).Activated:Connect(function()
                        local res = Remotes.get("TradeAction"):InvokeServer({ action = "decline" })
                        self.inviteFrom = nil
                        self:handleResult(res)
                        self:renderTrade()
                end)
        end

        -- sesi dagang aktif
        if self.tradeSnap then
                local snap = self.tradeSnap
                -- dua kolom ringkas
                local header = row(list, 40)
                Util.create("TextLabel", {
                        Position = UDim2.fromOffset(12, 6),
                        Size = UDim2.fromScale(0.5, 1),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBlack,
                        TextScaled = true,
                        TextColor3 = T.Gold,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = "TAWARANMU" .. (snap.me.ready and "  [SIAP]" or ""),
                }, header)
                Util.create("TextLabel", {
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -12, 0, 6),
                        Size = UDim2.fromScale(0.5, 1),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBlack,
                        TextScaled = true,
                        TextColor3 = T.Blue,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Text = (snap.partner.name or "?") .. (snap.partner.ready and "  [SIAP]" or ""),
                }, header)

                -- barangmu
                local offeredAny = false
                for kind, items in pairs(snap.me.items) do
                        for id, count in pairs(items) do
                                if count > 0 then
                                        offeredAny = true
                                        local r2 = row(list, 52)
                                        Util.create("TextLabel", {
                                                Position = UDim2.fromOffset(12, 8),
                                                Size = UDim2.new(1, -110, 0, 36),
                                                BackgroundTransparency = 1,
                                                Font = Enum.Font.Gotham,
                                                TextScaled = true,
                                                TextColor3 = T.Text,
                                                TextXAlignment = Enum.TextXAlignment.Left,
                                                Text = "Kamu tawar: " .. itemNameOf(kind, id) .. " x" .. count,
                                        }, r2)
                                        btn({
                                                parent = r2,
                                                AnchorPoint = Vector2.new(1, 0),
                                                Position = UDim2.new(1, -8, 0, 8),
                                                Size = UDim2.fromOffset(92, 34),
                                                BackgroundColor3 = T.Red,
                                                TextColor3 = Color3.new(1, 1, 1),
                                                Text = "Batal",
                                                _radius = 8,
                                        }).Activated:Connect(function()
                                                local res = Remotes.get("TradeAction"):InvokeServer({ action = "offer", kind = kind, id = id, count = 0 })
                                                self:handleResult(res)
                                        end)
                                end
                        end
                end
                -- barang partner
                for kind, items in pairs(snap.partner.items) do
                        for id, count in pairs(items) do
                                if count > 0 then
                                        local r2 = row(list, 52)
                                        Util.create("TextLabel", {
                                                Position = UDim2.fromOffset(12, 8),
                                                Size = UDim2.fromScale(1, 1),
                                                BackgroundTransparency = 1,
                                                Font = Enum.Font.Gotham,
                                                TextScaled = true,
                                                TextColor3 = T.Blue,
                                                TextXAlignment = Enum.TextXAlignment.Left,
                                                Text = (snap.partner.name or "?") .. " tawar: " .. itemNameOf(kind, id) .. " x" .. count,
                                        }, r2)
                                end
                        end
                end
                -- koin
                local coinRow = row(list, 56)
                Util.create("TextLabel", {
                        Position = UDim2.fromOffset(12, 8),
                        Size = UDim2.new(0.5, 0, 0, 40),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextScaled = true,
                        TextColor3 = T.Gold,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = "Koinmu: " .. Util.formatNumber(snap.me.coins or 0),
                }, coinRow)
                Util.create("TextLabel", {
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -12, 0, 8),
                        Size = UDim2.new(0.5, 0, 0, 40),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextScaled = true,
                        TextColor3 = T.Blue,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Text = "Koin lawan: " .. Util.formatNumber(snap.partner.coins or 0),
                }, coinRow)
                local coinInput = Util.create("TextBox", {
                        Position = UDim2.fromOffset(12, 8),
                        Size = UDim2.fromOffset(120, 40),
                        BackgroundColor3 = T.PanelLight,
                        TextColor3 = T.Text,
                        Font = Enum.Font.GothamBold,
                        TextScaled = true,
                        PlaceholderText = "koin...",
                        ClearTextOnFocus = true,
                        Text = "",
                }, coinRow)
                corner(coinInput, 8)
                coinInput.FocusLost:Connect(function()
                        local amount = tonumber(coinInput.Text)
                        if amount and amount > 0 then
                                local res = Remotes.get("TradeAction"):InvokeServer({ action = "coin", amount = math.floor(amount) })
                                self:handleResult(res)
                        end
                end)

                -- inventaris tersedia untuk ditawarkan
                Util.create("TextLabel", {
                        Size = UDim2.new(1, -8, 0, 28),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextScaled = true,
                        TextColor3 = T.TextDim,
                        Text = "TAWARKAN DARI TASMU:",
                }, list)
                if s then
                        local invSections = {
                                { kind = "crop", data = s.Crops, lookup = Config.Crops },
                                { kind = "bag", data = s.Bag, lookup = Config.Resources },
                                { kind = "fish", data = s.Fish, lookup = Config.Fish },
                                { kind = "equip", data = s.Equips, lookup = nil },
                                { kind = "use", data = s.Usables, lookup = nil },
                        }
                        for _, section in invSections do
                                for id, count in section.data do
                                        if count <= 0 then
                                                continue
                                        end
                                        local name = section.lookup and nil or nil
                                        if section.lookup then
                                                for _, d in ipairs(section.lookup) do
                                                        if d.id == id then
                                                                name = d.name
                                                                break
                                                        end
                                                end
                                        else
                                                name = itemNameOf(section.kind, id)
                                        end
                                        if name then
                                                local r2 = row(list, 52)
                                                Util.create("TextLabel", {
                                                        Position = UDim2.fromOffset(12, 8),
                                                        Size = UDim2.new(1, -200, 0, 36),
                                                        BackgroundTransparency = 1,
                                                        Font = Enum.Font.Gotham,
                                                        TextScaled = true,
                                                        TextColor3 = T.Text,
                                                        TextXAlignment = Enum.TextXAlignment.Left,
                                                        Text = name .. " x" .. count,
                                                }, r2)
                                                btn({
                                                        parent = r2,
                                                        AnchorPoint = Vector2.new(1, 0),
                                                        Position = UDim2.new(1, -8, 0, 8),
                                                        Size = UDim2.fromOffset(180, 34),
                                                        BackgroundColor3 = T.Gold,
                                                        TextColor3 = Color3.fromRGB(40, 30, 10),
                                                        Text = "Tawar Semua",
                                                        _radius = 8,
                                                }).Activated:Connect(function()
                                                        local res = Remotes.get("TradeAction"):InvokeServer({ action = "offer", kind = section.kind, id = id, count = count })
                                                        self:handleResult(res)
                                                end)
                                        end
                                end
                        end
                end

                -- tombol aksi sesi
                local actionRow = row(list, 60)
                local readyBtn = btn({
                        parent = actionRow,
                        Position = UDim2.fromOffset(12, 12),
                        Size = UDim2.fromOffset(170, 36),
                        BackgroundColor3 = snap.me.ready and T.Green or T.PanelLight,
                        TextColor3 = Color3.fromRGB(24, 30, 26),
                        Text = snap.me.ready and "SIAP (batal)" or "SIAP",
                        _radius = 8,
                })
                readyBtn.Activated:Connect(function()
                        local res = Remotes.get("TradeAction"):InvokeServer({ action = "ready", value = not snap.me.ready })
                        self:handleResult(res)
                end)
                local cancelBtn = btn({
                        parent = actionRow,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -12, 0, 12),
                        Size = UDim2.fromOffset(170, 36),
                        BackgroundColor3 = T.Red,
                        TextColor3 = Color3.new(1, 1, 1),
                        Text = "Batalkan Dagang",
                        _radius = 8,
                })
                cancelBtn.Activated:Connect(function()
                        local res = Remotes.get("TradeAction"):InvokeServer({ action = "cancel" })
                        self:handleResult(res)
                        self.tradeSnap = nil
                        self:renderTrade()
                end)
                return
        end

        -- daftar pemain untuk mengundang
        Util.create("TextLabel", {
                Size = UDim2.new(1, -8, 0, 30),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextScaled = true,
                TextColor3 = T.TextDim,
                Text = "Pemain di server ini (dekati untuk mengundang):",
        }, list)
        for _, other in Players:GetPlayers() do
                if other ~= player then
                        local r = row(list, 56)
                        Util.create("TextLabel", {
                                Position = UDim2.fromOffset(12, 8),
                                Size = UDim2.new(1, -120, 0, 40),
                                BackgroundTransparency = 1,
                                Font = Enum.Font.GothamBold,
                                TextScaled = true,
                                TextColor3 = T.Text,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Text = other.DisplayName,
                        }, r)
                        btn({
                                parent = r,
                                AnchorPoint = Vector2.new(1, 0),
                                Position = UDim2.new(1, -8, 0, 10),
                                Size = UDim2.fromOffset(100, 36),
                                BackgroundColor3 = T.Gold,
                                TextColor3 = Color3.fromRGB(40, 30, 10),
                                Text = "Undang",
                                _radius = 8,
                        }).Activated:Connect(function()
                                local res = Remotes.get("TradeAction"):InvokeServer({ action = "invite", target = other.Name })
                                self:handleResult(res)
                        end)
                end
        end
end

return UIController'''

assert src.rstrip().endswith("return UIController"), "file must end with return UIController"
idx = src.rstrip().rfind("return UIController")
src = src[:idx] + NEW + "\n"
open(PATH, "w").write(src)
print("patch part 3 OK")
