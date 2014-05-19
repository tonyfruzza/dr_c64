
; Clears both vertical and horizontal entries in their respecitve
; arrays if there are more than 4 entries in one of them.
clearPiecesInArray ; void ()
    ; see if there are more than 3 values in here
    lda varrayIndex
    cmp #4
    bcc finishedClearingVJmp ; >= 4
    ldx #$00 ; varray indexing * 2
    stx tmp
    jmp clearingLoop
finishedClearingVJmp
    jmp ClearH
clearingLoop
    lda varray, x
    sta zpPtr4
    sta cpia_pieceTmp
    lda varray+1, x
    sta zpPtr4+1
    sta cpia_pieceTmp+1
    inx
    inx
    inc tmp

; Look around to convert surounding pieces to independent cells if we can
cl_whatsToTheRight
    ldy #$01
    lda (zpPtr4),y
    cmp #PILL_RIGHT
    bne cl_whatsOnBottom
    lda #PILL_SIDE
    sta (zpPtr4),y
cl_whatsOnBottom
    ; What's below, y = 40
    ldy #40
    lda (zpPtr4),y
    cmp #PILL_BOTTOM
    bne cl_whatsOnTop
    lda #PILL_SIDE
    sta (zpPtr4),y
cl_whatsOnTop
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
    bne cl_whatsToTheLeft
    lda #PILL_SIDE
    sta (zpPtr4),y
cl_whatsToTheLeft
    ; we are now on top of the original piece, and want to look
    ; to the bottom one and to the left, so +39 y offset will do
    ldy #39
    lda (zpPtr4),y
    cmp #PILL_LEFT
    bne cl_SideManipulationComplete
    ; It was a left piece, let's convert it to a PILL_SIDE
    lda #PILL_SIDE
    sta (zpPtr4),y
; Finished looking around
cl_SideManipulationComplete
    ldy #$00
    ; restore zpPtr4
    lda cpia_pieceTmp
    sta zpPtr4
    lda cpia_pieceTmp+1
    sta zpPtr4+1

    ; Animation for clearning of pieces, one piece at a time

    ; Look for viruses for total Vertical
    lda (zpPtr4), y
    cmp #VIRUS_ONE
    beq cl_itIsAVirus
    cmp #VIRUS_TWO
    beq cl_itIsAVirus
    cmp #VIRUS_THREE
    bne cl_storeValue ; not a virus
    cl_itIsAVirus
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
cl_storeValue
    lda #PILL_CLEAR_1
    sta (zpPtr4), y
    dey ; set it back to 0
    lda tmp
    cmp varrayIndex
    beq cl_noclearingLoop
    jmp clearingLoop
cl_noclearingLoop
finishedClearingV
    jmp ClearH

cpia_pieceTmp   .byte $00, $00