--!nonstrict
--[[
        LeaderboardService.luau
        Global top-10 board by TotalEarned (OrderedDataStore):
          - uploads every online player's TotalEarned each refresh
          - reads the top 10 and renders them on physical boards (SurfaceGui)
          - serves the same rows to clients on request (RemoteFunction)
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Remotes)
local DataService = require(script.Parent.DataService)
local Util = require(ReplicatedStorage.Shared.Util)

local LeaderboardService = {}

local orderedStore = DataStoreService:GetOrderedDataStore(Config.Data.OrderedStoreName)
local lbRemote = Remotes.get("GetLeaderboard")

local latestRows: { { name: string, value: number } } = {}
local boards: { SurfaceGui } = {}

--------------------------------------------------------------------
-- BOARD CONSTRUCTION (procedural)
--------------------------------------------------------------------

local function buildBoard(position: Vector3, lookAt: Vector3): SurfaceGui
        local part = Instance.new("Part")
        part.Name = "GlobalLeaderboard"
        part.Size = Vector3.new(18, 11, 1)
        part.Anchored = true
        part.Material = Enum.Material.SmoothPlastic
        part.Color = Color3.fromRGB(25, 28, 38)
        part.CFrame = CFrame.lookAt(position, lookAt)
        part.Parent = workspace

        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Front
        gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        gui.PixelsPerStud = 50
        gui.Parent = part

        local title = Instance.new("TextLabel")
        title.Size = UDim2.fromScale(1, 0.16)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBlack
        title.TextScaled = true
        title.TextColor3 = Color3.fromRGB(255, 196, 37)
        title.Text = "TOP COIN EARNERS"
        title.Parent = gui

        local list = Instance.new("Frame")
        list.Position = UDim2.fromScale(0.05, 0.2)
        list.Size = UDim2.fromScale(0.9, 0.76)
        list.BackgroundTransparency = 1
        list.Parent = gui

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0.02, 0)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = list

        for i = 1, Config.Leaderboard.Size do
                local row = Instance.new("TextLabel")
                row.Name = "Row" .. i
                row.Size = UDim2.fromScale(1, 0.09)
                row.BackgroundTransparency = 1
                row.Font = Enum.Font.GothamBold
                row.TextXAlignment = Enum.TextXAlignment.Left
                row.TextScaled = true
                row.TextColor3 = Color3.fromRGB(230, 230, 240)
                row.Text = i .. ". -"
                row.Parent = list
                if i == 1 then
                        row.TextColor3 = Color3.fromRGB(255, 215, 0)
                elseif i == 2 then
                        row.TextColor3 = Color3.fromRGB(200, 200, 210)
                elseif i == 3 then
                        row.TextColor3 = Color3.fromRGB(205, 127, 50)
                end
        end

        table.insert(boards, gui)
        return gui
end

local function renderRows()
        for _, gui in boards do
                local list = gui:FindFirstChildOfClass("Frame")
                if not list then
                        continue
                end
                for i = 1, Config.Leaderboard.Size do
                        local row = list:FindFirstChild("Row" .. i)
                        if not row then
                                continue
                        end
                        local entry = latestRows[i]
                        if entry then
                                (row :: TextLabel).Text = i .. ". " .. entry.name .. " - " .. Util.formatNumber(entry.value)
                        else
                                (row :: TextLabel).Text = i .. ". -"
                        end
                end
        end
end

--------------------------------------------------------------------
-- REFRESH LOOP
--------------------------------------------------------------------

local function refresh()
        -- 1) Upload all online players
        for _, player in Players:GetPlayers() do
                if DataService.has(player) then
                        local data = DataService.get(player)
                        pcall(function()
                                orderedStore:SetAsync(tostring(player.UserId), math.floor(data.TotalEarned))
                        end)
                end
        end

        -- 2) Read top 10
        local ok, pages = pcall(function()
                return orderedStore:GetSortedAsync(false, Config.Leaderboard.Size)
        end)
        if not ok or not pages then
                return
        end
        local page = pages:GetCurrentPage()
        local rows: { { name: string, value: number } } = {}
        for rank, entry in page do
                local name = "Player " .. entry.key
                local lookup = Players:GetPlayerByUserId(tonumber(entry.key) or 0)
                if lookup then
                        name = lookup.DisplayName
                else
                        local okName, fetched = pcall(Players.GetNameFromUserIdAsync, Players, tonumber(entry.key) or 0)
                        if okName and fetched then
                                name = fetched
                        end
                end
                rows[rank] = { name = name, value = entry.value }
        end
        latestRows = rows
        renderRows()
end

--------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------

function LeaderboardService.init()
        lbRemote.OnServerInvoke = function()
                return latestRows
        end

        -- Two physical boards flanking the spawn area
        buildBoard(Vector3.new(-26, 10, 22), Vector3.new(0, 8, -10))
        buildBoard(Vector3.new(26, 10, 22), Vector3.new(0, 8, -10))

        task.spawn(function()
                -- first refresh soon, then periodically
                task.wait(5)
                while true do
                        refresh()
                        task.wait(Config.Leaderboard.RefreshInterval)
                end
        end)
end

return LeaderboardService
