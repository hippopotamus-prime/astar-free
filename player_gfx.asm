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

player_gfx:

blank:
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
    .byte %00000000
    .byte %00000000

player_frame_0:
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00111000
    .byte %01111100
    .byte %01111100
    .byte %11111110
    .byte %11111110
    .byte %11111110
    .byte %11111110
    .byte %11111110
    .byte %01111100
    .byte %01111100
    .byte %00111000
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
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000

player_frame_1:
    .byte %00000000
    .byte %00000000
    .byte %00000000
player_icon:
    .byte %00111000
    .byte %01111100
    .byte %01111100
    .byte %11111000
    .byte %11110000
    .byte %11100000
    .byte %11110000
    .byte %11111000
    .byte %01111100
    .byte %01111100
    .byte %00111000
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
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000

player_frame_2:
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %01000100
    .byte %01000100
    .byte %11000110
    .byte %11101110
    .byte %11101110
    .byte %11111110
    .byte %11111110
    .byte %01111100
    .byte %01111100
    .byte %00111000
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
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000

player_frame_3:
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00111000
    .byte %01111100
    .byte %01111100
    .byte %11111110
    .byte %11111110
    .byte %11101110
    .byte %11101110
    .byte %11000110
    .byte %01000100
    .byte %01000100
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
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000



missile_enable equ *-3
    ;.byte 0
    ;.byte 0
    ;.byte 0
    .byte 0
    .byte 0
    .byte 2
    .byte 2
    .byte 2
    .byte 2
    .byte 2
    .byte 2
    .byte 2
    .byte 0
    .byte 0
    .byte 0
    .byte 0

    .byte 0
    .byte 0
    .byte 0
    .byte 0
    .byte 0
    .byte 0
    .byte 0
    .byte 0
    .byte 0
    .byte 0
    .byte 0
    .byte 0
    .byte 0
    .byte 0
    .byte 0
    .byte 0
