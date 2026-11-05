#!/usr/bin/env python3
"""Patch UIController.luau part 2: inventory sections, remotes, tips, help, new panels."""

PATH = "/home/z/my-project/download/dunia-akiomida/src/Client/UIController.luau"
src = open(PATH).read()

def rep(old, new, count=1):
    global src
    assert src.count(old) == count, f"MATCH FAIL ({src.count(old)} != {count}): {old[:90]!r}"
    src = src.replace(old, new)

# ---------------------------------------------------------------- 1. renderInv: tambah peralatan & konsumsi
rep("""        local sections = {
                { title = "BIBIT", data = s.Seeds, lookup = Config.Crops, kind = "seed" },
                { title = "HASIL PANEN", data = s.Crops, lookup = Config.Crops, kind = "crop" },
                { title = "SUMBER DAYA", data = s.Bag, lookup = Config.Resources, kind = "bag" },
                { title = "IKAN", data = s.Fish, lookup = Config.Fish, kind = "fish" },
        }""",
"""        local sections = {
                { title = "BIBIT", data = s.Seeds, lookup = Config.Crops, kind = "seed" },
                { title = "HASIL PANEN", data = s.Crops, lookup = Config.Crops, kind = "crop" },
                { title = "SUMBER DAYA", data = s.Bag, lookup = Config.Resources, kind = "bag" },
                { title = "IKAN", data = s.Fish, lookup = Config.Fish, kind = "fish" },
        }

        -- peralatan tempaan (v3): pakai cepat dari tas
        for _, eq in ipairs(Balance.Equipment) do
                local count = s.Equips[eq.id] or 0
                if count > 0 then
                        local equipped = s.Equipped[eq.kind] == eq.id
                        local statText = eq.kind == "weapon" and ("ATK +" .. eq.atk) or ("DEF +" .. eq.def)
                        invRow(eq.name .. " x" .. count .. (equipped and "  [TERPAKAI]" or ""),
                                statText .. " - Lv " .. eq.level .. " | " .. (eq.desc or "Peralatan tempaan"),
                                Color3.fromRGB(eq.color[1], eq.color[2], eq.color[3]),
                                equipped and "Lepas" or "Pakai",
                                function()
                                        local res = Remotes.get("Equip"):InvokeServer(eq.kind, equipped and "" or eq.id)
                                        self:handleResult(res)
                                        self:renderInv()
                                end)
                end
        end

        -- makanan & ramuan (v3): makan langsung
        for _, u in ipairs(Balance.Usables) do
                local count = s.Usables[u.id] or 0
                if count > 0 then
                        invRow(u.name .. " x" .. count, u.desc .. " - jual @" .. self:clientPrice(u.sell, u.id) .. " koin",
                                Color3.fromRGB(u.color[1], u.color[2], u.color[3]),
                                "Makan",
                                function()
                                        local res = Remotes.get("UseItem"):InvokeServer(u.id)
                                        self:handleResult(res)
                                        self:renderInv()
                                end)
                end
        end""")

# ---------------------------------------------------------------- 2. TIPS baru
rep("""local TIPS = {
        "Klaim ladang GRATIS di Kawasan Ladang (Utara), lalu tanami bibit!",
        "Jual hasil panen ke Bu Laris di Pasar Pengepul - harga pasar berubah tiap 10 menit!",
        "Tebang pohon di Hutan Kayu untuk Kayu, dan tambang bijih di Tambang Selatan.",
        "Kucing Koin memberi +10% harga jual. Lihat Toko Peliharaan!",
        "Crops tumbuh nyata waktu - tanam lalu jelajahi dunia sambil menunggu.",
        "Pakai Kaleng Siram supaya tanaman tumbuh 25% lebih cepat.",
        "Bonus login harian 100 koin. Datang lagi besok!",
        "Kuis Kak Pintar di alun-alun memberi koin bonus - sepenuhnya opsional.",
}""",
"""local TIPS = {
        "Klaim ladang GRATIS di Kawasan Ladang (Utara), lalu tanami bibit!",
        "Jual hasil panen ke Bu Laris di Pasar Pengepul - harga pasar berubah tiap 10 menit!",
        "Tempa balok besi dari bijih di PAK TEMPA, lalu buat Pedang Besi & Zirah!",
        "Serang Gelatin Hijau di Padang Timur untuk Gelatin - bahan Zirah Kulit!",
        "BOSS RAID: Raja Golem muncul di Arena Timur - serang bersama semua pemain!",
        "Naik level dapat 2 poin stat - buka panel Kar dan bagikan ke STR/VIT/AGI!",
        "Makan Roti Aktif dari Bu Masak untuk lari lebih cepat 12%!",
        "Dagang aman antar pemain: tombol Dagang, dekati partner, undang & SIAP!",
        "Papan Tugas Harian di alun-alun memberi koin & XP besar - ambil tiap hari!",
        "Kucing Koin memberi +10% harga jual. Lihat Toko Peliharaan!",
        "Bonus login harian 100 koin. Datang lagi besok!",
        "Kuis Kak Pintar di alun-alun memberi koin bonus - sepenuhnya opsional.",
}""")

# ---------------------------------------------------------------- 3. Help text
rep("""                Text = table.concat({
                        "1. KLAIM LADANG (utara): dekati papan Ladang, tekan Ambil Alih. Gratis!",
                        "2. BELI BIBIT (Pasar Timur): Kak Tani menjual bibit wortel s/d melon bintang.",
                        "3. TANAM: dekati petak tanah coklat, tekan E, pilih bibit.",
                        "4. TUMBUH NYATA WAKTU: tanaman tumbuh saat kamu menjelajah. Siram dengan Kaleng Siram untuk +25% kecepatan.",
                        "5. PANEN: petak bercahaya = siap. Tekan E untuk panen.",
                        "6. JUAL: Bu Laris di Pasar Pengepul. Harga pasar naik-turun tiap 10 menit - jual saat permintaan tinggi!",
                        "7. KUMPUL: tebang pohon di Hutan Kayu, tambang batu/besi/kristal di Tambang Selatan (perlu Belik), mancing di Danau Tenang (perlu Pancing).",
                        "8. KAYA: beli peliharaan (bonus jual), Sepeda Angin (lari cepat), upgrade belik.",
                        "9. LEVEL: semua aktivitas memberi XP. Level tinggi membuka bibit mahal.",
                        "10. KUIS Kak Pintar opsional: +20 koin per jawaban benar. Diabaikan juga tidak apa-apa.",
                }, "\\n"),""",
"""                Text = table.concat({
                        "1. KUMPUL: tanam & panen (Ladang Utara), tebang pohon (Hutan), tambang bijih (Tambang, perlu Belik), mancing (Danau, perlu Pancing).",
                        "2. JUAL: Bu Laris di Pasar Pengepul - harga naik-turun tiap 10 menit, jual saat permintaan tinggi!",
                        "3. KOMBAT: dekati monster (Gelatin/Serigala/Golem) lalu tekan E untuk menyerang. Monster membalas - makan ramuan bila HP tipis!",
                        "4. TEMPAA: kumpulkan bahan, buat Balok Besi di PAK TEMPA, lalu tempa Pedang & Zirah. Pakai di panel Kar.",
                        "5. STAT: tiap naik level = 2 poin. Panel Kar: STR (serangan), VIT (HP), AGI (lari), INT (ramuan), DEX (kritikal).",
                        "6. MASAK: Bu Masak menjual resep - Roti Aktif (lari cepat), Sate Ikan & Ramuan (pulihkan HP).",
                        "7. BOSS: Raja Golem muncul di Arena Timur tiap ±15 menit. Serang bersama - hadiah sesuai kontribusi, teratas dapat bonus besar!",
                        "8. TUGAS: Papan Tugas di alun-alun - rotasi harian, hadiah koin+XP besar.",
                        "9. DAGANG: tombol Dagang, dekati pemain lain, undang, tawar barang/koin, keduanya SIAP -> tukar aman.",
                        "10. LEVEL membuka bibit mahal & resep tempaa. Semua aktivitas memberi XP!",
                        "11. KUIS Kak Pintar opsional: +20 koin per jawaban benar. Diabaikan juga tidak apa-apa.",
                }, "\\n"),""")

# ---------------------------------------------------------------- 4. wireRemotes: tambahan event v3
rep("""        Remotes.get("OpenQuiz").OnClientEvent:Connect(function()
                self:showPanel("Quiz")
                self:requestQuiz()
        end)

        -- minta state awal (fallback kalau StateSync pertama terlewat)""",
"""        Remotes.get("OpenQuiz").OnClientEvent:Connect(function()
                self:showPanel("Quiz")
                self:requestQuiz()
        end)

        ---------------------------------------------------------------- v3
        Remotes.get("OpenCraft").OnClientEvent:Connect(function(station)
                self.craftStation = station
                self:renderCraft()
                self:showPanel("Craft")
        end)

        Remotes.get("OpenQuest").OnClientEvent:Connect(function()
                self:renderQuest()
                self:showPanel("Quest")
        end)

        Remotes.get("OpenChar").OnClientEvent:Connect(function()
                self:renderChar()
                self:showPanel("Char")
        end)

        Remotes.get("OpenTrade").OnClientEvent:Connect(function()
                self:renderTrade()
                self:showPanel("Trade")
        end)

        Remotes.get("BossState").OnClientEvent:Connect(function(info)
                if info.active then
                        self.bossBar.Visible = true
                        self.bossTitle.Text = info.name .. " - " .. (info.zone or "Arena")
                        self.bossHp.Size = UDim2.fromScale(math.clamp((info.hp or 1) / (info.maxHp or 1), 0.02, 1), 1)
                else
                        self.bossBar.Visible = false
                        if info.killed then
                                self:toast("BOSS DIKALAHKAN!", info.name .. " tumbang berkat kerja sama tim!", T.Red)
                                makeSound(1.4):Play()
                        end
                end
        end)

        Remotes.get("TradeSync").OnClientEvent:Connect(function(snap)
                if snap.inviteFrom then
                        self.inviteFrom = snap.inviteFrom
                        if self.activePanel == "Trade" then
                                self:renderTrade()
                        end
                        return
                end
                self.inviteFrom = nil
                self.tradeSnap = snap
                if self.activePanel == "Trade" then
                        self:renderTrade()
                end
        end)

        -- detak HP: ikat humanoid lokal
        task.spawn(function()
                local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if not humanoid then
                        humanoid = player.CharacterAdded:Wait():FindFirstChildOfClass("Humanoid")
                end
                local function refreshHp()
                        if self.hpText and self.hpBar then
                                self.hpText.Text = "HP " .. math.ceil(humanoid.Health) .. "/" .. math.ceil(humanoid.MaxHealth)
                                self.hpBar.Size = UDim2.fromScale(math.clamp(humanoid.Health / math.max(1, humanoid.MaxHealth), 0.02, 1), 1)
                        end
                end
                humanoid.HealthChanged:Connect(refreshHp)
                humanoid.Changed:Connect(function(prop)
                        if prop == "MaxHealth" or prop == "Health" then
                                refreshHp()
                        end
                end)
                refreshHp()
        end)

        -- minta state awal (fallback kalau StateSync pertama terlewat)""")

open(PATH, "w").write(src)
print("patch part 2 OK")
