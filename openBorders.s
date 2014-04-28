;Opening the top + bottom borders
;inside an IRQ interrupt player

.org $0801
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00
SPRITE_LOC      .equ 50
SPRITE_LOC_Y    .equ 0
VIC_MEM         .equ 53248


init
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
;rts
showSprite
lda #$C0 ; $3000/$40 =  $C0
sta $07f8

lda #$ff
sta $3000

; Set color to white
lda #1
sta VIC_MEM+39

; Sprite 0 Location
lda #SPRITE_LOC
ldx #SPRITE_LOC_Y
sta $d000
stx $d001

; Enable Sprite 0
lda #$01
sta $d015

;loop
;    jmp loop
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
    lda #$1b ;If you want to display a bitmap pic, use #$3b instead
    sta $d011
    lda #<irq1
    sta $314
    lda #>irq1
    sta $315
    jmp $ea31 ; return to standard irq

