local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropData = require(ReplicatedStorage.Shared.CropData)
local GudangLogic = require(ReplicatedStorage.Shared.GudangLogic)

local GudangService = {}

local Land, Tas, Net, World
local points: { [number]: Vector3 } = {}
local gudang: { [number]: any } = {}

function GudangService.bind(deps)
        Land = deps.Land
        Tas = deps.Tas
        Net = deps.Net
        World = deps.World
end

function GudangService.setPoint(index: number, pos: Vector3)
        points[index] = pos
        if not gudang[index] then
                gudang[index] = GudangLogic.baru()
        end
end

local function near(player, index: number): boolean
        local p = points[index]
        if not p then
                return false
        end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not root then
                return false
        end
        return (root.Position - p).Magnitude <= 34
end

local function stateOf(index: number)
        if not gudang[index] then
                gudang[index] = GudangLogic.baru()
        end
        return gudang[index]
end

function GudangService.syncTo(player, index: number)
        local gd = stateOf(index)
        local slots = {}
        for i, s in ipairs(gd.s) do
                slots[i] = { i = i, id = s.id, count = s.count }
        end
        Net.get("GudangSync"):FireClient(player, { lahan = index, terpakai = #gd.s, maks = GudangLogic.MaksSlot, slots = slots })
end

function GudangService.simpan(player, cropId: any, nRaw: any): (boolean, string)
        local index = Land.landOf(player)
        if not index then
                return false, "Masuk duniamu dulu lewat Gerbang Dunia."
        end
        if type(cropId) ~= "string" or not CropData.byId[cropId] then
                return false, "Barang tidak dikenal."
        end
        if not near(player, index) then
                return false, "Dekati gudang dulu."
        end
        local stock = Tas.count(player, "hasil", cropId)
        if stock < 1 then
                return false, "Tidak ada hasil panen itu di tas."
        end
        local n = math.floor(tonumber(nRaw) or 0)
        if n < 1 then
                n = stock
        end
        n = math.min(n, stock, GudangLogic.MaksIsi)
        local gd = stateOf(index)
        local ok, msg = GudangLogic.simpan(gd, cropId, n)
        if not ok then
                return false, msg
        end
        Tas.remove(player, "hasil", cropId, n)
        if World then
                World.touch(index)
        end
        GudangService.syncTo(player, index)
        local info = CropData.byId[cropId]
        return true, "Disimpan " .. n .. " " .. info.nama .. ". " .. msg
end

function GudangService.ambil(player, slotI: any, nRaw: any): (boolean, string)
        local index = Land.landOf(player)
        if not index then
                return false, "Masuk duniamu dulu lewat Gerbang Dunia."
        end
        if not near(player, index) then
                return false, "Dekati gudang dulu."
        end
        local gd = stateOf(index)
        local i = math.floor(tonumber(slotI) or 0)
        local ok, msg, n = GudangLogic.ambil(gd, i, tonumber(nRaw))
        if not ok then
                return false, msg
        end
        local s = gd.s[i]
        local room = Tas.roomFor(player, "hasil", s.id, n)
        if room < 1 then
                return false, "Tas penuh! Kosongkan slot tas dulu."
        end
        if room < n then
                n = room
        end
        Tas.add(player, "hasil", s.id, n)
        GudangLogic.kurangi(gd, i, n)
        if World then
                World.touch(index)
        end
        GudangService.syncTo(player, index)
        local info = CropData.byId[s.id]
        return true, "Diambil " .. n .. " " .. (info and info.nama or s.id) .. ". " .. "Tampungan terpakai " .. #gd.s .. "/" .. GudangLogic.MaksSlot .. " (sisa " .. GudangLogic.MaksSlot - #gd.s .. ")."
end

function GudangService.serLahan(index: number)
        return GudangLogic.ser(gudang[index])
end

function GudangService.restoreLahan(index: number, arr: any)
        gudang[index] = GudangLogic.des(arr)
end

function GudangService.clearLahan(index: number)
        gudang[index] = nil
        points[index] = nil
end

return GudangService
