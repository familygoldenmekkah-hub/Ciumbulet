--!nonstrict
--[[
        QuizService.luau
        Mesin kuis server-authoritative:
          StartQuiz(zoneIndex)  -> server generate soal (MathGen), simpan jawaban
                                   di state server, kirim soal TANPA kunci jawaban.
          AnswerQuiz(qid, pilih) -> validasi, beri XP/koin/streak, kirim feedback.
        Soal aktif per pemain + kedaluwarsa + cooldown = anti-spam/anti-exploit.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage.Shared.Config)
local MathGen = require(ReplicatedStorage.Shared.MathGen)
local Remotes = require(ReplicatedStorage.Remotes)
local DataService = require(script.Parent.DataService)

local QuizService = {}

local notify = Remotes.get("Notify")

local ANSWER_COOLDOWN = Config.Progress.AnswerCooldown

-- player -> soal aktif
local active: { [Player]: { qid: string, benar: number, zoneIndex: number, betul: string, salah: string, born: number } } = {}
local lastAnswer: { [Player]: number } = {}

local function unlockedZoneCount(data): number
        -- zona 1 selalu terbuka; zona N+1 terbuka jika zona N dikuasai
        local count = 1
        for i = 1, #Config.Zones - 1 do
                if data.Mastered[Config.Zones[i].id] then
                        count = i + 1
                else
                        break
                end
        end
        return count
end

function QuizService.unlockedZoneCount(player: Player): number
        local data = DataService.get(player)
        return unlockedZoneCount(data)
end

--------------------------------------------------------------------
-- REQUEST STORY (NPC cerita per zona)
--------------------------------------------------------------------

local function onRequestStory(player: Player, zoneIndex: any)
        if type(zoneIndex) ~= "number" or not DataService.has(player) then
                return nil
        end
        zoneIndex = math.clamp(math.floor(zoneIndex), 1, #Config.Zones)
        if zoneIndex > QuizService.unlockedZoneCount(player) then
                return { locked = true }
        end
        local zone = Config.Zones[zoneIndex]
        -- halaman cerita original, ditulis khusus versi Roblox
        local stories = {
                [1] = {
                        "Selamat datang di Kamp Angka! Aku Kak Satu, penjaga pintu kamp.",
                        "Semua petualangan matematika dimulai dari sini: berhitung. Tanpa berhitung, karavan tersesat dan gudang kosong.",
                        "Jawab tantanganku untuk membuka jalan ke Hutan Simbol. Siap? Ayo mulai!",
                },
                [2] = {
                        "Halo, aku Kak Simbol dari Hutan Simbol. Di sini tanda-tanda punya kuasa.",
                        "Kali, kurung, minus... satu tanda bisa mengubah segalanya. Hutan ini mengajarkan bahasa matematika.",
                        "Buktikan kamu paham bahasanya, dan Pegunungan Pola menantimu.",
                },
                [3] = {
                        "Selamat datang di Pegunungan Pola! Aku Kak Pola, pemandu pendakian.",
                        "Gunung ini penuh barisan: naik-turun yang beraturan. Siapa melihat pola, dia setengah jalan.",
                        "Tantanganmu: tebak langkah berikutnya. Pendaki hebat selalu melihat pola!",
                },
                [4] = {
                        "Aku Kak Bukti, wali Kota Bukti. Di kota ini, klaim tanpa bukti tak lulus sidang.",
                        "Persamaan, luas, pertidaksamaan - semua harus diuji dengan perhitungan.",
                        "Selesaikan sidangnya, dan Lembah Kedalaman terbuka untukmu.",
                },
                [5] = {
                        "Aku Kak Dalam dari Lembah Kedalaman. Di sini kita tak berhenti di permukaan.",
                        "Fungsi, pangkat, pecahan - kita gali sampai mengerti 'kenapa'-nya.",
                        "Jawab dengan pemahaman, bukan terkaan, dan puncak akan memanggilmu.",
                },
                [6] = {
                        "Akhirnya! Aku Kak Prima, penjaga Puncak Riset. Hanya penjelajah terdepan sampai sini.",
                        "Prima, modulo, pola Gauss - alat-alat para peneliti sejati.",
                        "Tak ada zona setelah ini. Tantanganmu sekarang: skor tertinggi di papan penjelajah!",
                },
        }
        return { npc = "KAK " .. string.upper(zone.name:split(" ")[2] or zone.name), zone = zoneIndex, pages = stories[zoneIndex] }
end

--------------------------------------------------------------------
-- START QUIZ
--------------------------------------------------------------------

local function onStartQuiz(player: Player, zoneIndex: any)
        if type(zoneIndex) ~= "number" or not DataService.has(player) then
                return nil
        end
        zoneIndex = math.clamp(math.floor(zoneIndex), 1, #Config.Zones)
        if zoneIndex > QuizService.unlockedZoneCount(player) then
                return { locked = true }
        end

        local q = MathGen.generate(zoneIndex)
        local qid = tostring(math.random(1, 1e9)) .. "-" .. tostring(os.clock())
        active[player] = {
                qid = qid,
                benar = q.benar,
                zoneIndex = zoneIndex,
                betul = q.betul,
                salah = q.salah,
                born = time(),
        }
        return {
                qid = qid,
                zone = zoneIndex,
                t = q.t,
                opsi = q.opsi,
                -- kunci jawaban TIDAK dikirim ke client
        }
end

--------------------------------------------------------------------
-- ANSWER QUIZ
--------------------------------------------------------------------

local function onAnswerQuiz(player: Player, qid: any, choice: any)
        local data = DataService.get(player)
        local now = time()

        if lastAnswer[player] and now - lastAnswer[player] < ANSWER_COOLDOWN then
                return nil
        end
        lastAnswer[player] = now

        local current = active[player]
        if not current or not DataService.has(player) or type(choice) ~= "number" then
                return nil
        end
        if type(qid) ~= "string" or qid ~= current.qid then
                return nil -- soal sudah basi / gak cocok
        end
        if now - current.born > Config.Progress.MaxActiveQuestionSeconds then
                active[player] = nil
                return { expired = true }
        end
        active[player] = nil

        local zone = Config.Zones[current.zoneIndex]
        local correct = (math.floor(choice) == current.benar)

        if not correct then
                data.Streak = 0
                DataService.markDirty(player)
                QuizService.pushState(player)
                return { correct = false, feedback = current.salah, zoneName = zone.name }
        end

        -- benar: streak + XP + koin
        data.Streak += 1
        data.BestStreak = math.max(data.BestStreak, data.Streak)
        local streakBonus = math.min(data.Streak, Config.Progress.StreakBonusMax)
        data.XP += Config.Progress.XpPerCorrect + streakBonus
        data.Coins += Config.Progress.CoinPerCorrect * current.zoneIndex

        local zoneId = zone.id
        data.Correct[zoneId] = (data.Correct[zoneId] or 0) + 1

        local justMastered = false
        if not data.Mastered[zoneId] and data.Correct[zoneId] >= Config.Progress.MasteryTarget then
                data.Mastered[zoneId] = true
                justMastered = true
                data.XP += Config.Progress.MasteryBonusXp
                data.Coins += Config.Progress.MasteryBonusCoins
                if Config.Progress.UnlockNextOnMastery and current.zoneIndex < #Config.Zones then
                        notify:FireClient(player, "Zona baru!", Config.Zones[current.zoneIndex + 1].name .. " telah terbuka!")
                end
        end

        DataService.markDirty(player)
        QuizService.pushState(player)
        return {
                correct = true,
                feedback = current.betul,
                zoneName = zone.name,
                streak = data.Streak,
                justMastered = justMastered,
        }
end

--------------------------------------------------------------------
-- BAHASAN (membaca topik)
--------------------------------------------------------------------

local function onReadTopic(player: Player, topicId: any)
        if type(topicId) ~= "string" or not DataService.has(player) then
                return nil
        end
        local data = DataService.get(player)
        if table.find(data.Read, topicId) then
                return { already = true, total = #data.Read }
        end
        table.insert(data.Read, topicId)
        data.XP += 5
        data.Coins += 2
        DataService.markDirty(player)
        QuizService.pushState(player)
        return { already = false, total = #data.Read, xp = data.XP }
end

--------------------------------------------------------------------
-- KODE PENJELAJAH (dev)
--------------------------------------------------------------------

local function onRedeemDevCode(player: Player, code: any)
        if type(code) ~= "string" or not DataService.has(player) then
                return false
        end
        if code ~= Config.DevCode then
                return false, "Kode salah."
        end
        local data = DataService.get(player)
        if data.Dev then
                return true, "Kode sudah aktif."
        end
        data.Dev = true
        DataService.markDirty(player)
        QuizService.pushState(player)
        notify:FireClient(player, "Penjelajah Dev", "Kode diterima. Selamat datang kembali, pembuat dunia!")
        return true, "Kode diterima!"
end

--------------------------------------------------------------------
-- STATE SYNC
--------------------------------------------------------------------

function QuizService.pushState(player: Player)
        if not DataService.has(player) then
                return
        end
        local data = DataService.get(player)

        -- sinkronkan leaderstats XP (papan peringkat standar Roblox)
        local stats = player:FindFirstChild("leaderstats")
        if stats then
                local xp = stats:FindFirstChild("XP")
                if xp and xp:IsA("IntValue") then
                        xp.Value = math.floor(data.XP)
                end
        end

        Remotes.get("StateSync"):FireClient(player, {
                XP = data.XP,
                Coins = data.Coins,
                Correct = data.Correct,
                Mastered = data.Mastered,
                Read = data.Read,
                ReadCount = #data.Read,
                Streak = data.Streak,
                BestStreak = data.BestStreak,
                Dev = data.Dev,
                Unlocked = QuizService.unlockedZoneCount(player),
                MasteryTarget = Config.Progress.MasteryTarget,
        })
end

--------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------

function QuizService.init()
        Remotes.get("RequestStory").OnServerInvoke = onRequestStory
        Remotes.get("StartQuiz").OnServerInvoke = onStartQuiz
        Remotes.get("AnswerQuiz").OnServerInvoke = onAnswerQuiz
        Remotes.get("ReadTopic").OnServerInvoke = onReadTopic
        Remotes.get("RedeemDevCode").OnServerInvoke = onRedeemDevCode

        Players.PlayerRemoving:Connect(function(player)
                active[player] = nil
                lastAnswer[player] = nil
        end)
end

return QuizService
