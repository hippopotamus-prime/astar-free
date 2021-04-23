
sound_silent    equ 0
sound_intro_0   equ 1
sound_intro_1   equ 2
sound_collect   equ 3
sound_over_par  equ 4
sound_finish_0  equ 5
sound_finish_1  equ 6
sound_win_0     equ 7
sound_win_1     equ 8

sound_offsets:
    .byte silent_offset
    .byte intro_0_offset
    .byte intro_1_offset
    .byte collect_offset
    .byte over_par_offset
    .byte finish_0_offset
    .byte finish_1_offset
    .byte win_0_offset
    .byte win_1_offset


sound_start:

silent_offset equ *-sound_start
    .byte 0, -1

intro_0_offset equ *-sound_start
    .byte 1, 2, 1, 3, -2

intro_1_offset equ *-sound_start
    .byte 0, 0, 4, 5, 4, 5, 6, 7, 6, 8, 4, 5, 6, 7, 0, 0, -2

collect_offset equ *-sound_start
    .byte 9, -1

over_par_offset equ *-sound_start
    .byte 10, -1

finish_0_offset equ *-sound_start
    .byte 12, 11, 12, 11, -1

finish_1_offset equ *-sound_start
    .byte 0, 13, 14, -1

win_0_offset equ *-sound_start
    .byte 12, 11, 12, 11, 12, 11, 12, 11, -1

win_1_offset equ *-sound_start
    .byte 0, 13, 14, 4, 5, 13, 14, -1