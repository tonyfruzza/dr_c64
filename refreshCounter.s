; Interup based timing events

RASTER_TO_COUNT_AT  .equ 0
DELAY2              .equ 6

initRefreshCounter
    jmp irc_start
    refreshCount    .byte $00
    refreshTimer2   .byte $00
    refreshTimer3   .byte $00
irc_start
    sei          ; turn off interrupts
    lda #$7f
    ldx #$01
    sta $dc0d    ; Turn off CIA 1 interrupts
    sta $dd0d    ; Turn off CIA 2 interrupts
    stx $d01a    ; Turn on raster interrupts

    lda #$1b
    ;ldx #$08
    ;ldy #$14
sta $d011    ; Clear high bit of $d012, set text mode
    ;stx $d016    ; single-colour
    ;sty $d018    ; screen at $0400, charset at $2000

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
    inc refreshCount
    inc refreshTimer2
    inc refreshTimer3

; For input timers, these shouldn't roll over
    ldx #10 ; cached value for reseting a roll over
    inc r_repeatTime
    bne rNoReset
    stx r_repeatTime
rNoReset
    inc l_repeatTime
    bne lNoReset
    stx l_repeatTime
lNoReset
    inc d_repeatTime
    inc rotate_repeatTime

    lda refreshTimer3
    cmp #DELAY
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
