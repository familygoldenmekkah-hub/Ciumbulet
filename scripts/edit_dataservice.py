import pathlib

p = pathlib.Path("/home/z/my-project/download/dunia-akiomida/src/Server/Modules/DataService.luau")
s = p.read_text()

def rep(old, new):
    global s
    assert old in s, "MISSING: " + old[:80]
    s = s.replace(old, new, 1)

rep("""        Coins = Config.Economy.StartCoins,
                XP = 0,
                Seeds = Util.deepCopy(Config.Economy.StartSeeds),
                Crops = {},
                Bag = {},
                Fish = {},
                Tools = { pickTier = 1, can = false, rod = false, bike = false },
                Pets = {},
                ActivePet = "",
                -- v3: Toram-grade progression
                Stats = { str = 0, vit = 0, agi = 0, int = 0, dex = 0 },
                StatPoints = 0, -- poin gratis dari naik level
                Equips = {},
                EquipStars = {}, -- v8: level upgrade +1..+5 per equip
                CraftCount = {}, -- v10: jumlah tiap resep dibuat (mastery)
                Usables = {},
                Equipped = { weapon = "", armor = "" },
                Buff = { kind = "", expiry = 0 },
                Quest = { id = "", prog = 0, acceptedAt = 0, done = false },
                TotalEarned = 0,
                LastLoginDay = 0,
                Streak = 0, -- v9: rantai login harian
                HomeId = 0, -- v21: pulau rumah pribadi (0 = belum klaim)
                LandName = "",
                KoperasiName = "",
                Dev = false,
                LastSeen = 0,
        }""".replace("\n        ", "\n                "), """PLACEHOLDER_NOT_USED""") if False else None

old_default = """        return {
                Coins = Config.Economy.StartCoins,
                XP = 0,
                Seeds = Util.deepCopy(Config.Economy.StartSeeds),
                Crops = {},
                Bag = {},
                Fish = {},
                Tools = { pickTier = 1, can = false, rod = false, bike = false },
                Pets = {},
                ActivePet = "",
                -- v3: Toram-grade progression
                Stats = { str = 0, vit = 0, agi = 0, int = 0, dex = 0 },
                StatPoints = 0, -- poin gratis dari naik level
                Equips = {},
                EquipStars = {}, -- v8: level upgrade +1..+5 per equip
                CraftCount = {}, -- v10: jumlah tiap resep dibuat (mastery)
                Usables = {},
                Equipped = { weapon = "", armor = "" },
                Buff = { kind = "", expiry = 0 },
                Quest = { id = "", prog = 0, acceptedAt = 0, done = false },
                TotalEarned = 0,
                LastLoginDay = 0,
                Streak = 0, -- v9: rantai login harian
                HomeId = 0, -- v21: pulau rumah pribadi (0 = belum klaim)
                LandName = "",
                KoperasiName = "",
                Dev = false,
                LastSeen = 0,
        }"""

new_default = """        return {
                Coins = Config.Economy.StartCoins,
                XP = 0,
                Seeds = {},
                Crops = {},
                Bag = {},
                Fish = {},
                Stats = { str = 0, vit = 0, agi = 0, int = 0, dex = 0 },
                StatPoints = 0,
                Equips = {},
                EquipStars = {},
                CraftCount = {},
                Usables = {},
                Equipped = { weapon = "", armor = "" },
                Buff = { kind = "", expiry = 0 },
                TotalEarned = 0,
                LastLoginDay = 0,
                Streak = 0,
                HomeId = 0,
                LandName = "",
                KoperasiName = "",
                Dev = false,
                LastSeen = 0,
        }"""
rep(old_default, new_default)

old_tools = """        if type(raw.Tools) == "table" then
                out.Tools.pickTier = math.clamp(math.floor(tonumber(raw.Tools.pickTier) or 1), 1, 3)
                out.Tools.can = raw.Tools.can == true
                out.Tools.rod = raw.Tools.rod == true
                out.Tools.bike = raw.Tools.bike == true
        end
        if type(raw.Pets) == "table" then
                for id, owned in raw.Pets do
                        if type(id) == "string" and owned == true then
                                out.Pets[id] = true
                        end
                end
        end
"""
assert old_tools in s
s = s.replace(old_tools, "")

old_quest = """        if type(raw.Quest) == "table" then
                out.Quest.id = type(raw.Quest.id) == "string" and raw.Quest.id or ""
                out.Quest.prog = sanitizeCount(raw.Quest.prog)
                out.Quest.acceptedAt = sanitizeCount(raw.Quest.acceptedAt)
                out.Quest.done = raw.Quest.done == true
        end
        out.ActivePet = type(raw.ActivePet) == "string" and raw.ActivePet or ""
"""
assert old_quest in s
s = s.replace(old_quest, "")

old_push = """                Seeds = Util.deepCopy(data.Seeds),
                Crops = Util.deepCopy(data.Crops),
                Bag = Util.deepCopy(data.Bag),
                Fish = Util.deepCopy(data.Fish),
                Tools = Util.deepCopy(data.Tools),
                Pets = Util.deepCopy(data.Pets),
                ActivePet = data.ActivePet,
                -- v3
                Stats = Util.deepCopy(data.Stats),
                StatPoints = data.StatPoints,
                Equips = Util.deepCopy(data.Equips),
                EquipStars = Util.deepCopy(data.EquipStars),
                CraftCount = Util.deepCopy(data.CraftCount),
                Usables = Util.deepCopy(data.Usables),
                Equipped = Util.deepCopy(data.Equipped),
                Buff = Util.deepCopy(data.Buff),
                Quest = Util.deepCopy(data.Quest),
                Plot = okPlot and plotState or { claimed = false, tiles = {} },
                Demand = okDemand and demand or {},
                Dev = data.Dev,
                Streak = data.Streak,"""
new_push = """                Seeds = Util.deepCopy(data.Seeds),
                Crops = Util.deepCopy(data.Crops),
                Bag = Util.deepCopy(data.Bag),
                Fish = Util.deepCopy(data.Fish),
                Stats = Util.deepCopy(data.Stats),
                StatPoints = data.StatPoints,
                Equips = Util.deepCopy(data.Equips),
                EquipStars = Util.deepCopy(data.EquipStars),
                CraftCount = Util.deepCopy(data.CraftCount),
                Usables = Util.deepCopy(data.Usables),
                Equipped = Util.deepCopy(data.Equipped),
                Buff = Util.deepCopy(data.Buff),
                Farm = okPlot and plotState or { lahan = 0 },
                Dev = data.Dev,
                Streak = data.Streak,
                HomeId = data.HomeId,
                LandName = data.LandName,
                KoperasiName = data.KoperasiName,"""
rep(old_push, new_push)

rep("""        local okPlot, plotState = pcall(function()
                local fn = providers["plot"]
                if not fn then
                        return { claimed = false, tiles = {} }
                end
                return fn(player)
        end)
        local okDemand, demand = pcall(function()
                local fn = providers["demand"]
                if not fn then
                        return {}
                end
                return fn(player)
        end)""",
    """        local okPlot, plotState = pcall(function()
                local fn = providers["farm"]
                if not fn then
                        return { lahan = 0 }
                end
                return fn(player)
        end)""")

rep("""function DataService.countItem(player: Player, kind: string, id: string): number
        local field = KIND_FIELD[kind]
        if not field then
                return 0
        end
        local data = DataService.get(player)
        return data[field][id] or 0
end""",
    """function DataService.countItem(player: Player, kind: string, id: string): number
        local field = KIND_FIELD[kind]
        if not field then
                return 0
        end
        local data = DataService.get(player)
        return data[field][id] or 0
end

function DataService.tasTables(player: Player): ({ [string]: number }, { [string]: number })
        local data = DataService.get(player)
        return data.Seeds, data.Crops
end

function DataService.addWithCap(player: Player, kind: string, id: string, count: number): number
        local field = KIND_FIELD[kind]
        if not field then
                return 0
        end
        local seeds, crops = DataService.tasTables(player)
        local room = TasLogic.roomFor(seeds, crops, kind, id, count)
        if room > 0 then
                local data = DataService.get(player)
                data[field][id] = (data[field][id] or 0) + room
                DataService.markDirty(player)
        end
        return room
end""")

p.write_text(s)
print("DataService edits OK")
