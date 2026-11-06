local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropData = require(ReplicatedStorage.Shared.CropData)
local Layout = require(ReplicatedStorage.Shared.Layout)
local PanenStatus = require(ReplicatedStorage.Shared.PanenStatus)
local PukulLogic = require(ReplicatedStorage.Shared.PukulLogic)
local PlantModels = require(script.Parent.PlantModels)

local PlotService = {}

local Land, Net, World, Drop
local rng = Random.new()

local folders: { [number]: Folder } = {}
local planted: { [number]: { [number]: any } } = {}
local running: { [number]: boolean } = {}
local boards: { [number]: { TextLabel } } = {}
local combo: { [number]: { t: number, n: number } } = {}

function PlotService.bind(deps)
        Land = deps.Land
        Net = deps.Net
        World = deps.World
        Drop = deps.Drop
end

local function plotPos(index: number, idx: number): Vector3
        local o = Land.origin(index)
        local x, z = Layout.plotLocal(idx)
        return Vector3.new(o.X + x, 1.4, o.Z + z)
end

local function now(): number
        return Workspace:GetServerTimeNow()
end

local function payloadOf(index: number, idx: number): any
        local rec = planted[index] and planted[index][idx]
        local st = "kosong"
        local crop, readyAt
        if rec then
                crop = rec.crop
                readyAt = rec.readyAt
                st = now() >= rec.readyAt and "siap" or "tumbuh"
        end
        return {
                lahan = index,
                idx = idx,
                st = st,
                crop = crop,
                readyAt = readyAt,
        }
end

local function syncAll(index: number, idx: number)
        Net.get("PlotSync"):FireAllClients(payloadOf(index, idx))
end

local function pasangModel(index: number, idx: number, cropId: string): Model
        local model = PlantModels.buat(plotPos(index, idx), CropData.byId[cropId])
        model.Name = "Tanaman_" .. idx
        model:SetAttribute("PlotIdx", idx)
        model:SetAttribute("LahanIdx", index)
        model.Parent = folders[index]
        return model
end

function PlotService.buildGrid(index: number, parent: Instance?)
        if folders[index] then
                return
        end
        local root = parent or Workspace:FindFirstChild("Dunia")
        if not root then
                return
        end
        local folder = Instance.new("Folder")
        folder.Name = "PlotGrid_" .. index
        local o = Land.origin(index)
        local tmpl = Instance.new("Part")
        tmpl.Anchored = true
        tmpl.Size = Vector3.new(Layout.PlotSize, 0.4, Layout.PlotSize)
        tmpl.Color = Color3.fromRGB(96, 72, 48)
        tmpl.Material = Enum.Material.Ground
        tmpl.TopSurface = Enum.SurfaceType.Smooth
        for idx = 0, Layout.plotCount() - 1 do
                local p = tmpl:Clone()
                local x, z = Layout.plotLocal(idx)
                p.Position = Vector3.new(o.X + x, 1.2, o.Z + z)
                p:SetAttribute("LahanIdx", index)
                p:SetAttribute("PlotIdx", idx)
                p.Parent = folder
        end
        tmpl:Destroy()
        folder.Parent = root
        folders[index] = folder
        planted[index] = {}
end

function PlotService.clearGrid(index: number)
        running[index] = false
        planted[index] = nil
        if folders[index] then
                folders[index]:Destroy()
                folders[index] = nil
        end
        if boards[index] then
                boards[index] = nil
        end
end

function PlotService.stateOf(index: number, idx: number): string
        local rec = planted[index] and planted[index][idx]
        if not rec then
                return "kosong"
        end
        if now() >= rec.readyAt then
                return "siap"
        end
        return "tumbuh"
end

function PlotService.filledCount(index: number): number
        local n = 0
        local pl = planted[index]
        if pl then
                for _ in pairs(pl) do
                        n += 1
                end
        end
        return n
end

function PlotService.plotTotal(): number
        return Layout.plotCount()
end

function PlotService.setBoard(index: number, label: any)
        local list = {}
        local ok, isLabel = pcall(function()
                return label ~= nil and label:IsA("TextLabel")
        end)
        if ok and isLabel then
                table.insert(list, label :: TextLabel)
        elseif type(label) == "table" then
                for _, l in ipairs(label) do
                        local ok2, isL = pcall(function()
                                return l ~= nil and l:IsA("TextLabel")
                        end)
                        if ok2 and isL then
                                table.insert(list, l :: TextLabel)
                        end
                end
        end
        boards[index] = list
        PlotService.updateBoard(index)
end

function PlotService.updateBoard(index: number)
        local list = boards[index]
        if not list then
                return
        end
        local teks = "TERTANAM " .. PlotService.filledCount(index) .. "/" .. Layout.plotCount()
        for _, l in ipairs(list) do
                l.Text = teks
        end
end

function PlotService.statusPanen(index: number): { any }
        local daftar = PanenStatus.hitung(planted[index] or {}, now())
        for _, row in ipairs(daftar) do
                local info = CropData.byId[row.id]
                row.nama = info and info.nama or row.id
        end
        return daftar
end

function PlotService.startLoop(index: number)
        if running[index] then
                return
        end
        running[index] = true
        task.spawn(function()
                while running[index] do
                        task.wait(1)
                        local pl = planted[index]
                        if pl then
                                for idx, rec in pairs(pl) do
                                        if not rec.ready and now() >= rec.readyAt then
                                                rec.ready = true
                                                PlantModels.setSiap(rec.model, CropData.byId[rec.crop])
                                                syncAll(index, idx)
                                        end
                                end
                        end
                end
        end)
end

function PlotService.scanTargets(index: number, cropId: string): { number }
        local pl = planted[index]
        if not pl then
                return {}
        end
        local out = {}
        for idx = 0, Layout.plotCount() - 1 do
                if not pl[idx] then
                        table.insert(out, idx)
                end
        end
        return out
end

function PlotService.fillPlot(index: number, idx: number, cropId: string): boolean
        local pl = planted[index]
        if not pl then
                return false
        end
        if type(idx) ~= "number" or idx < 0 or idx >= Layout.plotCount() or not CropData.byId[cropId] then
                return false
        end
        if pl[idx] then
                return false
        end
        pl[idx] = {
                crop = cropId,
                readyAt = now() + CropData.GrowTime,
                model = pasangModel(index, idx, cropId),
                ready = false,
                hits = 0,
                lastHit = 0,
        }
        if World then
                World.touch(index)
        end
        syncAll(index, idx)
        PlotService.updateBoard(index)
        return true
end

function PlotService.punch(player: Player, idx: any): (boolean, string)
        local index = Land.landOf(player)
        if not index then
                return false, "Kamu tidak punya lahan."
        end
        if type(idx) ~= "number" or idx ~= idx or idx % 1 ~= 0 or idx < 0 or idx >= Layout.plotCount() then
                return false, "Plot tidak sah."
        end
        local rec = planted[index] and planted[index][idx]
        if not rec then
                return false, "Plot kosong."
        end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not root or (root.Position - plotPos(index, idx)).Magnitude > 26 then
                return false, "Terlalu jauh. Dekati tanaman itu."
        end
        local t = now()
        local c = combo[player.UserId]
        if c and t - c.t <= 4 then
                c.n += 1
                c.t = t
        else
                c = { t = t, n = 1 }
                combo[player.UserId] = c
        end
        local tier = 1
        if c.n >= 8 then
                tier = 3
        elseif c.n >= 4 then
                tier = 2
        end
        local info = CropData.byId[rec.crop]
        if t < rec.readyAt then
                local n, habis = PukulLogic.catat(rec.hits or 0, rec.lastHit or 0, t)
                rec.hits = n
                rec.lastHit = t
                PlantModels.efekPukul(rec.model, tier)
                if habis then
                        rec.model:Destroy()
                        planted[index][idx] = nil
                        if World then
                                World.touch(index)
                        end
                        syncAll(index, idx)
                        PlotService.updateBoard(index)
                end
                return true, "Pukulan " .. n .. "/" .. PukulLogic.MaksPukul
        end
        local y = CropData.Yield[info.rarity]
        local jumlah = rng:NextInteger(y.min, y.max)
        if Drop then
                Drop.spawn(index, plotPos(index, idx) + Vector3.new(0, 2.6, 0), rec.crop, jumlah, c.n, tier)
        end
        rec.model:Destroy()
        planted[index][idx] = nil
        if World then
                World.touch(index)
        end
        syncAll(index, idx)
        PlotService.updateBoard(index)
        return true, "Panen " .. jumlah .. " " .. info.nama
end

function PlotService.serialize(index: number): { [number]: { c: string, r: number } }
        local out = {}
        local pl = planted[index]
        if not pl then
                return out
        end
        for idx, rec in pairs(pl) do
                out[idx] = { c = rec.crop, r = rec.readyAt }
        end
        return out
end

function PlotService.restore(index: number, arr: { [number]: { c: string, r: number } })
        local pl = planted[index]
        if not pl then
                return
        end
        for idx, rec in pairs(arr or {}) do
                if not pl[idx] and CropData.byId[rec.c] then
                        local model = pasangModel(index, idx, rec.c)
                        local ready = now() >= rec.r
                        pl[idx] = { crop = rec.c, readyAt = rec.r, model = model, ready = ready, hits = 0, lastHit = 0 }
                        if ready then
                                PlantModels.setSiap(model, CropData.byId[rec.c])
                        end
                end
        end
end

return PlotService
