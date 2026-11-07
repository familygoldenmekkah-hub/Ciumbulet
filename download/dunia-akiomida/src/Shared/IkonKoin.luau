local IkonKoin = {}

function IkonKoin.ukuran(pxTeks: any): number
	local v = tonumber(pxTeks)
	if type(v) ~= "number" or v ~= v then
		return 12
	end
	return math.max(12, math.floor(v * 1.05 + 0.5))
end

function IkonKoin.buat(parent: Instance?, ukuran: number?): Frame
	local px = IkonKoin.ukuran(ukuran or 20)
	local wadah = Instance.new("Frame")
	wadah.Name = "IkonKoin"
	wadah.Size = UDim2.fromOffset(px, px)
	wadah.BackgroundTransparency = 1
	local lingkar = Instance.new("Frame")
	lingkar.Name = "Koin"
	lingkar.Size = UDim2.fromScale(1, 1)
	lingkar.BackgroundColor3 = Color3.fromRGB(255, 199, 71)
	lingkar.BorderSizePixel = 0
	lingkar.Parent = wadah
	local sudut = Instance.new("UICorner")
	sudut.CornerRadius = UDim.new(0.5, 0)
	sudut.Parent = lingkar
	local gradasi = Instance.new("UIGradient")
	gradasi.Color = ColorSequence.new(Color3.fromRGB(255, 226, 132), Color3.fromRGB(199, 133, 28))
	gradasi.Rotation = 105
	gradasi.Parent = lingkar
	local tepi = Instance.new("UIStroke")
	tepi.Color = Color3.fromRGB(148, 94, 16)
	tepi.Thickness = math.max(1, math.floor(px / 11))
	tepi.Transparency = 0.12
	tepi.Parent = lingkar
	local kilau = Instance.new("Frame")
	kilau.Name = "Kilau"
	kilau.AnchorPoint = Vector2.new(0.5, 0.5)
	kilau.Position = UDim2.fromScale(0.34, 0.3)
	kilau.Size = UDim2.fromScale(0.36, 0.24)
	kilau.Rotation = -28
	kilau.BackgroundColor3 = Color3.fromRGB(255, 247, 219)
	kilau.BackgroundTransparency = 0.4
	kilau.BorderSizePixel = 0
	kilau.Parent = lingkar
	local sudutKilau = Instance.new("UICorner")
	sudutKilau.CornerRadius = UDim.new(0.5, 0)
	sudutKilau.Parent = kilau
	wadah.Parent = parent
	return wadah
end

return IkonKoin
