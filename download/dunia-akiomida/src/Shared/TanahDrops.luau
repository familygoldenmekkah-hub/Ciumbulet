local TanahDrops = {}

TanahDrops.SELISIH_TENGGELAM = 0.05
TanahDrops.DUDUK_DIATAS = 0.08
TanahDrops.TIDUR_CEWAH = 2
TanahDrops.TIDUR_MAKS = 2.5

function TanahDrops.bagianBawah(rootY: number, setengah: number): number
        return rootY - setengah
end

function TanahDrops.tenggelam(rootBottomY: number, groundY: number): boolean
        return rootBottomY < groundY - TanahDrops.SELISIH_TENGGELAM
end

function TanahDrops.istirahatY(groundY: number, setengah: number): number
        return groundY + setengah + TanahDrops.DUDUK_DIATAS
end

function TanahDrops.harusTidur(settleTicks: number, umur: number): boolean
        return settleTicks >= TanahDrops.TIDUR_CEWAH or umur > TanahDrops.TIDUR_MAKS
end

function TanahDrops.perluNaik(rootBottomY: number, groundY: number, setengah: number): boolean
        return TanahDrops.tenggelam(rootBottomY, groundY) or rootBottomY < groundY
end

return TanahDrops
