.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00

SCREENMEM   .equ 1024
SCREENMEM2  .equ 2048

jmp vScrollScreenOff
; load 2nd line from top place into 1st line, go down 25 lines
; load_labels "/Users/Tony/Development/DrC64/labels.txt"
zpPtr1  .equ $ba
zpPtr2  .equ $bc

vScrollScreenOff
    ; Set screen height to 24 chars
    lda $d011
    and #%11110111
    sta $d011


    lda #0
    sta vScrollTimes
start
    jsr flipScreen
    lda screenbuf
    and #$1
beq writeToBackBuffer
    clc
    lda #<SCREENMEM
    sta zpPtr1
    adc #40
    sta zpPtr2
    lda #>SCREENMEM
    sta zpPtr1+1
    adc #0
    sta zpPtr2+1
    jmp startTheFlipping
writeToBackBuffer
    clc
    lda #<SCREENMEM2
    sta zpPtr1
    adc #40
    sta zpPtr2
    lda #>SCREENMEM2
    sta zpPtr1+1
    adc #0
    sta zpPtr2+1
startTheFlipping

    ldx #0
loop_0
    ldy #0
loop_1
    lda (zpPtr2), y
    sta (zpPtr1),y
    iny
    cpy #40
    bne loop_1
    clc
    lda zpPtr1
    adc #40
    sta zpPtr1
    lda zpPtr1+1
    adc #0
    sta zpPtr1+1
    clc
    lda zpPtr2
    adc #40
    sta zpPtr2
    lda zpPtr2+1
    adc #0
    sta zpPtr2+1
    inx
    cpx #24
    bne loop_0
justSoftScroll
    inc vScrollTimes
    jsr softScrollScreen2
    lda vScrollTimes
    cmp #25
    bne start
    rts
vScrollTimes    .byte $00

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


softScrollScreen2
    ; Reset scroller
    lda $d011
    and #%11111000
    ora #%00000111
    sta $d011 ; 0px 8
    jsr WaitFrame
    jsr WaitFrame
    dec $d011 ; 1px 7
    jsr WaitFrame
    jsr WaitFrame
    dec $d011 ; 2px 6
    jsr WaitFrame
    jsr WaitFrame
    dec $d011 ; 3px 5
    jsr WaitFrame
    jsr WaitFrame
    dec $d011 ; 4px 4
    jsr WaitFrame
    jsr WaitFrame
    dec $d011 ; 5px 3
    jsr WaitFrame
    jsr WaitFrame
    dec $d011 ; 6px 2
    jsr WaitFrame
    jsr WaitFrame
    dec $d011 ; 7px 1
    jsr WaitFrame
    jsr WaitFrame
lda $d011
and #%11111000
ora #%00000111
    rts

flipScreen
    lda screenbuf
    and #$1
    beq setToBackBuffer
    lda $d018
    and #%00001111
    ora #%00010000
    sta $d018
    inc screenbuf
    rts
setToBackBuffer
    lda $d018
    and #%00001111
    ora #%00100000
    sta $d018
    inc screenbuf
    rts


screenbuf   .byte $00

