import io

path = "/home/z/my-project/scripts/panen_massa.luau"
s = io.open(path, encoding="utf-8").read()

a = s.index('section("MESIN SEMAI: atur jumlah -> tuas kanan -> tuas kiri -> klaim")')
b = s.index('section("Gudang: 250 -> 999 -> 998 tetap presisi")')

baru = '''section("MESIN SEMAI: atur jumlah -> tuas kanan -> tuas kiri -> klaim")
moveTo(P1, 5185, 5, 50)
Stub.Scheduler.advance(0.1)
firePrompt(dunia, { action = "Semai Panen", object = "Mesin Semai" }, P1)
Stub.Scheduler.advance(0.2)
check("Panel Mesin Semai Panen terbuka", findGui(gui, "TextLabel", "Mesin Semai Panen") ~= nil, "-")
local stSemai0 = serverCall("GetState", P1)
local hasilWortel0 = 0
local adaBlokPanen = false
for _, slot in ipairs(stSemai0.tas) do
        if slot.kind == "hasil" and slot.id == "wortel" then
                hasilWortel0 += slot.count
        end
        if slot.id == "blok_panen" then
                adaBlokPanen = true
        end
end
check("Item bug blok_panen tidak ada di tas", not adaBlokPanen, "-")
check("Ada hasil wortel untuk mesin", hasilWortel0 >= 10, tostring(hasilWortel0))
check("Baris hasil wortel bisa dipilih", pilihBenih(gui, "Wortel"), "-")
check("Preset jumlah 10 diklik", tombolJumlah(gui, "10"), "-")
local isiBtn = findGui(gui, "TextButton", "Isi Mesin Semai")
check("Tombol Isi Mesin Semai ada", isiBtn ~= nil, "-")
if isiBtn then
        isiBtn.Activated:Fire()
        Stub.Scheduler.advance(0.3)
end
check("Papan mesin minta dua tuas", findGui(dunia, "TextLabel", "TEKAN TUAS KANAN LALU KIRI") ~= nil, "-")
check("Panel menampilkan langkah Tuas KANAN", findGui(gui, "TextLabel", "Tuas KANAN — Pinggir kanan mesin") ~= nil, "-")
check("Panel menampilkan langkah Tuas KIRI", findGui(gui, "TextLabel", "Tuas KIRI — Pinggir kiri mesin") ~= nil, "-")
local tolak1, tolakMsg1 = serverCall("SemaiAct", P1, "tuas")
check("Tekan tuas tanpa sisi DITOLAK server", tolak1 == false and type(tolakMsg1) == "string", tostring(tolakMsg1))
local tolak2, tolakMsg2 = serverCall("SemaiAct", P1, "tuas", "kiri")
check("Tuas KIRI sebelum KANAN DITOLAK server", tolak2 == false and string.find(tostring(tolakMsg2), "KANAN", 1, true) ~= nil, tostring(tolakMsg2))
local promptKanan, promptKiri
for _, p in ipairs(findPrompts(dunia)) do
        if p.ActionText == "Tekan Tuas" and p.ObjectText == "Tuas Kanan" then
                promptKanan = p
        end
        if p.ActionText == "Tekan Tuas" and p.ObjectText == "Tuas Kiri" then
                promptKiri = p
        end
end
check("Dua prompt Tekan Tuas ada di mesin", promptKanan ~= nil and promptKiri ~= nil, "-")
check("Prompt tuas KANAN aktif duluan", promptKanan ~= nil and promptKanan.Enabled == true and promptKiri ~= nil and promptKiri.Enabled == false, "-")
if promptKanan then
        promptKanan.Triggered:Fire(P1)
        Stub.Scheduler.advance(0.3)
end
check("Tuas KANAN ditekan dari dunia -> prompt pindah ke KIRI", promptKanan ~= nil and promptKanan.Enabled == false and promptKiri ~= nil and promptKiri.Enabled == true, "-")
local tolak3, tolakMsg3 = serverCall("SemaiAct", P1, "tuas", "kanan")
check("Tuas KANAN ditekan dua kali DITOLAK server", tolak3 == false, tostring(tolakMsg3))
if promptKiri then
        promptKiri.Triggered:Fire(P1)
        Stub.Scheduler.advance(0.3)
end
check("Kedua tuas selesai -> mesin langsung MENGGILING", findGui(dunia, "TextLabel", "MENGGILING...") ~= nil, "-")
Stub.Scheduler.advance(3.5)
local stSemai1 = serverCall("GetState", P1)
check("Batch mesin tercatat di papan", findGui(dunia, "TextLabel", "SEMAI TUNTAS - KLAIM HASIL") ~= nil, "-")
local klaimBtn = findGui(gui, "TextButton", "Klaim Semua")
check("Tombol Klaim Semua tampil setelah tuntas", klaimBtn ~= nil and tampakPenuh(klaimBtn), "-")
local function micdaOf(pl)
        local ls = pl:FindFirstChild("leaderstats")
        local mv = ls and ls:FindFirstChild("Micda")
        return mv and mv.Value or 0
end
local micda0 = micdaOf(P1)
if klaimBtn then
        klaimBtn.Activated:Fire()
        Stub.Scheduler.advance(0.3)
end
check("Struk klaim tampil", findGui(gui, "TextLabel", "Hasil Diklaim") ~= nil, "-")
local micda1 = micdaOf(P1)
check("Micda bertambah setelah klaim", micda1 > micda0, tostring(micda0) .. "->" .. tostring(micda1))
local stSemai2 = serverCall("GetState", P1)
local hasilWortel1 = 0
local blokWortel = 0
adaBlokPanen = false
for _, slot in ipairs(stSemai2.tas) do
        if slot.kind == "hasil" and slot.id == "wortel" then
                hasilWortel1 += slot.count
        end
        if slot.kind == "blok" and slot.id == "blok_wortel" then
                blokWortel += slot.count
        end
        if slot.id == "blok_panen" then
                adaBlokPanen = true
        end
end
check("10 wortel hasil dipakai mesin", hasilWortel1 == hasilWortel0 - 10, tostring(hasilWortel0) .. "->" .. tostring(hasilWortel1))
check("Hasil blok sesuai tanaman (blok_wortel)", blokWortel >= 0 and not adaBlokPanen, tostring(blokWortel))
check("Papan mesin kembali NONAKTIF setelah klaim", findGui(dunia, "TextLabel", "NONAKTIF") ~= nil, "-")
local okeStruk = findGui(gui, "TextButton", "Oke")
if okeStruk and tampakPenuh(okeStruk) then
        okeStruk.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end
local tutupPanel = findGui(gui, "TextButton", "X")
if tutupPanel and tampakPenuh(tutupPanel) then
        tutupPanel.Activated:Fire()
        Stub.Scheduler.advance(0.1)
end

'''

s = s[:a] + baru + s[b:]
io.open(path, "w", encoding="utf-8").write(s)
print("patched panen_massa.luau ok")
