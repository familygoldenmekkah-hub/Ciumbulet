local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropData = require(ReplicatedStorage.Shared.CropData)
local Net = require(ReplicatedStorage.Remotes)

local DataService = {}

local store = DataStoreService:GetDataStore("AKM_T1")
local cache: { [number]: any } = {}
local dirty: { [number]: boolean } = {}
local zoneProvider: ((Player) -> (string, string?))? = nil
local lahanProvider: ((Player) -> number?)? = nil

local function defaultData()
        return { m = CropData.StartMoney, t = {}, dev = false }
end

function DataService.setZoneProvider(fn)
        zoneProvider = fn
end

function DataService.setLahanProvider(fn)
        lahanProvider = fn
end

local function push(player: Player)
        local d = cache[player.UserId]
        if not d then
                return
        end
        local payload: any = { micda = math.floor(d.m), tas = d.t }
        if zoneProvider then
                local z, dn = zoneProvider(player)
                payload.zone = z
                payload.dunia = dn
        end
        if lahanProvider then
                payload.lahan = lahanProvider(player)
        end
        Net.get("Sync"):FireClient(player, payload)
        local ls = player:FindFirstChild("leaderstats")
        if ls then
                local v = ls:FindFirstChild("Micda")
                if v then
                        v.Value = math.floor(d.m)
                end
        end
end

function DataService.get(player: Player)
        return cache[player.UserId]
end

function DataService.markDirty(player: Player)
        dirty[player.UserId] = true
end

function DataService.push(player: Player)
        push(player)
end

function DataService.addMicda(player: Player, amount: number)
        local d = cache[player.UserId]
        if not d then
                return
        end
        d.m = math.max(0, d.m + amount)
        dirty[player.UserId] = true
        push(player)
end

function DataService.trySpend(player: Player, amount: number): boolean
        local d = cache[player.UserId]
        if not d then
                return false
        end
        if d.m < amount then
                return false
        end
        d.m -= amount
        dirty[player.UserId] = true
        push(player)
        return true
end

function DataService.load(player: Player): boolean
        local ok, data = pcall(function()
                return store:GetAsync("u_" .. player.UserId)
        end)
        if ok and type(data) == "table" and type(data.m) == "number" then
                cache[player.UserId] = {
                        m = data.m,
                        t = type(data.t) == "table" and data.t or {},
                        dev = data.dev == true,
                }
        elseif ok then
                cache[player.UserId] = defaultData()
        else
                cache[player.UserId] = defaultData()
                return false
        end
        dirty[player.UserId] = false
        push(player)
        return true
end

function DataService.save(player: Player)
        local d = cache[player.UserId]
        if not d or not dirty[player.UserId] then
                return
        end
        local ok = pcall(function()
                store:SetAsync("u_" .. player.UserId, { m = math.floor(d.m), t = d.t, dev = d.dev })
        end)
        if ok then
                dirty[player.UserId] = false
        end
end

function DataService.startLoops()
        task.spawn(function()
                while true do
                        task.wait(60)
                        for _, p in ipairs(Players:GetPlayers()) do
                                DataService.save(p)
                        end
                end
        end)
end

function DataService.drop(player: Player)
        cache[player.UserId] = nil
        dirty[player.UserId] = nil
end

return DataService
