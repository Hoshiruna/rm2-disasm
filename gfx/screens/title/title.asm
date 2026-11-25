        check_asset "title/title-screen.chr", $1000
        rom_bytes "GFX_09_B000", "title/title-screen.chr", $0000, $0A00
        .if SharedChrFromIntro = 0
                rom_bytes "GFX_09_AA00", "title/title-screen.chr", $0A00, $0200
                rom_bytes "GFX_09_AE00", "title/title-screen.chr", $0E00, $0200
                .if SharedChrFromMenus = 0
                        rom_bytes "GFX_09_AC00", "title/title-screen.chr", $0C00, $0200
                .endif
        .endif

; NEXXT shows these eleven Rockman tiles in pose order.
        check_asset "title/title-rockman.chr", $00B0
        rom_bytes "GFX_06_9090", "title/title-rockman.chr", $0000, $0030
        rom_bytes "GFX_06_9030", "title/title-rockman.chr", $0030, $0030
        rom_bytes "GFX_06_91F0", "title/title-rockman.chr", $0060, $0020
        rom_bytes "GFX_06_9060", "title/title-rockman.chr", $0080, $0030

        check_asset "title/title-screen.nam", $0400
        .segment "GFX_TITLE_NAM"
; Bank $0D stores title rows from bottom to top and reverses the attributes.
        .repeat 64, index
                .incbin "title/title-screen.nam", $03FF - index, 1
        .endrepeat
        .repeat 30, row
                .incbin "title/title-screen.nam", (29 - row) * 32, 32
        .endrepeat
