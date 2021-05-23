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

    ;sound control codes and corresponding
    ;volumes - the names match the ones
    ;used in Paul Slocum's music kit
BUZZ        equ 15      ;15 uneven grindy motor noise
BUZZ_VOL    equ 13
LOWBASS     equ 14      ;14 slower soft zippery buzz
LOWBASS_VOL equ 13
                        ;13 very similar to 12
LEAD        equ 12      ;12 basic beep
LEAD_VOL    equ 8
                        ;11 same as 0
                        ;10 soft rapid zippery buzz
                        ;9 buzz, little more even than 7
NOISE       equ 8       ;8 scratchy blow-up noise
NOISE_VOL   equ 4
PITFALL     equ 7       ;7 buzz
PITFALL_VOL equ 8
BASS        equ 6       ;6 faster (?) buzz
BASS_VOL    equ 9
                        ;5 annoying digitalish beep
SQUARE      equ 4       ;4 very similar to 5
SQUARE_VOL  equ 5
ENGINE      equ 3       ;3 wavey hollow-sounding buzz, weird
ENGINE_VOL  equ 13
RUMBLE      equ 2       ;2 clicky popish scratch noise
RUMBLE_VOL  equ 13
SAW         equ 1       ;1 smoother (?) fast buzz
SAW_VOL     equ 9
OFF         equ 0       ;0 soft pop noise, effectively no sound
OFF_VOL     equ 0




    ;AUDCX values for each control code
code_controls:
cOFF        equ 0
cNOISE      equ 1
cBUZZ       equ 2
cENGINE     equ 3
cLEAD       equ 4
cSQUARE     equ 5

    .byte OFF
    .byte NOISE
    .byte BUZZ
    .byte ENGINE
    .byte LEAD
    .byte SQUARE


    ;AUDVX values (adjusted up in play_sound)
code_volumes:
    .byte OFF_VOL
    .byte NOISE_VOL - 4
    .byte BUZZ_VOL - 4
    .byte ENGINE_VOL - 4
    .byte LEAD_VOL - 4
    .byte SQUARE_VOL - 4


    ;AUDFX values - each control code has
    ;a group of possible values (OFF doesn't matter)
code_freq_offsets equ *-1
    .byte noise_offset
    .byte buzz_offset
    .byte engine_offset
    .byte lead_offset
    .byte square_offset


frequency_base:

noise_offset equ *-frequency_base
    .byte 6,7,8                     ;basic drum sounds - mix with others
    .byte 30                        ;kick drum
    .byte 0                         ;high hat
buzz_offset equ *-frequency_base
    .byte 6                         ;basic drum sound
    .byte 30                        ;kick drum
engine_offset equ *-frequency_base
    .byte 12                        ;alternate drum sound

lead_offset equ *-frequency_base
    .byte 12,22,25,28,30            ;g4,a3,g3,f3,e3
square_offset equ *-frequency_base
    .byte 10,12,21,22,25,28,30      ;f6,d6,f5,e5,d5,c5,b4