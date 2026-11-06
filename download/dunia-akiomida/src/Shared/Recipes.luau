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

function Recipes.matchList(newCrop: string, neighborCrops: { string }): (string?, string?)
        if type(newCrop) ~= "string" then
                return nil, nil
        end
        for _, other in ipairs(neighborCrops) do
                if type(other) == "string" then
                        local out = Recipes.find(newCrop, other)
                        if out then
                                return out, other
                        end
                end
        end
        return nil, nil
end

return Recipes
