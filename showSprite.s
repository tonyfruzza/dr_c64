VIC_MEM         .equ 53248
SPRITE_LOC      .equ 24
SPRITE_LOC_Y    .equ 50
SPRITE_DATA_LOC .equ $3000
piece1          .equ $b0

.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00


init
    jsr copySpriteDataIn
; Let VIC know where sprite 0 is located
    lda #$C0 ; $3000/$40 =  $C0
    sta $07f8

    ; Set color to white
    lda #1
    sta VIC_MEM+39

    ; Sprite 0 Location
    lda #SPRITE_LOC
    ldx #SPRITE_LOC_Y
    sta $d000
    stx $d001

    ; Enable Sprite 0
    lda #$01
    sta $d015

    lda #$41
    sta piece1
    lda #$01
    sta piece1+1

    jsr SetSpriteBasedOnCharPos
    rts



copySpriteDataIn
    ldx #63
csdi_loop
    dex
    lda CUST_SPRITE_0, x
    sta SPRITE_DATA_LOC, x
    txa
    bne csdi_loop
rts

; Sprite Locations
; 24, 50 is top right = character 0
; 24 + (CHAR%40)*8 = x , 50 + (ABS(CHAR/40))*8 = y
; TEST FOR
; CHAR = 1
; 24 + (1%40)*8 = 32, 50 + 0 = 50
SetSpriteBasedOnCharPos
; Copy pos into temp location
lda piece1
sta charPosCopy
lda piece1+1
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
    sta $d000

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
    sta $d001
    rts
charPos     .byte $00 ; try 8 bit value first
charPosCopy .byte $00, $00
spritePosY  .byte $00

