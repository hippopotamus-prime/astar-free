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

gradient_msb_table:
    .byte >blank
    .byte >blank
    .byte >blank
    .byte >gradient_table_7
    .byte >gradient_table_6
    .byte >gradient_table_5
    .byte >gradient_table_4
    .byte >gradient_table_3
    .byte >gradient_table_2
    .byte >gradient_table_1
    .byte >gradient_table_0

gradient_lsb_table:
    .byte <blank
    .byte <blank
    .byte <blank
    .byte <gradient_table_7
    .byte <gradient_table_6
    .byte <gradient_table_5
    .byte <gradient_table_4
    .byte <gradient_table_3
    .byte <gradient_table_2
    .byte <gradient_table_1
    .byte <gradient_table_0



gradient_table_0 equ *-1
    .byte $f0
    .byte $f2
    .byte $f4
    .byte $f6
    .byte $f6
    .byte $f8
    .byte $fa
    .byte $fc
    .byte $fc
    .byte $fe
    .byte $fe
    .byte $fe
    .byte $fc
    .byte $fa
    .byte $f6

gradient_table_1 equ *-1
    .byte $00
    .byte $f0
    .byte $f2
    .byte $f4
    .byte $f4
    .byte $f6
    .byte $f8
    .byte $fa
    .byte $fa
    .byte $fc
    .byte $fc
    .byte $fc
    .byte $fa
    .byte $f8
    .byte $f4

gradient_table_2 equ *-1
    .byte $00
    .byte $00
    .byte $f0
    .byte $f2
    .byte $f2
    .byte $f4
    .byte $f6
    .byte $f8
    .byte $f8
    .byte $fa
    .byte $fa
    .byte $fa
    .byte $f8
    .byte $f6
    .byte $f2

gradient_table_3 equ *-1
    .byte $00
    .byte $00
    .byte $00
    .byte $f0
    .byte $f0
    .byte $f2
    .byte $f4
    .byte $f6
    .byte $f6
    .byte $f8
    .byte $f8
    .byte $f8
    .byte $f6
    .byte $f4
    .byte $f0

gradient_table_4 equ *-1
    .byte $00
    .byte $00
    .byte $00
    .byte $00
    .byte $00
    .byte $f0
    .byte $f2
    .byte $f4
    .byte $f4
    .byte $f6
    .byte $f6
    .byte $f6
    .byte $f4
    .byte $f2
    .byte $00

gradient_table_5 equ *-2
    .byte $00
    .byte $00
    .byte $00
    .byte $00
    .byte $00
    .byte $f0
    .byte $f2
    .byte $f2
    .byte $f4
    .byte $f4
    .byte $f4
    .byte $f2
    .byte $f0
    .byte $00

gradient_table_6 equ *-2
    .byte $00
    .byte $00
    .byte $00
    .byte $00
    .byte $00
    .byte $00
    .byte $f0
    .byte $f0
    .byte $f2
    .byte $f2
    .byte $f2
    .byte $f0
    .byte $00
    .byte $00

gradient_table_7 equ *-3
    .byte $00
    .byte $00
    .byte $00
    .byte $00
    .byte $00
    .byte $00
    .byte $00
    .byte $f0
    .byte $f0
    .byte $f0
    .byte $00
    .byte $00
    .byte $00