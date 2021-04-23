    MAC PICKUP
    .byte {1} + [{2}*16]
    ENDM

    MAC COORD
    .byte {1} + {2}*16
    ENDM

map_colors:
    IF PAL50 || PAL60
    .byte $d0 + 0
    .byte $20 + 0
    .byte $40 + 1
    .byte $60 + 2
    .byte $70 + 3
    .byte $50 + 4
    .byte $80 + 5
    .byte $30 + 6
    .byte $a0 + 7
    .byte $50 + 0
    .byte $70 + 1
    .byte $b0 + 2
    .byte $c0 + 3
    .byte $90 + 4
    .byte $20 + 5
    .byte $40 + 6
    .byte $30 + 7
    .byte $60 + 0
    .byte $b0 + 1
    .byte $50 + 2
    .byte $90 + 3
    .byte $80 + 4
    .byte $40 + 5
    .byte $c0 + 6
    .byte $20 + 7
    .byte $d0 + 0
    .byte $00 + 7
    ELSE
    .byte $80 + 0
    .byte $10 + 0
    .byte $20 + 1
    .byte $e0 + 2
    .byte $c0 + 3
    .byte $40 + 4
    .byte $50 + 5
    .byte $f0 + 6
    .byte $30 + 7
    .byte $d0 + 0
    .byte $b0 + 1
    .byte $a0 + 2
    .byte $60 + 3
    .byte $90 + 4
    .byte $10 + 5
    .byte $e0 + 6
    .byte $40 + 7
    .byte $f0 + 0
    .byte $70 + 1
    .byte $20 + 2
    .byte $b0 + 3
    .byte $30 + 4
    .byte $a0 + 5
    .byte $c0 + 6
    .byte $10 + 7
    .byte $80 + 0
    .byte $00 + 7
    ENDIF