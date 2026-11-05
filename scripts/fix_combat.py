import re

p = "/home/z/my-project/download/dunia-akiomida/src/Server/Modules/CombatService.luau"
src = open(p).read()

# 1) re-add hpBillboard signature before orphaned body
anchor = "        return model, root\nend\n        local gui = Instance.new(\"BillboardGui\")"
assert anchor in src, "anchor A missing"
src = src.replace(
    anchor,
    "        return model, root\nend\n\n"
    + "local function hpBillboard(body: Part, name: string, hp: number, maxHp: number, isBoss: boolean)\n"
    + "        local gui = Instance.new(\"BillboardGui\")",
    1,
)

# 2) remove the OLD ball/box buildMonsterModel (second occurrence)
start_marker = 'local function buildMonsterModel(def: any, position: Vector3, isBoss: boolean): (Model, Part)\n        local model = Instance.new("Model")\n        model.Name = isBoss and "RajaGolem"'
first = src.find("local function buildMonsterModel(def: any, position: Vector3, isBoss: boolean): (Model, Part)")
second = src.find(start_marker)
assert second > first, "old marker not found after new one"
end_marker = "        return model, body\nend\n\n--------------------------------------------------------------------\n-- SPAWN & AI"
end = src.find(end_marker, second)
assert end > second, "end marker missing"
src = src[:second] + src[end + len("        return model, body\nend\n\n"):]

open(p, "w").write(src)
print("fixed. hpBillboard count:", src.count("local function hpBillboard"))
print("buildMonsterModel count:", src.count("local function buildMonsterModel"))
