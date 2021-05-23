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

pickup_gfx_base:
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000

pickup_gfx_orange equ *-4
    .byte %00111100
    .byte %01001110
    .byte %10111111
    .byte %10111111
    .byte %10111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %01111110
    .byte %00111100

pickup_gfx_cherries equ *-1
    .byte %00000000
    .byte %01100000
    .byte %11110110
    .byte %11111111
    .byte %11111111
    .byte %10111111
    .byte %01101011
    .byte %00000110
    .byte %01000000
    .byte %00100100
    .byte %00100100
    .byte %01001000
    .byte %11110000

pickup_gfx_strawberry equ *-1
    .byte %00000000
    .byte %00000000
    .byte %00001000
    .byte %00010100
    .byte %00111110
    .byte %00101110
    .byte %01111011
    .byte %01011111
    .byte %01110101
    .byte %00111110
    .byte %00011100
    .byte %01110110
    .byte %00100100

pickup_gfx_apple equ *-1
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00101000
    .byte %01111100
    .byte %01111100
    .byte %11111110
    .byte %10111110
    .byte %10111110
    .byte %11111110
    .byte %01101100
    .byte %00010000
    .byte %00100000

pickup_gfx_cone equ *-1
    .byte %00000000
    .byte %00000000
    .byte %00100000
    .byte %00110000
    .byte %00111000
    .byte %01111100
    .byte %01111110
    .byte %01110000
    .byte %00001111
    .byte %01111111
    .byte %01111111
    .byte %00111110
    .byte %00011100

pickup_gfx_rose equ *-1
    .byte %00000000
    .byte %00010000
    .byte %00010000
    .byte %00001000
    .byte %00010100
    .byte %00000100
    .byte %00000100
    .byte %00001010
    .byte %00111000
    .byte %01110100
    .byte %01101100
    .byte %00101100
    .byte %00111000

    ; pickup_gfx_ring equ *-1
    ;     .byte %00000000
    ;     .byte %00111100
    ;     .byte %01111110
    ;     .byte %01100110
    ;     .byte %11000011
    ;     .byte %11000011
    ;     .byte %10000001
    ;     .byte %10000001
    ;     .byte %11000011
    ;     .byte %11000011
    ;     .byte %01100110
    ;     .byte %01111110
    ;     .byte %00111100
    ;
    ; pickup_colu_ring equ *-2
    ;     .byte $00
    ;     .byte $80
    ;     .byte $84
    ;     .byte $86
    ;     .byte $88
    ;     .byte $8a
    ;     .byte $8c
    ;     .byte $8c
    ;     .byte $8e
    ;     .byte $0e
    ;     .byte $8e
    ;     .byte $8c
    ;     .byte $86

pickup_gfx_pretzel equ *-1
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %01000001
    .byte %01011101
    .byte %00111110
    .byte %01100011
    .byte %01010101
    .byte %01010101
    .byte %01001001
    .byte %01101011
    .byte %01111111
    .byte %00110110


pickup_gfx_pear equ *-1
    .byte %00000000
    .byte %00111100
    .byte %01111110
    .byte %11111111
    .byte %10111111
    .byte %10111111
    .byte %11011111
    .byte %01111110
    .byte %00111100
    .byte %00111100
    .byte %00011000
    .byte %00010000
    .byte %00100000