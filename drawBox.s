
WALL_CHAR_TRT   .equ 73
WALL_CHAR_TLFT  .equ 110
WALL_CHAR_TOP   .equ 112

; Draw game board using char 230 as the boarder
; We'll start at the top left +3, draw down 16, 8 accross
DrawBoarderBox ; void = (ret>, ret<, topLeftPos>, topLeftPos<, height, width)
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
lda #COLOR_GREY
sta (zpPtr1),y

dbb_DrawTop
    iny
    cpy dbb_width
    beq dbb_endTop
    lda #WALL_CHAR_TOP
    sta (zpPtr2),y
    jmp dbb_DrawTop
dbb_endTop
    lda #WALL_CHAR_TRT
    sta (zpPtr2),y

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
    ldy dbb_width
    sta (zpPtr2), y

    ; Draw centers
    ldy #01
dbb_clearGameField
    lda #' '
    sta (zpPtr2),y
    lda #COLOR_WHITE
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
    ; then finish off the bottom line
    iny
dbb_DrawBottom
    lda #WALL_B
    sta (zpPtr2), y
    iny
    cpy dbb_width
    bne dbb_DrawBottom
dbbDone
    lda #WALL_BR
    sta (zpPtr2),y
    rts



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
    lda #COLOR_L_GREY
    sta (zpPtr3),y
    iny
    jmp printLoopSub
printCompleteSub
    rts