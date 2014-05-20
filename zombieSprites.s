; Data is already copied in because of copySpriteDataInForPlayerHead
; All we need to do is configure them using 

ZMB_FLICKER_FRAMES    .equ  25 ; How many frames to flicker when dying
; Seems to be sprite pad # - 1
ZMB1_BASE   .equ 194 + 11
ZMB1_OVR1   .equ 194 + 12
ZMB1_OVR2   .equ 194 + 13

ZMB2_BASE   .equ 194 + 14
ZMB2_OVR1   .equ 194 + 15
ZMB2_OVR2   .equ 194 + 16

ZMB3_BASE   .equ 194 + 17
ZMB3_OVR1   .equ 194 + 18
ZMB3_OVR2   .equ 194 + 19

SPRITE1_COLOR   .equ VMEM + 39
SPRITE2_COLOR   .equ VMEM + 40
SPRITE3_COLOR   .equ VMEM + 41
SPRITE4_COLOR   .equ VMEM + 42
SPRITE5_COLOR   .equ VMEM + 43
SPRITE6_COLOR   .equ VMEM + 44
SPRITE7_COLOR   .equ VMEM + 45
SPRITE8_COLOR   .equ VMEM + 46

SPRITE1_X_POS   .equ $d000
SPRITE1_Y_POS   .equ $d001
SPRITE2_X_POS   .equ $d002
SPRITE2_Y_POS   .equ $d003
SPRITE3_X_POS   .equ $d004
SPRITE3_Y_POS   .equ $d005
SPRITE4_X_POS   .equ $d006
SPRITE4_Y_POS   .equ $d007
SPRITE5_X_POS   .equ $d008
SPRITE5_Y_POS   .equ $d009
SPRITE6_X_POS   .equ $d00a
SPRITE6_Y_POS   .equ $d00b
SPRITE7_X_POS   .equ $d00c
SPRITE7_Y_POS   .equ $d00d
SPRITE8_X_POS   .equ $d00e
SPRITE8_Y_POS   .equ $d00f

initZombieSprites
    lda #%01111011
    sta faceSpriteEnableMask
    lda #0
    sta whoIsCompletelyDead
    sta whoDiedLast
    rts

enableZombieFaceSprites
    ; Configure memory locations
    lda #ZMB1_BASE
    sta SPRITE1_POINT+1 ; Sprite 2
    lda #ZMB2_BASE
    sta SPRITE1_POINT+4
    lda #ZMB3_BASE
    sta SPRITE1_POINT+6

    lda $d015
    and #%00000100
    bne ScoreOverTopIsHappening
    lda #ZMB1_OVR1
    sta SPRITE1_POINT
    lda #ZMB2_OVR1
    sta SPRITE1_POINT+3
    lda #ZMB3_OVR1
    sta SPRITE1_POINT+5
    jmp zmbOverTopSet
ScoreOverTopIsHappening
    lda #ZMB1_OVR2
    sta SPRITE1_POINT
    lda #ZMB2_OVR2
    sta SPRITE1_POINT+3
    lda #ZMB3_OVR2
    sta SPRITE1_POINT+5
zmbOverTopSet

    ; Bases are multicolor which are 1, 4, 6
    lda #%01010010
    sta $d01C

    lda #COLOR_DARK_GREY
    sta SPRITE1_COLOR
    lda #COLOR_L_BLUE
    lda colors+1
    sta SPRITE2_COLOR
    lda #COLOR_MAGENTA
    sta SPRITE4_COLOR
    lda #COLOR_CYAN
    lda colors+0
    sta SPRITE5_COLOR
    lda #COLOR_BROWN
    sta SPRITE6_COLOR
    lda #COLOR_L_GREEN
    lda colors+2
    sta SPRITE7_COLOR
    ; Multi colors are shared with other set

    lda #0
    sta $d010 ; Everyone is x<=256
    ; Zombie 1 pos
    lda #50
    sta SPRITE1_X_POS ; x pos sprite 1
    sta SPRITE2_X_POS ; x pos sprite 2
    lda #70
    sta SPRITE5_X_POS
    sta SPRITE4_X_POS
    lda #90
    sta SPRITE6_X_POS
    sta SPRITE7_X_POS
    lda #171
    sta SPRITE1_Y_POS
    sta SPRITE2_Y_POS
    sta SPRITE4_Y_POS
    sta SPRITE5_Y_POS
    sta SPRITE6_Y_POS
    sta SPRITE7_Y_POS
    ; Enable 124567 at first
    lda $d015
    and #%10000100 ; If score over the top is active then leave.
    ora faceSpriteEnableMask
    sta $d015
    jsr handleZmbiFlicker
    rts


handleZmbiFlicker
    lda framesFlickered
    beq noFlickers
    and #%00000001 ; Is it an odd number?
    beq hzf_notOdd
    lda whoDiedLast
    ora $d015 ; Enable them
    eor whoIsCompletelyDead
    sta $d015
    dec framesFlickered
    beq hzf_lastFlicker
    rts
hzf_notOdd
    lda whoDiedLast
    lda #$ff
    eor whoDiedLast
    eor whoIsCompletelyDead
    and $d015
    sta $d015
    dec framesFlickered
    beq hzf_lastFlicker
    rts
noFlickers
    lda #0
    sta whoDiedLast
    rts
hzf_lastFlicker
    lda whoDiedLast
    sta whoIsCompletelyDead
    rts

shouldWeDisableAFace
    lda virus1_count
    bne getMaskForVirus2
    lda #%11100111
    and faceSpriteEnableMask
    sta faceSpriteEnableMask
    lda #ZMB_FLICKER_FRAMES
    sta framesFlickered
    lda #%00011000
    ora whoDiedLast
    sta whoDiedLast
getMaskForVirus2
    lda virus2_count
    bne getMaskForVirus3
    lda #%11111100
    and faceSpriteEnableMask
    sta faceSpriteEnableMask
    lda #ZMB_FLICKER_FRAMES
    sta framesFlickered
    lda #%00000011
    ora whoDiedLast
    sta whoDiedLast
getMaskForVirus3
    lda virus3_count
    bne getMaskForVirusDone
    lda #%10011111
    and faceSpriteEnableMask
    sta faceSpriteEnableMask
    lda #ZMB_FLICKER_FRAMES
    sta framesFlickered
    lda #%01100000
    ora whoDiedLast
    sta whoDiedLast
getMaskForVirusDone
    rts

faceSpriteEnableMask    .byte 0
framesFlickered         .byte 0
whoDiedLast             .byte 0
whoIsCompletelyDead     .byte 0
