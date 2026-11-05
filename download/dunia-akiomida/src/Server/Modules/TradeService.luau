--!nonstrict
--[[
        TradeService.luau - v3 dagang antar pemain (gaya MMO klasik):
          - Undang pemain terdekat via panel (validasi jarak & data)
          - Dua sisi menawar barang & Micda, lalu keduanya "SIAP"
          - Eksekusi atomik & tervalidasi di server (anti-scam dasar)
          - Perubahan tawaran kapan pun mereset status SIAP kedua sisi
          - TradeSync: snapshot langsung ke kedua sisi setiap perubahan
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Remotes)

local DataService = require(script.Parent.DataService)

local TradeService = {}

-- sesi aktif: player -> session (kedua sisi menunjuk tabel sama)
local sessions: { [Player]: any } = {}
-- undangan menunggu: target -> {from, expires}
local invites: { [Player]: any } = {}

--------------------------------------------------------------------
-- SNAPSHOT
--------------------------------------------------------------------

local function offerOf(session: any, player: Player)
        return session[player == session.a and "offerA" or "offerB"]
end

local function pushSync(session: any)
        local snapA = {
                me = { name = session.a.DisplayName, items = session.offerA, coins = session.coinsA, ready = session.readyA },
                partner = { name = session.b.DisplayName, items = session.offerB, coins = session.coinsB, ready = session.readyB },
        }
        local snapB = {
                me = { name = session.b.DisplayName, items = session.offerB, coins = session.coinsB, ready = session.readyB },
                partner = { name = session.a.DisplayName, items = session.offerA, coins = session.coinsA, ready = session.readyA },
        }
        if session.a.Parent then
                Remotes.get("TradeSync"):FireClient(session.a, snapA)
        end
        if session.b.Parent then
                Remotes.get("TradeSync"):FireClient(session.b, snapB)
        end
end

local function closeSession(session: any, reason: string)
        for _, p in { session.a, session.b } do
                if sessions[p] == session then
                        sessions[p] = nil
                end
                if p.Parent and reason ~= "" then
                        Remotes.get("Notify"):FireClient(p, "Dagang", reason)
                end
        end
end

--------------------------------------------------------------------
-- EKSEKUSI (atomik)
--------------------------------------------------------------------

local function canDeliver(player: Player, items: { [string]: any }, coins: number): boolean
        local data = DataService.get(player)
        if data.Coins < coins then
                return false
        end
        for kind, list in items do
                for id, count in list do
                        if DataService.countItem(player, kind, id) < count then
                                return false
                        end
                end
        end
        return true
end

local function deliver(player: Player, items: { [string]: any }, coins: number)
        for kind, list in items do
                for id, count in list do
                        DataService.takeItem(player, kind, id, count)
                end
        end
        DataService.addCoins(player, -coins)
end

local function executeTrade(session: any)
        local a, b = session.a, session.b
        if not DataService.has(a) or not DataService.has(b) then
                closeSession(session, "Dagangan gagal - data pemain tidak siap.")
                return
        end
        if not canDeliver(a, session.offerA, session.coinsA) or not canDeliver(b, session.offerB, session.coinsB) then
                closeSession(session, "Dagangan gagal - barang/Micda berubah saat dagang.")
                pushSync(session)
                return
        end
        -- eksekusi: tukar
        deliver(a, session.offerA, session.coinsA)
        deliver(b, session.offerB, session.coinsB)
        for kind, list in session.offerA do
                for id, count in list do
                        DataService.giveItem(b, kind, id, count)
                end
        end
        for kind, list in session.offerB do
                for id, count in list do
                        DataService.giveItem(a, kind, id, count)
                end
        end
        DataService.addCoins(a, session.coinsB, false)
        DataService.addCoins(b, session.coinsA, false)

        Remotes.get("Notify"):FireClient(a, "Dagangan Sukses", "Tukar-menukar dengan " .. b.DisplayName .. " selesai!")
        Remotes.get("Notify"):FireClient(b, "Dagangan Sukses", "Tukar-menukar dengan " .. a.DisplayName .. " selesai!")
        DataService.push(a)
        DataService.push(b)
        closeSession(session, "")
end

--------------------------------------------------------------------
-- AKSI
--------------------------------------------------------------------

local function onTradeAction(player: Player, payload: any)
        if not DataService.has(player) or type(payload) ~= "table" or type(payload.action) ~= "string" then
                return { ok = false, msg = "Permintaan tidak valid." }
        end
        local action = payload.action

        -- sedang dalam sesi? kecuali invite, semua aksi butuh sesi
        local session = sessions[player]

        ---------------------------------------------------------------- undang
        if action == "invite" then
                if session then
                        return { ok = false, msg = "Kamu sedang dagang dengan " .. (player == session.a and session.b.DisplayName or session.a.DisplayName) .. "." }
                end
                local target = typeof(payload.target) == "string" and Players:FindFirstChild(payload.target) or nil
                if not target or target == player then
                        return { ok = false, msg = "Pemain tidak ditemukan di server ini." }
                end
                if not DataService.has(target) or sessions[target] then
                        return { ok = false, msg = "Pemain itu sedang tidak bisa diajak dagang." }
                end
                -- jarak: hanya pemain di dekatmu (biar interaksi tatap muka)
                local myRoot = player.Character and player.Character.PrimaryPart
                local theirRoot = target.Character and target.Character.PrimaryPart
                if not myRoot or not theirRoot or (myRoot.Position - theirRoot.Position).Magnitude > 60 then
                        return { ok = false, msg = "Dekati pemain itu dulu untuk mengundang dagang." }
                end
                invites[target] = { from = player, expires = os.time() + 45 }
                Remotes.get("Notify"):FireClient(target, "Undangan Dagang",
                        player.DisplayName .. " mengundangmu berdagang! Buka panel Dagang untuk menerima.")
                return { ok = true, msg = "Undangan terkirim ke " .. target.DisplayName .. ". Menunggu jawaban..." }

        ---------------------------------------------------------------- terima/tolak
        elseif action == "accept" then
                if session then
                        return { ok = false, msg = "Kamu sudah dalam sesi dagang." }
                end
                local inv = invites[player]
                if not inv or os.time() > inv.expires or not inv.from.Parent then
                        invites[player] = nil
                        return { ok = false, msg = "Undangan sudah kedaluwarsa." }
                end
                local from = inv.from
                if sessions[from] then
                        invites[player] = nil
                        return { ok = false, msg = "Pemain itu sudah dagang dengan orang lain." }
                end
                invites[player] = nil
                local newSession = {
                        a = from, b = player,
                        offerA = {}, offerB = {},
                        coinsA = 0, coinsB = 0,
                        readyA = false, readyB = false,
                }
                sessions[from] = newSession
                sessions[player] = newSession
                Remotes.get("OpenTrade"):FireClient(from)
                Remotes.get("OpenTrade"):FireClient(player)
                pushSync(newSession)
                return { ok = true, msg = "Dagangan dengan " .. from.DisplayName .. " dimulai." }

        elseif action == "decline" then
                local inv = invites[player]
                if inv and inv.from.Parent then
                        Remotes.get("Notify"):FireClient(inv.from, "Dagang", player.DisplayName .. " menolak undanganmu.")
                end
                invites[player] = nil
                return { ok = true, msg = "Undangan ditolak." }

        ---------------------------------------------------------------- isi sesi
        elseif action == "offer" and session then
                if type(payload.kind) ~= "string" or type(payload.id) ~= "string" then
                        return { ok = false, msg = "Tidak valid." }
                end
                local count = math.floor(tonumber(payload.count) or 0)
                local myOffer = offerOf(session, player)
                local have = DataService.countItem(player, payload.kind, payload.id)
                if count <= 0 then
                        myOffer[payload.kind][payload.id] = nil
                else
                        if have < count then
                                return { ok = false, msg = "Stok tidak cukup (" .. have .. ")." }
                        end
                        myOffer[payload.kind] = myOffer[payload.kind] or {}
                        myOffer[payload.kind][payload.id] = count
                end
                session.readyA = false
                session.readyB = false
                pushSync(session)
                return { ok = true }

        elseif action == "coin" and session then
                local amount = math.max(0, math.floor(tonumber(payload.amount) or 0))
                local data = DataService.get(player)
                if amount > data.Coins then
                        amount = data.Coins
                end
                if player == session.a then
                        session.coinsA = amount
                else
                        session.coinsB = amount
                end
                session.readyA = false
                session.readyB = false
                pushSync(session)
                return { ok = true }

        elseif action == "ready" and session then
                local value = payload.value == true
                if player == session.a then
                        session.readyA = value
                else
                        session.readyB = value
                end
                pushSync(session)
                if session.readyA and session.readyB then
                        task.defer(executeTrade, session)
                end
                return { ok = true }

        elseif action == "cancel" and session then
                closeSession(session, "Dagangan dibatalkan.")
                return { ok = true, msg = "Dagangan dibatalkan." }
        end

        return { ok = false, msg = "Kamu tidak sedang berdagang." }
end

--------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------

function TradeService.init()
        Remotes.get("TradeAction").OnServerInvoke = onTradeAction

        Players.PlayerRemoving:Connect(function(player)
                -- undangan
                invites[player] = nil
                for target, inv in invites do
                        if inv.from == player then
                                invites[target] = nil
                        end
                end
                -- sesi dagang
                local session = sessions[player]
                if session then
                        closeSession(session, "Partner dagangmu keluar server - dagangan dibatalkan.")
                end
        end)
end

return TradeService
