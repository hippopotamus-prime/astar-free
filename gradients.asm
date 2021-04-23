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