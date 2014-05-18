FRAME_TL    .equ 110
FRAME_TOP   .equ 111
FRAME_TR    .equ 112
FRAME_LEFT  .equ 113
FRAME_RIGHT .equ 114
FRAME_BL    .equ 115
FRAME_BOT   .equ 116
FRAME_BR    .equ 117

WORLD_PIECE_SMALL       .equ 108
WORLD_PIECE_LARGE       .equ 109
WORLD_MARKER_CLEAR      .equ 0
WOLRD_CONVERT_LARGE     .equ 1
WORLD_CONVERT_SMALL     .equ 2
WOLRD_MARKER_SKIP_OVER  .equ 3
MAP_MASK_1              .equ %00000011
MAP_MASK_2              .equ %00001100
MAP_MASK_3              .equ %00110000
MAP_MASK_4              .equ %11000000

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
    sta zpPtr3
    lda #>SCREENMEM
    adc #0
    sta zpPtr2+1
    clc
    adc #$d4
    sta zpPtr3+1
    ldy #0
    ldx #0
pwcm_loop
    lda (zpPtr1),y
    cmp #$ff ; End char
    beq pwcm_done
    and pwcm_mask
    ldx pwcm_mask
    cpx #MAP_MASK_1
    beq pwcm_noShift
    cpx #MAP_MASK_2
    beq pwcm_shift2
    cpx #MAP_MASK_3
    beq pwcm_shift4
    lsr ; Default fall through shift 6
    lsr
pwcm_shift4
    lsr
    lsr
pwcm_shift2
    lsr
    lsr
pwcm_noShift
    cmp #WORLD_MARKER_CLEAR
    beq pwcm_notGreen ; 0 value not green
    cmp #WOLRD_MARKER_SKIP_OVER
    beq pwcm_wasGreen ; 0 value not green
    cmp #WORLD_CONVERT_SMALL
    bne pwcm_notLittleWorldChar
    lda #WORLD_PIECE_SMALL
    jmp pwcm_gotWorldChar
pwcm_notLittleWorldChar
    lda #WORLD_PIECE_LARGE
pwcm_gotWorldChar
    sta (zpPtr2), y
    lda #COLOR_GREEN
    sta (zpPtr3), y
    jmp pwcm_wasGreen
pwcm_notGreen
    lda #CLEAR_CHAR
    sta (zpPtr2), y
pwcm_wasGreen
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
    sta zpPtr3
    lda zpPtr2+1
    adc #0
    sta zpPtr2+1
    clc
    adc #$d4
    sta zpPtr3+1
    jmp pwcm_loop
pwcm_done
    rts
pwcm_mask   .byte   0 ; Set this value to select map to print


LEVEL_FOR_MAP1  .equ 0
LEVEL_FOR_MAP2  .equ 6
LEVEL_FOR_MAP3  .equ 7
LEVEL_FOR_MAP4  .equ 8
selectMapPerLevel
    lda currentLvl
    cmp #LEVEL_FOR_MAP1
    beq smpl_doMap1
    cmp #LEVEL_FOR_MAP2
    beq smpl_doMap2
    cmp #LEVEL_FOR_MAP3
    beq smpl_doMap3
    cmp #LEVEL_FOR_MAP4
    beq smpl_doMap4
    rts ; Not a level to change things
smpl_doMap1
    lda #MAP_MASK_1
    sta pwcm_mask
    jmp smpl_finishUp
smpl_doMap2
    lda #MAP_MASK_2
    sta pwcm_mask
    jmp smpl_finishUp
smpl_doMap3
    lda #MAP_MASK_3
    sta pwcm_mask
    jmp smpl_finishUp
smpl_doMap4
    lda #MAP_MASK_4
    sta pwcm_mask
smpl_finishUp
    jsr printWorldCharMap
    jsr drawScreenFrame
    rts
