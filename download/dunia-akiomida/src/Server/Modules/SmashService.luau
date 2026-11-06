local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropData = require(ReplicatedStorage.Shared.CropData)

local SmashService = {}

local Land, Tas, Data, Net, Notify
local rng = Random.new()

local MAX_SLOTS = 6
local tables: { [number]: Vector3 } = {}
local slots: { [number]: { any } } = {}

local RARITY_COLOR = {
        common = Color3.fromRGB(96, 168, 74),
        rare = Color3.fromRGB(70, 128, 214),
        epic = Color3.fromRGB(168, 92, 224),
}
local RARITY_SIZE = {
        common = Vector3.new(2, 2, 2),
        rare = Vector3.new(2, 3, 2),
        epic = Vector3.new(3, 3, 3),
}

function SmashService.bind(deps)
        Land = deps.Land
        Tas = deps.Tas
        Data = deps.Data
        Net = deps.Net
        Notify = deps.Notify
end

function SmashService.registerTable(index: number, pos: Vector3)
        tables[index] = pos
        slots[index] = {}
end

function SmashService.tablePos(index: number): Vector3?
        return tables[index]
end

local function syncLahan(index: number, player: Player?)
        local arr = {}
        for i, s in ipairs(slots[index]) do
                arr[i] = { crop = s.crop, hits = s.hitsLeft, max = CropData.Smash[CropData.byId[s.crop].rarity].hits }
        end
        local ev = Net.get("SmashSync")
        if player then
                ev:FireClient(player, { lahan = index, slots = arr })
                return
        end
        for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if Land.landOf(p) == index then
                        ev:FireClient(p, { lahan = index, slots = arr })
                end
        end
end

function SmashService.clearLahan(index: number)
        slots[index] = {}
end

function SmashService.syncTo(player, index: number)
        syncLahan(index, player)
end

function SmashService.refundLahan(index: number, player)
        for _, s in ipairs(slots[index] or {}) do
                Tas.add(player, "hasil", s.crop, 1)
        end
        slots[index] = {}
end

function SmashService.place(player, cropId: any): (boolean, string)
        local index = Land.landOf(player)
        if not index then
                return false, "Kamu tidak punya lahan."
        end
        if type(cropId) ~= "string" or not CropData.byId[cropId] then
                return false, "Hasil panen tidak dikenal."
        end
        if #slots[index] >= MAX_SLOTS then
                return false, "Meja penuh. Pukul dulu yang ada."
        end
        if Tas.count(player, "hasil", cropId) < 1 then
                return false, "Hasil panen tidak ada di tas."
        end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not root or (root.Position - tables[index]).Magnitude > 24 then
                return false, "Terlalu jauh dari meja."
        end
        Tas.remove(player, "hasil", cropId, 1)
        local info = CropData.byId[cropId]
        local model = Instance.new("Model")
        model.Name = "Hasil_" .. #slots[index]
        local part = Instance.new("Part")
        part.Anchored = true
        part.CanQuery = false
        part.Size = RARITY_SIZE[info.rarity]
        part.Color = RARITY_COLOR[info.rarity]
        part.Material = Enum.Material.SmoothPlastic
        part.Position = tables[index] + Vector3.new(-10 + #slots[index] * 4, part.Size.Y / 2 + 0.1, 0)
        part.Parent = model
        model.Parent = workspace:FindFirstChild("Dunia")
        table.insert(slots[index], { crop = cropId, hitsLeft = CropData.Smash[info.rarity].hits, model = model })
        syncLahan(index, player)
        return true, info.nama .. " diletakkan di meja."
end

function SmashService.hit(player, slotIdx: any): (boolean, string)
        local index = Land.landOf(player)
        if not index then
                return false, "Kamu tidak punya lahan."
        end
        if type(slotIdx) ~= "number" or slotIdx < 1 or slotIdx > #slots[index] then
                return false, "Tidak ada hasil di posisi itu."
        end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not root or (root.Position - tables[index]).Magnitude > 24 then
                return false, "Terlalu jauh dari meja."
        end
        local s = slots[index][slotIdx]
        local info = CropData.byId[s.crop]
        local cfg = CropData.Smash[info.rarity]
        s.hitsLeft -= 1
        if s.hitsLeft <= 0 then
                s.model:Destroy()
                table.remove(slots[index], slotIdx)
                local micda = rng:NextInteger(cfg.micdaMin, cfg.micdaMax)
                Data.addMicda(player, micda)
                local pesan = "+" .. micda .. " Micda"
                if rng:NextNumber() < cfg.seed then
                        local put = Tas.add(player, "benih", s.crop, 1)
                        if put > 0 then
                                pesan ..= ", +1 Benih " .. info.nama
                        else
                                Notify(player, "Tas Penuh", "Benih gagal masuk, tas penuh.")
                        end
                end
                if rng:NextNumber() < cfg.blok then
                        local put = Tas.add(player, "blok", CropData.BlokId, 1)
                        if put > 0 then
                                pesan ..= ", +1 Blok Panen"
                        else
                                Notify(player, "Tas Penuh", "Blok panen gagal masuk, tas penuh.")
                        end
                end
                syncLahan(index, player)
                return true, pesan
        end
        local part = s.model:FindFirstChildWhichIsA("BasePart")
        if part then
                part.Size = part.Size * 0.92
        end
        syncLahan(index, player)
        return true, "Pukulan " .. (cfg.hits - s.hitsLeft) .. "/" .. cfg.hits
end

function SmashService.take(player, slotIdx: any): (boolean, string)
        local index = Land.landOf(player)
        if not index then
                return false, "Kamu tidak punya lahan."
        end
        if type(slotIdx) ~= "number" or slotIdx < 1 or slotIdx > #slots[index] then
                return false, "Tidak ada hasil di posisi itu."
        end
        local s = slots[index][slotIdx]
        if Tas.roomFor(player, "hasil", s.crop, 1) < 1 then
                return false, "Tas penuh!"
        end
        s.model:Destroy()
        table.remove(slots[index], slotIdx)
        Tas.add(player, "hasil", s.crop, 1)
        syncLahan(index, player)
        return true, "Diambil kembali."
end

return SmashService
