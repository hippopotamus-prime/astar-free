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

group_start:
    .byte   pSILENT,    pSILENT,    pSILENT,    pSILENT
    .byte   pSILENT,    pBUZZ,      pSILENT,    pKICK
    .byte   pSILENT,    pBUZZ,      pKICK,      pHATENG
    .byte   pSILENT,    pBUZZ,      pSILENT,    pHATENG

    .byte   pSQUAREde,  pSQUAREde,  pLEADga,    pLEADga
    .byte   pSQUAREbc,  pSQUAREbc,  pLEADga,    pLEADga
    .byte   pSQUAREe,   pSQUAREd,   pLEADa,     pLEADg
    .byte   pSQUAREbc,  pSQUAREbc,  pLEADa,     pLEADg
    .byte   pSQUAREc,   pSQUAREb,   pLEADga,    pLEADga

    .byte   pSILENT,    pSILENT,    pSQUAREe,   pLEADga
    .byte   pLEADe,     pLEADga,    pSQUAREb,   pSQUAREbc

    .byte   pKICK,      pKICK,      pKICK,      pKICK
    .byte   pBUZZ,      pBUZZ,      pBUZZ,      pBUZZ
    .byte   pSILENT,    pLEADa,     pLEADga,    pLEADg
    .byte   pSQUAREe,   pSQUAREde,  pSQUAREbc,  pSQUAREb