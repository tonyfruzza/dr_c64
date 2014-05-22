; Draw their talking room
BLOCK_TL    .equ 139
BLOCK_TR    .equ 140
BLOCK_BL    .equ 141
BLOCK_BR    .equ 142

CHAR1_DLG_X_POS .equ 255
CHAR1_DLG_Y_POS .equ 100
CHAR2_DLG_X_POS .equ 80
CHAR2_DLG_Y_POS .equ 200

SpritePackStartingFromDialog    .equ $a500 ; $a000 + (64 * 20)
SpritePackStartingForFirstDude  .equ $a640 ; $a000 + (64 * 25)

SPRITE_WORKING_RAM  .equ $3000

copySpriteDataInForDialog
    cli
    lda $01
    and #%11111101 ; I/O enabled, ram visible in both basic and kernel
    ; This is $15
    sta $01

    ldx #0
csdifd_loop
    ; Main Dialog dude starts at sprite 20 inwards of $a000 which should be 64*20+$a000 = $a500
    lda SpritePackStartingFromDialog,x
    sta SPRITE_WORKING_RAM,x
    lda SpritePackStartingFromDialog+$100,x
    sta SPRITE_WORKING_RAM+$100,x
    lda SpritePackStartingFromDialog+$200,x
    sta SPRITE_WORKING_RAM+$200,x ; Okay more than the first 5 (only needed $0140 bytes) we've filled up $32ff now

;    lda SpritePackBase+$300,x
;    sta SpritePackStartingForFirstDude+$300,x
;    lda SpritePackBase+$400,x
;    sta SpritePackStartingForFirstDude+$400,x

    inx
    bne csdifd_loop
    rts

initSpritesForDialog ; Using sprites 1&2 for main dude, 3&4 for other char
    jsr copySpriteDataInForDialog
    ; Configure location
    lda #CHAR1_DLG_X_POS
    sta SPRITE1_X_POS
    sta SPRITE2_X_POS
    lda #CHAR1_DLG_Y_POS
    sta SPRITE1_Y_POS
    sta SPRITE2_Y_POS
    ; Configure pointers
    lda #193 ; Memory location $3000
    sta SPRITE1_POINT
    lda #192 ; Memory location $3000
    sta SPRITE2_POINT

    ; Multi color-ness
    lda #%00000010
;    sta $D01C
;    lda #COLOR_L_GREY
;    sta $d025 ; Multi color #1
;    lda #COLOR_WHITE
;    sta $d026 ; Multi color #2

;    lda #COLOR_DARK_GREY
;    sta SPRITE1_COLOR
;    lda #COLOR_PINK
;    sta SPRITE2_COLOR

    lda #%00001111 ; enable sprites
    sta $d015
    rts

draw2x2BlockToZpPtr1 ; Do not disturb x
    lda zpPtr1
    sta zpPtr2
    clc
    lda #$D4
    adc zpPtr1+1
    sta zpPtr2+1
    ldy #0
    lda #BLOCK_TL
    sta (zpPtr1),y
    lda paintBoxesColor
    sta (zpPtr2),y
    iny
    lda #BLOCK_TR
    sta (zpPtr1),y
    lda paintBoxesColor
    sta (zpPtr2),y
    ldy #40
    lda #BLOCK_BL
    sta (zpPtr1),y
    lda paintBoxesColor
    sta (zpPtr2),y
    iny
    lda #BLOCK_BR
    sta (zpPtr1),y
    lda paintBoxesColor
    sta (zpPtr2),y
    rts


clearChatRoom
    lda #CLEAR_CHAR
    sta clearingChar
    jsr ClearScreen
    jsr drawScreenFrame
    ldx #0
    rts

drawThoseBoxes
    ldx #0
dtb_loop
    lda topLeftBoxLocationsLow, x
    beq dtb_done
    sta zpPtr1
dcr_loadHighBytes
    lda topLeftBoxLocationsHigh, x
    sta zpPtr1+1
    jsr draw2x2BlockToZpPtr1
    inx
    jmp dtb_loop
dtb_done
    rts

waitForInput
    jsr getFireButtonPressed
    beq waitForInput
    rts

doTheChatRoom
    jsr clearChatRoom
    lda #COLOR_MAGENTA
    sta paintBoxesColor
    ; A little self modifying stuff here
    lda #<topLeftBoxLocationsLow
    sta dtb_loop+1
    lda #>topLeftBoxLocationsLow
    sta dtb_loop+2

    lda #<topLeftBoxLocationsHigh
    sta dcr_loadHighBytes+1
    lda #>topLeftBoxLocationsHigh
    sta dcr_loadHighBytes+2
    jsr drawThoseBoxes

    ; And the bottom right area
    lda #COLOR_ORANGE
    sta paintBoxesColor
    lda #<bottomRightBoxLocationLow
    sta dtb_loop+1
    lda #>bottomRightBoxLocationLow
    sta dtb_loop+2

    lda #<bottomRightBoxLocationHigh
    sta dcr_loadHighBytes+1
    lda #>bottomRightBoxLocationHigh
    sta dcr_loadHighBytes+2
    jsr drawThoseBoxes

    jsr initSpritesForDialog

    jsr waitForInput
    rts

paintBoxesColor             .byte 0

topLeftBoxLocationsLow      .byte $52, $54, $56, $58, $5a, $5c, $60, $a2, $a4, $a6, $a8, $f2, $f4, $42, $92, $32, 0
topLeftBoxLocationsHigh     .byte $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $05, $05, $06, 0
bottomRightBoxLocationLow   .byte $6c, $6a, $68, $66, $64, $62, $5e, $1c, $1a, $18, $16, $cc, $ca, $7c, $2c, $8c, 0
bottomRightBoxLocationHigh  .byte $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $06, $06, $06, $06, $05, 0
