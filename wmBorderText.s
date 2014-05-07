FRAME_TL    .equ 110
FRAME_TOP   .equ 111
FRAME_TR    .equ 112
FRAME_LEFT  .equ 113
FRAME_RIGHT .equ 114
FRAME_BL    .equ 115
FRAME_BOT   .equ 116
FRAME_BR    .equ 117

drawScreenFrame
    lda #<SCREENMEM
    sta zpPtr1
    sta zpPtr2
    lda #>SCREENMEM
    sta zpPtr1+1
    clc
    adc #$D4
    sta zpPtr2+1
; top left corner
    ldy #0
    lda #FRAME_TL
    sta (zpPtr1),y
    lda #COLOR_L_GREY
    sta (zpPtr2),y
    iny
    ; Draw top line
dsf_topline
    lda #FRAME_TOP
    sta (zpPtr1), y
    lda #COLOR_L_GREY
    sta (zpPtr2), y
    iny
    cpy #39
    bne dsf_topline
    ; Draw top right
    lda #FRAME_TR
    sta (zpPtr1), y
    lda #COLOR_L_GREY
    sta (zpPtr2), y
    ldx #0

dsf_drawSides
    ldy #0
    clc
    lda zpPtr1
    adc #40
    sta zpPtr1
    sta zpPtr2
    lda zpPtr1+1
    adc #0
    sta zpPtr1+1
    sta zpPtr2+1
    clc
    adc #$D4
    sta zpPtr2+1
    lda #FRAME_LEFT
    sta (zpPtr1),y
    lda #COLOR_L_GREY
    sta (zpPtr2),y
    ldy #39
    lda #FRAME_RIGHT
    sta (zpPtr1),y
    lda #COLOR_L_GREY
    sta (zpPtr2),y
    inx
    cpx #24
    bne dsf_drawSides
    ; Draw bottom left corner
    ldy #0
    lda #FRAME_BL
    sta (zpPtr1), y
dsf_drawBottom
    iny
    lda #FRAME_BOT
    sta (zpPtr1), y
    lda #COLOR_L_GREY
    sta (zpPtr2), y
    cpy #38
    bne dsf_drawBottom
    ; Draw bottom right
    iny
    lda #FRAME_BR
    sta (zpPtr1), y
    rts

writeScreenTextForWorldMap
    lda #<PROGRESS
    pha
    lda #>PROGRESS
    pha
    lda #$2a
    pha
    lda #$04
    pha
    jsr printMsgSub

    lda #<LABELS
    pha
    lda #>LABELS
    pha
    lda #$9a
    pha
    lda #$07
    pha
    jsr printMsgSub
    ; Color the labels
    lda #COLOR_GREEN
    sta $db9a
    lda #COLOR_YELLOW
    sta $dba8
    lda #COLOR_RED
    sta $dbB5
    rts

printWorldCharMap
    lda #<WORLDCHARMAP
    sta zpPtr1
    lda #>WORLDCHARMAP
    sta zpPtr1+1
    lda #<SCREENMEM
    clc
    adc #120
    sta zpPtr2
    lda #>SCREENMEM
    adc #0
    sta zpPtr2+1
    ldy #0
    ldx #0
pwcm_loop
    lda (zpPtr1),y
    beq pwcm_done
    cmp #108 ; If it's one of those small map pieces
    bne pwcm_notLittleWorldChar
    jsr color_zpPtr2Green
    lda (zpPtr1),y ; reload value back in
pwcm_notLittleWorldChar
    cmp #109 ; If it's one of those larger map pieces
    bne pwcm_notGreen
    jsr color_zpPtr2Green
    lda (zpPtr1),y ; reload value back in
pwcm_notGreen
    sta (zpPtr2),y
    iny
    bne pwcm_loop
    clc
    lda zpPtr1
    adc #$ff
    sta zpPtr1
    lda zpPtr1+1
    adc #0
    sta zpPtr1+1
    clc
    lda zpPtr2
    adc #$ff
    sta zpPtr2
    lda zpPtr2+1
    adc #0
    sta zpPtr2+1
    jmp pwcm_loop
pwcm_done
    rts

color_zpPtr2Green
    clc
    lda zpPtr2
    sta zpPtr3
    lda zpPtr2+1
    adc #$d4
    sta zpPtr3+1
    lda #COLOR_GREEN
    sta (zpPtr3), y
    rts