
; This opens the top and bottom borders
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
