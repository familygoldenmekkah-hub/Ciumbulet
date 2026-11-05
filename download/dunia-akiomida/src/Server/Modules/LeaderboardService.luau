local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Remotes)
local DataService = require(script.Parent.DataService)
local Util = require(ReplicatedStorage.Shared.Util)

local LeaderboardService = {}

local orderedStore = DataStoreService:GetOrderedDataStore(Config.Data.OrderedStoreName)
local latestRows: { { name: string, value: number } } = {}
local boards: { SurfaceGui } = {}

local function buildBoard(position: Vector3, lookAt: Vector3)
        local part = Util.create("Part", {
                Name = "PapanPenjelajah",
                Size = Vector3.new(16, 10, 1),
                Anchored = true,
                Material = Enum.Material.SmoothPlastic,
                Color = Color3.fromRGB(25, 28, 38),
                CFrame = CFrame.lookAt(position, lookAt),
        }, workspace)

        local gui = Util.create("SurfaceGui", {
                Face = Enum.NormalId.Front,
                SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
                PixelsPerStud = 50,
        }, part)

        Util.create("TextLabel", {
                Size = UDim2.fromScale(1, 0.18),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBlack,
                TextScaled = true,
                TextColor3 = Color3.fromRGB(255, 209, 102),
                Text = "PAPAN JUARA DUNIA (XP)",
        }, gui)

        local list = Util.create("Frame", {
                Position = UDim2.fromScale(0.05, 0.22),
                Size = UDim2.fromScale(0.9, 0.74),
                BackgroundTransparency = 1,
        }, gui)
        Util.create("UIListLayout", { Padding = UDim.new(0.02, 0) }, list)

        for i = 1, Config.Leaderboard.Size do
                Util.create("TextLabel", {
                        Name = "Row" .. i,
                        Size = UDim2.fromScale(1, 0.09),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextScaled = true,
                        TextColor3 = i == 1 and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(230, 230, 240),
                        Text = i .. ". -",
                }, list)
        end
        table.insert(boards, gui)
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
                        local rowLabel = row :: TextLabel
                        rowLabel.Text = entry and (i .. ". " .. entry.name .. " - " .. Util.formatNumber(entry.value) .. " XP")
                                or (i .. ". -")
                end
        end
end

local function refresh()
        for _, player in Players:GetPlayers() do
                if DataService.has(player) then
                        local data = DataService.get(player)
                        pcall(function()
                                orderedStore:SetAsync(tostring(player.UserId), math.floor(data.XP))
                        end)
                end
        end

        local ok, pages = pcall(function()
                return orderedStore:GetSortedAsync(false, Config.Leaderboard.Size)
        end)
        if not ok or not pages then
                return
        end
        local rows: { { name: string, value: number } } = {}
        for rank, entry in pages:GetCurrentPage() do
                local name = "Penjelajah " .. entry.key
                local online = Players:GetPlayerByUserId(tonumber(entry.key) or 0)
                if online then
                        name = online.DisplayName
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

function LeaderboardService.init()
        Remotes.get("GetLeaderboard").OnServerInvoke = function()
                return latestRows
        end

        buildBoard(Vector3.new(-14, 8, -14), Vector3.new(0, 7, 24))
        buildBoard(Vector3.new(14, 8, -14), Vector3.new(0, 7, 24))

        task.spawn(function()
                task.wait(5)
                while true do
                        refresh()
                        task.wait(Config.Leaderboard.RefreshInterval)
                end
        end)
end

return LeaderboardService
