local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropData = require(ReplicatedStorage.Shared.CropData)
local Recipes = require(ReplicatedStorage.Shared.Recipes)
local SoalLogic = require(ReplicatedStorage.Shared.SoalLogic)

local TanamService = {}

local Land, Plot, Tas, Net, World
local rng = Random.new()

local points: { [number]: Vector3 } = {}
local sesi: { [number]: any } = {}

function TanamService.bind(deps)
        Land = deps.Land
        Plot = deps.Plot
        Tas = deps.Tas
        Net = deps.Net
        World = deps.World
end

function TanamService.setPoint(index: number, pos: Vector3)
        points[index] = pos
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
        return (root.Position - p).Magnitude <= 30
end

local function payload(s: any, selesai: boolean?, tuntas: any?): any
        local p: any = {
                aktif = s ~= nil,
                crop = s and s.cropId or nil,
                nama = s and s.nama or nil,
                jumlah = s and s.jumlah or 0,
                tertanam = s and s.tertanam or 0,
                totalSoal = s and math.ceil(s.jumlah / 10) or 0,
                selesai = selesai == true,
        }
        if tuntas then
                p.selesaiTuntas = true
                p.selesaiNama = tuntas.nama
                p.selesaiHasil = tuntas.total
        end
        if s and s.tertanam < s.jumlah and s.soal then
                p.soal = { teks = s.soal.teks, nomor = math.floor(s.tertanam / 10) + 1 }
        end
        return p
end

local function sync(player, s: any, selesai: boolean?, tuntas: any?)
        Net.get("TanamSync"):FireClient(player, payload(s, selesai, tuntas))
end

function TanamService.syncTo(player)
        sync(player, sesi[player.UserId])
end

function TanamService.start(player, cropId: any, jumlahRaw: any): (boolean, string)
        local index = Land.landOf(player)
        if not index then
                return false, "Masuk duniamu dulu lewat Gerbang Dunia."
        end
        if sesi[player.UserId] then
                return false, "Sesi tanam masih berjalan. Jawab soalnya atau batalkan dulu."
        end
        if not near(player, index) then
                return false, "Dekati Papan Tanam dulu."
        end
        if type(cropId) ~= "string" or not CropData.byId[cropId] then
                return false, "Benih tidak dikenal."
        end
        local seeds = Tas.count(player, "benih", cropId)
        if seeds < 1 then
                return false, "Benih itu tidak ada di tas."
        end
        local targets = Plot.scanTargets(index, cropId)
        if #targets < 1 then
                return false, "Tidak ada plot kosong yang bisa ditanam."
        end
        local jumlah = math.floor(tonumber(jumlahRaw) or 0)
        if jumlah < 1 then
                jumlah = seeds
        end
        jumlah = math.min(jumlah, #targets, seeds)
        if jumlah < 1 then
                return false, "Jumlah tanam tidak sah."
        end
        local info = CropData.byId[cropId]
        local s = {
                index = index,
                cropId = cropId,
                nama = info.nama,
                jumlah = jumlah,
                tertanam = 0,
                used = {},
        }
        s.soal = SoalLogic.buat(rng, 1, s.used)
        sesi[player.UserId] = s
        Plot.updateBoard(index)
        sync(player, s)
        return true, "Mulai tanam " .. info.nama
end

function TanamService.jawab(player, ans: any): (boolean, string)
        local s = sesi[player.UserId]
        if not s then
                return false, "Tidak ada sesi tanam berjalan."
        end
        if s.tertanam >= s.jumlah then
                sesi[player.UserId] = nil
                sync(player, nil, true, { nama = s.nama, total = s.tertanam })
                return true, "+" .. s.tertanam .. " " .. s.nama
        end
        local n = tonumber(ans)
        if type(n) ~= "number" or n ~= n then
                sync(player, s)
                return false, "Masukkan angka dulu."
        end
        if n ~= s.soal.jawab then
                sync(player, s)
                return false, "salah"
        end
        local seeds = Tas.count(player, "benih", s.cropId)
        local batch = math.min(10, s.jumlah - s.tertanam, seeds)
        if batch <= 0 then
                sesi[player.UserId] = nil
                sync(player, s, true)
                return true, "Benih habis"
        end
        local targets = Plot.scanTargets(s.index, s.cropId)
        local tanam = 0
        for i = 1, math.min(batch, #targets) do
                local idx = targets[i]
                if Tas.count(player, "benih", s.cropId) < 1 then
                        break
                end
                if Plot.fillPlot(s.index, idx, s.cropId) then
                        Tas.remove(player, "benih", s.cropId, 1)
                        tanam += 1
                end
        end
        s.tertanam += tanam
        if World then
                World.touch(s.index)
        end
        Plot.updateBoard(s.index)
        if tanam == 0 then
                sesi[player.UserId] = nil
                sync(player, s, true)
                return true, "Plot tidak tersedia"
        end
        if s.tertanam >= s.jumlah then
                sesi[player.UserId] = nil
                sync(player, nil, true, { nama = s.nama, total = s.tertanam })
                return true, "+" .. s.tertanam .. " " .. s.nama
        end
        s.soal = SoalLogic.buat(rng, math.floor(s.tertanam / 10) + 1, s.used)
        sync(player, s)
        return true, "+" .. tanam .. " " .. s.nama
end

function TanamService.batal(player): (boolean, string)
        if not sesi[player.UserId] then
                return false, "Tidak ada sesi tanam."
        end
        sesi[player.UserId] = nil
        sync(player, nil, true)
        return true, "Tanam dibatalkan"
end

function TanamService.gabung(player, a: any, b: any): (boolean, string)
        local index = Land.landOf(player)
        if not index then
                return false, "Masuk duniamu dulu lewat Gerbang Dunia."
        end
        if not near(player, index) then
                return false, "Dekati Papan Tanam dulu."
        end
        if type(a) ~= "string" or type(b) ~= "string" or not CropData.byId[a] or not CropData.byId[b] then
                return false, "Tidak bisa di-combine"
        end
        if a == b then
                return false, "Tidak bisa di-combine"
        end
        local hasil = Recipes.find(a, b)
        if not hasil then
                return false, "Tidak bisa di-combine"
        end
        if Tas.count(player, "benih", a) < 1 or Tas.count(player, "benih", b) < 1 then
                return false, "Benih tidak cukup di tas."
        end
        if Tas.roomFor(player, "benih", hasil, 1) < 1 then
                return false, "Tas penuh. Kosongkan satu slot dulu."
        end
        Tas.remove(player, "benih", a, 1)
        Tas.remove(player, "benih", b, 1)
        Tas.add(player, "benih", hasil, 1)
        return true, "Combine berhasil: benih " .. CropData.byId[hasil].nama .. " masuk tas."
end

function TanamService.statusPayload(player)
        local p = payload(sesi[player.UserId])
        local index = Land.landOf(player)
        p.status = index and Plot.statusPanen(index) or {}
        p.tertanamTotal = index and Plot.filledCount(index) or 0
        p.plotTotal = Plot.plotTotal()
        return p
end

function TanamService.leave(player)
        sesi[player.UserId] = nil
end

return TanamService
