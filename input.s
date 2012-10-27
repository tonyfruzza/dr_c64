; take input from user for gameplay

JOY1            .equ 56321 ; Joystick flag byte
LR_MOVE_REPEAT_TIME .equ 6
ROTATE_REPEAT_TIME  .equ 10
DOWN_REPEAT_TIME    .equ 3

r_repeatTime    .byte $00
l_repeatTime    .byte $00
d_repeatTime    .byte $00
rotate_repeatTime   .byte $00


updateJoyPos
    ldy #0 ; for clearing times if need be
    ldx JOY1 ; cache JOY1 value in x
    txa
    and #1 ; Up
    bne nextJoy1 ; if no match, then skip to nextJoy1
; do something for up?
nextJoy1
    txa ; transfer
    and #2 ; Down
    bne nextJoy2
    lda d_repeatTime
    cmp #DOWN_REPEAT_TIME
    bcc finishJoy
    sty d_repeatTime
    jsr MoveDownOne
nextJoy2
    txa
    and #4 ; Left
    bne nextJoy3
    lda l_repeatTime
    cmp #LR_MOVE_REPEAT_TIME
    bcc finishJoy
    sty l_repeatTime
    jsr MoveLeftOne
nextJoy3
    txa
    and #8 ; Right
    bne nextJoy4
    lda r_repeatTime
    cmp #LR_MOVE_REPEAT_TIME
    bcc finishJoy
    sty r_repeatTime
    jsr MoveRightOne
nextJoy4
    txa
    and #16 ; Button push
    bne finishJoy
    lda rotate_repeatTime
    cmp #ROTATE_REPEAT_TIME
    bcc finishJoy
    sty rotate_repeatTime
    jsr rotate
finishJoy
    rts