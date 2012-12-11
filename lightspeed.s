.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00

VIC_MEM         .equ 53248
SCREEN_BOARDER  .equ VIC_MEM + 32
SCREEN_BG_COLOR .equ VIC_MEM + 33
SCREENMEM       .equ 1024
COLORMEM        .equ $D400 + SCREENMEM
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

jmp init
; Vars
HLINE           .byte $00
HLINESPACING    .byte $32
COLOR_GROUP     .byte COLOR_BLACK, COLOR_WHITE, COLOR_GREEN, COLOR_L_GREEN, COLOR_GREY


init
lda #COLOR_GREEN
sta SCREEN_BG_COLOR
jsr ClearScreen
    ldx #00
loop
lda COLOR_GROUP, x
    sta SCREEN_BOARDER
    inx
    cpx #5
    bne XGood
    ldX #00
XGood

    jsr WaitFrame
    lda HLINESPACING
    clc
    adc HLINE
    sta HLINE
    jmp loop




WaitFrame   lda $d012
            cmp HLINE
            beq WaitFrame
            ;wait for the raster to reach line $f8 (should be closer to the start of this line this way)
WaitStep2   lda $d012
            cmp HLINE
            bne WaitStep2
Return      rts


ClearScreen LDX #$00
            LDA #COLOR_L_GREEN
Clearing    STA COLORMEM, X
            STA COLORMEM + $100, x
            STA COLORMEM + $200, x
            STA COLORMEM + $300, x
            INX
            BNE Clearing;
RTS