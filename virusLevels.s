last_virus_used     .byte $00 ; keep track betwen 0 - 2
created_viruses     .byte $00
viruses_to_print    .byte $00


putVirusesOnTheField ;
    lda currentLvl
    clc
    adc #1
    pha
    lda #4 ; number of viruses to have per lvl
    pha
    jsr eightBitMul
    lda tmp1 ; low byte of multiplication result
    sta viruses_to_print
    dec viruses_to_print


printLevelWorth
    lda #$00 ; Our counter
    sta  created_viruses
    tax
    tay ; zp indexing
    sta tmp

    clc
    lda #OnePGameFieldLocLow ; Low byte start location
    adc #161
    sta zpPtr2
    lda #OnePGameFieldLocHigh ; High byte start location
    adc #0
    sta zpPtr2+1

    jsr get_random_number
    and #15
    tax
    dex
    dex
    dex
    dex
    stx tmp2

goDownLinesLoop
    lda tmp
    cmp tmp2
    beq foundLine

    clc
    lda zpPtr2
    adc #40
    sta zpPtr2

    lda zpPtr2+1
    adc #0
    sta zpPtr2+1
    inc tmp
    jmp goDownLinesLoop
foundLine
    jsr get_random_number
    and #7
    tay

    ldx last_virus_used
useVirus

    lda (zpPtr2),y
    cmp #' '
    bne printLevelWorth ; Already something there go back before dec viruses_to_print
    
    lda VIRUS_CHAR_LIST, x
    sta (zpPtr2),y
    clc
    lda zpPtr2+1
    adc #$D4
    sta zpPtr2+1
    lda colors,x
    sta (zpPtr2),y

    lda viruses_to_print
    beq donePrintingViruses
    dec viruses_to_print

    inc last_virus_used
    ldx last_virus_used
    cpx #3
    bcc doNotResetVirusType
    lda #0
    sta last_virus_used
doNotResetVirusType
    jmp printLevelWorth
donePrintingViruses
    rts

