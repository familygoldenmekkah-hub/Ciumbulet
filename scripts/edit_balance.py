import re, pathlib

p = pathlib.Path("/home/z/my-project/download/dunia-akiomida/src/Shared/Balance.luau")
src = p.read_text()

def rep(old, new):
    global src
    assert old in src, "MISSING: " + old[:70]
    src = src.replace(old, new, 1)

rep("""        { id = "pedang_kayu", station = "tempa", kind = "equip", out = "pedang_kayu", count = 1, level = 1,
                recipe = { kayu = 8 }, xp = 10 },""",
    """        { id = "pedang_kayu", station = "tempa", kind = "equip", out = "pedang_kayu", count = 1, level = 1,
                recipe = { gel = 10 }, xp = 10 },""")

rep("""        { id = "pedang_besi", station = "tempa", kind = "equip", out = "pedang_besi", count = 1, level = 4,
                recipe = { kayu = 6, balok_besi = 3 }, xp = 26 },""",
    """        { id = "pedang_besi", station = "tempa", kind = "equip", out = "pedang_besi", count = 1, level = 4,
                recipe = { gel = 6, balok_besi = 3 }, xp = 26 },""")

rep("""        { id = "zirah_kulit", station = "tempa", kind = "equip", out = "zirah_kulit", count = 1, level = 2,
                recipe = { gel = 6, kayu = 4 }, xp = 12 },""",
    """        { id = "zirah_kulit", station = "tempa", kind = "equip", out = "zirah_kulit", count = 1, level = 2,
                recipe = { taring = 5, gel = 5 }, xp = 12 },""")

rep("""        { id = "roti_aktif", station = "dapur", kind = "use", out = "roti_aktif", count = 1, level = 1,
                recipe = { wortel = 2, jagung = 1 }, xp = 5 },""",
    """        { id = "roti_aktif", station = "dapur", kind = "use", out = "roti_aktif", count = 1, level = 1,
                recipe = { wortel = 3 }, xp = 5 },""")

rep("""        { id = "ramuan_hijau", station = "dapur", kind = "use", out = "ramuan_hijau", count = 1, level = 2,
                recipe = { apel = 3 }, xp = 6 },""",
    """        { id = "ramuan_hijau", station = "dapur", kind = "use", out = "ramuan_hijau", count = 1, level = 2,
                recipe = { jamur = 3 }, xp = 6 },""")

rep("""        { id = "ramuan_inti", station = "dapur", kind = "use", out = "ramuan_inti", count = 1, level = 6,
                recipe = { inti = 1, apel = 2 }, xp = 18 },""",
    """        { id = "ramuan_inti", station = "dapur", kind = "use", out = "ramuan_inti", count = 1, level = 6,
                recipe = { inti = 1, jamur = 2 }, xp = 18 },""")

rep("""                drops = { { id = "inti", chance = 0.35, min = 1, max = 1 }, { id = "batu", chance = 0.8, min = 2, max = 3 } },
                zone = "tambang", level = 5,""",
    """                drops = { { id = "inti", chance = 0.35, min = 1, max = 1 }, { id = "besi", chance = 0.8, min = 2, max = 3 } },
                zone = "tambang", level = 5,""")

rep("""                drops = { { id = "gel", chance = 0.5, min = 1, max = 2 }, { id = "apel", chance = 0.35, min = 1, max = 2 } },
                zone = "padang", level = 2,""",
    """                drops = { { id = "gel", chance = 0.5, min = 1, max = 2 }, { id = "taring", chance = 0.35, min = 1, max = 2 } },
                zone = "padang", level = 2,""")

rep("""                drops = { { id = "taring", chance = 0.5, min = 1, max = 2 }, { id = "kayu", chance = 0.4, min = 1, max = 3 } },
                zone = "hutan", level = 4,""",
    """                drops = { { id = "taring", chance = 0.5, min = 1, max = 2 }, { id = "gel", chance = 0.4, min = 1, max = 3 } },
                zone = "hutan", level = 4,""")

rep("""        { id = "pusat", name = "Pusat Kota", kind = "hub", center = { 0, 0 }, half = { 170, 150 },
                gates = {
                        { dest = "home", pos = { 0, 132 } },
                        { dest = "panen", pos = { 0, -132 } },
                        { dest = "padang", pos = { 152, -60 } },
                        { dest = "hutan", pos = { 152, 40 } },
                        { dest = "baja", pos = { 152, 130 } },
                } },
        { id = "panen", name = "Pulau Panen", kind = "civil", center = { 0, -640 }, half = { 190, 150 },
                gates = { { dest = "pusat", pos = { 0, -498 } } } },""",
    """        { id = "pusat", name = "Pusat Kota", kind = "hub", center = { 0, 0 }, half = { 170, 150 },
                gates = {
                        { dest = "home", pos = { 0, 132 } },
                        { dest = "padang", pos = { 152, -60 } },
                        { dest = "hutan", pos = { 152, 40 } },
                        { dest = "baja", pos = { 152, 130 } },
                } },""")

m = re.search(r"\n-{20,}\n-- EVENT DUNIA TERJADWAL.*?\nBalance\.Event = \{.*?\n\}\n", src, re.S)
assert m, "event block missing"
src = src[:m.start()] + "\n" + src[m.end():]

m = re.search(r"\n-{20,}\n-- TUGAS \(papan tugas; rotasi harian deterministik\)\n-{20,}\nBalance\.Quests = \{.*?Balance\.QuestsPerDay = 3.*?\nend\n", src, re.S)
assert m, "quests block missing"
src = src[:m.start()] + "\n" + src[m.end():]

p.write_text(src)
print("Balance edits OK, lines:", src.count("\n"))
