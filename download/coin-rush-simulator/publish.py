#!/usr/bin/env python3
"""
publish.py - Publish build/CoinRushSimulator.rbxlx ke Roblox lewat Open Cloud.

Tanpa dependency eksternal (pakai stdlib Python 3).

Pemakaian:
    python3 publish.py --api-key XXXX --universe-id 1234567890 --place-id 9876543210

    atau pakai environment variable:
    ROBLOX_API_KEY=xxxx python3 publish.py --universe-id 123 --place-id 456

Opsi:
    --file           path file place (default: build/CoinRushSimulator.rbxlx)
    --version-type   Published (rilis ke publik) atau Save (simpan draft saja,
                     butuh izin tambahan; default: Published)
"""

import argparse
import os
import pathlib
import sys
import urllib.error
import urllib.request

API_URL = "https://apis.roblox.com/universes/v1/{universe_id}/places/{place_id}/versions"


def human_error(status: int, body: str) -> str:
    hints = {
        400: "Body file kemungkinan tidak valid. Pastikan file .rbxlx berasal dari 'rojo build' terbaru.",
        401: "API key tidak valid / sudah kedaluwarsa. Buat ulang di create.roblox.com/credentials.",
        403: (
            "Akses ditolak. Cek: (1) API key punya permission 'universe-places: Write' "
            "untuk experience ini, (2) IP address kamu di-whitelist di pengaturan key "
            "(atau hapus IP restriction), (3) 'Studio Access to API Services' aktif di "
            "Game Settings experience."
        ),
        404: "Universe/Place ID salah. ID ada di URL Creator Dashboard saat membuka experience.",
        409: "Konflik versi - coba lagi beberapa detik.",
        429: "Rate limit Roblox. Tunggu 1-2 menit lalu coba lagi.",
        413: "File terlalu besar (limit 100 MB).",
    }
    hint = hints.get(status, "")
    return f"HTTP {status}: {body}\n{hint}" if hint else f"HTTP {status}: {body}"


def main() -> int:
    parser = argparse.ArgumentParser(description="Publish place file ke Roblox via Open Cloud")
    parser.add_argument("--api-key", default=os.environ.get("ROBLOX_API_KEY", ""),
                        help="Open Cloud API key (atau env ROBLOX_API_KEY)")
    parser.add_argument("--universe-id", required=True, type=int, help="Universe (experience) ID")
    parser.add_argument("--place-id", required=True, type=int, help="Place ID")
    parser.add_argument("--file", default="build/CoinRushSimulator.rbxlx", help="Path file place")
    parser.add_argument("--version-type", default="Published", choices=["Published", "Save"])
    args = parser.parse_args()

    if not args.api_key:
        print("ERROR: API key belum diisi. Pakai --api-key atau env ROBLOX_API_KEY.", file=sys.stderr)
        return 2

    path = pathlib.Path(args.file)
    if not path.exists():
        print(f"ERROR: File tidak ditemukan: {path}\nJalankan dulu: rojo build --output build/CoinRushSimulator.rbxlx .",
              file=sys.stderr)
        return 2

    body = path.read_bytes()
    print(f"Mengunggah {path} ({len(body):,} bytes) -> universe {args.universe_id}, place {args.place_id} "
          f"[{args.version_type}] ...")

    url = API_URL.format(universe_id=args.universe_id, place_id=args.place_id) + f"?versionType={args.version_type}"
    req = urllib.request.Request(
        url,
        data=body,
        method="POST",
        headers={
            "x-api-key": args.api_key,
            "Content-Type": "application/xml",  # .rbxlx = XML; pakai application/octet-stream untuk .rbxl
        },
    )

    try:
        with urllib.request.urlopen(req, timeout=300) as resp:
            payload = resp.read().decode("utf-8", "replace")
            print(f"SUKSES ({resp.status}): {payload}")
            print("Versi baru sudah live! Cek di Roblox app / Creator Dashboard.")
            return 0
    except urllib.error.HTTPError as e:
        body_text = e.read().decode("utf-8", "replace")
        print(f"GAGAL: {human_error(e.code, body_text)}", file=sys.stderr)
        return 1
    except urllib.error.URLError as e:
        print(f"GAGAL (jaringan): {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
