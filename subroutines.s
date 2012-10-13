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
            LDA #" " ; Space
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


print8BitDecNumber ; void (ret_2, ret_1, pos_high, pos_low, number); Store away return address
            sty RETY
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
            ldy RETY
            rts


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
            cld ; Set math type back to binary mode
            ; Copy return address back to stack
            lda ret1
            pha
            lda ret1+1
            pha
            rts


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
            ldx RETX ; return x's value back
            rts ; and return