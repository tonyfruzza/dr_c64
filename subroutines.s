;
;
; print8BitDecNumber    ; void (ret_2, ret_1, pos_high, pos_low, number); alters y, tmp, zptr1
; eightBitMul           ; tmp1, tmp4 = (return_2, return_1, num1, num2) ; alter x, tmp1, tmp2, tmp4
; ClearScreen           ; void ()
; get_random_number     ; a ()

ClearScreen ; void ()
    stx retx
    LDX #$00
Clearing
    lda #127
    STA SCREENMEM, X
    STA SCREENMEM + $100, x
    STA SCREENMEM + $200, x
    STA SCREENMEM + $300, x
    lda #COLOR_WHITE
    sta COLORMEM, x
    sta COLORMEM + $100, x
    sta COLORMEM + $200, x
    sta COLORMEM + $300, x
    INX
    BNE Clearing;
    ldx retx
    RTS


get_random_number ; reg a ()
            lda $d012 ; load current screen raster value
            eor $dc04 ; xor against value in $dc04
            sbc $dc05 ; then subtract value in $dc05
            rts

; converts 10 digits (32 bit values have max. 10 decimal digits)
; Using a byte per digit hrm...
convertP1ScoreToDecimal
    ldx #0
l3
    jsr div10
    ;    sta result,x
    sta P1_SCORE, x
    inx
    cpx #10
    bne l3
    rts

; divides a 32 bit value by 10
; remainder is returned in akku
div10
    ldy #32         ; 32 bits
    lda #0
    clc
l4
    rol
    cmp #10
    bcc skip
    sbc #10
skip
    rol P1_SCORE_B_COPY
    rol P1_SCORE_B_COPY+1
    rol P1_SCORE_B_COPY+2
    rol P1_SCORE_B_COPY+3
    dey
    bpl l4
    rts

P1_SCORE_B_COPY .byte $00, $00, $00, $00



eightBitMul ; tmp1, tmp4 = (return_2, return_1, num1, num2) ; alter tmp1, tmp2, tmp4
stx RETX ; stash a copy of reg x
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
M1
bcc M2
clc
adc tmp2 ; S?
M2
ror
ror tmp1 ; FPL?
dex
bne M1
sta tmp4 ; high byte (PH)
; Copy return address back to stack
lda ret1
pha
lda ret1+1
pha
ldx RETX ; return x's value back
rts ; and return



; Function to convert binary 8 bit value to a hex decimal number
; that can be printed numerically within 2 digits
bin2hex8bit ; TMP, TMP2 (ret_2, ret_1, binNumber)
    lda #$00
    sta TMP ; init to 0
    sta TMP2 ; init to 0

    pla
    sta RET1+1
    pla
    sta RET1

    pla
    tax ; place the binary number into X
    beq itsZero

    sed ; change to decimal mode
addOneMoreDec
    lda TMP
    clc ; clear any previous carry bits
    adc #$01 ; Add one decimal number for every value in X
    sta TMP
    lda TMP2
    adc #$00
    sta TMP2
    dex
    bne addOneMoreDec
    ; set math type back to binary
    cld
    ; Copy return address back to stack
itsZero
    lda ret1
    pha
    lda ret1+1
    pha
    rts ; and return



; Count how many raster lines it takes to complete task.
; Used in conjunction with IRQ
startTimer
    lda #0
    sta vBlanks
    lda $d012
    sta rasterCounter
    rts

stopTimer
lda $d012
    sta rasterCntTotal
lda vBlanks
sta vBlanksEnd
    rts


rasterCounter   .byte $00
rasterCntTotal  .byte $00
vBlanks         .byte $00
vBlanksEnd      .byte $00


