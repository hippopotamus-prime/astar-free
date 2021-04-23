pickup_colu_base:

pickup_colu_pretzel equ *-4
    IF PAL50 || PAL60
    .byte $26
    .byte $28
    .byte $26
    .byte $2a
    .byte $26
    .byte $28
    .byte $26
    .byte $2a
    .byte $28
    .byte $26
    ELSE
    .byte $f6
    .byte $f8
    .byte $f6
    .byte $fa
    .byte $f6
    .byte $f8
    .byte $f6
    .byte $fa
    .byte $f8
    .byte $f6
    ENDIF

pickup_colu_pear equ *-2
    IF PAL50 || PAL60
    .byte $36
    .byte $38
    .byte $3c
    .byte $3e
    .byte $3e
    .byte $3c
    .byte $3a
    .byte $3a
    .byte $3a
    .byte $38
    .byte $24
    .byte $26
    ELSE
    .byte $e6
    .byte $e8
    .byte $ec
    .byte $ee
    .byte $ee
    .byte $ec
    .byte $ea
    .byte $ea
    .byte $ea
    .byte $e8
    .byte $f4
    .byte $f6
    ENDIF

pickup_colu_rose equ *-2
    IF PAL50 || PAL60
    .byte $38
    .byte $3a
    .byte $38
    .byte $36
    .byte $38
    .byte $38
    .byte $36
    .byte $6a
    .byte $6a
    .byte $6c
    .byte $6e
    .byte $6c
    ELSE
    .byte $d8
    .byte $da
    .byte $d8
    .byte $d6
    .byte $d8
    .byte $d8
    .byte $d6
    .byte $4a
    .byte $4a
    .byte $4c
    .byte $4e
    .byte $4c
    ENDIF

pickup_colu_cone equ *-3
    IF PAL50 || PAL60
    .byte $26
    .byte $28
    .byte $26
    .byte $2a
    .byte $28
    .byte $26
    .byte $0e
    .byte $0e
    .byte $0e
    .byte $0e
    .byte $0e
    ELSE
    .byte $f6
    .byte $f8
    .byte $f6
    .byte $fa
    .byte $f8
    .byte $f6
    .byte $0e
    .byte $0e
    .byte $0e
    .byte $0e
    .byte $0e
    ENDIF

pickup_colu_apple equ *-4
    IF PAL50 || PAL60
    .byte $36
    .byte $3a
    .byte $3c
    .byte $3c
    .byte $3e
    .byte $3e
    .byte $3c
    .byte $38
    .byte $24
    .byte $26
    ELSE
    .byte $d6
    .byte $da
    .byte $dc
    .byte $dc
    .byte $de
    .byte $de
    .byte $dc
    .byte $d8
    .byte $f4
    .byte $f6
    ENDIF

pickup_colu_strawberry equ *-3
    IF PAL50 || PAL60
    .byte $66
    .byte $66
    .byte $68
    .byte $68
    .byte $6a
    .byte $6c
    .byte $6a
    .byte $66
    .byte $54
    .byte $56
    .byte $58
    ELSE
    .byte $46
    .byte $46
    .byte $48
    .byte $48
    .byte $4a
    .byte $4c
    .byte $4a
    .byte $46
    .byte $c4
    .byte $c6
    .byte $c8
    ENDIF

pickup_colu_cherries equ *-2
    IF PAL50 || PAL60
    .byte $64
    .byte $66
    .byte $68
    .byte $6a
    .byte $6a
    .byte $68
    .byte $66
    .byte $54
    .byte $56
    .byte $58
    .byte $5a
    .byte $56
    ELSE
    .byte $44
    .byte $46
    .byte $48
    .byte $4a
    .byte $4a
    .byte $48
    .byte $46
    .byte $c4
    .byte $c6
    .byte $c8
    .byte $ca
    .byte $c6
    ENDIF

pickup_colu_orange equ *-4
    ;Neither of these is a good orange...
    IF PAL50 || PAL60
    .byte $46
    .byte $48
    .byte $4a
    .byte $4c
    .byte $4c
    .byte $4e
    .byte $4e
    .byte $4c
    .byte $4a
    .byte $48
    ELSE
    .byte $36
    .byte $38
    .byte $3a
    .byte $3c
    .byte $3c
    .byte $3e
    .byte $3e
    .byte $3c
    .byte $3a
    .byte $38
    ENDIF