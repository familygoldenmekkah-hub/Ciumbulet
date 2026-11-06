#!/usr/bin/env python3
"""Generator file playtest gabungan: stub + seluruh modul game + skenario.

File game tidak diubah sama sekali; require(Instance) digantikan secara
tekstual menjadi referensi variabel modul agar semuanya bisa berjalan
dalam satu chunk Luau (sandbox CLI mengisolasi global antar modul).
"""
import re
import pathlib
import sys

ROOT = pathlib.Path("/home/z/my-project")
SRC = ROOT / "download/dunia-akiomida/src"
SIM = ROOT / "scripts/sim"

STUB = (SIM / "roblox_stub.luau").read_text()


def scenario_text() -> str:
    args = sys.argv[1:]
    path = pathlib.Path(args[0]) if len(args) >= 1 else (ROOT / "scripts/playtest.luau")
    return path.read_text()


def output_path() -> pathlib.Path:
    args = sys.argv[1:]
    return pathlib.Path(args[1]) if len(args) >= 2 else (SIM / "gen_playtest.luau")


SCENARIO = scenario_text()
OUTFILE = output_path()

MODULES_SHARED = ["CropData", "Recipes", "TasLogic", "Layout", "DuniaLogic", "SoalLogic", "GudangLogic", "PukulLogic", "PanenStatus", "UIStyle", "PukulAnim", "ArahPukul", "KontrolHP", "HUDLayout", "DropBentuk"]
MODULES_SERVER = [
    "RateLimit",
    "DevCodeVault",
    "BuildingKit",
    "LandService",
    "DataService",
    "TasService",
    "SmashService",
    "PlantModels",
    "DropModels",
    "PlotService",
    "ShopService",
    "WorldBuilder",
    "ZonaService",
    "TanamService",
    "GudangService",
    "DropService",
]
LAZY_UI = "UIController"

BANNED_NAMES = [
    "toram", "growtopia", "minecraft", "roblox studio", "adopt me",
    "pet simulator", "brookhaven", "blox fruits", "robux",
]


def read(path: pathlib.Path) -> str:
    return path.read_text()


def strip_scenario_header(text: str) -> str:
    text = re.sub(r"local rawreq = require\n", "", text)
    text = re.sub(r"local Stub = rawreq\(\"./sim/roblox_stub\"\)\n", "", text)
    text = re.sub(r"Stub\.install\(\)\n", "", text)
    text = re.sub(r"require = function\(arg\).*?\nend\n", "", text, count=1, flags=re.DOTALL)
    return text


def map_require(match: re.Match) -> str:
    arg = match.group(1).strip()
    name = None
    m = re.search(r"ReplicatedStorage\.Shared\.(\w+)", arg)
    if m:
        name = m.group(1)
    if name is None and re.search(r"ReplicatedStorage\.Remotes\b", arg):
        name = "Remotes"
    if name is None:
        m = re.search(r"script\.Modules\.(\w+)", arg)
        if m:
            name = m.group(1)
    if name is None:
        m = re.search(r"script\.Parent\.(\w+)", arg)
        if m:
            name = m.group(1)
    if name is None:
        m = re.search(r"script:WaitForChild\(\"(\w+)\"\)", arg)
        if m:
            name = m.group(1)
    if name is None:
        m = re.search(r"^Modules\.(\w+)$", arg)
        if m:
            name = m.group(1)
    if name is None:
        m = re.search(r"script\.(\w+)", arg)
        if m:
            name = m.group(1)
    if name is None:
        raise SystemExit("require tidak dikenali: " + arg)
    if name == LAZY_UI:
        return "LOAD_UI()"
    return "MOD_" + name


def wrap_module(name: str, source: str, lazy: bool = False) -> str:
    source = re.sub(r"require\(([^()]*(?:\([^()]*\))?[^()]*)\)", map_require, source)
    if lazy:
        return (
            f"local MOD_{name} = nil\n"
            f"local function LOAD_{name}()\n"
            f"\tif not MOD_{name} then\n"
            f"\t\tMOD_{name} = (function()\n{source}\n\t\tend)()\n"
            f"\t\treturn MOD_{name}\n"
            f"\telse\n"
            f"\t\treturn MOD_{name}\n"
            f"\tend\n"
            f"end\n"
            f"local function LOAD_UI() return LOAD_{name}() end\n"
        )
    return f"local MOD_{name} = (function()\n{source}\nend)()\n"


def scan_banned(text: str, where: str) -> list:
    hits = []
    low = text.lower()
    for b in BANNED_NAMES:
        if b in low:
            hits.append(f"{where}: '{b}'")
    return hits


def main() -> None:
    parts = []
    parts.append("-- AUTO-GENERATED oleh scripts/sim/gen.py - jangan edit manual")
    stub_src = STUB.replace("\nreturn Stub\n", "\n")
    parts.append(stub_src)
    parts.append('Stub.install()')

    for name in MODULES_SHARED:
        parts.append(wrap_module(name, read(SRC / "Shared" / f"{name}.luau")))
    parts.append(wrap_module("Remotes", read(SRC / "Remotes" / "init.luau")))
    for name in MODULES_SERVER:
        parts.append(wrap_module(name, read(SRC / "Server" / "Modules" / f"{name}.luau")))
    parts.append(wrap_module(LAZY_UI, read(SRC / "Client" / f"{LAZY_UI}.luau"), lazy=True))

    server_init = re.sub(
        r"require\(([^()]*(?:\([^()]*\))?[^()]*)\)", map_require, read(SRC / "Server" / "init.server.luau")
    )
    parts.append("local function RUN_init_server()\n" + server_init + "\nend\n")
    client_init = re.sub(
        r"require\(([^()]*(?:\([^()]*\))?[^()]*)\)", map_require, read(SRC / "Client" / "init.client.luau")
    )
    parts.append("local function RUN_init_client()\n" + client_init + "\nend\n")

    scenario = strip_scenario_header(SCENARIO)
    scenario = scenario.replace("rawreq(\"./../download/dunia-akiomida/src/Server/init.server\")", "RUN_init_server()")
    scenario = scenario.replace("rawreq(\"./../download/dunia-akiomida/src/Client/init.client\")", "RUN_init_client()")
    scenario = scenario.replace("script = serverScript", "script = Stub.serverScript()")
    scenario = scenario.replace("script = Stub.clientScript()", "script = Stub.clientScript()")
    parts.append(scenario)

    out = "\n".join(parts)
    combined = out
    for b in BANNED_NAMES:
        if b in combined.lower():
            hits = scan_banned(combined, "generated")
            raise SystemExit("nama game lain terdeteksi: " + ", ".join(hits))
    OUTFILE.write_text(out)
    print("generated:", OUTFILE, len(out), "bytes")


if __name__ == "__main__":
    main()
