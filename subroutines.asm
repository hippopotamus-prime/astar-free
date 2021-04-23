    ;---- Get everything ready for the display kernel ----
    ;No in/outputs
    ;destroys all
    ;This should be the last thing called during VSYNC
kernel_setup: subroutine
    sta HMCLR

    ;Here we're going to calculate a pointer to the player
    ;graphic, based on his direction (anim_base) and animation
    ;frame (from anim_counter).
    lda anim_counter
    and #%00000100      ;animate every 4 frames
    clc
    adc anim_base
    tax
    lda .ref_table,x
    sta REFP0
    lda .frame_table,x
    sta player_gfx_ptr

    ;Then we need to set the color at the top of each block
    ;here, since there isn't time to set it in the kernel
    ;via the normal method.
    ldy #BLOCK_HEIGHT-1
    lda (gradient_ptr),y
    and level_base_colu
    sta block_top_colu
    dey
    lda (gradient_ptr),y
    and level_base_colu
    sta block_top2_colu

    ;Now we'll position both objects and write some
    ;miscellanous values.......
    lda player_x
    ldx #0
    jsr position_player

    lda #PLAYER_COLU
    sta COLUP0

    lda missile_x
    ldx #2
    jsr position_player

    lda #%00100000          ;set missile 0 to very wide
    sta NUSIZ0

    sta WSYNC
    sta HMOVE

    ldx #9
    lda #<blank
.clear:
        sta player_gfx_lsbs,x
        sta missile_en_lsbs,x
        dex
        bpl .clear

    lda player_y
    beq .player_off
    jsr .y_calc
    adc player_gfx_ptr          ;sets c
    sta player_gfx_lsbs,x
    tya
    adc player_gfx_ptr          ;sets c again
    adc #15
    sta player_gfx_lsbs+1,x
.player_off:

    lda missile_y
    beq .missile_off
    jsr .y_calc
    adc #<missile_enable        ;sets c
    sta missile_en_lsbs,x
    tya
    adc #<missile_enable + 16
    sta missile_en_lsbs+1,x
.missile_off:

    lda #>player_gfx
    sta player_gfx_ptr + 1
    sta missile_en_ptr + 1

    lda #$80
    ldx #4
.hm_loop
        sta HMP0,x
        dex
        bpl .hm_loop
    rts

    ;-- short subroutine for maniputlating y-position --
    ;input:  a = object y
    ;output:  x = upper 4 bits, y = - lower 4 bits
.y_calc:
    tay
    lsr
    lsr
    lsr
    lsr
    tax
    tya
    and #%00001111
    eor #%11111111
    tay
    sec
    rts

.ref_table:
    .byte %00000000, %00000000, %00001000, %00000000
    .byte %00000000, %00000000, %00001000, %00000000

.frame_table:
    .byte <player_frame_1
    .byte <player_frame_3
    .byte <player_frame_1
    .byte <player_frame_2

    .byte <player_frame_0
    .byte <player_frame_0
    .byte <player_frame_0
    .byte <player_frame_0




    ;---- Initialize memory and TIA stuff ----
    ;no in/output
    ;destroys: a, x, y
init_game: subroutine
    ldy #.length - 1
.loop:
        lda .val,y
        ldx .dst,y
        sta 0,x
        dey
        bpl .loop
    rts

.dst:
    .byte CTRLPF
    .byte VDELP1
    .byte pickup_gfx_ptr+1
    .byte pickup_colu_ptr+1
    .byte pickup_nusizes+0
    .byte pickup_nusizes+BOARD_HEIGHT-1
    .byte pf1buf
    .byte pf2buf
    .byte pf3buf
    .byte pf4buf
    .byte pf4buf+9
    .byte gradient_ptr+1
    .byte gradient_ptr
    .byte state
    .byte level_flags
    .byte level_flags+1
    .byte level_flags+2
    .byte level_flags+3
.length equ *-.dst

.val:
    .byte 1
    .byte 1
    .byte >pickup_gfx_base
    .byte >pickup_colu_base
    .byte 5
    .byte 5
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte >blank
    .byte <blank
    .byte STATE_LOAD
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %11111111


    ;---- Return the status of SWCHB ----
    ;no input
    ;output: x = bits that are changed this frame
    ;        a = bits that are both pressed and changed this frame
    ;destroys: none
check_swchb: subroutine
    lax SWCHB
    eor swchb_bak           ;here a 1 means the switch changed
    stx swchb_bak
    tax
    eor #%11111111          ;now 0 means the switch changed
    ora SWCHB               ;and now 0 means it changed and is down
    rts


    ;---- Check for reset / select ----
    ;no input
    ;output: state might be updated
    ;destroys a, x, y
check_console_switches: subroutine
    jsr check_swchb

    lsr
    bcs .no_reset
        ldy #0
        sty advance_status
        ldy #STATE_WIN
        sty state
        dec level           ;effectively this advances to the same level
.no_reset:

    and #1
    bne .no_select
        sta advance_status
        lda #STATE_WIN
        sta state
.no_select:

    txa
    and #%01000000
    beq .no_ldiff
        jmp undo_move
.no_ldiff:

    rts





	;---- position the player horizontally ----
	;input:	a = x coordinate
	;		x = player (2&3 for missiles, 4 for the ball)
position_player: subroutine
	sta WSYNC

	sec				;2
.pxloop:
		sbc #15		;2
		bcs .pxloop	;3/2

	eor #255		;2
	sbc #6			;2
	asl				;2
	asl				;2
	asl				;2
	asl				;2
	sta RESP0,x		;4
	sta HMP0,x		;4
	rts				;6
