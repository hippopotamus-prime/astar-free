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

    .byte %00000000,%00000000
    .byte %10101101,%01011101
    .byte %10100101,%01010101
    .byte %11101101,%01110110
    .byte %10101001,%01010101
    .byte %10101111,%10110110
    .byte %01100000,%00000000
    .byte %00000000,%00000000

    PICKUP 0,5
    PICKUP 0,5
    PICKUP 0,5
    PICKUP 0,5
    PICKUP 0,5
    PICKUP 0,5
    PICKUP 0,5
    PICKUP 0,5

    COORD 2,0
    COORD 13,0

    ;The par score is irrelevant here
    .byte 0
