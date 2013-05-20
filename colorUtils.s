
RepaintCurrentColor
    ldy #0
    lda piece1
    sta zpPtr2
    lda piece1+1
    clc
    adc #$D4
    sta zpPtr2+1
    lda PRICOLOR
    sta (zpPtr2), y
    lda piece2
    sta zpPtr2
    lda piece2+1
    clc
    adc #$D4
    sta zpPtr2+1
    lda SECCOLOR
    sta (zpPtr2), y
    rts


ColorSwap
    lda PRICOLOR
    ldx SECCOLOR
    sta SECCOLOR
    stx PRICOLOR
    jsr RepaintCurrentColor
    rts


LandingPieceBright
    ldy #0
    lda piece1
    sta zpPtr2
    lda piece1+1
    clc
    adc #$D4
    sta zpPtr2+1
    lda #COLOR_WHITE
    sta (zpPtr2),y

    lda piece2
    sta zpPtr2
    lda piece2+1
    clc
    adc #$D4
    sta zpPtr2+1
    lda #COLOR_WHITE
    sta (zpPtr2),y

lda ORIENTATION
bne dropOnVertical
    lda #PILL_LEFT_D ; Left dropped piece
    sta (piece1),y
    lda #PILL_RIGHT_D ; Right dropped piece
    sta (piece2),y
    rts
dropOnVertical
    lda #PILL_TOP_D ; Left dropped piece
    sta (piece1),y
    lda #PILL_BOTTOM_D ; Right dropped piece
    sta (piece2),y
    rts

setPiecesBackToNormalAfterLanding
    lda ORIENTATION
    bne setBackVertical
    lda #PILL_LEFT
    sta (piece1),y
    lda #PILL_RIGHT
    sta (piece2),y
    rts
setBackVertical
    lda #PILL_TOP
    sta (piece1),y
    lda #PILL_BOTTOM
    sta (piece2),y
    rts

