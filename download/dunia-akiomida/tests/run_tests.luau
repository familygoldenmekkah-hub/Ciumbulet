local passed, failed = 0, 0
local function check(name: string, ok: boolean, detail: string?)
        if ok then
                passed += 1
                print("  PASS  " .. name)
        else
                failed += 1
                print("  FAIL  " .. name .. (detail and ("  -> " .. detail) or ""))
        end
end

print("=== TES DUNIA AKIOMIDA - DARI NOL ===")

print("--- Vault kode dev ---")
do
        local vault = require("./../src/Server/Modules/DevCodeVault")
        check("DevCodeVault termuat sebagai tabel", type(vault) == "table", "-")
        check("Kode dev tersimpan sebagai teks tak kosong", type(vault.CODE) == "string" and #vault.CODE > 0, "-")
        check("Kode dev tanpa spasi", type(vault.CODE) == "string" and string.find(vault.CODE, " ", 1, true) == nil, "-")
end

print(("="):rep(28))
print(string.format("HASIL: %d PASS, %d FAIL", passed, failed))
if failed > 0 then
        error(string.format("%d tes gagal", failed))
end
