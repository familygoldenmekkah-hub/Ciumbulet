#!/usr/bin/env python3
import pathlib
import re

ROOT = pathlib.Path("/home/z/my-project/download/dunia-akiomida")
UI = ROOT / "src/Client/UIController.luau"
NEW = pathlib.Path("/home/z/my-project/scripts/new_semai_section.luau").read_text()

s = UI.read_text()

awal = 'local semaiPanel = makePanel("semai")'
akhir = 'local tokoPanel = makePanel("toko")'
i = s.index(awal)
j = s.index(akhir)
s = s[:i] + NEW + "\n" + s[j:]

s = s.replace(
    'local JualLogic = require(ReplicatedStorage.Shared.JualLogic)',
    'local JualLogic = require(ReplicatedStorage.Shared.JualLogic)\nlocal SemaiLogic = require(ReplicatedStorage.Shared.SemaiLogic)\nlocal UserInputService = game:GetService("UserInputService")',
)

s = s.replace('        semai = "Semai Panen",', '        semai = "Mesin Semai Panen",')

s = s.replace(
    """        if s.kind == "blok" then
                mk("Frame", { Size = UDim2.fromScale(0.62, 0.62), Position = UDim2.fromScale(0.19, 0.19), BackgroundColor3 = warna(UIStyle.AbuGelap), BorderSizePixel = 0 }, wadah)
                return
        end""",
    """        if s.kind == "blok" then
                local cropId = CropData.blokCrop(s.id)
                local bInfo = cropId and CropData.Bentuk[cropId]
                local badan = mk("Frame", { Size = UDim2.fromScale(0.62, 0.62), Position = UDim2.fromScale(0.19, 0.19), BackgroundColor3 = bInfo and warna3b(bInfo.siap) or warna(UIStyle.AbuGelap), BorderSizePixel = 0 }, wadah)
                mk("Frame", { Size = UDim2.fromScale(0.72, 0.22), Position = UDim2.fromScale(0.14, 0.12), BackgroundColor3 = bInfo and warna3b(bInfo.aksen) or warna(UIStyle.Abu), BorderSizePixel = 0, ZIndex = 2 }, badan)
                return
        end""",
)

s = s.replace(
    'slot.nama.Text = UIStyle.potong(s.kind == "blok" and "Blok Panen" or (info and info.nama or s.id))',
    'slot.nama.Text = UIStyle.potong(s.kind == "blok" and CropData.blokNamaFor(CropData.blokCrop(s.id) or "") or (info and info.nama or s.id))',
)

s = s.replace(
    """Net.get("SmashSync").OnClientEvent:Connect(function(p)
        if p.lahan == state.lahan then
                state.semai = p.slots or {}
                if currentPanel == "semai" then
                        refreshSemai()
                end
        end
end)""",
    """Net.get("SemaiSync").OnClientEvent:Connect(function(p)
        if p.lahan == state.lahan then
                state.semai = p
                if currentPanel == "semai" then
                        refreshSemai()
                end
                if p.tahap == "tuntas" then
                        toast("Semai Tuntas", "Mesin selesai menggiling! Klaim hasilmu di mesin semai.")
                end
        end
end)""",
)

anchor = "local function buyBtn(parent: Frame, text: string, posX: number, packId: string)"
struk_code = '''bukaStrukKlaim = function(s: any)
        bersihkanModalIsi()
        modalTitle.Text = "Semai Tuntas - Hasil Diklaim"
        local urutan = 0
        local function baris(ikonData: any?, teks: string, kanan: string)
                urutan += 1
                local row = mk("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = warna(UIStyle.Permukaan) }, modalIsi)
                round(row, UIStyle.SudutKecil)
                if ikonData then
                        ikonSlot(row, ikonData)
                else
                        local m = mk("Frame", { Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(0, 6, 0, 4), BackgroundColor3 = warna(UIStyle.Aksen) }, row)
                        mk("UICorner", { CornerRadius = UDim.new(0.5, 0) }, m)
                        mk("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "M", Font = FONTB, TextSize = UIStyle.UkuranKecil, TextColor3 = warna(UIStyle.Latar), ZIndex = 2 }, m)
                end
                mk("TextLabel", { Size = UDim2.new(1, -100, 0, 36), Position = UDim2.new(0, 42, 0, 0), BackgroundTransparency = 1, Text = teks, TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, row)
                mk("TextLabel", { Size = UDim2.new(0, 52, 0, 36), Position = UDim2.new(1, -56, 0, 0), BackgroundTransparency = 1, Text = kanan, TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Aksen), TextXAlignment = Enum.TextXAlignment.Right }, row)
                local skala = mk("UIScale", { Scale = 0.01 }, row)
                task.delay(0.07 * urutan, function()
                        if row.Parent then
                                TweenService:Create(skala, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
                        end
                end)
        end
        baris(nil, "+" .. fmt(s.micda or 0) .. " Micda", "Micda")
        if (s.benih or 0) > 0 then
                baris({ kind = "benih", id = s.crop, count = s.benih }, "Benih " .. UIStyle.potong(s.nama, 18), "x" .. tostring(s.benih))
        end
        if (s.blok or 0) > 0 then
                baris({ kind = "blok", id = CropData.blokIdFor(s.crop), count = s.blok }, CropData.blokNamaFor(s.crop), "x" .. tostring(s.blok))
        end
        mk("TextLabel", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = "Hasil dari " .. tostring(s.jumlah) .. " x " .. UIStyle.potong(s.nama, 14) .. " (" .. tostring(s.pukulan) .. " pukulan) — semua masuk tas", TextSize = UIStyle.UkuranKecil, Font = FON, TextColor3 = warna(UIStyle.Abu), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true }, modalIsi)
        aturModalTombol("struk")
        modalDim.Visible = true
end

'''
s = s.replace(anchor, struk_code + anchor, 1)

UI.write_text(s)
print("ok, new length:", len(s.splitlines()))
