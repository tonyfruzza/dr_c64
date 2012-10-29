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

    cpx #7; >= 5
    bcc noVirusRowsYet

doRandomVirus
;jmp noVirusRowsYet ; if you don't want any viruses put this line in
    lda zpPtr2
    pha
    lda zpPtr2+1
    pha
    jsr printRandomVirus
    ;
noVirusRowsYet
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