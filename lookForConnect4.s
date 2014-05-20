doesThisPieceMatch ; (ret>, ret<, pos>, pos<, color)
    pla
    sta dlpm_ret+1
    pla
    sta dlpm_ret
    pla
    sta zpPtr5+1
    pla
    sta zpPtr5
    pla
    sta dlpm_color

    lda dlpm_ret
    pha
    lda dlpm_ret+1
    pha

    sty dlpm_rety
    ldy #0

    lda (zpPtr5),y
    cmp #PILL_SIDE
    beq couldMatch_piece
    cmp #PILL_LEFT
    beq couldMatch_piece
    cmp #PILL_RIGHT
    beq couldMatch_piece
    cmp #PILL_TOP
    beq couldMatch_piece
    cmp #PILL_BOTTOM
    beq couldMatch_piece
    cmp #VIRUS_ONE
    beq couldMatch_piece
    cmp #VIRUS_TWO
    beq couldMatch_piece
    cmp #VIRUS_THREE
    beq couldMatch_piece
    cmp #PILL_CLEAR_1
    beq couldMatch_piece
    jmp dlpm_notSame

couldMatch_piece ; Look now at the color
    clc
    lda zpPtr5+1
    adc #$D4
    sta zpPtr5+1
    lda (zpPtr5),y
    and #$0f
    cmp dlpm_color
    bne dlpm_notSame

    ldy dlpm_rety
    lda #1
    rts

dlpm_notSame
    ldy dlpm_rety
    lda #0
    rts

dlpm_ret    .byte $00, $00
dlpm_color  .byte $00
dlpm_rety   .byte $00







; Look Left -> Right, then Top -> Down
lookForConnect4c ; varray (return>, return<, piece>, piece<)
    sty lfc4_y
    pla
    sta lfc4_ret+1
    pla
    sta lfc4_ret
    pla
    sta tmp+1 ; piece >
    sta lfc4_og_pos+1 ; do not change
    pla
    sta tmp   ; piece <
    sta lfc4_og_pos ; do not change
    jsr initClearArrays



    ; Get color of this possition and store it CMPCOLOR
    clc
    lda tmp+1
    adc #$D4
    sta zpPtr2+1
    lda tmp
    sta zpPtr2
    ldy #$00
    lda(zpPtr2),y
    and #$0f
    sta CMPCOLOR


    lda tmp
    sta zpPtr2
    lda tmp+1
    sta zpPtr2+1
    ; Look for horizontal block to clear
lookLeft
    sec ; set carry for subtraction
    lda zpPtr2 ; piece <
    sbc #$01 ; look to the left
    sta zpPtr2
    lda zpPtr2+1
    sbc #$00 ; piece >
    sta zpPtr2+1


    ;(ret>, ret<, pos>, pos<, color)
    lda CMPCOLOR
    pha
    lda zpPtr2
    pha
    lda zpPtr2+1
    pha
    jsr doesThisPieceMatch
    beq lookLeftComplete ; no match so start looking right

    jmp lookLeft
lookLeftComplete
    clc
    lda zpPtr2
    adc #1
    sta zpPtr2
    pha
    lda zpPtr2+1
    adc #0
    sta zpPtr2+1
    pha
    jsr pushOntoHarray

lookRight
    clc
    lda #$01
    adc zpPtr2
    sta zpPtr2
    lda #$00
    adc zpPtr2+1
    sta zpPtr2+1

    ;(ret>, ret<, pos>, pos<, color)
    lda CMPCOLOR
    pha
    lda zpPtr2
    pha
    lda zpPtr2+1
    pha
    jsr doesThisPieceMatch
    beq lookRightDone

    lda zpPtr2
    pha
    lda zpPtr2+1
    pha
    jsr pushOntoHarray ; void (ret2, ret1, addy2, addy1)
    inc CONNECTCNT
    jmp lookRight ; loop until we've counted them all
lookRightDone


    ; Look for vertical blocks to clear
lookUp ; start at the top and work my way down
    sec
    lda tmp ; piece
    sbc #40
    sta zpPtr2
    lda tmp+1
    sbc #$00
    sta zpPtr2+1

    lda CMPCOLOR
    pha
    lda zpPtr2
    pha
    lda zpPtr2+1
    pha
    jsr doesThisPieceMatch
    beq lookUpComplete

    ; Piece is the same color, and type
    lda zpPtr2
    sta tmp ; make it the active top piece
    lda zpPtr2+1
    sta tmp+1

    jmp lookUp
lookUpComplete
    lda tmp
    sta zpPtr2
    pha
    lda tmp+1
    sta zpPtr2+1
    pha
    jsr pushOntoVarray


lookDown
    clc ; Look for a piece below
    lda #40
    adc zpPtr2
    sta zpPtr2
    lda #$00
    adc zpPtr2+1
    sta zpPtr2+1


    ;(ret>, ret<, pos>, pos<, color)
    lda CMPCOLOR
    pha
    lda zpPtr2
    pha
    lda zpPtr2+1
    pha
    jsr doesThisPieceMatch
    beq lookDownDone

    ; put this piece onto the array
    lda zpPtr2 ; Store away low byte
    pha
    lda zpPtr2+1 ; Store away high byte onto stack
    pha
    jsr pushOntoVarray ; void (ret2, ret1, addy2, addy1)
    inc CONNECTCNT
    jmp lookDown ; loop until we've counted them all
    lookDownDone
    jsr clearPiecesInArray
    ; put back return address onto stack
    ldy lfc4_y
    lda lfc4_ret
    pha
    lda lfc4_ret+1
    pha
    rts

lfc4_ret    .byte $00, $00
lfc4_y      .byte $00
lfc4_og_pos .byte $00, $00

