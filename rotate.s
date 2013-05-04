
rotate
    ; Cleared printed pill first
    ldy #$00
    lda #" "
    sta (piece1), y
    sta (piece2), y
    lda ORIENTATION
    sta ORIENTATION_BEFORE ; cache to see if it changed at the end to make sound
    beq rotateUnder
    jmp rotateToLeft
rotateUnder
    ; put piece1 where piece2 was, then move piece 1 down one row
    ; Pieces will be vertical after this move
    ; Is there something above and below p1, then we could rotate over to the right perhaps?
    sec
    lda piece1
    sbc #40
    sta zpPtr2
    lda piece1+1
    sbc #0
    sta zpPtr2+1
    lda (zpPtr2), y
    cmp #' '
    beq rotateHasRoom
    ; Estabished there is no room above
    iny
    lda (zpPtr2),y
    cmp #' '
    bne CantDoRotateToLeftVertical
    ; There is room to the top left
    clc
    lda zpPtr2
    adc #1
    sta zpPtr2
    sta piece1
    lda zpPtr2+1
    adc #0
    ;sta zpPtr2+1
    sta piece1+1
    inc ORIENTATION
    jmp RotateFinished
CantDoRotateToLeftVertical
    ; Is there something above that would get in the way of this rotate?
    ; If there is nothing below then we can rotate it down, rather than up as usual
    ; but we have to manually move it down
;    sec
;    lda piece1
;    sbc #40
;    sta zpPtr2
;    lda piece1+1
;    sbc #0
;    sta zpPtr2+1
;    lda (zpPtr2), y
;    cmp #' '
;    beq rotateHasRoom
    ; Okay, no room above, but what's below?
    clc
    lda piece1
    adc #40
    sta zpPtr2
    lda piece1+1
    adc #0
    sta zpPtr2+1
    lda (zpPtr2),y
    cmp #' '
beq RotateCanContinue
jmp RotateFinishedNoSound
RotateCanContinue
;    bne RotateFinishedNoSound ; No room above or below, eject!
    ; put the piece2 under piece1 and inc ORIENTATION
    clc
    lda piece1
    adc #40
    sta piece2
    lda piece1+1
    adc #0
    sta piece2+1
    inc ORIENTATION
    jmp RotateFinished

    ; Clear to rotate
rotateHasRoom
    inc ORIENTATION
    lda piece1
    sta piece2
    sec
    sbc #40
    sta piece1
    lda piece1+1
    sta piece2+1
    sbc #00
    sta piece1+1
    jmp RotateFinished
rotateToLeft
    ; Just put them back horizontally and swap the colors
    ; piece one is on top, return it to the bottom, and move
    ; piece2 to the right
    ; Piece2 is currently where we want 1 at
    ; We'll have to see if this is possible though since there needs to be space to the right of current piece2

    ; If there is collision to right, but none to left then shift to the left
    ldy #1
    lda (piece2), y
    ldy #0
    cmp #' '
    beq commitRotateToHorizontal ; We're okay just rotate as normal
    ; There is something on the right !

    ; What's to the left of the bottom?
    lda piece2
    pha
    lda piece2+1
    pha
    jsr CheckCollisionLeft ; Is there room to the left?
beq RotateCanContinue2
jmp RotateFinishedNoSound
RotateCanContinue2
;    bne RotateFinishedNoSound ; there was no room
    ; Nothing to the left of the bottom, but what about the top?
    ; Well there could be something to the top, which would fail a move left
    ; in which case we have to manually rotate and move left so as to not
    ; clear out the piece to the right
    ; 1 converted to: <- 1 2
    ; 2
    lda #' '
    sta (piece1),y
    lda piece2
    sec
    sbc #1
    sta piece1
    lda piece2+1
    sbc #0
    sta piece1+1
    jsr ColorSwap
    lda #00
    sta ORIENTATION
    jmp RotateFinished
commitRotateToHorizontal
    clc
    lda piece2
    sta piece1
    adc #$01
    sta piece2
    lda piece2+1
    sta piece1+1
    adc #$00
    sta piece2+1
    jsr ColorSwap
    lda #$00
    sta ORIENTATION
RotateFinished
    ; Play noise
    lda #<SOUND_ROTATE
    ldy #>SOUND_ROTATE
    ldx #14 ; channel 3
    jsr songStartAdress+6
    ; Done with sound
RotateFinishedNoSound
    jsr RepaintCurrentColor
    ; print the result
    ldy #$00
    lda ORIENTATION
    beq RotateEndHorizontal
    lda #PILL_TOP
    sta (piece1),y
    lda #PILL_BOTTOM
    sta (piece2),y
    rts
RotateEndHorizontal
    lda #PILL_LEFT
    sta (piece1),y
    lda #PILL_RIGHT
    sta (piece2),y
    rts

ORIENTATION_BEFORE  .byte $00
