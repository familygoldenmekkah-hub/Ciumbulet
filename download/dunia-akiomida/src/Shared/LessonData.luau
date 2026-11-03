--!nonstrict
--[[
	LessonData.luau
	Materi "Bahasan" per zona - teks original yang ditulis ulang untuk versi
	Roblox (gaya edukatif populer, ringkas, bahasa Indonesia).
	Setiap zona punya topik pendek; pemain menandai "sudah dibaca" untuk progres.
]]

local LessonData = {}

-- index zona 1..6, sesuai urutan Config.Zones
local LESSONS = {
	[1] = {
		{ id = "kamp-1", title = "Angka lahir dari kebutuhan", text = "Dulu gembala menghitung domba dengan batu: satu batu satu domba. Batu tersisa artinya domba belum pulang. Angka lahir untuk menjaga agar tidak ada yang hilang." },
		{ id = "kamp-2", title = "Menambah itu menggabungkan", text = "Menambahkan = menggabungkan dua kelompok jadi satu. 3 batu ditambah 4 batu bukan 34 batu - melainkan 7 batu. Coba bayangkan benda, bukan hanya lambang." },
		{ id = "kamp-3", title = "Mengurang itu menyisihkan", text = "Mengurangi = menyingkirkan sebagian dari kelompok. Kalau 9 kue dimakan 4, tersisa 5. Kurang juga bisa dianggap melangkah mundur di garis bilangan." },
		{ id = "kamp-4", title = "Perkalian itu penjumlahan cepat", text = "4 x 3 artinya 4 + 4 + 4. Perkalian adalah jalan pintas untuk penjumlahan berulang. Makin paham maknanya, makin cepat hitungmu." },
		{ id = "kamp-5", title = "Pembagian itu membagi rata", text = "12 dibagi 3 artinya membagi 12 menjadi 3 kelompok sama besar: tiap kelompok 4. Pembagian adalah kebalikan perkalian." },
	},
	[2] = {
		{ id = "hutan-1", title = "Bilangan negatif ada di bawah nol", text = "Suhu 3 derajat lalu turun 5 derajat: hasilnya -2. Negatif bukan 'aneh', hanya langkah ke kiri dari nol di garis bilangan." },
		{ id = "hutan-2", title = "Urutan operasi", text = "Kerjakan kurung dulu, lalu kali/bagi, terakhir tambah/kurang. 2 + 3 x 4 = 14, bukan 20. Aturan ini bikin semua orang paham makna yang sama." },
		{ id = "hutan-3", title = "Simbol bermakna", text = "+, -, x, :, = adalah alat tulis pikiran. Tanda yang salah mengubah makna: 5 - 2 beda jauh dengan 5 + 2. Baca simbol seperti membaca rambu jalan." },
		{ id = "hutan-4", title = "Kurung mengubah segalanya", text = "(2 + 3) x 4 = 20, tapi 2 + 3 x 4 = 14. Kurung menyuruhmu mengerjakan dulu. Letak satu tanda bisa mengubah jawaban." },
	},
	[3] = {
		{ id = "gunung-1", title = "Pola barisan tambah", text = "2, 5, 8, 11, ... tiap kali naik 3. Beda yang tetap menandai barisan aritmetika. Temukan bedanya, kamu bisa menebak langkah ke seribu pun." },
		{ id = "gunung-2", title = "Pola barisan kali", text = "3, 6, 12, 24, ... tiap kali dikali 2. Barisan geometri tumbuh makin cepat - seperti bola salju menggulung." },
		{ id = "gunung-3", title = "Pola segitiga", text = "1, 3, 6, 10, 15 ... ditambah 2, lalu 3, lalu 4. Rumusnya n(n+1)/2. Pola yang sama dipakai menyusun bola pinak di lapangan." },
		{ id = "gunung-4", title = "Pola bentuk", text = "Jumlah sisi segitiga 3, persegi 4, pentagon 5. Bentuk punya pola angka. Matematika membaca dunia lewat pola seperti ini." },
	},
	[4] = {
		{ id = "kota-1", title = "Menyelesaikan persamaan", text = "2x + 3 = 11. Kurangi kedua ruas dengan 3: 2x = 8. Bagi dua: x = 4. Persamaan seperti timbangan - apa yang dilakukan di satu ruas, lakukan juga di ruas lain." },
		{ id = "kota-2", title = "Membuktikan, bukan menebak", text = "Klaim '7 x 8 = 56' harus diuji. Kuadratkan, jumlahkan, periksa. Di Kota Bukti, argumen tanpa perhitungan gak lulus sidang." },
		{ id = "kota-3", title = "Luas dan keliling", text = "Keliling = jalan keliling pagar (persegi: 4 x sisi). Luas = seluruh lantai di dalam (sisi x sisi). Dua hal berbeda yang sering tertukar." },
		{ id = "kota-4", title = "Pertidaksamaan", text = "x > 3 artinya semua bilangan lebih dari 3: 4, 5, 6, ... sampai tak terhingga. Satu simbol membuka wilayah jawaban, bukan hanya satu angka." },
	},
	[5] = {
		{ id = "lembah-1", title = "Fungsi itu mesin", text = "f(x) = 2x + 1. Masukkan 3, keluar 7. Fungsi mengubah input jadi output dengan aturan tetap. Grafiknya menggambar cerita hubungan itu." },
		{ id = "lembah-2", title = "Pangkat & akar", text = "5^2 = 25, akar 25 = 5. Pangkat menaikkan, akar menurunkan kembali. Dua arah jalan yang sama." },
		{ id = "lembah-3", title = "Pecahan & perbandingan", text = "1/2 dari 10 = 5. Pecahan adalah pembagian yang ditulis rapi. Rasio 2:3 artinya tiap 2 bagian A ada 3 bagian B." },
		{ id = "lembah-4", title = "Memahami vs menghafal", text = "Yang dihafal mudah lupa; yang dipahami melekat. Lembah Kedalaman melatih bertanya 'kenapa' sebelum 'berapa'." },
	},
	[6] = {
		{ id = "salju-1", title = "Bilangan prima", text = "2, 3, 5, 7, 11, 13 ... hanya habis dibagi 1 dan dirinya. Prima adalah 'atom' bilangan - semua bilangan tersusun darinya." },
		{ id = "salju-2", title = "Aritmetika modular", text = "7 mod 3 = 1, karena 7 = 2 x 3 + 1. Sisa pembagian berguna untuk jam, kalender, hingga kriptografi." },
		{ id = "salju-3", title = "Penjumlahan Gauss", text = "1 + 2 + ... + 100 = 5050, lewat trik 100(101)/2. Riset sering dimulai dari melihat pola di tempat yang orang lain anggap biasa." },
		{ id = "salju-4", title = "Bertanya seperti peneliti", text = "Coba tebak, uji dengan contoh kecil, cari lawan, lalu buktikan. Puncak Riset bukan soal jawaban cepat, tapi pertanyaan yang tepat." },
	},
}

--- Returns the lesson list for a 1-based zone index.
function LessonData.forZone(zoneIndex: number): { any }
	return LESSONS[zoneIndex] or {}
end

--- Total topic count across all zones (for HUD progress).
function LessonData.totalTopics(): number
	local n = 0
	for _, list in LESSONS do
		n += #list
	end
	return n
end

return LessonData
