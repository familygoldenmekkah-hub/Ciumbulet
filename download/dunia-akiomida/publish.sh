#!/usr/bin/env bash
# publish.sh - versi curl dari publish.py
# Pemakaian:
#   ./publish.sh <API_KEY> <UNIVERSE_ID> <PLACE_ID> [file.rbxlx]
set -euo pipefail

API_KEY="${1:?Pemakaian: ./publish.sh <API_KEY> <UNIVERSE_ID> <PLACE_ID> [file]}"
UNIVERSE_ID="${2:?Universe ID wajib}"
PLACE_ID="${3:?Place ID wajib}"
FILE="${4:-build/CoinRushSimulator.rbxlx}"

[ -f "$FILE" ] || { echo "File tidak ada: $FILE - jalankan 'rojo build' dulu." >&2; exit 2; }

curl --fail-with-body --location --silent --show-error \
  --request POST \
  "https://apis.roblox.com/universes/v1/${UNIVERSE_ID}/places/${PLACE_ID}/versions?versionType=Published" \
  --header "x-api-key: ${API_KEY}" \
  --header "Content-Type: application/xml" \
  --data-binary "@${FILE}"

echo ""
echo "Kalau output berisi versionNumber berarti sukses - versi baru sudah live."
