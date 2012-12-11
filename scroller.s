.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00

SCREEN_LOC  .equ $0400
VMEM        .equ $D000
SCREEN_C    .equ $0400
VIC_MEM         .equ 53248
SCREEN_BOARDER  .equ VIC_MEM + 32
COLOR_BLACK     .equ $00
COLOR_WHITE     .equ $01
COLOR_RED       .equ $02
COLOR_CYAN      .equ $03
COLOR_MAGENTA   .equ $04
COLOR_GREEN     .equ $05
COLOR_BLUE      .equ $06
COLOR_YELLOW    .equ $07
COLOR_ORANGE    .equ $08
COLOR_BROWN     .equ $09
COLOR_PINK      .equ $0a
COLOR_DARK_GREY .equ $0b
COLOR_GREY      .equ $0c
COLOR_L_GREEN   .equ $0d
COLOR_L_BLUE    .equ $0e
COLOR_L_GREY    .equ $0f


    lda #34
    sta times
scrollOuterLoop
    ldx #38
    ldy #0
scroll
    lda SCREEN_LOC+41,y
    sta SCREEN_LOC+40,y
    iny
    dex
    bpl scroll
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
ldy offset
lda newchar, y
inc offset
sta SCREEN_LOC+79
    dec times
    bne scrollOuterLoop
    rts

offset  .byte $00
newchar .byte 17, 21, 9, 20, 32, 32, 32, 32, 32, 32, 18, 5, 20, 21, 18, 14, 32, 32, 32, 32, 32, 32, 32
        .byte 18, 5, 19, 20, 1, 18, 20, 32, 32, 32, 32
times   .byte 40


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