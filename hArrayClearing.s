
ClearH
    ;
    ; Clear H array if we need to
    lda harrayIndex
    cmp #4
    bcc ClearHFinished ; Is it less than 4?
    ldx #$00 ; h array indexing * 2
    ldy #$00 ; zero page indexing, leave as 0
    sty tmp  ; h array indexing by 1
    jmp hclearingLoop
ClearHFinished
    rts
hclearingLoop
    lda harray, x
    sta zpPtr4
    sta cpia_pieceTmp
    lda harray+1, x
    sta zpPtr4+1
    sta cpia_pieceTmp+1
    inx
    inx
    inc tmp

; Look all around to see if we need to convert
; some sides into cell pieces while doing our Horizontal clearing
clh_whatsToTheRight
    ldy #$01
    lda (zpPtr4),y
    cmp #PILL_RIGHT
    bne clh_whatsOnBottom
    lda #PILL_SIDE
    sta (zpPtr4),y
clh_whatsOnBottom
    ; What's below, y = 40
    ldy #40
    lda (zpPtr4),y
    cmp #PILL_BOTTOM
    bne clh_whatsOnTop
    lda #PILL_SIDE
    sta (zpPtr4),y
clh_whatsOnTop
    ldy #00
    sec
    lda zpPtr4
    sbc #40
    sta zpPtr4
    lda zpPtr4+1
    sbc #00
    sta zpPtr4+1
    lda (zpPtr4),y
    cmp #PILL_TOP
    bne clh_whatsToTheLeft
    lda #PILL_SIDE
    sta (zpPtr4),y
clh_whatsToTheLeft
    ; we are now on top of the original piece, and want to look
    ; to the bottom one and to the left, so +39 y offset will do
    ldy #39
    lda (zpPtr4),y
    cmp #PILL_LEFT
    bne clh_SideManipulationComplete
    ; It was a left piece, let's convert it to a PILL_SIDE
    lda #PILL_SIDE
    sta (zpPtr4),y

; Finished looking around
clh_SideManipulationComplete
    ldy #$00
    lda cpia_pieceTmp
    sta zpPtr4
    lda cpia_pieceTmp+1
    sta zpPtr4+1
    ; Clearing a piece for this pill drop
    lda (zpPtr4), y
    cmp #VIRUS_ONE
    beq cl_itIsAVirus_2
    cmp #VIRUS_TWO
    beq cl_itIsAVirus_2
    cmp #VIRUS_THREE
    bne cl_storeValue_2 ; not a virus
    cl_itIsAVirus_2
    stx posOffsetXY
    sty posOffsetXY+1
    ; Play noise
    lda #<SOUND_CLEAR
    ldy #>SOUND_CLEAR
    ldx #14 ; channel 3
    jsr songStartAdress+6
    ldx posOffsetXY
    ldy posOffsetXY+1

    inc virusesClearedForPopUpScore
    lda zpPtr4
    sta placeScoreHere
    lda zpPtr4+1
    sta placeScoreHere+1
    jsr SetSpriteBasedOnCharPos
cl_storeValue_2
    lda #PILL_CLEAR_1
    sta (zpPtr4), y
    lda tmp
    cmp harrayIndex
    beq finishedClearingH
    jmp hclearingLoop
finishedClearingH
    rts

