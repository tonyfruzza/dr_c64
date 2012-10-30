;OnePGameFieldLocLow   .equ $0f
;OnePGameFieldLocHigh  .equ $04

; Draw game board using char 230 as the boarder
DrawGameBoarder
    lda #$00 ; Our counter
    tax
    tay
    sta TMP1 ; used to count how many viruses we've printed

    sec
    lda #OnePGameFieldLocLow ; Low byte start location
    sbc #40
    sta zpPtr2
    lda #OnePGameFieldLocHigh ; High byte start location
    sbc #0
    sta zpPtr2+1


    lda #' '
ClearTopLineLoop
    sta (zpPtr2),y
    iny
    cpy #10
    beq dgb_start
    jmp ClearTopLineLoop

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
    jsr DrawBoarderBox

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
    lda #8 ; Width
    pha
    lda #2 ; Height
    pha
    lda #$1b
    pha
    lda #$05
    pha
    jsr DrawBoarderBox


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
    jsr DrawBoarderBox


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
    lda #5 ; width
    pha
    lda #2 ; height
    pha

    lda #$2c
    pha
    lda #$04
    pha
    jsr DrawBoarderBox


    ; Do the screen text for the first time
    ;printMsgSub ; void (ret>, ret<, txt>, txt<, pos>, pos<)
    lda #<MSG_NEXT
    pha
    lda #>MSG_NEXT
    pha

    lda #$55
    pha
    lda #$04
    pha
    jsr printMsgSub

    ; Set up the position of the "next" pill colors
    lda #$7E
    sta piece1_next
    lda #$04
    sta piece1_next+1

    lda #$7F
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


