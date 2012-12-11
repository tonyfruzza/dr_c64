.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00

;SCREEN_LOC  .equ $0400
SCREEN_LOC  .equ $2000
VMEM        .equ $D000
SCREEN_C    .equ $0400



initHighRes
    ; bits 1, 2, 3 of VMEM 24 controls video memory pointer in 2 kilobytes steps
; default to me looked like bit 3 is on
; For bitmap mode memory data pointer must fall between 16K bank of mem
jsr cs
;jsr cl
;    jsr clearScreenLoop
;  bit 5 of VMEM+17 set display mode


    lda VMEM+17
    ora #32
    sta VMEM+17


;lda VMEM+17
;    and #223
;    sta VMEM+17
;    jsr WaitFrame

DisplayGlitchLoop
    lda VMEM+24
    and #240
    tay
    lda offset
and #$0f
    sta offsetAnd
    tya
    ora offsetAnd
    sta VMEM+24
    inc offset
    jsr WaitFrame
    jmp DisplayGlitchLoop


offset  .byte $00
offsetAnd .byte $00


cs ; void ()
LDX #$00
Clearing
lda #0
STA SCREEN_C, X
STA SCREEN_C + $100, x
STA SCREEN_C + $200, x
STA SCREEN_C + $300, x
INX
BNE Clearing;
RTS



clearScreen
    lda #0
    tax
clearScreenLoop
    sta SCREEN_LOC, x
    sta SCREEN_LOC + $0100, x
    sta SCREEN_LOC + $0200, x
    sta SCREEN_LOC + $0300, x
    sta SCREEN_LOC + $0400, x
    sta SCREEN_LOC + $0500, x
    sta SCREEN_LOC + $0600, x
    sta SCREEN_LOC + $0700, x
    sta SCREEN_LOC + $0800, x
    sta SCREEN_LOC + $0900, x
    sta SCREEN_LOC + $0a00, x
    sta SCREEN_LOC + $0b00, x
    sta SCREEN_LOC + $0c00, x
    sta SCREEN_LOC + $0d00, x
    sta SCREEN_LOC + $0e00, x
    sta SCREEN_LOC + $0f00, x
    sta SCREEN_LOC + $1000, x
    sta SCREEN_LOC + $1100, x
    sta SCREEN_LOC + $1200, x
    sta SCREEN_LOC + $1300, x
    sta SCREEN_LOC + $1400, x
    sta SCREEN_LOC + $1500, x
    sta SCREEN_LOC + $1600, x
    sta SCREEN_LOC + $1700, x
    sta SCREEN_LOC + $1800, x
    sta SCREEN_LOC + $1900, x
    sta SCREEN_LOC + $1a00, x
    sta SCREEN_LOC + $1b00, x
    sta SCREEN_LOC + $1c00, x
    sta SCREEN_LOC + $1d00, x
    sta SCREEN_LOC + $1e00, x
    sta SCREEN_LOC + $1f00, x
    inx
    bne clearScreenLoop
    rts

WaitFrame   lda $d012
cmp #0
beq WaitFrame
;wait for the raster to reach line $f8 (should be closer to the start of this line this way)
WaitStep2   lda $d012
cmp #0
bne WaitStep2
Return      rts