VIC_MEM         .equ 53248
SPRITE_LOC_X    .equ 150
SPRITE_LOC_Y    .equ 229
SPRITE_MEM1_LOC .equ $3000

.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00

init
    jsr moveSpriteMemory
    lda #$C0 ; $3000/$40 =  $C0
    sta $07f8 ; Sprite 1 pointer
    sta $07f9 ; Sprite 2 pointer
    sta $07fA ; Sprite 3 pointer
    sta $07fB ; Sprite 4 pointer
    sta $07fC ; Sprite 3 pointer
    sta $07fD ; Sprite 4 pointer
    sta $07fE ; Sprite 3 pointer
    sta $07fF ; Sprite 4 pointer

jsr setupIrqs


    ; enable Sprites
    lda #$ff
    sta $d015
    ; set color
    lda #1
    sta VIC_MEM+39
    sta VIC_MEM+40
    sta VIC_MEM+41
    sta VIC_MEM+42
    sta VIC_MEM+43
    sta VIC_MEM+44
    sta VIC_MEM+45
    sta VIC_MEM+46



    lda s1x ; location
    sta $d000
    lda s2x
    sta $d002 ; Set x for sprite 2
    lda s3x
    sta $d004 ; Set x for sprite 3
    lda s4x
    sta $d006 ; Set x for sprite 4

    lda s5x
    sta $d008 ; Set x for sprite 3
    lda s6x
    sta $d00a ; Set x for sprite 4
lda s7x
sta $d00c ; sprite 5 x
lda s8x
sta $d00e ; sprite 6 x



    jmp spriteAnimate
rts

spriteAnimate
    ldx #42
sa_loop
    lda path, x
    sta $d001
    lda path2, x
    sta $d003

    lda path, x
    sta $d005
    lda path2, x
    sta $d007

    lda path, x
    sta $d009
    lda path2, x
    sta $d00B

    lda path, x
    sta $d00D
    lda path2, x
    sta $d00F




    inc s1x
    inc s1x
    inc s1x

    inc s2x
    inc s2x
    inc s2x

    inc s3x
    inc s3x
    inc s3x

    inc s4x
    inc s4x
    inc s4x

    inc s5x
    inc s5x
    inc s5x

    inc s6x
    inc s6x
    inc s6x

inc s7x
inc s7x
inc s7x

inc s8x
inc s8x
inc s8x



    lda s1x
    sta $d000 ; sprite 1 x
    lda s2x
    sta $d002 ; sprite 2 x
    lda s3x
    sta $d004 ; sprite 3 x
    lda s4x
    sta $d006 ; sprite 4 x
    lda s5x
    sta $d008 ; sprite 5 x
    lda s6x
    sta $d00a ; sprite 6 x
    lda s7x
    sta $d00c ; sprite 5 x
    lda s8x
    sta $d00e ; sprite 6 x




;jsr WaitFrame
;jsr WaitFrame
;jsr WaitFrame


    dex
    beq sa_done
    jmp sa_loop
sa_done
;jmp spriteAnimate
    rts


s1x .byte 0
s2x .byte 20

s3x .byte 63
s4x .byte 83

s5x .byte 126
s6x .byte 146

s7x .byte 189
s8x .byte 209




moveSpriteMemory
    ; 63 bytes
    ldx #63
msm_loop
    lda CUST_SPRITE_0, x
    sta SPRITE_MEM1_LOC, x
    dex
    bne msm_loop
    rts

WaitFrame
    lda $d012
    cmp #0
    beq WaitFrame
    ;wait for the raster to reach line $f8 (should be closer to the start of this line this way)
WaitStep2
    lda $d012
    cmp #0
    bne WaitStep2
Return
    rts

; 21
;path .byte 108, 111, 114, 118, 122, 126, 131, 135, 140, 145, 150, 155, 160, 165, 169, 174, 178, 182, 186, 189, 192
; 43
path    .byte 30, 30, 29, 29, 28, 26, 25, 23, 21, 19, 16, 16, 19, 21, 23, 25, 26, 28, 29, 29, 30, 30, 30, 29, 29, 28, 26, 25, 23, 21, 19, 16, 16, 19, 21, 23, 25, 26, 28, 29, 29, 30, 30
path2   .byte 16, 19, 21, 23, 25, 26, 28, 29, 29, 30, 30, 30, 29, 29, 28, 26, 25, 23, 21, 19, 16, 16, 19, 21, 23, 25, 26, 28, 29, 29, 30, 30, 30, 30, 29, 29, 28, 26, 25, 23, 21, 19, 16

setupIrqs
sei
;    lda #$02
;    sta $d020
;    lda #$00
;    sta $d021
lda #<irq1
sta $314
lda #>irq1
sta $315
lda #$7f
sta $dc0d
lda #$1b
sta $d011
lda #$01
sta $d01a
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
inc doWeMove
bne noNow
jsr spriteAnimate
noNow
jmp $ea31 ; return to standard irq

irq2
inc $d019
lda #$fa ; 250
sta $d012
lda #$1b ;If you want to display a bitmap pic, use #$3b instead
sta $d011
lda #<irq1
sta $314
lda #>irq1
sta $315
jmp $ea31 ; return to standard irq

doWeMove    .byte $00




; tools/bitmapReader -f outbreak_assets/ball24x21.raw -w 24 -h 21 -s
CUST_SPRITE_0
    .byte 1, 252, 0
    .byte 7, 255, 0
    .byte 15, 255, 128
    .byte 31, 255, 192
    .byte 63, 255, 224
    .byte 127, 255, 240
    .byte 127, 255, 240
    .byte 255, 255, 248
    .byte 255, 255, 248
    .byte 255, 255, 248
    .byte 255, 255, 248
    .byte 255, 255, 248
    .byte 255, 255, 248
    .byte 255, 255, 248
    .byte 127, 255, 240
    .byte 127, 255, 240
    .byte 63, 255, 224
    .byte 31, 255, 192
    .byte 15, 255, 128
    .byte 7, 255, 0
    .byte 1, 252, 0