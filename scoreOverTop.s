
; For calculating and displaying sprite scores where pieces are cleared
;
SPRITE1_DATA    .equ $0240
SPRITE2_DATA    .equ $0280
SPRITE3_DATA    .equ $02C0

SPRITE1_POINT   .equ $07f8
SPRITE2_POINT   .equ $07f9
SPRITE3_POINT   .equ $07fa

virusesClearedForPopUpScore .byte $00
;                                   0,   1,   2,   3,   4,   5,   6 Virus clears values / 100
scorePreCalcValues          .byte $00, $01, $03, $07, $15, $31, $63


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
;    jsr figureOutScoreForPopOver ; get the score set into accumOfScore
;    jsr convertPopOverScoreToHex2
    jsr clearScoreSprite
    ; Using sprite 3 and his data is located at SPRITE3_DATA
    ; each number is 4x5 bytes (20 bytes total)

    ldx virusesClearedForPopUpScore
    lda scorePreCalcValues, x
    and #$f0
    lsr
    lsr
    lsr
    lsr
    sta scoreDigitsToPrint
    lda scorePreCalcValues, x
    and #$0f
    sta scoreDigitsToPrint+1


    ldx #0
    ldy #0
copySmallNumToSprite
; X***
    lda #0
    sta copyDigit
    lda scoreDigitsToPrint
    beq csnts_gotDigit1 ; Don't print anything for leading 0 to score
    ; possible values are 1, 3, or 6
    cmp #1
    bne csnts_three
    lda SN01, x
    asl
    asl
    asl
    asl
    sta copyDigit
    jmp csnts_gotDigit1
csnts_three
    cmp #3
    bne csnts_six
    lda SN23, x
    asl
    asl
    asl
    asl
    sta copyDigit
    jmp csnts_gotDigit1
csnts_six
    ; default down to 6
    lda SN67, x
    and #$f0
    sta copyDigit
csnts_gotDigit1
; *X**
; Possible values are: 1, 3, 5, 7
    lda scoreDigitsToPrint+1
    cmp #1
    bne csnts_three_2
    lda SN01, x
    and #$0f
    jmp csnts_gotDigit2
csnts_three_2
    cmp #3
    bne csnts_five_2
    lda SN23, x
    and #$0f
    jmp csnts_gotDigit2
csnts_five_2
    cmp #5
    bne csnts_seven_2
    lda SN45, x
    and #$0f
    jmp csnts_gotDigit2
csnts_seven_2 ; default
    lda SN67, x
    and #$0f
csnts_gotDigit2
    ora copyDigit ; Put the 2 digits together
    sta SPRITE3_DATA,y
    iny
; These are always 00 ie 100, 300, 700, etc.
; **X*
    lda SN01, x
    and #$f0
    sta copyDigit
; ***X
    lda SN01, x
    and #$f0
    lsr
    lsr
    lsr
    lsr
    ora copyDigit
sta SPRITE3_DATA,y

    iny
    iny
    inx
    cpx #5
beq csnts_done
jmp copySmallNumToSprite
csnts_done
    rts

copyDigit           .byte $00
scoreDigitsToPrint  .byte $00, $00


clearScoreSprite ; set bytesToClearForSprite to 63 initially then 15
    ; sprite is 3bytes by 21, so it's 63 bytes total
    ; when only clearing the first 5 lines it's 5*3 = 15 bytes total
    lda #11
    sta SPRITE3_POINT
    lda #COLOR_WHITE
    sta VMEM+41

    ldx #0
    txa
css_loop
    sta SPRITE3_DATA,x
    inx
    cpx bytesToClearForSprite
    bne css_loop
    rts

bytesToClearForSprite .byte $00