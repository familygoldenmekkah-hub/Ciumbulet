--!nonstrict
--[[
        QuestService.luau - v3 "Toram-grade" papan tugas:
          - Rotasi harian 3 tugas dari kolam Balance.Quests (deterministik
            per hari, sama untuk semua server)
          - Terima 1 tugas aktif, progres otomatis dari aktivitas dunia:
            harvest / chop / mine / fish / kill / craft / cook
          - Klaim hadiah koin+XP di papan tugas
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Remotes)
local Balance = require(ReplicatedStorage.Shared.Balance)

local DataService = require(script.Parent.DataService)

local QuestService = {}

local questById: { [string]: any } = {}
for _, q in ipairs(Balance.Quests) do
        questById[q.id] = q
end

--------------------------------------------------------------------
-- ROTASI HARIAN (di Balance - dipakai server & client)
--------------------------------------------------------------------

function QuestService.todayQuestIds(): { string }
	return Balance.todayQuestIds()
end

--------------------------------------------------------------------
-- AKSI TUGAS
--------------------------------------------------------------------

local function snapshot(player: Player)
        local data = DataService.get(player)
        local active = nil
        if data.Quest.id ~= "" then
                local q = questById[data.Quest.id]
                if q then
                        active = {
                                id = q.id,
                                title = q.title,
                                desc = q.desc,
                                prog = math.min(data.Quest.prog, q.goal.count),
                                count = q.goal.count,
                                done = data.Quest.done,
                                coins = q.reward.coins,
                                xp = q.reward.xp,
                        }
                end
        end
        local offers = {}
        for _, id in QuestService.todayQuestIds() do
                local q = questById[id]
                if q and id ~= data.Quest.id then
                        table.insert(offers, { id = q.id, title = q.title, desc = q.desc, coins = q.reward.coins, xp = q.reward.xp })
                end
        end
        return { active = active, offers = offers }
end

local function onQuestAction(player: Player, action: any, questId: any)
        if not DataService.has(player) or type(action) ~= "string" then
                return { ok = false, msg = "Permintaan tidak valid." }
        end
        local data = DataService.get(player)

        if action == "list" then
                return { ok = true, board = snapshot(player) }
        end

        if action == "accept" then
                if type(questId) ~= "string" then
                        return { ok = false, msg = "Tugas tidak dikenal." }
                end
                if data.Quest.id ~= "" and not data.Quest.done then
                        return { ok = false, msg = "Selesaikan tugas yang sedang berjalan dulu!" }
                end
                local offered = false
                for _, id in QuestService.todayQuestIds() do
                        if id == questId then
                                offered = true
                                break
                        end
                end
                local q = questById[questId]
                if not offered or not q then
                        return { ok = false, msg = "Tugas itu tidak ada di papan hari ini." }
                end
                data.Quest = { id = questId, prog = 0, acceptedAt = os.time(), done = false }
                DataService.markDirty(player)
                DataService.push(player)
                return { ok = true, msg = "Tugas diterima: " .. q.title .. " - " .. q.desc, board = snapshot(player) }
        end

        if action == "claim" then
                if data.Quest.id == "" then
                        return { ok = false, msg = "Belum ada tugas aktif." }
                end
                local q = questById[data.Quest.id]
                if not q or not data.Quest.done then
                        return { ok = false, msg = "Tugas belum selesai. Semangat!" }
                end
                DataService.addCoins(player, q.reward.coins, true)
                DataService.addXP(player, q.reward.xp)
                data.Quest = { id = "", prog = 0, acceptedAt = 0, done = false }
                DataService.markDirty(player)
                DataService.push(player)
                return { ok = true, msg = "Tugas selesai! +" .. q.reward.coins .. " koin, +" .. q.reward.xp .. " XP", board = snapshot(player) }
        end

        return { ok = false, msg = "Aksi tidak dikenal." }
end

--------------------------------------------------------------------
-- HOOK PROGRES DARI LAYANAN LAIN
--------------------------------------------------------------------

--- type: "harvest" | "chop" | "mine" | "fish" | "kill" | "craft" | "cook"
function QuestService.progress(player: Player, kind: string, amount: number)
        if not DataService.has(player) then
                return
        end
        local data = DataService.get(player)
        if data.Quest.id == "" or data.Quest.done then
                return
        end
        local q = questById[data.Quest.id]
        if not q or q.goal.type ~= kind then
                return
        end
        data.Quest.prog = math.min(q.goal.count, data.Quest.prog + math.max(1, amount))
        if data.Quest.prog >= q.goal.count then
                data.Quest.done = true
                Remotes.get("Notify"):FireClient(player, "Tugas Selesai!",
                        q.title .. " selesai! Kembali ke Papan Tugas di alun-alun untuk klaim hadiah.")
        else
                Remotes.get("Notify"):FireClient(player, "Progres Tugas",
                        q.title .. ": " .. data.Quest.prog .. "/" .. q.goal.count)
        end
        DataService.markDirty(player)
end

--------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------

function QuestService.bindBoard(prompt: ProximityPrompt)
        prompt.ActionText = "Lihat Tugas"
        prompt.ObjectText = "Papan Tugas Harian"
        prompt.MaxActivationDistance = 11
        prompt.HoldDuration = 0
        prompt.Triggered:Connect(function(player)
                if DataService.has(player) then
                        Remotes.get("OpenQuest"):FireClient(player)
                end
        end)
end

function QuestService.init()
        Remotes.get("QuestAction").OnServerInvoke = onQuestAction
end

return QuestService
