local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropData = require(ReplicatedStorage.Shared.CropData)

local PlantModels = {}

local KAYAK = Color3.fromRGB(110, 82, 54)

local function warna3(t: any): Color3
        if type(t) == "table" then
                return Color3.fromRGB(t[1] or 255, t[2] or 255, t[3] or 255)
        end
        return Color3.fromRGB(200, 200, 200)
end

local function part(model: Model, size: Vector3, cf: CFrame, color: Color3, shape: Enum.PartType?): Part
        local p = Instance.new("Part")
        p.Anchored = true
        p.CanQuery = false
        p.CanCollide = false
        p.Size = size
        p.CFrame = cf
        p.Color = color
        p.Material = Enum.Material.SmoothPlastic
        p.TopSurface = Enum.SurfaceType.Smooth
        p.BottomSurface = Enum.SurfaceType.Smooth
        if shape then
                p.Shape = shape
        end
        p.Parent = model
        return p
end

local function buah(model: Model, size: Vector3, cf: CFrame, color: Color3): Part
        local p = part(model, size, cf, color, Enum.PartType.Ball)
        p:SetAttribute("Buah", true)
        return p
end

local function silinder(model: Model, tinggi: number, dia: number, cf: CFrame, color: Color3): Part
        return part(model, Vector3.new(tinggi, dia, dia), cf * CFrame.Angles(0, 0, math.rad(90)), color, Enum.PartType.Cylinder)
end

local function buatAkar(model: Model, pos: Vector3, b: any)
        local w = b.w
        local root = buah(model, Vector3.new(w, w * 0.7, w), CFrame.new(pos + Vector3.new(0, w * 0.22, 0)), b.warna)
        root.Shape = Enum.PartType.Ball
        for i = 0, b.b - 1 do
                local sudut = math.rad(i * (360 / b.b))
                local arah = CFrame.new(pos + Vector3.new(0, b.t * 0.45, 0)) * CFrame.Angles(0, sudut, 0) * CFrame.new(w * 0.35, 0, 0) * CFrame.Angles(0, 0, math.rad(24))
                part(model, Vector3.new(0.22, b.t * 0.85, 0.55), arah, b.aksen)
        end
end

local function buatDaun(model: Model, pos: Vector3, b: any)
        local w = b.w
        part(model, Vector3.new(w, 0.5, w), CFrame.new(pos + Vector3.new(0, 0.45, 0)), b.aksen)
        part(model, Vector3.new(w * 0.8, 0.5, w * 0.8), CFrame.new(pos + Vector3.new(0, 0.95, 0)), b.warna)
        part(model, Vector3.new(w * 0.55, 0.5, w * 0.55), CFrame.new(pos + Vector3.new(0, 1.45, 0)), b.aksen)
        buah(model, Vector3.new(w * 0.42, w * 0.42, w * 0.42), CFrame.new(pos + Vector3.new(0, b.t * 0.85, 0)), b.warna)
end

local function buatBulat(model: Model, pos: Vector3, b: any)
        buah(model, Vector3.new(b.w, b.w, b.w), CFrame.new(pos + Vector3.new(0, b.w * 0.48, 0)), b.warna)
        silinder(model, b.t * 0.8, 0.3, CFrame.new(pos + Vector3.new(0, b.w * 0.9 + b.t * 0.35, 0)), b.aksen)
end

local function buatTangkai(model: Model, pos: Vector3, b: any)
        local n = math.max(2, b.b)
        for i = 0, n - 1 do
                local sudut = (i / n) * math.pi * 2
                local ox = math.cos(sudut) * b.w * 0.33
                local oz = math.sin(sudut) * b.w * 0.33
                local tinggi = b.t * (0.82 + 0.18 * ((i % 3) / 2))
                local dasar = pos + Vector3.new(ox, tinggi / 2, oz)
                silinder(model, tinggi, 0.22, CFrame.new(dasar), b.aksen)
                buah(model, Vector3.new(0.55, 0.55, 0.55), CFrame.new(pos + Vector3.new(ox, tinggi + 0.25, oz)), b.warna)
        end
end

local function buatPohon(model: Model, pos: Vector3, b: any)
        local batang = b.t * 0.62
        silinder(model, batang, 0.5, CFrame.new(pos + Vector3.new(0, batang / 2, 0)), KAYAK)
        local kanopiY = batang + b.w * 0.32
        part(model, Vector3.new(b.w, b.w * 0.8, b.w), CFrame.new(pos + Vector3.new(0, kanopiY, 0)), b.aksen, Enum.PartType.Ball)
        for i = 0, b.b - 1 do
                local sudut = (i / b.b) * math.pi * 2
                local ox = math.cos(sudut) * b.w * 0.3
                local oz = math.sin(sudut) * b.w * 0.3
                local fy = kanopiY - 0.2 + 0.3 * ((i % 2))
                buah(model, Vector3.new(0.55, 0.55, 0.55), CFrame.new(pos + Vector3.new(ox, fy, oz)), b.warna)
        end
end

local function buatSemak(model: Model, pos: Vector3, b: any)
        silinder(model, b.t * 0.4, 0.3, CFrame.new(pos + Vector3.new(0, b.t * 0.2, 0)), KAYAK)
        part(model, Vector3.new(b.w, 0.4, b.w * 0.8), CFrame.new(pos + Vector3.new(0, b.t * 0.42, 0)), b.aksen)
        for i = 0, b.b - 1 do
                local sudut = (i / b.b) * math.pi * 2
                local ox = math.cos(sudut) * b.w * 0.3
                local oz = math.sin(sudut) * b.w * 0.3
                buah(model, Vector3.new(b.w * 0.26, b.w * 0.26, b.w * 0.26), CFrame.new(pos + Vector3.new(ox, b.t * 0.62 + 0.22 * (i % 2), oz)), b.warna)
        end
end

local function buatKacang(model: Model, pos: Vector3, b: any)
        part(model, Vector3.new(b.w, 0.3, b.w * 0.8), CFrame.new(pos + Vector3.new(0, 0.35, 0)), b.aksen)
        part(model, Vector3.new(b.w * 0.6, 0.3, b.w * 0.5), CFrame.new(pos + Vector3.new(0, 0.65, 0)), b.aksen)
        for i = 0, b.b - 1 do
                local sudut = (i / b.b) * math.pi * 2
                local ox = math.cos(sudut) * b.w * 0.28
                local oz = math.sin(sudut) * b.w * 0.24
                local pod = part(model, Vector3.new(0.62, 0.28, 0.26), CFrame.new(pos + Vector3.new(ox, 0.95, oz)) * CFrame.Angles(0, sudut, 0), b.warna)
                pod:SetAttribute("Buah", true)
        end
end

local function buatCendawan(model: Model, pos: Vector3, b: any)
        silinder(model, b.t * 0.6, 0.5, CFrame.new(pos + Vector3.new(0, b.t * 0.3, 0)), b.aksen)
        local topi = part(model, Vector3.new(0.6, b.w, b.w), CFrame.new(pos + Vector3.new(0, b.t * 0.72, 0)) * CFrame.Angles(0, 0, math.rad(90)), b.warna, Enum.PartType.Cylinder)
        topi:SetAttribute("Buah", true)
end

local PEMBENTUK: { [string]: (Model, Vector3, any) -> () } = {
        akar = buatAkar,
        daun = buatDaun,
        bulat = buatBulat,
        tangkai = buatTangkai,
        pohon = buatPohon,
        semak = buatSemak,
        kacang = buatKacang,
        cendawan = buatCendawan,
}

function PlantModels.buat(pos: Vector3, info: any): Model
        local model = Instance.new("Model")
        model.Name = "Tanaman"
        local b = CropData.Bentuk[info.id]
        local bentuk = b or { jenis = "daun", t = 1.6, w = 1.4, b = 1, warna = Color3.fromRGB(96, 140, 80), siap = Color3.fromRGB(220, 160, 70), aksen = Color3.fromRGB(110, 160, 90) }
        if type(b.warna) == "table" then
                bentuk = {
                        jenis = b.jenis,
                        t = b.t,
                        w = b.w,
                        b = b.b,
                        warna = warna3(b.warna),
                        siap = warna3(b.siap),
                        aksen = warna3(b.aksen),
                }
        end
        local pembentuk = PEMBENTUK[bentuk.jenis] or buatDaun
        pembentuk(model, pos, bentuk)
        return model
end

function PlantModels.setSiap(model: Model, info: any)
        local b = CropData.Bentuk[info.id]
        if not b then
                return
        end
        local siap = warna3(b.siap)
        for _, d in ipairs(model:GetDescendants()) do
                if d:IsA("BasePart") and d:GetAttribute("Buah") then
                        d.Color = siap
                        d.Size = d.Size * 1.12
                end
        end
        model:SetAttribute("Siap", true)
end

function PlantModels.efekPukul(model: Model, tier: number)
        local target: BasePart? = nil
        for _, d in ipairs(model:GetDescendants()) do
                if d:IsA("BasePart") and d:GetAttribute("Buah") then
                        target = d
                        break
                end
        end
        if not target then
                target = model:FindFirstChildWhichIsA("BasePart") :: BasePart?
        end
        if not target then
                return
        end
        local awal = target.Size
        local turun = TweenService:Create(target, TweenInfo.new(0.09, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = awal * 0.78 })
        turun:Play()
        turun.Completed:Connect(function()
                if target.Parent then
                        TweenService:Create(target, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = awal }):Play()
                end
        end)
        local snd = Instance.new("Sound")
        snd.SoundId = "rbxasset://sounds/electronicpingshort.wav"
        snd.Volume = 0.3 + 0.08 * tier
        snd.PlaybackSpeed = 0.85
        snd.Parent = target
        snd:Play()
        Debris:AddItem(snd, 1.2)
        local pem = Instance.new("ParticleEmitter")
        pem.Color = ColorSequence.new(target.Color)
        pem.Lifetime = NumberRange.new(0.3, 0.6)
        pem.Speed = NumberRange.new(6, 12)
        pem.SpreadAngle = Vector2.new(180, 180)
        pem.Size = NumberSequence.new(0.4, 0)
        pem.Transparency = NumberSequence.new(0.15, 1)
        pem.Enabled = false
        pem.Parent = target
        pem:Emit(6 + 4 * tier)
        Debris:AddItem(pem, 1.2)
end

return PlantModels
