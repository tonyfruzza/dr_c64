
MoveRightOne
    ldy #$00 ; offset from current char pos
    lda (piece1),y
    sta pSideTmp1
    lda (piece2),y
    sta pSideTmp2
    lda ORIENTATION
    beq MoveRightHorizontalOnly
    lda piece1
    pha
    lda piece1+1
    pha
    jsr CheckCollisionRight
    bne rightMoveDoneNoSound
MoveRightHorizontalOnly
    lda piece2
    pha
    lda piece2+1
    pha
    jsr CheckCollisionRight
    bne rightMoveDoneNoSound

    ; Secondary piece
    ldy #$00
    lda #CLEAR_CHAR
    sta (piece2), y
    clc
    lda #$01
    adc piece2
    sta piece2
    lda #$00 ; Add any roll over to the high byte
    adc piece2+1
    sta piece2+1
    lda pSideTmp2
    sta (piece2), y
    ; clear pos
    lda #CLEAR_CHAR
    sta (piece1), y
    ; increment the pointer value by one
    clc
    lda #$01
    adc piece1
    sta piece1
    lda #$00 ; Add any roll over to the high byte
    adc piece1+1
    sta piece1+1
    lda pSideTmp1
    sta (piece1), y
    jsr RepaintCurrentColor
rightMoveDone
    lda #<SOUND_HORIZONTAL
    ldy #>SOUND_HORIZONTAL
    ldx #14
    jsr songStartAdress+6
    pla
    pla
rightMoveDoneNoSound
    rts
