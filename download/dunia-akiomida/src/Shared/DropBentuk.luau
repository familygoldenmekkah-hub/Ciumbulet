local DropBentuk = {}

local IKON = {
	akar = {
		{ bentuk = "kotak", dx = 0.3, dy = 0.32, dw = 0.4, dh = 0.4, warna = "buah" },
		{ bentuk = "kotak", dx = 0.38, dy = 0.2, dw = 0.24, dh = 0.24, warna = "buah" },
		{ bentuk = "batang", dx = 0.42, dy = 0.08, dw = 0.16, dh = 0.2, warna = "aksen" },
	},
	daun = {
		{ bentuk = "kotak", dx = 0.26, dy = 0.22, dw = 0.48, dh = 0.48, warna = "aksen" },
		{ bentuk = "lingkaran", dx = 0.4, dy = 0.58, dw = 0.22, dh = 0.22, warna = "buah" },
	},
	bulat = {
		{ bentuk = "batang", dx = 0.44, dy = 0.08, dw = 0.12, dh = 0.18, warna = "aksen" },
		{ bentuk = "lingkaran", dx = 0.22, dy = 0.24, dw = 0.56, dh = 0.56, warna = "buah" },
	},
	tangkai = {
		{ bentuk = "batang", dx = 0.26, dy = 0.3, dw = 0.09, dh = 0.5, warna = "aksen" },
		{ bentuk = "batang", dx = 0.46, dy = 0.24, dw = 0.09, dh = 0.56, warna = "aksen" },
		{ bentuk = "batang", dx = 0.66, dy = 0.3, dw = 0.09, dh = 0.5, warna = "aksen" },
		{ bentuk = "lingkaran", dx = 0.24, dy = 0.16, dw = 0.13, dh = 0.13, warna = "buah" },
		{ bentuk = "lingkaran", dx = 0.44, dy = 0.1, dw = 0.13, dh = 0.13, warna = "buah" },
		{ bentuk = "lingkaran", dx = 0.64, dy = 0.16, dw = 0.13, dh = 0.13, warna = "buah" },
	},
	pohon = {
		{ bentuk = "batang", dx = 0.44, dy = 0.7, dw = 0.12, dh = 0.22, warna = "aksen" },
		{ bentuk = "lingkaran", dx = 0.16, dy = 0.14, dw = 0.68, dh = 0.68, warna = "aksen" },
		{ bentuk = "lingkaran", dx = 0.36, dy = 0.34, dw = 0.3, dh = 0.3, warna = "buah" },
	},
	semak = {
		{ bentuk = "pipih", dx = 0.16, dy = 0.68, dw = 0.68, dh = 0.16, warna = "aksen" },
		{ bentuk = "lingkaran", dx = 0.12, dy = 0.42, dw = 0.3, dh = 0.3, warna = "buah" },
		{ bentuk = "lingkaran", dx = 0.36, dy = 0.3, dw = 0.34, dh = 0.34, warna = "buah" },
		{ bentuk = "lingkaran", dx = 0.58, dy = 0.44, dw = 0.28, dh = 0.28, warna = "buah" },
	},
	kacang = {
		{ bentuk = "batang", dx = 0.44, dy = 0.1, dw = 0.12, dh = 0.22, warna = "aksen" },
		{ bentuk = "pipih", dx = 0.14, dy = 0.34, dw = 0.32, dh = 0.22, warna = "buah" },
		{ bentuk = "pipih", dx = 0.54, dy = 0.34, dw = 0.32, dh = 0.22, warna = "buah" },
		{ bentuk = "pipih", dx = 0.34, dy = 0.6, dw = 0.32, dh = 0.22, warna = "aksen" },
	},
	cendawan = {
		{ bentuk = "batang", dx = 0.4, dy = 0.52, dw = 0.2, dh = 0.32, warna = "aksen" },
		{ bentuk = "topi", dx = 0.14, dy = 0.16, dw = 0.72, dh = 0.42, warna = "buah" },
	},
}

function DropBentuk.ikonBagian(jenis: string)
	return IKON[jenis]
end

function DropBentuk.spesifikasi(bentuk: any): { jenis: string, buah: { number }, aksen: { number }, skala: number }?
	if type(bentuk) ~= "table" or type(bentuk.jenis) ~= "string" then
		return nil
	end
	if not IKON[bentuk.jenis] then
		return nil
	end
	if type(bentuk.siap) ~= "table" or type(bentuk.aksen) ~= "table" then
		return nil
	end
	local w = type(bentuk.w) == "number" and bentuk.w or 1.4
	local skala = w * 0.55
	if skala < 0.7 then
		skala = 0.7
	elseif skala > 1.8 then
		skala = 1.8
	end
	return {
		jenis = bentuk.jenis,
		buah = { bentuk.siap[1] or 200, bentuk.siap[2] or 200, bentuk.siap[3] or 200 },
		aksen = { bentuk.aksen[1] or 110, bentuk.aksen[2] or 160, bentuk.aksen[3] or 90 },
		skala = skala,
	}
end

return DropBentuk
