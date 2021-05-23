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

    ;It's tha main display kernel!
    ;-----------------------------

    ;The spaghetti code is a dangerous tool, Saruman!
    ;Why?  Why should _we_ fear to use it?

kernel_jump: subroutine
    jmp (kernel_addr)

kernel: subroutine
    ldy #0
    ldx #BOARD_HEIGHT-1
    sta WSYNC
    bne .enter              ;3

.end:
    sta WSYNC
    sty PF2
    sty PF1
    sty GRP0
    sty ENAM0
    rts

.mid_block:
    ;53

    lda (pickup_gfx_ptr),y  ;5
    sta GRP1                ;3 = 61

    lda (gradient_ptr),y    ;5
    and level_base_colu     ;3
    sta COLUPF              ;3 = 72

    lda (pickup_colu_ptr),y ;5 = 1
    sta COLUP1              ;3

.loop:
    lda (player_gfx_ptr),y  ;5
    sta GRP0                ;3 = 12

    lda pf1buf,x            ;4
    sta PF1                 ;3 = 19

    lda (missile_en_ptr),y  ;5
    sta ENAM0               ;3 = 27

    lda pf2buf,x            ;4
    sta PF2                 ;3 = 34

    lda pf4buf,x            ;4
    sta PF1                 ;3 = 41

    lda pf3buf,x            ;4
    sta PF2                 ;3 = 48         <---- this timing is really important!

    dey                     ;2
    bne .mid_block          ;2/3


.next_block:
    ;52

    sty GRP1                ;3

    dex                     ;2
    bmi .end                ;2/3

    sty.w PF2               ;4 = 63

    lda (player_gfx_ptr),y  ;5
    sta GRP0                ;3 = 71

    lda (missile_en_ptr),y  ;5
    sta ENAM0               ;3 = 3

.enter:
    sty PF1                 ;3 = 6

    ldy pickup_positions,x  ;4 = 10
    lda hmove_table,y       ;4
    sta HMP1                ;3 = 17
    lda resp_table,y        ;4
    bpl .right_side         ;2/3

    ;23
.left_position:
        asl                 ;2
        bmi .left_position  ;2/3

    sta RESP1               ;3

    ;30 <= ? <= 45

    lda player_gfx_lsbs,x   ;4
    sta player_gfx_ptr      ;3
    lda missile_en_lsbs,x   ;4
    sta missile_en_ptr      ;3 <= 59

    ;c always set by asl
    bcs .continue           ;3 <= 62


.right_side:
    ;24

    tay                     ;2
    lda player_gfx_lsbs,x   ;4
    sta player_gfx_ptr      ;3
    lda missile_en_lsbs,x   ;4
    sta missile_en_ptr      ;3

    ;40
.right_position:
        dey
        bne .right_position ;2/3

    nop 0
    sta RESP1               ;3

    ;50 <= ? <= 65

.continue:
    lda block_top_colu      ;3
    sta COLUPF              ;3

    ldy #BLOCK_HEIGHT - 1   ;2 <= 73

    sta WSYNC

    lda (player_gfx_ptr),y  ;5
    sta GRP0                ;3
    lda (missile_en_ptr),y  ;5
    sta ENAM0               ;3 = 16

    ldy pickup_nusizes,x    ;4

    lda pf1buf,x            ;4
    sta PF1                 ;3 = 27

    lda pf2buf,x            ;4
    sta PF2                 ;3 = 34

    lda pf4buf,x            ;4
    sta PF1                 ;3 = 41

    lda pf3buf,x            ;4
    sta PF2                 ;3 = 48

    sty NUSIZ1              ;3 = 51

    ;This next part disables the pickups if needed,
    ;it could be replaced by something like...
    ;   lda pickup_gfx_lsbs,x
    ;   sta pickup_gfx_ptr
    ;...but that would chew up even more ram
    lda #0                  ;2
    cpy #5                  ;2
    bne .pickup_on          ;2/3
        .byte $2c           ;4              skip next 2-byte instruction
.pickup_on:
    lda pickup_gfx_lsb      ;3
    sta pickup_gfx_ptr      ;3

    ldy #BLOCK_HEIGHT - 2   ;2 = 66

    lda block_top2_colu      ;3
    nop;and #$fc                ;2

    sta HMOVE               ;3 = 74         <---- no black line
    sta COLUPF              ;3
    jmp .loop               ;3 = 4



resp_table:
    ;-+~= left half =~+-
    .byte %10000000     ;+0
    .byte %10000000     ;+0
    .byte %11000000     ;+15
    .byte %11000000     ;+15
    .byte %11100000     ;+30
    .byte %11100000     ;+30
    .byte %11110000     ;+45
    .byte %11110000     ;+45

    ;-+~= right half =~+-
    .byte 1             ;+60
    .byte 2             ;+75
    .byte 2             ;+75
    .byte 3             ;+90
    .byte 3             ;+90
    .byte 4             ;+105
    .byte 4             ;+105
    .byte 5             ;+120


hmove_table:
    ;-+~= left half =~+-
    .byte $30           ;-11
    .byte $b0           ;-3
    .byte $20           ;-10
    .byte $a0           ;-2
    .byte $10           ;-9
    .byte $90           ;-1
    .byte $00           ;-8
    .byte $80           ;-0

    ;-+~= right half =~+-
    .byte $f0           ;-7
    .byte $60           ;-14
    .byte $e0           ;-6
    .byte $50           ;-13
    .byte $d0           ;-5
    .byte $40           ;-12
    .byte $c0           ;-4
    .byte $30           ;-11
