
.org $0801
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00
firstRaster     .equ 0
SPRITE_LOC      .equ 50
SPRITE_LOC_Y    .equ 0
VIC_MEM         .equ 53248
SCREEN_BORDER   .equ VIC_MEM + 32
CHROUT          .equ $FFD2


entryPoint
    sei          ; turn off interrupts
    lda #$7f
    ldx #$01
    sta $dc0d    ; Turn off CIA 1 interrupts
    sta $dd0d    ; Turn off CIA 2 interrupts
    stx $d01a    ; Turn on raster interrupts

    lda $d011
    ora $40
    sta $d011 ; Turn on bit 7

    lda #<irq1    ; low part of address of interrupt handler code
    ldx #>irq1    ; high part of address of interrupt handler code
    ldy #firstRaster     ; line to trigger interrupt
    sta $0314    ; store in interrupt vector
    stx $0315
    sty $d012 ; Which raster line to execute at

    lda $dc0d    ; ACK CIA 1 interrupts
    lda $dd0d    ; ACK CIA 2 interrupts
    asl $d019    ; ACK VIC interrupts
    cli          ; turn interrupts back on


;loop
;jsr printSomeChar
;   jmp loop
rts




pullFromQueueAndWorkIt
    dec qCount
    ldx qCount

    lda qUp, x
    pha
    lda qLow, x ; Why does it skip ahead one byte when jmp rts'ing
    tax
    dex
    txa
    pha
    ; put registers back to how they were.
;    lda qAXY
;    ldx qAXY+1
;    ldy qAXY+2
    rts ; Now jump to it, and then come back
    ; store current registers
;    sta qAXY
;    stx qAXY+1
;    sty qAXY+2
    rts

pushOnToQueue
    ldx qCount

    lda qUpNew
    sta qUp, x

    lda qLowNew
    sta qLow, x
    inc qCount
    rts

qCount  .byte $00
qUpNew  .byte $00
qLowNew .byte $00
qUp     .byte $00, $00, $00, $00, $00, $00, $00
qLow    .byte $00, $00, $00, $00, $00, $00, $00
qAXY    .byte $00, $00, $00




; Interrupt area
irq1
    inc SCREEN_BORDER
    jsr get_random_number
    and #1
    bne noNewPrint
    ; random again
    jsr get_random_number
    and #1
    bne noNewPrint
    ; Add something to worker queue
    lda #<printSomeChar
    sta qLowNew
    lda #>printSomeChar
    sta qUpNew
    jsr pushOnToQueue
    jsr pullFromQueueAndWorkIt
noNewPrint



    asl $d019    ; ACK interrupt (to re-enable it)

;    pla
;    tay
;    pla
;    tax
;    pla
dec SCREEN_BORDER
jmp $ea31
;    rti          ; return from interrupt


get_random_number ; reg a ()
    lda $d012 ; load current screen raster value
    eor $dc04 ; xor against value in $dc04
    sbc $dc05 ; then subtract value in $dc05
    rts


printSomeChar
    lda #65
    jsr CHROUT
    rts