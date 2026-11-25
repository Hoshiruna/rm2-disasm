        check_asset "stage-select/stage-select-screen.chr", $1000
        rom_bytes "GFX_08_8800", "stage-select/stage-select-screen.chr", $0000, $1000

        check_asset "stage-select/portraits/stage-select-portraits.chr", $02F0
        rom_bytes "GFX_05_9000", "stage-select/portraits/stage-select-portraits.chr", $0000, $02F0

; The game already loads this full raw NAM from bank $0B.
        check_asset "stage-select/stage-select-screen.nam", $0400
        rom_bytes "GFX_STAGE_SELECT_NAM", "stage-select/stage-select-screen.nam", $0000, $0400
