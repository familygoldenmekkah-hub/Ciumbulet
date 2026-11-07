P = '/home/z/my-project/download/dunia-akiomida/src/Client/UIController.luau'
s = open(P).read()

def ganti(lama, baru):
    global s
    lama = lama.expandtabs(8)
    baru = baru.expandtabs(8)
    if lama not in s:
        raise SystemExit("TIDAK KETEMU: " + lama[:90])
    s = s.replace(lama, baru, 1)

ganti(
"""	if aktif then
		soalNomor.Text = "Soal " .. tostring(t.soal and t.soal.nomor or 1) .. " dari " .. tostring(t.totalSoal) .. " — tertanam " .. tostring(t.tertanam) .. "/" .. tostring(t.jumlah)
		if t.soal then
			soalTeks.Text = t.soal.teks
		end
	else
		tanamFeedback.Text = ""
	end""",
"""	if aktif then
		local nomor = t.soal and t.soal.nomor or math.min(math.floor((t.tertanam or 0) / 10) + 1, t.totalSoal or 1)
		local total = t.totalSoal or 1
		progresTeks.Text = tostring(nomor) .. "/" .. tostring(total)
		progresIsi.Size = UDim2.fromScale(math.clamp((t.tertanam or 0) / math.max(1, t.jumlah or 1), 0, 1), 1)
		if t.soal then
			soalTeks.Text = t.soal.teks
		end
	else
		tanamFeedback.Text = ""
	end""")

ganti(
"""mulaiBtn.Activated:Connect(function()
	if not selectedSeed then
		tanamFeedback.TextColor3 = warna(UIStyle.Merah)
		tanamFeedback.Text = "Pilih benih dulu di daftar."
		return
	end
	local jumlah = selectedQty
	if jumlah == nil then
		jumlah = selectedSeed and tasTotal("benih", selectedSeed) or 0
	end
	local ok, msg = Net.get("TanamAct"):InvokeServer("start", selectedSeed, jumlah)
	tanamFeedback.TextColor3 = warna(ok and UIStyle.Aksen or UIStyle.Merah)
	tanamFeedback.Text = msg
	if ok then
		refreshTanam()
	end
end)""",
"""mulaiBtn.Activated:Connect(function()
	if not selectedSeed then
		tanamFeedback.TextColor3 = warna(UIStyle.Merah)
		tanamFeedback.Text = "Pilih benih dulu di daftar."
		return
	end
	local jumlah = selectedQty
	if jumlah == nil then
		jumlah = selectedSeed and tasTotal("benih", selectedSeed) or 0
	end
	local ok, msg = Net.get("TanamAct"):InvokeServer("start", selectedSeed, jumlah)
	if ok then
		tanamFeedback.Text = ""
		refreshTanam()
	else
		tanamFeedback.TextColor3 = warna(UIStyle.Merah)
		tanamFeedback.Text = tostring(msg)
	end
end)""")

ganti(
"""soalBtn.Activated:Connect(function()
	local n = tonumber(soalJawab.Text)
	if not n then
		soalFeedback.TextColor3 = warna(UIStyle.Merah)
		soalFeedback.Text = "Masukkan angka dulu."
		return
	end
	local ok, msg = Net.get("TanamAct"):InvokeServer("jawab", n)
	soalFeedback.TextColor3 = warna(ok and UIStyle.Aksen or UIStyle.Merah)
	soalFeedback.Text = msg
	if ok then
		soalJawab.Text = ""
	end
end)""",
"""local function goyangJawab()
	soalJawab.BackgroundColor3 = warna(UIStyle.Merah)
	soalSkala.Scale = 0.96
	task.delay(0.12, function()
		soalSkala.Scale = 1.02
	end)
	task.delay(0.24, function()
		soalSkala.Scale = 1
	end)
	task.delay(0.55, function()
		soalJawab.BackgroundColor3 = warna(UIStyle.Permukaan)
	end)
end

soalBtn.Activated:Connect(function()
	local n = tonumber(soalJawab.Text)
	if not n then
		goyangJawab()
		return
	end
	local folderSebelum: { [number]: boolean } = {}
	local folder = state.zone == "dunia" and state.lahan and folderTanaman() or nil
	if folder then
		for _, m in ipairs(folder:GetChildren()) do
			if m:IsA("Model") and string.sub(m.Name, 1, 8) == "Tanaman_" then
				local idx = m:GetAttribute("PlotIdx")
				if type(idx) == "number" then
					folderSebelum[idx] = true
				end
			end
		end
	end
	local ok, msg = Net.get("TanamAct"):InvokeServer("jawab", n)
	if ok then
		soalJawab.Text = ""
		if tostring(msg) ~= "" then
			toastSaja(tostring(msg))
		end
		efekTanamanBaru(folderSebelum)
	else
		goyangJawab()
	end
end)""")

ganti(
"""batalBtn.Activated:Connect(function()
	local ok = Net.get("TanamAct"):InvokeServer("batal")
	if ok then
		state.tanam = nil
		refreshTanam()
	end
end)""",
"""batalBtn.Activated:Connect(function()
	local ok, msg = Net.get("TanamAct"):InvokeServer("batal")
	if ok then
		state.tanam = nil
		toastSaja(tostring(msg))
		refreshTanam()
	end
end)""")

ganti(
"""Net.get("TanamSync").OnClientEvent:Connect(function(p)
	state.tanam = p
	if currentPanel == "tanam" and tabAktif == "tanam" then
		refreshTanam()
	end
end)""",
"""Net.get("TanamSync").OnClientEvent:Connect(function(p)
	state.tanam = p
	if currentPanel == "tanam" and tabAktif == "tanam" then
		refreshTanam()
	end
	if p and p.selesaiTuntas == true and currentPanel == "tanam" then
		closePanel()
	end
end)""")

open(P, 'w').write(s)
print("patch tahap 2b selesai")
