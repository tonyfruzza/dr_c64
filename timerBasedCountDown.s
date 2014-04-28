.org $0801
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00

VIC_MEM         .equ 53248
SCREEN_BORDER   .equ VIC_MEM + 32
SCREEN_BG_COLOR .equ VIC_MEM + 33
TIME_MINUTES_START  .equ $30
TIME_SECONDS_START  .equ $10
SCREEN_MEM          .equ $0400

entryPoint
    sei          ; turn off interrupts
    lda #$7f
    ldx #$01
    sta $dc0d    ; Turn off CIA 1 interrupts
    sta $dd0d    ; Turn off CIA 2 interrupts
    stx $d01a    ; Turn on raster interrupts
    lda $d011
    ora $40
    sta $d011     ; Turn on bit 7
    sta $d011     ; Clear high bit of $d012, set text mode
    lda #<int1    ; low part of address of interrupt handler code
    ldx #>int1    ; high part of address of interrupt handler code
    ldy #25      ; raster line to trigger interrupt
    sta $0314   ; store in interrupt vector
    stx $0315
    sty $d012

    lda $dc0d    ; ACK CIA 1 interrupts
    lda $dd0d    ; ACK CIA 2 interrupts
    asl $d019    ; ACK VIC interrupts
    cli          ; turn interrupts back on


init
    ; Set init time
    lda #TIME_MINUTES_START
    sta timeMinutesDec
    lda #TIME_SECONDS_START
    sta timeSecondsDec
    lda #60
    sta counterFraction

gameLoop
rts
    jmp gameLoop

int1
    asl $d019    ; ACK interrupt (to re-enable it)
    dec counterFraction
    bne dontResetTimer ; not 0 yet

    ;inc SCREEN_BORDER
    lda #60
    sta counterFraction
    jsr decrementByASecond
    jsr printTimer
dontResetTimer
    ; Restore values back from stack
;    pla
;    tay
;    pla
;    tax
;    pla
;    cli ; Turn back on the interupt
;    rti          ; return from interrupt
;    rts
jmp $ea31
counterFraction .byte $00

printTimer
    ldx timeMinutesDec
    txa
    and #$f0
    lsr
    lsr
    lsr
    lsr
    ora #$30
    sta SCREEN_MEM
    txa
    and #$0f
    ora #$30
    sta SCREEN_MEM+1
    lda #58 ; ':'
    sta SCREEN_MEM+2
    ldx timeSecondsDec
    txa
    and #$f0
    lsr
    lsr
    lsr
    lsr
    ora #$30
    sta SCREEN_MEM+3
    txa
    and #$0f
    ora #$30
    sta SCREEN_MEM+4
    rts


decrementByASecond
    ; Look to see if seconds is 0
    lda timeSecondsDec
    bne decAsUsual
    ; See if minute is also 0
    lda timeMinutesDec
    beq timerRanOut
    ; Seconds was 0 so set to 60
    lda #$60
    sta timeSecondsDec
    ; Since seconds rolled under, we need to decrement our minute counter
    lda timeMinutesDec
    beq timerRanOut
    sed ; Going decimal mode
    sec ; setting carry to do subtration
    lda timeMinutesDec
    sbc #1
    sta timeMinutesDec
    cld ; go back to bin math
decAsUsual
    sed ; Going decimal mode
    sec ; setting carry to do subtration
    lda timeSecondsDec
    sbc #1
    sta timeSecondsDec
    cld ; go back to bin math
    rts
timerRanOut
    ; Timer is at 0:00
    rts


timeMinutesDec .byte $00
timeSecondsDec .byte $00