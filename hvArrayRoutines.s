
; Push 16 bit value onto varray
pushOntoVarray ; void (ret2, ret1, addy2, addy1)
    lda varrayIndex
    asl ; multiply * 2
    tax ; copy to x
    pla
    sta ret1+1
    pla
    sta ret1
    pla
    sta varray+1, x
    pla
    sta varray, x
    inc varrayIndex
    ; Return to where we came from
    lda ret1
    pha
    lda ret1+1
    pha
    rts

pushOntoHarray ; void (ret2, ret1, addy2, addy1)
    lda harrayIndex
    asl ; multiply * 2
    tax ; copy to x
    pla
    sta ret1+1
    pla
    sta ret1
    pla
    sta harray+1, x
    pla
    sta harray, x
    inc harrayIndex
    ; Return to where we came from
    lda ret1
    pha
    lda ret1+1
    pha
    rts




; Zeros out the vertical clear array
initClearArrays
            ldx #21 ; 10 x 2 bytes is how large it can be
            lda #$00
            sta varrayIndex
            sta harrayIndex
initClearArrayLoop
            sta varray, x
            sta harray, x
            dex
            beq clearArraysDone ; check for x != 0
            jmp initClearArrayLoop
clearArraysDone
            rts

varray      .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
varrayIndex .byte $00
harray      .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
harrayIndex .byte $00
posOffsetXY .byte $00, $00 ; Shared with V clearing routine