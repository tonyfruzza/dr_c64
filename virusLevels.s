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
;    adc #161
    adc #121
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
;    dex
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

    ; Look around, are there two viruses viruses next to this place
    txa
    pha ; virusIndex
    tya
    pha ; posision offset
    lda zpPtr2
    pha ; pos<
    lda zpPtr2+1
    pha ; pos>
    jsr isThisGoodPlaceForVirusType
    cmp #0
    beq printLevelWorth ; Too crowded

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


; Where x will be the new virus and 'o' are matching viruses
;

; BAD Scenarios
;     bit
; o ; 0
; o ; 1
; x ; 2
; ? ; 3
; ? ; 4

; = 3

; ?
; o
; x = bad 2
; o
; ?
; = 10

; ?
; ?
; x
; o = bad 3
; o
; = 24

; Bits are
; 43210
; oox?? = bad 4 = 24
; ?oxo? = bad 5 = 10
; ??xoo = bad 6 = 3



; a = 1 if there are not too many of the same types of viruses in the area given
isThisGoodPlaceForVirusType ; (ret>, ret<, pos>, pos<, offset, virusIndex)
    sty RETY
    stx RETX
    ldy #0
    pla
    sta ret1+1
    pla
    sta ret1
    pla
    sta zpPtr1+1
    pla
    sta zpPtr1
    pla
    sta istgpfvt_posOffset
    pla
    tax

    ; reset our counters
    lda #0
    sta istgpfvt_H_Count
    sta istgpfvt_V_Count

    ; Get actual location by adding offset
    clc
    lda zpPtr1
    adc istgpfvt_posOffset
    sta zpPtr1
    lda #0
    adc zpPtr1+1

; Start at 2 rows up and work your way down
    sec
    lda zpPtr1
    sbc #80
    sta zpPtr1
    lda zpPtr1+1
    sbc #0
    sta zpPtr1+1

    lda (zpPtr1), y
    cmp VIRUS_CHAR_LIST, x
    bne notVBit0
    lda istgpfvt_V_Count
ora #%00000001
    sta istgpfvt_V_Count
notVBit0
; One ontop of original
    ldy #40
    lda (zpPtr1),y
    cmp VIRUS_CHAR_LIST,x
    bne notVBit1
    lda istgpfvt_V_Count
ora #%00000010
    sta istgpfvt_V_Count
notVBit1
; One below of original
    ldy #120
    lda (zpPtr1),y

    cmp VIRUS_CHAR_LIST,x
    bne notVBit3
    lda istgpfvt_V_Count
ora #%00001000
    sta istgpfvt_V_Count
notVBit3
; Two below of original
    ldy #160
    lda (zpPtr1),y
    cmp VIRUS_CHAR_LIST,x
    bne notVBit4
    lda istgpfvt_V_Count
ora #%00010000
    sta istgpfvt_V_Count
notVBit4
; Finished loading istgpfvt_V_count, now to the Horizontal count
    ldy #78 ; two to the left of the original
    lda (zpPtr1),y
    cmp VIRUS_CHAR_LIST,x
    bne notHBit4
    lda istgpfvt_H_Count
ora #%00010000
    sta istgpfvt_H_Count
notHBit4
    iny ; y = #79 one left of org
    lda (zpPtr1),y
    cmp VIRUS_CHAR_LIST,x
    bne notHBit3
    lda istgpfvt_H_Count
ora #%00001000
    sta istgpfvt_H_Count
notHBit3
    iny
    iny
    lda (zpPtr1),y ; y = #81 one right of org
    cmp VIRUS_CHAR_LIST,x
    bne notHBit1
    lda istgpfvt_H_Count
ora #%00000010
    sta istgpfvt_H_Count
notHBit1
    iny
    lda (zpPtr1),y ; y = #82 two right of org
    cmp VIRUS_CHAR_LIST,x
    bne notHBit0
    lda istgpfvt_H_Count
ora #%00000001
    sta istgpfvt_H_Count
notHBit0

    lda ret1
    pha
    lda ret1+1
    pha


    ldy RETY
    ldx RETX
; Now that all is loaded up we can know what's around our piece and can decide to return
; 1 for okay, or 0 for bad
; Look down our V byte
    lda istgpfvt_V_Count
    ; mask off bits we don't care for this
and #%00000011
    cmp #3
    beq notGoodPlaceForVirus

    lda istgpfvt_V_Count
    ; mask off bits we don't care for this
and #%00001010
    cmp #10
    beq notGoodPlaceForVirus

    lda istgpfvt_V_Count
    ; mask off bits we don't care for this
and #%00011000
    cmp #24
    beq notGoodPlaceForVirus

; Look down our H byte
    lda istgpfvt_H_Count
and #%00000011
    cmp #3
    beq notGoodPlaceForVirus

    lda istgpfvt_H_Count
    ; mask off bits we don't care for this
and #%00001010
    cmp #10
    beq notGoodPlaceForVirus

    lda istgpfvt_H_Count
    ; mask off bits we don't care for this
and #%00011000
    cmp #24
    beq notGoodPlaceForVirus


    lda #1 ; It's good passed all tests
    rts
notGoodPlaceForVirus
    lda #0
    rts

istgpfvt_posOffset  .byte $00
istgpfvt_H_Count    .byte $00
istgpfvt_V_Count    .byte $00

