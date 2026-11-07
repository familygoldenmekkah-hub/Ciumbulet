#!/usr/bin/env python3
"""Diagnosa DataStore LIVE Dunia Akiomida via Open Cloud API.
Mencantumkan & membaca entri AKM_T1 (u_/l_) dan AKM_Dunia (d_)
untuk membuktikan akar bug 'keluar masuk = dari nol'.
Kredensial hanya dibaca dari .secrets, tidak pernah dicetak."""
import json, sys, urllib.request, urllib.error

KEY = ""
with open("/home/z/my-project/.secrets/akiomida.env") as f:
    for line in f:
        if line.startswith("ROBLOX_API_KEY="):
            KEY = line.split("=", 1)[1].strip()
UNI = 10774464946
BASE = f"https://apis.roblox.com/datastores/v1/universes/{UNI}"

def req(url):
    r = urllib.request.Request(url, headers={"x-api-key": KEY})
    try:
        with urllib.request.urlopen(r, timeout=30) as resp:
            return resp.status, json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()[:300]

def list_entries(store, prefix="", limit=20):
    url = f"{BASE}/datastores/{store}/entries?limit={limit}"
    if prefix:
        url += f"&prefix={prefix}"
    return req(url)

def get_entry(store, key):
    return req(f"{BASE}/datastores/{store}/entries/{key}")

st, data = list_entries("AKM_T1")
print("== AKM_T1 keys ==")
if st == 200:
    for e in data.get("entries", []):
        print(" ", e.get("name"))
else:
    print(" FAIL", st, data)

st, data = list_entries("AKM_Dunia")
print("== AKM_Dunia keys ==")
if st == 200:
    for e in data.get("entries", []):
        print(" ", e.get("name"))
else:
    print(" FAIL", st, data)

# Baca beberapa entri dunia utuh + beberapa entri user
st, data = list_entries("AKM_Dunia", limit=5)
if st == 200:
    for e in data.get("entries", []):
        name = e.get("name")
        s2, v = get_entry("AKM_Dunia", name)
        print(f"== AKM_Dunia/{name} (status {s2}) ==")
        if s2 == 200:
            val = v.get("value")
            print(json.dumps(val, indent=1)[:1200])
        else:
            print(" ", v)

st, data = list_entries("AKM_T1", prefix="u_", limit=5)
if st == 200:
    for e in data.get("entries", []):
        name = e.get("name")
        s2, v = get_entry("AKM_T1", name)
        print(f"== AKM_T1/{name} (status {s2}) ==")
        if s2 == 200:
            val = v.get("value")
            print(json.dumps(val, indent=1)[:900])
        else:
            print(" ", v)
