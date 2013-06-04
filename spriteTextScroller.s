; load_labels "/Users/Tony/Development/DrC64/labels.txt"
VIC_MEM         .equ 53248
SCREEN_BORDER   .equ VIC_MEM + 32
SPRITE_LOC_Y    .equ 40
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

piece1          .equ $b0
ROMCHARBITMAP   .equ 53248 ; - 57343 from ROM
NEWCHARMAP      .equ $9000 ;
zpPtr1          .equ $ba
zpPtr2          .equ $b4
zpPtr3          .equ $b6
; Koala picture format locations:
; $6000 - $7F3F BITMAP
; $7F40 - $8327 SCREEN RAM
; $8328 - $870F COLOR RAM
; $8710 Background color

; Program is now residing in $0801 - $3711
; Character data copied to $9000
; Sprite data $4000 - $4200


.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00

init
;    lda #1
;    sta SCREEN_BORDER
    jsr setupScreenForSpashScreen
    jsr MapInRomChars
    jsr CharCopy
    jsr MapOutRomChars
    jsr zeroOutSpriteData
    jsr copySpriteDataIn
jsr init_irq
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

    ; Set color to white
    lda #3 ; cyan
    sta VIC_MEM+39 ; 0
    sta VIC_MEM+40 ; 1
    sta VIC_MEM+41 ; 2
    sta VIC_MEM+42 ; 3
    sta VIC_MEM+43 ; 4
    sta VIC_MEM+44 ; 5
    sta VIC_MEM+45 ; 6
    sta VIC_MEM+46 ; 7


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


main_loop
    jsr copySpriteDataIn
    jsr moveSpritesLeft
    inc msgOffset
    jmp main_loop
    rts

init_irq
sei
lda #<irq1
sta $314
lda #>irq1
sta $315
lda #$7f
sta $dc0d ; enable interrupts
lda #$1b ; character mode default
sta $d011
lda #$01
sta $d01a ; raster interrupt enabled by #1
cli
rts

irq1
    inc $d019
    lda #1
    sta $d012
    lda #$00
    sta $d011
    lda #<irq2
    sta $314
    lda #>irq2
    sta $315
    jmp $ea31 ; return to standard irq

irq2
    inc $d019
    lda #$fa ; 250
    sta $d012
    ; #$1b to display text
    lda #$3b ;If you want to display a bitmap pic, use #$3b instead
    sta $d011
    lda #<irq1
    sta $314
    lda #>irq1
    sta $315
    jmp $ea31 ; return to standard irq



MapInRomChars
lda 56334
and #254
sta 56334
    ; Switch in ROM characters into RAM
    lda 1
    and #251
    sta 1
    rts

MapOutRomChars
    ; Switch i/o
    lda 1
    ora #4
    sta 1
; Turn keyboard scanning back ON
lda 56334
ora #1
sta 56334
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


CharCopy
    ldx #00
ldy #00
CharCopyLoop
    lda ROMCHARBITMAP,x
    sta NEWCHARMAP,x
    lda ROMCHARBITMAP+$100, x
    sta NEWCHARMAP+$100,x
    lda ROMCHARBITMAP+$200, x
    sta NEWCHARMAP+$200,x
    lda ROMCHARBITMAP+$300, x
    sta NEWCHARMAP+$300,x
    inx
    bne CharCopyLoop
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


; For bitmap part

copyImage
; Bitmap data is loaded in at $6000 - $7F3F which is 7,999 bytes, or 31 * 256
; Load background color and set it
; $8710 - $6000 = 2710
lda bday+$2710
;lda #0
sta $d020
sta $d021
; Loop to 256 31 times here

ldx #0
loadccimage
;    jmp setColorRam
; BITMAP
lda bday,x
sta $6000,x
lda bday+$100,x
sta $6100,x
lda bday+$200,x
sta $6200,x
lda bday+$300,x
sta $6300,x
lda bday+$400,x
sta $6400,x
lda bday+$500,x
sta $6500,x
lda bday+$600,x
sta $6600,x
lda bday+$700,x
sta $6700,x
lda bday+$800,x
sta $6800,x
lda bday+$900,x
sta $6900,x
lda bday+$A00,x
sta $6A00,x
lda bday+$B00,x
sta $6B00,x
lda bday+$C00,x
sta $6C00,x
lda bday+$D00,x
sta $6D00,x
lda bday+$E00,x
sta $6E00,x
lda bday+$F00,x
sta $6F00,x
lda bday+$1000,x
sta $7000,x
lda bday+$1100,x
sta $7100,x
lda bday+$1200,x
sta $7200,x
lda bday+$1300,x
sta $7300,x
lda bday+$1400,x
sta $7400,x
lda bday+$1500,x
sta $7500,x
lda bday+$1600,x
sta $7600,x
lda bday+$1700,x
sta $7700,x
lda bday+$1800,x
sta $7800,x
lda bday+$1900,x
sta $7900,x
lda bday+$1A00,x
sta $7A00,x
lda bday+$1B00,x
sta $7B00,x
lda bday+$1C00,x
sta $7C00,x
lda bday+$1D00,x
sta $7D00,x
lda bday+$1E00,x
sta $7E00,x
lda bday+$1F00,x
sta $7F00,x


; SCREEN RAM
; $7F40 - $6000 =
lda bday+$1f40,x
;    LDA $7F40,X
STA $5C00,X
lda bday+$2040,x
;    LDA $8040,X
STA $5D00,X
lda bday+$2140,x
;    LDA $8140,X
STA $5E00,X
lda bday+$2240,x
;    LDA $8240,X
STA $5F00,X

; COLOR RAM
; $8328 - $6000 = $2328
; $7C00 more than screen mem??
setColorRam
    lda bday+$2328,x
    STA $D800,X
    lda bday+$2428,x
    STA $D900,X
    lda bday+$2528,x
    STA $DA00,X
    lda bday+$2628,x
    STA $DB00,X


    inx
    beq ci_done
    jmp loadccimage
ci_done
    rts


setupScreenForSpashScreen
;    jsr backUpCurrentVideoSettings
jsr setToBitMapMode
    jsr copyImage
    rts

setToBitMapMode
    lda #$02 ; bank #1 index 0 $4000-$7FFF + $2000 = $6000, default is 3 which is bank #0
    sta $DD00
    lda #$3B
    sta $d011
    lda #$D8
    sta $d016
    lda $d018
    and #%00000001
    ora #%01111100
    sta $d018
    rts

backUpCurrentVideoSettings
lda $DD00
sta old_DD00
lda $d011
sta old_D011
lda $d016
sta old_d016
lda $d018
sta old_D018
rts

returnScreenBackFromSpash
lda old_DD00
sta $DD00
lda old_D011
sta $d011
lda old_d016
sta $d016
lda old_D018
sta $d018
rts

old_DD00    .byte $00
old_D011    .byte $00
old_d016    .byte $00
old_D018    .byte $00





msgOffset   .byte $00
msgLow .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $90, $28, $98, $28, $70, $a0, $48, $70, $38, $00, $08, $00, $80, $90, $28, $b0, $48, $28, $b8, $00, $78, $30, $00, $b8, $40, $08, $a0, $00, $48, $98, $00, $a0, $78, $00, $18, $78, $68, $28, $00, $60, $08, $a0, $28, $90, $00, $a0, $40, $48, $98, $00, $c8, $28, $08, $90, $70, $00, $a8, $98, $28, $00, $50, $78, $c8, $98, $a0, $48, $18, $58, $00, $90, $00, $a0, $78, $00, $80, $60, $08, $c8, $70, $00, $a0, $40, $28, $00, $38, $08, $68, $28, $00, $40, $08, $98, $00, $08, $00, $60, $78, $a0, $00, $78, $30, $00, $b8, $78, $90, $58, $00, $60, $28, $30, $a0, $60, $00, $10, $a8, $a0, $00, $48, $38, $68, $00, $28, $c0, $18, $48, $a0, $28, $20, $00, $a0, $78, $00, $98, $40, $08, $90, $28, $00, $18, $78, $68, $68, $28, $70, $a0, $98, $00, $18, $08, $70, $00, $38, $78, $00, $a0, $78, $00, $a0, $78, $70, $c8, $90, $a0, $80, $d0, $a0, $00, $38, $68, $08, $48, $60, $70, $18, $78, $68, $00, $28, $70, $50, $78, $c8, $00, $78, $a8, $90, $00, $30, $08, $b0, $78, $90, $48, $a0, $28, $00, $c0, $10, $48, $a0, $00, $80, $48, $60, $60, $00, $38, $08, $68, $28, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 0
msgHigh .byte $91, $91, $91, $91, $91, $91, $91, $91, $91, $91, $91, $91, $91, $91, $91, $91, $91, $91, $91, $90, $90, $90, $90, $90, $90, $90, $90, $90, $90, $91, $90, $91, $90, $90, $90, $90, $90, $90, $90, $91, $90, $90, $91, $90, $90, $90, $90, $91, $90, $90, $91, $90, $90, $91, $90, $90, $90, $90, $91, $90, $90, $90, $90, $90, $91, $90, $90, $90, $90, $91, $90, $90, $90, $90, $91, $91, $90, $90, $90, $91, $90, $90, $90, $90, $90, $90, $90, $90, $91, $91, $91, $90, $90, $91, $90, $90, $90, $90, $91, $91, $90, $90, $90, $91, $90, $90, $90, $90, $91, $90, $90, $90, $91, $90, $91, $90, $90, $90, $91, $90, $90, $91, $90, $90, $90, $90, $91, $90, $90, $90, $90, $91, $91, $90, $90, $90, $91, $90, $91, $90, $91, $90, $90, $90, $90, $90, $90, $90, $91, $90, $90, $91, $90, $90, $90, $90, $90, $91, $90, $90, $90, $90, $90, $90, $90, $90, $91, $90, $90, $90, $91, $90, $90, $91, $90, $90, $91, $90, $90, $90, $90, $91, $91, $91, $90, $90, $90, $90, $90, $90, $90, $90, $91, $90, $90, $90, $91, $90, $90, $90, $90, $90, $91, $90, $90, $90, $91, $90, $90, $90, $90, $90, $90, $90, $90, $91, $91, $90, $90, $90, $91, $90, $90, $90, $90, $91, $90, $90, $90, $90, $91, $91, $91, $91, $91, $91, $91, $91, $91, $91, $91, $91, $91, $91, $91, $91, $91, $91, $91, $91, $91, $91, $91, 0

