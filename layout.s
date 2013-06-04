;OnePGameFieldLocLow   .equ $0f
;OnePGameFieldLocHigh  .equ $04



ClearTopLine
    sec
    lda #OnePGameFieldLocLow ; Low byte start location
    sbc #40
    sta zpPtr2
    lda #OnePGameFieldLocHigh ; High byte start location
    sbc #0
    sta zpPtr2+1
ClearTopLineLoop
    cpy #0
    bne NotTopLeft
    lda #110
    jmp ApplyClearingTopLine
NotTopLeft
    cpy #9
    bne NotTopRight
    lda #73
    jmp ApplyClearingTopLine
NotTopRight
    lda #' '
ApplyClearingTopLine
    sta (zpPtr2),y
    iny
    cpy #10
    beq ctl_done
    jmp ClearTopLineLoop
ctl_done
    rts


; Draw game board using char 230 as the boarder
DrawGameBorder
    lda #$00 ; Our counter
    tax
    tay
    sta TMP1 ; used to count how many viruses we've printed

    jsr ClearTopLine
dgb_start
    ldy #$00

    lda #OnePGameFieldLocLow ; Low byte start location
    sta zpPtr2
    lda #OnePGameFieldLocHigh ; High byte start location
    sta zpPtr2+1
dgbLoop
    ldy #00
    lda #WALL_SIDES
    sta (zpPtr2), y
    ldy #9
    sta (zpPtr2), y

    ; Draw centers
    ldy #01
    clearGameField
    lda #' '
    sta (zpPtr2),y
    iny
    cpy #9
    bne clearGameField
    ; Next line down
    clc
    lda zpPtr2
    adc #40
    sta zpPtr2
    lda zpPtr2+1
    adc #0
    sta zpPtr2+1

    inx
    cpx #16 ; game field length
    bne dgbLoop
    ldy #00
    lda #WALL_BL
    sta (zpPtr2),y
    ; then finish off the bottom line
    iny
DrawBottom
    lda #WALL_B
    sta (zpPtr2), y
    iny
    cpy #9
    bne DrawBottom
dgbDone
    lda #WALL_BR
    sta (zpPtr2),y
    jsr displayTopSprite ; enable the top sprites
    jsr removeBgNearTop
    rts




;bin2hex8bit ; TMP, TMP2 (ret_2, ret_1, binNumber)
printSinglePlayerLevelBox
    ; Print Level box and message
    lda #10 ; Width
    pha
    lda #2 ; Height
    pha
    lda #$33
    pha
    lda #$05
    pha
    jsr DrawBorderBox

    lda #<MSG_LEVEL
    pha
    lda #>MSG_LEVEL
    pha

    lda #$5e
    pha
    lda #$05
    pha
    jsr printMsgSub

    lda currentLvl
    pha
    jsr bin2hex8bit
    lda #$88
    sta zpPtr2
    lda #$05
    sta zpPtr2+1
    ldy #0
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
    lda #10 ; Width
    pha
    lda #2 ; Height
    pha
    lda #$1a
    pha
    lda #$05
    pha
    jsr DrawBorderBox


    lda #<MSG_VIRUS
    pha
    lda #>MSG_VIRUS
    pha

    lda #$45
    pha
    lda #$05
    pha
    jsr printMsgSub
    rts

printSinglePlayerScoreBox
    ; Score box and message
    lda #10 ; Width
    pha
    lda #2 ; Height
    pha
    lda #$43
    pha
    lda #$04
    pha
    jsr DrawBorderBox


    lda #<MSG_SCORE
    pha
    lda #>MSG_SCORE
    pha

    lda #$6e
    pha
    lda #$04
    pha
    jsr printMsgSub
    rts

printSinglePlayerNextPieceBox
    lda #10 ; width
    pha
    lda #2 ; height
    pha

    lda #$2a
    pha
    lda #$04
    pha
    jsr DrawBorderBox


    ; Do the screen text for the first time
    ;printMsgSub ; void (ret>, ret<, txt>, txt<, pos>, pos<)
    lda #<MSG_NEXT
    pha
    lda #>MSG_NEXT
    pha

    lda #$56
    pha
    lda #$04
    pha
    jsr printMsgSub

    ; Set up the position of the "next" pill colors
    lda #$7f
    sta piece1_next
    lda #$04
    sta piece1_next+1

    lda #$80
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

printQuickZombieInBox
    lda #10 ; width
    pha
    lda #5 ; height
    pha

    lda #$0A ; 1,546
    pha
    lda #$06
    pha
    jsr DrawBorderBox

; The right side box
    lda #10 ; Width
    pha
    lda #5 ; Height
    pha
    lda #$23
    pha
    lda #$06
    pha
    jsr DrawBorderBox

pqzib_drawSomething
    lda DrawRightSide
    beq pqzib_DrawLeftSide
    cmp #1
    beq pqzib_drawRightSide
    jmp pqzib_done
    ; Draw Left side
pqzib_DrawLeftSide
    lda #$33 ; 1,587
    sta zpPtr2
    lda #$06
    sta zpPtr2+1
    jmp pqzib_draw

pqzib_drawRightSide
    ; Right Row 1/5
    lda #$4C ; 1,587
    sta zpPtr2
    lda #$06
    sta zpPtr2+1
    jmp pqzib_draw

pqzib_draw
    ; Row 1/5
    ldy #0
    ldx #128
    txa
    sta (zpPtr2), y
    inx
    txa
    iny
    sta (zpPtr2), y
    inx
    txa
    iny
    sta (zpPtr2), y
    iny
    lda #' '
    sta (zpPtr2), y
    lda #143
    iny
    sta (zpPtr2), y
    iny
    lda #' '
    sta (zpPtr2), y
    ; Right Zombie
    dex
    dex
    txa
    iny
    sta (zpPtr2), y
    inx
    txa
    iny
    sta (zpPtr2), y
    inx
    txa
    iny
    sta (zpPtr2), y


    ; Row 2/5
    ldy #40
    inx
    txa
    sta (zpPtr2), y
    inx
    txa
    iny
    sta (zpPtr2), y
    inx
    txa
    iny
    sta (zpPtr2), y
    iny
    lda #' '
    sta (zpPtr2), y
    lda #144
    iny
    sta (zpPtr2), y
    iny
    lda #' '
    sta (zpPtr2), y
    ; Right Zombie
    dex
    dex
    txa
    iny
    sta (zpPtr2), y
    inx
    txa
    iny
    sta (zpPtr2), y
    inx
    txa
    iny
    sta (zpPtr2), y



    ; Row 3/5
    ldy #80
    inx
    txa
    sta (zpPtr2), y
    inx
    txa
    iny
    sta (zpPtr2), y
    inx
    txa
    iny
    sta (zpPtr2), y
    iny
    lda #' '
    sta (zpPtr2), y
    lda #145
    iny
    sta (zpPtr2), y
    iny
    lda #' '
    sta (zpPtr2), y
    ; Right Zombie
    dex
    dex
    txa
    iny
    sta (zpPtr2), y
    inx
    txa
    iny
    sta (zpPtr2), y
    inx
    txa
    iny
    sta (zpPtr2), y



    ; Row 4/5
    ldy #120
    inx
    txa
    sta (zpPtr2), y
    inx
    txa
    iny
    sta (zpPtr2), y
    inx
    txa
    iny
    sta (zpPtr2), y
    iny
    lda #' '
    sta (zpPtr2), y
    lda #146
    iny
    sta (zpPtr2), y
    iny
    lda #' '
    sta (zpPtr2), y
    ; Right Zombie
    dex
    dex
    txa
    iny
    sta (zpPtr2), y
    inx
    txa
    iny
    sta (zpPtr2), y
    inx
    txa
    iny
    sta (zpPtr2), y



    ; Row 5/5
    ldy #160
    inx
    txa
    sta (zpPtr2), y
    inx
    txa
    iny
    sta (zpPtr2), y
    inx
    txa
    iny
    sta (zpPtr2), y
    iny
    lda #' '
    sta (zpPtr2), y
    lda #147
    iny
    sta (zpPtr2), y
    iny
    lda #' '
    sta (zpPtr2), y
    ; Right Zombie
    dex
    dex
    txa
    iny
    sta (zpPtr2), y
    inx
    txa
    iny
    sta (zpPtr2), y
    inx
    txa
    iny
    sta (zpPtr2), y

    inc DrawRightSide
    jmp pqzib_drawSomething
pqzib_done
    lda #0
    sta DrawRightSide
    jsr zombieColorSwap ; init color
    rts
DrawRightSide   .byte $00




TOP_CLEAR1 .equ 1161
TOP_CLEAR2 .equ 1162
TOP_CLEAR3 .equ 1163
TOP_CLEAR4 .equ 1164
TOP_CLEAR5 .equ 1165
TOP_CLEAR6 .equ 1166
removeBgNearTop
    lda #' '
    sta TOP_CLEAR1
    sta TOP_CLEAR2
    sta TOP_CLEAR3
    sta TOP_CLEAR4
    sta TOP_CLEAR5
    sta TOP_CLEAR6
    rts

