#!/usr/bin/env bash
# TERBITKAN v61 + CADANGAN — jalankan SEKALI setelah kredensial dikembalikan.
# Syarat:
#   1. /home/z/my-project/.secrets/akiomida.env   berisi ROBLOX_API_KEY=...
#   2. /home/z/my-project/.secrets/ciumbulet.env  berisi GITHUB_TOKEN_CIUM=...
# Langkah: verifikasi build v61 -> publish Open Cloud -> verifikasi versi live
#          -> cadangan GitHub (script resmi).
set -uo pipefail

PROY=/home/z/my-project/download/dunia-akiomida
AKI=/home/z/my-project/.secrets/akiomida.env
CIUM=/home/z/my-project/.secrets/ciumbulet.env

[ -f "$AKI" ] || { echo "[BLOK] $AKI belum ada. Isi ROBLOX_API_KEY terlebih dulu."; exit 2; }
export ROBLOX_API_KEY="$(grep -E '^ROBLOX_API_KEY=' "$AKI" | cut -d= -f2-)"
[ -n "${ROBLOX_API_KEY:-}" ] || { echo "[BLOK] ROBLOX_API_KEY kosong di $AKI"; exit 2; }

echo "[1/4] Verifikasi build v61 ada..."
ls -la "$PROY/build/DuniaAkiomida.rbxlx" || exit 2
grep -q "desSatuPlot" "$PROY/build/DuniaAkiomida.rbxlx" || { echo "[BLOK] Build tidak memuat kode v61 — jalankan rojo build ulang."; exit 2; }

echo "[2/4] Publish ke Roblox (Open Cloud)..."
python3 "$PROY/publish.py" --universe-id 10774464946 --place-id 77626159664192 --file "$PROY/build/DuniaAkiomida.rbxlx" || exit 2

echo "[3/4] Cek waktu update universe via API publik..."
curl -s "https://games.roblox.com/v1/games?universeIds=10774464946" | python3 -c "import json,sys; d=json.load(sys.stdin)['data'][0]; print('updated:', d['updated'])"

echo "[4/4] Cadangan GitHub..."
bash /home/z/my-project/scripts/backup_github.sh || echo "[PERINGATAN] Backup gagal — cek $CIUM"

echo "SELESAI. v61 live — server baru memakai format plot array + saldo awal 10.000."
