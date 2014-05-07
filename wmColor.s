; There are 5 steps, COLOR_YELLOW, COLOR_L_GREEN, COLOR_GREEN, COLOR_CYAN, COLOR_BLUE
OUTBREAK_COLOR_LVL1 .equ COLOR_YELLOW
OUTBREAK_COLOR_LVL2 .equ COLOR_L_GREEN
OUTBREAK_COLOR_LVL3 .equ COLOR_GREEN
OUTBREAK_COLOR_LVL4 .equ COLOR_CYAN
OUTBREAK_COLOR_LVL5 .equ COLOR_L_BLUE
OUTBREAK_COLOR_LVL6 .equ $ff
OUTBREAK_LVL1       .equ 0
OUTBREAK_LVL2       .equ 1
OUTBREAK_LVL3       .equ 2
OUTBREAK_LVL4       .equ 3
OUTBREAK_LVL5       .equ 4
COLOR_PANDEMIC      .equ COLOR_RED
COLOR_OUTBREAK      .equ COLOR_YELLOW
COLOR_CLEAR         .equ COLOR_GREEN

updateColorWorldMap
    lda currentLvl
    cmp #OUTBREAK_LVL1
    beq setupLevel1
    cmp #OUTBREAK_LVL2
    beq setupLevel2
    cmp #OUTBREAK_LVL3
    beq setupLevel3
    cmp #OUTBREAK_LVL4
    beq setupLevel4
    cmp #OUTBREAK_LVL5
    beq setupLevel5
    rts
setupLevel1
    lda #OUTBREAK_COLOR_LVL1
    sta valueForRed
    lda #OUTBREAK_COLOR_LVL2
    sta valueForYellow
    lda #OUTBREAK_COLOR_LVL3
    sta valueForGreen
    jmp doColorWorldMap
setupLevel2
    lda #OUTBREAK_COLOR_LVL2
    sta valueForRed
    lda #OUTBREAK_COLOR_LVL3
    sta valueForYellow
    lda #OUTBREAK_COLOR_LVL4
    sta valueForGreen
    jmp doColorWorldMap
setupLevel3
    lda #OUTBREAK_COLOR_LVL3
    sta valueForRed
    lda #OUTBREAK_COLOR_LVL4
    sta valueForYellow
    lda #OUTBREAK_COLOR_LVL5
    sta valueForGreen
    jmp doColorWorldMap
setupLevel4
    lda #OUTBREAK_COLOR_LVL4
    sta valueForRed
    lda #OUTBREAK_COLOR_LVL5
    sta valueForYellow
    lda #OUTBREAK_COLOR_LVL6
    sta valueForGreen
    jmp doColorWorldMap
setupLevel5
    lda #OUTBREAK_COLOR_LVL5
    sta valueForRed
    lda #OUTBREAK_COLOR_LVL5
    sta valueForYellow
    lda #OUTBREAK_COLOR_LVL6
    sta valueForGreen
    jmp doColorWorldMap
doColorWorldMap
    ; Setup color pointers
    lda #<WMCOLORMAP
    sta zpPtr1
    lda #>WMCOLORMAP
    sta zpPtr1+1
    lda #<COLORMEM
    clc
    adc #120
    sta zpPtr2
    lda #>COLORMEM
    adc #0
    sta zpPtr2+1
    ldy #0
dcwm_loop
    lda (zpPtr1), y
    tax
    beq dcwm_complete ; 0 Reached end
    cpx valueForGreen
    bne dcwm_noMatchForClear
    lda #COLOR_CLEAR
    sta (zpPtr2), y
dcwm_noMatchForClear
    cpx valueForYellow
    bne dcwm_noMatchForOutbreak
    lda #COLOR_OUTBREAK
    sta (zpPtr2), y
dcwm_noMatchForOutbreak
    cpx valueForRed
    bne dcwm_noMatchForPandemic
    lda #COLOR_PANDEMIC
    sta (zpPtr2), y
dcwm_noMatchForPandemic
    iny
    bne dcwm_loop
    clc
    lda #$ff
    adc zpPtr1
    sta zpPtr1
    lda #0
    adc zpPtr1+1
    sta zpPtr1+1
    clc
    lda #$ff
    adc zpPtr2
    sta zpPtr2
    lda #0
    adc zpPtr2+1
    sta zpPtr2+1
    jmp dcwm_loop
dcwm_complete
    rts

valueForRed     .byte 0
valueForYellow  .byte 0
valueForGreen   .byte 0
