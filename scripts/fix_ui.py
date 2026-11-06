import re

p = "/home/z/my-project/download/dunia-akiomida/src/Client/UIController.luau"
src = open(p, encoding="utf-8").read()

def cut(src, start_anchor, end_anchor, replacement):
    i = src.index(start_anchor)
    j = src.index(end_anchor, i) + len(end_anchor)
    return src[:i] + replacement + src[j:]

src = src.replace('        combine = "Gabung Benih",\n', '')

src = src.replace(
    'local gabungBtn = mk("TextButton", { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -8, 1, -6), Size = UDim2.new(0, 190, 0, 34), BackgroundColor3 = Color3.fromRGB(46, 110, 62), Text = "Gabung Benih", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1) }, tasPanel)\nround(gabungBtn)\n',
    'local hintGabung = mk("TextLabel", { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -8, 1, -6), Size = UDim2.new(0.5, -12, 0, 28), BackgroundTransparency = 1, Text = "Mau gabung benih? Tanam 2 benih resep di plot bertetangga di lahanku.", TextWrapped = true, TextScaled = true, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(150, 200, 130), TextXAlignment = Enum.TextXAlignment.Right }, tasPanel)\n'
)

src = cut(
    src,
    'local combinePanel = makePanel("combine")',
    'round(combineBtn)\n\n',
    ''
)

src = src.replace(
    'Text = "Setiap pemain punya dunia pribadi terpisah. Tamu bisa berkunjung tanpa bisa mengubah apa pun. Tidak perlu mengatur ID apa pun."',
    'Text = "Duniamu terbuka seketika tanpa loading dan tanpa ID. Tamu bisa berkunjung dan tidak bisa mengubah apa pun."'
)

old_handlers = '''masukBtn.Activated:Connect(function()
        local ok, msg = Net.get("DuniaAct"):InvokeServer("masuk")
        toast(ok and "Gerbang Dunia" or "Gagal", msg)
end)
kunjungiBtn.Activated:Connect(function()
        local ok, msg = Net.get("DuniaAct"):InvokeServer("kunjungi", kunjungiNama.Text)
        toast(ok and "Kunjungan" or "Gagal", msg)
end)
'''
new_handlers = '''local function syncState()
        task.spawn(function()
                local st = Net.get("GetState"):InvokeServer()
                if st then
                        state.micda = st.micda or 0
                        state.tas = st.tas or {}
                        state.lahan = st.lahan
                        state.zone = st.zone or "kota"
                        state.dunia = st.dunia
                        state.role = st.role or "hub"
                        micdaLabel.Text = fmt(state.micda) .. " Micda"
                        if state.zone == "dunia" then
                                zonaLabel.Text = "Dunia " .. tostring(state.dunia or "Petani")
                        else
                                zonaLabel.Text = "Pusat Kota"
                        end
                        refreshTas()
                end
        end)
end

masukBtn.Activated:Connect(function()
        local ok, msg = Net.get("DuniaAct"):InvokeServer("masuk")
        toast(ok and "Gerbang Dunia" or "Gagal", msg)
        if ok then
                syncState()
        end
end)
kunjungiBtn.Activated:Connect(function()
        local ok, msg = Net.get("DuniaAct"):InvokeServer("kunjungi", kunjungiNama.Text)
        toast(ok and "Kunjungan" or "Gagal", msg)
        if ok then
                syncState()
        end
end)
'''
assert old_handlers in src
src = src.replace(old_handlers, new_handlers)

src = cut(
    src,
    'local function buildSeedColumn(col: ScrollingFrame, isA: boolean)',
    'local plotPanel = makePanel("plot")',
    'local plotPanel = makePanel("plot")'
)

src = cut(
    src,
    'gabungBtn.Activated:Connect(function()',
    '        refreshCombine()\nend)\n\n',
    ''
)

old_sync = '''Net.get("Sync").OnClientEvent:Connect(function(payload)
        state.micda = payload.micda
        state.tas = payload.tas or {}
        micdaLabel.Text = fmt(state.micda) .. " Micda"
        refreshTas()
        if currentPanel == "combine" then
                refreshCombine()
        elseif currentPanel == "semai" then'''
new_sync = '''Net.get("Sync").OnClientEvent:Connect(function(payload)
        state.micda = payload.micda
        state.tas = payload.tas or {}
        micdaLabel.Text = fmt(state.micda) .. " Micda"
        if payload.zone then
                state.zone = payload.zone
                state.dunia = payload.dunia
                if state.zone == "dunia" then
                        zonaLabel.Text = "Dunia " .. tostring(state.dunia or "Petani")
                else
                        zonaLabel.Text = "Pusat Kota"
                end
        end
        refreshTas()
        if currentPanel == "semai" then'''
assert old_sync in src
src = src.replace(old_sync, new_sync)

old_open = '''        elseif name == "gerbang" then
                openPanel("gerbang")
        elseif name == "combine" then
                openPanel("combine")
                refreshCombine()
        end'''
new_open = '''        elseif name == "gerbang" then
                openPanel("gerbang")
        end'''
assert old_open in src
src = src.replace(old_open, new_open)

src = src.replace(
    'Text = "Pack berisi 3 benih acak sesuai kategori. Toko juga membeli hasil panenmu."',
    'Text = "Ambil pack benih lewat kasir atau rak berisi benih. Pack berisi 3 benih acak; toko juga membeli hasil panenmu."'
)

open(p, "w", encoding="utf-8").write(src)
print("OK")
