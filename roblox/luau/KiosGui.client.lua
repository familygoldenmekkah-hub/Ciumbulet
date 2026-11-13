--!strict
-- Miodakali — Antarmuka Kios Desa (klien)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local Konfig = require(ReplicatedStorage:WaitForChild("KonfigurasiMiodakali"))
local KiosEvent = ReplicatedStorage:WaitForChild("KiosEvent")
local player = Players.LocalPlayer

local gui = script.Parent :: ScreenGui

local frame = Instance.new("Frame")
frame.Name = "Kotak"
frame.Size = UDim2.fromScale(0.42, 0.62)
frame.Position = UDim2.fromScale(0.29, 0.19)
frame.BackgroundColor3 = Color3.fromRGB(38, 30, 20)
frame.BackgroundTransparency = 0.08
frame.Visible = false
frame.Parent = gui

local sudut = Instance.new("UICorner")
sudut.CornerRadius = UDim.new(0, 14)
sudut.Parent = frame

local judul = Instance.new("TextLabel")
judul.Name = "Judul"
judul.Size = UDim2.fromScale(1, 0.1)
judul.BackgroundTransparency = 1
judul.TextColor3 = Color3.fromRGB(255, 233, 184)
judul.TextScaled = true
judul.Font = Enum.Font.GothamBold
judul.Text = "KIOS DESA — Pak Dalu"
judul.Parent = frame

local daftar = Instance.new("ScrollingFrame")
daftar.Name = "Daftar"
daftar.Size = UDim2.fromScale(0.92, 0.78)
daftar.Position = UDim2.fromScale(0.04, 0.12)
daftar.BackgroundTransparency = 1
daftar.BorderSizePixel = 0
daftar.CanvasSize = UDim2.new(0, 0, 0, 0)
daftar.AutomaticCanvasSize = Enum.AutomaticSize.Y
daftar.Parent = frame

local tata = Instance.new("UIListLayout")
tata.Padding = UDim.new(0, 6)
tata.SortOrder = Enum.SortOrder.LayoutOrder
tata.Parent = daftar

local info = Instance.new("TextLabel")
info.Name = "Info"
info.Size = UDim2.fromScale(0.92, 0.07)
info.Position = UDim2.fromScale(0.04, 0.91)
info.BackgroundTransparency = 1
info.TextColor3 = Color3.fromRGB(200, 190, 160)
info.TextScaled = true
info.Text = "Tanaman tumbuh waktu nyata · naik level untuk buka benih baru"
info.Parent = frame

local tombolTutup = Instance.new("TextButton")
tombolTutup.Size = UDim2.fromScale(0.14, 0.08)
tombolTutup.Position = UDim2.fromScale(0.83, 0.01)
tombolTutup.TextColor3 = Color3.fromRGB(255, 120, 100)
tombolTutup.BackgroundTransparency = 1
tombolTutup.TextScaled = true
tombolTutup.Font = Enum.Font.GothamBold
tombolTutup.Text = "Tutup"
tombolTutup.Parent = frame
tombolTutup.Activated:Connect(function()
        frame.Visible = false
end)

local function baris(teks: string, urutan: number, saatTekan: () -> ())
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromScale(1, 0)
        b.AutomaticSize = Enum.AutomaticSize.Y
        b.BackgroundColor3 = Color3.fromRGB(58, 48, 34)
        b.TextColor3 = Color3.fromRGB(255, 233, 184)
        b.TextScaled = true
        b.Font = Enum.Font.Gotham
        b.Text = teks
        b.AutoButtonColor = true
        b.LayoutOrder = urutan
        b.Parent = daftar
        local sud = Instance.new("UICorner")
        sud.CornerRadius = UDim.new(0, 8)
        sud.Parent = b
        b.Activated:Connect(saatTekan)
end

local urutan = 0
local player = Players.LocalPlayer

local function labelLevel(lb: number): string
        local lv = player:FindFirstChild("leaderstats")
        local nilai = lv and lv:FindFirstChild("LevelPetani")
        local sekarang = nilai and nilai:IsA("IntValue") and nilai.Value or 1
        return if sekarang >= lb then "" else "  [Level " .. lb .. "]"
end

for _, t in Konfig.Tanaman :: {any} do
        urutan += 1
        local nama = t.benih
        local menit = math.floor(t.detikTumbuh / 60)
        local ket = if t.detikTumbuh < 60 then (t.detikTumbuh .. " dtk") else (menit .. " mnt")
        baris(
                "Beli "
                        .. nama
                        .. "  ("
                        .. t.hargaBenih
                        .. " Kirupi · "
                        .. ket
                        .. ")"
                        .. labelLevel(t.levelButuh),
                urutan,
                function()
                        KiosEvent:FireServer("beli", nama, 1)
                end
        )
end
urutan += 1
baris("Beli Pakanu  (" .. Konfig.HargaPakanu .. " Kirupi)", urutan, function()
        KiosEvent:FireServer("beli", "Pakanu", 1)
end)
urutan += 1
baris(
        "Beli Panyukan  (" .. Konfig.HargaPanyukan .. " Kirupi)" .. labelLevel(Konfig.LevelPanyukan),
        urutan,
        function()
                KiosEvent:FireServer("beli", "Panyukan", 1)
        end
)

for _, t in Konfig.Tanaman :: {any} do
        urutan += 1
        local nama = t.nama
        local harga = t.hargaJual
        baris("Jual " .. nama .. "  (+" .. harga .. ")", urutan, function()
                KiosEvent:FireServer("jual", nama, 1)
        end)
end
for nama, harga in Konfig.HargaJualLain :: {any} do
        urutan += 1
        baris("Jual " .. nama .. "  (+" .. harga .. ")", urutan, function()
                KiosEvent:FireServer("jual", nama, 1)
        end)
end

KiosEvent.OnClientEvent:Connect(function()
        frame.Visible = not frame.Visible
end)
