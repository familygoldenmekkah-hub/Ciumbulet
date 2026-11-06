local SesiLogic = {}

SesiLogic.StaleDetik = 90

function SesiLogic.bisaAmbil(old: any, jobId: any, now: number): boolean
        if type(old) ~= "table" then
                return true
        end
        if old.j == nil or old.j == "" then
                return true
        end
        if old.j == jobId then
                return true
        end
        if type(old.t) ~= "number" then
                return true
        end
        return now - old.t >= SesiLogic.StaleDetik
end

function SesiLogic.kunciBaru(jobId: any, now: number): any
        return { j = tostring(jobId), t = math.floor(now) }
end

function SesiLogic.lepas(jobId: any): any
        return { j = "", t = 0 }
end

return SesiLogic
