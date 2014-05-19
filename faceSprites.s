
SpritePackBase  .equ $a000
SPRITE6_DATA    .equ $3080
SPRITE7_DATA    .equ $30C0

; Copy data in

; Configure colors for shared, set pos

copySpriteDataInForPlayerHead
    cli
    lda $01
    and #%11111101 ; I/O enabled, ram visible in both basic and kernel
    ; This is $15
    sta $01

    ldx #0
csdifph_loop

;    lda SpritePackBase+64,x
;    sta SPRITE6_DATA,x

;    lda SpritePackBase,x
;    sta SPRITE7_DATA,x
; Copy in 8 * 256 = 2k
    lda SpritePackBase,x
    sta SPRITE6_DATA,x
    lda SpritePackBase+$100,x
    sta SPRITE6_DATA+$100,x
    lda SpritePackBase+$200,x
    sta SPRITE6_DATA+$200,x
    lda SpritePackBase+$300,x
    sta SPRITE6_DATA+$300,x
    lda SpritePackBase+$400,x
    sta SPRITE6_DATA+$400,x
    lda SpritePackBase+$500,x
    sta SPRITE6_DATA+$500,x
    lda SpritePackBase+$600,x
    sta SPRITE6_DATA+$600,x ; This should be enough for 28 sprites
;    lda SpritePackBase+$700,x
;    sta SPRITE6_DATA+$700,x
    inx
    bne csdifph_loop
    rts


enableFaceSprite
    lda #195
    sta SPRITE6_POINT
    lda #194
    sta SPRITE7_POINT

    lda $d015 ; See what sprites are enabled
    ora #%01100000
    sta $d015

    ; Main char sprite is over 256 x
    lda #%01100000
    sta $d010

    lda #COLOR_DARK_GREY
    sta VMEM+44
    lda #COLOR_PINK
    sta VMEM+45

    lda #3
    sta $d00a ; x pos sprite 6
    sta $d00c
    lda #203
    sta $d00b ; y pos sprite 6
    sta $d00d

    ; Multi color-ness
    lda #%01000000
    sta $D01C
    lda #COLOR_L_GREY
    sta $d025 ; Multi color #1
    lda #COLOR_WHITE
    sta $d026 ; Multi color #2
    rts
