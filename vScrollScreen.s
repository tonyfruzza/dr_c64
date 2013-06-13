vScrollScreenOff
    lda #0
    sta vScrollTimes
    sta endMsgDidFullScreen
    sta endMsgTmpX
    sta endMsgIdx
    sta endMsgLineNum
    jsr setEndMsgPointerBack
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

    inc vScrollTimes
    jsr copyInANewRowForVScroll
    lda endMsgDidFullScreen
    beq vs_noWait
    jsr WaitEventFrame
    jsr WaitEventFrame
    inc endMsgLineNum
vs_noWait
    lda vScrollTimes
    cmp #25
    beq vs_clearedEntireScreenOnce
cmp #50
beq vs_done
    jmp start
vs_clearedEntireScreenOnce
    inc endMsgDidFullScreen
    jmp start
vs_done
    rts

vScrollTimes    .byte $00




copyInANewRowForVScroll
    stx cinrfv_tmpxy
    sty cinrfv_tmpxy+1
    ; Starts at SCREENMEM + 960 for 40 chars at a time
    ldx #0
cinrfv_loop
    jsr get_random_number
    and #3
    tay
    cmp #3
    bne noDecNeeded
    dey
noDecNeeded
lda colors, y
sta COLORMEM +960, x
    lda VIRUS_CHAR_LIST, y
    sta charToPrint
lda endMsgDidFullScreen
beq LessThan35

cpx #5 ; >= 5
bcc GreaterThan5
cpx #35
bcs LessThan35
lda #' '
lda #COLOR_WHITE
sta COLORMEM +960, x
jsr getNextEndMsgChar
sta charToPrint
GreaterThan5
LessThan35

    lda charToPrint
    sta SCREENMEM + 960, x
    inx
    cpx #40
    bne cinrfv_loop
    ldx cinrfv_tmpxy
    ldy cinrfv_tmpxy+1
    rts

cinrfv_tmpxy .byte $00, $00

getNextEndMsgChar
    ; Do we just print a line of spaces to double space?
    lda endMsgLineNum
    and #$1
    beq gnemc_justASpace

    stx endMsgTmpX
    ldx endMsgIdx
endMsgPointer
    lda endingMsg, x
    inc endMsgIdx
    bne getNextAsYouWere ; If endMsgIdx == 0 then run selfModifyEndMsg
    jsr selfModifyEndMsgPointer
getNextAsYouWere
    ldx endMsgTmpX
    rts
gnemc_justASpace
    lda #' '
    rts

selfModifyEndMsgPointer
    inc endMsgPointer+2
    rts

setEndMsgPointerBack
    lda #>endingMsg
    sta endMsgPointer+2
    rts

COLOR_THIS_ROW  .equ 56221
cycleColorsOnSecondToBottomRow
    ; We're going to be painting the color for
    ; 925 - 955, total is 30 chars
    lda charColorCycle
    and #1
    beq firstColors
    lda #COLOR_YELLOW
    jmp gotColor
firstColors
    lda #COLOR_WHITE
gotColor
    ldx #0
ccostbr_loop
    sta COLOR_THIS_ROW, x
    inx
    cpx #30
    bne ccostbr_loop
    inc charColorCycle
    rts




charColorCycle  .byte 00
charToPrint .byte $00
endMsgDidFullScreen .byte $00
endMsgTmpX  .byte $00
endMsgIdx   .byte $00
endMsgLineNum   .byte $00
endingMsg .byte 32, 15, 21, 20, 2, 18, 5, 1, 11, 32, 16, 18, 5, 22, 9, 5, 23, 32, 32, 2, 18, 15, 21, 7, 8, 20, 32, 20, 15, 32, 32, 25, 15, 21, 32, 2, 25, 32, 6, 12, 9, 13, 19, 15, 6, 20, 32, 3, 15, 4, 5, 32, 2, 25, 32, 20, 15, 14, 25, 32, 32, 6, 18, 21, 26, 26, 1, 46, 32, 32, 19, 9, 4, 32, 32, 2, 25, 32, 18, 9, 3, 8, 1, 18, 4, 32, 32, 15, 6, 32, 32, 14, 5, 23, 32, 32, 4, 9, 13, 5, 14, 19, 9, 15, 14, 32, 32, 9, 14, 3, 12, 21, 4, 5, 4, 32, 32, 23, 47, 32, 32, 7, 15, 1, 20, 20, 18, 1, 3, 11, 5, 18, 46, 32, 32, 20, 8, 5, 32, 32, 6, 21, 12, 12, 32, 7, 1, 13, 5, 32, 32, 20, 15, 32, 32, 9, 14, 3, 12, 21, 4, 5, 32, 32, 1, 4, 4, 9, 20, 9, 15, 14, 1, 12, 32, 7, 1, 13, 5, 32, 32, 13, 15, 4, 5, 19, 44, 32, 32, 32, 32, 15, 18, 9, 7, 9, 14, 1, 12, 32, 32, 32, 32, 13, 21, 19, 9, 3, 44, 32, 32, 9, 13, 16, 18, 15, 22, 5, 4, 32, 7, 6, 24, 44, 32, 13, 15, 18, 5, 32, 12, 5, 22, 5, 12, 19, 32, 20, 15, 32, 32, 5, 14, 10, 15, 25, 32, 13, 21, 20, 1, 20, 9, 14, 7, 32, 1, 23, 1, 25, 32, 32, 15, 14, 32, 25, 15, 21, 18, 32, 32, 3, 54, 52, 46, 32, 32, 32, 32, 3, 15, 13, 9, 14, 7, 32, 32, 32, 12, 1, 20, 5, 32, 32, 32, 50, 48, 49, 51, 32, 32, 32, 32, 32, 32, 32, 32, 32, 1, 22, 1, 9, 12, 1, 2, 12, 5, 32, 6, 18, 15, 13, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 8, 20, 20, 16, 58, 47, 47, 23, 23, 23, 46, 6, 12, 9, 13, 19, 15, 6, 20, 46, 3, 15, 46, 21, 11, 47, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 0



