; take input from user for gameplay

JOY1            .equ 56321 ; Joystick flag byte
LR_MOVE_REPEAT_TIME     .equ 5
LR_FIRST_MOVE_R_TIME    .equ 10
DOWN_REPEAT_TIME    .equ 2

l_repeatTime    .byte LR_FIRST_MOVE_R_TIME
r_repeatTime    .byte LR_FIRST_MOVE_R_TIME
l_firstPress    .byte $00
r_firstPress    .byte $00
d_repeatTime    .byte DOWN_REPEAT_TIME
rotate_repeatTime   .byte $00 ; Actually there is no repeat, so using this byte to track if button is being held down


updateJoyPos
    ldy #0 ; for clearing times if need be
    ldx JOY1 ; cache JOY1 value in x
;    txa
;    and #1 ; Up
;    bne nextJoy1 ; if no match, then skip to nextJoy1
    ; do something for up?

nextJoy1
    txa ; transfer
    and #2 ; Down
    bne nextJoy2
    lda d_repeatTime
    cmp #DOWN_REPEAT_TIME
    bcc nextJoy2
    sty d_repeatTime
    jsr MoveDownOne


nextJoy2 ; Left
    ldy #0
    txa
    and #4
    bne LeftNotPressed

    lda l_firstPress   ; 0 is true in this case
    cmp #2
    bcc LeftFirstPress ; < 2 then

    lda l_repeatTime
    cmp #LR_MOVE_REPEAT_TIME
    bcc nextJoy3
    jmp LeftNotFirstMove
LeftFirstPress
    lda l_repeatTime
    cmp #LR_FIRST_MOVE_R_TIME
    bcc nextJoy3 ; Less than LR_FIRST_MOVE?
    inc l_firstPress
LeftNotFirstMove
    sty l_repeatTime ; Reset repeat time back to 0
    jsr MoveLeftOne
    jmp nextJoy3
LeftNotPressed
    lda #LR_FIRST_MOVE_R_TIME
    sta l_repeatTime
    sty l_firstPress ; Reset first press to 0

nextJoy3 ; Right
    ldy #0
    txa
    and #8
    bne RightNotPressed

    lda r_firstPress
    cmp #2
    bcc RightFirstPress ; < 2 then
    lda r_repeatTime
    cmp #LR_MOVE_REPEAT_TIME
    bcc nextJoy4
    jmp RightNotFirstMove
RightFirstPress
    lda r_repeatTime
    cmp #LR_FIRST_MOVE_R_TIME
    bcc nextJoy4
    inc r_firstPress
RightNotFirstMove
    sty r_repeatTime
    jsr MoveRightOne
    jmp nextJoy4
RightNotPressed
    lda #LR_FIRST_MOVE_R_TIME
    sta r_repeatTime ; allow the key to be pressed again immediately after being picked up
    sty r_firstPress

nextJoy4
    ldy #0
    txa
    and #16 ; Button push
    bne ButtonNotPressed

    lda rotate_repeatTime
    bne finishJoy
    jsr rotate
inc rotate_repeatTime
    jmp finishJoy
ButtonNotPressed
;    lda #ROTATE_REPEAT_TIME
    sty rotate_repeatTime
finishJoy
    rts



; This will make sure all is reset back to the init state
resetInputMovement
    lda #LR_FIRST_MOVE_R_TIME
    sta l_repeatTime
    sta r_repeatTime
    lda #0
    sta l_firstPress
    sta r_firstPress
    sta rotate_repeatTime
    rts