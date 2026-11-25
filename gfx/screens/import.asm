        .setcpu "6502"

; Shared ranges in PRG bank $09. The menu source takes precedence at $AC00.
SharedChrFromIntro = 0          ; $AA00-$AFFF uses intro.chr instead of title-screen.chr
SharedChrFromMenus = 0          ; $A000-$A4FF and $AC00-$ADFF use shared-background.chr

.enum Screen
        Opening1988
        OpeningCapcom
        Story1
        Story2
        Story3
        Story4
        StoryReset
        StartMenu
        PasswordEntry
        GameOver
        EndingWalk
        EndingHelmet
.endenum

.macro check_asset filename, length
        .local asset_start
        .pushseg
        .segment "GFX_INPUT_CHECK"
asset_start:
        .incbin filename
        .assert * - asset_start = length, error, .concat("Unexpected asset size: ", filename)
        .popseg
.endmacro

.macro rom_bytes segment_name, filename, file_offset, length
        .segment segment_name
        .incbin filename, file_offset, length
.endmacro

; Offsets $000-$3BF are tiles. Offsets $3C0-$3FF are attributes.
; The ROM stores only the listed ranges. A zero length disables a range.
.macro nam_region filename, ppu_base, file_offset, length
        .assert file_offset >= 0, error, "Negative NAM offset"
        .assert length >= 0, error, "Negative NAM length"
        .assert file_offset + length <= $0400, error, "NAM range exceeds the screen"
        .repeat length / $100, chunk
                .byte >(ppu_base + file_offset + chunk * $100)
                .byte <(ppu_base + file_offset + chunk * $100), $00
                .incbin filename, file_offset + chunk * $100, $100
        .endrepeat
        .if (length & $FF)
                .byte >(ppu_base + file_offset + (length & $FF00))
                .byte <(ppu_base + file_offset + (length & $FF00)), <(length)
                .incbin filename, file_offset + (length & $FF00), length & $FF
        .endif
.endmacro

.macro end_nam name, active
        active = * - name
        .if active
                .byte $00
        .endif
.endmacro

.macro nam_pointer name, active
        .if active
                .word name
        .else
                .word $0000
        .endif
.endmacro

.macro apply_screen screen
        php
        pha
        lda #screen * 2
        jsr apply_nam
        pla
        plp
.endmacro

        .segment "GFX_NAM"
nam_storage_start:
        .include "title/title.asm"
        .include "intro/intro.asm"
        .include "stage-select/stage-select.asm"
        .include "password-and-game-over/password-and-game-over.asm"
        .include "ending/ending.asm"
        .include "wily-map/wily-map.asm"

        .segment "GFX_NAM"
.if OpeningActive + StoryActive + StartMenuActive + PasswordActive + GameOverActive + EndingWalkActive + EndingHelmetActive

; A holds a table offset. Callers preserve A and status.
apply_nam:
        pha
        txa
        pha
        tya
        pha
        lda $08
        pha
        lda $09
        pha
        tsx
        lda $0105,x
        tax
        lda nam_streams+1,x
        beq restore_registers

        lda $F7
        and #$7B
        sta $2000
        lda #$00
        sta $2001
        tay
        lda nam_streams+1,x
        sta $09
        lda nam_streams,x
        sta $08
        jmp read_block

; Each block holds a PPU address, byte count, then tiles or attributes.
; A byte count of $00 copies 256 bytes. Address high $00 ends the stream.
write_block:
        bit $2002
        sta $2006
        jsr next_byte
        sta $2006
        jsr next_byte
        tax
copy_bytes:
        lda ($08),y
        sta $2007
        iny
        dex
        bne copy_bytes
        tya
        beq advance_page
        clc
        adc $08
        sta $08
        bcc reset_index
advance_page:
        inc $09
reset_index:
        ldy #$00
read_block:
        jsr next_byte
        bne write_block

; Restore the scroll offsets used by the stock NMI handler.
        bit $2002
        sec
        lda $1F
        sbc $B8
        sta $2005
        sec
        lda $22
        sbc $B6
        sta $2005
        lda $F8
        sta $2001
        lda $F7
        sta $2000
restore_registers:
        pla
        sta $09
        pla
        sta $08
        pla
        tay
        pla
        tax
        pla
        rts

next_byte:
        lda ($08),y
        inc $08
        bne :+
        inc $09
:       ora #$00
        rts

nam_streams:
        nam_pointer opening_1988, OpeningActive
        nam_pointer opening_capcom, OpeningCapcomActive
        nam_pointer story_1, StoryActive
        nam_pointer story_2, Story2Active
        nam_pointer story_3, Story3Active
        nam_pointer story_4, Story4Active
        nam_pointer story_reset, StoryResetActive
        nam_pointer start_menu, StartMenuActive
        nam_pointer password_entry, PasswordActive
        nam_pointer game_over, GameOverActive
        nam_pointer ending_walk, EndingWalkActive
        nam_pointer ending_helmet, EndingHelmetActive
.endif
        .assert * - nam_storage_start <= $065E, error, "NAM regions exceed the fixed-bank space"
