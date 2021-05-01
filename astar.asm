	processor 6502
	include "vcs.h"
	include "macro.h"

    ;Use -Ivariants/PAL50, -Ivariants/PAL60, or -Ivariants/NTSC to select a
    ;version of variant.h to use.
    include "variant.h"

    ;\=========================================/
    ;|\vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv/|
    ;|>                                       <|
    ;|>>  -+--~~==<<( CONSTANTS )>>==~~--+-  <<|
    ;|>                                       <|
    ;|/^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\|
    ;/=========================================\

    IF PAL50
VBLANK_WAIT         equ 73
OVERSCAN_WAIT       equ 63
SCREEN_WAIT         equ 192
SOUND_STEP          equ 103
    ELSE
VBLANK_WAIT         equ 43
OVERSCAN_WAIT       equ 34
SCREEN_WAIT         equ 192
SOUND_STEP          equ 86
    ENDIF

LEVELS              equ 24
BLOCK_HEIGHT        equ 16      ;Don't change this!
BOARD_HEIGHT        equ 10

    IF PAL50 || PAL60
PLAYER_COLU         equ $2e     ;It's great that PAL machines don't have yellow...
    ELSE
PLAYER_COLU         equ $1e
    ENDIF

SPLASH_HEIGHT       equ 10
SPLASH_X0           equ 80-(3*8)+4
SPLASH_X1           equ 80-(2*8)+4

PLAYER_X_OFFSET     equ 20      ;0 on the map corresponds to this
                                ;in player (normal hmove) coordinates
MISSILE_X_OFFSET    equ 23      ;and this in missile coordinates

FADE_TOP            equ 43

DIR_NONE            equ -1
DIR_RIGHT           equ 0
DIR_UP              equ 1
DIR_LEFT            equ 2
DIR_DOWN            equ 3


    seg.u vars

    ;\======================================/
    ;|\vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv/|
    ;|>                                    <|
    ;|>>  -+--~~==<<( MEMORY )>>==~~--+-  <<|
    ;|>                                    <|
    ;|/^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\|
    ;/======================================\
    org  $80

pf1buf              .ds BOARD_HEIGHT - 1    ;the first and last rows are always the same
pf2buf              .ds BOARD_HEIGHT - 1
pf3buf              .ds BOARD_HEIGHT - 1
pf4buf              .ds BOARD_HEIGHT

player_gfx_lsbs     .ds BOARD_HEIGHT - 1
missile_en_lsbs     .ds BOARD_HEIGHT

prev_object         .ds 1       ;as current_object, but -1 if undo is unavailable
prev_x              .ds 1
prev_y              .ds 1
anim_base           .ds 1
anim_counter        .ds 1
moves               .ds 2
current_object      .ds 1       ;0 = player, 1 = missile
                                ;current_object duplicates as pickup_positions[0];
                                ;pickup 0 is always disabled, but it's still positioned,
                                ;so we need valid (if random) position values for it

pickup_positions    equ *-1
                    .ds BOARD_HEIGHT - 2    ;the edges don't matter (always disabled)
pickup_nusizes      .ds BOARD_HEIGHT        ;nusiz 5 means it's disabled

pickup_gfx_ptr      .ds 2
pickup_colu_ptr     .ds 2
pickup_gfx_lsb      .ds 1       ;backup of the ptr's lsb

missile_en_ptr      .ds 2
player_gfx_ptr      .ds 2

level_base_colu     .ds 1
block_top_colu      .ds 1
block_top2_colu     .ds 1

player_x            .ds 1       ;Coordinates of the bottom-left corner
missile_x           .ds 1       ;  The interleaving is important!
player_y            .ds 1       ;  Also y must directly follow x!
missile_y           .ds 1
direction           .ds 1

inpt4_bak           .ds 1
swchb_bak           .ds 1
level               .ds 1
state               .ds 1
par                 .ds 1

sound_index_0       .ds 1
sound_index_1       .ds 1
sound_step_timer    .ds 1
sound_step_index    .ds 1
sound_pattern_index .ds 1
sound_group_index_0 .ds 1
sound_group_index_1 .ds 1
vol_adjust          .ds 1

level_flags         .ds 4

gradient_ptr        .ds 2
kernel_addr         .ds 2
speech_addr         .ds 2

fade_counter        equ prev_x
advance_status      equ prev_y

    ;Temporary storage for general use by
    ;subroutines.  This is destroyed every
    ;frame when player_gfx_lsbs is updated.
scratch             equ player_gfx_lsbs
scratch0            equ scratch + 0
scratch1            equ scratch + 1
scratch2            equ scratch + 2
scratch3            equ scratch + 3
scratch4            equ scratch + 4
scratch5            equ scratch + 5
scratch6            equ scratch + 6
scratch7            equ scratch + 7

scratch8            equ missile_en_lsbs
scratch9            equ scratch8 + 1
scratch10           equ scratch8 + 2
scratch11           equ scratch8 + 3

	echo $100-*
	echo "bytes left"



    seg main

    ;\======================================/
    ;|\vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv/|
    ;|>                                    <|
    ;|>>  -+--~~==<<( BANK 0 )>>==~~--+-  <<|
    ;|>                                    <|
    ;|/^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\|
    ;/======================================\
    org  $f000

    include "kernel.asm"
    include "status_display.asm"
    include "state.asm"
    include "subroutines.asm"
    include "game.asm"
    include "map_loader.asm"
    include "sound.asm"
    include "memory.asm"
    include "sound/patterns.asm"
    include "sound/songs.asm"
    include "sound/codes.asm"
    include "speakjet.inc"          ;AtariVox drivers
    include "i2c.inc"
    I2C_SUBS scratch0

start:
    CLEAN_START
    jsr init_game


vblank: subroutine
    ;Vertical sync (I don't trust the VERTICAL_SYNC macro)
    lda #2
    sta WSYNC
    sta VSYNC
    sta WSYNC
    sta WSYNC
    lsr
    sta WSYNC
    sta VSYNC

    lda #VBLANK_WAIT
    sta TIM64T

    lda #<kernel
    sta kernel_addr
    lda #>kernel
    sta kernel_addr+1

    jsr process_state
    jsr kernel_setup

.wait:
    lda INTIM
    bne .wait

    sta WSYNC
    sta VBLANK

    jsr kernel_jump
    jsr show_status

overscan: subroutine
    ldx #2
    stx VBLANK

    lda #OVERSCAN_WAIT
    sta TIM64T

    jsr advance_sound   ;preserves x
    dex
    jsr play_sound
    dex
    jsr play_sound

.wait:
    lda INTIM
    bne .wait

    ;SPKOUT scratch0

    sta WSYNC
    beq vblank


    include "maps/map_base.asm"

map_base:
    include "maps/title.asm"
    include "maps/mapE1.asm"
    include "maps/mapE2.asm"
    include "maps/map01.asm"
    include "maps/map02.asm"
    include "maps/map03.asm"
    include "maps/map04.asm"
    include "maps/map05.asm"
    include "maps/map06.asm"
    include "maps/map07.asm"
    include "maps/map08.asm"
    include "maps/map09.asm"
    include "maps/map10.asm"
    include "maps/map11.asm"
    include "maps/map12.asm"
    include "maps/map13.asm"
    include "maps/map14.asm"
    include "maps/map15.asm"
    include "maps/map16.asm"
    include "maps/map17.asm"
    include "maps/map18.asm"
    include "maps/map19.asm"
    include "maps/map20.asm"
    include "maps/map21.asm"
    include "maps/map22.asm"
    include "maps/end.asm"
    include "maps/mapS1.asm"

pickup_gfx_table:
    .byte <pickup_gfx_cherries
    .byte <pickup_gfx_strawberry
    .byte <pickup_gfx_orange
    .byte <pickup_gfx_apple
    .byte <pickup_gfx_cone
    .byte <pickup_gfx_pretzel
    .byte <pickup_gfx_pear
    .byte <pickup_gfx_rose

    ;None of the following stuff is allowed to cross a page boundary,
    ;so the includes below are kind of sensitive...
    ;   gradient_table_x in gradients.asm
    ;   digit_gfx.asm
    ;   pickup_gfx.asm
    ;   pickup_colu.asm
    ;   player_gfx.asm
    ;   splash_gfx.asm     <--- this one maybe not

    org $fd03
    include "gradients.asm"
    include "digit_gfx.asm"
    .byte "Can'-Ka No Rey"

    org  $fe00
    include "pickup_gfx.asm"
    include "pickup_colu.asm"
    include "sound/groups.asm"

    include "player_gfx.asm"
    include "splash_gfx.asm"

pickup_colu_table:
    .byte <pickup_colu_cherries
    .byte <pickup_colu_strawberry
    .byte <pickup_colu_orange
    .byte <pickup_colu_apple
    .byte <pickup_colu_cone
    .byte <pickup_colu_pretzel
    .byte <pickup_colu_pear
    .byte <pickup_colu_rose

    org  $fffa
	.word start
	.word start
	.word start
