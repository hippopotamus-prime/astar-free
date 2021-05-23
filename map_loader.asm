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

    ;Map Format
    ;----------
    ;2 bytes * MAP_HEIGHT-2 rows, map data
    ;1 byte * MAP_HEIGHT-2 rows, pickup positions/nusizes
    ;1 byte player x/y
    ;1 byte block x/y
    ;1 byte par score

    ;1 byte color base stored elsewhere


    ;---- Multiply a by x ----
    ;input:  a and x = 8 bit values to multiply
    ;output:  scratch0-1 = 16 bit result
    ;destroys: y
    ;notes:  always returns y=0, c clear
multiply: subroutine
    lsr
    sta scratch0
    lda #0
    sta scratch1
    ldy #8
.loop:
    bcc .skip
        clc
        txa
        adc scratch1
.skip:
    ror
    sta scratch1
    ror scratch0
    dey
    bne .loop
    rts




    ;---- Load a map and related data into memory ----
    ;input:  level = index of map to load
    ;output:  pf*buf, pickup_positions/nusizes, player_x/y/dir updated
    ;destroys: a, x, y, scratch0-2
load_map: subroutine
    ;convert from bcd...
    lda level
    ;and #%11110000
    ;lsr
    ;sta scratch0
    ;lsr
    ;lsr
    ;adc scratch0
    ;sta scratch0
    ;txa
    ;and #%00001111
    ;adc scratch0

    ;The background color (upper 4 bits) and
    ;the index of the pickup graphic (lower 4 bits)
    ;isn't stored with the map data, so we'll
    ;handle that first.
    tay
    lax map_colors,y
    ora #$0f
    sta level_base_colu
    txa
    and #$0f
    tax
    lda pickup_gfx_table,x
    sta pickup_gfx_lsb
    lda pickup_colu_table,x
    sta pickup_colu_ptr
    tya

    ;Now multiply the level by 27...
    ldx #27
    jsr multiply

    lda scratch0       ;lsb of map_base is 0
    adc #<map_base
    sta scratch0
    lda scratch1
    adc #>map_base
    sta scratch1

    ;Now start loading the data...
    ldy #[BOARD_HEIGHT * 2] - 4 + BOARD_HEIGHT - 2 + 2

    ;The highest byte is the par score (in BCD)
    lda (scratch0),y
    sta par

    ;The next two bytes are starting coordinates
    ;for the player (lower byte) and the block
    dey
    ldx #1
.coord_loop:
        lda (scratch0),y
        and #%00001111
        asl
        asl
        asl
        adc offsets,x
        sta player_x,x
        lda (scratch0),y
        and #%11110000
        sta player_y,x
        dey
        dex
        bpl .coord_loop

    ldx #BOARD_HEIGHT - 3
.pickup_loop:
        lda (scratch0),y
        and #%00001111
        sta pickup_positions+1,x
        lda (scratch0),y
        lsr
        lsr
        lsr
        lsr
        sta pickup_nusizes+1,x
        dey
        dex
        bpl .pickup_loop

    ldx #BOARD_HEIGHT - 3
.map_loop:
        sty scratch2
        lda (scratch0),y
        pha
        and #%00001111
        tay
        lda .pf4table,y
        sta pf4buf+1,x
        pla
        lsr
        lsr
        lsr
        lsr
        tay
        lda .pf3table,y
        sta pf3buf+1,x

        ldy scratch2
        dey
        lda (scratch0),y
        pha
        and #%00001111
        tay
        lda .pf2table,y
        sta pf2buf+1,x
        pla
        lsr
        lsr
        lsr
        lsr
        tay
        lda .pf1table,y
        sta pf1buf+1,x

        ldy scratch2
        dey
        dey
        dex
        bpl .map_loop

    rts

.pf1table:
.pf3table:
    .byte %00000000
    .byte %00000011
    .byte %00001100
    .byte %00001111
    .byte %00110000
    .byte %00110011
    .byte %00111100
    .byte %00111111
    .byte %11000000
    .byte %11000011
    .byte %11001100
    .byte %11001111
    .byte %11110000
    .byte %11110011
    .byte %11111100
    .byte %11111111

.pf2table:
.pf4table:
    .byte %00000000
    .byte %11000000
    .byte %00110000
    .byte %11110000
    .byte %00001100
    .byte %11001100
    .byte %00111100
    .byte %11111100
    .byte %00000011
    .byte %11000011
    .byte %00110011
    .byte %11110011
    .byte %00001111
    .byte %11001111
    .byte %00111111
    .byte %11111111
