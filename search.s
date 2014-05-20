;
; Loop through the entire playing field and find connect 4's
;
lookForAnyConnect4s
    ldy #$00
    sty TMP1 ; used as a screen y offset, 0 - 15
    sty tmp2 ; used as a screen x offset, 0 - 7
    ; Reset virus counts to 0
    sty virus1_count
    sty virus2_count
    sty virus3_count

    lda #OnePGameFieldLocLow ; start <
    ;        lda #$0f
    sta zpPtr1
    lda #OnePGameFieldLocHigh ; start >
    ;        lda #$04
    sta zpPtr1+1
connectsOuterLoop
    lda tmp2 ; what's the current x offset?
    cmp #8
    beq anyConnectDone
    clc
    lda zpPtr1
    adc #$01
    sta zpPtr1
    sta zpPtr4
    lda #$00
    sta tmp1 ; reset inner loop
    adc zpPtr1+1
    sta zpPtr1+1
    sta zpPtr4+1
anyConnectInnerLoop
    lda tmp1  ; y offset
    cmp #16
    beq anyConnectInnerLoopDone
    lda (zpPtr4),y
    ; Tried writing this as a subroutine, it's corrupting the stack though :-(
    cmp #VIRUS_ONE
    beq lfac4_piece
    cmp #VIRUS_TWO
    beq lfac4_piece
    cmp #VIRUS_THREE
    beq lfac4_piece
    cmp #PILL_SIDE
    beq lfac4_piece
    cmp #PILL_LEFT
    beq lfac4_piece
    cmp #PILL_RIGHT
    beq lfac4_piece
    cmp #PILL_TOP
    beq lfac4_piece
    cmp #PILL_BOTTOM
    beq lfac4_piece
    cmp #PILL_CLEAR_1
    beq lfac4_piece
    jmp nextConnectAnyRow
lfac4_piece
    lda zpPtr4
    pha
    lda zpPtr4+1
    pha
    jsr lookForConnect4c
    nextConnectAnyRow
    inc tmp1
    clc
    lda zpPtr4
    adc #40
    sta zpPtr4
    lda #$00
    adc zpPtr4+1
    sta zpPtr4+1
    jmp anyConnectInnerLoop
anyConnectInnerLoopDone
    inc tmp2
    jmp connectsOuterLoop
anyConnectDone
    rts



;
FieldSearch
    lda #$00
    sta fs_didWorkReturn ; to be returned as the count of drops that occured
fs_Continue ; a = void()
    lda #$10 ; #0f wasn't enough
    sta fs_innerLoopIdx  ; used as screen y offset, 0 - 15
    ldy #$00
    sty fs_didWorkThisLoop      ; used to keep track if anything dropped, shared with dropDownIfYouCan
    sty fs_outLoopIdx   ; used as screen x index 0 - 7
    sty p1VirusCount ; reset our virus count for player one
    sty p1VirusCountBinNew
    ; Bottom left pos is +$0280 from top left game field
    ; In bottom left wall corner
    clc
    lda #OnePGameFieldLocLow
    adc #$80
    sta zpPtr1
    lda #OnePGameFieldLocHigh
    adc #$02
    sta zpPtr1+1
fs_dropOuterLoop
    lda fs_outLoopIdx
    cmp #8
    beq fs_done
    ; Move one right
    clc
    lda zpPtr1
    adc #$01
    sta zpPtr1
    sta zpPtr2
    lda #$00
    adc zpPtr1+1
    sta zpPtr1+1
    sta zpPtr2+1
    lda #$11 ; $0f wasn't enough
    sta fs_innerLoopIdx ; reset inner loop index
fs_dropInnerLoop
    lda fs_innerLoopIdx
    beq fs_dropInnerLoopComplete
    sec
    lda zpPtr2
    sbc #40
    sta zpPtr2
    lda zpPtr2+1
    sbc #$00
    sta zpPtr2+1
    lda (zpPtr2),y
    ; Look for viruses for total
    cmp #VIRUS_ONE
    beq itsVirus1
    cmp #VIRUS_TWO
    beq itsVirus2
    cmp #VIRUS_THREE
    beq itsVirus3
    jmp notAVirus
itsVirus1
    inc virus1_count
    jmp itIsAVirus
itsVirus2
    inc virus2_count
    jmp itIsAVirus
itsVirus3
    inc virus3_count
itIsAVirus
    ; It is a virus
    sed ; go into decimal mode
    clc
    lda #1
    adc p1VirusCount
    sta p1VirusCount
    cld ; back to binary math
    inc p1VirusCountBinNew
    lda (zpPtr2),y ; reload in what we are comparing
notAVirus
    cmp #PILL_CLEAR_1
    bne fs_nextCharType
    inc fs_didWorkThisLoop
    ; This is where we'd sleep before
    lda #PILL_CLEAR_2
    sta (zpPtr2),y
    jmp fs_nextRow
fs_nextCharType
    cmp #PILL_CLEAR_2
    bne fs_nextRow
    inc fs_didWorkReturn
    lda #CLEAR_CHAR
    sta (zpPtr2),y
fs_nextRow
    dec fs_innerLoopIdx
    jmp fs_dropInnerLoop
fs_dropInnerLoopComplete
    inc fs_outLoopIdx
    jmp fs_dropOuterLoop
    fs_done
    lda fs_didWorkThisLoop
    beq fs_reallyDone
fs_doMoreWork
    jsr WaitEventFrame ; Wait between clearing animation
    jmp fs_Continue ; if there were any dropped this last time, see if there were any left
fs_reallyDone
    lda fs_didWorkReturn
    rts

fs_outLoopIdx       .byte $00
fs_innerLoopIdx     .byte $0f
fs_didWorkThisLoop  .byte $00
fs_didWorkReturn    .byte $00

virus1_count        .byte 0
virus2_count        .byte 0
virus3_count        .byte 0
