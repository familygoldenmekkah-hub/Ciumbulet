local Recipes = {}

Recipes.List = {
	{ a = "jeruk_mandarin", b = "grapefruit", out = "tangelo" },
	{ a = "plum", b = "aprikot", out = "plumcot" },
	{ a = "nektarin", b = "plum", out = "nectaplum" },
	{ a = "arachis_duranensis", b = "arachis_ipaensis", out = "kacang_tanah" },
	{ a = "ceri", b = "plum", out = "pluerry" },
	{ a = "brassica_rapa", b = "brassica_oleracea", out = "canola" },
	{ a = "gandum", b = "rye", out = "triticale" },
	{ a = "labu_maxima", b = "labu_moschata", out = "tetsukabuto" },
}

function Recipes.find(a: string, b: string): string?
	for _, r in ipairs(Recipes.List) do
		if (r.a == a and r.b == b) or (r.a == b and r.b == a) then
			return r.out
		end
	end
	return nil
end

return Recipes
