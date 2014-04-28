; Interup based timing events

RASTER_TO_COUNT_AT  .equ 220
DELAY2              .equ 6
;songStartAdress     .equ $2300
SID_VOLUME          .equ $D418
songStartAdress     .equ $8000
SOUND_ROTATE        .byte $00,$f6,$00,$a0,$12,$c0,$d0,$d1,$d2,$d4,$d6,$d8,$da,$10,$00
SOUND_HORIZONTAL    .byte $00,$53,$00,$a0,$12,$c0,$d0,$d1,$d2,$d4,$d6,$d8,$da,$10,$00
SOUND_BOTTOM        .byte $82,$24,$00,$a0,$81,$90,$41,$8e,$8a,$40,$00
SOUND_CLEAR         .byte $01, $93, $00, $c4, $81, $c4, $c4, $c4, $21, $c4, $c0, $c7, $c0, $c6, $c0, $c4, $c0, $c4, $80, $00
refreshCount        .byte $00
refreshTimer2       .byte $00
refreshTimer3       .byte $00
playMusic           .byte $00
flashTimes          .byte $00

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

;
; Event entry point
irq_refreshCounter ; void (y, x, a)
    inc vBlanks ; for raster counter
    ; See if we need to turn off a score sprite
    lda $d015
    and #4
    beq noScoreSpriteEnabled
    lda framesToShowSprite
    beq disableScoreSprite
    cmp #15
    bne noScoreSpriteMods
    ; For 15 do
    lda #COLOR_GREY
    sta VMEM+41
    dec $d005
    dec $d005
    jmp noScoreSpriteMods

    cmp #5
    lda #COLOR_DARK_GREY
    sta VMEM+41
    dec $d005
    dec $d005

;jsr handleScreenFlash

noScoreSpriteMods
    dec framesToShowSprite
    jmp noScoreSpriteEnabled
disableScoreSprite
    ; everything except for sprite 3 enabled
    lda $d015
    and #$fb
    sta $d015
noScoreSpriteEnabled

    lda playMusic
    beq dontPlayMusic
    jsr songStartAdress+3 ; Play song
dontPlayMusic
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


handleScreenFlash
    lda SCREEN_BORDER
    and #$0f ; Upper bits are being set to F here, not sure why!?
    bne turnFlashOff ; Not black?
    ; do we flash for a score?
doWeFlash
    lda flashTimes
    beq doneFlash ; Do we need to flash?
    lda #COLOR_DARK_GREY
    sta SCREEN_BORDER
    dec flashTimes
    jsr zombieColorSwap
    jmp doneFlash
    turnFlashOff
    lda framesToShowSprite ; extend flash time out as long as score is displayed
    bne doneFlash
    lda #COLOR_BLACK
    sta SCREEN_BORDER
doneFlash
    rts
