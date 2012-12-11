

RepaintCurrentColor
ldy #00
lda piece1
sta zpPtr2
lda piece1+1
sta zpPtr2+1
lda #$D4
clc
adc zpPtr2+1
sta zpPtr2+1

lda PRICOLOR
sta (zpPtr2), y
lda piece2
sta zpPtr2
lda piece2+1
sta zpPtr2+1
lda #$D4
clc
adc zpPtr2+1
sta zpPtr2+1
lda SECCOLOR
sta (zpPtr2), y
rts

;


ColorSwap   lda PRICOLOR
ldx SECCOLOR
sta SECCOLOR
stx PRICOLOR
jsr RepaintCurrentColor
rts