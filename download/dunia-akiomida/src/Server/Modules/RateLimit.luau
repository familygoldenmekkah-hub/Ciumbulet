local RateLimit = {}

RateLimit.clock = os.clock

local buckets: { [number]: { [string]: { tokens: number, last: number } } } = {}

function RateLimit.allow(userId: number, key: string, perSecond: number, burst: number): boolean
	local user = buckets[userId]
	if not user then
		user = {}
		buckets[userId] = user
	end
	local b = user[key]
	local now = RateLimit.clock()
	if not b then
		b = { tokens = burst, last = now }
		user[key] = b
	end
	b.tokens = math.min(burst, b.tokens + (now - b.last) * perSecond)
	b.last = now
	if b.tokens >= 1 then
		b.tokens -= 1
		return true
	end
	return false
end

function RateLimit.clear(userId: number)
	buckets[userId] = nil
end

return RateLimit
