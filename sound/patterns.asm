    MAC STEP
.code   set {1}
.freq   set {2}
.vol    set {3}

    .byte .freq * 32 + (.vol + 2) * 8 + .code

    ENDM


    MAC REST

    STEP cOFF, 0, -2

    ENDM



pattern_start:

pSILENT equ [*-pattern_start]/8
    REST
    REST
    REST
    REST
    REST
    REST
    REST
    REST

pBUZZ equ [*-pattern_start]/8
    REST
    REST
    REST
    REST
    STEP cNOISE, 1, -1
    STEP cNOISE, 1, 0
    STEP cNOISE, 0, 0
    STEP cBUZZ, 0, 1

pENGINE equ [*-pattern_start]/8
    REST
    REST
    REST
    REST
    STEP cNOISE, 1, -1
    STEP cNOISE, 1, 0
    STEP cNOISE, 2, 0
    STEP cENGINE, 0, 1

pKICK equ [*-pattern_start]/8
    REST
    REST
    REST
    REST
    STEP cNOISE, 3, 0
    STEP cNOISE, 3, 0
    STEP cNOISE, 3, 1
    STEP cBUZZ, 1, 1

pHATENG equ [*-pattern_start]/8
    STEP cNOISE, 1, -1
    STEP cNOISE, 1, 0
    STEP cNOISE, 2, 0
    STEP cENGINE, 0, 1
    REST
    REST
    STEP cNOISE, 2, -1
    STEP cNOISE, 4, 1

pLEADga equ [*-pattern_start]/8
    REST
    STEP cLEAD, 1, -1
    STEP cLEAD, 1, 0
    STEP cLEAD, 1, 1
    REST
    STEP cLEAD, 2, -1
    STEP cLEAD, 2, 0
    STEP cLEAD, 2, 1

pSQUAREbc equ [*-pattern_start]/8
    REST
    STEP cSQUARE, 5, -1
    STEP cSQUARE, 5, 0
    STEP cSQUARE, 5, 1
    REST
    STEP cSQUARE, 6, -1
    STEP cSQUARE, 6, 0
    STEP cSQUARE, 6, 1

pSQUAREde equ [*-pattern_start]/8
    REST
    STEP cSQUARE, 3, -1
    STEP cSQUARE, 3, 0
    STEP cSQUARE, 3, 1
    REST
    STEP cSQUARE, 4, -1
    STEP cSQUARE, 4, 0
    STEP cSQUARE, 4, 1

pSQUAREd equ [*-pattern_start]/8
    REST
    REST
    REST
    REST
    STEP cSQUARE, 4, -1
    STEP cSQUARE, 4, -1
    STEP cSQUARE, 4, 0
    STEP cSQUARE, 4, 1

pSQUAREe equ [*-pattern_start]/8
    REST
    REST
    REST
    REST
    STEP cSQUARE, 3, -1
    STEP cSQUARE, 3, -1
    STEP cSQUARE, 3, 0
    STEP cSQUARE, 3, 1

pSQUAREb equ [*-pattern_start]/8
    REST
    REST
    REST
    REST
    STEP cSQUARE, 6, -1
    STEP cSQUARE, 6, -1
    STEP cSQUARE, 6, 0
    STEP cSQUARE, 6, 1

pSQUAREc equ [*-pattern_start]/8
    REST
    REST
    REST
    REST
    STEP cSQUARE, 5, -1
    STEP cSQUARE, 5, -1
    STEP cSQUARE, 5, 0
    STEP cSQUARE, 5, 1

pLEADg equ [*-pattern_start]/8
    REST
    REST
    REST
    REST
    STEP cLEAD, 2, -1
    STEP cLEAD, 2, -1
    STEP cLEAD, 2, 0
    STEP cLEAD, 2, 1

pLEADa equ [*-pattern_start]/8
    REST
    REST
    REST
    REST
    STEP cLEAD, 1, -1
    STEP cLEAD, 1, -1
    STEP cLEAD, 1, 0
    STEP cLEAD, 1, 1

pLEADe equ [*-pattern_start]/8
    REST
    REST
    STEP cLEAD, 3, -1
    STEP cLEAD, 3, -1
    STEP cLEAD, 3, 0
    STEP cLEAD, 3, 0
    STEP cLEAD, 3, 1
    STEP cLEAD, 3, 1