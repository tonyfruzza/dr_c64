JOY2            .equ 56320
VIC_MEM         .equ 53248
SCREEN_BACKGRND .equ VIC_MEM + 33
SCREEN_LOC      .equ $6000
SCREEN_LOC2     .equ $4000
SCREEN_C        .equ $D800
SCREEN_BORDER   .equ VIC_MEM + 32
COLOR_TABLE     .equ $6800
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
zpp0            .equ $b0
zpp1            .equ $b2
zpp2            .equ $b4
zpp3            .equ $b6
zpp4            .equ $b8
zpp5            .equ $ba
zpp6            .equ $bc
zpp7            .equ $be
zpp8            .equ $c0
zpp9            .equ $c2




.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00


jsr clearColors
jsr init
jsr initSineTable2
jsr initInterupt

gameLoop
    dec xoffset

    ; Figure out what to clear
;    lda $dd00
;    and #%00000010

    lda $d018
    and #%00001000
    bne clearBank2
    jsr clearBitmapData2
clearBank2
    jsr clearBitmapData
doneClearing
    jsr paintSin
    dec xoffset
    jsr paintSin
        dec xoffset
    jsr paintSin
        dec xoffset
    jsr paintSin
    jmp gameLoop


paintWithTable
; Stash x, y
    stx retX
    sty retY

    ldy savedY
    ldx savedX
    lda ytablelow,y
    sta zpp0

    lda ytablehigh,y
    sta zpp0+1

    lda $d018
    and #%00001000
    bne doNoMathWeAreNotBank1
;    sec
;    lda zpp0+1
;    sbc #$20
;    sta zpp0+1
doNoMathWeAreNotBank1
    ldy xtablelow,x
    lda (zpp0),y
    ora mask, x
    sta (zpp0),y
    ldy retY ; return Y back
    ldx retX ; return X back
    rts
savedY  .byte 0
savedX  .byte 0
retX    .byte 0
retY    .byte 0


init
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
    lda #%00111011
    sta $d011

    ; 0-2 : Horizontal raster scroll
    ;   3 : Screen width 0 = 38, 1 = 40
    ;   4 : Multicolor mode on
    ; I'm seeing 6 and 7 set to 11
    ; %1101 1000 = 40 columns, multicolor mode
    lda #%11011000
    lda #%11001000
    sta $d016

; Bitmap memory $6000, and switched to $4000 later, Color memory stays at $6800
    lda $d018
    and #%00000001
;    ora #%01111100
    ora #%11111000
    sta $d018

    lda #COLOR_BLACK
    sta SCREEN_BORDER
    rts

clearBitmapData
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

clearBitmapData2
    lda #0
    tax
clearScreenLoop2
    sta SCREEN_LOC2, x
    sta SCREEN_LOC2 + $0100, x
    sta SCREEN_LOC2 + $0200, x
    sta SCREEN_LOC2 + $0300, x
    sta SCREEN_LOC2 + $0400, x
    sta SCREEN_LOC2 + $0500, x
    sta SCREEN_LOC2 + $0600, x
    sta SCREEN_LOC2 + $0700, x
    sta SCREEN_LOC2 + $0800, x
    sta SCREEN_LOC2 + $0900, x
    sta SCREEN_LOC2 + $0a00, x
    sta SCREEN_LOC2 + $0b00, x
    sta SCREEN_LOC2 + $0c00, x
    sta SCREEN_LOC2 + $0d00, x
    sta SCREEN_LOC2 + $0e00, x
    sta SCREEN_LOC2 + $0f00, x
    sta SCREEN_LOC2 + $1000, x
    sta SCREEN_LOC2 + $1100, x
    sta SCREEN_LOC2 + $1200, x
    sta SCREEN_LOC2 + $1300, x
    sta SCREEN_LOC2 + $1400, x
    sta SCREEN_LOC2 + $1500, x
    sta SCREEN_LOC2 + $1600, x
    sta SCREEN_LOC2 + $1700, x
    sta SCREEN_LOC2 + $1800, x
    sta SCREEN_LOC2 + $1900, x
    sta SCREEN_LOC2 + $1a00, x
    sta SCREEN_LOC2 + $1b00, x
    sta SCREEN_LOC2 + $1c00, x
    sta SCREEN_LOC2 + $1d00, x
    sta SCREEN_LOC2 + $1e00, x
    sta SCREEN_LOC2 + $1f00, x
;    rts
    inx
    bne clearScreenLoop2
    rts


clearColors ; void ()
    ldx #0
    lda #COLOR_WHITE ; Draw color (forground)
    asl
    asl
    asl
    asl
    ora #COLOR_DARK_GREY ; Background color
Clearing
    sta SCREEN_C, X
    sta SCREEN_C + $100, x
    sta SCREEN_C + $200, x
    sta SCREEN_C + $300, x

    sta COLOR_TABLE + 0, x
    sta COLOR_TABLE + $100, x
    sta COLOR_TABLE + $200, x
    sta COLOR_TABLE + $300, x

    inx
    bne Clearing
    rts

initInterupt
    sei          ; turn off interrupts
    lda #$7f
    ldx #%00000001
    sta $dc0d    ; Turn off CIA 1 interrupts
    sta $dd0d    ; Turn off CIA 2 interrupts
    stx $d01a    ; Turn on raster interrupts, and sprite to sprite ints
    lda $d011
    ora $40
    sta $d011     ; Turn on bit 7
    sta $d011     ; Clear high bit of $d012, set text mode
    lda #<int1    ; low part of address of interrupt handler code
    ldx #>int1    ; high part of address of interrupt handler code
    ldy #0        ; raster line to trigger interrupt
    sta $0314     ; store in interrupt vector
    stx $0315
    sty $d012

    lda $dc0d    ; ACK CIA 1 interrupts
    lda $dd0d    ; ACK CIA 2 interrupts
    lda #0
    sta $d019
    ;asl $d019    ; ACK VIC interrupts
    cli          ; turn interrupts back on
    rts

int1
    jsr updateJoyPos
    asl $d019    ; ACK interrupt (to re-enable it)
    pla
    tay
    pla
    tax
    pla
    cli ; Turn back on the interupt
    rti          ; return from interrupt


; Manipulate paddlePos directly
updateJoyPos ; #1 is UP
    lda JOY2
    and #1
    bne nextJoy1
    jsr initSineTable
nextJoy1 ; DOWN
    lda JOY2
    and #2
    bne nextJoy2
    jsr initSineTable2
nextJoy2 ; Left
    lda JOY2
    and #4
    bne nextJoy3
;    lda $dd00
;    and #%11111100
;    ora #%00000001
;    sta $dd00 ; store bank #2
    lda $d018
    and #%11110111
    sta $d018
nextJoy3 ; Right
    lda JOY2
    and #8
    bne nextJoy4
    lda $d018
;    and #%11110111
    ora #%00001000
    sta $d018
nextJoy4
    lda JOY2
    and #16 ; Button push
    bne ButtonNotPressed
ButtonNotPressed
    rts


initSineTable
    ldy #$3f
    ldx #$00
    ; Accumulate the delta (normal 16-bit addition)
ist_loop
    lda value
    clc
    adc delta
    sta value
    lda value+1
    adc delta+1
    sta value+1

    ; Reflect the value around for a sine wave
    sta sine+$c0,x
    sta sine+$80,y
;    eor #$ff
    eor #$7f
    sta sine+$40,x
    sta sine+$00,y

    ; Increase the delta, which creates the "acceleration" for a parabola
    lda delta
;    adc #$10   ; this value adds up to the proper amplitude
    adc #$08   ; this value adds up to the proper amplitude
    sta delta
    bcc dontIncDelta
    inc delta+1
dontIncDelta
    ; Loop
    inx
    dey
    bpl ist_loop
    jsr paintSin
    rts

reflect .byte $7f
acceler .byte $08

initSineTable2
	ldx#127
prefill
	sta sine,x
	lda #19
	sta sine+52,x
	lda #250
	sta sine+128+52,x
	dex
	bpl prefill

	ldy #30
	clc
smoothloop
	lda sine,x
	adc sine,y
	ror
	sta sine,x
	iny
	inx
	bne smoothloop
	dey
	bne smoothloop
    rts


paintSin
    ldx xoffset
    txa
    clc
    adc #128
    tay
    lda #0
    sta savedX
ps_loop
    lda sine, x
;    lsr
;    lsr
    sta savedY
    inc savedY ; lower it one
    jsr paintWithTable
    ; Second line
    lda sine, y
;    lsr
;    lsr

    sta savedY
    inc savedY
    jsr paintWithTable
    inx
    iny
    inx
    iny

    inc savedX ; lower it one
    bne ps_loop
    rts

xoffset     .byte 0
xoffset2    .byte 0


value   .byte 0, 0
delta   .byte 0, 0
sine    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

