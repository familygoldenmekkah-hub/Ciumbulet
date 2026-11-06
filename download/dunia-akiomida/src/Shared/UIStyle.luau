local UIStyle = {}

UIStyle.Latar = { 23, 25, 30 }
UIStyle.Permukaan = { 32, 35, 42 }
UIStyle.PermukaanAktif = { 48, 54, 66 }
UIStyle.Teks = { 240, 241, 244 }
UIStyle.Abu = { 148, 154, 165 }
UIStyle.AbuGelap = { 96, 102, 112 }
UIStyle.Aksen = { 138, 158, 184 }
UIStyle.Hijau = { 62, 142, 90 }
UIStyle.Merah = { 178, 84, 72 }
UIStyle.Kuning = { 255, 214, 110 }

UIStyle.Font = "Gotham"
UIStyle.FontTebal = "GothamBold"
UIStyle.FontHitam = "GothamBlack"

UIStyle.UkuranJudul = 19
UIStyle.UkuranIsi = 15
UIStyle.UkuranKecil = 12

UIStyle.Sudut = 8
UIStyle.SudutKecil = 6
UIStyle.AmanAtas = 56
UIStyle.LebarPanelMaks = 640
UIStyle.TinggiPanelMaks = 480

UIStyle.NamaMaks = 18

function UIStyle.cekTigaUkuran(): boolean
        local n = 0
        for _, _ in pairs({ judul = UIStyle.UkuranJudul, isi = UIStyle.UkuranIsi, kecil = UIStyle.UkuranKecil }) do
                n += 1
        end
        return n == 3
end

function UIStyle.tabTampak(tab: string): { [string]: boolean }
        local penuh = {
                tanam = { daftarTanam = true, angka = true, mulai = true, gabung = false, status = false, soal = false },
                gabung = { daftarTanam = false, angka = false, mulai = false, gabung = true, status = false, soal = false },
                status = { daftarTanam = false, angka = false, mulai = false, gabung = false, status = true, soal = false },
        }
        local p = penuh[tab]
        if not p then
                return { daftarTanam = false, angka = false, mulai = false, gabung = false, status = false, soal = false }
        end
        return p
end

function UIStyle.tabTunggal(tab: string): boolean
        local t = UIStyle.tabTampak(tab)
        local n = 0
        if t.daftarTanam then
                n += 1
        end
        if t.gabung then
                n += 1
        end
        if t.status then
                n += 1
        end
        return n == 1 and t.daftarTanam == (t.angka and t.mulai)
end

function UIStyle.potong(nama: any, maks: number?): string
        if type(nama) ~= "string" then
                return "?"
        end
        local m = type(maks) == "number" and maks or UIStyle.NamaMaks
        if #nama <= m then
                return nama
        end
        return string.sub(nama, 1, m - 1) .. "…"
end

return UIStyle
