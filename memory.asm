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

EEPROM_BASE_ADDRESS     equ $0200
SIG_BYTE_0              equ 'A
SIG_BYTE_1              equ 'S


    ;---- Sync level markers on memory card ----
do_memory: subroutine
    ;This takes the place of the main display kernel.
    ;We're going to do some stuff with the memory card,
    ;then just wait for INTIM to run out.
    lda #SCREEN_WAIT
    sta TIM64T

    ;First we need to make sure the signature word ('AS')
    ;is there.  It should be the first word in AStar's
    ;section...

    jsr i2c_startwrite
    bcs .stop_write
    lda #>EEPROM_BASE_ADDRESS
    jsr i2c_txbyte
    bcs .stop_write
    lda #<EEPROM_BASE_ADDRESS
    jsr i2c_txbyte
    bcs .stop_write
    jsr i2c_stopwrite

    jsr i2c_startread
    jsr i2c_rxbyte
    cmp #SIG_BYTE_0
    bne .write_markers
    jsr i2c_rxbyte
    cmp #SIG_BYTE_1
    bne .write_markers

    ;So if the signature word is there, we can assume
    ;all the data is valid and load the level markers.
    ;We're still in read mode from checking the signatures.

    ;Note the data on the eeprom is stored
    ;in reverse order!
    ldx #3
.read_loop:
        jsr i2c_rxbyte
        ora level_flags,x       ;Merge with what's in memory
        sta level_flags,x
        dex
        bpl .read_loop

    ;Now we'll write the merged markers back
    ;to the memory card.  First though, we'll
    ;also write the signature word.  If we
    ;got here by failing the signature check,
    ;this will just write the markers that were
    ;in memory, effectively wiping the eeprom.
.write_markers:
    jsr i2c_stopread
    jsr i2c_startwrite
    bcs .stop_write

    ldx #3
.write_loop_1:
        lda .write_table,x
        jsr i2c_txbyte
        bcs .stop_write
        dex
        bpl .write_loop_1

    ldx #3
.write_loop_2:
        lda level_flags,x
        jsr i2c_txbyte
        bcs .stop_write
        dex
        bpl .write_loop_2

.stop_write:
    jsr i2c_stopwrite

.wait_display:
    lda INTIM
    bne .wait_display
    rts

.write_table:
    .byte SIG_BYTE_1
    .byte SIG_BYTE_0
    .byte <EEPROM_BASE_ADDRESS
    .byte >EEPROM_BASE_ADDRESS