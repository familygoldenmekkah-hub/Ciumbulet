#!/usr/bin/env bash
# CADANGAN GITHUB DUNIA AKIOMIDA
# Dipanggil di akhir SETIAP sesi update (wajib). Commit semua perubahan
# proyek dan push ke branch "dunia-akiomida" di github.com/familygoldenmekkah-hub/Ciumbulet (lokasi yang dipilih pemilik).
# Kredensial dibaca dari .secrets (tidak pernah dicetak/disimpan lain).
set -uo pipefail
set -a; source /home/z/my-project/.secrets/akiomida.env; set +a
set -a; source /home/z/my-project/.secrets/ciumbulet.env; set +a
REPO_DIR=/home/z/my-project/download/dunia-akiomida
BRANCH=dunia-akiomida
REMOTE=https://github.com/familygoldenmekkah-hub/Ciumbulet.git
VER=$(grep -oE 'versionNumber [0-9]+' "$REPO_DIR/README.md" | head -1 | grep -oE '[0-9]+$')
cd "$REPO_DIR" || exit 1
mkdir -p harness/sim
cp -f /home/z/my-project/scripts/playtest.luau /home/z/my-project/scripts/panen_massa.luau harness/ 2>/dev/null
cp -f /home/z/my-project/scripts/sim/gen.py /home/z/my-project/scripts/sim/roblox_stub.luau /home/z/my-project/scripts/sim/gen_playtest.luau /home/z/my-project/scripts/sim/gen_massa.luau harness/sim/ 2>/dev/null
git add -A
if ! git diff --cached --quiet; then
    git commit -m "v${VER:-?} — snapshot otomatis sesi update (riwayat lengkap: README.md tabel versi + RUBRIC.md skor)" | tail -1
fi
N=$(git rev-list --count origin/"${BRANCH}"..main 2>/dev/null || echo "?")
if git push "https://x-access-token:${GITHUB_TOKEN_CIUM}@github.com/familygoldenmekkah-hub/Ciumbulet.git" main:${BRANCH} 2>&1 | tail -2; then
    echo "[CADANGAN] Terpush: ${REMOTE} branch ${BRANCH} (v${VER:-?}, ${N} commit)"
else
    echo "[CADANGAN][PERINGATAN] Push gagal (mungkin history berubah). Cek manual."
fi
