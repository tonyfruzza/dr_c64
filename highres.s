.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00

SCREEN_LOC      .equ $6000
SCREEN_C        .equ $D800
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
VIC_MEM         .equ 53248
SCREEN_BORDER   .equ VIC_MEM + 32
SCREEN_BG_COLOR .equ VIC_MEM + 33
zpPtr1          .equ $ba
zpPtr2          .equ $bc
c1_r1_pic_ptr   .equ $be
c1_r1_scr_ptr   .equ $c0
; Color offset $1f40 "Screen"
; Color offset $2328 "Color"


    jsr init
    jsr clearScreen
    jsr ClearColors
    jsr setColorsRepeat
    jsr drawSomething

mainLoop
jmp mainLoop

    ldx #0
drawLoop
    jsr shiftScreenRight
    inx
    bne drawLoop
rts


shiftScreenRight
    clc
    lda zpPtr1
    adc #8
    sta zpPtr1
    lda zpPtr1+1
    adc #0
    sta zpPtr1+1
    jsr drawSomething
    rts



BLOCKS_WIDE     .equ 10
drawSomething
    stx tmp_x ; cache x so that we can return with original value
    lda #<highDot
    sta zpPtr2
    lda #>highDot
    sta zpPtr2+1

; Color
lda #<highDot+$1f40
sta c1_r1_pic_ptr
lda #>highDot+$1f41
sta c1_r1_pic_ptr

lda #$00
sta c1_r1_scr_ptr
lda #$5c
sta c1_r1_scr_ptr+1

    ldx #0
ds_loop
    ldy #0
; Color copy
    lda (c1_r1_pic_ptr), y
    sta (c1_r1_scr_ptr), y
; Bitmap copy
    lda (zpPtr2), y
    sta (zpPtr1), y
    iny
    lda (zpPtr2), y
    sta (zpPtr1), y
    iny
    lda (zpPtr2), y
    sta (zpPtr1), y
    iny
    lda (zpPtr2), y
    sta (zpPtr1), y
    iny
    lda (zpPtr2), y
    sta (zpPtr1), y
    iny
    lda (zpPtr2), y
    sta (zpPtr1), y
    iny
    lda (zpPtr2), y
    sta (zpPtr1), y
    iny
    lda (zpPtr2), y
    sta (zpPtr1), y
; how many wide?
    inx
    cpx #BLOCKS_WIDE
    beq ds_done
; load in next block
clc
lda c1_r1_pic_ptr


    clc
    lda zpPtr1
    adc #8
    sta zpPtr1
    lda zpPtr1+1
    adc #0
    sta zpPtr1+1

    clc
    lda zpPtr2
    adc #8
    sta zpPtr2
    lda zpPtr2+1
    adc #0
    sta zpPtr2+1
    jmp ds_loop

ds_done
    ldx tmp_x ; return x to it's previous value
    rts
pxlsWidePrinted .byte $00
tmp_x           .byte $00

setColorsRepeat
    ldx #0
scr_loop
    lda highDot+$1f40
    sta $5c00,x
    STA $5D00,X
    STA $5E00,X
    STA $5F00,X
lda highDot+$2328
    sta SCREEN_C,x
    sta SCREEN_C+$100, x
    sta SCREEN_C+$200, x
    sta SCREEN_C+$300, x
    inx
    bne scr_loop
    rts

init
    ; Set top left corner
    lda #<SCREEN_LOC
    sta zpPtr1
    lda #>SCREEN_LOC
    sta zpPtr1+1
    lda #COLOR_BLACK
    sta SCREEN_BG_COLOR



    ; Configure VIC2 memory layout
    ; This is % 0111 _101_1
    ; _101_ 4: $2000-$3FFF, 8192-16383

    ; Default is xxxx 010x which sets to ROM charset since we are in VIC bank #0
    ; Default is 0001 xxxx which sets screen memory to $0400 (1024)
    ;
    lda #$02 ; bank #1 index 0 $4000-$7FFF + $2000 = $6000, default is 3 which is bank #0
    sta $DD00

    ; Set video mode
    ; 0-2 : Veritcal raster scroll
    ;   3 : screen height 0 = 24, 1 = 25
    ;   4 : 0 screen off
    ;   5 : 0 = text mode, 1 = bitmap mode
    ;   6 : extended background mode on
    ;   7 : read/set current raster line/interrupt
    ;
    ;  7654 3210
    ; %0011 1011 = screen on, 25 rows : this is default
    lda #$3B
    sta $d011

    ; 0-2 : Horizontal raster scroll
    ;   3 : Screen width 0 = 38, 1 = 40
    ;   4 : Multicolor mode on
    ; I'm seeing 6 and 7 set to 11
    ; %1101 1000 = 40 columns, multicolor mode
    lda #$D8
    sta $d016

    ; Ends up being a value of $7d or %0111 1101
    ; Character mem at $70000, Screen memory at $5c00, Sprite 0 pointer $5ff8 ?
    lda $d018
    and #%00000001
    ora #%01111100
    sta $d018
    rts


ClearColors ; void ()
    LDX #$00
Clearing
    lda #0
    STA SCREEN_C, X
    STA SCREEN_C + $100, x
    STA SCREEN_C + $200, x
    STA SCREEN_C + $300, x
    INX
    BNE Clearing;
    RTS



clearScreen
    lda #0
    tax
clearScreenLoop
    sta SCREEN_LOC, x
    sta SCREEN_LOC + $0100, x
    sta SCREEN_LOC + $0200, x
    sta SCREEN_LOC + $0300, x
    sta SCREEN_LOC + $0400, x
    sta SCREEN_LOC + $0500, x
    sta SCREEN_LOC + $0600, x
    sta SCREEN_LOC + $0700, x
    sta SCREEN_LOC + $0800, x
    sta SCREEN_LOC + $0900, x
    sta SCREEN_LOC + $0a00, x
    sta SCREEN_LOC + $0b00, x
    sta SCREEN_LOC + $0c00, x
    sta SCREEN_LOC + $0d00, x
    sta SCREEN_LOC + $0e00, x
    sta SCREEN_LOC + $0f00, x
    sta SCREEN_LOC + $1000, x
    sta SCREEN_LOC + $1100, x
    sta SCREEN_LOC + $1200, x
    sta SCREEN_LOC + $1300, x
    sta SCREEN_LOC + $1400, x
    sta SCREEN_LOC + $1500, x
    sta SCREEN_LOC + $1600, x
    sta SCREEN_LOC + $1700, x
    sta SCREEN_LOC + $1800, x
    sta SCREEN_LOC + $1900, x
    sta SCREEN_LOC + $1a00, x
    sta SCREEN_LOC + $1b00, x
    sta SCREEN_LOC + $1c00, x
    sta SCREEN_LOC + $1d00, x
    sta SCREEN_LOC + $1e00, x
    sta SCREEN_LOC + $1f00, x
    inx
    bne clearScreenLoop
    rts

WaitFrame
    lda $d012
    cmp #0
    beq WaitFrame
    ;wait for the raster to reach line $f8 (should be closer to the start of this line this way)
WaitStep2
    lda $d012
    cmp #0
    bne WaitStep2
Return
    rts
