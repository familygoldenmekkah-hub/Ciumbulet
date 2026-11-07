local MesinLogika = {}

function MesinLogika.angkaJumlah(jumlah: any): number?
	if type(jumlah) ~= "number" or jumlah ~= jumlah or jumlah % 1 ~= 0 or jumlah < 1 then
		return nil
	end
	return math.floor(jumlah)
end

function MesinLogika.isiMesin(batch: any): number
	if type(batch) ~= "table" then
		return 0
	end
	if type(batch.jumlah) ~= "number" or batch.jumlah ~= batch.jumlah or batch.jumlah < 0 then
		return 0
	end
	return math.floor(batch.jumlah)
end

function MesinLogika.sisaKapasitas(batch: any, kapasitas: number): number
	local sisa = kapasitas - MesinLogika.isiMesin(batch)
	if sisa < 0 then
		return 0
	end
	return sisa
end

function MesinLogika.maksIsi(dimiliki: any, batch: any, kapasitas: number): number
	local d = 0
	if type(dimiliki) == "number" and dimiliki == dimiliki and dimiliki > 0 then
		d = math.floor(dimiliki)
	end
	local sisa = MesinLogika.sisaKapasitas(batch, kapasitas)
	if d < sisa then
		return d
	end
	return sisa
end

function MesinLogika.batchAktif(batch: any): boolean
	return type(batch) == "table" and batch.tahap ~= nil and batch.tahap ~= "kosong"
end

function MesinLogika.atur(batch: any, cropId: any, jumlah: any, dimiliki: any, kapasitas: number, namaA: any, namaB: any): (boolean, string)
	if type(cropId) ~= "string" then
		return false, "Hasil panen tidak dikenal."
	end
	if type(batch) == "table" and batch.tahap == "giling" then
		return false, "Mesin sedang menggiling " .. tostring(namaB) .. ". Tunggu sampai SEMAI TUNTAS."
	end
	if type(batch) == "table" and batch.tahap == "tuntas" then
		return false, "Klaim hasil " .. tostring(namaB) .. " dulu. Mesin masih berisi."
	end
	if MesinLogika.batchAktif(batch) and batch.crop ~= cropId then
		return false, "Mesin sedang memproses " .. tostring(namaB) .. ". Selesaikan semai itu dulu sebelum memasukkan item lain."
	end
	local n = MesinLogika.angkaJumlah(jumlah)
	if not n then
		return false, "Jumlah tidak sah. Isi angka bulat minimal 1."
	end
	local d = 0
	if type(dimiliki) == "number" and dimiliki == dimiliki and dimiliki > 0 then
		d = math.floor(dimiliki)
	end
	if d < 1 then
		return false, "Tidak ada " .. tostring(namaA) .. " di tas. Panen dulu hasilnya dengan Punch."
	end
	if n > d then
		return false, "Jumlah melebihi stok di tas! Ada " .. tostring(d) .. " " .. tostring(namaA) .. "."
	end
	local sisa = MesinLogika.sisaKapasitas(batch, kapasitas)
	if sisa < 1 then
		return false, "Kapasitas mesin penuh (" .. tostring(kapasitas) .. "/" .. tostring(kapasitas) .. "). Klaim isi mesin dulu."
	end
	if n > sisa then
		return false, "Jumlah melebihi sisa kapasitas mesin! Sisa " .. tostring(sisa) .. " lagi."
	end
	return true, ""
end

return MesinLogika
