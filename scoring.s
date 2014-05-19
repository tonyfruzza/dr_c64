; Print virus count
UpdateVirusCount
    ldy #0
    lda #$6c
    sta zpPtr2
    lda #$05
    sta zpPtr2+1

    lda #$30
    sta (zpPtr2),y
    iny
    ldx p1VirusCount
    txa
    and #$f0
    lsr ; Shift over 4 times
    lsr
    lsr
    lsr
    ora #$30
    sta (zpPtr2),y
    iny
    txa
    and #$0f
    ora #$30
    sta (zpPtr2),y
    rts


; score is made up of 4 bytes of decimal numbers
updateScore
    ; See if there is any difference between the last virus count and the new one
    lda p1VirusCountBinLast
    cmp p1VirusCountBinNew
    bne us_continue ; There was something cleared
    jmp printCurrentScoreWithNoChange
us_continue
    sec
    sbc p1VirusCountBinNew
    tax ; x contains the difference

    ; Make the new count the current one now
    lda p1VirusCountBinNew
    sta p1VirusCountBinLast

; Add the points up
scoreLoop
    lda VIRUS_MUL_1
    sta scoreMultiplierTmp
    lda VIRUS_MUL_1+1
    sta scoreMultiplierTmp+1
    lda #0
    sta scoreMultiplierTmp+2
    sta scoreMultiplierTmp+3
    stx tmp ; store how many times to shift to the left

multiplierLoop
    dec tmp
    beq multiplierDone
    clc
    rol scoreMultiplierTmp
    rol scoreMultiplierTmp+1
    rol scoreMultiplierTmp+2
    rol scoreMultiplierTmp+3
    jmp multiplierLoop

multiplierDone
    clc
    lda P1_SCORE_B
    adc scoreMultiplierTmp
    sta P1_SCORE_B
    sta P1_SCORE_B_COPY

    lda P1_SCORE_B+1
    adc scoreMultiplierTmp+1
    sta P1_SCORE_B+1
    sta P1_SCORE_B_COPY+1

    lda P1_SCORE_B+2
    adc scoreMultiplierTmp+2
    sta P1_SCORE_B+2
    sta P1_SCORE_B_COPY+2

    lda P1_SCORE_B+3
    adc scoreMultiplierTmp+3
    sta P1_SCORE_B+3
    sta P1_SCORE_B_COPY+3

    dex
    beq printCurrentScore
    jmp scoreLoop


printCurrentScoreWithNoChange
    lda P1_SCORE_B
    sta P1_SCORE_B_COPY
    lda P1_SCORE_B+1
    sta P1_SCORE_B_COPY+1
    lda P1_SCORE_B+2
    sta P1_SCORE_B_COPY+2
    lda P1_SCORE_B+3
    sta P1_SCORE_B_COPY+3
printCurrentScore
    jsr convertP1ScoreToDecimal
    ldy #$00
    lda #$34
    sta zpPtr2
    lda #$05
    sta zpPtr2+1
    ldx #6 ; ldx #8 for two more numbers
l2
    lda P1_SCORE,x
    ora #$30
    sta (zpPtr2),y
    iny
    dex
    bpl l2
scoreUpdateComplete
    rts

scoreMultiplierTmp .byte $00, $00, $00, $00
carryWasSet        .byte $00


