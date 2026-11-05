--!nonstrict
--[[
        UIController.luau - seluruh UI Dunia Akiomida (dibangun lewat kode):
          - HUD XP/koin/streak + chip zona saat menjelajah
          - panel cerita NPC -> kuis pilihan ganda + feedback edukatif
          - panel Bahasan (baca materi) + papan penjelajah + kode penjelajah
          - toast notifikasi
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local LessonData = require(ReplicatedStorage.Shared.LessonData)
local Remotes = require(ReplicatedStorage.Remotes)
local Util = require(ReplicatedStorage.Shared.Util)

local UIController = {}
UIController.__index = UIController

local T = {
        Bg = Color3.fromRGB(16, 19, 28),
        Panel = Color3.fromRGB(30, 34, 48),
        PanelLight = Color3.fromRGB(44, 49, 66),
        Gold = Color3.fromRGB(255, 209, 102),
        Green = Color3.fromRGB(88, 200, 130),
        Red = Color3.fromRGB(235, 100, 100),
        Blue = Color3.fromRGB(99, 200, 255),
        Text = Color3.fromRGB(238, 238, 246),
        TextDim = Color3.fromRGB(165, 170, 185),
        Disabled = Color3.fromRGB(70, 74, 88),
}

local player = Players.LocalPlayer

local function corner(parent, radius)
        return Util.create("UICorner", { CornerRadius = UDim.new(0, radius or 10) }, parent)
end

local function makeSound()
        return Util.create("Sound", {
                SoundId = "rbxasset://sounds/electronicpingshort.wav",
                Volume = 0.35,
        }, SoundService)
end

function UIController.new()
        local self = setmetatable({}, UIController)
        self.state = nil
        self.zoneIndex = 0
        self.sound = makeSound()

        self:buildRoot()
        self:buildHUD()
        self:buildZoneChip()
        self:buildDialog()
        self:buildQuiz()
        self:buildBahasan()
        self:buildLeaderboardPanel()
        self:buildDevPanel()
        self:buildNotify()
        self:wire()

        return self
end

--------------------------------------------------------------------
-- ROOT & HUD
--------------------------------------------------------------------

function UIController:buildRoot()
        self.gui = Util.create("ScreenGui", {
                Name = "AkiomidaUI",
                ResetOnSpawn = false,
                IgnoreGuiInset = true,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        }, player:WaitForChild("PlayerGui"))
end

function UIController:buildHUD()
        local panel = Util.create("Frame", {
                Position = UDim2.new(0, 14, 0, 12),
                Size = UDim2.new(0, 300, 0, 40),
                BackgroundColor3 = T.Panel,
                Parent = self.gui,
        })
        corner(panel, 12)
        Util.create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 12),
                VerticalAlignment = Enum.VerticalAlignment.Center,
        }, panel)
        local function chip(text0: string, color: Color3)
                local l = Util.create("TextLabel", {
                        Size = UDim2.new(0, 92, 0, 26),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        Text = text0,
                        TextSize = 15,
                        TextColor3 = color,
                        Parent = panel,
                })
                return l
        end
        self.xpLabel = chip("XP 0", T.Gold)
        self.coinLabel = chip("Koin 0", T.Blue)
        self.streakLabel = chip("Runtun 0", T.Green)

        local lbBtn = Util.create("TextButton", {
                Position = UDim2.new(1, -134, 0, 12),
                Size = UDim2.new(0, 120, 0, 40),
                BackgroundColor3 = T.Panel,
                Font = Enum.Font.GothamBlack,
                Text = "PAPAN XP",
                TextSize = 16,
                TextColor3 = T.Text,
                Parent = self.gui,
        })
        corner(lbBtn, 12)
        lbBtn.Activated:Connect(function()
                self:setLBOpen(not self.lbOpen)
        end)

        local devBtn = Util.create("TextButton", {
                Position = UDim2.new(1, -168, 0, 12),
                Size = UDim2.new(0, 30, 0, 40),
                BackgroundColor3 = T.Panel,
                Font = Enum.Font.GothamBlack,
                Text = "*",
                TextSize = 22,
                TextColor3 = T.TextDim,
                Parent = self.gui,
        })
        corner(devBtn, 12)
        devBtn.Activated:Connect(function()
                self.devFrame.Visible = not self.devFrame.Visible
        end)
end

function UIController:buildZoneChip()
        local chip = Util.create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(0.5, 0, 0, 12),
                Size = UDim2.new(0, 320, 0, 56),
                BackgroundColor3 = T.Bg,
                BackgroundTransparency = 0.1,
                Parent = self.gui,
        })
        corner(chip, 14)
        Util.create("UIStroke", { Color = T.PanelLight, Thickness = 2 }, chip)
        self.zoneChip = chip

        self.zoneName = Util.create("TextLabel", {
                Position = UDim2.new(0, 12, 0, 8),
                Size = UDim2.new(1, -24, 0, 22),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                Text = "",
                TextScaled = true,
                TextColor3 = T.Text,
                Parent = chip,
        })
        self.zoneSlogan = Util.create("TextLabel", {
                Position = UDim2.new(0, 12, 0, 32),
                Size = UDim2.new(1, -24, 0, 16),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = "",
                TextScaled = true,
                TextColor3 = T.TextDim,
                Parent = chip,
        })
        self.zoneProgress = Util.create("TextLabel", {
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -10, 0, 8),
                Size = UDim2.new(0, 80, 0, 16),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = "",
                TextSize = 13,
                TextColor3 = T.Gold,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = chip,
        })
end

--------------------------------------------------------------------
-- DIALOG CERITA NPC
--------------------------------------------------------------------

function UIController:buildDialog()
        local frame = Util.create("Frame", {
                Visible = false,
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.new(0.5, 0, 1, -20),
                Size = UDim2.new(0, 520, 0, 190),
                BackgroundColor3 = T.Bg,
                BackgroundTransparency = 0.05,
                Parent = self.gui,
        })
        corner(frame, 16)
        Util.create("UIStroke", { Color = T.PanelLight, Thickness = 2 }, frame)
        self.dialogFrame = frame

        self.dlgName = Util.create("TextLabel", {
                Position = UDim2.new(0, 16, 0, 10),
                Size = UDim2.new(1, -32, 0, 22),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                Text = "NPC",
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 18,
                TextColor3 = T.Gold,
                Parent = frame,
        })
        self.dlgText = Util.create("TextLabel", {
                Position = UDim2.new(0, 16, 0, 38),
                Size = UDim2.new(1, -32, 0, 96),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = "",
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextSize = 16,
                TextColor3 = T.Text,
                Parent = frame,
        })
        local nextBtn = Util.create("TextButton", {
                AnchorPoint = Vector2.new(1, 1),
                Position = UDim2.new(1, -14, 1, -12),
                Size = UDim2.new(0, 140, 0, 34),
                BackgroundColor3 = T.Blue,
                Font = Enum.Font.GothamBlack,
                Text = "Lanjut",
                TextSize = 15,
                TextColor3 = T.Text,
                Parent = frame,
        })
        corner(nextBtn, 10)
        nextBtn.Activated:Connect(function()
                self:advanceDialog()
        end)
        self.dlgNext = nextBtn

        local closeBtn = Util.create("TextButton", {
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(0, 14, 1, -12),
                Size = UDim2.new(0, 90, 0, 34),
                BackgroundColor3 = T.PanelLight,
                Font = Enum.Font.GothamBold,
                Text = "Tutup",
                TextSize = 14,
                TextColor3 = T.TextDim,
                Parent = frame,
        })
        corner(closeBtn, 10)
        closeBtn.Activated:Connect(function()
                self.dialogFrame.Visible = false
        end)
end

function UIController:openStory(zoneIndex: number)
        task.spawn(function()
                local ok, story = pcall(function()
                        return Remotes.get("RequestStory"):InvokeServer(zoneIndex)
                end)
                if not ok or not story then
                        return
                end
                if story.locked then
                        self:toast("Zona Terkunci", "Kuasai zona sebelumnya dulu, penjelajah!")
                        return
                end
                self.story = { zone = zoneIndex, pages = story.pages, page = 1 }
                self.dlgName.Text = story.npc
                self.dialogFrame.Visible = true
                self:showStoryPage()
        end)
end

function UIController:showStoryPage()
        local story = self.story
        if not story then
                return
        end
        self.dlgText.Text = story.pages[story.page]
        self.dlgNext.Text = story.page >= #story.pages and "Mulai Tantangan!" or "Lanjut"
end

function UIController:advanceDialog()
        local story = self.story
        if not story then
                return
        end
        if story.page < #story.pages then
                story.page += 1
                self:showStoryPage()
        else
                self.dialogFrame.Visible = false
                self:startQuiz(story.zone)
        end
end

--------------------------------------------------------------------
-- KUIS
--------------------------------------------------------------------

function UIController:buildQuiz()
        local frame = Util.create("Frame", {
                Visible = false,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.new(0, 560, 0, 360),
                BackgroundColor3 = T.Bg,
                BackgroundTransparency = 0.04,
                Parent = self.gui,
        })
        corner(frame, 18)
        Util.create("UIStroke", { Color = T.PanelLight, Thickness = 2 }, frame)
        self.quizFrame = frame

        self.quizTitle = Util.create("TextLabel", {
                Position = UDim2.new(0, 16, 0, 12),
                Size = UDim2.new(1, -32, 0, 22),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                Text = "TANTANGAN",
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 17,
                TextColor3 = T.Gold,
                Parent = frame,
        })

        self.quizQuestion = Util.create("TextLabel", {
                Position = UDim2.new(0, 16, 0, 44),
                Size = UDim2.new(1, -32, 0, 64),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = "",
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextSize = 18,
                TextColor3 = T.Text,
                Parent = frame,
        })

        self.quizFeedback = Util.create("TextLabel", {
                Position = UDim2.new(0, 16, 1, -56),
                Size = UDim2.new(1, -32, 0, 44),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = "",
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 15,
                TextColor3 = T.TextDim,
                Parent = frame,
        })

        self.optionButtons = {}
        for i = 1, 3 do
                local btn = Util.create("TextButton", {
                        Position = UDim2.new(0, 16, 0, 118 + (i - 1) * 52),
                        Size = UDim2.new(1, -32, 0, 44),
                        BackgroundColor3 = T.PanelLight,
                        Font = Enum.Font.GothamBold,
                        Text = "",
                        TextSize = 17,
                        TextColor3 = T.Text,
                        Parent = frame,
                })
                corner(btn, 10)
                btn.Activated:Connect(function()
                        self:answer(i)
                end)
                self.optionButtons[i] = btn
        end
end

function UIController:startQuiz(zoneIndex: number)
        task.spawn(function()
                local ok, q = pcall(function()
                        return Remotes.get("StartQuiz"):InvokeServer(zoneIndex)
                end)
                if not ok or not q then
                        return
                end
                if q.locked then
                        self:toast("Zona Terkunci", "Kuasai zona sebelumnya dulu!")
                        return
                end
                self.activeQuiz = { qid = q.qid, zone = zoneIndex }
                local zone = Config.Zones[zoneIndex]
                self.quizTitle.Text = string.upper(zone.name) .. "  -  TANTANGAN " .. self:zoneCorrect(zoneIndex) .. "/" .. self:masteryTarget()
                self.quizQuestion.Text = q.t
                self.quizFeedback.Text = ""
                for i, btn in self.optionButtons do
                        btn.Text = q.opsi[i]
                        btn.BackgroundColor3 = T.PanelLight
                end
                self.quizFrame.Visible = true
        end)
end

function UIController:answer(choice: number)
        local quiz = self.activeQuiz
        if not quiz then
                return
        end
        task.spawn(function()
                local ok, result = pcall(function()
                        return Remotes.get("AnswerQuiz"):InvokeServer(quiz.qid, choice)
                end)
                if not ok or not result then
                        return
                end
                if result.expired then
                        self.quizFrame.Visible = false
                        self.activeQuiz = nil
                        self:toast("Soal kedaluwarsa", "Coba tantangan lagi ya!")
                        return
                end
                if result.correct then
                        self.sound.PlaybackSpeed = 1.1
                        self.sound:Play()
                        self.optionButtons[choice].BackgroundColor3 = T.Green
                        self.quizFeedback.TextColor3 = T.Green
                        if result.justMastered then
                                self.quizFeedback.Text = result.feedback .. "  ZONA DIKUASAI!"
                        else
                                self.quizFeedback.Text = result.feedback
                        end
                else
                        self.sound.PlaybackSpeed = 0.7
                        self.sound:Play()
                        self.quizFeedback.TextColor3 = T.TextDim
                        self.quizFeedback.Text = result.feedback
                end
                task.delay(1.6, function()
                        if self.quizFrame.Visible then
                                self.activeQuiz = nil
                                self.quizFrame.Visible = false
                                -- soal berikutnya otomatis kalau masih di depan NPC
                                if result.correct then
                                        self:startQuiz(quiz.zone)
                                end
                        end
                end)
        end)
end

--------------------------------------------------------------------
-- BAHASAN
--------------------------------------------------------------------

function UIController:buildBahasan()
        local frame = Util.create("Frame", {
                Visible = false,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.new(0, 520, 0, 380),
                BackgroundColor3 = T.Bg,
                BackgroundTransparency = 0.04,
                Parent = self.gui,
        })
        corner(frame, 18)
        Util.create("UIStroke", { Color = T.PanelLight, Thickness = 2 }, frame)
        self.bahasanFrame = frame

        self.bahasanTitle = Util.create("TextLabel", {
                Position = UDim2.new(0, 16, 0, 10),
                Size = UDim2.new(1, -60, 0, 24),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                Text = "BAHASAN",
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 18,
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
                TextSize = 15,
                TextColor3 = T.Text,
                Parent = frame,
        })
        corner(close, 8)
        close.Activated:Connect(function()
                self.bahasanFrame.Visible = false
        end)

        local scroll = Util.create("ScrollingFrame", {
                Position = UDim2.new(0, 12, 0, 44),
                Size = UDim2.new(1, -24, 1, -56),
                BackgroundTransparency = 1,
                ScrollBarThickness = 4,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                Parent = frame,
        })
        Util.create("UIListLayout", { Padding = UDim.new(0, 8) }, scroll)
        self.bahasanScroll = scroll
end

function UIController:openBahasan(zoneIndex: number)
        for _, child in self.bahasanScroll:GetChildren() do
                if child:IsA("Frame") then
                        child:Destroy()
                end
        end
        local zone = Config.Zones[zoneIndex]
        self.bahasanTitle.Text = "BAHASAN  -  " .. string.upper(zone.name)

        for i, lesson in LessonData.forZone(zoneIndex) do
                local read = self.state and self.state.Read and table.find(self.state.Read, lesson.id) ~= nil
                local row = Util.create("Frame", {
                        Size = UDim2.new(1, -8, 0, 76),
                        BackgroundColor3 = T.Panel,
                        Parent = self.bahasanScroll,
                })
                corner(row, 10)
                Util.create("TextLabel", {
                        Position = UDim2.new(0, 10, 0, 6),
                        Size = UDim2.new(1, -120, 0, 20),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        Text = lesson.title,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextSize = 15,
                        TextColor3 = read and T.Green or T.Text,
                        Parent = row,
                })
                Util.create("TextLabel", {
                        Position = UDim2.new(0, 10, 0, 27),
                        Size = UDim2.new(1, -120, 0, 44),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.Gotham,
                        Text = lesson.text,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        TextSize = 12,
                        TextColor3 = T.TextDim,
                        Parent = row,
                })
                local mark = Util.create("TextButton", {
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, -10, 0.5, 0),
                        Size = UDim2.new(0, 92, 0, 34),
                        BackgroundColor3 = read and T.Disabled or T.Green,
                        Font = Enum.Font.GothamBlack,
                        Text = read and "Dibaca" or "Tandai",
                        TextSize = 13,
                        TextColor3 = T.Text,
                        Parent = row,
                })
                corner(mark, 8)
                if not read then
                        mark.Activated:Connect(function()
                                task.spawn(function()
                                        local ok, res = pcall(function()
                                                return Remotes.get("ReadTopic"):InvokeServer(lesson.id)
                                        end)
                                        if ok and res and not res.already then
                                                self:toast("Bahasan dibaca", "+" .. (res.xp or 5) .. " XP. Makin dalam pemahamanmu!")
                                                mark.Text = "Dibaca"
                                                mark.BackgroundColor3 = T.Disabled
                                        end
                                end)
                        end)
                end
                row.LayoutOrder = i
        end
        self.bahasanFrame.Visible = true
end

--------------------------------------------------------------------
-- PAPAN XP + KODE DEV + NOTIFY
--------------------------------------------------------------------

function UIController:buildLeaderboardPanel()
        local frame = Util.create("Frame", {
                Visible = false,
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -14, 0, 60),
                Size = UDim2.new(0, 250, 0, 300),
                BackgroundColor3 = T.Bg,
                BackgroundTransparency = 0.06,
                Parent = self.gui,
        })
        corner(frame, 14)
        Util.create("UIStroke", { Color = T.PanelLight, Thickness = 2 }, frame)
        self.lbFrame = frame
        Util.create("TextLabel", {
                Position = UDim2.new(0, 12, 0, 8),
                Size = UDim2.new(1, -24, 0, 24),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                Text = "PENJELAJAH TERATAS",
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 14,
                TextColor3 = T.Gold,
                Parent = frame,
        })
        self.lbList = Util.create("Frame", {
                Position = UDim2.new(0, 12, 0, 38),
                Size = UDim2.new(1, -24, 1, -50),
                BackgroundTransparency = 1,
                Parent = frame,
        })
        Util.create("UIListLayout", { Padding = UDim.new(0, 4) }, self.lbList)
end

function UIController:buildDevPanel()
        local frame = Util.create("Frame", {
                Visible = false,
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -150, 0, 58),
                Size = UDim2.new(0, 240, 0, 96),
                BackgroundColor3 = T.Bg,
                BackgroundTransparency = 0.06,
                Parent = self.gui,
        })
        corner(frame, 12)
        Util.create("UIStroke", { Color = T.PanelLight, Thickness = 2 }, frame)
        self.devFrame = frame
        Util.create("TextLabel", {
                Position = UDim2.new(0, 10, 0, 6),
                Size = UDim2.new(1, -20, 0, 18),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = "Kode Penjelajah",
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 13,
                TextColor3 = T.TextDim,
                Parent = frame,
        })
        local input = Util.create("TextBox", {
                Position = UDim2.new(0, 10, 0, 28),
                Size = UDim2.new(1, -20, 0, 30),
                BackgroundColor3 = T.Panel,
                Font = Enum.Font.Gotham,
                Text = "",
                PlaceholderText = "Masukkan kode...",
                TextSize = 14,
                TextColor3 = T.Text,
                ClearTextOnFocus = false,
                Parent = frame,
        })
        corner(input, 8)
        local submit = Util.create("TextButton", {
                Position = UDim2.new(0, 10, 0, 64),
                Size = UDim2.new(1, -20, 0, 26),
                BackgroundColor3 = T.Blue,
                Font = Enum.Font.GothamBlack,
                Text = "Kirim",
                TextSize = 13,
                TextColor3 = T.Text,
                Parent = frame,
        })
        corner(submit, 8)
        submit.Activated:Connect(function()
                local code = input.Text
                task.spawn(function()
                        local ok, res = pcall(function()
                                return Remotes.get("RedeemDevCode"):InvokeServer(code)
                        end)
                        if ok and res == true then
                                input.Text = ""
                                self.devFrame.Visible = false
                        elseif ok then
                                self:toast("Kode", tostring(res))
                        end
                end)
        end)
end

function UIController:buildNotify()
        self.notifyFrame = Util.create("Frame", {
                AnchorPoint = Vector2.new(1, 1),
                Position = UDim2.new(1, -16, 1, -16),
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
-- LOGIKA
--------------------------------------------------------------------

function UIController:zoneCorrect(zoneIndex: number): number
        if not self.state then
                return 0
        end
        local zone = Config.Zones[zoneIndex]
        return self.state.Correct[zone.id] or 0
end

function UIController:masteryTarget(): number
        return self.state and self.state.MasteryTarget or 10
end

function UIController:setLBOpen(open: boolean)
        self.lbOpen = open
        self.lbFrame.Visible = open
        if open then
                self:refreshLB()
        end
end

function UIController:refreshLB()
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
                                Size = UDim2.new(1, 0, 0, 22),
                                BackgroundTransparency = 1,
                                Font = Enum.Font.Gotham,
                                Text = "Belum ada penjelajah - jadilah yang pertama!",
                                TextSize = 13,
                                TextColor3 = T.TextDim,
                                Parent = self.lbList,
                        })
                        return
                end
                for i, entry in rows do
                        Util.create("TextLabel", {
                                Size = UDim2.new(1, 0, 0, 22),
                                BackgroundTransparency = 1,
                                Font = Enum.Font.GothamBold,
                                Text = i .. ". " .. entry.name .. " - " .. Util.formatNumber(entry.value) .. " XP",
                                TextXAlignment = Enum.TextXAlignment.Left,
                                TextSize = 14,
                                TextColor3 = i <= 3 and T.Gold or T.Text,
                                Parent = self.lbList,
                        })
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
                local tween = TweenService:Create(card, TweenInfo.new(0.4), { BackgroundTransparency = 1 })
                tween:Play()
                tween.Completed:Wait()
                card:Destroy()
        end)
end

function UIController:detectZone()
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then
                return
        end
        local z = root.Position.Z
        local idx = math.floor((z - Config.World.StartZ + Config.World.ZoneSpacing / 2) / Config.World.ZoneSpacing) + 1
        idx = math.clamp(idx, 1, #Config.Zones)
        if idx ~= self.zoneIndex then
                self.zoneIndex = idx
                local zone = Config.Zones[idx]
                local color = Util.zoneColor(zone.color)
                self.zoneName.Text = zone.name
                self.zoneName.TextColor3 = color
                self.zoneSlogan.Text = zone.slogan
        end
        -- progres zona di chip
        if self.state then
                local zone = Config.Zones[self.zoneIndex]
                local done = self.state.Correct[zone.id] or 0
                local mastered = self.state.Mastered[zone.id]
                local unlocked = self.zoneIndex <= (self.state.Unlocked or 1)
                if not unlocked then
                        self.zoneProgress.Text = "TERKUNCI"
                        self.zoneProgress.TextColor3 = T.Red
                elseif mastered then
                        self.zoneProgress.Text = "DIKUASAI"
                        self.zoneProgress.TextColor3 = T.Green
                else
                        self.zoneProgress.Text = done .. "/" .. self:masteryTarget()
                        self.zoneProgress.TextColor3 = T.Gold
                end
        end
end

function UIController:applyState(state)
        self.state = state
        self.xpLabel.Text = "XP " .. Util.formatNumber(state.XP)
        self.coinLabel.Text = "Koin " .. Util.formatNumber(state.Coins)
        self.streakLabel.Text = "Runtun " .. tostring(state.Streak)
        if state.Dev then
                self.streakLabel.TextColor3 = T.Gold
        end
end

function UIController:wire()
        Remotes.get("StateSync").OnClientEvent:Connect(function(state)
                self:applyState(state)
        end)

        Remotes.get("Notify").OnClientEvent:Connect(function(title, message)
                self:toast(title, message)
        end)

        Remotes.get("ZoneEntered").OnClientEvent:Connect(function(info)
                if info.type == "npc" then
                        self:openStory(info.zone)
                elseif info.type == "board" then
                        self:openBahasan(info.zone)
                end
        end)

        task.spawn(function()
                while true do
                        task.wait(0.4)
                        self:detectZone()
                end
        end)

        task.spawn(function()
                while true do
                        task.wait(20)
                        if self.lbOpen then
                                self:refreshLB()
                        end
                end
        end)
end

return UIController
