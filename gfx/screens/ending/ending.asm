        check_asset "ending/ending-background.chr", $1000
        rom_bytes "GFX_08_A400", "ending/ending-background.chr", $0000, $0C00
        rom_bytes "GFX_07_B200", "ending/ending-background.chr", $0C00, $0200
; The final two CHR pages are loaded by Wily 6.
        rom_bytes "GFX_02_B600", "ending/ending-background.chr", $0E00, $0200

        check_asset "ending/sprites/ending-sprites.chr", $1000
        rom_bytes "GFX_03_9900", "ending/sprites/ending-sprites.chr", $0000, $0200
        rom_bytes "GFX_03_9C00", "ending/sprites/ending-sprites.chr", $0200, $0100
        rom_bytes "GFX_04_9D00", "ending/sprites/ending-sprites.chr", $0300, $0100
        rom_bytes "GFX_04_9B00", "ending/sprites/ending-sprites.chr", $0400, $0100
        rom_bytes "GFX_06_B200", "ending/sprites/ending-sprites.chr", $0500, $0200
        rom_bytes "GFX_04_9700", "ending/sprites/ending-sprites.chr", $0700, $0100
        rom_bytes "GFX_05_9300", "ending/sprites/ending-sprites.chr", $0800, $0100
        rom_bytes "GFX_05_9600", "ending/sprites/ending-sprites.chr", $0900, $0200
        rom_bytes "GFX_05_9C00", "ending/sprites/ending-sprites.chr", $0B00, $0100
        rom_bytes "GFX_07_9D00", "ending/sprites/ending-sprites.chr", $0C00, $0100
        rom_bytes "GFX_07_9F00", "ending/sprites/ending-sprites.chr", $0D00, $0100
        rom_bytes "GFX_02_9500", "ending/sprites/ending-sprites.chr", $0E00, $0200

        check_asset "ending/ending-walk.nam", $0400
        check_asset "ending/ending-helmet.nam", $0400

; Both pages are available after the original metatile loader.
; A byte count of zero uses the original layout for that page.
        .segment "GFX_NAM"
ending_walk:
        nam_region "ending/ending-walk.nam", $2400, $0000, $0000
        end_nam ending_walk, EndingWalkActive
ending_helmet:
        nam_region "ending/ending-helmet.nam", $2000, $0000, $0000
        end_nam ending_helmet, EndingHelmetActive

.if EndingWalkActive + EndingHelmetActive
        .segment "GFX_HOOK_ENDING"
        jsr apply_ending
        .segment "GFX_NAM"
apply_ending:
        jsr $A840
        .if EndingWalkActive
                apply_screen Screen::EndingWalk
        .endif
        .if EndingHelmetActive
                apply_screen Screen::EndingHelmet
        .endif
        rts
.endif
