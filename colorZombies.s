zombieColorSwap
    jsr setZombieColorSet
zcs_colorSomething
    lda zombieRightSideColor
    beq zcs_colorLeftSide
    cmp #1
    beq zcs_colorRightSide
    jmp zcs_done
; Draw Left side
zcs_colorLeftSide
    lda #$33 ; 1,587
    sta zpPtr2
    lda #$DA
    sta zpPtr2+1
    jmp zcs_color
zcs_colorRightSide
    ; Right Row 1/5
    lda #$4C ; 1,587
    sta zpPtr2
    lda #$DA
    sta zpPtr2+1
zcs_color
; Row 1/5
    jsr getZombieLeftColor
    ldy #0
    sta (zpPtr2), y
    iny
    sta (zpPtr2), y
    iny
    sta (zpPtr2), y
    iny ; space
    iny ; text
    iny ; space
    ; Right Zombie
    jsr getZombieRightColor
    iny
    sta (zpPtr2), y
    iny
    sta (zpPtr2), y
    iny
    sta (zpPtr2), y

    ; Row 2/5
    ldy #40
    jsr getZombieLeftColor
    sta (zpPtr2), y
    iny
    sta (zpPtr2), y
    iny
    sta (zpPtr2), y
    iny ; space
    iny ; text
    iny ; space
    ; Right Zombie
    jsr getZombieRightColor
    iny
    sta (zpPtr2), y
    iny
    sta (zpPtr2), y
    iny
    sta (zpPtr2), y

    ; Row 3/5
    ldy #80
    jsr getZombieLeftColor
    sta (zpPtr2), y
    iny
    sta (zpPtr2), y
    iny
    sta (zpPtr2), y
    iny ; space
    iny ; text
    iny ; space
    ; Right Zombie
    jsr getZombieRightColor
    iny
    sta (zpPtr2), y
    iny
    sta (zpPtr2), y
    iny
    sta (zpPtr2), y

    ; Row 4/5
    ldy #120
    jsr getZombieLeftColor
    sta (zpPtr2), y
    iny
    sta (zpPtr2), y
    iny
    sta (zpPtr2), y
    iny ; space
    iny ; text
    iny ; space
    ; Right Zombie
    jsr getZombieRightColor
    iny
    sta (zpPtr2), y
    iny
    sta (zpPtr2), y
    iny
    sta (zpPtr2), y

    ; Row 5/5
    ldy #160
    jsr getZombieLeftColor
    sta (zpPtr2), y
    iny
    sta (zpPtr2), y
    iny
    sta (zpPtr2), y
    iny ; space
    iny ; text
    iny ; space
    ; Right Zombie
    jsr getZombieRightColor
    iny
    sta (zpPtr2), y
    iny
    sta (zpPtr2), y
    iny
    sta (zpPtr2), y
    inc zombieRightSideColor
    jmp zcs_colorSomething
zcs_done
    lda #0
    sta zombieRightSideColor
    rts

zombieRightSideColor    .byte $00
zombieColorOffset       .byte $00
zombieColorSet          .byte $00, $00, $00, $00

setZombieColorSet
    lda zombieColorOffset
    beq noOffset
    cmp #1
    beq oneOffset
    cmp #2
    beq twoOffset
noOffset
    lda colors
    sta zombieColorSet
    lda colors+1
    sta zombieColorSet+1
    lda colors+2
    sta zombieColorSet+2
    lda #COLOR_WHITE
    sta zombieColorSet+3
    inc zombieColorOffset
    rts
oneOffset
    lda #COLOR_WHITE
    sta zombieColorSet
    lda colors+1
    sta zombieColorSet+1
    lda colors+2
    sta zombieColorSet+2
    lda colors
    sta zombieColorSet+3
    inc zombieColorOffset
    rts
twoOffset
    lda colors+2
    sta zombieColorSet
    lda #COLOR_WHITE
    sta zombieColorSet+1
    lda colors
    sta zombieColorSet+2
    lda colors+1
    sta zombieColorSet+3
    lda #0
    sta zombieColorOffset
    rts



getZombieLeftColor
    lda zombieRightSideColor
    beq zcs_lowColors
zcs_highColors
    lda zombieColorSet+2 ; color 3
    rts
zcs_lowColors
    lda zombieColorSet ; color 0
    rts



getZombieRightColor
    lda zombieRightSideColor
    beq zcs_lowColors2
zcs_highColors2
    lda zombieColorSet+3 ; color 4
    rts
zcs_lowColors2
    lda zombieColorSet+1 ; color 1
    rts


