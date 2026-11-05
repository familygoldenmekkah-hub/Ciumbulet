--!nonstrict
--[[
	MarketService.luau - v4 "PAPAN JUAL" (pasar pemain gaya konsinyasi MMO):
	  - Papan fisik di alun-alun: pemain MENJUAL barang langsung ke pemain LAIN
	  - Harga ditentukan penjual; pembeli bayar penuh SEKALI (tanpa bunga/riba)
	  - Biaya jasa pasar 2% (min 1 Micda): TRANSPARAN, terlihat sebelum konfirmasi
	  - Barang & Micda aman di DataStore; hasil jual diantar lewat "kotak pos"
	    walau penjual sedang offline
	  - Tanpa undian, tanpa lotre, tanpa spekulasi tersembunyi -> syariah-safe
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local Remotes = require(ReplicatedStorage.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)
local Balance = require(ReplicatedStorage.Shared.Balance)

local DataService = require(script.Parent.DataService)

local MarketService = {}

local STORE_NAME = "AKM_Market_v1"
local BOARD_KEY = "board"
local MAIL_KEY = "mail"
local MAX_LISTINGS_PER_PLAYER = 10
local MAX_BOARD = 60
local FEE_RATE = 0.02 -- biaya jasa pasar 2%, transparan (ujr, bukan riba)
local FEE_MIN = 1

local store = nil
local board: { any } = {} -- daftar lelangan aktif
local mail: { [number]: number } = {} -- userId -> Micda menunggu diambil
local listingSeq = 0
local dirtyBoard = false
local dirtyMail = false

local VALID: { [string]: { [string]: boolean } } = {}

local function buildValid()
	local function set(kind: string, ids: { string })
		VALID[kind] = {}
		for _, id in ids do
			VALID[kind][id] = true
		end
	end
	local cropIds = {}
	for _, c in ipairs(Config.Crops) do
		table.insert(cropIds, c.id)
	end
	set("seed", cropIds)
	set("crop", cropIds)
	local bagIds = {}
	for _, r in ipairs(Config.Resources) do
		table.insert(bagIds, r.id)
	end
	set("bag", bagIds)
	local fishIds = {}
	for _, f in ipairs(Config.Fish) do
		table.insert(fishIds, f.id)
	end
	set("fish", fishIds)
	local equipIds, useIds = {}, {}
	for _, e in ipairs(Balance.Equipment) do
		table.insert(equipIds, e.id)
	end
	set("equip", equipIds)
	for _, u in ipairs(Balance.Usables) do
		table.insert(useIds, u.id)
	end
	set("use", useIds)
end

function MarketService.feeOf(price: number): number
	return math.max(FEE_MIN, math.floor(price * FEE_RATE + 0.5))
end

local function publicListings()
	local out = {}
	for _, l in board do
		table.insert(out, l)
	end
	table.sort(out, function(a, b)
		return a.at < b.at
	end)
	return out
end

local function pushBoard(player: Player?)
	local snap = { listings = publicListings(), feeRate = FEE_RATE, feeMin = FEE_MIN }
	if player then
		Remotes.get("MarketSync"):FireClient(player, snap)
	else
		Remotes.get("MarketSync"):FireAllClients(snap)
	end
end

local function saveLoop()
	while true do
		task.wait(4)
		pcall(function()
			if dirtyBoard then
				dirtyBoard = false
				store:SetAsync(BOARD_KEY, board)
			end
			if dirtyMail then
				dirtyMail = false
				store:SetAsync(MAIL_KEY, mail)
			end
		end)
	end
end

function MarketService.myListings(player: Player)
	local out = {}
	for _, l in board do
		if l.sellerId == player.UserId then
			table.insert(out, l)
		end
	end
	return out
end

local function onMarketAction(player: Player, payload: any)
	if not DataService.has(player) or type(payload) ~= "table" or type(payload.action) ~= "string" then
		return { ok = false, msg = "Permintaan tidak valid." }
	end
	local action = payload.action

	---------------------------------------------------------- lihat papan
	if action == "browse" or action == "mine" then
		return {
			ok = true,
			listings = publicListings(),
			mine = MarketService.myListings(player),
			feeRate = FEE_RATE,
			feeMin = FEE_MIN,
		}
	end

	---------------------------------------------------------- jual
	if action == "list" then
		local kind, id = tostring(payload.kind or ""), tostring(payload.id or "")
		local count = math.floor(tonumber(payload.count) or 0)
		local price = math.floor(tonumber(payload.price) or 0)
		if not VALID[kind] or not VALID[kind][id] then
			return { ok = false, msg = "Barang tidak dikenal." }
		end
		if count < 1 then
			return { ok = false, msg = "Jumlah minimal 1." }
		end
		if price < 1 or price > 999999 then
			return { ok = false, msg = "Harga harus 1 - 999.999 Micda." }
		end
		if DataService.countItem(player, kind, id) < count then
			return { ok = false, msg = "Stok di tas tidak cukup." }
		end
		local mine = 0
		for _, l in board do
			if l.sellerId == player.UserId then
				mine += 1
			end
		end
		if mine >= MAX_LISTINGS_PER_PLAYER then
			return { ok = false, msg = "Maksimal " .. MAX_LISTINGS_PER_PLAYER .. " barang dijual sekaligus." }
		end
		if #board >= MAX_BOARD then
			return { ok = false, msg = "Papan penuh. Coba lagi nanti." }
		end
		DataService.takeItem(player, kind, id, count)
		listingSeq += 1
		table.insert(board, {
			lid = "L" .. listingSeq,
			sellerId = player.UserId,
			sellerName = player.DisplayName,
			kind = kind,
			id = id,
			count = count,
			price = price,
			at = os.time(),
		})
		dirtyBoard = true
		pushBoard(nil)
		DataService.push(player)
		return { ok = true, msg = "Terpasang di papan: " .. count .. "x @ " .. price .. " Micda (jasa " .. MarketService.feeOf(price) .. ")." }
	end

	---------------------------------------------------------- batal
	if action == "cancel" then
		local lid = tostring(payload.lid or "")
		for i, l in board do
			if l.lid == lid then
				if l.sellerId ~= player.UserId then
					return { ok = false, msg = "Bukan barangmu." }
				end
				table.remove(board, i)
				DataService.giveItem(player, l.kind, l.id, l.count)
				dirtyBoard = true
				pushBoard(nil)
				DataService.push(player)
				return { ok = true, msg = "Penjualan dibatalkan, barang kembali ke tas." }
			end
		end
		return { ok = false, msg = "Lelangan tidak ditemukan." }
	end

	---------------------------------------------------------- beli
	if action == "buy" then
		local lid = tostring(payload.lid or "")
		for i, l in board do
			if l.lid == lid then
				if l.sellerId == player.UserId then
					return { ok = false, msg = "Itu barangmu sendiri." }
				end
				local data = DataService.get(player)
				if data.Coins < l.price then
					return { ok = false, msg = "Micda tidak cukup (butuh " .. l.price .. ")." }
				end
				table.remove(board, i)
				DataService.addCoins(player, -l.price, false)
				DataService.giveItem(player, l.kind, l.id, l.count)
				-- hasil jual bersih (harga - jasa transparan) menuju penjual
				local proceeds = l.price - MarketService.feeOf(l.price)
				local seller = Players:GetPlayerByUserId(l.sellerId)
				if seller and DataService.has(seller) then
					DataService.addCoins(seller, proceeds, false)
					DataService.push(seller)
					Remotes.get("Notify"):FireClient(seller, "Terjual!",
						l.count .. "x barangmu terjual ke " .. player.DisplayName .. " (+" .. proceeds .. " Micda).")
				else
					mail[l.sellerId] = (mail[l.sellerId] or 0) + proceeds
					dirtyMail = true
				end
				dirtyBoard = true
				pushBoard(nil)
				DataService.push(player)
				return { ok = true, msg = "Membeli " .. l.count .. "x seharga " .. l.price .. " Micda. Cek tasmu!" }
			end
		end
		return { ok = false, msg = "Barang sudah terjual atau dihapus." }
	end

	return { ok = false, msg = "Aksi tidak dikenal." }
end

function MarketService.claimMail(player: Player)
	local amount = mail[player.UserId] or 0
	if amount <= 0 then
		return
	end
	mail[player.UserId] = nil
	dirtyMail = true
	if DataService.has(player) then
		DataService.addCoins(player, amount, false)
		DataService.push(player)
		task.delay(6, function()
			if player.Parent then
				Remotes.get("Notify"):FireClient(player, "Kotak Pos Pasar",
					"Hasil penjualanmu di Papan Jual: +" .. amount .. " Micda!")
			end
		end)
	end
end

function MarketService.bindPrompt(prompt: ProximityPrompt)
	prompt.Triggered:Connect(function(player)
		if DataService.has(player) then
			pushBoard(player)
			Remotes.get("OpenMarket"):FireClient(player)
		end
	end)
end

function MarketService.init()
	buildValid()
	local ok = pcall(function()
		store = DataStoreService:GetDataStore(STORE_NAME)
	end)
	if ok and store then
		local okBoard, data = pcall(function()
			return store:GetAsync(BOARD_KEY)
		end)
		if okBoard and type(data) == "table" then
			board = data
			for _, l in board do
				local n = tonumber(string.sub(tostring(l.lid), 2)) or 0
				if n > listingSeq then
					listingSeq = n
				end
			end
		end
		local okMail, mdata = pcall(function()
			return store:GetAsync(MAIL_KEY)
		end)
		if okMail and type(mdata) == "table" then
			mail = mdata
		end
		task.spawn(saveLoop)
	else
		warn("[AKIOMIDA] Market DataStore tidak tersedia; papan jalan per-sesi saja.")
	end
	Remotes.get("MarketAction").OnServerInvoke = onMarketAction
end

return MarketService
