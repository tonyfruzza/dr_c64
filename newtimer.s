.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00

VMEM                .equ $D000
SCREEN_BORDER       .equ VMEM + 32
SCREENMEM           .equ $0400
PAL_50HZ            .equ 19705
PAL_60HZ            .equ 16421
songStartAdress     .equ $8000
JOY2                .equ $dc00
JOY_BIT_UP          .equ 1
JOY_BIT_DOWN        .equ 2
JOY_BIT_LEFT        .equ 4
JOY_BIT_RIGHT       .equ 8
JOY_BIT_FIRE        .equ 16
BACKGROUND_CHAR     .equ " "
zpPtr1          .equ $ba
zpPtr2          .equ $b4
zpPtr3          .equ $b6
zpPtr4          .equ $b8
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
MODE_50         .equ 0
MODE_60         .equ 1
CIA1_OVERFLOW   .equ %10000001



    jsr initRefreshCounter
    jsr ClearScreen
    lda #<textMsg
    pha
    lda #>textMsg
    pha
    lda #$00
    pha
    lda #$04
    pha
    jsr printMsgSub

    lda #<text60hz
    pha
    lda #>text60hz
    pha
    lda #$28
    pha
    lda #$04
    pha
    jsr printMsgSub


    lda #15 ; Volume Max
    jsr songStartAdress+9
    lda #0 ; Play song 1
    jsr songStartAdress


theLoop
    ldx JOY2
    txa
    and #JOY_BIT_UP
    beq joy_is_up
    txa
    and #JOY_BIT_DOWN
    beq joy_is_down
    txa
    and #JOY_BIT_LEFT
    beq joy_is_left

    jsr printSample
    jmp theLoop

joy_is_up
    lda mode
    cmp #MODE_60
    beq joy_no_change
    sei
    lda #MODE_60
    sta mode
    lda $dc0d
    lda $dd0d
    lda #<PAL_60HZ
    sta $dc04 ; CIA2 timer A low byte
    lda #>PAL_60HZ
    sta $dc05 ; CIA2 timer A high byte
    cli
    lda #<text60hz
    pha
    lda #>text60hz
    pha
    lda #$28
    pha
    lda #$04
    pha
    jsr printMsgSub

    jmp theLoop
joy_is_down
    lda mode
    cmp #MODE_50
    beq joy_no_change
    sei
    lda #MODE_50
    sta mode
    lda $dc0d
    lda $dd0d
    lda #<PAL_50HZ
    sta $dc04 ; CIA2 timer A low byte
    lda #>PAL_50HZ
    sta $dc05 ; CIA2 timer A high byte
    cli
    lda #<text50hz
    pha
    lda #>text50hz
    pha
    lda #$28
    pha
    lda #$04
    pha
    jsr printMsgSub
joy_no_change
    jmp theLoop

joy_is_left
    lda $dc08 ; read tenths to start TOD clock timer
    ; start timer back up
    lda $dc0e
    ora #%00000001
    sta $dc0e ; start the timer back up
    jmp theLoop

textMsg     .byte 16, 1, 12, 32, 13, 1, 3, 8, 9, 14, 5, 32, 18, 21, 14, 14, 9, 14, 7, 32, 13, 21, 19, 9, 3, 32, 1, 20, 32, 53, 48, 32, 1, 14, 4, 32, 54, 48, 8, 26, 0
text50hz    .byte 53, 48, 8, 26, 0
text60hz    .byte 54, 48, 8, 26, 0
mode        .byte 1 ; Default to 60


ClearScreen ; void ()
    LDX #$00
Clearing
    lda clearingChar
    STA SCREENMEM, X
    STA SCREENMEM + $100, x
    STA SCREENMEM + $200, x
    STA SCREENMEM + $300, x
    INX
    BNE Clearing
    RTS
clearingChar    .byte BACKGROUND_CHAR ; Can be set before using routine

initRefreshCounter
    sei          ; turn off interrupts

    lda #%10000101 ; enable cia 1 irq by timer a, bit 2 for RTC interupt trigger
    sta $dc0d

    lda #$7f ; Disable?
    sta $dd0d

    lda $dc0d ; ack
    lda $dd0d ; ack

    lda #$00   ;this is how to tell the VICII to generate a raster interrupt
    sta $d01a

    lda #%00010001 ; Start timer a, restart when counted down, load start value into timer, set timer to 50hz for RTC
    sta $dc0e


    ; Set interupt clock cycle count down number to 17,045
    lda #<PAL_60HZ
    sta $dc04 ; CIA2 timer A low byte
    lda #>PAL_60HZ
    sta $dc05 ; CIA2 timer A high byte

    lda #%00000000 ; Configure TOD clock time
    sta $dc0f

    sta $dc09 ; seconds
    sta $dc0a ; minutes
    sta $dc0b ; hours
    lda #0 ; Set TOD to 00:00:00.00
    sta $dc08 ; tenths



    lda #%10000000 ; Configure TOD clock ALARM, otherwise don't use Timer B
    sta $dc0f

    ; What about some RTC
    lda #5
    sta $dc09 ; set TOD SEC
    lda #0
    sta $dc0a ; set TOD MIN
    sta $dc0b ; Set TOD HR
    lda #0
    sta $dc08 ; set tenth seconds



    ; Configure ROM/RAM
    lda #$35   ;we turn off the BASIC and KERNAL rom here
    sta $01    ;the cpu now sees RAM everywhere except at $d000-$e000, where still the registers of
           ;SID/VICII/etc are visible

    lda #<irq_refreshCounter    ; low part of address of interrupt handler code
    sta $fffe
    lda #>irq_refreshCounter    ; high part of address of interrupt handler code
    sta $ffff
    cli          ; turn interrupts back on
    rts



irq_refreshCounter
    pha        ;store register A in stack
    txa
    pha        ;store register X in stack
    tya
    pha        ;store register Y in stack
    inc SCREEN_BORDER
    jsr songStartAdress+3 ; Play song
    dec SCREEN_BORDER

    lda $dc0d
    sta toPrint
    pla
    tay
    pla
    tax
    pla
    rti          ; return from interrupt


printMsgSub ; void (ret>, ret<, txt>, txt<, pos>, pos<)
    pla
    sta ret1+1
    pla
    sta ret1

    pla
    sta zpPtr2+1 ; screen pos
    pla
    sta zpPtr2

    pla
    sta zpPtr1+1 ; txt data
    pla
    sta zpPtr1

    ldy #$00
printLoopSub
    lda (zpPtr1), y
    beq printCompleteSub
    sta (zpPtr2), y
    lda #COLOR_WHITE ; inner default color for text
    sta (zpPtr3),y
    iny
    jmp printLoopSub
printCompleteSub
    lda ret1
    pha
    lda ret1+1
    pha
    rts

ret1    .byte 0, 0


convertValToString ; void (ret >, ret <, val)
    pla
    sta ret1+1
    pla
    sta ret1
    pla
    tay ; cache the register value in y
    ; 0 out regString with 8 '0' characters
    lda #$30
    sta regString
    sta regString+1
    sta regString+2
    sta regString+3
    sta regString+4
    sta regString+5
    sta regString+6
    sta regString+7

    tya
    ; First bit
    and #%00000001
    beq skipBit1 ; not set
    inc regString+7 ; set to #$31 which is '1'
skipBit1
    tya ; get register from y cache
    and #%00000010
    beq skipBit2
    inc regString+6
skipBit2
    tya ; get register from y cache
    and #%00000100
    beq skipBit3
    inc regString+5
skipBit3
    tya
    and #%00001000
    beq skipBit4
    inc regString+4
skipBit4
    tya
    and #%00010000
    beq skipBit5
    inc regString+3
skipBit5
    tya
    and #%00100000
    beq skipBit6
    inc regString+2
skipBit6
    tya
    and #%01000000
    beq skipBit7
    inc regString+1
skipBit7
    tya
    and #%10000000
    beq skipBit8
    inc regString
skipBit8
    lda ret1
    pha
    lda ret1+1
    pha
    rts

regString   .byte 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 9 bytes, 9th for terminating char

printSample ; void ()
    lda toPrint
    cmp #CIA1_OVERFLOW
    beq ps_continue
    lda $dc0e
    and #%11111110
    sta $dc0e ; pause the timer it's different.
ps_continue
    pha
    jsr convertValToString
    lda #<regString
    pha
    lda #>regString
    pha
    lda #$50
    pha
    lda #$04
    pha
    jsr printMsgSub
    rts
toPrint     .byte 0 ; Set aside for value to print to screen with