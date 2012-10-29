;
;
; print8BitDecNumber    ; void (ret_2, ret_1, pos_high, pos_low, number); alters y, tmp, zptr1
; eightBitMul           ; tmp1, tmp4 = (return_2, return_1, num1, num2) ; alter x, tmp1, tmp2, tmp4
; ClearScreen           ; void ()
; get_random_number     ; a ()

ClearScreen ; void ()
            stx retx
            LDX #$00
lda #127
;            LDA #" " ; Space
            Clearing    STA SCREENMEM, X
            STA SCREENMEM + $100, x
            STA SCREENMEM + $200, x
            STA SCREENMEM + $300, x
            INX
            BNE Clearing;
            ldx retx
            RTS

get_random_number ; reg a ()
            lda $d012 ; load current screen raster value
            eor $dc04 ; xor against value in $dc04
            sbc $dc05 ; then subtract value in $dc05
            rts

; Enable keyboard repeat for all keys
enableKeyboardRepeat
    lda #128
    sta 650
    rts

; Disable repeat for all keys
disableKeyboardRepeat
    lda #0
    sta 650
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
;    rol value
;    rol value+1
;    rol value+2
;    rol value+3
dey
bpl l4
rts

P1_SCORE_B_COPY .byte $00, $00, $00, $00

;value   .byte $ff,$0,$0,$0
;result  .byte 0,0,0,0,0,0,0,0,0,0


