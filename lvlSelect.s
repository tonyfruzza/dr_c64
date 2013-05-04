; This is the screen used to select the current level to play
; Levels are 0 - 20 that can be chosen lvl 21 is only reachable if you play through 20
; Read input from joystick and print


MSG_CHOOSE_LVL  .byte 3,8,15,15,19,5,32,12,5,22,5,12,32,23,9,20,8,32,10,15,25,49,58,0

printLevelSelectScreen
    jsr ClearScreen

    ; Print Level box and message
    lda #26 ; Width
    pha
    lda #1 ; Height
    pha
    lda #$1e ; low byte upper left corner
    pha
    lda #$05 ; high byte upper left corner
    pha
    jsr DrawBorderBox

    lda #<MSG_CHOOSE_LVL
    pha
    lda #>MSG_CHOOSE_LVL
    pha

    lda #$47
    pha
    lda #$05
    pha
    jsr printMsgSub
    jsr resetInputMovement

levelSelectLoop
    jsr updateTheLevelWeHaveSelected
    jsr getJoystickInputForLevel
    bne levelSelected
    jmp levelSelectLoop
levelSelected
    rts

updateTheLevelWeHaveSelected
    lda #0
    sta tmp ; to store our decimal value of level
    ldx currentLvl
    beq utlwhs_print
    sed
utlwhs_loop
    clc
    lda tmp
    adc #1
    sta tmp
    dex
    beq utlwhs_print

    jmp utlwhs_loop
utlwhs_print
    cld
    lda #$5e
    sta zpPtr1
    lda #$05
    sta zpPtr1+1
    lda tmp
    and #$f0
    lsr
    lsr
    lsr
    lsr
    ora #$30
    ldy #0
    sta (zpPtr1),y
    lda tmp
    and #$0f
    ora #$30
    iny
    sta (zpPtr1),y

clc
lda #$d4
adc zpPtr1+1
sta zpPtr1+1
lda #COLOR_WHITE
sta (zpPtr1),y
dey
sta (zpPtr1),y
    rts
