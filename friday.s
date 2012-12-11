SCREENMEM   .equ 1024 ; Start of character screen map, color map is + $D400
NEWCHARMAP  .equ 12288 ; $3000 new place for Charset
FRIDAY_LOC  .equ 1278
VIC_MEM         .equ 53248
SCREEN_BOARDER  .equ VIC_MEM + 32
SCREEN_BG_COLOR .equ VIC_MEM + 33
COLORMEM    .equ $D800
RASTER_TO_COUNT_AT  .equ 80
songStartAdress     .equ $2300

.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00

start
;    lda #0
;    jsr songStartAdress
    ; Tell VIC where to get charmap from
    lda 53272
    and #240
    clc
    adc #12
    sta 53272
    jsr ClearScreen
    jsr printFriday
;    jsr initRefreshCounter
rts


printFriday
    ldx #0
    stx SCREEN_BG_COLOR
    ldy #12
pf_loop
    txa
    sta FRIDAY_LOC, x
    inx
    dey
    bne pf_loop

    ldx #20
    ldy #0
pf_loop2
    txa
    sta FRIDAY_LOC+40, y
    inx
    iny
    cpy #12
    bne pf_loop2

loading
    ldx #0
loading_loop
    lda loadString, x
    beq doneWithLoadingString
    sta FRIDAY_LOC+154, x
    lda #38
    sta FRIDAY_LOC+274, x
    inx
    jmp loading_loop
doneWithLoadingString
    dex
    lda #39
    sta FRIDAY_LOC+274, x

backgroundColorFlicker
    jsr get_random_number
    sta SCREEN_BOARDER
lda #0
sta SCREEN_BOARDER
nop
nop
nop
nop
nop

    jmp backgroundColorFlicker


rts
;                                             .
loadString  .byte 12, 13, 14, 15, 16, 17, 18, 19, 19, 19, 40, 32, 33, 34, 14, 35, 34, 40, 37, 14, 16, 36, 19, 19, 19, 0
; l = 12
; o = 13
; a = 14
; d = 15
; i = 16
; n = 17
; g = 18
; . = 19
; p = 32
; l = 33
; e = 34
; s = 35
; t = 36
; w = 37



initRefreshCounter
sei          ; turn off interrupts
lda #$7f
ldx #$01
sta $dc0d    ; Turn off CIA 1 interrupts
sta $dd0d    ; Turn off CIA 2 interrupts
stx $d01a    ; Turn on raster interrupts

lda #$1b
sta $d011    ; Clear high bit of $d012, set text mode

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

asl $d019    ; ACK interrupt (to re-enable it)
jsr songStartAdress+3

pla
tay
pla
tax
pla
;    jmp $ea31 ; Go back to the default interupt address
rti          ; return from interrupt



ClearScreen ; void ()
    LDX #$00
Clearing
    lda #40
    STA SCREENMEM, X
    STA SCREENMEM + $100, x
    STA SCREENMEM + $200, x
    STA SCREENMEM + $300, x
    lda #1
    sta COLORMEM, x
    sta COLORMEM + $100, x
    sta COLORMEM + $200, x
    sta COLORMEM + $300, x
    inx
    BNE Clearing;
    RTS

get_random_number ; reg a ()
    lda $d012 ; load current screen raster value
    eor $dc04 ; xor against value in $dc04
    sbc $dc05 ; then subtract value in $dc05
    rts




.org NEWCHARMAP
CUST_CHAR_0 .byte 0, 255, 255, 255, 56, 56, 57, 63
CUST_CHAR_1 .byte 0, 252, 252, 252, 28, 28, 192, 192
CUST_CHAR_2 .byte 0, 255, 255, 255, 56, 56, 56, 63
CUST_CHAR_3 .byte 0, 224, 240, 248, 120, 56, 120, 240
CUST_CHAR_4 .byte 0, 63, 63, 63, 3, 3, 3, 3
CUST_CHAR_5 .byte 0, 248, 248, 248, 128, 128, 128, 128
CUST_CHAR_6 .byte 0, 255, 255, 255, 56, 56, 56, 56
CUST_CHAR_7 .byte 0, 192, 240, 248, 120, 60, 28, 28
CUST_CHAR_8 .byte 0, 63, 63, 63, 7, 14, 14, 12
CUST_CHAR_9 .byte 0, 192, 192, 224, 224, 240, 112, 112
CUST_CHAR_10 .byte 0, 126, 126, 126, 28, 30, 14, 14
CUST_CHAR_11 .byte 0, 252, 252, 252, 112, 112, 224, 192
CUST_CHAR_12 .byte 120, 48, 48, 48, 48, 49, 49, 127
CUST_CHAR_13 .byte 56, 108, 198, 198, 198, 198, 108, 56
CUST_CHAR_14 .byte 120, 56, 60, 44, 36, 126, 70, 239
CUST_CHAR_15 .byte 248, 108, 102, 102, 102, 102, 108, 248
CUST_CHAR_16 .byte 126, 24, 24, 24, 24, 24, 24, 126
CUST_CHAR_17 .byte 231, 102, 118, 118, 110, 110, 110, 230
CUST_CHAR_18 .byte 62, 102, 194, 192, 223, 198, 102, 62
CUST_CHAR_19 .byte 0, 0, 0, 0, 0, 0, 28, 28
CUST_CHAR_20 .byte 63, 63, 57, 56, 56, 254, 254, 254
CUST_CHAR_21 .byte 192, 192, 192, 0, 0, 0, 0, 0
CUST_CHAR_22 .byte 63, 63, 57, 56, 56, 252, 252, 252
CUST_CHAR_23 .byte 224, 192, 224, 240, 240, 126, 62, 62
CUST_CHAR_24 .byte 3, 3, 3, 3, 3, 63, 63, 63
CUST_CHAR_25 .byte 128, 128, 128, 128, 128, 248, 248, 248
CUST_CHAR_26 .byte 56, 56, 56, 56, 56, 255, 255, 255
CUST_CHAR_27 .byte 28, 28, 28, 60, 120, 240, 240, 192
CUST_CHAR_28 .byte 28, 31, 31, 63, 56, 254, 254, 254
CUST_CHAR_29 .byte 120, 248, 248, 252, 28, 127, 127, 127
CUST_CHAR_30 .byte 7, 3, 3, 3, 3, 31, 31, 31
CUST_CHAR_31 .byte 192, 128, 128, 128, 128, 240, 240, 240
CUST_CHAR_32 .byte 126, 51, 51, 51, 62, 48, 48, 120
CUST_CHAR_33 .byte 120, 48, 48, 48, 48, 49, 49, 127
CUST_CHAR_34 .byte 254, 98, 96, 120, 96, 96, 98, 254
CUST_CHAR_35 .byte 62, 102, 98, 124, 30, 70, 102, 124
CUST_CHAR_36 .byte 255, 153, 153, 153, 24, 24, 24, 126
CUST_CHAR_37 .byte 231, 66, 90, 90, 90, 102, 102, 102
CUST_CHAR_38 .byte 255, 255, 255, 255, 255, 255, 255, 255
CUST_CHAR_39 .byte 255, 1, 1, 1, 1, 1, 1, 255
CUST_CHAR_40 .byte 0,0,0,0,0,0,0,0