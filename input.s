; take input from user for gameplay

;JOY1                    .equ 56321 ; Joystick flag byte
; Swapping joysticks!!! JOY1 is actually JOY2!
JOY1                    .equ 56320 ; Joystick flag byte
JOY2                    .equ 56320
LR_MOVE_REPEAT_TIME     .equ 5
LR_FIRST_MOVE_R_TIME    .equ 7
DOWN_REPEAT_TIME        .equ 2
FIRE_REPEAT_TIME        .equ 7
JOY_BIT_UP              .equ 1
JOY_BIT_DOWN            .equ 2
JOY_BIT_LEFT            .equ 4
JOY_BIT_RIGHT           .equ 8
JOY_BIT_FIRE            .equ 16

l_repeatTime    .byte LR_FIRST_MOVE_R_TIME
r_repeatTime    .byte LR_FIRST_MOVE_R_TIME
l_firstPress    .byte $00
r_firstPress    .byte $00
d_repeatTime    .byte DOWN_REPEAT_TIME
f_repeatTime    .byte FIRE_REPEAT_TIME
rotate_Hold     .byte $00 ; Actually there is no repeat, so using this byte to track if button is being held down
turnInputOff    .byte $00


; This will make sure all is reset back to the init state
resetInputMovement
    lda #LR_FIRST_MOVE_R_TIME
    sta l_repeatTime
    sta r_repeatTime
    lda #FIRE_REPEAT_TIME
    sta f_repeatTime
    lda #0
    sta l_firstPress
    sta r_firstPress
    sta rotate_Hold
    rts

updateJoyPos
    ldy #0 ; for clearing times if need be
    ldx JOY1 ; cache JOY1 value in x
;    txa
;    and #1 ; Up
;    bne nextJoy1 ; if no match, then skip to nextJoy1
    ; do something for up?

nextJoy1
    txa ; Cache joystick input values
    and #JOY_BIT_DOWN
    bne nextJoy2
    lda d_repeatTime
    cmp #DOWN_REPEAT_TIME
    bcc nextJoy2
    sty d_repeatTime
    jsr MoveDownOne


nextJoy2 ; Left
    ldy #0
    txa
    and #JOY_BIT_LEFT
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
    and #JOY_BIT_RIGHT
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
    and #JOY_BIT_FIRE
    bne ButtonNotPressed

    lda rotate_Hold
    bne finishJoy
    ; Look to see when the last time was that we rotated
    lda f_repeatTime
    cmp #FIRE_REPEAT_TIME
    bcc finishJoy

    jsr rotate
    sty f_repeatTime ; Reset the last time we hit fire to 0 counter
    inc rotate_Hold
    jmp finishJoy
ButtonNotPressed
    sty rotate_Hold ; Fire not pressed, prevent rotating while holding down fire
finishJoy
    rts



;
;       For LEVEL SELECT
;
getJoystickInputForLevel ; returns 1 if button pressed to accept
    lda turnInputOff
    beq gjifl_readInput
    jmp gjifl_ButtonNotPressed
gjifl_readInput
    ldx JOY2 ; cache JOY1 value in x
    ldy #0
    txa
    and #JOY_BIT_LEFT
    bne gjifl_LeftNotPressed
    lda currentLvl
    beq gjifl_nextJoy3
    lda l_firstPress   ; 0 is true in this case
    cmp #2
    bcc gjifl_LeftFirstPress ; < 2 then
    lda l_repeatTime
    lsr
    cmp #LR_MOVE_REPEAT_TIME
    bcc gjifl_nextJoy3
    jmp gjifl_LeftNotFirstMove
gjifl_LeftFirstPress
    lda l_repeatTime
    cmp #LR_FIRST_MOVE_R_TIME
    bcc gjifl_nextJoy3 ; Less than LR_FIRST_MOVE?
    inc l_firstPress
gjifl_LeftNotFirstMove
    sty l_repeatTime ; Reset repeat time back to 0
    dec currentLvl
    jmp gjifl_nextJoy3
gjifl_LeftNotPressed
    lda #LR_FIRST_MOVE_R_TIME
    sta l_repeatTime
    sty l_firstPress ; Reset first press to 0
gjifl_nextJoy3 ; Right
    ldy #0
    txa
    and #JOY_BIT_RIGHT
    bne gjifl_RightNotPressed
    lda currentLvl
    cmp #20
    beq gjifl_nextJoy4
    lda r_firstPress
    cmp #2
    bcc gjifl_RightFirstPress ; < 2 then
    lda r_repeatTime
    lsr
    cmp #LR_MOVE_REPEAT_TIME
    bcc gjifl_nextJoy4
    jmp gjifl_RightNotFirstMove
gjifl_RightFirstPress
    lda r_repeatTime
    cmp #LR_FIRST_MOVE_R_TIME
    bcc gjifl_nextJoy4
    inc r_firstPress
gjifl_RightNotFirstMove
    sty r_repeatTime
    inc currentLvl
    jmp gjifl_nextJoy4
gjifl_RightNotPressed
    lda #LR_FIRST_MOVE_R_TIME
    sta r_repeatTime ; allow the key to be pressed again immediately after being picked up
    sty r_firstPress
gjifl_nextJoy4
    txa
    and #JOY_BIT_FIRE
    bne gjifl_ButtonNotPressed
gjifl_buttonPressed
    lda #1 ; return true
    rts
gjifl_ButtonNotPressed
    lda #0 ; return false
    rts


getFireButtonPressed
    lda JOY2
    and #JOY_BIT_FIRE
    bne gfbp_notPressed
    lda #1
    rts
gfbp_notPressed
    lda #0
    rts

