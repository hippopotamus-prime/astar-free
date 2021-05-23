    ; =====================================================================
    ; AStar
    ; Copyright 2005 Aaron Curtis
    ; 
    ; This file is part of AStar.
    ; 
    ; AStar is free software; you can redistribute it and/or modify
    ; it under the terms of the GNU General Public License as published by
    ; the Free Software Foundation; either version 3 of the License, or
    ; (at your option) any later version.
    ; 
    ; AStar is distributed in the hope that it will be useful,
    ; but WITHOUT ANY WARRANTY; without even the implied warranty of
    ; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    ; GNU General Public License for more details.
    ; 
    ; You should have received a copy of the GNU General Public License
    ; along with AStar; if not, see <https://www.gnu.org/licenses/>.
    ; =====================================================================

    ;This file contains subroutines for controlling
    ;the game objects, moving them around them map,
    ;detecting collisions, and the like.



    ;---- Mark a level as completed ----
    ;input:  none (reads from level)
    ;output:  level_flags updated
    ;destroys: a, x, y
mark_level:
    ldx level
    dex                 ;level 0 (the title screen) doesn't count
    txa
    and #%00000111
    tay
    txa
    lsr
    lsr
    lsr
    tax
    lda .masks,y
    ora level_flags,x
    sta level_flags,x
    rts

    ;The masks are high->low like this
    ;so they're easier to draw on the screen
.masks:
    .byte %10000000
    .byte %01000000
    .byte %00100000
    .byte %00010000
    .byte %00001000
    .byte %00000100
    .byte %00000010
    .byte %00000001



    ;---- Compare moves to the par score ----
    ;input:  none
    ;output:  as normal cmp (par to moves)
    ;destroys: a
compare_par: subroutine
    clc
    lda moves+1
    bne .end

    lda par
    cmp moves
.end:
    rts



    ;---- Reset game variables ----
    ;input:  none
    ;output:  various memory locations reset
    ;destroys: x,y
reset_game_vars: subroutine
    ldy #DIR_NONE
    sty direction

    ;ldy #-1
    sty prev_object

    ;zero out moves, anim_base, anim_counter,
    ;current_object, prev_x, prev_y, fade_counter
    iny
    ldx #moves+1 - prev_x
.loop:
        sty prev_x,x
        dex
        bpl .loop
    rts




    ;---- Set the board gradient based on the fade counter ----
    ;input:  fade_counter = some valid value
    ;output:  gradient_ptr set
    ;destroys: a, x
fade_gradient: subroutine
    lda fade_counter
    lsr
    lsr
    tax

    sec
    sbc #FADE_TOP/4
    sta vol_adjust

    lda gradient_msb_table,x
    sta gradient_ptr+1
    lda gradient_lsb_table,x
    sta gradient_ptr
    rts



    ;---- Undo the last move ----
    ;input:  none
    ;output:  reverts missile or player_x, y, dir, moves
    ;destroys:  a, x
undo_move: subroutine
    ldx prev_object
    bmi .end
    bne .no_anim
        ;ldx #0
        stx anim_counter
.no_anim:
    lda prev_x
    sta player_x,x
    lda prev_y
    sta player_y,x
    lda #-1
    sta direction
    sta prev_object

    sed
    sec
    lda moves
    sbc #1
    sta moves
    lda moves+1
    sbc #0
    sta moves+1
    cld

.end:
    rts




    ;---- Check if all the pickups are picked up ----
    ;input:  none
    ;output:  state affected
    ;destroys: x, a
check_level_done: subroutine
    ldx #BOARD_HEIGHT - 2
.loop:
        lda pickup_nusizes,x
        cmp #5
        bne .end
        dex
        bne .loop

    lda #STATE_WIN
    sta state

    ;x was 0 from the loop...
    ;advance_status 1 is the over-par ending,
    ;2 is under par (longer music)
    inx
    jsr compare_par
    bcc .over_par
        jsr mark_level  ;destroys x
        ldx #2
.over_par:
    stx advance_status

.end:
    rts



    ;---- Set the current object based on joystick input ----
    ;No in/outputs
    ;destroys: a, x
set_current_object: subroutine
    lax INPT4
    bmi .end

    ;We only want to catch the button on an up->down transition,
    ;i.e. currently 0, but 1 on previous frame
    eor inpt4_bak
    bpl .end

    ;We also only want to change when the current object
    ;isn't doing anything...
    lda direction
    bpl .end

    lda current_object
    eor #1
    sta current_object

.end:
    stx inpt4_bak
    rts



    ;---- Change object direction based on joystick input ----
    ;input:  x = object (0 for the player, 1 for the missile)
    ;output:  dir, anim_base updated
    ;         a = add to move counter (0 or 1)
    ;destroys: y
read_input_direction: subroutine
    lda direction
    bpl .end

    lda SWCHA
    lsr
    lsr
    lsr
    lsr
    tay
    lda .directions,y
    sta direction
    bmi .end

    cpx #0
    bne .no_anim_change
        sta anim_base
.no_anim_change:

    lda #1
    rts

.end:
    lda #0
    rts

.directions:            ;joystick input codes - clear is active
    .byte DIR_NONE      ;%0000
    .byte DIR_NONE      ;%0001
    .byte DIR_NONE      ;%0010
    .byte DIR_NONE      ;%0011
    .byte DIR_NONE      ;%0100
    .byte DIR_NONE      ;%0101
    .byte DIR_NONE      ;%0110
    .byte DIR_RIGHT     ;%0111
    .byte DIR_NONE      ;%1000
    .byte DIR_NONE      ;%1001
    .byte DIR_NONE      ;%1010
    .byte DIR_LEFT      ;%1011
    .byte DIR_NONE      ;%1100
    .byte DIR_DOWN      ;%1101
    .byte DIR_UP        ;%1110
    .byte DIR_NONE      ;%1111




    ;---- x-offsets for either object ----
offsets:
    .byte PLAYER_X_OFFSET
    .byte MISSILE_X_OFFSET



    ;---- Move an object according to its direction ----
    ;input:  x = object (0 for the player, 1 for the missile)
    ;        a = add to move counter (0 or 1)
    ;output:  player_x, _y, _dir updated
    ;destroys: a, x, y, scratch0-6
move_object: subroutine
    ldy direction
    bpl .go

.clear:
    lda #DIR_NONE
    sta direction
    rts

.go:
        sta scratch6
        clc
        beq .right
        dey
        beq .up
        dey
        beq .left

.down:
    lda player_y,x
    adc #-1
    sta scratch4
    bcs .sety

.up:
    lda player_y,x
    adc #1
    sta scratch4
    adc #15

.sety:
    tay
    lda player_x,x
    sec
    sbc offsets,x
    inx
    inx
    stx scratch5
    tax
    bcs .move

.left:
    lda player_x,x
    adc #-1
    sta scratch4
    bcs .setx

.right:
    lda player_x,x
    adc #1
    sta scratch4
    adc #7

.setx:
    ldy player_y,x
    sec
    sbc offsets,x
    stx scratch5
    tax

.move:
    jsr get_column_row
    jsr detect_block
    bne .clear

    lda current_object
    eor #1
    tax
    jsr detect_object
    beq .clear

    lda current_object
    beq .skip_pickups
        jsr detect_pickups
        txa
        bpl .clear
        bmi .finish

.skip_pickups:
    inc anim_counter

.finish:
    lda scratch6
    beq .no_move_update

        ldx current_object
        stx prev_object
        lda player_x,x
        sta prev_x
        lda player_y,x
        sta prev_y

        jsr compare_par
        bne .no_sound
            ldx #sound_over_par
            ldy #0
            jsr set_sound
.no_sound:

        sed
        lda moves
        clc
        adc #1
        tax
        lda moves+1
        adc #0
        bcs .overflow
            sta moves+1
            stx moves
.overflow:
        cld

.no_move_update:
    lda scratch4
    ldx scratch5
    sta player_x,x
    rts




    ;---- Look for pickups at the player's position ----
    ;This is a higher-level wrapper around
    ;detect_pickups and collect_pickup
    ;No in/outputs
    ;destroys: a, x, y, scratch2, scratch3
check_player_pickups: subroutine
    lda player_x
    clc
    adc #4 - PLAYER_X_OFFSET    ;sets c
    tax
    lda player_y
    adc #7
    tay
    jsr get_column_row
    jsr detect_pickups
    txa
    bpl collect_pickup
    rts



    ;---- Remove a pickup from the map ----
    ;input:  x = index of pickup
    ;        scratch3 = row
    ;        (i.e. the output from detect_pickups)
    ;output:  map is updated, sound effect played
    ;destroys: a,x,y
collect_pickup: subroutine
    txa
    asl
    asl
    asl
    ldx scratch3
    adc pickup_nusizes,x
    tay
    lda .new_nusizes,y
    sta pickup_nusizes,x
    lda .deltas,y
    adc pickup_positions,x
    sta pickup_positions,x

    ldy #-1                         ;when undoing a move, we don't have the ability
    sty prev_object                 ;to restore pickups, so disable undo whenever
                                    ;a pickup is collected

    ldx #sound_collect
    iny         ;ldy #0
    jmp set_sound

.deltas:
    .byte 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 2, 4, 0, 8, 0, 0, 0
    .byte 0, 0, 0, 2, 0, 0, 4, 0

.new_nusizes:
    .byte 5, 0, 0, 1, 0, 5, 2, 5
    .byte 5, 0, 0, 2, 0, 5, 4, 5
    .byte 5, 0, 0, 1, 0, 5, 2, 5



    ;---- Test if an object is at some coordinates ----
    ;input:  x = object (0 = player, 1 = missile)
    ;        scratch2 = column, scratch3 = row
    ;output:  z if the object was present
    ;destroys: a
detect_object: subroutine
    lda player_x,x
    sec
    sbc offsets,x
    lsr
    lsr
    lsr
    cmp scratch2
    bne .end

    lda player_y,x
    lsr
    lsr
    lsr
    lsr
    cmp scratch3
.end:
    rts




    ;---- Test if there's a block at some coordinates ----
    ;input:  scratch2 = column, scratch3 = row
    ;        (i.e. the output from get_column_row)
    ;output:  nz if there was a block
    ;destroys: a, x, y, scratch0
detect_block: subroutine
    ;First we have to figure out what playfield
    ;we're on...
    lax scratch2
    lsr
    lsr
    tay
    lda .pf_buf_table,y
    clc
    adc scratch3                    ;clears c
    sta scratch0

    ;Then we have to get a mask for the right
    ;playfield bit.  These are cleverly stored
    ;in a table...
    txa
    and #%00000011
    adc .mask_table_offsets,y       ;clears c
    tax
    lda .mask_table,x

    ;Done!
    ldx scratch0
    and 0,x
    rts

.pf_buf_table:
    .byte pf1buf, pf2buf, pf3buf, pf4buf

.mask_table_offsets:
    .byte 0, 4, 0, 4

.mask_table:
    .byte %10000000
    .byte %00100000
    .byte %00001000
    .byte %00000010
    .byte %00000010
    .byte %00001000
    .byte %00100000
    .byte %10000000



    ;---- Test if there's a pickup at some row/column ----
    ;input:  scratch2 = column, scratch3 = row
    ;        (i.e. the outputs of get_column_row)
    ;output:  x = index of pickup found (0,1,2) or -1 if none was found
    ;destroys: a, y
detect_pickups: subroutine
    ldx scratch3

    ldy pickup_nusizes,x
    lda pickup_positions,x
    ldx .counters,y
    bmi .end
.loop:
        cmp scratch2
        beq .end

        clc
        adc .deltas,y
        dex
        bpl .loop

.end:
    rts

.counters:
    .byte 0, 1, 1, 2, 1, -1, 2
.deltas:
    .byte 0, 2, 4, 2, 8, 0, 4



    ;---- Translate x, y coordinates to map column, row ----
    ;input:  x, y = map coordinates
    ;output:  scratch2 = column, scratch3 = row
    ;destroys: a
get_column_row: subroutine
    txa
    lsr
    lsr
    lsr
    sta scratch2

    tya
    lsr
    lsr
    lsr
    lsr
    sta scratch3

    rts
