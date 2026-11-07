# Harness pengujian (playtest + ujian massa)

Simulator Roblox-CLI untuk menguji game tanpa membuka Roblox Studio.

- `harness/sim/gen_*.luau` = file gabungan SIAP JALAN: `luau harness/sim/gen_playtest.luau` dan `luau harness/sim/gen_massa.luau` (butuh binary `luau` di ../tools).
- `harness/sim/gen.py` = generator: menambah modul src/ + skenario menjadi satu chunk (`python3 harness/sim/gen.py <skenario> <output>`; path ROOT disesuaikan untuk komputer lain).
- `harness/sim/roblox_stub.luau` = stub engine (Instance/Enum/Remote/Scheduler).
- `harness/playtest.luau` + `harness/panen_massa.luau` = skenario uji (dipakai gen.py).
- Alur resmi per versi: lihat README.md bagian "Sesi update mandiri".