local CropData = {}

CropData.GrowTime = 3
CropData.StartMoney = 900000
CropData.TasSlots = 50
CropData.TasStack = 250
CropData.BlokId = "blok_panen"

CropData.Packs = {
	common = { price = 2400, count = 3 },
	rare = { price = 9000, count = 3 },
}

CropData.Yield = {
	common = { min = 1, max = 10 },
	rare = { min = 1, max = 6 },
	epic = { min = 1, max = 4 },
}

CropData.Smash = {
	common = { hits = 5, seed = 0.45, blok = 0.20, micdaMin = 1, micdaMax = 5 },
	rare = { hits = 10, seed = 0.30, blok = 0.15, micdaMin = 3, micdaMax = 9 },
	epic = { hits = 15, seed = 0.10, blok = 0.15, micdaMin = 9, micdaMax = 19 },
}

CropData.Crops = {
	{ id = "wortel", nama = "Wortel", rarity = "common", jual = 1 },
	{ id = "pisang", nama = "Pisang", rarity = "common", jual = 1 },
	{ id = "bayam", nama = "Bayam", rarity = "common", jual = 1 },
	{ id = "kentang", nama = "Kentang", rarity = "common", jual = 1 },
	{ id = "ubi_jalar", nama = "Ubi Jalar", rarity = "common", jual = 2 },
	{ id = "jambu_biji", nama = "Jambu Biji", rarity = "common", jual = 2 },
	{ id = "singkong", nama = "Singkong", rarity = "common", jual = 2 },
	{ id = "tebu", nama = "Tebu", rarity = "common", jual = 5 },
	{ id = "kedelai", nama = "Kedelai", rarity = "common", jual = 6 },
	{ id = "jamur", nama = "Jamur", rarity = "common", jual = 6 },
	{ id = "brokoli", nama = "Brokoli", rarity = "common", jual = 7 },
	{ id = "sorgum", nama = "Sorgum", rarity = "common", jual = 17 },
	{ id = "jeruk_mandarin", nama = "Jeruk Mandarin", rarity = "rare", jual = 2 },
	{ id = "plum", nama = "Plum", rarity = "rare", jual = 3 },
	{ id = "aprikot", nama = "Aprikot", rarity = "rare", jual = 4 },
	{ id = "nektarin", nama = "Nektarin", rarity = "rare", jual = 5 },
	{ id = "brassica_rapa", nama = "Brassica Rapa", rarity = "rare", jual = 7 },
	{ id = "brassica_oleracea", nama = "Brassica Oleracea", rarity = "rare", jual = 7 },
	{ id = "grapefruit", nama = "Grapefruit", rarity = "rare", jual = 10 },
	{ id = "labu_moschata", nama = "Labu Cucurbita Moschata", rarity = "rare", jual = 15 },
	{ id = "labu_maxima", nama = "Labu Cucurbita Maxima", rarity = "rare", jual = 17 },
	{ id = "gandum", nama = "Gandum", rarity = "rare", jual = 19 },
	{ id = "arachis_duranensis", nama = "Arachis Duranensis", rarity = "rare", jual = 20 },
	{ id = "arachis_ipaensis", nama = "Arachis Ipaensis", rarity = "rare", jual = 20 },
	{ id = "rye", nama = "Rye", rarity = "rare", jual = 40 },
	{ id = "ceri", nama = "Ceri", rarity = "rare", jual = 87 },
	{ id = "tangelo", nama = "Tangelo", rarity = "epic", jual = 17 },
	{ id = "plumcot", nama = "Plumcot", rarity = "epic", jual = 22 },
	{ id = "nectaplum", nama = "Nectaplum", rarity = "epic", jual = 25 },
	{ id = "kacang_tanah", nama = "Kacang Tanah", rarity = "epic", jual = 30 },
	{ id = "pluerry", nama = "Pluerry", rarity = "epic", jual = 35 },
	{ id = "canola", nama = "Canola", rarity = "epic", jual = 60 },
	{ id = "triticale", nama = "Triticale", rarity = "epic", jual = 67 },
	{ id = "tetsukabuto", nama = "Tetsukabuto", rarity = "epic", jual = 75 },
}

CropData.byId = {}
for _, c in ipairs(CropData.Crops) do
	CropData.byId[c.id] = c
end

function CropData.byRarity(rarity: string): { any }
	local out = {}
	for _, c in ipairs(CropData.Crops) do
		if c.rarity == rarity then
			table.insert(out, c)
		end
	end
	return out
end

return CropData
