P = '/home/z/my-project/download/dunia-akiomida/src/Server/Modules/TanamService.luau'
s = open(P).read()

def ganti(lama, baru):
    global s
    lama = lama.expandtabs(8)
    baru = baru.expandtabs(8)
    if lama not in s:
        raise SystemExit("TIDAK KETEMU: " + lama[:90])
    s = s.replace(lama, baru, 1)

ganti(
"""     return true, "Sesi tanam " .. info.nama .. " mulai: " .. jumlah .. " plot. Jawab soal untuk membuka 10 plot.\"""",
"""     return true, "Mulai tanam " .. info.nama""")

ganti(
"""     if s.tertanam >= s.jumlah then
                sesi[player.UserId] = nil
                sync(player, nil, true)
                return true, "Sesi tanam sudah selesai."
        end""",
"""     if s.tertanam >= s.jumlah then
                sesi[player.UserId] = nil
                sync(player, nil, true, { nama = s.nama, total = s.tertanam })
                return true, "+" .. s.tertanam .. " " .. s.nama
        end""")

ganti(
"""     if n ~= s.soal.jawab then
                sync(player, s)
                return false, "Salah! Soal tertahan sampai jawabanmu benar."
        end""",
"""     if n ~= s.soal.jawab then
                sync(player, s)
                return false, "salah"
        end""")

ganti(
"""     if tanam == 0 then
                sesi[player.UserId] = nil
                sync(player, s, true)
                return true, "Plot tidak tersedia lagi. Sesi dihentikan."
        end
        if s.tertanam >= s.jumlah then
                sesi[player.UserId] = nil
                sync(player, nil, true)
                return true, "Benar! Sesi selesai — tertanam " .. s.tertanam .. " " .. s.nama .. ". Panen dengan tombol Punch!"
        end
        s.soal = SoalLogic.buat(rng, math.floor(s.tertanam / 10) + 1, s.used)
        sync(player, s)
        return true, "Benar! " .. tanam .. " plot terisi. Soal berikutnya sudah menunggu.\"""",
"""     if tanam == 0 then
                sesi[player.UserId] = nil
                sync(player, s, true)
                return true, "Plot tidak tersedia"
        end
        if s.tertanam >= s.jumlah then
                sesi[player.UserId] = nil
                sync(player, nil, true, { nama = s.nama, total = s.tertanam })
                return true, "+" .. s.tertanam .. " " .. s.nama
        end
        s.soal = SoalLogic.buat(rng, math.floor(s.tertanam / 10) + 1, s.used)
        sync(player, s)
        return true, "+" .. tanam .. " " .. s.nama""")

ganti(
"""     return true, "Sesi tanam dibatalkan. Benih yang belum ditanam tetap di tas.\"""",
"""     return true, "Tanam dibatalkan\"""")

ganti(
"""             return true, "Benih habis. Sesi tanam dihentikan.\"""",
"""             return true, "Benih habis\"""")

open(P, 'w').write(s)
print("TanamService selesai")
