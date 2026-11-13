#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Miodakali — Generator file Roblox (.rbxlx) + skrip Luau
Kerangka game Desa Miodakali untuk dibuka di Roblox Studio.
Seluruh nama, model, dan sistem adalah karya asli Miodakali.
"""
import os
from xml.sax.saxutils import escape

ROOT = "/home/z/my-project"
OUT_DIR = os.path.join(ROOT, "roblox")
LUAU_DIR = os.path.join(OUT_DIR, "luau")
os.makedirs(LUAU_DIR, exist_ok=True)

_id = [0]


def ref() -> str:
    _id[0] += 1
    return f"RBX{_id[0]}"


def warna_packed(r: int, g: int, b: int) -> int:
    return 4278190080 + (r << 16) + (g << 8) + b


# ----------------------------- item dunia -----------------------------

class Dunia:
    def __init__(self):
        self.items = []

    def tambah(self, item):
        self.items.append(item)
        return item


def buat_part(d: Dunia, nama: str, pos, ukuran, rgb, shape="Block", can_collide=True, parent=None):
    """pos/ukuran dalam studs; koordinat pusat part."""
    attrs = {
        "class": "Part",
        "referent": ref(),
        "nama": nama,
        "pos": pos,
        "size": ukuran,
        "rgb": rgb,
        "shape": shape,
        "can_collide": can_collide,
        "children": [],
    }
    if parent is None:
        return d.tambah(attrs)
    parent.setdefault("children", []).append(attrs)
    return attrs


def buat_prompt(d: Dunia, parent, action: str, objek: str, jarak: float = 8.0):
    parent.setdefault("children", []).append({
        "class": "ProximityPrompt",
        "referent": ref(),
        "nama": "Prompt",
        "action": action,
        "objek": objek,
        "jarak": jarak,
    })


def buat_model(d: Dunia, nama: str, parent=None):
    attrs = {"class": "Model", "referent": ref(), "nama": nama, "children": []}
    if parent is None:
        return d.tambah(attrs)
    parent.setdefault("children", []).append(attrs)
    return attrs


def buat_folder(d: Dunia, nama: str, parent=None):
    attrs = {"class": "Folder", "referent": ref(), "nama": nama, "children": []}
    if parent is None:
        return d.tambah(attrs)
    parent.setdefault("children", []).append(attrs)
    return attrs


# ----------------------------- sumber Luau -----------------------------

LUA_KONFIG = """--!strict
-- Miodakali — Konfigurasi (karya asli game Miodakali)
local Konfig = {}

Konfig.UangAwal = 150

-- Tanaman ladang
Konfig.Tanaman = {
        { nama = "Lumira", benih = "BenihLumira", hargaBenih = 12, hargaJual = 22, hariTumbuh = 1 },
        { nama = "Beraka", benih = "BenihBeraka", hargaBenih = 10, hargaJual = 18, hariTumbuh = 1 },
        { nama = "Terunu", benih = "BenihTerunu", hargaBenih = 15, hargaJual = 34, hariTumbuh = 2 },
        { nama = "Makira", benih = "BenihMakira", hargaBenih = 18, hargaJual = 40, hariTumbuh = 2 },
        { nama = "Kopanu", benih = "BenihKopanu", hargaBenih = 16, hargaJual = 36, hariTumbuh = 2 },
        { nama = "Sundara", benih = "BenihSundara", hargaBenih = 22, hargaJual = 52, hariTumbuh = 3 },
}

Konfig.HargaPakanu = 8
Konfig.HargaPanyukan = 120

-- Hasil lain yang bisa dijual di kios
Konfig.HargaJualLain = {
        TelurAyumi = 18,
        SusuSapiyu = 30,
        Balanu = 10,
        Batuku = 12,
        Ikana = 20,
        Silara = 36,
        Kiraya = 62,
}

Konfig.DetikPerHari = 300
Konfig.JamAwal = 6
Konfig.JamAkhir = 26

return Konfig
"""

LUA_UTAMA = """--!strict
-- Miodakali — Sistem Utama (server)
-- Kerangka belajar: petak ladang, ternak halal, tebang pohon, pecah batu,
-- kios beli-jual, dan siklus siang-malam. Seluruh nama & sistem karya asli
-- Miodakali.

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Konfig = require(ReplicatedStorage:WaitForChild("KonfigurasiMiodakali"))
local KiosEvent = ReplicatedStorage:WaitForChild("KiosEvent")

-- ============================== PEMAIN ==============================

local function buatKantong(player: Player): Folder
        local kantong = Instance.new("Folder")
        kantong.Name = "Kantong"
        kantong.Parent = player
        return kantong
end

local function stat(player: Player, nama: string): IntValue
        local leader = player:FindFirstChild("leaderstats")
        local kantong = player:FindFirstChild("Kantong")
        for wadah in {leader, kantong} :: {any} do
                if wadah then
                        local nilai = wadah:FindFirstChild(nama)
                        if nilai and nilai:IsA("IntValue") then
                                return nilai
                        end
                end
        end
        error("stat tidak ditemukan: " .. nama)
end

local function beri(player: Player, nama: string, delta: number)
        local nilai = stat(player, nama)
        nilai.Value = math.max(0, nilai.Value + delta)
end

local function milik(player: Player, nama: string): number
        local ok, hasil = pcall(function()
                return stat(player, nama).Value
        end)
        if ok then
                return hasil
        end
        return 0
end

Players.PlayerAdded:Connect(function(player)
        local leader = Instance.new("Folder")
        leader.Name = "leaderstats"
        leader.Parent = player

        local kirupi = Instance.new("IntValue")
        kirupi.Name = "Kirupi"
        kirupi.Value = Konfig.UangAwal
        kirupi.Parent = leader

        local tenaga = Instance.new("IntValue")
        tenaga.Name = "Tenaga"
        tenaga.Value = 100
        tenaga.Parent = leader

        buatKantong(player)
end)

-- ============================== LADANG ==============================

type Petak = {
        part: Part,
        prompt: ProximityPrompt,
        tahap: string, -- "rumput" | "gembur" | "tanam" | "matang"
        tanaman: string?, -- nama hasil
        hariTumbuh: number,
        disiram: boolean,
}

local petakList: {Petak} = {}

local function teksPrompt(p: Petak): (string, string)
        if p.tahap == "rumput" then
                return "Gemburkan Tanah", "Petak Ladang"
        elseif p.tahap == "gembur" then
                return "Tanam Benih", "Petak Ladang"
        elseif p.tahap == "tanam" then
                if p.matang then
                        return "Panen " .. (p.tanaman or "?"), "Petak Ladang"
                end
                return "Siram", "Petak Ladang"
        end
        return "?", "?"
end

local function segarkanPrompt(p: Petak)
        local aksi, objek = teksPrompt(p)
        p.prompt.ActionText = aksi
        p.prompt.ObjectText = objek
end

local function perbaruiWarna(p: Petak)
        if p.tahap == "rumput" then
                p.part.Color = Color3.fromRGB(106, 158, 68)
        elseif p.tahap == "gembur" then
                p.part.Color = Color3.fromRGB(163, 113, 75)
        elseif p.disiram then
                p.part.Color = Color3.fromRGB(122, 80, 48)
        else
                p.part.Color = Color3.fromRGB(150, 102, 66)
        end
end

local ladangFolder = Workspace:WaitForChild("Ladang")
for _, anak in ladangFolder:GetChildren() do
        if anak:IsA("BasePart") then
                local prompt = anak:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then
                        local p: Petak = {
                                part = anak,
                                prompt = prompt,
                                tahap = "rumput",
                                tanaman = nil,
                                hariTumbuh = 0,
                                disiram = false,
                        }
                        table.insert(petakList, p)
                        perbaruiWarna(p)
                        segarkanPrompt(p)
                end
        end
end

local function pilihBenih(player: Player): string?
        for _, t in Konfig.Tanaman :: {any} do
                if milik(player, t.benih) > 0 then
                        return t
                end
        end
        return nil
end

for _, p in petakList do
        p.prompt.Triggered:Connect(function(player)
                if p.tahap == "rumput" then
                        p.tahap = "gembur"
                elseif p.tahap == "gembur" then
                        local benih = pilihBenih(player)
                        if not benih then
                                p.prompt.ActionText = "Butuh Benih!"
                                task.wait(1.2)
                                segarkanPrompt(p)
                                return
                        end
                        beri(player, benih.benih, -1)
                        p.tanaman = benih.nama
                        p.hariTumbuh = 0
                        p.tahap = "tanam"
                elseif p.tahap == "tanam" then
                        if p.matang then
                                beri(player, p.tanaman or "", 1)
                                p.tanaman = nil
                                p.hariTumbuh = 0
                                p.matang = false
                                p.tahap = "gembur"
                        elseif not p.disiram then
                                p.disiram = true
                        end
                end
                perbaruiWarna(p)
                segarkanPrompt(p)
        end)
end

-- ============================== HEWAN TERNAK ==============================

type Hewan = {
        model: Model,
        prompt: ProximityPrompt,
        jenis: string, -- "ayumi" | "sapiyu"
        diberiMakan: boolean,
        siap: boolean,
}

local hewanList: {Hewan} = {}

local ternakFolder = Workspace:FindFirstChild("HewanTernak")
if ternakFolder then
        for _, model in ternakFolder:GetChildren() do
                if model:IsA("Model") then
                        local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then
                                local jenis = string.lower(string.sub(model.Name, 1, 6))
                                local h: Hewan = {
                                        model = model,
                                        prompt = prompt,
                                        jenis = if string.find(string.lower(model.Name), "ayumi") then "ayumi" else "sapiyu",
                                        diberiMakan = false,
                                        siap = false,
                                }
                                table.insert(hewanList, h)
                        end
                end
        end
end

local function segarkanPromptHewan(h: Hewan)
        if h.siap then
                h.prompt.ActionText = if h.jenis == "ayumi" then "Ambil Telur Ayumi" else "Ambil Susu Sapiyu"
        elseif not h.diberiMakan then
                h.prompt.ActionText = "Beri Pakanu"
        else
                h.prompt.ActionText = "Sudah Kenyang"
        end
        h.prompt.ObjectText = if h.jenis == "ayumi" then "Ayumi" else "Sapiyu"
end

for _, h in hewanList do
        segarkanPromptHewan(h)
        h.prompt.Triggered:Connect(function(player)
                if h.siap then
                        local hasil = if h.jenis == "ayumi" then "TelurAyumi" else "SusuSapiyu"
                        beri(player, hasil, 1)
                        h.siap = false
                elseif not h.diberiMakan then
                        if milik(player, "Pakanu") > 0 then
                                beri(player, "Pakanu", -1)
                                h.diberiMakan = true
                        else
                                h.prompt.ActionText = "Butuh Pakanu!"
                                task.wait(1.2)
                        end
                end
                segarkanPromptHewan(h)
        end)
end

-- ============================== POHON & BATU ==============================

type Sumber = {
        prompt: ProximityPrompt,
        bagian: {BasePart},
        hidup: boolean,
        nyawa: number,
        tunggu: number,
        jenis: string, -- "kayanu" | "batuku"
}

local sumberList: {Sumber} = {}

for namaFolder, jenis in {Kayanu = "kayanu", Batu = "batuku"} :: {any} do
        local f = Workspace:FindFirstChild(namaFolder)
        if f then
                for _, model in f:GetChildren() do
                        if model:IsA("Model") then
                                local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if prompt then
                                        local s: Sumber = {
                                                prompt = prompt,
                                                bagian = {},
                                                hidup = true,
                                                nyawa = 3,
                                                tunggu = 0,
                                                jenis = jenis,
                                        }
                                        for _, b in model:GetDescendants() do
                                                if b:IsA("BasePart") then
                                                        table.insert(s.bagian, b)
                                                end
                                        end
                                        table.insert(sumberList, s)
                                        prompt.ObjectText = if jenis == "kayanu" then "Kayanu" else "Batuku"
                                        prompt.ActionText = if jenis == "kayanu" then "Tebang" else "Pecahkan"
                                end
                        end
                end
        end
end

for _, s in sumberList do
        s.prompt.Triggered:Connect(function(player)
                if not s.hidup then
                        return
                end
                s.nyawa -= 1
                if s.nyawa <= 0 then
                        s.hidup = false
                        s.tunggu = if s.jenis == "kayanu" then 2 else 3
                        for _, b in s.bagian do
                                b.Transparency = 1
                                b.CanCollide = false
                                if b:IsA("ProximityPrompt") then
                                        b.Enabled = false
                                end
                        end
                        beri(player, if s.jenis == "kayanu" then "Balanu" else "Batuku", 2)
                        s.prompt.Enabled = false
                else
                        s.prompt.ActionText = string.format("%s (%d lagi)", if s.jenis == "kayanu" then "Tebang" else "Pecahkan", s.nyawa)
                end
        end)
end

-- ============================== KIOS DESA ==============================

local pintuKios = Workspace:FindFirstChild("PintuKios", true)
if pintuKios then
        local prompt = pintuKios:FindFirstChildWhichIsA("ProximityPrompt")
        if prompt then
                prompt.Triggered:Connect(function(player)
                        KiosEvent:FireClient(player)
                end)
        end
end

KiosEvent.OnServerEvent:Connect(function(player, aksi: string, nama: string, jumlah: number)
        if typeof(aksi) ~= "string" or typeof(nama) ~= "string" or typeof(jumlah) ~= "number" then
                return
        end
        jumlah = math.floor(math.max(1, jumlah))

        if aksi == "beli" then
                local harga = nil
                if nama == "Pakanu" then
                        harga = Konfig.HargaPakanu
                elseif nama == "Panyukan" then
                        harga = Konfig.HargaPanyukan
                else
                        for _, t in Konfig.Tanaman :: {any} do
                                if t.benih == nama then
                                        harga = t.hargaBenih
                                        break
                                end
                        end
                end
                if harga and milik(player, "Kirupi") >= harga * jumlah then
                        beri(player, "Kirupi", -harga * jumlah)
                        beri(player, nama, jumlah)
                end
        elseif aksi == "jual" then
                local harga = nil
                for _, t in Konfig.Tanaman :: {any} do
                        if t.nama == nama then
                                harga = t.hargaJual
                                break
                        end
                end
                if not harga then
                        harga = Konfig.HargaJualLain[nama]
                end
                if harga and milik(player, nama) >= jumlah then
                        beri(player, nama, -jumlah)
                        beri(player, "Kirupi", harga * jumlah)
                end
        end
end)

-- ============================== SIKLUS HARI ==============================

task.spawn(function()
        while true do
                local awal = os.clock()
                while os.clock() - awal < Konfig.DetikPerHari do
                        local maju = (os.clock() - awal) / Konfig.DetikPerHari
                        Lighting.ClockTime = Konfig.JamAwal + maju * (Konfig.JamAkhir - Konfig.JamAwal)
                        task.wait(0.5)
                end
                -- hari berganti
                for _, p in petakList do
                        if p.tahap == "tanam" and p.tanaman then
                                if p.disiram then
                                        p.hariTumbuh += 1
                                        local def = nil
                                        for _, t in Konfig.Tanaman :: {any} do
                                                if t.nama == p.tanaman then
                                                        def = t
                                                        break
                                                end
                                        end
                                        if def and p.hariTumbuh >= def.hariTumbuh then
                                                p.matang = true
                                        end
                                end
                                p.disiram = false
                                perbaruiWarna(p)
                                segarkanPrompt(p)
                        end
                end
                for _, h in hewanList do
                        if h.diberiMakan then
                                h.siap = true
                                h.diberiMakan = false
                        end
                        segarkanPromptHewan(h)
                end
                for _, s in sumberList do
                        if not s.hidup then
                                s.tunggu -= 1
                                if s.tunggu <= 0 then
                                        s.hidup = true
                                        s.nyawa = 3
                                        for _, b in s.bagian do
                                                b.Transparency = 0
                                                b.CanCollide = true
                                        end
                                        s.prompt.Enabled = true
                                        s.prompt.ActionText = if s.jenis == "kayanu" then "Tebang" else "Pecahkan"
                                end
                        end
                end
        end
end)
"""

LUA_KIOS_GUI = """--!strict
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
info.Text = "Ketuk: sekali = beli 1 / jual 1"
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
for _, t in Konfig.Tanaman :: {any} do
        urutan += 1
        local nama = t.benih
        local harga = t.hargaBenih
        baris("Beli " .. nama .. "  (" .. harga .. " Kirupi)", urutan, function()
                KiosEvent:FireServer("beli", nama, 1)
        end)
end
urutan += 1
baris("Beli Pakanu  (" .. Konfig.HargaPakanu .. " Kirupi)", urutan, function()
        KiosEvent:FireServer("beli", "Pakanu", 1)
end)
urutan += 1
baris("Beli Panyukan  (" .. Konfig.HargaPanyukan .. " Kirupi)", urutan, function()
        KiosEvent:FireServer("beli", "Panyukan", 1)
end)

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
"""

# ----------------------------- membangun dunia -----------------------------

d = Dunia()

# tanah dasar & jalan
buat_part(d, "TanahDesa", (0, -1, 0), (240, 2, 240), warna_packed(134, 191, 90))
buat_part(d, "JalanUtama", (0, 0.05, -60), (170, 0.4, 12), warna_packed(216, 192, 138), can_collide=False)
buat_part(d, "JalanTengah", (30, 0.05, -20), (12, 0.4, 90), warna_packed(216, 192, 138), can_collide=False)
buat_part(d, "JalanSelatan", (0, 0.05, 40), (140, 0.4, 12), warna_packed(216, 192, 138), can_collide=False)

# kolam
buat_part(d, "Kolam", (78, 0.4, 10), (36, 1.2, 30), warna_packed(95, 168, 199))

# ladang: 6x4 petak 10x10
ladang = buat_folder(d, "Ladang")
n = 0
for baris_idx in range(4):
    for kolom in range(6):
        n += 1
        px = -85 + kolom * 12
        pz = -25 + baris_idx * 12
        petak = buat_part(d, f"Petak{n:02d}", (px, 0.3, pz), (10, 0.6, 10), warna_packed(106, 158, 68), parent=ladang)
        buat_prompt(d, petak, "Gemburkan Tanah", "Petak Ladang")

# pohon Kayanu
kayanu = buat_folder(d, "Kayanu")
posisi_pohon = [(-105, -70), (-75, -75), (-40, -80), (0, -90), (95, -70), (105, -30)]
for i, (px, pz) in enumerate(posisi_pohon, start=1):
    m = buat_model(d, f"Kayanu{i:02d}", parent=kayanu)
    batang = buat_part(d, f"BatangKayanu{i:02d}", (px, 4, pz), (2.4, 10, 2.4), warna_packed(122, 82, 48), parent=m)
    buat_part(d, f"TajukKayanu{i:02d}", (px, 13, pz), (9, 9, 9), warna_packed(63, 125, 58), shape="Ball", parent=m)
    buat_prompt(d, batang, "Tebang", "Kayanu")

# batu
batu_folder = buat_folder(d, "Batu")
posisi_batu = [(-100, 20), (-60, 55), (60, 55), (100, -60)]
for i, (px, pz) in enumerate(posisi_batu, start=1):
    m = buat_model(d, f"Batuku{i:02d}", parent=batu_folder)
    batu = buat_part(d, f"Batuk{i:02d}", (px, 1.6, pz), (3.4, 3.4, 3.4), warna_packed(154, 154, 148), shape="Ball", parent=m)
    buat_prompt(d, batu, "Pecahkan", "Batuku")


def bangunan(nama: str, cx: float, cz: float, lebar: float, dalam: float, tinggi: float, rgb_dinding, rgb_atap, pintu_label: str):
    m = buat_model(d, nama)
    y = tinggi / 2
    # dinding depan (dengan celah pintu), belakang, kiri, kanan
    celah = 4
    sisi = (lebar - celah) / 2
    buat_part(d, f"DindingDepanKiri{nama}", (cx - celah / 2 - sisi / 2, y, cz + dalam / 2), (sisi, tinggi, 1), rgb_dinding, parent=m)
    buat_part(d, f"DindingDepanKanan{nama}", (cx + celah / 2 + sisi / 2, y, cz + dalam / 2), (sisi, tinggi, 1), rgb_dinding, parent=m)
    buat_part(d, f"DindingBelakang{nama}", (cx, y, cz - dalam / 2), (lebar, tinggi, 1), rgb_dinding, parent=m)
    buat_part(d, f"DindingKiri{nama}", (cx - lebar / 2, y, cz), (1, tinggi, dalam), rgb_dinding, parent=m)
    buat_part(d, f"DindingKanan{nama}", (cx + lebar / 2, y, cz), (1, tinggi, dalam), rgb_dinding, parent=m)
    # atap
    buat_part(d, f"Atap{nama}", (cx, tinggi + 1.2, cz), (lebar + 2, 1.6, dalam + 2), rgb_atap, parent=m)
    # pintu interaktif
    pintu = buat_part(d, f"Pintu{nama}", (cx, tinggi / 2, cz + dalam / 2), (celah, tinggi, 0.6), warna_packed(107, 66, 38), can_collide=False, parent=m)
    buat_prompt(d, pintu, pintu_label, nama)
    return m


# bangunan desa
bangunan("Rumah", -55, -95, 22, 16, 9, warna_packed(239, 227, 196), warna_packed(201, 111, 74), "Istirahat")
bangunan("Dapur", -20, -95, 14, 12, 8, warna_packed(239, 227, 196), warna_packed(138, 158, 106), "Masak")
kios = bangunan("Kios", 45, -95, 20, 14, 8, warna_packed(239, 227, 196), warna_packed(184, 90, 62), "Buka Kios")
pintu_kios = kios["children"][-2]  # part pintu (sebelum prompt)
pintu_kios["nama"] = "PintuKios"
bangunan("Kandang", -85, 55, 16, 12, 7, warna_packed(200, 152, 104), warna_packed(138, 158, 106), "Kandang Ayumi")
bangunan("Pondok", 75, 55, 16, 12, 7, warna_packed(208, 168, 120), warna_packed(138, 158, 106), "Pondok Sapiyu")

# hewan ternak halal
ternak = buat_folder(d, "HewanTernak")
for i, (px, pz) in enumerate([(-90, 40), (-84, 43), (-78, 39)], start=1):
    m = buat_model(d, f"Ayumi{i:02d}", parent=ternak)
    badan = buat_part(d, f"BadanAyumi{i:02d}", (px, 1.4, pz), (2.2, 1.8, 2.8), warna_packed(242, 234, 216), shape="Ball", parent=m)
    buat_part(d, f"KepalaAyumi{i:02d}", (px, 2.4, pz + 1.6), (1.2, 1.2, 1.2), warna_packed(242, 234, 216), shape="Ball", parent=m)
    buat_prompt(d, badan, "Beri Pakanu", "Ayumi")
for i, (px, pz) in enumerate([(70, 40), (80, 43)], start=1):
    m = buat_model(d, f"Sapiyu{i:02d}", parent=ternak)
    badan = buat_part(d, f"BadanSapiyu{i:02d}", (px, 2.2, pz), (4.2, 2.8, 6.5), warna_packed(242, 232, 216), parent=m)
    buat_part(d, f"KepalaSapiyu{i:02d}", (px, 3, pz + 3.8), (2, 2, 2), warna_packed(242, 232, 216), shape="Ball", parent=m)
    buat_prompt(d, badan, "Beri Pakanu", "Sapiyu")

# spawn
spawn = buat_part(d, "TitikAwal", (0, 0.4, -35), (8, 0.8, 8), warna_packed(255, 236, 179))
spawn["class"] = "SpawnLocation"

# ----------------------------- serialisasi XML -----------------------------


def cframe_xml(indent: str, pos) -> str:
    x, y, z = pos
    return (
        f"{indent}<Coordinate3 name=\"CFrame\">\n"
        f"{indent}\t<X>{x}</X>\n{indent}\t<Y>{y}</Y>\n{indent}\t<Z>{z}</Z>\n"
        f"{indent}\t<R00>1</R00><R01>0</R01><R02>0</R02>\n"
        f"{indent}\t<R10>0</R10><R11>0</R11><R12>0</R12>\n"
        f"{indent}\t<R20>0</R20><R21>0</R21><R22>0</R22>\n"
        f"{indent}</Coordinate3>\n"
    )


def serialize(item, depth=0) -> str:
    ind = "\t" * (depth + 1)
    cls = item["class"]
    nama = escape(item["nama"], {'"': "&quot;"})
    out = f"{ind[:-1] if depth else ''}<Item class=\"{cls}\" referent=\"{item['referent']}\">\n"
    out += f"{ind}<Properties>\n"
    out += f"{ind}\t<string name=\"Name\">{nama}</string>\n"
    if cls == "Part" or cls == "SpawnLocation":
        out += f"{ind}\t<bool name=\"Anchored\">true</bool>\n"
        if not item.get("can_collide", True):
            out += f"{ind}\t<bool name=\"CanCollide\">false</bool>\n"
        out += f"{ind}\t<Color3uint8 name=\"Color3uint8\">{item['rgb']}</Color3uint8>\n"
        sx, sy, sz = item["size"]
        out += f"{ind}\t<Vector3 name=\"size\"><X>{sx}</X><Y>{sy}</Y><Z>{sz}</Z></Vector3>\n"
        out += cframe_xml(f"{ind}\t", item["pos"])
        if item.get("shape", "Block") == "Ball":
            out += f"{ind}\t<Token name=\"Shape\">0</Token>\n"
    elif cls == "ProximityPrompt":
        out += f"{ind}\t<string name=\"ActionText\">{escape(item['action'])}</string>\n"
        out += f"{ind}\t<string name=\"ObjectText\">{escape(item['objek'])}</string>\n"
        out += f"{ind}\t<bool name=\"RequiresLineOfSight\">false</bool>\n"
        out += f"{ind}\t<float name=\"MaxActivationDistance\">{item['jarak']}</float>\n"
    out += f"{ind}</Properties>\n"
    for c in item.get("children", []):
        out += serialize(c, depth + 1)
    out += f"{ind[:-1] if depth else ''}</Item>\n"
    return out


# sumber skrip disimpan juga sebagai file terpisah
with open(os.path.join(LUAU_DIR, "KonfigurasiMiodakali.lua"), "w") as f:
    f.write(LUA_KONFIG)
with open(os.path.join(LUAU_DIR, "MiodakaliUtama.server.lua"), "w") as f:
    f.write(LUA_UTAMA)
with open(os.path.join(LUAU_DIR, "KiosGui.client.lua"), "w") as f:
    f.write(LUA_KIOS_GUI)

xml = []
xml.append(
    '<roblox xmlns:xmime="http://schemas.microsoft.com/2003/10/Serialization/" '
    'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
    'xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">\n'
)
xml.append("\t<Item class=\"Workspace\" referent=\"RBXW\">\n\t\t<Properties>\n\t\t\t<string name=\"Name\">Workspace</string>\n\t\t</Properties>\n")
for item in d.items:
    xml.append(serialize(item, depth=1))
xml.append("\t</Item>\n")

xml.append("\t<Item class=\"Lighting\" referent=\"RBXL\">\n\t\t<Properties>\n\t\t\t<string name=\"Name\">Lighting</string>\n\t\t\t<float name=\"ClockTime\">6</float>\n\t\t</Properties>\n\t</Item>\n")

xml.append("\t<Item class=\"ReplicatedStorage\" referent=\"RBXR\">\n\t\t<Properties>\n\t\t\t<string name=\"Name\">ReplicatedStorage</string>\n\t\t</Properties>\n")
xml.append("\t\t<Item class=\"ModuleScript\" referent=\"RBXK\">\n\t\t\t<Properties>\n\t\t\t\t<string name=\"Name\">KonfigurasiMiodakali</string>\n\t\t\t\t<ProtectedString name=\"Source\">{}</ProtectedString>\n\t\t\t</Properties>\n\t\t</Item>\n".format(escape(LUA_KONFIG)))
xml.append("\t\t<Item class=\"RemoteEvent\" referent=\"RBXE\">\n\t\t\t<Properties>\n\t\t\t\t<string name=\"Name\">KiosEvent</string>\n\t\t\t</Properties>\n\t\t</Item>\n")
xml.append("\t</Item>\n")

xml.append("\t<Item class=\"StarterGui\" referent=\"RBXG\">\n\t\t<Properties>\n\t\t\t<string name=\"Name\">StarterGui</string>\n\t\t</Properties>\n")
xml.append("\t\t<Item class=\"ScreenGui\" referent=\"RBXS\">\n\t\t\t<Properties>\n\t\t\t\t<string name=\"Name\">KiosGui</string>\n\t\t\t\t<bool name=\"Enabled\">false</bool>\n\t\t\t</Properties>\n")
xml.append("\t\t\t<Item class=\"LocalScript\" referent=\"RBXLG\">\n\t\t\t\t<Properties>\n\t\t\t\t\t<string name=\"Name\">KiosKlien</string>\n\t\t\t\t\t<ProtectedString name=\"Source\">{}</ProtectedString>\n\t\t\t\t</Properties>\n\t\t\t</Item>\n".format(escape(LUA_KIOS_GUI)))
xml.append("\t\t</Item>\n\t</Item>\n")

xml.append("\t<Item class=\"ServerScriptService\" referent=\"RBXV\">\n\t\t<Properties>\n\t\t\t<string name=\"Name\">ServerScriptService</string>\n\t\t</Properties>\n")
xml.append("\t\t<Item class=\"Script\" referent=\"RBXM\">\n\t\t\t<Properties>\n\t\t\t\t<string name=\"Name\">MiodakaliUtama</string>\n\t\t\t\t<ProtectedString name=\"Source\">{}</ProtectedString>\n\t\t\t</Properties>\n\t\t</Item>\n".format(escape(LUA_UTAMA)))
xml.append("\t</Item>\n")

xml.append("\t<Item class=\"StarterPlayer\" referent=\"RBXP\">\n\t\t<Properties>\n\t\t\t<string name=\"Name\">StarterPlayer</string>\n\t\t</Properties>\n\t\t<Item class=\"StarterPlayerScripts\" referent=\"RBXPS\">\n\t\t\t<Properties>\n\t\t\t\t<string name=\"Name\">StarterPlayerScripts</string>\n\t\t\t</Properties>\n\t\t</Item>\n\t</Item>\n")

xml.append("</roblox>\n")

out_path = os.path.join(OUT_DIR, "miodakali.rbxlx")
with open(out_path, "w") as f:
    f.write("".join(xml))

# validasi XML
import xml.dom.minidom as minidom

with open(out_path, "r") as f:
    minidom.parse(f)

print("OK — file valid:")
print(" -", out_path, f"({os.path.getsize(out_path)} bytes, {_id[0]} item)")
print(" -", os.path.join(LUAU_DIR, "KonfigurasiMiodakali.lua"))
print(" -", os.path.join(LUAU_DIR, "MiodakaliUtama.server.lua"))
print(" -", os.path.join(LUAU_DIR, "KiosGui.client.lua"))
