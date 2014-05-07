SPRITE_LOC_Y    .equ 0
SPRITE_LOCX0    .equ 15
SPRITE_LOCX1    .equ 63
SPRITE_LOCX2    .equ 111
SPRITE_LOCX3    .equ 159
SPRITE_LOCX4    .equ 207
SPRITE_LOCX5    .equ 255
SPRITE_LOCX6    .equ 47
SPRITE_LOCX7    .equ 95

SPRITE_DB_H     .equ $D01D

SPRITE_DATA_LOC0 .equ $4000
SPRITE_DATA_LOC1 .equ $4040
SPRITE_DATA_LOC2 .equ $4080
SPRITE_DATA_LOC3 .equ $40C0
SPRITE_DATA_LOC4 .equ $4100
SPRITE_DATA_LOC5 .equ $4140
SPRITE_DATA_LOC6 .equ $4180
SPRITE_DATA_LOC7 .equ $41C0


startHSpriteScroller
    jsr zeroOutSpriteData

; Let VIC know where sprite 0 is located
lda #$00 ; 0
sta $5ff8
lda #$01 ; 1
sta $5ff9
lda #$02 ; 2
sta $5ffA
lda #$03 ; 3
sta $5ffB
lda #$04 ; 4
sta $5ffC
lda #$05 ; 5
sta $5ffD
lda #$06 ; 6
sta $5ffE
lda #$07 ; 7
sta $5ffF

; double all the Horizontal
lda #$ff
sta SPRITE_DB_H
; Set color
lda #3 ; cyan
ldx #9
colorAllSprites
    dex
    sta VIC_MEM+39, x ; 0
    bne colorAllSprites

; Sprite 0 Location
lda #SPRITE_LOCX0
ldx #SPRITE_LOC_Y
sta $d000
stx $d001
lda #SPRITE_LOCX1
sta $d002
stx $d003
lda #SPRITE_LOCX2
sta $d004
stx $d005
lda #SPRITE_LOCX3
sta $d006
stx $d007
lda #SPRITE_LOCX4
sta $d008
stx $d009
lda #SPRITE_LOCX5
sta $d00a
stx $d00b
ldy #%11000000
sty $D010 ; X greater than
lda #SPRITE_LOCX6
sta $d00c
stx $d00d
lda #SPRITE_LOCX7
sta $d00e
stx $d00f

; Enable Sprites
lda #$ff
sta $d015
rts

copySpriteDataIn
ldx #0
ldy #0

ldx msgOffset
; Char 0
inx
lda msgLow, x
sta zpPtr2
lda msgHigh, x
sta zpPtr2+1
inx
lda msgLow, x
sta zpPtr3
lda msgHigh, x
sta zpPtr3+1


ldx #0
cpdi_loop0
lda #0
sta SPRITE_DATA_LOC0, y
iny
; 2nd char
sty yTmp
txa
tay
lda (zpPtr2),y
ldy yTmp
sta SPRITE_DATA_LOC0, y
iny
; 3rd char
sty yTmp
txa
tay
lda (zpPtr3),y
ldy yTmp
sta SPRITE_DATA_LOC0, y
iny
inx
cpx #8
bne cpdi_loop0

; Sprite 1
ldx msgOffset
inx
inx
inx
lda msgLow, x
sta zpPtr1
lda msgHigh, x
sta zpPtr1+1
inx
lda msgLow, x
sta zpPtr2
lda msgHigh, x
sta zpPtr2+1
inx
lda msgLow, x
sta zpPtr3
lda msgHigh, x
sta zpPtr3+1

ldx #0
ldy #0
cpdi_loop1
sty yTmp
txa
tay
lda (zpPtr1),y
ldy yTmp
sta SPRITE_DATA_LOC1, y
iny
sty yTmp
txa
tay
lda (zpPtr2),y
ldy yTmp
sta SPRITE_DATA_LOC1, y
iny
sty yTmp
txa
tay
lda (zpPtr3),y
ldy yTmp
sta SPRITE_DATA_LOC1, y
iny
inx
cpx #8
bne cpdi_loop1


; Sprite 2
ldx msgOffset
inx
inx
inx
inx
inx
inx
lda msgLow, x
sta zpPtr1
lda msgHigh, x
sta zpPtr1+1
inx
lda msgLow, x
sta zpPtr2
lda msgHigh, x
sta zpPtr2+1
inx
lda msgLow, x
sta zpPtr3
lda msgHigh, x
sta zpPtr3+1

ldx #0
ldy #0
cpdi_loop2
sty yTmp
txa
tay
lda (zpPtr1),y
ldy yTmp
sta SPRITE_DATA_LOC2, y
iny
sty yTmp
txa
tay
lda (zpPtr2),y
ldy yTmp
sta SPRITE_DATA_LOC2, y
iny
sty yTmp
txa
tay
lda (zpPtr3),y
ldy yTmp
sta SPRITE_DATA_LOC2, y
iny
inx
cpx #8
bne cpdi_loop2
; Sprite 3
ldx msgOffset
inx
inx
inx
inx
inx
inx
inx
inx
inx
lda msgLow, x
sta zpPtr1
lda msgHigh, x
sta zpPtr1+1
inx
lda msgLow, x
sta zpPtr2
lda msgHigh, x
sta zpPtr2+1
inx
lda msgLow, x
sta zpPtr3
lda msgHigh, x
sta zpPtr3+1
ldx #0
ldy #0
cpdi_loop3
sty yTmp
txa
tay
lda (zpPtr1),y
ldy yTmp
sta SPRITE_DATA_LOC3, y
iny
sty yTmp
txa
tay
lda (zpPtr2),y
ldy yTmp
sta SPRITE_DATA_LOC3, y
iny
sty yTmp
txa
tay
lda (zpPtr3),y
ldy yTmp
sta SPRITE_DATA_LOC3, y
iny
inx
cpx #8
bne cpdi_loop3
; Sprite 4
ldx msgOffset
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
lda msgLow, x
sta zpPtr1
lda msgHigh, x
sta zpPtr1+1
inx
lda msgLow, x
sta zpPtr2
lda msgHigh, x
sta zpPtr2+1
inx
lda msgLow, x
sta zpPtr3
lda msgHigh, x
sta zpPtr3+1

ldx #0
ldy #0
cpdi_loop4
sty yTmp
txa
tay
lda (zpPtr1),y
ldy yTmp
sta SPRITE_DATA_LOC4, y
iny
sty yTmp
txa
tay
lda (zpPtr2),y
ldy yTmp
sta SPRITE_DATA_LOC4, y
iny
sty yTmp
txa
tay
lda (zpPtr3),y
ldy yTmp
sta SPRITE_DATA_LOC4, y
iny
inx
cpx #8
bne cpdi_loop4
; Sprite 5
ldx msgOffset
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
lda msgLow, x
sta zpPtr1
lda msgHigh, x
sta zpPtr1+1
inx
lda msgLow, x
sta zpPtr2
lda msgHigh, x
sta zpPtr2+1
inx
lda msgLow, x
sta zpPtr3
lda msgHigh, x
sta zpPtr3+1

ldx #0
ldy #0
cpdi_loop5
sty yTmp
txa
tay
lda (zpPtr1),y
ldy yTmp
sta SPRITE_DATA_LOC5, y
iny
sty yTmp
txa
tay
lda (zpPtr2),y
ldy yTmp
sta SPRITE_DATA_LOC5, y
iny
sty yTmp
txa
tay
lda (zpPtr3),y
ldy yTmp
sta SPRITE_DATA_LOC5, y
iny
inx
cpx #8
bne cpdi_loop5
; Sprite 6
ldx msgOffset
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
lda msgLow, x
sta zpPtr1
lda msgHigh, x
sta zpPtr1+1
inx
lda msgLow, x
sta zpPtr2
lda msgHigh, x
sta zpPtr2+1
inx
lda msgLow, x
sta zpPtr3
lda msgHigh, x
sta zpPtr3+1

ldx #0
ldy #0
cpdi_loop6
sty yTmp
txa
tay
lda (zpPtr1),y
ldy yTmp
sta SPRITE_DATA_LOC6, y
iny
sty yTmp
txa
tay
lda (zpPtr2),y
ldy yTmp
sta SPRITE_DATA_LOC6, y
iny
sty yTmp
txa
tay
lda (zpPtr3),y
ldy yTmp
sta SPRITE_DATA_LOC6, y
iny
inx
cpx #8
bne cpdi_loop6
; Sprite 7
ldx msgOffset
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
inx
lda msgLow, x
sta zpPtr1
lda msgHigh, x
sta zpPtr1+1
inx
lda msgLow, x
sta zpPtr2
lda msgHigh, x
sta zpPtr2+1
inx
lda msgLow, x
sta zpPtr3
lda msgHigh, x
bne continueOnNotLastChar
lda #0
sta msgOffset ; reset message counter now that we've gotten to the end
continueOnNotLastChar
sta zpPtr3+1

ldx #0
ldy #0
cpdi_loop7
sty yTmp
txa
tay
lda (zpPtr1),y
ldy yTmp
sta SPRITE_DATA_LOC7, y
iny
sty yTmp
txa
tay
lda (zpPtr2),y
ldy yTmp
sta SPRITE_DATA_LOC7, y
iny
sty yTmp
txa
tay
lda (zpPtr3),y
ldy yTmp
sta SPRITE_DATA_LOC7, y
iny
inx
cpx #8
bne cpdi_loop7
rts
cWasSet .byte $00
yTmp    .byte $00


moveSpritesLeft

    ; Sprite 0 Location
    ldx #0
msl_loop
    dec $d000
    dec $d002
    dec $d004
    dec $d006
    dec $d008
    dec $d00a
    dec $d00c
    dec $d00e
    jsr WaitFrame
    jsr setYForAllSprites
    inx
    cpx #15
    bne msl_loop

    ldx #0
msl_loop2
    inc $d000
    inc $d002
    inc $d004
    inc $d006
    inc $d008
    inc $d00a
    inc $d00c
    inc $d00e
    inx
    cpx #15
    bne msl_loop2
    rts


WaitFrame
lda $d012
cmp #100
beq WaitFrame
;wait for the raster to reach line $f8 (should be closer to the start of this line this way)
WaitStep2   lda $d012
cmp #100
bne WaitStep2
Return
rts



zeroOutSpriteData
    ldx #0
    txa
zosd_loop
    sta SPRITE_DATA_LOC0, x
    sta SPRITE_DATA_LOC0+$100, x
    inx
    bne zosd_loop
    rts

setYForAllSprites
    lda spritesYPos
    cmp #50
    beq startMovingItDownNow
    cmp #70
    beq startMovingItUpNow

    lda spritesYDir ; 0 = Down, 1 = Up
    beq moveAllSpritesDown
    bne moveAllSpritesUp

startMovingItDownNow
    lda #0
    sta spritesYDir
    jmp moveAllSpritesDown
startMovingItUpNow
    lda #1
    sta spritesYDir
    jmp moveAllSpritesUp

moveAllSpritesDown
    lda spritesYPos
    sta $d001
    sta $d003
    sta $d005
    sta $d007
    sta $d009
    sta $d00b
    sta $d00d
    sta $d00f
    inc spritesYPos
    rts

moveAllSpritesUp
    lda spritesYPos
    sta $d001
    sta $d003
    sta $d005
    sta $d007
    sta $d009
    sta $d00b
    sta $d00d
    sta $d00f
    dec spritesYPos
    rts

spritesYPos .byte   50
spritesYDir .byte   $00



msgOffset   .byte $00