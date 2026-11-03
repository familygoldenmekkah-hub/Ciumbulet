--!nonstrict
--[[
        MathGen.luau
        Generator soal matematika prosedural (karya original, gaya edukatif
        peduli umpan balik). Satu generator per zona, tingkat kesulitan naik.

        Output per soal:
        { t = teks soal, opsi = {3 teks}, benar = index (1..3),
          betul = pujian/penguatan, salah = petunjuk lembut }
]]

local MathGen = {}

local function shuffledOptions(correct: number, decoys: { number }): ({ string }, number)
        local opts = { tostring(correct) }
        for _, d in decoys do
                if #opts >= 3 then
                        break
                end
                if d ~= correct then
                        table.insert(opts, tostring(d))
                end
        end
        -- fallback decoys bila kurang
        local filler = correct + 1
        while #opts < 3 do
                if filler ~= correct and table.find(opts, tostring(filler)) == nil then
                        table.insert(opts, tostring(filler))
                end
                filler += 1
        end
        -- shuffle
        for i = #opts, 2, -1 do
                local j = math.random(1, i)
                opts[i], opts[j] = opts[j], opts[i]
        end
        local correctIndex = table.find(opts, tostring(correct)) or 1
        return opts, correctIndex
end

local function question(t: string, correct: number, decoys: { number }, betul: string, salah: string)
        local opsi, benar = shuffledOptions(correct, decoys)
        return { t = t, opsi = opsi, benar = benar, betul = betul, salah = salah }
end

local function near(n: number): { number }
        -- decoys "klik terdekat" yang masuk akal secara pedagogis
        local out = {}
        local candidates = { n + 1, n - 1, n + 2, n - 2, n + 10, n - 10, n * 2 }
        for _, c in candidates do
                if c >= 0 and c ~= n and table.find(out, c) == nil then
                        table.insert(out, c)
                end
        end
        return out
end

--------------------------------------------------------------------
-- ZONA 1: KAMP ANGKA - berhitung dasar
--------------------------------------------------------------------
local function kamp(): any
        local pick = math.random(1, 4)
        if pick == 1 then
                local a, b = math.random(2, 9), math.random(2, 9)
                return question(
                        ("Tenda butuh %d tiang. Sudah berdiri %d. Berapa tiang lagi yang harus dipasang?"):format(a + b, a),
                        b,
                        near(b),
                        ("Tepat! Dari %d menuju %d: %d langkah. Satu tiang berdiri!"):format(a, a + b, b),
                        "Hitung maju pelan-pelan dari " .. a .. " sampai " .. (a + b) .. ". Berapa langkah itu?"
                )
        elseif pick == 2 then
                local a, b = math.random(2, 6), math.random(2, 6)
                return question(
                        ("Kayu unggun disusun %d tumpukan, tiap tumpukan berisi %d kayu. Semuanya berapa kayu?"):format(a, b),
                        a * b,
                        near(a * b),
                        ("Benar! %d x %d = %d. Menjumlah berulang seperti ini adalah bibit perkalian!"):format(a, b, a * b),
                        "Coba hitung tumpuk demi tumpuk, tambahkan terus jumlahnya."
                )
        elseif pick == 3 then
                local total = math.random(5, 12)
                local ambil = math.random(1, total - 2)
                return question(
                        (("%d batu dikumpulkan, lalu %d dipakai bikin tungku. Sisa berapa batu?"):format(total, ambil)),
                        total - ambil,
                        near(total - ambil),
                        "Benar! Mengambil dari jumlah itu artinya berkurang.",
                        "Mulai dari " .. total .. ", lalu hitung mundur sebanyak " .. ambil .. "."
                )
        else
                local domba, kandang = math.random(6, 15), math.random(2, 5)
                return question(
                        (("%d domba dibagi rata ke %d kandang. Tiap kandang berisi berapa domba?"):format(domba, kandang)),
                        math.floor(domba / kandang),
                        near(math.floor(domba / kandang)),
                        "Benar! Membagi rata = membagi sama besar ke tiap kelompok.",
                        ("Bayangkan membagikan domba satu per satu bergiliran ke %d kandang."):format(kandang)
                )
        end
end

--------------------------------------------------------------------
-- ZONA 2: HUTAN SIMBOL - tanda, urutan operasi, bilangan negatif
--------------------------------------------------------------------
local function hutan(): any
        local pick = math.random(1, 4)
        if pick == 1 then
                local a, b, c = math.random(2, 6), math.random(2, 6), math.random(2, 6)
                local correct = a + b * c
                return question(
                        ("Berapa hasil dari %d + %d x %d?"):format(a, b, c),
                        correct,
                        { a * b + c, correct + b, correct - a },
                        "Benar! Kali dulu, baru tambah - urutan operasi menyelamatkanmu.",
                        "Ingat aturan hutan: kali dibahas lebih dulu daripada tambah."
                )
        elseif pick == 2 then
                local a = math.random(3, 12)
                local b = math.random(1, a + 4)
                local correct = a - b
                return question(
                        ("Suhu di hutan %d derajat, malamnya turun %d derajat. Suhu sekarang?"):format(a, b),
                        correct,
                        { a + b, math.abs(correct) + 1, correct + 1 },
                        "Benar! Turun dari angka positif bisa mendarat di wilayah negatif.",
                        "Melangkah mundur dari " .. a .. " sebanyak " .. b .. " kali - bisa lewat nol!"
                )
        elseif pick == 3 then
                local a, b = math.random(-9, 9), math.random(-9, 9)
                if a == b then
                        b = b + 1
                end
                local larger = math.max(a, b)
                return question(
                        ("Mana yang LEBIH BESAR: %d atau %d?"):format(a, b),
                        larger,
                        { math.min(a, b), math.abs(a), math.abs(b) },
                        "Benar! Garis bilangan: makin ke kanan makin besar, minus itu di kiri nol.",
                        "Bayangkan garis bilangan: -5 -4 -3 -2 -1 0 1 2 3 ..."
                )
        else
                local a, b = math.random(2, 9), math.random(2, 9)
                local correct = a * b
                return question(
                        ("Simbol misteri: %d ? %d = %d. Simbol ? seharusnya..."):format(a, b, correct),
                        correct,
                        { a + b, correct + a, math.abs(a - b) },
                        "Benar! Tanda itu tanda kali - simbol punya makna, bukan hiasan.",
                        "Periksa: apakah hasilnya jauh lebih besar dari kedua bilangan? Itu petunjuk perkalian."
                )
        end
end

--------------------------------------------------------------------
-- ZONA 3: PEGUNUNGAN POLA - pola barisan
--------------------------------------------------------------------
local function gunung(): any
        local pick = math.random(1, 3)
        if pick == 1 then
                local start, step = math.random(1, 9), math.random(2, 7)
                local seq = { start, start + step, start + 2 * step, start + 3 * step }
                local nxt = start + 4 * step
                return question(
                        ("Barisan gunung: %d, %d, %d, %d, ... Berapa angka berikutnya?"):format(seq[1], seq[2], seq[3], seq[4]),
                        nxt,
                        { nxt + step, nxt - 1, seq[4] + 1 },
                        ("Benar! Beda tetap +%d. Pola itu tangganya."):format(step),
                        "Cari selisih dua angka yang berdekatan - selisihnya selalu sama."
                )
        elseif pick == 2 then
                local start = math.random(1, 4)
                local seq = { start, start * 2, start * 4, start * 8 }
                local nxt = start * 16
                return question(
                        ("Jejak di gunung: %d, %d, %d, %d, ... angka berikutnya?"):format(seq[1], seq[2], seq[3], seq[4]),
                        nxt,
                        { start * 12, nxt + 2, seq[4] + 8 },
                        "Benar! Tiap langkah dikali 2 - pola perkalian meledak tingginya!",
                        "Bandingkan tiap angka dengan sebelumnya: berapa kali lipat?"
                )
        else
                local rows = math.random(3, 8)
                local correct = rows * (rows + 1) / 2
                return question(
                        ("Susunan kaki gunung: baris 1 ada 1 batu, baris 2 ada 2 batu, sampai baris %d. Total batu?"):format(rows),
                        correct,
                        near(correct),
                        "Benar! 1+2+...+n = n(n+1)/2 - pola segitiga legendaris.",
                        "Jumlahkan bertahap: 1+2=3, 3+3=6, 6+4=10 ... terus sampai baris " .. rows .. "."
                )
        end
end

--------------------------------------------------------------------
-- ZONA 4: KOTA BUKTI - aljabar & pembuktian sederhana
--------------------------------------------------------------------
local function kota(): any
        local pick = math.random(1, 3)
        if pick == 1 then
                local a = math.random(2, 9)
                local x = math.random(2, 9)
                local b = math.random(1, 9)
                return question(
                        ("Selesaikan: %dx + %d = %d. Berapa x?"):format(a, b, a * x + b),
                        x,
                        { x + 1, x - 1, a + x },
                        "Benar! Pindahkan konstanta, lalu bagi - kasus hukum di Kota Bukti selesai.",
                        "Kurangi kedua ruas dengan " .. b .. " dulu, baru bagi dengan " .. a .. "."
                )
        elseif pick == 2 then
                local a, b = math.random(2, 12), math.random(2, 12)
                local correct = a * a + b
                return question(
                        ("Klaim warga: %d x %d + %d = %d. Benar atau tidak? (pilih nilai yang benar)"):format(a, a, b, correct + 2),
                        correct,
                        { correct + 2, a * a - b, a * 2 + b },
                        "Benar! Hitung sendiri = membuktikan. Itu jiwa Kota Bukti.",
                        "Kuadratkan dulu, lalu tambahkan. Jangan percaya klaim tanpa perhitungan!"
                )
        else
                local n = math.random(4, 12)
                local correct = n * n
                return question(
                        ("Luas pelataran kota berbentuk persegi dengan sisi %d. Berapa luasnya?"):format(n),
                        correct,
                        { 4 * n, n * 2, correct + n },
                        "Benar! Luas persegi = sisi x sisi. Bukti geometris selesai.",
                        "Luas bukan keliling - keliling yang 4 x sisi."
                )
        end
end

--------------------------------------------------------------------
-- ZONA 5: LEMBAH KEDALAMAN - pangkat, akar, fungsi
--------------------------------------------------------------------
local function lembah(): any
        local pick = math.random(1, 3)
        if pick == 1 then
                local base = math.random(2, 6)
                local exp = math.random(2, 3)
                local correct = base ^ exp
                return question(
                        ("Teropong riset memperbesar %d kali tiap lapis. Setelah %d lapis: berapa %d^%d?"):format(base, exp, base, exp),
                        correct,
                        { base * exp, correct + base, correct - base },
                        "Benar! Pangkat = perkalian berulang. Semakin dalam, semakin terpahami.",
                        ("%d dipangkatkan %d artinya %d dikalikan dirinya sendiri %d kali."):format(base, exp, base, exp)
                )
        elseif pick == 2 then
                local x = math.random(1, 8)
                local a, b = math.random(2, 5), math.random(1, 6)
                local correct = a * x + b
                return question(
                        ("Fungsi f(x) = %dx + %d. Berapa f(%d)?"):format(a, b, x),
                        correct,
                        near(correct),
                        ("Benar! Masukkan %d ke x: %d(%d) + %d = %d."):format(x, a, x, b, correct),
                        ("Ganti setiap x dengan %d, lalu hitung sesuai urutan operasi."):format(x)
                )
        else
                local root = math.random(2, 12)
                local square = root * root
                return question(
                        ("Akar dari %d?"):format(square),
                        root,
                        { root + 1, root - 1, root * 2 },
                        ("Benar! %d x %d kembali ke %d. Akar adalah kebalikan kuadrat."):format(root, root, square),
                        "Coba kuadratkan pilihan-pilihannya - mana yang kembali ke " .. square .. "?"
                )
        end
end

--------------------------------------------------------------------
-- ZONA 6: PUNCAK RISET - prima, modulo, nalar tingkat lanjut
--------------------------------------------------------------------
local function salju(): any
        local pick = math.random(1, 3)
        if pick == 1 then
                local primes = { 7, 11, 13, 17, 19, 23 }
                local p = primes[math.random(1, #primes)]
                local composites = { 9, 15, 21, 25, 27, 33 }
                local c = composites[math.random(1, #composites)]
                local correct = math.random() < 0.5 and p or c
                local askPrima = correct == p
                return question(
                        ("Manakah bilangan PRIMA: %d atau %d?"):format(p, c),
                        correct,
                        { askPrima and c or p },
                        "Benar! Prima hanya habis dibagi 1 dan dirinya sendiri.",
                        ("Uji bagi: apakah %d bisa dibagi bilangan lain selain 1 dan dirinya?"):format(askPrima and c or p)
                )
        elseif pick == 2 then
                local a = math.random(10, 40)
                local n = math.random(3, 6)
                local correct = a % n
                return question(
                        ("Sisa pembagian %d mod %d?"):format(a, n),
                        correct,
                        near(correct),
                        "Benar! Modulo = sisa setelah dibagi rata. Jam bergulir juga begitu.",
                        ("%d dibagi %d: kali berapa supaya mendekati, sisanya berapa?"):format(a, n)
                )
        else
                local a = math.random(3, 9)
                local correct = a * (a + 1) / 2 * 2
                return question(
                        ("Jumlah 1 + 2 + ... + %d, lalu dikali 2. Hasilnya?"):format(a),
                        correct,
                        near(correct),
                        "Benar! Rumus Gauss n(n+1)/2 lalu dilipatgandakan - riset dimulai dari tools yang tepat.",
                        ("Hitung 1+2+...+%d = %d(%d+1)/2 dulu, baru kali 2."):format(a, a, a)
                )
        end
end

local GENERATORS = { kamp, hutan, gunung, kota, lembah, salju }

--- zoneIndex 1..6
function MathGen.generate(zoneIndex: number): any
        local gen = GENERATORS[math.clamp(zoneIndex, 1, #GENERATORS)]
        return gen()
end

return MathGen
