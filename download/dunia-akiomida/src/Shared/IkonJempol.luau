local IkonJempol = {}

IkonJempol.Bagian = {
        { dx = 0.14, dy = 0.34, dw = 0.52, dh = 0.48, bentuk = "kotak" },
        { dx = 0.14, dy = 0.22, dw = 0.13, dh = 0.20, bentuk = "lingkaran" },
        { dx = 0.30, dy = 0.16, dw = 0.13, dh = 0.20, bentuk = "lingkaran" },
        { dx = 0.46, dy = 0.18, dw = 0.13, dh = 0.20, bentuk = "lingkaran" },
        { dx = 0.60, dy = 0.26, dw = 0.12, dh = 0.18, bentuk = "lingkaran" },
        { dx = 0.02, dy = 0.44, dw = 0.16, dh = 0.34, bentuk = "kotak" },
        { dx = 0.20, dy = 0.40, dw = 0.40, dh = 0.05, bentuk = "garis" },
        { dx = 0.20, dy = 0.52, dw = 0.40, dh = 0.05, bentuk = "garis" },
        { dx = 0.20, dy = 0.64, dw = 0.40, dh = 0.05, bentuk = "garis" },
}

function IkonJempol.bagian(): { any }
        local out = {}
        for _, g in ipairs(IkonJempol.Bagian) do
                table.insert(out, { dx = g.dx, dy = g.dy, dw = g.dw, dh = g.dh, bentuk = g.bentuk })
        end
        return out
end

function IkonJempol.valid(): boolean
        for _, g in ipairs(IkonJempol.Bagian) do
                if g.dx < 0 or g.dy < 0 or g.dx + g.dw > 1 or g.dy + g.dh > 1 then
                        return false
                end
                if g.dw <= 0 or g.dh <= 0 then
                        return false
                end
        end
        return #IkonJempol.Bagian >= 4
end

return IkonJempol
