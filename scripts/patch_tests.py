P = '/home/z/my-project/download/dunia-akiomida/tests/run_tests.luau'
s = open(P).read()

def ganti(lama, baru):
    global s
    lama = lama.expandtabs(8)
    baru = baru.expandtabs(8)
    if lama not in s:
        raise SystemExit("TIDAK KETEMU: " + lama[:90])
    s = s.replace(lama, baru, 1)

ganti(
"""	check("Dana awal 999.999.999.999.000 (999,99 T)", CropData.StartMoney == 999999999999000, tostring(CropData.StartMoney))""",
"""	check("Dana awal pemain baru 10.000 Micda", CropData.StartMoney == 10000, tostring(CropData.StartMoney))""")

ganti(
"""	check("Saldo awal baru tampil 999,99 T", UangSingkat.singkat(CropData.StartMoney) == "999,99 T", UangSingkat.singkat(CropData.StartMoney))
	check("Ketuk saldo: angka lengkap 999.999.999.999.000 bertitik", UangSingkat.penuh(CropData.StartMoney) == "999.999.999.999.000", UangSingkat.penuh(CropData.StartMoney))""",
"""	check("Saldo awal baru tampil 10 Rb", UangSingkat.singkat(CropData.StartMoney) == "10 Rb", UangSingkat.singkat(CropData.StartMoney))
	check("Ketuk saldo: angka lengkap 10.000 bertitik", UangSingkat.penuh(CropData.StartMoney) == "10.000", UangSingkat.penuh(CropData.StartMoney))""")

ganti(
"""	check("Ruang rekening tinggal 1.000 Micda ke atap 1000 T (jujur: hampir penuh)", UangLogic.ruangSisa(stAwal) == 1000, tostring(UangLogic.ruangSisa(stAwal)))""",
"""	check("Ruang rekening baru = atap 1000 T dikurangi 10.000", UangLogic.ruangSisa(stAwal) == 999999999990000, tostring(UangLogic.ruangSisa(stAwal)))""")

ganti(
"""	check("Ujian dimulai dari dunia baru: 999.999.999.999.000 Micda & tas kosong", micda == CropData.StartMoney and TasLogic.usedSlots(tas) == 0, tostring(micda))""",
"""	check("Ujian dimulai dari dunia baru: 10.000 Micda & tas kosong", micda == CropData.StartMoney and TasLogic.usedSlots(tas) == 0, tostring(micda))""")

ganti(
"""print(("="):rep(28))
print(string.format("HASIL: %d PASS, %d FAIL", passed, failed))""",
"""print("--- Y: Ikon koin emas Micda ---")
do
	local IkonKoin = require("./../src/Shared/IkonKoin")
	check("Ukuran koin proporsional teks (22 px teks -> 23 px koin)", IkonKoin.ukuran(22) == 23, tostring(IkonKoin.ukuran(22)))
	check("Ukuran koin minimal 12 px", IkonKoin.ukuran(4) == 12 and IkonKoin.ukuran(nil) == 21, tostring(IkonKoin.ukuran(4)) .. "/" .. tostring(IkonKoin.ukuran(nil)))
	check("Ukuran koin tahan input rusak", IkonKoin.ukuran("x") == 12 and IkonKoin.ukuran(0 / 0) == 12, "-")
end

print(("="):rep(28))
print(string.format("HASIL: %d PASS, %d FAIL", passed, failed))""")

open(P, 'w').write(s)
print("run_tests selesai")
