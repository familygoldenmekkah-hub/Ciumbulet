P = '/home/z/my-project/scripts/panen_massa.luau'
s = open(P).read()

def ganti(lama, baru):
    global s
    lama = lama.expandtabs(8)
    baru = baru.expandtabs(8)
    if lama not in s:
        raise SystemExit("TIDAK KETEMU: " + lama[:90])
    s = s.replace(lama, baru, 1)

ganti(
'check("Soal 1 dari 5 tampil", findGui(gui, "TextLabel", "Soal 1 dari 5") ~= nil, "-")',
'check("Progres sederhana 1/5 tampil tanpa gaya kuis", findGui(gui, "TextLabel", "1/5") ~= nil and findGui(gui, "TextLabel", "Soal 1 dari") == nil, "-")')

ganti(
"""check("Benih wortel sisa 5", tasCount(P1, "benih", "wortel") == 5, tostring(tasCount(P1, "benih", "wortel")))""",
"""check("Panel papan menutup sendiri setelah soal terakhir", gui:FindFirstChild("DimLayar") ~= nil and gui:FindFirstChild("DimLayar").Visible == false, "-")
check("Tombol punch tampil kembali setelah sesi selesai", gui:FindFirstChild("TombolPunch") ~= nil and gui:FindFirstChild("TombolPunch").Visible == true, "-")
check("Toast netral '+50 Wortel' tampil", findGui(gui, "TextLabel", "+50 Wortel") ~= nil, "-")
Stub.Scheduler.advance(2.1)
check("Toast 50 hilang sendiri dalam 2 detik", findGui(gui, "TextLabel", "+50 Wortel") == nil, "-")
check("Benih wortel sisa 5", tasCount(P1, "benih", "wortel") == 5, tostring(tasCount(P1, "benih", "wortel")))""")

open(P, 'w').write(s)
print("massa selesai")
