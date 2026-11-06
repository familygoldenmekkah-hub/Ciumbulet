local Layout = {}

Layout.LahanCount = 24
Layout.Cols = 6
Layout.Rows = 4
Layout.SizeX = 240
Layout.SizeZ = 220
Layout.Gap = 40

Layout.PlotCols = 25
Layout.PlotRows = 20
Layout.PlotSize = 4
Layout.PlotPitch = 6
Layout.PlotBlockX = 10
Layout.PlotBlockZ = 30
Layout.PlotBlockW = 150
Layout.PlotBlockD = 120

function Layout.cellOrigin(index: number): (number, number)
	local row = math.floor((index - 1) / Layout.Cols)
	local col = (index - 1) % Layout.Cols
	return col * (Layout.SizeX + Layout.Gap), row * (Layout.SizeZ + Layout.Gap)
end

function Layout.plotCount(): number
	return Layout.PlotCols * Layout.PlotRows
end

function Layout.plotLocal(idx: number): (number, number)
	local col = idx % Layout.PlotCols
	local row = math.floor(idx / Layout.PlotCols)
	local x = Layout.PlotBlockX + 1 + Layout.PlotSize / 2 + Layout.PlotPitch * col
	local z = Layout.PlotBlockZ + 1 + Layout.PlotSize / 2 + Layout.PlotPitch * row
	return x, z
end

function Layout.duniaOffsetX(): number
	return 5000
end

return Layout
