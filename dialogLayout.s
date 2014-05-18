; Draw their talking room
BLOCK_TL    .equ 139
BLOCK_TR    .equ 140
BLOCK_BL    .equ 141
BLOCK_BR    .equ 142

draw2x2BlockToZpPtr1
    ldy #0
    lda #BLOCK_TL
    sta (zpPtr1),y
    iny
    lda #BLOCK_TR
    sta (zpPtr1),y
    ldy #40
    lda #BLOCK_BL
    sta (zpPtr1),y
    iny
    lda #BLOCK_BR
    sta (zpPtr1),y
    rts

drawChatRoom
    lda #CLEAR_CHAR
    sta clearingChar
    jsr ClearScreen
    jsr drawScreenFrame
    ldx #0
drawThosBoxes
    lda boxLocationsLow, x
    beq dtb_done
    sta zpPtr1
    lda boxLocationsHigh, x
    sta zpPtr1+1
    jsr draw2x2BlockToZpPtr1
    inx
    jmp drawThosBoxes
dtb_done
    rts

waitForInput
    jsr getFireButtonPressed
    beq waitForInput
    rts

doTheChatRoom
    jsr drawChatRoom
    jsr waitForInput
    rts

boxLocationsLow     .byte $52, $54, $56, $58, $5a, $5c, $60, $a2, $a4, $a6, $a8, $f2, $f4, $42, $92, $32, 0
boxLocationsHigh    .byte $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $05, $05, $06, 0