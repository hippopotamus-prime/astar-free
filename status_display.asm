    ;---- Calculate pointers to digit graphics ----
    ;input:  a = bcd number
    ;        x = digit gfx ptrs storage location (4 bytes)
    ;outputs: digit gfx ptrs are written (msb first)
    ;destroys: a, y, scratch11
calculate_digit_ptrs: subroutine
    tay
    and #%00001111
    asl
    sta scratch11
    asl
    asl
    adc scratch11
    adc #<digit_gfx
    sta 2,x

    tya
    and #%11110000
    lsr
    sta scratch11
    lsr
    lsr
    adc scratch11
    adc #<digit_gfx
    sta 0,x

    lda #>digit_gfx
    sta 3,x
    sta 1,x

    rts




    ;---- Draw the status bar at the bottom of the screen ----
    ;input:  moves, current_object set
    ;output:  draws graphics
    ;destroys: a, x, y, scratch0-10
show_status: subroutine
    tsx
    stx scratch10

    ;Darken the display if we've gone over
    ;the par number of moves

    ldx #(PLAYER_COLU & $f0) + 2

    jsr compare_par
    bcc .over_par
        ldx #PLAYER_COLU
.over_par:

    stx COLUP1
    stx COLUP0

    ;Set up the graphic pointers...

    lda moves
    ldx #scratch4
    jsr calculate_digit_ptrs

    lda moves+1
    ldx #scratch0
    jsr calculate_digit_ptrs

    ldx current_object
    lda icon_msbs,x
    sta scratch9
    lda icon_lsbs,x
    sta scratch8

    ;Now get the graphics positioned properly...

    ldx #1
    stx REFP0
    stx NUSIZ0

    dex
    lda #PLAYER_X_OFFSET + 11
    jsr position_player
    sta WSYNC
    sta HMOVE

    lda #3
    sta NUSIZ1

    ldy #10
.loop:
    ;23.2   29.0    34.1
    ;           31.2    37.0

    sta.w GRP0              ;3 = 62
    stx GRP1                ;3
    stx GRP0                ;3      activate 1-0
    lax (scratch6),y        ;5 = 73

    sta WSYNC

    txs                     ;2
    lax (scratch2),y        ;5 = 7

    sta RESP1               ;3

    lda (scratch0),y        ;5
    sta GRP1                ;3 = 18
    lda (scratch4),y        ;5

    stx GRP0                ;3 = 26 activate 1-1 & 0-0
    sta GRP1                ;3 = 29
    tsx                     ;2
    stx GRP0                ;3 = 34 activate 1-2 & 0-1

    lda (scratch8),y        ;5
    ldx #0                  ;2
    stx GRP1                ;3
    stx GRP0                ;3
    sta GRP1                ;3
    sta RESP1               ;3 = 53

    dey                     ;2
    bpl .loop               ;3 = 58

    iny
    sty GRP0                ;activate the final icon line
    sty GRP1                ;then wipe GRP1
    sty GRP0                ;and activate it...

    ldx scratch10
    txs

    ;flow into the next subroutine




    ;---- Draw the graphic at the bottom of the screen ----
    ;input:  level_flags set
    ;output:  draws graphics, level markers
    ;destroys: a, x, y, scratch0-1
show_splash: subroutine
    ;After calling show_status, NUSIZ1
    ;REFP0, COLUPx will be set correctly

    lda #SPLASH_X0
    ldx #0
    jsr position_player

    lda #SPLASH_X1
    inx
    jsr position_player

    sta WSYNC
    sta HMOVE

    lda #3
    sta NUSIZ0
    sta VDELP0

    ldx #SPLASH_HEIGHT-1

    ;The code below uses pf1buf and pf2buf
    ;to store temporary values.  This is safe
    ;because they always need to be set to $ff
    ;during the kernel, so we can restore them to
    ;a fixed value at the end of the routine.

	;column 1 starts at 42.1 clocks
	;each column is 2.2 clocks wide....
	;42.1	45.0	47.2	50.1	53.0	55.2
.loop:
    sta WSYNC

	lda splash0,x      ;4
	sta GRP0           ;3		set column 0
	lda splash1,x      ;4
	sta GRP1           ;3		set column 1, activate column 0
	lda splash2,x      ;4
	sta GRP0           ;3		set 2, activate 1
	lda splash3,x      ;4
	ldy splash4,x      ;4
	sta pf1buf         ;3
	stx pf2buf         ;3
	lda splash5,x      ;4
	ldx pf1buf         ;3 = 42

	;wait for the exact right spot.........

	stx GRP1		;3		set 3, activate 2 - 0 must be finished!
	sty GRP0		;3		set 4, activate 3 - 1 must be finished!
	sta GRP1		;3		set 5, activate 4 - 2 must be finished!
	sta GRP0		;3 = 54	activate 5 - 3 must be finished!

    ldx pf2buf
    dex
    bpl .loop

    sta WSYNC
    txa
    inx             ;wipe graphics and draw a blank line
    stx GRP1        ;before flowing into the next part...
    stx GRP0
    stx GRP1

    ;Now show markers for the levels that have been completed
    sta WSYNC
    tay                         ;2
    eor initial_level_flags+0   ;4
    and level_flags+0           ;3
    sta GRP0                    ;3 = 12
    tya                         ;2
    eor initial_level_flags+1   ;4
    and level_flags+1           ;3
    sta GRP1                    ;3 = 24
    tya                         ;2
    eor initial_level_flags+2   ;4
    and level_flags+2           ;3
    sta GRP0                    ;3 = 36

    ;restore these to their correct values    
    sty pf1buf                  ;3
    sty pf2buf                  ;3
    stx GRP1                    ;3 = 45
    stx GRP0
    stx VDELP0
    rts


icon_msbs:
    .byte >player_icon, >block_icon
icon_lsbs:
    .byte <player_icon, <block_icon

block_icon:
    .byte %00000000
    .byte %00000000
    .byte %00111100
    .byte %00111100
    .byte %00111100
    .byte %00111100
    .byte %00111100
    .byte %00111100
    .byte %00111100
    .byte %00000000
    .byte %00000000
