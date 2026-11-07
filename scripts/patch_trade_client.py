#!/usr/bin/env python3
"""patch_trade_client.py - integrasikan UI trade ke src/Client/UIController.luau.

Perubahan:
1. state.trade di tabel state.
2. PANEL_TITLES trade = "Trade".
3. openPanel: batal trade bila pindah panel lain; ukuran panel trade; sembunyikan kontrol.
4. closeBtn: batal trade saat menutup panel trade lewat X.
5. Sisipkan blok UI trade sebelum print penutup.
"""
import pathlib
import sys

UI = pathlib.Path("/home/z/my-project/download/dunia-akiomida/src/Client/UIController.luau")
BLOK = pathlib.Path("/home/z/my-project/scripts/trade_client_block.luau")

src = UI.read_text(encoding="utf-8")
blok = BLOK.read_text(encoding="utf-8")

gagal = []

def ganti(lama: str, baru: str, nama: str, wajib_sekali: bool = True) -> None:
    global src
    hitung = src.count(lama)
    if hitung != 1 and wajib_sekali:
        gagal.append(f"{nama}: ditemukan {hitung}x (harus 1x)")
        return
    src = src.replace(lama, baru, 1)

# 1. state table
ganti(
    """        gudang = nil,
        tanam = nil,
}""",
    """        gudang = nil,
        tanam = nil,
        trade = nil,
}""",
    "state.trade",
)

# 2. PANEL_TITLES
ganti(
    """        gudang = "Gudang Hasil Panen",
}""",
    """        gudang = "Gudang Hasil Panen",
        trade = "Trade",
}""",
    "PANEL_TITLES.trade",
)

# 3. openPanel
ganti(
    """local function openPanel(name: string)
        for n, f in pairs(panels) do
                f.Visible = n == name
        end
        panelTitle.Text = PANEL_TITLES[name] or ""
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
end""",
    """local function openPanel(name: string)
        if state.trade and name ~= "trade" then
                task.spawn(function()
                        pcall(function()
                                Net.get("TradeAct"):InvokeServer("batal")
                        end)
                end)
        end
        for n, f in pairs(panels) do
                f.Visible = n == name
        end
        panelTitle.Text = PANEL_TITLES[name] or ""
        if name == "semai" or name == "tanam" or name == "trade" then
                panelBatas.MaxSize = Vector2.new(820, 660)
        else
                panelBatas.MaxSize = Vector2.new(UIStyle.LebarPanelMaks, UIStyle.TinggiPanelMaks)
        end
        kunciKamera()
        dim.Visible = true
        currentPanel = name
        if name == "tanam" or name == "trade" then
                sembunyikanKontrol()
        end
end""",
    "openPanel",
)

# 4. closeBtn
ganti(
    """closeBtn.Activated:Connect(closePanel)""",
    """closeBtn.Activated:Connect(function()
        local tradeTerbuka = currentPanel == "trade" and state.trade ~= nil
        closePanel()
        if tradeTerbuka then
                task.spawn(function()
                        pcall(function()
                                Net.get("TradeAct"):InvokeServer("batal")
                        end)
                end)
        end
end)""",
    "closeBtn",
)

# 5. sisip blok sebelum print penutup
penanda = 'print("[AKIOMIDA] UI siap.")'
if src.count(penanda) != 1:
    gagal.append(f"penanda penutup: ditemukan {src.count(penanda)}x")
else:
    src = src.replace(penanda, blok.rstrip() + "\n\n" + penanda, 1)

if gagal:
    print("GAGAL:")
    for g in gagal:
        print(" -", g)
    sys.exit(1)

UI.write_text(src, encoding="utf-8")
print("OK: UIController.luau dipatch (state, judul, openPanel, closeBtn, blok trade)")
