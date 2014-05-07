; Draw game board using char 230 as the border
; We'll start at the top left +3, draw down 16, 8 accross
DrawBorderBox ; void = (ret>, ret<, topLeftPos>, topLeftPos<, height, width)
    jmp dbb_start
    dbb_height  .byte $00
    dbb_width   .byte $00
dbb_start
    pla
    sta ret1+1
    pla
    sta ret1
    pla
    sta zpPtr2+1
    clc
    adc #$d4
    sta zpPtr1+1
    pla
    sta zpPtr2
    sta zpPtr1
    pla
    sta dbb_height
    pla
    sta dbb_width

    lda ret1
    pha
    lda ret1+1
    pha

    ldx #$00 ; Our counter

ldy #0
lda #WALL_CHAR_TLFT
sta (zpPtr2),y
lda #COLOR_MAGENTA
sta (zpPtr1),y

dbb_DrawTop
    iny
    cpy dbb_width
    beq dbb_endTop
    lda #WALL_CHAR_TOP
    sta (zpPtr2),y
    lda #COLOR_MAGENTA
    sta (zpPtr1),y
    jmp dbb_DrawTop
dbb_endTop
    lda #WALL_CHAR_TRT
    sta (zpPtr2),y
    lda #COLOR_MAGENTA
    sta (zpPtr1),y

    clc
    lda #40
    adc zpPtr2
    sta zpPtr2
    lda #0
    adc zpPtr2+1
    sta zpPtr2+1

    clc
    lda #40
    adc zpPtr1
    sta zpPtr1
    lda #0
    adc zpPtr1+1
    sta zpPtr1+1


dbbLoop
    ldy #00
    lda #WALL_SIDES
    sta (zpPtr2), y
    lda #COLOR_MAGENTA
    sta (zpPtr1), y
    ldy dbb_width
    lda #WALL_SIDES
    sta (zpPtr2), y
    lda #COLOR_MAGENTA
    sta (zpPtr1), y

    ; Draw centers
    ldy #01
dbb_clearGameField
    lda #CLEAR_CHAR
    sta (zpPtr2),y
    lda #COLOR_WHITE ; Text content color
    sta (zpPtr1),y

    iny
    cpy dbb_width
    bne dbb_clearGameField
    ; Next line down
    clc
    lda zpPtr2
    adc #40
    sta zpPtr2
    lda zpPtr2+1
    adc #0
    sta zpPtr2+1

    clc
    lda zpPtr1
    adc #40
    sta zpPtr1
    lda zpPtr1+1
    adc #0
    sta zpPtr1+1

    inx
    cpx dbb_height
    bne dbbLoop
    ldy #00
    lda #WALL_BL
    sta (zpPtr2),y
    lda #COLOR_MAGENTA
    sta (zpPtr1),y
    ; then finish off the bottom line
    iny
dbb_DrawBottom
    lda #WALL_B
    sta (zpPtr2), y
    lda #COLOR_MAGENTA
    sta (zpPtr1), y
    iny
    cpy dbb_width
    bne dbb_DrawBottom
dbbDone
    lda #WALL_BR
    sta (zpPtr2),y
    lda #COLOR_MAGENTA
    sta (zpPtr1),y
; Carve out the bottom line
    inc dbb_width ; Include the right most character as well
dbb_solidBlackUnder
    ; Move cursor down one row for drawing
    clc
    lda zpPtr2
    adc #40
    sta zpPtr2
    lda zpPtr2+1
    adc #0
    sta zpPtr2+1
    ldy #0
    lda #CLEAR_CHAR
dbb_solidLineLoop
    sta (zpPtr2), y
    iny
    cpy dbb_width
    bne dbb_solidLineLoop
    ; Move color cursor down a couple rows to color shadow
    clc
    lda #40
    adc zpPtr2
    sta zpPtr1
    lda #$d4
    adc zpPtr2+1
    sta zpPtr1+1
    ldy #0
    lda #COLOR_DARK_GREY
dbb_shadowUnderLoop
    sta (zpPtr1), y
    iny
    cpy dbb_width
    bne dbb_shadowUnderLoop
    ; Next shadow under
    clc
    lda #40
    adc zpPtr1
    sta zpPtr1
    lda #0
    adc zpPtr1+1
    sta zpPtr1+1
    ldy #0
    lda #COLOR_GREY
dbb_shadowUnderLoop2
    sta (zpPtr1), y
    iny
    cpy dbb_width
    bne dbb_shadowUnderLoop2
    ; Next shadow under
    lda cutLastLine
    bne dbb_finished

    clc
    lda #40
    adc zpPtr1
    sta zpPtr1
    lda #0
    adc zpPtr1+1
    sta zpPtr1+1
    ldy #0
    lda #COLOR_L_GREY
dbb_shadowUnderLoop3
    sta (zpPtr1), y
    iny
    cpy dbb_width
    bne dbb_shadowUnderLoop3
dbb_finished
    lda #0
    sta cutLastLine ; Always return it back to 0
    rts
cutLastLine .byte 0 ; This is because the game board gets painted off the bottom by one row


;
; Print Message subrutine string ending in 0
printMsgSub ; void (ret>, ret<, color, txt>, txt<, pos>, pos<)
    pla
    sta ret1+1
    pla
    sta ret1

    pla
    sta zpPtr2+1 ; screen pos
    clc
    adc #$d4
    sta zpPtr3+1
    pla
    sta zpPtr2
    sta zpPtr3

;    pla
;    txa ; stash color here

    pla
    sta zpPtr1+1 ; txt data
;    sta tmp+1
    pla
    sta zpPtr1
;    sta tmp

    lda ret1
    pha
    lda ret1+1
    pha

    ldy #$00
printLoopSub
    lda (zpPtr1), y
    beq printCompleteSub
    sta (zpPtr2), y
    lda #COLOR_WHITE ; inner default color for text
    sta (zpPtr3),y
    iny
    jmp printLoopSub
printCompleteSub
    rts