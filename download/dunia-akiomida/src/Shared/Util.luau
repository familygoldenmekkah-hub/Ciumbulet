--!nonstrict
--[[
	Util.luau - helper bersama (server & client).
]]

local Util = {}

local SUFFIXES = { "", "K", "M", "B", "T" }

function Util.formatNumber(n: number): string
	n = math.floor(n)
	if n < 1000 then
		return tostring(n)
	end
	local idx = math.floor(math.log10(n) / 3)
	if idx >= #SUFFIXES then
		idx = #SUFFIXES - 1
	end
	local m = n / (1000 ^ idx)
	local text
	if m >= 100 then
		text = string.format("%.0f", m)
	elseif m >= 10 then
		text = string.format("%.1f", m)
	else
		text = string.format("%.2f", m)
	end
	text = text:gsub("%.?0+$", "")
	return text .. SUFFIXES[idx + 1]
end

function Util.deepCopy<T>(t: T): T
	if type(t) ~= "table" then
		return t
	end
	local out = {}
	for k, v in pairs(t :: any) do
		out[k] = Util.deepCopy(v)
	end
	return out :: any
end

function Util.retry<T>(attempts: number, fn: () -> ...any): (boolean, ...any)
	local ok, a, b, c = false, nil, nil, nil
	for i = 1, attempts do
		ok, a, b, c = pcall(fn)
		if ok then
			return true, a, b, c
		end
		task.wait(i * 2)
	end
	return false, a
end

function Util.create(className: string, props: { [string]: any }?, parent: Instance?): Instance
	local inst = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			(inst :: any)[k] = v
		end
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

--- Warna zona dari Config.Zones (array {r,g,b} 0-255) -> Color3.
function Util.zoneColor(rgb): Color3
	return Color3.fromRGB(rgb[1], rgb[2], rgb[3])
end

return Util
