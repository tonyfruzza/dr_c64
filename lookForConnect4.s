doesLeftPieceMatch ; (ret>, ret<, pos>, pos<, color)
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

    sec
    lda zpPtr5
    sbc #01
    sta zpPtr5
    lda zpPtr5+1
    sbc #00
    sta zpPtr5+1

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
    jmp couldMatch_piece

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



lookForConnect4c ; varray (return>, return<, piece>, piece<)
    jmp lfc4_start
    lfc4_ret    .byte $00, $00
    lfc4_y      .byte $00
lfc4_start
    sty lfc4_y
    pla
    sta lfc4_ret+1
    pla
    sta lfc4_ret
    pla
    sta tmp+1 ; piece >
    pla
    sta tmp   ; piece <
    jsr initClearArrays



    ; Get color of this possition and store it CMPCOLOR
    clc
    lda tmp+1
    adc #$D4
    sta zpPtr3+1
    lda tmp
    sta zpPtr3
    ldy #$00
    lda(zpPtr3),y
    and #$0f
    sta CMPCOLOR


    ; Look for horizontal block to clear
lookLeft
    sec ; set carry for subtraction
    lda tmp ; piece <
    sbc #$01 ; look to the left
    sta zpPtr2
    lda tmp+1
    sbc #$00 ; piece >
    sta zpPtr2+1


;(ret>, ret<, pos>, pos<, color)
lda CMPCOLOR
pha
lda zpPtr2
pha
lda zpPtr2+1
pha
jsr doesLeftPieceMatch



    ldy #$00 ; zp index offset
    lda (zpPtr2), y
    cmp #PILL_SIDE
    beq ll_piece
    cmp #PILL_LEFT
    beq ll_piece
    cmp #PILL_RIGHT
    beq ll_piece
    cmp #PILL_TOP
    beq ll_piece
    cmp #PILL_BOTTOM
    beq ll_piece
    cmp #VIRUS_ONE
    beq ll_piece
    cmp #VIRUS_TWO
    beq ll_piece
    cmp #VIRUS_THREE
    beq ll_piece
    cmp #PILL_CLEAR_1
    beq ll_piece
    jmp lookLeftComplete
ll_piece
    clc
    lda zpPtr2 ; get color of piece to left to see if it matches
    sta zpPtr3
    lda #$D4
    adc zpPtr2+1
    sta zpPtr3+1
    lda (zpPtr3),y
    and #$0f
    cmp CMPCOLOR
    bne lookLeftComplete
    ; Piece to left is the same color and type
    lda zpPtr2
    sta tmp
    lda zpPtr2+1
    sta tmp+1
    jmp lookLeft
    lookLeftComplete
    lda tmp
    sta zpPtr2
    pha
    lda tmp+1
    sta zpPtr2+1
    pha
    jsr pushOntoHarray
lookRight
    clc
    lda #$01
    adc zpPtr2
    sta zpPtr2
    lda #$00
    tay ; init y index to 0
    adc zpPtr2+1
    sta zpPtr2+1
    lda (zpPtr2), y
    cmp #PILL_SIDE
    beq lr_piece
    cmp #PILL_LEFT
    beq lr_piece
    cmp #PILL_RIGHT
    beq lr_piece
    cmp #PILL_TOP
    beq lr_piece
    cmp #PILL_BOTTOM
    beq lr_piece
    cmp #VIRUS_ONE
    beq lr_piece
    cmp #VIRUS_TWO
    beq lr_piece
    cmp #VIRUS_THREE
    beq lr_piece
    cmp #PILL_CLEAR_1
    beq lr_piece


    jmp lookRightDone
    lr_piece
    clc
    lda zpPtr2
    sta zpPtr3
    lda #$D4
    adc zpPtr2+1
    sta zpPtr3+1
    lda (zpPtr3),y
    and #$0f
    cmp CMPCOLOR
    bne lookRightDone
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
    ldy #$00 ; index offset for zp load
    lda (zpPtr2),y
    cmp #PILL_SIDE
    beq lu_piece
    cmp #PILL_LEFT
    beq lu_piece
    cmp #PILL_RIGHT
    beq lu_piece
    cmp #PILL_TOP
    beq lu_piece
    cmp #PILL_BOTTOM
    beq lu_piece
    cmp #VIRUS_ONE
    beq lu_piece
    cmp #VIRUS_TWO
    beq lu_piece
    cmp #VIRUS_THREE
    beq lu_piece
    cmp #PILL_CLEAR_1
    beq lu_piece


    jmp lookUpComplete
lu_piece
    clc
    lda zpPtr2 ; load back in low byte
    sta zpPtr3 ; and copy it over to the color place
    lda #$D4
    adc zpPtr2+1
    sta zpPtr3+1
    lda (zpPtr3),y
    and #$0f
    cmp CMPCOLOR
    bne lookUpComplete
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

    ; debug shit
    lda #1
    sta (zpPtr2),y


lookDown
    clc ; Look for a piece below
    lda #40
    adc zpPtr2
    sta zpPtr2
    lda #$00
    adc zpPtr2+1
    sta zpPtr2+1
    ldy #$00
    lda (zpPtr2), y

    cmp #PILL_SIDE
    beq ld_piece
    cmp #PILL_LEFT
    beq ld_piece
    cmp #PILL_RIGHT
    beq ld_piece
    cmp #PILL_TOP
    beq ld_piece
    cmp #PILL_BOTTOM
    beq ld_piece
    cmp #VIRUS_ONE
    beq ld_piece
    cmp #VIRUS_TWO
    beq ld_piece
    cmp #VIRUS_THREE
    beq ld_piece
    cmp #PILL_CLEAR_1
    beq ld_piece


    jmp lookDownDone
    ; debug
ld_piece

    clc ; Now look for color
    lda zpPtr2
    sta zpPtr3
    lda #$D4
    adc zpPtr2+1
    sta zpPtr3+1
    lda (zpPtr3), y
    and #$0f ; mask out the top part of the byte, it could be garbage
    cmp CMPCOLOR
    bne lookDownDone
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
