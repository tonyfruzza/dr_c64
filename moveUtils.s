
CheckCollisionBelow ; Sets a = (ret1>, ret1<, pos>, pos<)
pla
sta ret1+1
pla
sta ret1
pla
sta zpPtr3+1
pla
clc
adc #40
sta zpPtr3
lda ret1
pha
lda ret1+1
pha
; Look below to see what's there, is it a space?
lda #$00 ; Add any roll over to the high byte
tay
adc zpPtr3+1
sta zpPtr3+1
lda (zpPtr3), y
cmp #CLEAR_CHAR
beq noCollitionDetected
bne collitionDetected
collitionDetected
lda #$01
rts
noCollitionDetected
lda #$00
rts

CheckCollisionLeft ; a = (ret1>, ret1<, pos>, pos<)
pla
sta ret1+1
pla
sta ret1

pla
sta zpPtr3+1
pla
sta zpPtr3

sec
lda zpPtr3
sbc #$01
sta zpPtr3
lda zpPtr3+1
sbc #$00
sta zpPtr3+1
; Push back return onto stack
lda ret1
pha
lda ret1+1
pha
ldy #$00
lda (zpPtr3), y
;            sta tmp4 ; what, why did I have this here?
cmp #CLEAR_CHAR
beq noCollitionDetectedLeft
collitionDetectedLeft
lda #$01
rts
noCollitionDetectedLeft
lda #$00
rts


CheckCollisionRight ; a = (ret1>, ret1<, pos>, pos<)
jmp ccr_start
ccr_rety    .byte $00
ccr_start
pla
sta ret1+1
pla
sta ret1
pla
sta zpPtr3+1
pla
sta zpPtr3
lda ret1
pha
lda ret1+1
pha
ldy #1
lda (zpPtr3), y
cmp #CLEAR_CHAR
beq noCollitionDetectedRight
collitionDetectedRight
ldy ccr_rety
lda #$01
rts
noCollitionDetectedRight
ldy ccr_rety
lda #$00
rts
