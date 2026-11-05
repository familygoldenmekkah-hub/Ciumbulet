local CropConfig = {}

CropConfig.Rarities = {
	{ id = "common", name = "Common", order = 1, color = { 178, 182, 190 } },
	{ id = "rare", name = "Rare", order = 2, color = { 104, 172, 242 } },
	{ id = "epic", name = "Epic", order = 3, color = { 188, 124, 246 } },
}

CropConfig.Crops = {
	{ id = "wortel", name = "Wortel", rarity = "common", sell = 5, color = { 255, 140, 60 } },
	{ id = "pisang", name = "Pisang", rarity = "common", sell = 5, color = { 255, 216, 80 } },
	{ id = "bayam", name = "Bayam", rarity = "common", sell = 8, color = { 74, 170, 92 } },
	{ id = "kentang", name = "Kentang", rarity = "common", sell = 9, color = { 222, 190, 122 } },
	{ id = "ubi_jalar", name = "Ubi Jalar", rarity = "common", sell = 11, color = { 202, 112, 70 } },
	{ id = "jambu_biji", name = "Jambu Biji", rarity = "common", sell = 13, color = { 152, 202, 112 } },
	{ id = "singkong", name = "Singkong", rarity = "common", sell = 13, color = { 190, 172, 122 } },
	{ id = "tebu", name = "Tebu", rarity = "common", sell = 25, color = { 152, 220, 140 } },
	{ id = "kedelai", name = "Kedelai", rarity = "common", sell = 30, color = { 222, 202, 132 } },
	{ id = "jamur", name = "Jamur", rarity = "common", sell = 30, color = { 212, 192, 172 } },
	{ id = "brokoli", name = "Brokoli", rarity = "common", sell = 38, color = { 72, 152, 82 } },
	{ id = "sorgum", name = "Sorgum", rarity = "common", sell = 88, color = { 192, 142, 82 } },
	{ id = "jeruk_mandarin", name = "Jeruk Mandarin", rarity = "rare", sell = 11, color = { 255, 172, 62 } },
	{ id = "plum", name = "Plum", rarity = "rare", sell = 19, color = { 152, 82, 182 } },
	{ id = "aprikot", name = "Aprikot", rarity = "rare", sell = 20, color = { 250, 152, 92 } },
	{ id = "nektarin", name = "Nektarin", rarity = "rare", sell = 25, color = { 242, 112, 112 } },
	{ id = "brassica_rapa", name = "Brassica Rapa", rarity = "rare", sell = 38, color = { 242, 212, 92 } },
	{ id = "brassica_oleracea", name = "Brassica Oleracea", rarity = "rare", sell = 38, color = { 122, 152, 232 } },
	{ id = "grapefruit", name = "Grapefruit", rarity = "rare", sell = 50, color = { 255, 122, 112 } },
	{ id = "labu_moschata", name = "Labu Cucurbita Moschata", rarity = "rare", sell = 75, color = { 232, 152, 62 } },
	{ id = "labu_maxima", name = "Labu Cucurbita Maxima", rarity = "rare", sell = 88, color = { 212, 102, 52 } },
	{ id = "gandum", name = "Gandum", rarity = "rare", sell = 95, color = { 232, 202, 112 } },
	{ id = "arachis_duranensis", name = "Arachis Duranensis", rarity = "rare", sell = 100, color = { 172, 192, 112 } },
	{ id = "arachis_ipaensis", name = "Arachis Ipaensis", rarity = "rare", sell = 100, color = { 152, 182, 102 } },
	{ id = "rye", name = "Rye", rarity = "rare", sell = 200, color = { 182, 162, 122 } },
	{ id = "ceri", name = "Ceri", rarity = "rare", sell = 438, color = { 222, 52, 72 } },
	{ id = "tangelo", name = "Tangelo", rarity = "epic", sell = 88, color = { 255, 152, 52 } },
	{ id = "plumcot", name = "Plumcot", rarity = "epic", sell = 113, color = { 192, 92, 202 } },
	{ id = "nectaplum", name = "Nectaplum", rarity = "epic", sell = 125, color = { 242, 102, 142 } },
	{ id = "kacang_tanah", name = "Kacang Tanah", rarity = "epic", sell = 150, color = { 202, 172, 112 } },
	{ id = "pluerry", name = "Pluerry", rarity = "epic", sell = 175, color = { 212, 72, 112 } },
	{ id = "canola", name = "Canola", rarity = "epic", sell = 300, color = { 250, 212, 72 } },
	{ id = "triticale", name = "Triticale", rarity = "epic", sell = 338, color = { 222, 192, 132 } },
	{ id = "tetsukabuto", name = "Tetsukabuto", rarity = "epic", sell = 375, color = { 92, 142, 72 } },
}

CropConfig.Recipes = {
	{ out = "tangelo", inputs = { "jeruk_mandarin", "grapefruit" } },
	{ out = "plumcot", inputs = { "plum", "aprikot" } },
	{ out = "nectaplum", inputs = { "nektarin", "plum" } },
	{ out = "kacang_tanah", inputs = { "arachis_duranensis", "arachis_ipaensis" } },
	{ out = "pluerry", inputs = { "ceri", "plum" } },
	{ out = "canola", inputs = { "brassica_rapa", "brassica_oleracea" } },
	{ out = "triticale", inputs = { "gandum", "rye" } },
	{ out = "tetsukabuto", inputs = { "labu_maxima", "labu_moschata" } },
}

CropConfig.Packs = {
	{ id = "common", name = "Pack Common", price = 400, count = 3, rarity = "common" },
	{ id = "rare", name = "Pack Rare", price = 1500, count = 3, rarity = "rare" },
	{ id = "epic", name = "Pack Epic", price = 3500, count = 3, rarity = "epic" },
}

CropConfig.GrowTime = 3
CropConfig.YieldMin = 1
CropConfig.YieldMax = 4

local byId: { [string]: any } = {}
for _, crop in ipairs(CropConfig.Crops) do
	byId[crop.id] = crop
end

function CropConfig.byId(id: string): any?
	return byId[id]
end

function CropConfig.nameOf(id: string): string
	local c = byId[id]
	return c and c.name or id
end

function CropConfig.sellOf(id: string): number
	local c = byId[id]
	return c and c.sell or 0
end

function CropConfig.rarityOf(id: string): string
	local c = byId[id]
	return c and c.rarity or "common"
end

function CropConfig.rarityColor(id: string): { number }
	local r = byId[id] and byId[id].rarity or "common"
	for _, rr in ipairs(CropConfig.Rarities) do
		if rr.id == r then
			return rr.color
		end
	end
	return { 178, 182, 190 }
end

function CropConfig.byRarity(rarity: string): { any }
	local out = {}
	for _, crop in ipairs(CropConfig.Crops) do
		if crop.rarity == rarity then
			table.insert(out, crop)
		end
	end
	return out
end

function CropConfig.packById(id: string): any?
	for _, p in ipairs(CropConfig.Packs) do
		if p.id == id then
			return p
		end
	end
	return nil
end

function CropConfig.findRecipe(idA: string, idB: string): any?
	for _, recipe in ipairs(CropConfig.Recipes) do
		local a, b = recipe.inputs[1], recipe.inputs[2]
		if (a == idA and b == idB) or (a == idB and b == idA) then
			return recipe
		end
	end
	return nil
end

function CropConfig.recipesUsing(id: string): { any }
	local out = {}
	for _, recipe in ipairs(CropConfig.Recipes) do
		if recipe.inputs[1] == id or recipe.inputs[2] == id then
			table.insert(out, recipe)
		end
	end
	return out
end

return CropConfig
