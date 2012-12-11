.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00

; print out a decimal number to the screen at the top right corner

SCREENMEM .equ 1024

jmp start
TMP .byte $00
TMP2 .byte $00
TMP3 .byte $00
TMP4 .byte $00
TMP5 .byte $00
RET1 .byte $00, $00
SCORE .byte $00, $04, $00, $00
zpPtr1         .equ $b0
; sed = set decimal arithmatic flag
; cld = clear decimal flag
; asl = accumulator shift left
; lsr = logical shift right on the accumulator

start
;lda #$00
;sta SCORE
jsr ClearScreen
;sed

loopScoreInc

; bin2hex16bit ; TMP, TMP2, TMP3 (ret_2, ret_1, binNumber_high, binNumber_low)
; Lowest byte 000,0xx
lda SCORE
pha
lda SCORE+1
pha
jsr bin2hex16bit ; Set TMP, TMP2 to Decimal numbers of the value SCORE

lda TMP ; Load TMP
pha
lda #$06 ; low byte
pha
lda #$04 ; high byte
pha
;jsr addTwoNumbers
jsr print8BitDecNumber


; Mid byte 00x,x00
lda TMP2
pha
lda #$04 ; low byte
pha
lda #$04 ; high byte
pha
jsr print8BitDecNumber


; High byte xx0,000
lda TMP3
pha
lda #$02 ; low byte
pha
lda #$04 ; high byte
pha
jsr print8BitDecNumber
rts

; Higher byte xx,000,000
;lda SCORE+3
;pha
;lda #$00 ; low byte
;pha
;lda #$04 ; high byte
;pha
;jsr print8BitDecNumber



lda #$01
clc
adc SCORE
sta SCORE
lda #$00
adc SCORE+1
sta SCORE+1

;lda #$00
;adc SCORE+2
;sta SCORE+2
;lda #$00
;adc SCORE+3
;sta SCORE+3



jsr WaitFrame
jsr WaitFrame
jsr WaitFrame
jsr WaitFrame
jsr WaitFrame

jmp loopScoreInc ; endless loop

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
    ; Copy return address back to stack
    lda ret1
    pha
    lda ret1+1
    pha
    rts







print16BitDecNumber ; void (ret_2, ret_1, pos_high, pos_low, number_high, number_low); Store away return address
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





ClearScreen LDX #$00
LDA #" " ; Space
Clearing    STA SCREENMEM, X
STA SCREENMEM + $100, x
STA SCREENMEM + $200, x
STA SCREENMEM + $300, x
INX
BNE Clearing;
RTS







; Wait for frame to be drawn
WaitFrame ; void:()
lda $d012
cmp #$F8
beq WaitFrame
;wait for the raster to reach line $f8 (should be closer to the start of this line this way)
WaitStep2   lda $d012
cmp #$F8
bne WaitStep2
;jmp MoveDownOne
Return      rts









addTwoNumbers ; void (returnAddy_1, returnAddy_2, pos_2, pos_1, num2, num1)
; Store away return address
pla
sta RET1+1
pla
sta RET1

; Set decimal math mode
sed
clc
pla
sta TMP2 ; store pos_2
pla
adc TMP2
sta TMP ; store complete number in temp location
lsr ; Shift over 4 times
lsr
lsr
lsr
ora #$30 ; Add in the character bits
tax ; copy a over to x for a moment
pla ; pull out pointer of address for print location
sta zpPtr1+1
pla
sta zpPtr1
txa
ldy #$00
sta (zpPtr1), Y
lda TMP ; load back the complete number
and #$0f ; mask off the top half
ora #$30 ; convert to character number
sta SCREENMEM + 1
cld

lda ret1
pha
lda ret1+1
pha
rts








test5 ; how does the asl work exactly?
lda VIRUS_MUL_1
sta P1_SCORE_B

lda #0
sta cWasSet
clc
asl P1_SCORE_B
bcc firstNoCarry
lda #1
sta cWasSet
firstNoCarry
clc
asl P1_SCORE_B+1
lda cWasSet
ora P1_SCORE_B+1
sta P1_SCORE_B+1
lda #0
sta cWasSet
bcc secondNoCarry
lda #1
sta cWasSet
secondNoCarry
clc
asl P1_SCORE_B+2
lda cWasSet
ora P1_SCORE_B+2
sta P1_SCORE_B+2


lda #0
sta cWasSet
clc
asl P1_SCORE_B
bcc firstNoCarry_2
lda #1
sta cWasSet
firstNoCarry_2
clc
asl P1_SCORE_B+1
lda cWasSet
ora P1_SCORE_B+1
sta P1_SCORE_B+1
lda #0
sta cWasSet
bcc secondNoCarry_2
lda #1
sta cWasSet
secondNoCarry_2
clc
asl P1_SCORE_B+2
lda cWasSet
ora P1_SCORE_B+2
sta P1_SCORE_B+2



lda #0
sta cWasSet
clc
asl P1_SCORE_B
bcc firstNoCarry_3
lda #1
sta cWasSet
firstNoCarry_3
clc
asl P1_SCORE_B+1
lda cWasSet
ora P1_SCORE_B+1
sta P1_SCORE_B+1
lda #0
sta cWasSet
bcc secondNoCarry_3
lda #1
sta cWasSet
secondNoCarry_3
clc
asl P1_SCORE_B+2
lda cWasSet
ora P1_SCORE_B+2
sta P1_SCORE_B+2
rts
cWasSet .byte $00