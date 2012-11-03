
; register A will be greater than 0 if it did some drops
; This subroutine just scans the playing field and hands off to something else
; to do the actual dropping
doDrop
    lda #$00
    sta tmp3 ; to be returned as the count of drops that occured
dropContinue ; a = void()
    ldy #$10 ; zp index, do not change
    sty tmp  ; used as screen y offset, 0 - 15
    ldy #$00
    sty tmp1 ; used to keep track if anything dropped, shared with dropDownIfYouCan
    sty tmp2 ; used as screen x index 0 - 7

    ; This the bottom left pos (in the boarder), to get there start at the top left
    ; then add $0258
    ; Originally was:  $0667 - $040f

    clc
    lda #OnePGameFieldLocLow
    adc #$80
    sta zpPtr1
    lda #OnePGameFieldLocHigh
    adc #$02
    sta zpPtr1+1


rowLoop
    ; This part moves from the lowest level on up
    lda tmp ; y starting at bottom #$0f
    beq rowLoopComplete


;    lda #8 ; Reset column pos to right side
    lda #0
    sta tmp2

    sec
    lda zpPtr1
    sbc #40
    sta zpPtr1
    sta zpPtr2

    lda zpPtr1+1
    sbc #0
    sta zpPtr1+1
    sta zpPtr2+1

columnLoop
    lda tmp2
    cmp #8
    beq columnLoopComplete

    clc
    lda zpPtr2
    adc #1
    sta zpPtr2
    lda zpPtr2+1
    adc #0
    sta zpPtr2+1

    lda (zpPtr2),y
    ; Loaded for the compares
    cmp #PILL_SIDE
    beq drop_piece

    cmp #PILL_LEFT ; Should we drop both pieces down as a group?
    beq drop_2pieces ; Horizontal

    cmp #PILL_TOP ; should we drop both pieces down as a group vertically?
    beq drop_2piecesVertically

    jmp nextColumn ; default

drop_2piecesVertically
    lda zpPtr2
    pha
    lda zpPtr2+1
    pha
    jsr dropDoubleVerticalIfYouCan
    jmp nextColumn
drop_2pieces
    lda zpPtr2
    pha
    lda zpPtr2+1
    pha
    jsr dropDoubleHorizontalIfYouCan
    jmp nextColumn
drop_piece
    lda zpPtr2
    pha
    lda zpPtr2+1
    pha
    jsr dropDownIfYouCan

nextColumn
    inc tmp2 ; increment column index
    jmp columnLoop
columnLoopComplete

nextRow
    dec tmp
    jmp rowLoop


rowLoopComplete
    ; Time between drops
    jsr WaitEventFrame
    jsr WaitEventFrame
    lda tmp1 ; Any drops done this last time? We'll want to drop more if so
    bne dropContinueShortJump
    lda tmp3 ; Total number of drops returned
    rts
dropContinueShortJump
    jmp dropContinue






; Given the top joined piece, can we drop it?
dropDoubleVerticalIfYouCan
    jmp ddviyc_start
    ddviyc_y    .byte $00
    ddviyc_ret  .byte $00, $00
ddviyc_start
    sty ddviyc_y
    pla
    sta ddviyc_ret+1
    pla
    sta ddviyc_ret
    pla
    sta zpPtr3+1
    pla
    sta zpPtr3
    ; push return back onto stack
    lda ddviyc_ret
    pha
    lda ddviyc_ret+1
    pha
    ; what's 2 below
    ldy #80
    lda (zpPtr3),y
    cmp #' '
    bne ddviyc_noDrop
    ; Okay we can drop, erase the top piece
    ldy #0
    ; Still have #' ' in register a
    sta (zpPtr3),y
    lda #PILL_TOP
    ldy #40
    sta (zpPtr3),y
    ldy #80
    lda #PILL_BOTTOM
    sta (zpPtr3),y
    ; now copy colors on over to new possitions

    clc
    lda zpPtr3+1
    adc #$d4
    sta zpPtr3+1
    ldy #40
    lda (zpPtr3),y
    and #$0f
    ldy #80
    sta (zpPtr3),y
    ldy #0
    lda (zpPtr3),y
    and #$0f
    ldy #40
    sta (zpPtr3),y

    ldy ddviyc_y
    inc tmp3
    inc tmp1

ddviyc_noDrop
    ldy ddviyc_y
    rts

; Given the left piece, can we drop it?
; Joined pieces only drop if there are two clear spaces below
dropDoubleHorizontalIfYouCan ; inc tmp3  (ret2, ret1, pos+1, pos)
    jmp ddhiyc_start
    ddhiyc_y    .byte $00
    ddhiyc_ret  .byte $00, $00
    ddhiyc_start
    sty ddhiyc_y
    pla
    sta ddhiyc_ret+1
    pla
    sta ddhiyc_ret
    pla
    sta zpPtr3+1
    pla
    sta zpPtr3
    ; push return back onto stack
    lda ddhiyc_ret
    pha
    lda ddhiyc_ret+1
    pha

    ; What's below?
    ldy #40
    lda (zpPtr3), y ; What's below?
    cmp #" "
    bne ddhiyc_noDrop
    iny
    lda (zpPtr3),y ; +41
    cmp #" "
    bne ddhiyc_noDrop
    ; Piece dropped so remove the old piece
    ldy #$00
    lda #' '
    sta (zpPtr3),y
    iny ; #1
    sta (zpPtr3),y
    ; Piece can be dropped, let's copy it over to the new spot
    ldy #40
    lda #PILL_LEFT
    sta (zpPtr3),y
    iny ; #41
    lda #PILL_RIGHT
    sta (zpPtr3),y
    ; now load colors to copy on over
    clc
    lda zpPtr3+1
    adc #$d4
    sta zpPtr3+1
    ldy #$00
    lda (zpPtr3),y
    and #$0f
    ldy #40
    sta (zpPtr3),y
    ldy #1
    lda (zpPtr3),y
    and #$0f
    ldy #41
    sta (zpPtr3),y
    ddhiyc_Drop
    inc tmp3
    inc tmp1
    ;        lda #$01
    ldy ddhiyc_y
    rts
ddhiyc_noDrop
    ;        lda #$00
    ldy ddhiyc_y
    rts


dropDownIfYouCan ; void (ret2, ret1, pos+1, pos)
    jmp startDropDownIfYouCan
    localXTmp   .byte $00
    localYTmp   .byte $00
    ddiyc_ret   .byte $00, $00
startDropDownIfYouCan
    stx localXTmp
    sty localYTmp

    pla
    sta ddiyc_ret+1
    pla
    sta ddiyc_ret
    pla
    sta zpPtr3+1
    pla
    sta zpPtr3

    ; Look below and store it into zpPtr4
    ldy #40
    lda (zpPtr3),y
    cmp #' '
    bne noDrop
    ; Copy piece down one
    ldy #0
    lda (zpPtr3),y
    ldy #40
    sta (zpPtr3),y
    ; clear piece that was dropped
    lda #' '
    ldy #0
    sta (zpPtr3),y
    ; now transfer color from above to below
    clc
    lda zpPtr3+1
    adc #$d4
    sta zpPtr3+1
    lda (zpPtr3),y
    and #$0f
    ldy #40
    sta (zpPtr3),y

    inc tmp1 ; shared value for knowing if there was a drop
    inc tmp3 ; shared value for knowing total of drops
noDrop
    ldy localYTmp
    ldx localXTmp
    lda ddiyc_ret
    pha
    lda ddiyc_ret+1
    pha
    rts
