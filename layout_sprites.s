

SPRITE1_DATA    .equ $0240
SPRITE2_DATA    .equ $0280
SPRITE3_DATA    .equ $02C0

SPRITE1_POINT   .equ $07f8
SPRITE2_POINT   .equ $07f9
; VIC is using memory bank #0 so VIC sees $0000-$3FFF

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

;    lda scorePopUp,x ; We dynamically build this now
;    sta SPRITE3_DATA,x

    inx
    cpx #62
    bne csdiul_loop
    rts

displayTopSprite
    jsr copySpriteDataIntoUseableLocation
    lda #9 ; $3000/$40 =  $C0
    sta SPRITE1_POINT ; Sprite 1 pointer
    lda #10
    sta SPRITE2_POINT
    lda #11
    sta SPRITE1_POINT+2

    lda $d015 ; See what sprites are enabled
    ora #3
    sta $d015 ; enable sprite 1 & 2
    lda #1
    sta VMEM+39 ; set color
    sta VMEM+40
    sta VMEM+41
    lda #152
    sta $d000 ; x pos
    lda #69
    sta $d001 ; y pos sprite 1
    sta $d003 ; y pos sprite 2
    lda #192
    sta $d002 ; x pos sprite 2
    rts

hideTopSprites
    lda $d015
    and #%11111100
    sta $d015 ; enable sprite 1 & 2
    rts