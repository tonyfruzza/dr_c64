
;SPRITE1_DATA    .equ $0240
;SPRITE2_DATA    .equ $0280
;SPRITE3_DATA    .equ $02C0

SPRITE4_DATA    .equ $3000 ; Center left overlay
SPRITE5_DATA    .equ $3040 ; Center right overlay

copySpriteDataIntoUseableLocation
; leftTopSprite = starting address of sprite for top left
; $D018 = 00011101
; screen mem $400, $sprite pointer $7f8, charmem = $3000
; need 63bytes free for sprite
; $200 used by basic for storing stuff, not using basic, so could be okay? this is pointer offset of 8
    ldx #0
csdiul_loop
    lda leftTopSprite,x
    sta SPRITE1_DATA,x
    lda rightTopSprite,x
    sta SPRITE2_DATA,x
    lda centerLeftTopSprite,x
    sta SPRITE4_DATA,x
    lda centerRightTopSprite,x
    sta SPRITE5_DATA,x
    inx
    cpx #62
    bne csdiul_loop
    rts

displayTopSprite
    jsr copySpriteDataIntoUseableLocation
    lda #9 ; $3000/$40 =  $C0
    sta SPRITE1_POINT ; Sprite 1 pointer
    lda #10
    sta SPRITE2_POINT ; Sprite 2 pointer
    lda #11
    sta SPRITE1_POINT+2 ; Sprite 3 pointer used for score
    lda #192
    sta SPRITE1_POINT+3 ;
    lda #193
    sta SPRITE1_POINT+4 ;

    lda #%00011000 ; Set sprite 4 behind
    sta $D01B

    lda $d015 ; See what sprites are enabled
    ora #%00011111
    sta $d015 ; enable sprite 1 & 2
    lda #COLOR_MAGENTA
    sta VMEM+39 ; set color
    sta VMEM+40
    lda #COLOR_BROWN
    sta VMEM+42 ; Top center left
    lda #COLOR_ORANGE
    sta VMEM+43 ; Top center right
    lda #152
    sta $d000 ; x pos
    lda #69
    sta $d001 ; y pos sprite 1
    sta $d003 ; y pos sprite 2
    sta $d007 ; y pos sprite 4
    sta $d009 ; y pos sprite 5
    lda #168
    sta $d006 ; x pos sprite 4
    lda #192
    sta $d008 ; x pos sprite 5
    sta $d002 ; x pos sprite 2
    rts
