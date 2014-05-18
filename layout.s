
; Draw game board
DrawGameBorder
    lda #1
    sta cutLastLine
    lda #09 ; Width
    pha
    lda #16 ; Height
    pha
    ; Box in relation to play field is actually shifted up one row

    sec
    lda #OnePGameFieldLocLow ; Low byte start location
    sbc #40
    pha
    lda #OnePGameFieldLocHigh ; High byte start location
    sbc #0
    pha
    jsr DrawBorderBox
    jsr copySpriteDataInForPlayerHead ; Do this once when setting up layout
;    jsr displayTopSprite ; enable the top sprites
    jsr drawInlet
    rts

;bin2hex8bit ; TMP, TMP2 (ret_2, ret_1, binNumber)
printSinglePlayerLevelBox
    ; Print Level box and message
    lda #08 ; Width
    pha
    lda #2 ; Height
    pha
    lda #$36 ; Low pos
    pha
    lda #$05 ; High pos
    pha
    jsr DrawBorderBox

    lda #<MSG_LEVEL
    pha
    lda #>MSG_LEVEL
    pha

    lda #$60
    pha
    lda #$05
    pha
    jsr printMsgSub

    lda currentLvl
    pha
    jsr bin2hex8bit
    lda #$89
    sta zpPtr2 ; Low pos
    lda #$05
    sta zpPtr2+1 ; High pos
    ldy #0
    lda #$30
    sta (zpPtr2), y
    iny
    lda TMP
    and #$f0
    lsr
    lsr
    lsr
    lsr
    ora #$30
    sta (zpPtr2),y
    iny
    lda TMP
    and #$0f
    ora #$30
    sta (zpPtr2),y
    rts

; Virus count box and and message
printSinglePlayerVirusCountBox
    lda #08 ; Width
    pha
    lda #2 ; Height
    pha
    lda #$19 ; low pos
    pha
    lda #$05 ; high pos
    pha
    jsr DrawBorderBox


    lda #<MSG_VIRUS
    pha
    lda #>MSG_VIRUS
    pha

    lda #$43 ; low pos
    pha
    lda #$05 ; high pos
    pha
    jsr printMsgSub
    rts

printSinglePlayerScoreBox
    ; Score box and message
    lda #08 ; Width
    pha
    lda #2 ; Height
    pha
    lda #$43 ; Low Pos
    pha
    lda #$04 ; High Pos
    pha
    jsr DrawBorderBox


    lda #<MSG_SCORE
    pha
    lda #>MSG_SCORE
    pha

    lda #$6d
    pha
    lda #$04
    pha
    jsr printMsgSub
    rts

printSinglePlayerNextPieceBox
    lda #07 ; width
    pha
    lda #2 ; height
    pha

    lda #$2d ; Low pos
    pha
    lda #$04 ; high pos
    pha
    jsr DrawBorderBox


    ; Do the screen text for the first time
    ;printMsgSub ; void (ret>, ret<, txt>, txt<, pos>, pos<)
    lda #<MSG_NEXT
    pha
    lda #>MSG_NEXT
    pha

    lda #$57
    pha
    lda #$04
    pha
    jsr printMsgSub

    ; Set up the position of the "next" pill colors
    lda #$80
    sta piece1_next
    lda #$04
    sta piece1_next+1

    lda #$81
    sta piece2_next
    lda #$04
    sta piece2_next+1

    ; Draw the "next" pills
    ldy #$00

    lda #PILL_LEFT
    sta (piece1_next),y
    lda #PILL_RIGHT
    sta (piece2_next),y


    jsr NewColors ; need to run this twice the first time
    rts

drawInlet
    ; Reset the value of some self modifying code that gets run multiple times
    lda #<inletMapRow1
    sta drawInletRowLoop+1
    lda #>inletMapRow1
    sta drawInletRowLoop+2
    ; Same for color
    lda #<inletClrRow1
    sta drawInletRowColorLoop+1
    lda #>inletClrRow1
    sta drawInletRowColorLoop+2

    ldy #0
    sec
    lda #OnePGameFieldLocLow
    sbc #119
    sta zpPtr1
    sta zpPtr2 ; Color low
    lda #OnePGameFieldLocHigh
    sbc #0
    sta zpPtr1+1
    ; Do Color
    clc
    adc #$D4
    sta zpPtr2+1 ; Color high

    ldx #0
drawInletRowLoop
    lda inletMapRow1, y
    sta (zpPtr1), y
drawInletRowColorLoop
    lda inletClrRow1, y
    sta (zpPtr2), y
    iny
    cpy #8
    bne drawInletRowLoop
    inx
    cpx #2
    beq drawInletFinished

    clc
    lda zpPtr1
    adc #40
    sta zpPtr1
    sta zpPtr2
    lda zpPtr1+1
    adc #0
    sta zpPtr1+1
    ; Do Color
    clc
    adc #$D4
    sta zpPtr2+1 ; Color high

    ldy #0 ; reset counter
    ; Self modify inletMapRow1 memaddress used above
    clc
    lda drawInletRowLoop+1 ; Load low byte
    adc #8
    sta drawInletRowLoop+1
    lda drawInletRowLoop+2 ; Load high byte
    adc #0
    sta drawInletRowLoop+2
    ; Do the same for the color part
    clc
    lda drawInletRowColorLoop+1 ; Load low byte
    adc #8
    sta drawInletRowColorLoop+1
    lda drawInletRowColorLoop+2 ; Load high byte
    adc #0
    sta drawInletRowColorLoop+2


    jmp drawInletRowLoop
drawInletFinished
    jsr ClearTopLine
    rts
; Characters used to create inlet top to mating point
inletMapRow1    .byte 100, WALL_CHAR_TRT, 91, CLEAR_CHAR, 92, 93, WALL_CHAR_TLFT, 101
inletMapRow2    .byte BACKGROUND_CHAR, WALL_SIDES, 94, CLEAR_CHAR, 95, 96, WALL_SIDES, BACKGROUND_CHAR

inletClrRow1    .byte COLOR_MAGENTA, COLOR_MAGENTA, COLOR_BROWN, COLOR_BROWN, COLOR_BROWN, COLOR_ORANGE, COLOR_MAGENTA, COLOR_MAGENTA
inletClrRow2    .byte COLOR_WHITE, COLOR_MAGENTA, COLOR_BROWN, COLOR_BROWN, COLOR_BROWN, COLOR_ORANGE, COLOR_MAGENTA, COLOR_WHITE


ClearTopLine
    sec
    lda #OnePGameFieldLocLow ; Low byte start location
    sta zpPtr1 ; Top visible line
    sbc #40
    sta zpPtr2 ; Top line under sprite
    lda #OnePGameFieldLocHigh ; High byte start location
    sta zpPtr1+1
    sbc #0
    sta zpPtr2+1
    ldy #8
ClearTopLineLoop
    lda (zpPtr2),y
    cmp #PILL_TOP ; If there is a pill hanging up above
    bne ctl_NoConvertChar
    lda #PILL_SIDE ; then convert the bottom half to a single pill cell
    sta (zpPtr1),y
ctl_NoConvertChar
    lda #CLEAR_CHAR
    sta (zpPtr2),y
    dey
    bne ClearTopLineLoop
ctl_done
    rts


printVirusContainerBox
    lda #10 ; Width
    pha
    lda #3 ; Height
    pha
    lda #$32 ; low pos + 280
    pha
    lda #$06 ; high pos
    pha
    jsr DrawBorderBox
    rts

printPlayerContainerBox
    lda #05 ; Width
    pha
    lda #3 ; Height
    pha
    lda #$9c ; Low pos
    pha
    lda #$06 ; High pos
    pha
    jsr DrawBorderBox
    rts
