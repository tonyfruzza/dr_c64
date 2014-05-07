; This is the screen used to select the current level to play
; Levels are 0 - 20 that can be chosen lvl 21 is only reachable if you play through 20
; Read input from joystick and print
LEVELSELECTPOS  .equ 1096

printLevelSelectScreen
    lda #CLEAR_CHAR
    sta clearingChar ; Set the clearing char for screen clearing
    jsr ClearScreen
    jsr printWorldCharMap
    jsr drawScreenFrame
    jsr writeScreenTextForWorldMap
    jsr updateColorWorldMap

    jsr resetInputMovement
    jsr WaitEventFrame
    lda #0
    sta turnInputOff
    lda currentLvl
    sta levelSelectedLast

levelSelectLoop
    jsr updateTheLevelWeHaveSelected
    lda currentLvl
    cmp levelSelectedLast
    beq lsl_noLevelChange
    sta levelSelectedLast
    jsr updateColorWorldMap
lsl_noLevelChange
    jsr getJoystickInputForLevel
    bne levelSelected
    jmp levelSelectLoop
levelSelected
    rts
levelSelectedLast   .equ 0

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
    lda #<LEVELSELECTPOS
    sta zpPtr1
    lda #>LEVELSELECTPOS
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
