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

ZMB1_X_POS  .equ 50
ZMB2_X_POS  .equ 70
ZMB3_X_POS  .equ 90

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

ZMB1_SPRITES_MASK    .equ %00011000
ZMB2_SPRITES_MASK    .equ %00000011
ZMB3_SPRITES_MASK    .equ %01100000

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
SeeWhoIsGettingInjured
    ldy #ZMB1_X_POS
    ldx #ZMB1_OVR1
    lda injuredVirusMask
    and #ZMB1_SPRITES_MASK ; Purple?
    beq sotih_notZombie1
    ldx #ZMB1_OVR2
    lda injuredFrameCount
    and #1 ; Is it odd?
    beq sotih_notZombie1
    ldy #ZMB1_X_POS+1 ; Shake him!
sotih_notZombie1
    sty SPRITE1_X_POS ; x pos sprite 1
    sty SPRITE2_X_POS ; x pos sprite 2
    stx SPRITE1_POINT

    ldy #ZMB2_X_POS
    ldx #ZMB2_OVR1
    lda injuredVirusMask
    and #ZMB2_SPRITES_MASK
    beq sotih_notZombie2
    ldx #ZMB2_OVR2
    lda injuredFrameCount
    and #1 ; Is it odd?
    beq sotih_notZombie2
    ldy #ZMB2_X_POS+1 ; Shake him!
sotih_notZombie2
    stx SPRITE1_POINT+3
    sty SPRITE5_X_POS
    sty SPRITE4_X_POS

    ldy #ZMB3_X_POS
    ldx #ZMB3_OVR1
    lda injuredVirusMask
    and #ZMB3_SPRITES_MASK
    beq sotih_notZombie3
    ldx #ZMB3_OVR2
    lda injuredFrameCount
    and #1 ; Is it odd?
    beq sotih_notZombie3
    ldy #ZMB3_X_POS+1 ; Shake him!
sotih_notZombie3
    sty SPRITE6_X_POS
    sty SPRITE7_X_POS
    stx SPRITE1_POINT+5
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

    lda #171
    sta SPRITE1_Y_POS
    sta SPRITE2_Y_POS
    sta SPRITE4_Y_POS
    sta SPRITE5_Y_POS
    sta SPRITE6_Y_POS
    sta SPRITE7_Y_POS
    ; Enable 124567 at first
    lda $d015
    and #%10000100 ; If score over the top is active then leave sprite 3 and 8 enabled
    ora faceSpriteEnableMask
    sta $d015
    jsr handleZmbiFlicker
    inc injuredFrameCount
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
    lda #ZMB1_SPRITES_MASK
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
    lda #ZMB2_SPRITES_MASK
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
    lda #ZMB3_SPRITES_MASK
    ora whoDiedLast
    sta whoDiedLast
getMaskForVirusDone
    rts

faceSpriteEnableMask    .byte 0
framesFlickered         .byte 0
whoDiedLast             .byte 0
whoIsCompletelyDead     .byte 0
injuredFrameCount       .byte 0

