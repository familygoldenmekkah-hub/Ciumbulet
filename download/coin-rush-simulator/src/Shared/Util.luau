--!nonstrict
--[[
	Util.luau
	Small helpers shared by server and client.
]]

local Util = {}

local SUFFIXES = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp" }

--- Format 1234567 -> "1.23M". Always returns a display string.
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
	-- strip trailing ".0" style noise
	text = text:gsub("%.?0+$", "")
	return text .. SUFFIXES[idx + 1]
end

--- Deep copy for the player data template.
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

--- pcalls fn and retries up to attempts times. Returns success + values.
function Util.retry<T>(attempts: number, fn: () -> ...any): (boolean, ...any)
	local ok, a, b, c = false, nil, nil, nil
	for i = 1, attempts do
		ok, a, b, c = pcall(fn)
		if ok then
			return true, a, b, c
		end
		task.wait(i * 2) -- backoff: 2s, 4s, 6s...
	end
	return false, a
end

--- Creates an Instance, assigns properties, parents it. Keeps UI code terse.
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

--- Tiny signal implementation (enough for client state updates).
export type Signal = {
	Connect: (self: Signal, fn: (...any) -> ()) -> RBXScriptConnection,
	Fire: (self: Signal, ...any) -> (),
}

function Util.signal()
	local callbacks = {}
	local sig = {}

	function sig.Connect(_, fn)
		table.insert(callbacks, fn)
		return {
			Disconnect = function()
				local i = table.find(callbacks, fn)
				if i then
					table.remove(callbacks, i)
				end
			end,
		}
	end

	function sig.Fire(_, ...)
		for _, fn in callbacks do
			task.spawn(fn, ...)
		end
	end

	return sig
end

return Util
