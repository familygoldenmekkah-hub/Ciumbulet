local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CropData = require(ReplicatedStorage.Shared.CropData)
local DropModels = require(script.Parent.DropModels)
local KlaimDrop = require(ReplicatedStorage.Shared.KlaimDrop)
local PanenWaktu = require(ReplicatedStorage.Shared.PanenWaktu)
local DuniaLogic = require(ReplicatedStorage.Shared.DuniaLogic)

local DropService = {}

local Land, Tas, Audit

local folders: { [number]: Folder } = {}
local rekaman: { [number]: { [string]: any } } = {}
local counters: { [number]: number } = {}

function DropService.bind(deps)
        Land = deps.Land
        Tas = deps.Tas
        Audit = deps.Audit
end

local function folderFor(index: number): Folder?
        local root = Workspace:FindFirstChild("Dunia")
        if not root then
                return nil
        end
        local f = root:FindFirstChild("Drops_" .. index)
        if not f then
                f = Instance.new("Folder")
                f.Name = "Drops_" .. index
                f.Parent = root
        end
        folders[index] = f :: Folder
        return f :: Folder
end

local function hitungHidup(index: number): number
        local n = 0
        for _, rec in pairs(rekaman[index] or {}) do
                if rec.status == "ada" or rec.status == "proses" then
                        n += 1
                end
        end
        return n
end

local function hapusModel(model: Model?)
        if model and model.Parent then
                model:Destroy()
        end
end

function DropService.clearLahan(index: number)
        rekaman[index] = nil
        counters[index] = nil
        local f = folders[index]
        if f then
                f:Destroy()
                folders[index] = nil
        end
end

local function floatify(root: BasePart, basePos: Vector3)
        root.Anchored = true
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        TweenService:Create(root, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Position = basePos + Vector3.new(0, 2.8, 0) }):Play()
end

local function idBaru(index: number): string
        counters[index] = (counters[index] or 0) + 1
        local unik = tostring(os.time()):sub(-8)
        return "d" .. tostring(index) .. "x" .. tostring(counters[index]) .. "y" .. unik .. tostring(math.random(100, 999))
end

local function pasangClaim(index: number, rec: any, part: BasePart, basePos: Vector3)
        part.Touched:Connect(function(hit)
                if rec.status ~= "ada" then
                        return
                end
                local karakter = hit and hit.Parent
                local p = karakter and Players:GetPlayerFromCharacter(karakter)
                if not p then
                        return
                end
                local root = karakter:FindFirstChild("HumanoidRootPart") :: BasePart?
                local dist = root and (root.Position - part.Position).Magnitude or math.huge
                local ok, alasan = KlaimDrop.coba(rec, p.UserId, dist)
                if not ok then
                        if Audit then
                                if alasan == "bukan_milik" then
                                        Audit.catat(p, "milik", "drop " .. tostring(rec.id))
                                elseif alasan == "jarak" then
                                        Audit.catat(p, "jarak", "drop " .. tostring(rec.id))
                                elseif alasan == "sudah_diambil" then
                                        Audit.catat(p, "klaim_ganda", "drop " .. tostring(rec.id))
                                end
                        end
                        return
                end
                local cid = rec.crop
                local n = rec.count
                if Tas.roomFor(p, "hasil", cid, n) < n then
                        KlaimDrop.batalkan(rec, p.UserId)
                        floatify(part, basePos)
                        return
                end
                if not KlaimDrop.selesai(rec, p.UserId) then
                        return
                end
                Tas.add(p, "hasil", cid, n)
                local pem = part:FindFirstChildWhichIsA("ParticleEmitter")
                if pem then
                        pem:Emit(8)
                end
                local ding = Instance.new("Sound")
                ding.SoundId = "rbxasset://sounds/electronicpingshort.wav"
                ding.Volume = 0.45
                ding.PlaybackSpeed = 1.5
                ding.Parent = part
                ding:Play()
                part.Anchored = true
                part.CanCollide = false
                for _, d in ipairs(rec.model:GetDescendants()) do
                        if d:IsA("BasePart") then
                                d.Anchored = true
                                d.CanCollide = false
                        end
                end
                task.delay(0.9, function()
                        hapusModel(rec.model)
                end)
        end)
end

local function bangunModel(index: number, rec: any): boolean
        local f = folderFor(index)
        if not f then
                return false
        end
        local info = CropData.byId[rec.crop]
        if not info then
                return false
        end
        local model = DropModels.buat(rec.pos, rec.crop, rec.tier or 1)
        if not model then
                return false
        end
        local part = model.PrimaryPart :: BasePart
        part:SetAttribute("DropId", rec.id)
        part:SetAttribute("LahanIdx", index)
        model.Parent = f
        rec.model = model
        rec.part = part
        local warna = part.Color
        local pem = Instance.new("ParticleEmitter")
        pem.Color = ColorSequence.new(warna)
        pem.Lifetime = NumberRange.new(0.45, 0.9)
        pem.Speed = NumberRange.new(8, 16)
        pem.SpreadAngle = Vector2.new(180, 180)
        pem.Size = NumberSequence.new(0.55, 0)
        pem.Transparency = NumberSequence.new(0.1, 1)
        pem.Enabled = false
        pem.Parent = part
        if not rec.pulih then
                pem:Emit(10 + 9 * (rec.tier or 1))
                local snd = Instance.new("Sound")
                snd.SoundId = "rbxasset://sounds/electronicpingshort.wav"
                snd.Volume = 0.3 + 0.12 * (rec.tier or 1)
                snd.PlaybackSpeed = 1.25 - 0.14 * (rec.tier or 1)
                snd.Parent = part
                snd:Play()
                if (rec.comboN or 0) >= 4 then
                        local whoosh = Instance.new("Sound")
                        whoosh.SoundId = "rbxasset://sounds/swoosh.wav"
                        whoosh.Volume = 0.35
                        whoosh.Parent = part
                        whoosh:Play()
                end
                part.AssemblyLinearVelocity = Vector3.new(math.random(-7, 7), 18 + 5 * (rec.tier or 1), math.random(-7, 7))
                part.AssemblyAngularVelocity = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
        end
        local basePos = part.Position
        pasangClaim(index, rec, part, basePos)
        return true
end

function DropService.spawn(index: number, pos: Vector3, cropId: string, count: number, comboN: number, tier: number)
        local info = CropData.byId[cropId]
        if not info then
                return
        end
        local owner = Land and Land.ownerOf(index)
        if not owner then
                return
        end
        rekaman[index] = rekaman[index] or {}
        if hitungHidup(index) >= DuniaLogic.MaxDrops then
                local tertua, waktuTua = nil, math.huge
                for id, rec in pairs(rekaman[index]) do
                        if rec.status == "ada" and rec.bornAt < waktuTua then
                                tertua, waktuTua = id, rec.bornAt
                        end
                end
                if tertua then
                        local lama = rekaman[index][tertua]
                        hapusModel(lama.model)
                        rekaman[index][tertua] = nil
                end
        end
        local rec: any = {
                id = idBaru(index),
                crop = cropId,
                count = count,
                pos = pos,
                bornAt = os.time(),
                status = "ada",
                owner = owner,
                comboN = comboN,
                tier = tier,
                pulih = false,
        }
        if not bangunModel(index, rec) then
                return
        end
        rekaman[index][rec.id] = rec
end

function DropService.serLahan(index: number): { any }
        local out = {}
        for _, rec in pairs(rekaman[index] or {}) do
                if rec.status == "ada" then
                        table.insert(out, {
                                id = rec.id,
                                crop = rec.crop,
                                count = rec.count,
                                pos = { x = rec.pos.X, y = rec.pos.Y, z = rec.pos.Z },
                        })
                end
        end
        return out
end

function DropService.restoreLahan(index: number, arr: any, leaveTime: any): number
        rekaman[index] = rekaman[index] or {}
        if leaveTime ~= nil and not PanenWaktu.masihAman(leaveTime, os.time()) then
                return 0
        end
        local n = 0
        for _, d in ipairs(DuniaLogic.desDrops(arr or {})) do
                local rec: any = {
                        id = d.id,
                        crop = d.crop,
                        count = d.count,
                        pos = Vector3.new(d.pos.x, d.pos.y, d.pos.z),
                        bornAt = os.time(),
                        status = "ada",
                        owner = Land and Land.ownerOf(index),
                        pulih = true,
                }
                if not rekaman[index][rec.id] and CropData.byId[rec.crop] and bangunModel(index, rec) then
                        rekaman[index][rec.id] = rec
                        n += 1
                end
                if n >= DuniaLogic.MaxDrops then
                        break
                end
        end
        return n
end

function DropService.hidup(index: number): number
        return hitungHidup(index)
end

return DropService
