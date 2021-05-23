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

STATE_PLAY          equ 0
STATE_LOAD          equ 1
STATE_WIN           equ 2
STATE_ADVANCE       equ 3
STATE_FADE_OUT      equ 4
STATE_FADE_IN       equ 5
STATE_TITLE         equ 6
STATE_MEMORY        equ 7

    ;---- Run the game according to its state ----
    ;This is the highest level routine in the game,
    ;to be executed at the start of VBLANK.
    ;No in/outputs.
process_state: subroutine
    ldx state
    lda .function_msbs,x
    sta scratch1
    lda .function_lsbs,x
    sta scratch0
    jmp (scratch0)

.function_msbs:
    .byte >play
    .byte >load
    .byte >win
    .byte >advance
    .byte >fade_out
    .byte >fade_in
    .byte >title
    .byte >memory

.function_lsbs:
    .byte <play
    .byte <load
    .byte <win
    .byte <advance
    .byte <fade_out
    .byte <fade_in
    .byte <title
    .byte <memory


    ;---- Play the game ----
    ;This the main game-play handling function,
    ;corresponding to STATE_PLAY.
    ;It eventually transitions to STATE_WIN or STATE_LOAD.
play: subroutine
    jsr check_console_switches
    jsr check_level_done
    jsr check_player_pickups
    jsr set_current_object
    ldx current_object
    jsr read_input_direction
    jmp move_object



    ;---- Wait on the title screen ----
    ;STATE_TITLE -> STATE_WIN
title: subroutine
    jsr check_swchb
    sta scratch0

    ror
    and scratch0
    ror
    ror
    and INPT4
    asl

    bcs .end
        lda #1
        sta advance_status
        lda #STATE_WIN
        sta state
.end:
    rts




    ;---- Load the current level ----
    ;This corresponds to STATE_LOAD.
    ;It transitions to STATE_MEMORY.
load: subroutine
    jsr load_map
    lda #STATE_MEMORY
    sta state
    jmp reset_game_vars


    ;---- End the current level ----
    ;This function handles the successful completion
    ;of the current level, corresponding to STATE_WIN.
    ;It transitions to STATE_FADE_OUT.
win: subroutine
    lda #STATE_FADE_OUT
    sta state
    lda #FADE_TOP
    sta fade_counter
    rts



    ;---- Move to the next level ----
    ;This function advances the level and
    ;checks for game over; it corresponds to
    ;STATE_ADVANCE.
    ;It transitions to STATE_LOAD.
advance: subroutine
    lda #STATE_LOAD
    sta state
    ldx advance_status
    cpx #2
    bne .no_win

    ;-- Inline: Check if every level is completed --
    ;input:  none (reads level_flags)
    ;output:  z if all are completed
    ;destroys: a, x
    ldy #4
    lda #%11111111
.loop:
        and level_flags-1,y
        dey
        bne .loop
    eor #%11111111

    bne .no_win
        lda #LEVELS+1
        sta level
        rts
.no_win:

    ;-- Advance to the next level --
    lda level
    cmp #LEVELS
    bcc .no_wrap
        sty level   ;y=0 from the loop
.no_wrap:
    inc level

    ;-- Easter Egg --
    ;Finish level 3 or higher perfectly and hold
    ;up on P0, down on P1, then you go to the
    ;secret level.
    cmp #3
    bcc .no_easter
        txa
        eor #%00000010
        ora SWCHA
        and #%00010010
        bne .no_easter
            lda #LEVELS+2
            sta level
.no_easter:

    ;-- Check if reset and select are both down --
    ;This takes you back to the title screen.
    lda SWCHB
    sta swchb_bak
    and #%00000011
    bne .no_title
        ;lda #0
        sta level
        rts
.no_title:

    ;-- Set the opening music for the next level --
    ldy .sounds_1,x
    lda .sounds_0,x
    tax
    jmp set_sound

.sounds_0:
    .byte sound_silent
    .byte sound_finish_0
    .byte sound_win_0
.sounds_1:
    .byte sound_silent
    .byte sound_finish_1
    .byte sound_win_1



    ;---- Sync memory card ----
    ;STATE_MEMORY --> STATE_FADE_IN
memory: subroutine
    lda #<do_memory
    sta kernel_addr
    lda #>do_memory
    sta kernel_addr+1
    lda #STATE_FADE_IN
    sta state
    rts



    ;---- Fade Out ----
    ;STATE_FADE_OUT --> STATE_ADVANCE
fade_out: subroutine
    dec fade_counter
    beq .advance
        ;When the right difficulty switch is set, we
        ;skip the cool fade effects by decrementing
        ;the counter to zero in one frame.
        lda SWCHB
        bmi fade_out
        bpl .end
.advance:
    ldx #sound_silent
    ldy #sound_silent
    jsr set_sound
    lda #STATE_ADVANCE
    sta state
.end:
    jmp fade_gradient


    ;---- Fade In ----
    ;STATE_FADE_IN --> STATE_PLAY or STATE_TITLE
fade_in: subroutine
    inc fade_counter
    lda fade_counter
    cmp #FADE_TOP
    beq .advance
        lda SWCHB
        bmi fade_in
        bpl .end

.advance:
    lda level
    beq .title
    cmp #LEVELS+1
    beq .win

    ldx #STATE_PLAY
    bpl .set_state

.win:
    jsr init_game       ;reset level_flags
    lda #$13
    sta moves+1
    lda #$37
    sta moves

.title:
    ldx #sound_intro_0
    ldy #sound_intro_1
    jsr set_sound
    ldx #STATE_TITLE

.set_state:
    stx state
.end:
    jmp fade_gradient