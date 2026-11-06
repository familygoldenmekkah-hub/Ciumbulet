local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local CropData = require(ReplicatedStorage.Shared.CropData)
local SemaiLogic = require(ReplicatedStorage.Shared.SemaiLogic)

local MesinSemaiService = {}

local Land, Tas, Uang, Net, World
local rng = Random.new()

local mesin: { [number]: any } = {}
local batch: { [number]: any } = {}

local TEKS_TAHAP = {
        kosong = { teks = "NONAKTIF", warna = { 208, 210, 216 } },
        tuas = { teks = "TEKAN TUAS KANAN LALU KIRI", warna = { 255, 214, 110 } },
        giling = { teks = "MENGGILING...", warna = { 255, 158, 74 } },
        tuntas = { teks = "SEMAI TUNTAS - KLAIM HASIL", warna = { 122, 232, 130 } },
}

local LAMPU_MATI = 0.55
local LAMPU_NYALA = 0

local WAKTU_ANIM_TUAS = 0.45

local function bagian(model: Instance, nama: string): any
        local d = model:FindFirstChild(nama, true)
        return d
end

local function baseOf(p: BasePart?): CFrame?
        if p and p.Parent then
                return p.CFrame
        end
        return nil
end

function MesinSemaiService.bind(deps)
        Land = deps.Land
        Tas = deps.Tas
        Uang = deps.Uang
        Net = deps.Net
        World = deps.World
end

local function daftarTuas(model: Model, nama: string): any
        local pedestal = bagian(model, "Tuas" .. nama .. "Pedestal")
        local arm = bagian(model, "Tuas" .. nama .. "Arm")
        local knob = bagian(model, "Tuas" .. nama .. "Knob")
        if not arm or not arm:GetAttribute("CFNaik") then
                return nil
        end
        return {
                arm = arm,
                knob = knob,
                lampu = bagian(model, "Tuas" .. nama .. "Lampu"),
                prompt = pedestal and pedestal:FindFirstChild("PromptTuas" .. nama),
                suara = pedestal and pedestal:FindFirstChild("SuaraTuas" .. nama),
                cfNaik = arm:GetAttribute("CFNaik"),
                cfTurun = arm:GetAttribute("CFTurun"),
                knobNaik = knob and knob:GetAttribute("CFNaik"),
                knobTurun = knob and knob:GetAttribute("CFTurun"),
        }
end

function MesinSemaiService.registerMesin(index: number, model: Model)
        local drum = bagian(model, "MesinDrum")
        local m = {
                pos = model:GetPivot().Position,
                status = bagian(model, "StatusMesin"),
                drum = drum,
                drumBase = baseOf(drum),
                girA = bagian(model, "MesinGirA"),
                girABase = baseOf(bagian(model, "MesinGirA")),
                girB = bagian(model, "MesinGirB"),
                girBBase = baseOf(bagian(model, "MesinGirB")),
                roda = bagian(model, "MesinRoda"),
                rodaBase = baseOf(bagian(model, "MesinRoda")),
                rib1 = bagian(model, "MesinRib1"),
                rib1Base = baseOf(bagian(model, "MesinRib1")),
                rib2 = bagian(model, "MesinRib2"),
                rib2Base = baseOf(bagian(model, "MesinRib2")),
                rib3 = bagian(model, "MesinRib3"),
                rib3Base = baseOf(bagian(model, "MesinRib3")),
                lampuMerah = bagian(model, "MesinLampuMerah"),
                lampuKuning = bagian(model, "MesinLampuKuning"),
                lampuHijau = bagian(model, "MesinLampuHijau"),
                asap = bagian(model, "AsapMesin"),
                suaraGiling = bagian(model, "SuaraGiling"),
                suaraDing = bagian(model, "SuaraDing"),
                suaraStart = bagian(model, "SuaraStart"),
                tuasKanan = daftarTuas(model, "Kanan"),
                tuasKiri = daftarTuas(model, "Kiri"),
                blink = false,
                mode = "",
        }
        mesin[index] = m
        if m.asap then
                m.asap.Enabled = false
        end
        if m.suaraGiling then
                m.suaraGiling.Playing = false
        end
        MesinSemaiService.terapkanTahap(index)
end

local function setStatus(index: number)
        local m = mesin[index]
        if not m or not m.status or not m.status.Parent then
                return
        end
        local b = batch[index]
        local cfg = TEKS_TAHAP[b and b.tahap or "kosong"]
        m.status.Text = cfg.teks
        m.status.TextColor3 = Color3.fromRGB(cfg.warna[1], cfg.warna[2], cfg.warna[3])
end

local function setLampu(part: any, warna: Color3, nyala: boolean)
        if part and part.Parent then
                part.Color = warna
                part.Transparency = nyala and LAMPU_NYALA or LAMPU_MATI
        end
end

local MERAH_ON = Color3.fromRGB(232, 76, 60)
local KUNING_ON = Color3.fromRGB(255, 206, 84)
local HIJAU_ON = Color3.fromRGB(108, 220, 116)
local LAMPU_OFF = Color3.fromRGB(72, 76, 84)

local function lampuTuas(index: number, nama: string, t: any, kuningBlink: boolean)
        local m = mesin[index]
        local tuas = m and m["tuas" .. nama]
        if not tuas or not tuas.lampu then
                return
        end
        if type(t) == "table" and t[string.lower(nama)] == true then
                setLampu(tuas.lampu, HIJAU_ON, true)
        elseif kuningBlink then
                setLampu(tuas.lampu, KUNING_ON, true)
        else
                setLampu(tuas.lampu, LAMPU_OFF, false)
        end
end

local function lampuUpdate(index: number)
        local m = mesin[index]
        if not m then
                return
        end
        local b = batch[index]
        local tahap = b and b.tahap or "kosong"
        if tahap ~= m.mode then
                m.mode = tahap
                m.blink = false
        end
        local tuasAktif = tahap == "tuas"
        local merahNyala = tahap == "kosong"
        local kuningNyala = tahap == "giling" or (tuasAktif and m.blink)
        local hijauNyala = tahap == "tuntas"
        setLampu(m.lampuMerah, merahNyala and MERAH_ON or LAMPU_OFF, merahNyala)
        setLampu(m.lampuKuning, kuningNyala and KUNING_ON or LAMPU_OFF, kuningNyala)
        setLampu(m.lampuHijau, hijauNyala and HIJAU_ON or LAMPU_OFF, hijauNyala)
        local t = tuasAktif and b.tuas or nil
        lampuTuas(index, "Kanan", t, tuasAktif and m.blink)
        lampuTuas(index, "Kiri", t, tuasAktif and m.blink and (type(t) == "table" and t.kanan == true))
end

local function aturPromptTuas(index: number)
        local m = mesin[index]
        if not m then
                return
        end
        local b = batch[index]
        local tahap = b and b.tahap or "kosong"
        local t = b and b.tuas
        local berikut = (tahap == "tuas") and SemaiLogic.tuasBerikut(t) or nil
        if m.tuasKanan and m.tuasKanan.prompt then
                m.tuasKanan.prompt.Enabled = berikut == "kanan"
        end
        if m.tuasKiri and m.tuasKiri.prompt then
                m.tuasKiri.prompt.Enabled = berikut == "kiri"
        end
end

function MesinSemaiService.terapkanTahap(index: number)
        setStatus(index)
        lampuUpdate(index)
        aturPromptTuas(index)
        local m = mesin[index]
        if not m then
                return
        end
        local b = batch[index]
        local tahap = b and b.tahap or "kosong"
        local aktif = tahap == "giling"
        if m.asap then
                m.asap.Enabled = aktif
        end
        if m.suaraGiling then
                m.suaraGiling.Playing = aktif
        end
        if tahap == "tuntas" and m.suaraDing then
                m.suaraDing:Play()
        end
        if tahap == "giling" and m.suaraStart then
                m.suaraStart:Play()
        end
end

local function animasiTuas(m: any, nama: string, turun: boolean)
        local tuas = m and m["tuas" .. nama]
        if not tuas or not tuas.cfTurun or not tuas.cfNaik then
                return
        end
        local target = turun and tuas.cfTurun or tuas.cfNaik
        local targetKnob = turun and tuas.knobTurun or tuas.knobNaik
        local info = TweenInfo.new(WAKTU_ANIM_TUAS, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(tuas.arm, info, { CFrame = target }):Play()
        if tuas.knob and targetKnob then
                TweenService:Create(tuas.knob, info, { CFrame = targetKnob }):Play()
        end
end

RunService.Heartbeat:Connect(function(dt)
        local now = os.clock()
        for index, m in pairs(mesin) do
                local b = batch[index]
                if b and b.tahap == "giling" then
                        local sudut = now * 8
                        local putar = CFrame.Angles(sudut, 0, 0)
                        if m.drum and m.drumBase then
                                m.drum.CFrame = m.drumBase * putar
                        end
                        if m.rib1 and m.rib1Base then
                                m.rib1.CFrame = m.rib1Base * putar
                        end
                        if m.rib2 and m.rib2Base then
                                m.rib2.CFrame = m.rib2Base * putar
                        end
                        if m.rib3 and m.rib3Base then
                                m.rib3.CFrame = m.rib3Base * putar
                        end
                        if m.girA and m.girABase then
                                m.girA.CFrame = m.girABase * CFrame.Angles(now * 6, 0, 0)
                        end
                        if m.girB and m.girBBase then
                                m.girB.CFrame = m.girBBase * CFrame.Angles(-now * 6, 0, 0)
                        end
                        if m.roda and m.rodaBase then
                                m.roda.CFrame = m.rodaBase * CFrame.Angles(now * 10, 0, 0)
                        end
                end
        end
end)

task.spawn(function()
        while true do
                task.wait(0.4)
                for index, m in pairs(mesin) do
                        local b = batch[index]
                        local tahap = b and b.tahap or "kosong"
                        if tahap == "tuas" then
                                m.blink = not m.blink
                        elseif m.blink then
                                m.blink = false
                        end
                        lampuUpdate(index)
                end
        end
end)

local function syncLahan(index: number, player: Player?)
        local b = batch[index]
        local p: any = { lahan = index, tahap = b and b.tahap or "kosong" }
        if b then
                p.crop = b.crop
                p.jumlah = b.jumlah
                p.pukulan = b.pukulan
                p.micda = b.hasil.micda
                p.benih = b.hasil.benih
                p.blok = b.hasil.blok
                if b.tahap == "tuas" then
                        p.tuas = { kanan = b.tuas.kanan, kiri = b.tuas.kiri }
                end
        end
        local ev = Net.get("SemaiSync")
        if player then
                ev:FireClient(player, p)
                return
        end
        for _, pl in ipairs(game:GetService("Players"):GetPlayers()) do
                if Land.landOf(pl) == index then
                        ev:FireClient(pl, p)
                end
        end
end

function MesinSemaiService.syncTo(player, index: number)
        syncLahan(index, player)
end

function MesinSemaiService.clearLahan(index: number)
        batch[index] = nil
        local m = mesin[index]
        if m then
                m.mode = ""
                m.blink = false
        end
        MesinSemaiService.terapkanTahap(index)
end

local function dekatMesin(player: Player, index: number): boolean
        local m = mesin[index]
        if not m then
                return false
        end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not root or (root.Position - m.pos).Magnitude > CropData.MesinSemai.JarakMaks then
                return false
        end
        return true
end

local function resetTuas(index: number)
        local m = mesin[index]
        if not m then
                return
        end
        for _, nama in ipairs({ "Kanan", "Kiri" }) do
                local tuas = m["tuas" .. nama]
                if tuas and tuas.cfNaik then
                        tuas.arm.CFrame = tuas.cfNaik
                        if tuas.knob and tuas.knobNaik then
                                tuas.knob.CFrame = tuas.knobNaik
                        end
                end
        end
end

function MesinSemaiService.atur(player, cropId: any, jumlah: any): (boolean, string)
        local index = Land.landOf(player)
        if not index then
                return false, "Kamu tidak punya lahan."
        end
        if batch[index] then
                return false, "Mesin masih berisi semaian. Selesaikan dulu."
        end
        if type(cropId) ~= "string" or not CropData.byId[cropId] then
                return false, "Hasil panen tidak dikenal."
        end
        if type(jumlah) ~= "number" or jumlah ~= jumlah or jumlah % 1 ~= 0 or jumlah < 1 then
                return false, "Jumlah tidak sah."
        end
        if not mesin[index] or not dekatMesin(player, index) then
                return false, "Terlalu jauh dari mesin."
        end
        local info = CropData.byId[cropId]
        local cfg = CropData.Giling[info.rarity]
        local kapasitas = CropData.MesinSemai.Kapasitas
        if jumlah > kapasitas then
                jumlah = kapasitas
        end
        local dimiliki = Tas.count(player, "hasil", cropId)
        if dimiliki < 1 then
                return false, "Tidak ada " .. info.nama .. " di tas."
        end
        if jumlah > dimiliki then
                jumlah = dimiliki
        end
        local diambil = Tas.remove(player, "hasil", cropId, jumlah)
        if diambil < 1 then
                return false, "Hasil panen tidak bisa diambil dari tas."
        end
        local hasil = SemaiLogic.gulung(rng, cfg, diambil)
        resetTuas(index)
        batch[index] = {
                pemilik = player.UserId,
                crop = cropId,
                jumlah = diambil,
                pukulan = SemaiLogic.pukulanTotal(diambil, SemaiLogic.pukulanPerItem(cfg)),
                hasil = hasil,
                tahap = "tuas",
                tuas = SemaiLogic.tuasBaru(),
        }
        if World then
                World.touch(index)
        end
        MesinSemaiService.terapkanTahap(index)
        syncLahan(index)
        return true, info.nama .. " x" .. tostring(diambil) .. " masuk mesin. Tekan tuas KANAN, lalu tuas KIRI!", {
                crop = cropId,
                jumlah = diambil,
                pukulan = batch[index].pukulan,
                kapasitas = kapasitas,
        }
end

function MesinSemaiService.tekan(player, sisi: any): (boolean, string)
        local index = Land.landOf(player)
        if not index then
                return false, "Kamu tidak punya lahan."
        end
        local b = batch[index]
        if not b then
                return false, "Mesin kosong. Isi dulu hasil panennya."
        end
        if b.pemilik ~= player.UserId then
                return false, "Bukan semaianmu."
        end
        if b.tahap ~= "tuas" then
                return false, "Tuas sudah selesai ditekan."
        end
        if not dekatMesin(player, index) then
                return false, "Terlalu jauh dari mesin."
        end
        local ok, kode = SemaiLogic.prosesTekan(b.tuas, sisi)
        if not ok then
                if kode == "urutan" then
                        local berikut = SemaiLogic.tuasBerikut(b.tuas)
                        return false, "Urutan salah! Tekan tuas " .. string.upper(berikut or "kanan") .. " dulu."
                elseif kode == "sudah" then
                        return false, "Tuas ini sudah ditekan."
                elseif kode == "sisi" then
                        return false, "Sisi tuas tidak dikenal."
                end
                return false, "Tuas tidak bisa ditekan."
        end
        local namaBesar = (sisi == "kanan") and "Kanan" or "Kiri"
        animasiTuas(mesin[index], namaBesar, true)
        local tuasM = mesin[index] and mesin[index]["tuas" .. namaBesar]
        if tuasM and tuasM.suara then
                tuasM.suara:Play()
        end
        if SemaiLogic.tuasSelesai(b.tuas) then
                b.tahap = "giling"
                MesinSemaiService.terapkanTahap(index)
                syncLahan(index)
                local waktu = CropData.MesinSemai.WaktuGiling
                task.delay(waktu, function()
                        local b2 = batch[index]
                        if b2 and b2.tahap == "giling" then
                                b2.tahap = "tuntas"
                                if World then
                                        World.touch(index)
                                end
                                MesinSemaiService.terapkanTahap(index)
                                syncLahan(index)
                        end
                end)
                return true, "Kedua tuas aktif! Mesin menyala dan menggiling selama " .. tostring(waktu) .. " detik."
        end
        MesinSemaiService.terapkanTahap(index)
        syncLahan(index)
        if sisi == "kanan" then
                return true, "Tuas KANAN aktif! Sekarang tekan tuas KIRI."
        end
        return true, "Tuas aktif."
end

function MesinSemaiService.klaim(player): (boolean, string, any)
        local index = Land.landOf(player)
        if not index then
                return false, "Kamu tidak punya lahan."
        end
        local b = batch[index]
        if not b then
                return false, "Mesin kosong. Belum ada hasil untuk diklaim."
        end
        if b.pemilik ~= player.UserId then
                return false, "Bukan semaianmu."
        end
        if b.tahap == "tuas" then
                return false, "Tekan kedua tuas mesin dulu."
        elseif b.tahap == "giling" then
                return false, "Mesin masih menggiling. Tunggu sebentar."
        end
        if not dekatMesin(player, index) then
                return false, "Terlalu jauh dari mesin."
        end
        local info = CropData.byId[b.crop]
        local items = {}
        if b.hasil.benih > 0 then
                table.insert(items, { kind = "benih", id = b.crop, count = b.hasil.benih })
        end
        if b.hasil.blok > 0 then
                table.insert(items, { kind = "blok", id = CropData.blokIdFor(b.crop), count = b.hasil.blok })
        end
        if #items > 0 and not Tas.canFitBatch(player, items) then
                return false, "Tas penuh! Kosongkan slot dulu, lalu klaim lagi."
        end
        for _, it in ipairs(items) do
                Tas.add(player, it.kind, it.id, it.count)
        end
        local okUang, msgUang = true, "ok"
        if b.hasil.micda > 0 and Uang then
                okUang, msgUang = Uang.AddMicda(player, b.hasil.micda, "semai_hasil")
        end
        local struk = {
                crop = b.crop,
                nama = info and info.nama or b.crop,
                jumlah = b.jumlah,
                pukulan = b.pukulan,
                micda = b.hasil.micda,
                benih = b.hasil.benih,
                blok = b.hasil.blok,
                uangOk = okUang,
        }
        batch[index] = nil
        if World then
                World.touch(index)
        end
        MesinSemaiService.terapkanTahap(index)
        syncLahan(index)
        if okUang then
                return true, "Semai tuntas! Semua hasil masuk tas.", struk
        end
        return false, "Micda ditunda: " .. tostring(msgUang), struk
end

function MesinSemaiService.serializeLahan(index: number): { any }
        local out = {}
        local b = batch[index]
        if b then
                table.insert(out, { c = b.crop, j = b.jumlah, m = b.hasil.micda, b = b.hasil.benih, k = b.hasil.blok })
        end
        return out
end

function MesinSemaiService.restoreLahan(index: number, arr: any, ownerId: number?)
        if not mesin[index] then
                return
        end
        for _, rec in ipairs(arr or {}) do
                if type(rec) == "table" and type(rec.c) == "string" and CropData.byId[rec.c] then
                        local info = CropData.byId[rec.c]
                        local jumlah = 1
                        local micda = info.jual
                        local benih = 0
                        local blok = 0
                        if type(rec.j) == "number" and rec.j >= 1 then
                                jumlah = math.min(math.floor(rec.j), CropData.MesinSemai.Kapasitas)
                                micda = type(rec.m) == "number" and math.max(0, math.floor(rec.m)) or 0
                                benih = type(rec.b) == "number" and math.max(0, math.floor(rec.b)) or 0
                                blok = type(rec.k) == "number" and math.max(0, math.floor(rec.k)) or 0
                        end
                        resetTuas(index)
                        batch[index] = {
                                pemilik = ownerId,
                                crop = rec.c,
                                jumlah = jumlah,
                                pukulan = jumlah,
                                hasil = { micda = micda, benih = benih, blok = blok },
                                tahap = "tuntas",
                        }
                        break
                end
        end
        MesinSemaiService.terapkanTahap(index)
end

return MesinSemaiService
