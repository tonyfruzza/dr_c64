;
;
; bin2hex16bit          ; TMP, TMP2, TMP3 (ret_2, ret_1, binNumber_high, binNumber_low) alters tmp, tmp2, tmp3, tmp4, tmp 5
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
