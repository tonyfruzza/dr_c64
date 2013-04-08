; Interup based timing events

RASTER_TO_COUNT_AT  .equ 0
DELAY2              .equ 6
songStartAdress     .equ $2300
SOUND_ROTATE        .byte $00,$f6,$00,$a0,$12,$c0,$d0,$d1,$d2,$d4,$d6,$d8,$da,$10,$00
SOUND_HORIZONTAL    .byte $00,$53,$00,$a0,$12,$c0,$d0,$d1,$d2,$d4,$d6,$d8,$da,$10,$00
SOUND_BOTTOM        .byte $82,$24,$00,$a0,$81,$90,$41,$8e,$8a,$40,$00
refreshCount        .byte $00
refreshTimer2       .byte $00
refreshTimer3       .byte $00

initRefreshCounter
    sei          ; turn off interrupts
    lda #$7f
    ldx #$01
    sta $dc0d    ; Turn off CIA 1 interrupts
    sta $dd0d    ; Turn off CIA 2 interrupts
    stx $d01a    ; Turn on raster interrupts

    ; Set video mode
    ; %0001 1011 = screen on, 25 rows : this is default
    lda #$1b
    sta $d011
    ; %0001 1000 = 40 columns, multicolor mode
    lda #$18 ;
    sta $d016



    lda #<irq_refreshCounter    ; low part of address of interrupt handler code
    ldx #>irq_refreshCounter    ; high part of address of interrupt handler code
    ldy #RASTER_TO_COUNT_AT     ; line to trigger interrupt
    sta $0314    ; store in interrupt vector
    stx $0315
    sty $d012

    lda $dc0d    ; ACK CIA 1 interrupts
    lda $dd0d    ; ACK CIA 2 interrupts
    asl $d019    ; ACK VIC interrupts
    cli          ; turn interrupts back on
    rts


irq_refreshCounter ; void (y, x, a)
    jsr songStartAdress+3
    inc refreshCount
    inc refreshTimer2
    inc refreshTimer3

; For input timers, these shouldn't roll over
    ldx #10 ; cached value for reseting a roll over

    inc f_repeatTime ; Fire button repeat
    bne fNoReset
    stx f_repeatTime
fNoReset
    inc r_repeatTime
    bne rNoReset
    stx r_repeatTime
rNoReset
    inc l_repeatTime
    bne lNoReset
    stx l_repeatTime
lNoReset
    inc d_repeatTime
    lda refreshTimer3
    cmp DELAY
    bne noRefreshTimer3Work
    jsr cycleAnimatedViruses
    lda #0
    sta refreshTimer3

;    jsr cycleBackgroundAnimation
noRefreshTimer3Work

    asl $d019    ; ACK interrupt (to re-enable it)

    pla
    tay
    pla
    tax
    pla

;    jmp $ea31 ; Go back to the default interupt address
    rti          ; return from interrupt


WaitEventFrame
    lda #0
    sta refreshTimer2
waitStart
    lda #DELAY2
    cmp refreshTimer2
    bcc waitDone ; >= than DELAY2
    jmp waitStart
waitDone
    rts
