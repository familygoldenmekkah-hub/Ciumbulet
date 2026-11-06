local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropData = require(ReplicatedStorage.Shared.CropData)
local Net = require(ReplicatedStorage.Remotes)
local UangLogic = require(ReplicatedStorage.Shared.UangLogic)
local SesiLogic = require(ReplicatedStorage.Shared.SesiLogic)

local DataService = {}

local store = DataStoreService:GetDataStore("AKM_T1")
local jobId = game.JobId ~= "" and game.JobId or "studio"
local cache: { [number]: any } = {}
local dirty: { [number]: boolean } = {}
local loadedOk: { [number]: boolean } = {}
local zoneProvider: ((Player) -> (string, string?))? = nil
local lahanProvider: ((Player) -> number?)? = nil

local function now(): number
        return os.time()
end

local function defaultData(): any
        return { u = UangLogic.baru(CropData.StartMoney), t = {}, dev = false }
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
        local payload: any = { micda = UangLogic.saldo(d.u), tas = d.t }
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
                        v.Value = UangLogic.saldo(d.u)
                end
        end
end

function DataService.get(player: Player)
        return cache[player.UserId]
end

function DataService.uangState(player: Player)
        local d = cache[player.UserId]
        return d and d.u or nil
end

function DataService.markDirty(player: Player)
        dirty[player.UserId] = true
end

function DataService.push(player: Player)
        push(player)
end

function DataService.bolehSimpan(player: Player): boolean
        return loadedOk[player.UserId] == true
end

local function ambilKunci(userId: number): boolean
        local ambil = false
        local ok = pcall(function()
                store:UpdateAsync("l_" .. tostring(userId), function(old)
                        if SesiLogic.bisaAmbil(old, jobId, now()) then
                                ambil = true
                                return SesiLogic.kunciBaru(jobId, now())
                        end
                        ambil = false
                        return old
                end)
        end)
        return ok and ambil
end

local function lepasKunci(userId: number)
        pcall(function()
                store:UpdateAsync("l_" .. tostring(userId), function(old)
                        if type(old) == "table" and old.j == jobId then
                                return SesiLogic.lepas(jobId)
                        end
                        return old
                end)
        end)
end

function DataService.load(player: Player): (boolean, string?)
        local userId = player.UserId
        local ok, data = pcall(function()
                return store:GetAsync("u_" .. tostring(userId))
        end)
        if not ok then
                cache[userId] = defaultData()
                loadedOk[userId] = false
                dirty[userId] = false
                push(player)
                return false, "galat"
        end
        if type(data) == "table" and type(data.m) == "number" and not data.u then
                data.u = UangLogic.baru(data.m)
        end
        if type(data) ~= "table" or type(data.u) ~= "table" or type(data.u.m) ~= "number" then
                data = { u = UangLogic.baru(CropData.StartMoney), t = {}, dev = false }
        end
        if not ambilKunci(userId) then
                cache[userId] = defaultData()
                loadedOk[userId] = false
                dirty[userId] = false
                push(player)
                return false, "kunci"
        end
        cache[userId] = {
                u = { m = data.u.m, ledger = type(data.u.ledger) == "table" and data.u.ledger or {}, tick = {} },
                t = type(data.t) == "table" and data.t or {},
                dev = data.dev == true,
        }
        loadedOk[userId] = true
        dirty[userId] = false
        push(player)
        return true, nil
end

local function simpanSekali(userId: number, d: any): boolean
        local hasil = false
        local ok = pcall(function()
                store:UpdateAsync("u_" .. tostring(userId), function()
                        hasil = true
                        return {
                                u = { m = UangLogic.saldo(d.u), ledger = d.u.ledger },
                                t = d.t,
                                dev = d.dev,
                        }
                end)
        end)
        return ok and hasil
end

function DataService.save(player: Player)
        local userId = player.UserId
        local d = cache[userId]
        if not d or not loadedOk[userId] or not dirty[userId] then
                return
        end
        for i = 1, 3 do
                if simpanSekali(userId, d) then
                        dirty[userId] = false
                        return
                end
                task.wait(0.4 * i)
        end
end

function DataService.startLoops()
        task.spawn(function()
                while true do
                        task.wait(75)
                        for _, p in ipairs(Players:GetPlayers()) do
                                DataService.save(p)
                        end
                end
        end)
end

function DataService.drop(player: Player)
        local userId = player.UserId
        if loadedOk[userId] then
                lepasKunci(userId)
        end
        cache[userId] = nil
        dirty[userId] = nil
        loadedOk[userId] = nil
end

return DataService
