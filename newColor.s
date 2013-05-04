
NewColors
    jmp nc_start
    theNewColor1    .byte $00
    theNewColor2    .byte $00
nc_start
    jsr get_random_number
    and #3
    tay
    lda colors, y
    sta theNewColor1
    jsr get_random_number
    and #3
    tay
    beq dontDecY
    dey
    dontDecY
    lda colors, y
    sta theNewColor2
ChangeColor
    ldy #00
    lda piece1_next
    sta zpPtr2
    lda piece1_next+1
    sta zpPtr2+1
    lda #$D4
    clc
    adc zpPtr2+1
    sta zpPtr2+1

    ; Cache current color
    lda (zpPtr2),y
    and #$0f
    sta NextPriC

    lda theNewColor1
    sta (zpPtr2), y
    lda piece2_next
    sta zpPtr2
    lda piece2_next+1
    sta zpPtr2+1
    lda #$D4
    clc
    adc zpPtr2+1
    sta zpPtr2+1
    ; cahce current color
    lda (zpPtr2),y
    and #$0f
    sta NextSecC
    lda theNewColor2
    sta (zpPtr2), y
SwapInOldColor
    lda piece1
    sta zpPtr2
    lda piece1+1
    clc
    adc #$D4
    sta zpPtr2+1

    lda NextPriC
    sta (zpPtr2),y
    sta PRICOLOR

    lda piece2
    sta zpPtr2
    lda piece2+1
    clc
    adc #$D4
    sta zpPtr2+1
    lda NextSecC
    sta (zpPtr2),y
    sta SECCOLOR
    rts
