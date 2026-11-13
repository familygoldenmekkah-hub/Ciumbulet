#!/usr/bin/env python3
"""Perbarui sumber skrip Luau yang tersemat di miodakali.rbxlx."""
import html
import re
import sys

RBXLX = '/home/z/my-project/roblox/miodakali.rbxlx'
LUAU_DIR = '/home/z/my-project/roblox/luau'
PASANGAN = {
    'KonfigurasiMiodakali': f'{LUAU_DIR}/KonfigurasiMiodakali.lua',
    'MiodakaliUtama': f'{LUAU_DIR}/MiodakaliUtama.server.lua',
    'KiosKlien': f'{LUAU_DIR}/KiosGui.client.lua',
}

xml = open(RBXLX, encoding='utf-8').read()

for nama, jalur in PASANGAN.items():
    sumber = open(jalur, encoding='utf-8').read()
    terX = html.escape(sumber, quote=False)
    # temukan blok Item milik skrip ini lalu ganti ProtectedString Source-nya
    pola = re.compile(
        r'(<Item class="(?:Script|LocalScript|ModuleScript)"[^>]*>\s*<Properties>\s*<string name="Name">'
        + re.escape(nama)
        + r'</string>.*?<ProtectedString name="Source">)(.*?)(</ProtectedString>)',
        re.S,
    )
    cocok = pola.search(xml)
    if not cocok:
        print(f'GAGAL: skrip {nama} tidak ditemukan')
        sys.exit(1)
    xml = xml[: cocok.start(2)] + terX + xml[cocok.end(2):]
    print(f'OK: {nama} -> {len(terX)} karakter')

open(RBXLX, 'w', encoding='utf-8').write(xml)
print('rbxlx diperbarui')
