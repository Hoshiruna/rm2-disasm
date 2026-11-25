        check_asset "intro/intro.chr", $1000
        .if SharedChrFromMenus = 0
                rom_bytes "GFX_09_A000", "intro/intro.chr", $0000, $0500
        .endif
        rom_bytes "GFX_09_A500", "intro/intro.chr", $0500, $0500
        .if SharedChrFromIntro
                rom_bytes "GFX_09_AA00", "intro/intro.chr", $0A00, $0200
                rom_bytes "GFX_09_AE00", "intro/intro.chr", $0E00, $0200
                .if SharedChrFromMenus = 0
                        rom_bytes "GFX_09_AC00", "intro/intro.chr", $0C00, $0200
                .endif
        .endif

        check_asset "intro/opening-1988.nam", $0400
        check_asset "intro/opening-capcom.nam", $0400
        check_asset "intro/story-01.nam", $0400
        check_asset "intro/story-02.nam", $0400
        check_asset "intro/story-03.nam", $0400
        check_asset "intro/story-04.nam", $0400

; The original loaders read six tiles per opening card and two 21-tile story lines.
        .segment "GFX_OPENING_TEXT"
        .incbin "intro/opening-1988.nam", $01CD, 6
        .incbin "intro/opening-capcom.nam", $01CD, 6

.macro story_lines filename
        .incbin filename, $0306, 21
        .incbin filename, $0346, 21
.endmacro

        .segment "GFX_STORY_TEXT"
        story_lines "intro/story-01.nam"
        story_lines "intro/story-02.nam"
        story_lines "intro/story-03.nam"
        story_lines "intro/story-04.nam"

; For edits outside the text areas, list the same extra ranges for each card.
; Each declaration takes a PPU base, a NAM offset, and a byte count.
.macro opening_regions filename
        nam_region filename, $2000, $0000, $0000
.endmacro

.macro story_regions filename
        nam_region filename, $2000, $0000, $0000
.endmacro

        .segment "GFX_NAM"
opening_1988:
        opening_regions "intro/opening-1988.nam"
        end_nam opening_1988, OpeningActive
opening_capcom:
        opening_regions "intro/opening-capcom.nam"
        end_nam opening_capcom, OpeningCapcomActive
story_1:
        story_regions "intro/story-01.nam"
        end_nam story_1, StoryActive
story_2:
        story_regions "intro/story-02.nam"
        end_nam story_2, Story2Active
story_3:
        story_regions "intro/story-03.nam"
        end_nam story_3, Story3Active
story_4:
        story_regions "intro/story-04.nam"
        end_nam story_4, Story4Active
story_reset:
        story_regions "intro/stock-story-04.bin"
        end_nam story_reset, StoryResetActive

.if OpeningActive
        .segment "GFX_HOOK_OPENING"
        jsr apply_opening

        .segment "GFX_NAM"
apply_opening:
        jsr $C0AB
        php
        pha
        lda $FE
        cmp #$12
        bne opening_done
        lda $FF
        cmp #$08
        bne opening_done
        lda $FD
        beq opening_second
        lda #Screen::Opening1988 * 2
        jmp opening_write
opening_second:
        lda #Screen::OpeningCapcom * 2
opening_write:
        jsr apply_nam
opening_done:
        pla
        plp
        rts
.endif

.if StoryActive
        .segment "GFX_HOOK_STORY"
        jsr apply_story
        .segment "GFX_HOOK_STORY_EXIT"
        jsr restore_story
        nop

        .segment "GFX_NAM"
apply_story:
        jsr $C0AB
        php
        pha
        lda $FE
        cmp #$26
        bne story_done
        lda $FF
        cmp #$09
        bne story_done
        lda $FD
        cmp #$2A
        beq story_first
        cmp #$54
        beq story_second
        cmp #$7E
        beq story_third
        cmp #$A8
        bne story_done
        lda #Screen::Story4 * 2
        jmp story_write
story_first:
        lda #Screen::Story1 * 2
        jmp story_write
story_second:
        lda #Screen::Story2 * 2
        jmp story_write
story_third:
        lda #Screen::Story3 * 2
story_write:
        jsr apply_nam
story_done:
        pla
        plp
        rts

restore_story:
        lda $FD
        cmp #$A8
        bne :+
        apply_screen Screen::StoryReset
:       rts
.endif
