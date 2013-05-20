SCREENMEM   .equ 1024 ; Start of character screen map, color map is + $D400
NEWCHARMAP  .equ 12288 ; $3000 new place for Charset
FRIDAY_LOC  .equ 1278
VIC_MEM         .equ 53248
SCREEN_BOARDER  .equ VIC_MEM + 32
SCREEN_BG_COLOR .equ VIC_MEM + 33
COLORMEM    .equ $D800
RASTER_TO_COUNT_AT  .equ 80
;songStartAdress     .equ $2300
songStartAdress     .equ $5000
zpp0            .equ $b0
COLOR_BLACK     .equ $00
COLOR_WHITE     .equ $01
COLOR_DARK_GREY .equ $0b
COLOR_GREY      .equ $0c
COLOR_L_GREY    .equ $0f


.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00


start
    ; Set video mode
    ; %0001 1011 = screen on, 25 rows : this is default
    lda #$1b
    sta $d011
    ; %0001 1000 = 40 columns, multicolor mode
    lda #$08 ;
    sta $d016

    ; Tell VIC where to get charmap from
    lda 53272 ; $D018
    and #240
    clc
    adc #12
    sta 53272

    ; Set background colors
    lda #0
    sta $d020
    sta $d021
    lda #1
    sta $d022
    lda #4
    sta $d023

    jsr ClearScreen
    jsr printBlock


mainLoop
;    jsr cycleCharAni
;    jsr WaitFrame
;    jsr WaitFrame
;   jsr WaitFrame
;    jsr WaitFrame
;    jsr WaitFrame
;    jsr WaitFrame
;    jsr WaitFrame
;    jsr WaitFrame
    jsr setRandomDataForChar0
    jsr changeBackgroundColor
    jmp mainLoop
    rts

changeBackgroundColor
    jsr get_random_number
    and #1
    beq storeBlack
    and #2
    beq storeGrey
    lda #1
    sta SCREEN_BG_COLOR
    rts
storeGrey
    lda #COLOR_GREY
    sta SCREEN_BG_COLOR
storeBlack
    sta SCREEN_BG_COLOR
    rts

; Try and set some random data at the character 0
; character is 8 characters long
setRandomDataForChar0
    lda <CUST_CHAR_0
    sta zpp0
    lda >CUST_CHAR_0
    sta zpp0+1
    ldy #0
doSomeRandom
    jsr get_random_number ; load random value into A
    sta NEWCHARMAP, y
    iny
    cpy #8
    bne doSomeRandom
    rts

printBlock
    lda #0
    sta SCREENMEM
    rts


ClearScreen ; void ()
    LDX #$00
Clearing
    lda #0
    STA SCREENMEM, X
    STA SCREENMEM + $100, x
    STA SCREENMEM + $200, x
    STA SCREENMEM + $300, x
    lda #$01
    sta COLORMEM, x
    sta COLORMEM + $100, x
    sta COLORMEM + $200, x
    sta COLORMEM + $300, x
    inx
    BNE Clearing;
    RTS

get_random_number ; reg a ()
    lda $d012 ; load current screen raster value
    eor $dc04 ; xor against value in $dc04
    sbc $dc05 ; then subtract value in $dc05
    rts

cycleCharAni ; Using char 0
    ldx #0
    ldy charCount
    cpy #8
    bne loadCharLoop
    ldy #0
    sty charCount

loadCharLoop
    cpy #0
    bne charCountNot0
    lda CUST_CHAR_0, x   ; 8 * 0 * 0
    sta NEWCHARMAP, x    ; static 8 * 0

    jmp charCountNot0
    lda CUST_CHAR_0+8, x ; (8 * 0) + 8
    sta NEWCHARMAP+8, x  ; static 8 * 1

    lda CUST_CHAR_0+128, x ; 8 * 0 + 128
    sta NEWCHARMAP+16, x  ; 8 * 2
    lda CUST_CHAR_0+136, x ; 8 * 0 + 128 + 8
    sta NEWCHARMAP+24, x  ; 8 * 3

charCountNot0
    cpy #1
    bne charCountNot1
    lda CUST_CHAR_0+16, x   ; 8 * 2 * 1
    sta NEWCHARMAP, x    ; static 8 * 0
    lda CUST_CHAR_0+24, x  ; 8 * 2 * 1 + 8
    sta NEWCHARMAP+8, x  ; static 8 * 1

    lda CUST_CHAR_0+144, x ; 8 * 2 * 1 + 128
    sta NEWCHARMAP+16, x  ; static  8 * 2
    lda CUST_CHAR_0+152, x ; 8 * 2 * 1 + 128 + 8
    sta NEWCHARMAP+24, x  ; static 8 * 3

charCountNot1
    cpy #2
    bne charCountNot2
    lda CUST_CHAR_0+32, x   ; 8 * 2 * 2
    sta NEWCHARMAP, x    ; static 8 * 0
    lda CUST_CHAR_0+40, x  ; 8 * 2 * 2 + 8
    sta NEWCHARMAP+8, x  ; static 8 * 1

    lda CUST_CHAR_0+160, x ; 8 * 2 * 2 + 128
    sta NEWCHARMAP+16, x  ; static  8 * 2
    lda CUST_CHAR_0+168, x ; 8 * 2 * 2 + 128 + 8
    sta NEWCHARMAP+24, x  ; static 8 * 3

charCountNot2
    cpy #3
    bne charCountNot3
    lda CUST_CHAR_0+48, x   ; 8 * 2 * 3
    sta NEWCHARMAP, x    ; static 8 * 0
    lda CUST_CHAR_0+56, x  ; 8 * 2 * 3 + 8
    sta NEWCHARMAP+8, x  ; static 8 * 1

    lda CUST_CHAR_0+176, x ; 8 * 2 * 3 + 128
    sta NEWCHARMAP+16, x  ; static  8 * 2
    lda CUST_CHAR_0+184, x ; 8 * 2 * 3 + 128 + 8
    sta NEWCHARMAP+24, x  ; static 8 * 3

charCountNot3
    cpy #4
    bne charCountNot4
    lda CUST_CHAR_0+64, x   ; 8 * 2 * 4
    sta NEWCHARMAP, x    ; static 8 * 0
    lda CUST_CHAR_0+72, x  ; 8 * 2 * 4 + 8
    sta NEWCHARMAP+8, x  ; static 8 * 1

    lda CUST_CHAR_0+192, x ; 8 * 2 * 4 + 128
    sta NEWCHARMAP+16, x  ; static  8 * 2
    lda CUST_CHAR_0+200, x ; 8 * 2 * 4 + 128 + 8
    sta NEWCHARMAP+24, x  ; static 8 * 3

charCountNot4
    cpy #5
    bne charCountNot5
    lda CUST_CHAR_0+80, x   ; 8 * 2 * 5
    sta NEWCHARMAP, x    ; static 8 * 0
    lda CUST_CHAR_0+88, x  ; 8 * 2 * 5 + 8
    sta NEWCHARMAP+8, x  ; static 8 * 1

    lda CUST_CHAR_0+208, x ; 8 * 2 * 5 + 128
    sta NEWCHARMAP+16, x  ; static  8 * 2
    lda CUST_CHAR_0+216, x ; 8 * 2 * 5 + 128 + 8
    sta NEWCHARMAP+24, x  ; static 8 * 3

charCountNot5
    cpy #6
    bne charCountNot6
    lda CUST_CHAR_0+96, x   ; 8 * 2 * 6
    sta NEWCHARMAP, x    ; static 8 * 0
    lda CUST_CHAR_0+104, x  ; 8 * 2 * 6 + 8
    sta NEWCHARMAP+8, x  ; static 8 * 1

    lda CUST_CHAR_0+224, x ; 8 * 2 * 6 + 128
    sta NEWCHARMAP+16, x  ; static  8 * 2
    lda CUST_CHAR_0+232, x ; 8 * 2 * 6 + 128 + 8
    sta NEWCHARMAP+24, x  ; static 8 * 3

charCountNot6
    cpy #7
    bne charCountLost
    lda CUST_CHAR_0+112, x   ; 8 * 2 * 7
    sta NEWCHARMAP, x    ; static 8 * 0
    lda CUST_CHAR_0+120, x  ; 8 * 2 * 7 + 8
    sta NEWCHARMAP+8, x  ; static 8 * 1

    lda CUST_CHAR_0+240, x ; 8 * 2 * 7 + 128
    sta NEWCHARMAP+16, x  ; static  8 * 2
    lda CUST_CHAR_0+248, x ; 8 * 2 * 7 + 128 + 8
    sta NEWCHARMAP+24, x  ; static 8 * 3

charCountLost


    inx
    cpx #8
    beq loadCharLoopFinished
    jmp loadCharLoop
loadCharLoopFinished
    inc charCount ; next character next time
    rts
charCount   .byte 0


WaitFrame
    lda $d012
    cmp #0
    beq WaitFrame
    ;wait for the raster to reach line $f8 (should be closer to the start of this line this way)
WaitStep2   lda $d012
    cmp #0
    bne WaitStep2
Return
    rts

CUST_CHAR_0 .byte 85, 170, 0, 221, 119, 0, 170, 85
;CUST_CHAR_0 .byte 0, 0, 63, 63, 240, 240, 243, 243
CUST_CHAR_1 .byte 0, 0, 240, 240, 252, 252, 252, 252
CUST_CHAR_2 .byte 63, 63, 240, 240, 243, 243, 255, 255
CUST_CHAR_3 .byte 240, 240, 252, 252, 252, 252, 252, 252
CUST_CHAR_4 .byte 240, 240, 243, 243, 255, 255, 255, 255
CUST_CHAR_5 .byte 252, 252, 252, 252, 252, 252, 252, 252
CUST_CHAR_6 .byte 243, 243, 255, 255, 255, 255, 255, 255
CUST_CHAR_7 .byte 252, 252, 252, 252, 252, 252, 252, 252
CUST_CHAR_8 .byte 255, 255, 255, 255, 255, 255, 63, 63
CUST_CHAR_9 .byte 252, 252, 252, 252, 252, 252, 240, 240
CUST_CHAR_10 .byte 255, 255, 255, 255, 63, 63, 0, 0
CUST_CHAR_11 .byte 252, 252, 252, 252, 240, 240, 0, 0
CUST_CHAR_12 .byte 255, 255, 63, 63, 0, 0, 63, 63
CUST_CHAR_13 .byte 252, 252, 240, 240, 0, 0, 240, 240
CUST_CHAR_14 .byte 63, 63, 0, 0, 63, 63, 240, 240
CUST_CHAR_15 .byte 240, 240, 0, 0, 240, 240, 252, 252
CUST_CHAR_16 .byte 255, 255, 255, 255, 255, 255, 63, 63
CUST_CHAR_17 .byte 252, 252, 252, 252, 252, 252, 240, 240
CUST_CHAR_18 .byte 255, 255, 255, 255, 63, 63, 0, 0
CUST_CHAR_19 .byte 252, 252, 252, 252, 240, 240, 0, 0
CUST_CHAR_20 .byte 255, 255, 63, 63, 0, 0, 63, 63
CUST_CHAR_21 .byte 252, 252, 240, 240, 0, 0, 240, 240
CUST_CHAR_22 .byte 63, 63, 0, 0, 63, 63, 240, 240
CUST_CHAR_23 .byte 240, 240, 0, 0, 240, 240, 252, 252
CUST_CHAR_24 .byte 0, 0, 63, 63, 240, 240, 243, 243
CUST_CHAR_25 .byte 0, 0, 240, 240, 252, 252, 252, 252
CUST_CHAR_26 .byte 63, 63, 240, 240, 243, 243, 255, 255
CUST_CHAR_27 .byte 240, 240, 252, 252, 252, 252, 252, 252
CUST_CHAR_28 .byte 240, 240, 243, 243, 255, 255, 255, 255
CUST_CHAR_29 .byte 252, 252, 252, 252, 252, 252, 252, 252
CUST_CHAR_30 .byte 243, 243, 255, 255, 255, 255, 255, 255
CUST_CHAR_31 .byte 252, 252, 252, 252, 252, 252, 252, 252