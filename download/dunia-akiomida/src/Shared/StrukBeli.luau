local StrukBeli = {}

function StrukBeli.rangkum(picks: { any }, byId: { [string]: any }): { any }
	local urut = {}
	local hitung: { [string]: number } = {}
	for _, id in ipairs(picks) do
		local kunci = tostring(id)
		if not hitung[kunci] then
			hitung[kunci] = 0
			table.insert(urut, id)
		end
		hitung[kunci] += 1
	end
	local rows = {}
	for _, id in ipairs(urut) do
		local info = byId and byId[id]
		table.insert(rows, {
			id = id,
			nama = (info and info.nama) or tostring(id),
			count = hitung[tostring(id)],
		})
	end
	return rows
end

function StrukBeli.totalBaris(rows: { any }): number
	local n = 0
	for _, r in ipairs(rows) do
		n += r.count
	end
	return n
end

return StrukBeli
