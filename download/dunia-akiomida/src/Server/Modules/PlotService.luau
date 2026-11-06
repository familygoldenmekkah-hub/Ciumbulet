local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropData = require(ReplicatedStorage.Shared.CropData)
local Layout = require(ReplicatedStorage.Shared.Layout)
local Recipes = require(ReplicatedStorage.Shared.Recipes)

local PlotService = {}

local Land, Tas, Net, World
local rng = Random.new()

local folders: { [number]: Folder } = {}
local planted: { [number]: { [number]: any } } = {}
local running: { [number]: boolean } = {}

local RARITY_COLOR = {
        common = Color3.fromRGB(76, 145, 65),
        rare = Color3.fromRGB(58, 112, 200),
        epic = Color3.fromRGB(150, 80, 205),
}

function PlotService.bind(deps)
        Land = deps.Land
        Tas = deps.Tas
        Net = deps.Net
        World = deps.World
end

local function plotPos(index: number, idx: number): Vector3
        local o = Land.origin(index)
        local x, z = Layout.plotLocal(idx)
        return Vector3.new(o.X + x, 1.4, o.Z + z)
end

local function now(): number
        return Workspace:GetServerTimeNow()
end

local function sync(player: Player, index: number, idx: number)
        local rec = planted[index] and planted[index][idx]
        local st = "kosong"
        local crop, readyAt
        if rec then
                crop = rec.crop
                readyAt = rec.readyAt
                st = now() >= rec.readyAt and "siap" or "tumbuh"
        end
        Net.get("PlotSync"):FireClient(player, {
                lahan = index,
                idx = idx,
                st = st,
                crop = crop,
                readyAt = readyAt,
        })
end

local function makePlantModel(index: number, idx: number, cropId: string): Model
        local info = CropData.byId[cropId]
        local model = Instance.new("Model")
        model.Name = "Tanaman_" .. idx
        local pos = plotPos(index, idx)
        local stem = Instance.new("Part")
        stem.Anchored = true
        stem.CanQuery = false
        stem.Size = Vector3.new(1, 2, 1)
        stem.Position = pos + Vector3.new(0, 1, 0)
        stem.Color = Color3.fromRGB(96, 116, 58)
        stem.Material = Enum.Material.Grass
        stem.Parent = model
        local head = Instance.new("Part")
        head.Name = "Kepala"
        head.Anchored = true
        head.CanQuery = false
        head.Size = Vector3.new(2, 1, 2)
        head.Position = pos + Vector3.new(0, 2.5, 0)
        head.Color = RARITY_COLOR[info.rarity] or RARITY_COLOR.common
        head.Material = Enum.Material.SmoothPlastic
        head.Parent = model
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
                                                local head = rec.model and rec.model:FindFirstChild("Kepala")
                                                if head then
                                                        head.Size = Vector3.new(3, 2, 3)
                                                        head.Position = plotPos(index, idx) + Vector3.new(0, 3, 0)
                                                end
                                                for _, p in ipairs(Players:GetPlayers()) do
                                                        sync(p, index, idx)
                                                end
                                        end
                                end
                        end
                end
        end)
end

function PlotService.plant(player: Player, idx: number, cropId: string): (boolean, string)
        local index = Land.landOf(player)
        if not index then
                return false, "Kamu tidak punya lahan."
        end
        if type(idx) ~= "number" or idx < 0 or idx >= Layout.plotCount() then
                return false, "Plot tidak sah."
        end
        local info = CropData.byId[cropId]
        if not info then
                return false, "Tanaman tidak dikenal."
        end
        local pl = planted[index]
        if not pl then
                return false, "Lahan belum siap."
        end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not root or (root.Position - plotPos(index, idx)).Magnitude > 48 then
                return false, "Terlalu jauh dari plot."
        end
        local rec = pl[idx]
        if rec then
                local pasangan = Recipes.sameSpot(rec.crop, cropId)
                if not pasangan then
                        return false, "Plot masih terisi. Untuk gabung benih, tanam benih pasangan resep di plot yang sama."
                end
                if Tas.count(player, "benih", cropId) < 1 then
                        return false, "Benih tidak ada di tas."
                end
                Tas.remove(player, "benih", cropId, 1)
                local namaLama = CropData.byId[rec.crop].nama
                if rec.model then
                        rec.model:Destroy()
                end
                rec.crop = pasangan
                rec.readyAt = now() + CropData.GrowTime
                rec.ready = false
                rec.model = makePlantModel(index, idx, pasangan)
                if World then
                        World.touch(index)
                end
                sync(player, index, idx)
                return true, "Gabung benih: " .. namaLama .. " + " .. info.nama .. " menjadi " .. CropData.byId[pasangan].nama .. "!"
        end
        if Tas.count(player, "benih", cropId) < 1 then
                return false, "Benih tidak ada di tas."
        end
        Tas.remove(player, "benih", cropId, 1)
        local model = makePlantModel(index, idx, cropId)
        pl[idx] = {
                crop = cropId,
                readyAt = now() + CropData.GrowTime,
                model = model,
                ready = false,
        }
        if World then
                World.touch(index)
        end
        sync(player, index, idx)
        return true, "Ditanam."
end

function PlotService.harvest(player: Player, idx: number): (boolean, string)
        local index = Land.landOf(player)
        if not index then
                return false, "Kamu tidak punya lahan."
        end
        if type(idx) ~= "number" or idx < 0 or idx >= Layout.plotCount() then
                return false, "Plot tidak sah."
        end
        local rec = planted[index] and planted[index][idx]
        if not rec then
                return false, "Plot kosong."
        end
        if now() < rec.readyAt then
                return false, "Belum siap panen."
        end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not root or (root.Position - plotPos(index, idx)).Magnitude > 48 then
                return false, "Terlalu jauh dari plot."
        end
        local info = CropData.byId[rec.crop]
        local y = CropData.Yield[info.rarity]
        local jumlah = rng:NextInteger(y.min, y.max)
        if Tas.roomFor(player, "hasil", rec.crop, jumlah) < jumlah then
                return false, "Tas penuh! Kosongkan slot dulu."
        end
        rec.model:Destroy()
        planted[index][idx] = nil
        Tas.add(player, "hasil", rec.crop, jumlah)
        if World then
                World.touch(index)
        end
        sync(player, index, idx)
        return true, "Panen " .. jumlah .. " " .. info.nama .. "."
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
                        local model = makePlantModel(index, idx, rec.c)
                        local ready = now() >= rec.r
                        pl[idx] = { crop = rec.c, readyAt = rec.r, model = model, ready = ready }
                        if ready then
                                local head = model:FindFirstChild("Kepala")
                                if head then
                                        head.Size = Vector3.new(3, 2, 3)
                                        head.Position = plotPos(index, idx) + Vector3.new(0, 3, 0)
                                end
                        end
                end
        end
end

return PlotService
