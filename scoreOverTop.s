; Sprite Locations
; 24, 50 is top right = character 0
; 24 + ((CHAR-1024)%40)*8 = x , 50 + (ABS((CHAR-1024)/40))*8 = y
; TEST FOR
; CHAR = 1
; 24 + (1%40)*8 = 32, 50 + 0 = 50
SetSpriteBasedOnCharPos
sta showScoreAXY
stx showScoreAXY+1
sty showScoreAXY+2
    ; Copy pos into temp location
    ; Subtract 1024 (screen memory location)
    sec
    lda placeScoreHere
    sbc #$00
    sta charPosCopy
    lda placeScoreHere+1
    sbc #$04
    sta charPosCopy+1

    ; Divide pos / 40
    ; TLQ[charPosCopy],TH[charPosCopy+1] / B[#40] = TLQ[charPosCopy] (overwritten)
    ; Accumulator has remainder
    LDA charPosCopy+1
    LDX #8
    ASL charPosCopy
DIV1
    ROL
    BCS DIV2
    CMP #40
    BCC DIV3
DIV2
    SBC #40
    SEC
DIV3
    ROL charPosCopy
    DEX
    BNE DIV1
    ; Accumulator set to remainder right now, multiply that by 8 to get X offset
    asl
    asl
    asl
    ; Add 24
    clc
    adc #24
    sta $d004

    ; Multiply by 8
    lda charPosCopy
    asl
    asl
    asl
    ;sta charPosCopy
    ; Now just add 50
    ;    lda charPosCopy
    clc
    adc #50
    sta $d005
; Display sprite by enabling
    lda #COLOR_WHITE
    sta VMEM+41
    lda $d015
    ora #4 ; for sprite 3
    sta $d015
    lda #25
    sta framesToShowSprite
    jsr writeScoreIntoSprite
    lda showScoreAXY
    ldx showScoreAXY+1
    ldy showScoreAXY+2
    rts

placeScoreHere      .byte $00, $00
charPosCopy         .byte $00, $00
framesToShowSprite  .byte $00
showScoreAXY        .byte $00, $00, $00

writeScoreIntoSprite
    jsr clearScoreSprite
    ; Using sprite 3 and his data is located at SPRITE3_DATA
    ; each number is 4x5 bytes (20 bytes total)
    ldx #0
    ldy #0
copySmallNumToSprite
; X***
    lda SN23, x
    and #$0f ; Only use the first nibble
asl
asl
asl
asl
    sta firstDigit
; *X**
    lda SN01, x
    and #$F0 ; Only use the first nibble
    lsr
    lsr
    lsr
    lsr
    ora firstDigit
    sta SPRITE3_DATA,y
    iny

; **X*
    lda SN01, x
    and #$f0
    sta firstDigit
; ***X
    lda SN23, x
    and #$00
    ora firstDigit
sta SPRITE3_DATA,y

    iny
    iny
    inx
    cpx #5
    bne copySmallNumToSprite
    rts

clearScoreSprite
    ; sprite is 3bytes by 21, so it's 63 bytes total
    ldx #0
    txa
css_loop
    sta SPRITE3_DATA,x
    inx
    cpx #63
    bne css_loop
    rts

firstDigit     .byte $00