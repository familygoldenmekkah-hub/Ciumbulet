-- TradeService: sesi trade antar pemain, server-authoritative.
-- Alur: obeng -> popup "Trade dengan (nama)?" -> Fase Tawar (4 slot item +
-- 1 slot Micda, perubahan broadcast langsung, Accept) -> Fase Konfirmasi
-- (hanya Batal/Konfirmasi) -> Eksekusi atomik di server.
--
-- Garis keamanan:
--   1. Satu sesi aktif per pemain, satu permintaan menggantung per target.
--   2. Item/Micda yang ditawarkan "terkunci": tidak bisa dijual/ditanam/
--      disimpan/dibelanjakan di tempat lain selama sesi (TasService +
--      CurrencyService membaca TradeService.jumlahTerkan / micdaTerkan).
--   3. Semua parameter dari client divalidasi (jenis, ID, jumlah integer,
--      tanpa NaN, batas slot, batas saldo).
--   4. Data harus selesai dimuat (bolehSimpan) sebelum aksi trade apa pun.
--   5. Sebelum eksekusi: simulasi ulang atas data hidup; gagal apa pun =
--      seluruh trade dibatalkan tanpa perubahan parsial.
--   6. Timeout tiap fase, pemain keluar, atau batal => sesi bersih, kunci lepas.
--   7. Semua peristiwa penting dicatat AuditService.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CropData = require(ReplicatedStorage.Shared.CropData)
local Net = require(ReplicatedStorage.Remotes)
local UangLogic = require(ReplicatedStorage.Shared.UangLogic)
local TasLogic = require(ReplicatedStorage.Shared.TasLogic)
local TradeLogic = require(ReplicatedStorage.Shared.TradeLogic)
local RateLimit = require(script.Parent.RateLimit)

local TradeService = {}

local Data, Audit, Notify = nil, nil, nil

type Sisi = {
        user: number,
        offer: any,
        siap: boolean,
        konfirm: boolean,
}

type Sesi = {
        id: string,
        fase: string,
        A: Sisi,
        B: Sisi,
        exp: number,
}

local sesiAktif: { [number]: Sesi } = {}
local undangan: { [number]: { dari: number, nama: string, token: string, exp: number } } = {}
local counter = 0

local function sekarang(): number
        return os.time()
end

local function pemainDari(userId: number): Player?
        return Players:GetPlayerByUserId(userId)
end

local function namaOf(player: Player): string
        return player.DisplayName ~= "" and player.DisplayName or player.Name
end

local function sisiDari(s: Sesi, userId: number): Sisi?
        if s.A.user == userId then
                return s.A
        end
        if s.B.user == userId then
                return s.B
        end
        return nil
end

local function lawanDari(s: Sesi, userId: number): Sisi?
        if s.A.user == userId then
                return s.B
        end
        if s.B.user == userId then
                return s.A
        end
        return nil
end

local function pandangan(sisi: Sisi): any
        local items = {}
        for _, s in ipairs(sisi.offer.items) do
                table.insert(items, { kind = s.kind, id = s.id, count = s.count })
        end
        return {
                items = items,
                micda = sisi.offer.micda,
                siap = sisi.siap == true,
                konfirm = sisi.konfirm == true,
        }
end

local function snapshot(s: Sesi, userId: number): any
        local saya = sisiDari(s, userId) :: Sisi
        local lawan = lawanDari(s, userId) :: Sisi
        local lawanPlayer = pemainDari(lawan.user)
        return {
                id = s.id,
                fase = s.fase,
                lawanId = lawan.user,
                lawanNama = lawanPlayer and namaOf(lawanPlayer) or "Pemain",
                aku = pandangan(saya),
                lawan = pandangan(lawan),
                sisa = TradeLogic.sisaDetik(s.exp, sekarang()),
        }
end

local function beriSesi(s: Sesi)
        for _, sisi in ipairs({ s.A, s.B }) do
                local p = pemainDari(sisi.user)
                if p then
                        Net.get("TradeSync"):FireClient(p, "buka", snapshot(s, sisi.user))
                end
        end
end

local function tutupSesiInternal(s: Sesi, alasan: string, pesanA: string, pesanB: string)
        sesiAktif[s.A.user] = nil
        sesiAktif[s.B.user] = nil
        local ev = Net.get("TradeSync")
        local pa = pemainDari(s.A.user)
        local pb = pemainDari(s.B.user)
        if pa then
                ev:FireClient(pa, "tutup", { alasan = alasan, pesan = pesanA })
        end
        if pb then
                ev:FireClient(pb, "tutup", { alasan = alasan, pesan = pesanB })
        end
end

function TradeService.bind(deps)
        Data = deps.Data
        Audit = deps.Audit
        Notify = deps.Notify
end

-- ===== KUNCI ITEM / MICDA (dipakai TasService & CurrencyService) =====

function TradeService.jumlahTerkan(userId: number, kind: string, id: string): number
        local s = sesiAktif[userId]
        if not s then
                return 0
        end
        local saya = sisiDari(s, userId)
        if not saya then
                return 0
        end
        for _, it in ipairs(saya.offer.items) do
                if it.kind == kind and it.id == id then
                        return it.count
                end
        end
        return 0
end

function TradeService.micdaTerkan(userId: number): number
        local s = sesiAktif[userId]
        if not s then
                return 0
        end
        local saya = sisiDari(s, userId)
        if not saya then
                return 0
        end
        return saya.offer.micda or 0
end

function TradeService.adaSesi(userId: number): boolean
        return sesiAktif[userId] ~= nil
end

-- ===== BANTU VALIDASI =====

local function siapPakai(player: Player): boolean
        return Data ~= nil and Data.get(player) ~= nil and Data.bolehSimpan(player) == true
end

local function jarakOK(a: Player, b: Player): boolean
        local ca, cb = a.Character, b.Character
        local ra = ca and ca:FindFirstChild("HumanoidRootPart") :: BasePart?
        local rb = cb and cb:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not ra or not rb then
                return false
        end
        return ((ra :: BasePart).Position - (rb :: BasePart).Position).Magnitude <= TradeLogic.JARAK_MAKS
end

local function sisaTersedia(player: Player, kind: string, id: string): number
        local d = Data.get(player)
        if not d then
                return 0
        end
        local total = TasLogic.countOf(d.t, kind, id)
        local terkunci = TradeService.jumlahTerkan(player.UserId, kind, id)
        -- slot yang sedang diganti dihitung kembali sebagai tersedia
        local s = sesiAktif[player.UserId]
        local sendiri = 0
        if s then
                local saya = sisiDari(s, player.UserId) :: Sisi
                local idx = TradeLogic.cariIdx(saya.offer, kind, id)
                if idx then
                        sendiri = saya.offer.items[idx].count
                end
        end
        local terkunciBersih = terkunci - sendiri
        if terkunciBersih < 0 then
                terkunciBersih = 0
        end
        local sisa = total - terkunciBersih
        if sisa < 0 then
                return 0
        end
        return sisa
end

local function perbaruiTawar(s: Sesi)
        s.A.siap = false
        s.B.siap = false
        s.exp = sekarang() + TradeLogic.TAWAR_UMUR
        beriSesi(s)
end

-- ===== AKSI DARI CLIENT =====

function TradeService.ajak(player: Player, targetIdRaw: any): (boolean, string)
        if not RateLimit.allow(player.UserId, "trade_ajak", 0.3, 3) then
                return false, "Terlalu cepat."
        end
        local targetId = tonumber(targetIdRaw)
        if type(targetId) ~= "number" or targetId ~= math.floor(targetId) or targetId <= 0 then
                return false, "Target tidak sah."
        end
        local target = pemainDari(targetId)
        if not target or target == player then
                return false, "Pemain tidak ada di server ini."
        end
        if not siapPakai(player) or not siapPakai(target) then
                return false, "Data pemain belum siap untuk trade."
        end
        if sesiAktif[player.UserId] then
                return false, "Kamu sedang dalam trade."
        end
        if sesiAktif[targetId] then
                return false, "Pemain itu sedang dalam trade lain."
        end
        if not jarakOK(player, target) then
                return false, "Dekati pemain itu dulu untuk mengajak trade."
        end
        local lama = undangan[targetId]
        if lama and lama.dari ~= player.UserId and lama.exp > sekarang() then
                return false, "Pemain itu sudah punya permintaan trade lain."
        end
        counter += 1
        local token = tostring(player.UserId) .. "-" .. tostring(counter)
        undangan[targetId] = { dari = player.UserId, nama = namaOf(player), token = token, exp = sekarang() + TradeLogic.UNDAANGAN_UMUR }
        Net.get("TradeSync"):FireClient(target, "permintaan", {
                dari = player.UserId,
                nama = namaOf(player),
                token = token,
                expDetik = TradeLogic.UNDAANGAN_UMUR,
        })
        Audit.catat(player, "trade", "ajak->" .. tostring(targetId))
        return true, "Permintaan trade terkirim ke " .. namaOf(target) .. "."
end

function TradeService.terima(player: Player, tokenRaw: any): (boolean, string)
        if not RateLimit.allow(player.UserId, "trade_ops", 5, 10) then
                return false, "Terlalu cepat."
        end
        local inv = undangan[player.UserId]
        if not inv or tokenRaw ~= inv.token then
                return false, "Permintaan trade sudah tidak berlaku."
        end
        if sekarang() >= inv.exp then
                undangan[player.UserId] = nil
                return false, "Permintaan trade kedaluwarsa."
        end
        local pengirim = pemainDari(inv.dari)
        if not pengirim then
                undangan[player.UserId] = nil
                return false, "Pemain pengundang sudah keluar."
        end
        if not siapPakai(player) or not siapPakai(pengirim) then
                return false, "Data pemain belum siap untuk trade."
        end
        if sesiAktif[player.UserId] or sesiAktif[pengirim.UserId] then
                undangan[player.UserId] = nil
                return false, "Salah satu pemain sedang dalam trade lain."
        end
        undangan[player.UserId] = nil
        undangan[pengirim.UserId] = nil -- bersihkan undangan silang bila ada
        counter += 1
        local s = {
                id = "T" .. tostring(counter),
                fase = "tawar",
                exp = sekarang() + TradeLogic.TAWAR_UMUR,
                A = { user = pengirim.UserId, offer = TradeLogic.offerBaru(), siap = false, konfirm = false },
                B = { user = player.UserId, offer = TradeLogic.offerBaru(), siap = false, konfirm = false },
        }
        sesiAktif[pengirim.UserId] = s
        sesiAktif[player.UserId] = s
        Audit.catat(player, "trade", "mulai dengan " .. tostring(pengirim.UserId))
        beriSesi(s)
        return true, "Trade dimulai."
end

function TradeService.tolak(player: Player, tokenRaw: any): (boolean, string)
        local inv = undangan[player.UserId]
        if not inv or tokenRaw ~= inv.token then
                return false, "Tidak ada permintaan trade."
        end
        undangan[player.UserId] = nil
        local pengirim = pemainDari(inv.dari)
        if pengirim then
                Notify(pengirim, "Trade", namaOf(player) .. " menolak permintaan trade.")
        end
        Audit.catat(player, "trade", "tolak dari " .. tostring(inv.dari))
        return true, "Permintaan trade ditolak."
end

function TradeService.sisip(player: Player, kind: any, id: any, nRaw: any): (boolean, string)
        if not RateLimit.allow(player.UserId, "trade_ops", 5, 10) then
                return false, "Terlalu cepat."
        end
        local s = sesiAktif[player.UserId]
        if not s or s.fase ~= "tawar" then
                return false, "Tidak sedang dalam fase tawar."
        end
        if type(kind) ~= "string" or type(id) ~= "string" then
                return false, "Item tidak sah."
        end
        local n = tonumber(nRaw)
        local tersedia = sisaTersedia(player, kind, id)
        local ok, msg = TradeLogic.sisip((sisiDari(s, player.UserId) :: any).offer, kind, id, n, tersedia, CropData.byId)
        if not ok then
                return false, msg
        end
        Audit.catat(player, "trade", "sisip " .. tostring(kind) .. ":" .. tostring(id) .. " x" .. tostring(n))
        perbaruiTawar(s)
        return true, "ok"
end

function TradeService.hapus(player: Player, kind: any, id: any): (boolean, string)
        if not RateLimit.allow(player.UserId, "trade_ops", 5, 10) then
                return false, "Terlalu cepat."
        end
        local s = sesiAktif[player.UserId]
        if not s or s.fase ~= "tawar" then
                return false, "Tidak sedang dalam fase tawar."
        end
        if type(kind) ~= "string" or type(id) ~= "string" then
                return false, "Item tidak sah."
        end
        local saya = sisiDari(s, player.UserId) :: any
        if not TradeLogic.hapus(saya.offer, kind, id) then
                return false, "Item itu tidak ada di tawaranmu."
        end
        Audit.catat(player, "trade", "hapus " .. kind .. ":" .. id)
        perbaruiTawar(s)
        return true, "ok"
end

function TradeService.aturMicda(player: Player, nRaw: any): (boolean, string)
        if not RateLimit.allow(player.UserId, "trade_ops", 5, 10) then
                return false, "Terlalu cepat."
        end
        local s = sesiAktif[player.UserId]
        if not s or s.fase ~= "tawar" then
                return false, "Tidak sedang dalam fase tawar."
        end
        local d = Data.get(player)
        if not d then
                return false, "Data belum siap."
        end
        local saldo = UangLogic.saldo(d.u)
        local ok, msg = TradeLogic.aturMicda((sisiDari(s, player.UserId) :: any).offer, nRaw, saldo)
        if not ok then
                return false, msg
        end
        Audit.catat(player, "trade", "micda " .. tostring(nRaw))
        perbaruiTawar(s)
        return true, "ok"
end

function TradeService.setSiap(player: Player, mau: any): (boolean, string)
        if not RateLimit.allow(player.UserId, "trade_ops", 5, 10) then
                return false, "Terlalu cepat."
        end
        local s = sesiAktif[player.UserId]
        if not s or s.fase ~= "tawar" then
                return false, "Tidak sedang dalam fase tawar."
        end
        local saya = sisiDari(s, player.UserId) :: Sisi
        saya.siap = mau == true
        Audit.catat(player, "trade", "siap=" .. tostring(saya.siap))
        if s.A.siap and s.B.siap then
                s.fase = "konfirmasi"
                s.A.konfirm = false
                s.B.konfirm = false
                s.A.siap = false
                s.B.siap = false
                s.exp = sekarang() + TradeLogic.KONFIRM_UMUR
                Audit.catat(player, "trade", "fase konfirmasi")
        else
                s.exp = sekarang() + TradeLogic.TAWAR_UMUR
        end
        beriSesi(s)
        return true, "ok"
end

function TradeService.konfirm(player: Player): (boolean, string)
        if not RateLimit.allow(player.UserId, "trade_konfirm", 2, 4) then
                return false, "Terlalu cepat."
        end
        local s = sesiAktif[player.UserId]
        if not s or s.fase ~= "konfirmasi" then
                return false, "Tidak sedang dalam fase konfirmasi."
        end
        local saya = sisiDari(s, player.UserId) :: Sisi
        if saya.konfirm then
                return true, "Sudah dikonfirmasi. Menunggu lawan."
        end
        saya.konfirm = true
        Audit.catat(player, "trade", "konfirm")
        if s.A.konfirm and s.B.konfirm then
                TradeService.eksekusi(s)
        else
                beriSesi(s)
        end
        return true, "ok"
end

function TradeService.batal(player: Player): (boolean, string)
        local s = sesiAktif[player.UserId]
        if not s then
                return false, "Tidak ada trade yang berjalan."
        end
        Audit.catat(player, "trade", "batal")
        tutupSesiInternal(s, "batal", "Kamu membatalkan trade.", namaOf(player) .. " membatalkan trade.")
        return true, "Trade dibatalkan."
end

-- ===== EKSEKUSI ATOMIK =====
-- validasiEksekusi mengembalikan salinan tas akhir kedua sisi; salinan itu
-- yang dipasang sekaligus, lalu Micda dipindah lewat UangLogic (ledger reason
-- "trade"). Tidak ada yield di antara langkah-langkah ini.

function TradeService.eksekusi(s: Sesi)
        local pa = pemainDari(s.A.user)
        local pb = pemainDari(s.B.user)
        if not pa or not pb then
                tutupSesiInternal(s, "keluar", "Lawanmu keluar — trade dibatalkan, barang tetap di tasmu.", "Lawanmu keluar — trade dibatalkan, barang tetap di tasmu.")
                return
        end
        local dA = Data.get(pa)
        local dB = Data.get(pb)
        if not dA or not dB or not Data.bolehSimpan(pa) or not Data.bolehSimpan(pb) then
                tutupSesiInternal(s, "galat", "Data belum siap — trade dibatalkan, tidak ada yang berubah.", "Data belum siap — trade dibatalkan, tidak ada yang berubah.")
                return
        end
        local ok, alasan, ka, kb = TradeLogic.validasiEksekusi(s.A.offer, s.B.offer, dA.t, dB.t, UangLogic.saldo(dA.u), UangLogic.saldo(dB.u))
        if not ok then
                Audit.catat(pa, "trade_validasi", alasan or "?")
                Audit.catat(pb, "trade_validasi", alasan or "?")
                tutupSesiInternal(s, "galat", "Trade dibatalkan otomatis: " .. tostring(alasan) .. " Barang tetap aman.", "Trade dibatalkan otomatis: " .. tostring(alasan) .. " Barang tetap aman.")
                return
        end
        local function gantiIsi(tas: { any }, baru: { any })
                for i = #tas, 1, -1 do
                        table.remove(tas, i)
                end
                for _, b in ipairs(baru) do
                        table.insert(tas, { kind = b.kind, id = b.id, count = b.count })
                end
        end
        gantiIsi(dA.t, ka :: { any })
        gantiIsi(dB.t, kb :: { any })
        local waktu = sekarang()
        local mA = s.A.offer.micda or 0
        local mB = s.B.offer.micda or 0
        if mA > 0 then
                UangLogic.bayar(dA.u, mA, "trade", waktu)
                UangLogic.tambah(dB.u, mA, "trade", waktu)
        end
        if mB > 0 then
                UangLogic.bayar(dB.u, mB, "trade", waktu)
                UangLogic.tambah(dA.u, mB, "trade", waktu)
        end
        sesiAktif[s.A.user] = nil
        sesiAktif[s.B.user] = nil
        Data.markDirty(pa)
        Data.markDirty(pb)
        Data.push(pa)
        Data.push(pb)
        local rA = TradeLogic.ringkas(s.A.offer, CropData.byId)
        local rB = TradeLogic.ringkas(s.B.offer, CropData.byId)
        Audit.catat(pa, "trade_ok", "lawan=" .. tostring(s.B.user) .. " kirim=" .. rA .. " terima=" .. rB)
        Audit.catat(pb, "trade_ok", "lawan=" .. tostring(s.A.user) .. " kirim=" .. rB .. " terima=" .. rA)
        local ev = Net.get("TradeSync")
        ev:FireClient(pa, "tutup", { alasan = "berhasil", pesan = "Trade berhasil! Terima: " .. rB })
        ev:FireClient(pb, "tutup", { alasan = "berhasil", pesan = "Trade berhasil! Terima: " .. rA })
        task.spawn(function()
                pcall(function()
                        Data.save(pa)
                end)
                pcall(function()
                        Data.save(pb)
                end)
        end)
end

-- ===== BERSIH-BERSIH =====

function TradeService.leave(player: Player)
        undangan[player.UserId] = nil
        local s = sesiAktif[player.UserId]
        if s then
                tutupSesiInternal(s, "keluar", "Lawanmu keluar — trade dibatalkan, barang tetap di tasmu.", "Lawanmu keluar — trade dibatalkan, barang tetap di tasmu.")
        end
end

-- ===== MULAI =====

function TradeService.start()
        Net.get("TradeAct").OnServerInvoke = function(player: Player, action: any, a: any, b: any, c: any)
                if type(action) ~= "string" then
                        return false, "Aksi tidak sah."
                end
                if action == "ajak" then
                        return TradeService.ajak(player, a)
                elseif action == "terima" then
                        return TradeService.terima(player, a)
                elseif action == "tolak" then
                        return TradeService.tolak(player, a)
                elseif action == "sisip" then
                        return TradeService.sisip(player, a, b, c)
                elseif action == "hapus" then
                        return TradeService.hapus(player, a, b)
                elseif action == "micda" then
                        return TradeService.aturMicda(player, a)
                elseif action == "siap" then
                        return TradeService.setSiap(player, a)
                elseif action == "konfirm" then
                        return TradeService.konfirm(player)
                elseif action == "batal" then
                        return TradeService.batal(player)
                end
                Audit.catat(player, "argumen", "trade:" .. action)
                return false, "Aksi tidak dikenal."
        end

        task.spawn(function()
                while true do
                        task.wait(1)
                        local t = sekarang()
                        for uid, inv in pairs(undangan) do
                                if t >= inv.exp then
                                        undangan[uid] = nil
                                end
                        end
                        for uid, s in pairs(sesiAktif) do
                                if uid == s.A.user and t >= s.exp then
                                        local pa = pemainDari(s.A.user)
                                        if pa then
                                                Audit.catat(pa, "trade_timeout", s.fase)
                                        end
                                        local pb = pemainDari(s.B.user)
                                        if pb then
                                                Audit.catat(pb, "trade_timeout", s.fase)
                                        end
                                        tutupSesiInternal(s, "waktu", "Trade dibatalkan otomatis (waktu habis). Barang tetap di tasmu.", "Trade dibatalkan otomatis (waktu habis). Barang tetap di tasmu.")
                                end
                        end
                end
        end)
end

return TradeService
