    ;A song is a series of groups, and a group is made
    ;of four patterns.  A pattern is eight steps, and
    ;a step indexes a control code, volume, and frequency.

    ;The sound engine supports 32 patterns and 64 groups.



    ;---- Set the current song ----
    ;input:  x = sound index 0
    ;        y = sound index 1
    ;output:  sound_index_x is set
    ;         other sound memory is cleared
    ;destroys: a
set_sound: subroutine
    stx sound_index_0
    sty sound_index_1
    lda #0
    sta sound_step_timer
    sta sound_group_index_0
    sta sound_group_index_1
    lda #7
    sta sound_step_index
    lsr ;lda #3
    sta sound_pattern_index
    rts



    ;---- Advance songs ----
    ;Note that this advances songs on both channels,
    ;so only call it once.
    ;input:  sound_step_delta set (higher = faster)
    ;output:  sound_step_timer, step_index, pattern_index,
    ;         group_index updated
    ;destroys: a
advance_sound: subroutine
    ;We'll play the current step for some amount of time
    ;determined by sound_step_delta...
    lda sound_step_timer
    clc
    adc #SOUND_STEP
    sta sound_step_timer
    bcc .end

        ;If the step is done, advance to the next one...
        dec sound_step_index
        bpl .end

            ;But if that was the last step, go to the
            ;first one in the next pattern...
            lda #7
            sta sound_step_index
            dec sound_pattern_index
            bpl .end

                ;And if that was the last pattern, go
                ;to the first one in the next group.
                lda #3
                sta sound_pattern_index

                ;Songs on both channels advance at the same
                ;rate, but they can have special commands in
                ;different places (see below).  Hence the
                ;group indices must be separate.
                inc sound_group_index_0
                inc sound_group_index_1
.end:
    rts



    ;---- Play the current note in a song ----
    ;input:  x = channel
    ;output:  AUDXX registers updated
    ;destroys: a, y
play_sound: subroutine
    ldy sound_index_0,x
    lda sound_offsets,y
    clc
    adc sound_group_index_0,x
    tay
    lda sound_start,y
    bpl .normal_group

        ;Now if the current group is negative, it's
        ;actually a special command.

        tay
        iny
        beq .stop
        iny

.loop:
    ;-2 means loop back to group index 0
    sty sound_group_index_0,x
    beq play_sound

.stop:
    ;-1 means stop the song.
    tya
    sta sound_index_0,x
    sta sound_group_index_0,x
    ;group 0 is silent, so use that...

.normal_group:
    ;Now we'll load the current pattern out
    ;of the group data...
    asl
    asl
    adc sound_pattern_index
    tay
    lda group_start,y

    ;And the current step out of the pattern data...
    asl
    asl
    asl
    adc sound_step_index
    tay
    lda pattern_start,y

    ;The first three bits of a step are a control
    ;code.  These directly index AUDCX values stored
    ;in a table.
    pha
    and #%00000111
    tay
    lda code_controls,y
    sta AUDC0,x
    pla

    ;The next two bits are volume adjustment (we'll
    ;multiply it by two).  Each control code has a
    ;pre-set volume that's stored in another table,
    ;and we'll add to that value.
    lsr
    lsr
    pha
    and #%00000110
    clc
    adc code_volumes,y
    adc vol_adjust
    bpl .vol_ok
        lda #0
.vol_ok:
    sta AUDV0,x
    pla

    ;The last three bits are the pitch.  Each control
    ;code has only a few pitches that work well, and
    ;these are tabulated for every code.
    lsr
    lsr
    lsr
    clc
    adc code_freq_offsets,y
    tay
    lda frequency_base,y
    sta AUDF0,x

    rts