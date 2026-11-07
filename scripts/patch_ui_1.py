P = '/home/z/my-project/download/dunia-akiomida/src/Client/UIController.luau'
s = open(P).read()

def ganti(lama, baru, wajib=True):
    global s
    lama = lama.expandtabs(8)
    baru = baru.expandtabs(8)
    if lama not in s:
        if wajib:
            raise SystemExit("TIDAK KETEMU: " + lama[:90])
        return
    s = s.replace(lama, baru, 1)

ganti(
"""local UangSingkat = require(ReplicatedStorage.Shared.UangSingkat)""",
"""local UangSingkat = require(ReplicatedStorage.Shared.UangSingkat)
local IkonKoin = require(ReplicatedStorage.Shared.IkonKoin)""")

ganti(
"""local function warna3b(t: any): Color3
        if type(t) == "table" then
                return Color3.fromRGB(t[1] or 200, t[2] or 200, t[3] or 200)
        end
        return warna(UIStyle.Abu)
end""",
"""local function warna3b(t: any): Color3
        if type(t) == "table" then
                return Color3.fromRGB(t[1] or 200, t[2] or 200, t[3] or 200)
        end
        return warna(UIStyle.Abu)
end

local function folderTanaman(): Folder?
        local dunia = Workspace:FindFirstChild("Dunia")
        return dunia and dunia:FindFirstChild("PlotGrid_" .. tostring(state.lahan), true)
end

local function fxTumbuh(posisi: Vector3)
        local wadah = Instance.new("Part")
        wadah.Size = Vector3.new(0.4, 0.4, 0.4)
        wadah.Transparency = 1
        wadah.CFrame = CFrame.new(posisi)
        wadah.Anchored = true
        wadah.CanCollide = false
        wadah.CanQuery = false
        wadah.CanTouch = false
        wadah.Parent = Workspace
        local cahaya = Instance.new("ParticleEmitter")
        cahaya.Color = ColorSequence.new(Color3.fromRGB(160, 240, 165), Color3.fromRGB(96, 198, 112))
        cahaya.LightEmission = 0.85
        cahaya.Lifetime = NumberRange.new(0.35, 0.7)
        cahaya.Speed = NumberRange.new(2.5, 5)
        cahaya.SpreadAngle = Vector2.new(180, 180)
        cahaya.Size = NumberSequence.new(0.32, 0)
        cahaya.Enabled = false
        cahaya.Parent = wadah
        local bunyi = Instance.new("Sound")
        bunyi.SoundId = "rbxasset://sounds/electronicpingshort.wav"
        bunyi.PlaybackSpeed = 1.5
        bunyi.Volume = 0.4
        bunyi.Parent = wadah
        pcall(function()
                cahaya:Emit(14)
                bunyi:Play()
        end)
        task.delay(1.6, function()
                wadah:Destroy()
        end)
end

local function efekTanamanBaru(sebelum: { [number]: boolean })
        task.spawn(function()
                task.wait(0.14)
                local folder = state.zone == "dunia" and state.lahan and folderTanaman() or nil
                if not folder then
                        return
                end
                local jumlahFx = 0
                for _, m in ipairs(folder:GetChildren()) do
                        if m:IsA("Model") and string.sub(m.Name, 1, 8) == "Tanaman_" and jumlahFx < 12 then
                                local idx = m:GetAttribute("PlotIdx")
                                if type(idx) == "number" and not sebelum[idx] then
                                        jumlahFx += 1
                                        fxTumbuh(m:GetPivot().Position + Vector3.new(0, 0.8, 0))
                                end
                        end
                end
        end)
end""")

ganti(
"""local ikonSaldo = mk("Frame", { LayoutOrder = 1, Size = UDim2.fromOffset(HUDLayout.SaldoIkonPx, HUDLayout.SaldoIkonPx), BackgroundColor3 = warna(UIStyle.Aksen) }, saldo)
mk("UICorner", { CornerRadius = UDim.new(0.5, 0) }, ikonSaldo)
teksSkala({ Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "M", Font = FONTB, TextColor3 = warna(UIStyle.Latar) }, ikonSaldo)""",
"""local ikonSaldo = mk("Frame", { LayoutOrder = 1, Size = UDim2.fromOffset(HUDLayout.SaldoIkonPx, HUDLayout.SaldoIkonPx), BackgroundTransparency = 1 }, saldo)
IkonKoin.buat(ikonSaldo, HUDLayout.SaldoIkonPx)""")

ganti(
"""local jumpPxNyata: number? = nil""",
"""local jumpPxNyata: number? = nil
local lompatBtnNyata: GuiObject? = nil""")

ganti(
"""     jumpPxNyata = jump.AbsoluteSize.X
        aturPunch()""",
"""     jumpPxNyata = jump.AbsoluteSize.X
        lompatBtnNyata = jump
        aturPunch()""")

ganti(
"""local function closePanel()
        dim.Visible = false
        currentPanel = nil
        bukaKamera()
end""",
"""local function sembunyikanKontrol()
        punchBtn.Visible = false
        punchShadow.Visible = false
        if lompatBtnNyata then
                lompatBtnNyata.Visible = false
        end
end

local function tampilkanKontrol()
        punchBtn.Visible = true
        punchShadow.Visible = true
        if lompatBtnNyata then
                lompatBtnNyata.Visible = true
        end
end

local function closePanel()
        dim.Visible = false
        currentPanel = nil
        tampilkanKontrol()
        bukaKamera()
end""")

ganti(
"""     panelTitle.Text = PANEL_TITLES[name] or ""
        if name == "semai" then
                panelBatas.MaxSize = Vector2.new(760, 620)
        else
                panelBatas.MaxSize = Vector2.new(UIStyle.LebarPanelMaks, UIStyle.TinggiPanelMaks)
        end
        kunciKamera()
        dim.Visible = true
        currentPanel = name
end""",
"""     panelTitle.Text = PANEL_TITLES[name] or ""
        if name == "semai" or name == "tanam" then
                panelBatas.MaxSize = Vector2.new(760, 620)
        else
                panelBatas.MaxSize = Vector2.new(UIStyle.LebarPanelMaks, UIStyle.TinggiPanelMaks)
        end
        kunciKamera()
        dim.Visible = true
        currentPanel = name
        if name == "tanam" then
                sembunyikanKontrol()
        end
end""")

ganti(
"""local toastOrder = 0
local function toast(title: string, msg: string)""",
"""local toastOrder = 0

local function toastSaja(teks: string)
        toastOrder += 1
        local f = mk("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = warna(UIStyle.Latar), BackgroundTransparency = 0.1, LayoutOrder = -toastOrder }, toastHolder)
        round(f)
        mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }, f)
        mk("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, f)
        IkonKoin.buat(f, 18).LayoutOrder = 1
        mk("TextLabel", { LayoutOrder = 2, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, Text = teks, TextSize = UIStyle.UkuranIsi, Font = FONTB, TextColor3 = warna(UIStyle.Teks), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = false }, f)
        task.delay(2, function()
                f:Destroy()
        end)
end

local function toast(title: string, msg: string)""")

open(P, 'w').write(s)
print("patch tahap 1 selesai")
