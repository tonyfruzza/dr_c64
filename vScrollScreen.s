vScrollScreenOff
lda #0
sta vScrollTimes
start
;Screen Mem
clc
lda #<SCREENMEM
sta zpPtr1
adc #40
sta zpPtr2
lda #>SCREENMEM
sta zpPtr1+1
adc #0
sta zpPtr2+1
; Color Mem
clc
lda #<SCREENMEM
sta zpPtr3
lda #>SCREENMEM
adc #$D4
sta zpPtr3+1
clc
lda zpPtr3
adc #40
sta zpPtr4
lda zpPtr3+1
adc #0
sta zpPtr4+1


ldx #0
loop_0
ldy #0
loop_1
lda (zpPtr2), y
sta (zpPtr1), y
lda (zpPtr4), y
sta (zpPtr3), y
iny
cpy #40
bne loop_1
; Screen line math
clc
lda zpPtr1
adc #40
sta zpPtr1
lda zpPtr1+1
adc #0
sta zpPtr1+1
clc
lda zpPtr2
adc #40
sta zpPtr2
lda zpPtr2+1
adc #0
sta zpPtr2+1

; Color line math
clc
lda zpPtr3
adc #40
sta zpPtr3
lda zpPtr3+1
adc #0
sta zpPtr3+1

clc
lda zpPtr4
adc #40
sta zpPtr4
lda zpPtr4+1
adc #0
sta zpPtr4+1


inx
cpx #24
bne loop_0
; We could write a new line in here
lda #' '
ldy #0
sta (zpPtr2), y

inc vScrollTimes
;jsr WaitFrame
;jsr WaitFrame
;jsr WaitFrame
;jsr WaitFrame
;jsr WaitFrame
;jsr WaitFrame
;jsr WaitFrame
    lda vScrollTimes
    cmp #25
    beq vs_done
    jmp start
vs_done
    rts

vScrollTimes    .byte $00