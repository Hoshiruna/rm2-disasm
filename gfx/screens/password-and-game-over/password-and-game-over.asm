        check_asset "password-and-game-over/shared-background.chr", $1000
        rom_bytes "GFX_08_8000", "password-and-game-over/shared-background.chr", $0000, $0400
        rom_bytes "GFX_08_8400", "password-and-game-over/shared-background.chr", $0600, $0400
        rom_bytes "GFX_09_9F00", "password-and-game-over/shared-background.chr", $0A00, $0100
        .if SharedChrFromMenus
                rom_bytes "GFX_09_A000", "password-and-game-over/shared-background.chr", $0B00, $0500
                rom_bytes "GFX_09_AC00", "password-and-game-over/shared-background.chr", $0400, $0200
        .endif

        check_asset "password-and-game-over/start-menu.nam", $0400
        check_asset "password-and-game-over/password-entry.nam", $0400
        check_asset "password-and-game-over/game-over.nam", $0400

; Set a byte count of $0400 for a full screen, or list smaller ranges.
        .segment "GFX_NAM"
start_menu:
        nam_region "password-and-game-over/start-menu.nam", $2400, $0000, $0000
        end_nam start_menu, StartMenuActive
password_entry:
        nam_region "password-and-game-over/password-entry.nam", $2000, $0000, $0000
        end_nam password_entry, PasswordActive
game_over:
        nam_region "password-and-game-over/game-over.nam", $2400, $0000, $0000
        end_nam game_over, GameOverActive

.if StartMenuActive
        .segment "GFX_HOOK_START_MENU"
        jsr apply_start_menu
        .segment "GFX_NAM"
apply_start_menu:
        apply_screen Screen::StartMenu
        jmp $A974
.endif

.if PasswordActive
        .segment "GFX_HOOK_PASSWORD"
        jsr apply_password_entry
        .segment "GFX_NAM"
apply_password_entry:
        jsr $A98E
        apply_screen Screen::PasswordEntry
        rts
.endif

.if GameOverActive
        .segment "GFX_HOOK_GAME_OVER"
        jsr apply_game_over
        .segment "GFX_NAM"
apply_game_over:
        apply_screen Screen::GameOver
        jmp $A896
.endif
