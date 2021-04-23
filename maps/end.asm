    .byte %00000000,%00000000
    .byte %00000011,%11000000
    .byte %00000100,%00100000
    .byte %00000000,%00000000
    .byte %00000000,%00000000
    .byte %00000010,%01000000
    .byte %00000010,%01000000
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

    ;The par score should be high here so the
    ;status is highlighted on the final screen
    .byte 255