local GabungLogic = {}

GabungLogic.Cols = 25
GabungLogic.Rows = 20

function GabungLogic.neighbors(idx: number): { number }
	local out = {}
	if
		type(idx) ~= "number"
		or idx < 0
		or idx >= GabungLogic.Cols * GabungLogic.Rows
		or idx ~= math.floor(idx)
	then
		return out
	end
	local col = idx % GabungLogic.Cols
	local row = math.floor(idx / GabungLogic.Cols)
	if col > 0 then
		table.insert(out, idx - 1)
	end
	if col < GabungLogic.Cols - 1 then
		table.insert(out, idx + 1)
	end
	if row > 0 then
		table.insert(out, idx - GabungLogic.Cols)
	end
	if row < GabungLogic.Rows - 1 then
		table.insert(out, idx + GabungLogic.Cols)
	end
	return out
end

return GabungLogic
