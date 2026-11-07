P = '/home/z/my-project/download/dunia-akiomida/src/Server/Modules/DataService.luau'
s = open(P).read()

def ganti(lama, baru):
    global s
    lama = lama.expandtabs(8)
    baru = baru.expandtabs(8)
    if lama not in s:
        raise SystemExit("TIDAK KETEMU: " + lama[:90])
    s = s.replace(lama, baru, 1)

ganti(
"""function DataService.load(player: Player): (boolean, string?, number)
	local userId = player.UserId
	local ok, data = pcall(function()
		return store:GetAsync("u_" .. tostring(userId))
	end)
	if not ok then
		cache[userId] = defaultData()
		loadedOk[userId] = false
		dirty[userId] = false
		push(player)
		return false, "galat", 0
	end""",
"""local RETRY_MUAT = 3

function DataService.load(player: Player): (boolean, string?, number)
	local userId = player.UserId
	local ok, data = false, nil
	for i = 1, RETRY_MUAT do
		ok, data = pcall(function()
			return store:GetAsync("u_" .. tostring(userId))
		end)
		if ok then
			break
		end
		if i < RETRY_MUAT then
			task.wait(0.4 * i)
		end
	end
	if not ok then
		cache[userId] = defaultData()
		loadedOk[userId] = false
		dirty[userId] = false
		push(player)
		return false, "galat", 0
	end""")

ganti(
"""function DataService.drop(player: Player)""",
"""function DataService.cobaSinkron(player: Player): boolean
	if loadedOk[player.UserId] then
		return true
	end
	local userId = player.UserId
	local lama = cache[userId]
	local mainan = dirty[userId] == true
	local ok, alasan, dibuang = DataService.load(player)
	if not ok then
		return false
	end
	if mainan and lama then
		cache[userId] = lama
		dirty[userId] = true
		push(player)
	end
	return true
end

function DataService.drop(player: Player)""")

open(P, 'w').write(s)
print("DataService: retry + cobaSinkron selesai")
