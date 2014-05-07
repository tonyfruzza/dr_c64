
MoveLeftOne
    ldy #$00
    lda (piece1),y
    sta pSideTmp1
    lda (Piece2),y
    sta pSideTmp2
    lda ORIENTATION
    beq MoveLeftHorizontalOnly
    lda piece2
    pha
    lda piece2+1
    pha
    jsr CheckCollisionLeft
    bne leftMoveDoneNoSound
MoveLeftHorizontalOnly
    lda piece1
    pha
    lda piece1+1
    pha
    jsr CheckCollisionLeft
    bne leftMoveDoneNoSound ; ? 1

    ; Clear the current pos
    lda #CLEAR_CHAR
    sta (piece1), y

    ; decrement the pointer value by one
    sec
    lda piece1
    sbc #$01
    sta piece1
    lda piece1+1 ; subtract 0 and any borrow generated above
    sbc #$00
    sta piece1+1
    lda pSideTmp1
    sta (piece1), y
    ; Second
    lda #CLEAR_CHAR
    sta (piece2), y

    ; decrement the pointer value by one
    sec
    lda piece2
    sbc #$01
    sta piece2
    lda piece2+1 ; subtract 0 and any borrow generated above
    sbc #$00
    sta piece2+1
    lda pSideTmp2
    sta (piece2), y

    jsr RepaintCurrentColor
leftMoveDone
    lda #<SOUND_HORIZONTAL
    ldy #>SOUND_HORIZONTAL
    ldx #14
    jsr songStartAdress+6
    pla
    pla
leftMoveDoneNoSound
    rts