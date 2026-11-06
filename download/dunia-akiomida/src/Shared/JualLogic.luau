local JualLogic = {}

function JualLogic.saring(teks: any, maks: number): number?
        if type(teks) ~= "string" and type(teks) ~= "number" then
                return nil
        end
        local n = tonumber(teks)
        if not n or n ~= n or n % 1 ~= 0 or n < 1 then
                return nil
        end
        n = math.floor(n)
        if type(maks) == "number" then
                if maks < 1 then
                        return nil
                end
                if n > maks then
                        n = maks
                end
        end
        if n < 1 then
                return nil
        end
        return n
end

function JualLogic.total(unit: number, n: number): number
        return math.floor(unit) * math.floor(n)
end

return JualLogic
