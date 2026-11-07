P = '/home/z/my-project/scripts/playtest.luau'
s = open(P).read()

def ganti(lama, baru):
    global s
    lama = lama.expandtabs(8)
    baru = baru.expandtabs(8)
    if lama not in s:
        raise SystemExit("TIDAK KETEMU: " + lama[:90])
    s = s.replace(lama, baru, 1)

ganti("m = 999999999999000,", "m = 10000,")
ganti(
'check("Micda awal 999.999.999.999.000", ls and ls:FindFirstChild("Micda") and ls:FindFirstChild("Micda").Value == 999999999999000, tostring(ls and ls:FindFirstChild("Micda").Value))',
'check("Micda awal pemain 10.000", ls and ls:FindFirstChild("Micda") and ls:FindFirstChild("Micda").Value == 10000, tostring(ls and ls:FindFirstChild("Micda").Value))')
ganti(
'check("Saldo awal tampil singkat 999,99 T", angkaHUD ~= nil and angkaHUD.Text == "999,99 T", angkaHUD and angkaHUD.Text or "hilang")',
'check("Saldo awal tampil singkat 10 Rb", angkaHUD ~= nil and angkaHUD.Text == "10 Rb", angkaHUD and angkaHUD.Text or "hilang")')
ganti(
'check("Ketuk 1: angka lengkap bertitik 999.999.999.999.000", angkaHUD ~= nil and angkaHUD.Text == "999.999.999.999.000", angkaHUD and angkaHUD.Text or "hilang")',
'check("Ketuk 1: angka lengkap bertitik 10.000", angkaHUD ~= nil and angkaHUD.Text == "10.000", angkaHUD and angkaHUD.Text or "hilang")')
ganti(
'check("Ketuk 2: kembali ke singkatan 999,99 T", angkaHUD ~= nil and angkaHUD.Text == "999,99 T", angkaHUD and angkaHUD.Text or "hilang")',
'check("Ketuk 2: kembali ke singkatan 10 Rb", angkaHUD ~= nil and angkaHUD.Text == "10 Rb", angkaHUD and angkaHUD.Text or "hilang")')
ganti(
'check("Micda belum terpotong sebelum Ya", ls and ls:FindFirstChild("Micda").Value == 999999999999000, tostring(ls and ls:FindFirstChild("Micda").Value))',
'check("Micda belum terpotong sebelum Ya", ls and ls:FindFirstChild("Micda").Value == 10000, tostring(ls and ls:FindFirstChild("Micda").Value))')
ganti(
'return m ~= nil and m.Visible == false and ls and ls:FindFirstChild("Micda").Value == 999999999999000',
'return m ~= nil and m.Visible == false and ls and ls:FindFirstChild("Micda").Value == 10000')
ganti(
'check("Beli setelah Ya (999.999.999.999.000 - 2.400 = 999.999.999.996.600)", micdaAfterBuy == 999999999996600, tostring(micdaAfterBuy))',
'check("Beli setelah Ya (10.000 - 2.400 = 7.600)", micdaAfterBuy == 7600, tostring(micdaAfterBuy))')

ganti(
"""check("Kotak saldo melebar otomatis (AutomaticSize X)", saldoHUD ~= nil and saldoHUD.AutomaticSize == Enum.AutomaticSize.X, saldoHUD and tostring(saldoHUD.AutomaticSize))""",
"""check("Kotak saldo melebar otomatis (AutomaticSize X)", saldoHUD ~= nil and saldoHUD.AutomaticSize == Enum.AutomaticSize.X, saldoHUD and tostring(saldoHUD.AutomaticSize))
check("Ikon koin emas di HUD, tanpa huruf M", saldoHUD ~= nil and saldoHUD:FindFirstChild("IkonKoin", true) ~= nil and (function()
	for _, d in ipairs(saldoHUD:GetDescendants()) do
		if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text == "M" then
			return false
		end
	end
	return true
end)(), "-")""")

ganti(
"""local soal1 = findSoalTeks(gui)
check("Soal matematika muncul di papan", soal1 ~= nil, soal1 and soal1.Text or "hilang")

local label0 = findGui(dunia, "TextLabel", "TERTANAM 0/500")
check("Papan menampilkan TERTANAM 0/500 sebelum jawab", label0 ~= nil, "-")

if soal1 then
	local box = findTextBoxByPlaceholder(gui, "Tulis jawaban angka")
	box.Text = "999999"
	local jawabBtn = findGui(gui, "TextButton", "Jawab")
	jawabBtn.Activated:Fire()
	Stub.Scheduler.advance(0.1)
end
local salah = findGui(gui, "TextLabel", "Salah")
check("Jawaban salah tertahan (pesan di dalam papan)", salah ~= nil, salah and salah.Text or "-")
local masih0 = findGui(dunia, "TextLabel", "TERTANAM 0/500")
check("Jawaban salah tidak membuka plot", masih0 ~= nil, "-")

burn(1.2)
local okJ1, detJ1 = jawabSoal(gui)
Stub.Scheduler.advance(0.1)
check("Jawaban benar diterima server", okJ1 == true, tostring(detJ1))
local label10 = findGui(dunia, "TextLabel", "TERTANAM 10/500")
check("10 plot terisi setelah 1 soal benar", label10 ~= nil, label10 and label10.Text or "-")""",
"""local soal1 = findSoalTeks(gui)
check("Soal matematika muncul di papan", soal1 ~= nil, soal1 and soal1.Text or "hilang")
check("Progres sederhana 1/1 tampil", findGui(gui, "TextLabel", "1/1") ~= nil, "-")
check("Teks gaya kuis 'Soal 1 dari' hilang", findGui(gui, "TextLabel", "Soal 1 dari") == nil, "-")
check("Tombol punch disembunyikan saat panel terbuka", gui:FindFirstChild("TombolPunch") ~= nil and gui:FindFirstChild("TombolPunch").Visible == false, "-")

local label0 = findGui(dunia, "TextLabel", "TERTANAM 0/500")
check("Papan menampilkan TERTANAM 0/500 sebelum jawab", label0 ~= nil, "-")

if soal1 then
	local box = findTextBoxByPlaceholder(gui, "Tulis jawaban angka")
	box.Text = "999999"
	local jawabBtn = findGui(gui, "TextButton", "Jawab")
	jawabBtn.Activated:Fire()
	Stub.Scheduler.advance(0.1)
end
local boxSalah = findTextBoxByPlaceholder(gui, "Tulis jawaban angka")
check("Jawaban salah: kolom memerah, tanpa kalimat kuis", boxSalah ~= nil and boxSalah.BackgroundColor3 == Color3.fromRGB(178, 84, 72) and findGui(gui, "TextLabel", "Salah") == nil, boxSalah and tostring(boxSalah.BackgroundColor3) or "hilang")
local masih0 = findGui(dunia, "TextLabel", "TERTANAM 0/500")
check("Jawaban salah tidak membuka plot", masih0 ~= nil, "-")
Stub.Scheduler.advance(0.7)
local boxPulih = findTextBoxByPlaceholder(gui, "Tulis jawaban angka")
check("Kolom input pulih ke warna normal", boxPulih ~= nil and boxPulih.BackgroundColor3 == Color3.fromRGB(32, 35, 42), boxPulih and tostring(boxPulih.BackgroundColor3) or "hilang")

burn(1.2)
local okJ1, detJ1 = jawabSoal(gui)
Stub.Scheduler.advance(0.3)
check("Jawaban benar diterima server", okJ1 == true, tostring(detJ1))
check("Tanaman muncul dengan efek partikel singkat", countClass(Workspace, "ParticleEmitter") >= 1, tostring(countClass(Workspace, "ParticleEmitter")))
check("Tanaman muncul dengan suara pendek", countClass(Workspace, "Sound") >= 1, tostring(countClass(Workspace, "Sound")))
check("Toast netral '+10 Wortel' tampil", findGui(gui, "TextLabel", "+10 Wortel") ~= nil, "-")
local label10 = findGui(dunia, "TextLabel", "TERTANAM 10/500")
check("10 plot terisi setelah 1 soal benar", label10 ~= nil, label10 and label10.Text or "-")
check("Panel papan menutup sendiri setelah sesi selesai", gui:FindFirstChild("DimLayar") ~= nil and gui:FindFirstChild("DimLayar").Visible == false, "-")
check("Tombol punch tampil kembali setelah panel tutup", gui:FindFirstChild("TombolPunch") ~= nil and gui:FindFirstChild("TombolPunch").Visible == true, "-")
Stub.Scheduler.advance(2.0)
check("Toast hilang sendiri dalam 2 detik", findGui(gui, "TextLabel", "+10 Wortel") == nil, "-")""")

open(P, 'w').write(s)
print("playtest selesai")
