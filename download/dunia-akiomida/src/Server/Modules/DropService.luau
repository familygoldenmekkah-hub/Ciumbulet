local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CropData = require(ReplicatedStorage.Shared.CropData)

local DropService = {}

local Land, Tas

local folders: { [number]: Folder } = {}

local RARITY_COLOR = {
        common = Color3.fromRGB(120, 200, 90),
        rare = Color3.fromRGB(90, 150, 235),
        epic = Color3.fromRGB(190, 110, 240),
}

function DropService.bind(deps)
        Land = deps.Land
        Tas = deps.Tas
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

function DropService.clearLahan(index: number)
        local f = folders[index]
        if f then
                f:Destroy()
                folders[index] = nil
        end
end

local function floatify(part: BasePart, basePos: Vector3)
        part.Anchored = true
        part.AssemblyLinearVelocity = Vector3.zero
        part.AssemblyAngularVelocity = Vector3.zero
        TweenService:Create(part, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Position = basePos + Vector3.new(0, 2.8, 0) }):Play()
end

function DropService.spawn(index: number, pos: Vector3, cropId: string, count: number, comboN: number, tier: number)
        local info = CropData.byId[cropId]
        if not info then
                return
        end
        local f = folderFor(index)
        if not f then
                return
        end
        local warna = RARITY_COLOR[info.rarity] or RARITY_COLOR.common
        local part = Instance.new("Part")
        part.Name = "Hasil_" .. cropId
        part:SetAttribute("LahanIdx", index)
        part:SetAttribute("CropId", cropId)
        part:SetAttribute("Count", count)
        local s = 1.5 + 0.3 * tier
        part.Size = Vector3.new(s, s, s)
        part.Color = warna
        part.Material = Enum.Material.SmoothPlastic
        part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.25, 0.62, 1, 1)
        part.Position = pos
        part.Parent = f
        local pem = Instance.new("ParticleEmitter")
        pem.Color = ColorSequence.new(warna)
        pem.Lifetime = NumberRange.new(0.45, 0.9)
        pem.Speed = NumberRange.new(8, 16)
        pem.SpreadAngle = Vector2.new(180, 180)
        pem.Size = NumberSequence.new(0.55, 0)
        pem.Transparency = NumberSequence.new(0.1, 1)
        pem.Enabled = false
        pem.Parent = part
        pem:Emit(10 + 9 * tier)
        local snd = Instance.new("Sound")
        snd.SoundId = "rbxasset://sounds/electronicpingshort.wav"
        snd.Volume = 0.3 + 0.12 * tier
        snd.PlaybackSpeed = 1.25 - 0.14 * tier
        snd.Parent = part
        snd:Play()
        if comboN >= 4 then
                local whoosh = Instance.new("Sound")
                whoosh.SoundId = "rbxasset://sounds/swoosh.wav"
                whoosh.Volume = 0.35 + 0.1 * tier
                whoosh.PlaybackSpeed = 1.1 - 0.1 * tier
                whoosh.Parent = part
                whoosh:Play()
        end
        part.AssemblyLinearVelocity = Vector3.new(math.random(-9, 9), 22 + 5 * tier, math.random(-9, 9))
        part.AssemblyAngularVelocity = Vector3.new(math.random(-6, 6), math.random(-6, 6), math.random(-6, 6))
        local basePos = pos + Vector3.new(0, 3.4, 0)
        local kunci = 0
        local selesai = false
        part.Touched:Connect(function(hit)
                if selesai or os.clock() - kunci < 0.4 then
                        return
                end
                local karakter = hit and hit.Parent
                local p = karakter and Players:GetPlayerFromCharacter(karakter)
                if not p then
                        return
                end
                if Land.ownerOf(index) ~= p.UserId then
                        return
                end
                kunci = os.clock()
                local cid = part:GetAttribute("CropId") :: string
                local n = part:GetAttribute("Count") :: number
                if Tas.roomFor(p, "hasil", cid, n) < n then
                        floatify(part, basePos)
                        return
                end
                selesai = true
                Tas.add(p, "hasil", cid, n)
                pem:Emit(8)
                local ding = Instance.new("Sound")
                ding.SoundId = "rbxasset://sounds/electronicpingshort.wav"
                ding.Volume = 0.45
                ding.PlaybackSpeed = 1.5
                ding.Parent = part
                ding:Play()
                part.CanCollide = false
                part.Anchored = true
                task.delay(0.9, function()
                        if part.Parent then
                                part:Destroy()
                        end
                end)
        end)
        task.delay(900, function()
                if part.Parent and not part.Anchored then
                        part:Destroy()
                end
        end)
end

return DropService
