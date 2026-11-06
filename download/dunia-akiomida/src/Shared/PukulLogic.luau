local PukulLogic = {}

PukulLogic.MaksPukul = 5
PukulLogic.Jendela = 8

function PukulLogic.catat(hits: number, lastHit: number, t: number, jendela: number?): (number, boolean)
        local h = type(hits) == "number" and hits or 0
        local l = type(lastHit) == "number" and lastHit or 0
        local j = type(jendela) == "number" and jendela or PukulLogic.Jendela
        local beruntun = (l > 0 and t - l <= j and t - l >= 0) and (h + 1) or 1
        if beruntun < 1 then
                beruntun = 1
        end
        return beruntun, beruntun >= PukulLogic.MaksPukul
end

return PukulLogic
