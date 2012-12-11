.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00

VIC_MEM         .equ 53248
SCREEN_BOARDER  .equ VIC_MEM + 32
SCREENMEM   .equ 1024 ; Start of character screen map, color map is + $D400
JOY         .equ 56321 ; Joystick flag byte
zpPtr1      .equ $b0
GETIN       .equ $FFE4

jmp init
lastposx    .byte $00
lastposy    .byte $00
posx        .byte $00
posy        .byte $00
ret1        .byte $00, $00 ; used a temp stack return
TMP         .byte $00
tmp1        .byte $00
tmp2        .byte $00
tmp3        .byte $00
tmp4        .byte $00
tmp5        .byte $00
messagexat  .byte 25
messagerow  .byte 10
message     .byte "some message that we can scroll on the screen...", $00


; VICE Monitor Label File Loading: load_labels "/Users/Tony/Development/DrC64/labels.txt"
; Quick VICE monitor notes:
; show_labels
; cd /Users/Tony/Development/DrC64/
; m H .piece2 .piece2
; m H .varrayindex .varrayindex
; watch store .varrayindex
; watch store .varrayindex .varrayindex
; break .brkhere
; return


init
    lda #40
    sta posx
    lda #25
    sta posy

    sei          ; turn off interrupts

gameloop
    jsr updateJoyPos
    jsr updatePos
;    jsr GETIN
;    cmp #"q"
;    beq exitGame
    jmp gameloop
    exitGame rts


moveMarker ; void (return_2, return1, screenpos_high, screenpos_low)
    pla
    sta ret1+1
    pla
    sta ret1
    pla
    sta zpPtr1+1
    pla
    sta zpPtr1
    ldy #$00
    lda #42 ; '*'
    sta (zpPtr1), y
    lda ret1
    pha
    lda ret1+1
    pha
    rts




updatePos
    lda #40 ; for Y ofset, multiply by 40 for each row
    pha
    lda posy
    pha
    jsr eightBitMul ; tmp1, tmp4 = (return_2, return_1, num1, num2)
    ; Add x offset to tmp1, tmp4
    clc
    lda posx
    adc tmp1
    sta tmp1
    lda #$00
    adc tmp4
    sta tmp4 ; end of adding posx offset

    lda tmp1
    pha
    lda tmp4
    ora #04
    pha
    jsr moveMarker

;    lda tmp1
;   pha
;    lda tmp4
;    ora #04
;    pha
;   jsr bin2hex16bit ; TMP, TMP2, TMP3 (ret_2, ret_1, binNumber_high, binNumber_low)


    ; print8BitDecNumber ; void (ret_2, ret_1, pos_high, pos_low, number);
;   lda tmp
;   pha
;   lda #$02 ; = pos_low
;   pha
;   lda #$04 ; = pos_high
;   pha
;   jsr print8BitDecNumber

;   lda tmp2
;   pha
;   lda #$00 ; = pos_low
;   pha
;   lda #$04 ; = pos_high
;   pha
;   jsr print8BitDecNumber

    rts







;
; subrutines below here.....

updateJoyPos
    ldx JOY
    txa
    and #1 ; Up
    bne nextJoy1 ; if no match, then skip to nextJoy1
    dec posy; decrement y
nextJoy1
    txa ; transfer
    and #2
    bne nextJoy2; if 1 then nextJoy1
    inc posy; Down one
nextJoy2
    txa
    and #4
    bne nextJoy3
    dec posx ; left
nextJoy3
    txa
    and #8
    bne nextJoy4
    inc posx ; right
nextJoy4
    txa
    and #16 ; Button push
    bne finishJoy
    inc SCREEN_BOARDER
finishJoy
    rts


eightBitMul ; tmp1, tmp4 = (return_2, return_1, num1, num2)
    pla
    sta ret1+1
    pla
    sta ret1
    pla
    sta tmp2
    pla
    sta tmp1
    lda #$00
    ldx #8
    lsr tmp1 ; FPL?
L1  bcc L2
    clc
    adc tmp2 ; S?
L2  ror
    ror tmp1 ; FPL?
    dex
    bne L1
    sta tmp4 ; high byte (PH)
; Copy return address back to stack
    lda ret1
    pha
    lda ret1+1
    pha
    rts ; and return


bin2hex16bit ; TMP, TMP2, TMP3 (ret_2, ret_1, binNumber_high, binNumber_low)
pla
sta RET1+1
pla
sta RET1
; Pull off the 16bit binary number
pla
sta TMP5 ; high byte
pla
sta TMP4 ; low byte
lda #$00 ; Init the HEX storage locations
sta TMP  ; init to 0
sta TMP2 ; init to 0
sta TMP3 ; init to 0
addOneMoreDec16
lda TMP5
ora TMP4
beq bin2hex16bitDone; are we zero yet?
cld ; go back to binary math
; Subtract one binary value from TMP4, TMP5
lda TMP4 ; low byte load
sec
sbc #01
sta TMP4
lda TMP5 ; high byte load
sbc #00
sta TMP5
; Add in decimal mode to TMP, TMP2, TMP3
sed
lda TMP
clc ; clear any previous carry bits
adc #$01 ; Add one decimal number for every value in X
sta TMP
lda TMP2
adc #$00
sta TMP2
lda TMP3
adc #$00
sta TMP3
jmp addOneMoreDec16
bin2hex16bitDone
cld ; clear the decimal flag
; Copy return address back to stack
lda ret1
pha
lda ret1+1
pha
rts


print8BitDecNumber ; void (ret_2, ret_1, pos_high, pos_low, number); Store away return address
pla
sta RET1+1
pla
sta RET1
; start

pla
sta zpPtr1+1 ; high byte
pla
sta zpPtr1   ; low byte

ldy #$00
pla ; pull off number
sta TMP
lsr ; Shift over 4 times
lsr
lsr
lsr
ora #$30
sta (zpPtr1), y ; print left char

lda TMP ; load back the complete number
and #$0f ; mask off the top half
ora #$30 ; convert to character number
iny
sta (zpPtr1), y
; Copy return address back to stack
lda ret1
pha
lda ret1+1
pha
rts
