; Sample ASM Sprite Program
.org $0801
; Plug into BASIC 10 SYS2064 so .prg will execute
; when RUN
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00
; Line 20 constant variable V
V	.equ 53248
start
    ; Line 22 print character 147 to screen
    lda #147 ; clear screen char
    jsr $FFD2 ; CHROUT kernel routine
    ; Line 22 set V+21 to 0
    lda #0
    sta V+21
    ; Line 25 set 53280 (screen border) to 5 (GREEN)
    lda #5
    sta 53280
    ; Line 25 set 53281 (screen) to 1 (WHITE)
    lda #1
    sta 53281
    ; line 30 put 192 into 2040 (setting sprite pointer)
    lda #192
    sta 2040

    ; line 50, 70
    ldx #0
spriteCopyLoop
    lda BUTTERFLY, x
    sta $3000, x ; This is where the sprite data is located based on the pointer (192 * 64)
    inx
    cpx #63
    bne spriteCopyLoop

    ; line 75
    lda #7
    sta V+39 ; set sprite to color Yellow
    ; line 80
    lda #1
    sta V+23
    sta V+29 ; Register A is still set to 1
    ; line 88 init x, y values
    ldx #50
    stx SPRITE1_X
    lda #24
    sta SPRITE1_Y
    ; Line 95 enable Sprite
    lda #1
    sta V+21
    ; Line 90 set sprite position
moveSpriteLoop
    lda SPRITE1_X
    sta V+0
    lda SPRITE1_Y
    sta V+1
    ; Line 95 increment x and y
    inc SPRITE1_X
    inc SPRITE1_Y
    ; Line 110 if Y is 255 then set X and Y to 1 else go to MoveSpriteLoop (Line 90)
    lda SPRITE1_Y
    bne moveSpriteLoop
    ; Line 110 condition is true
    lda #1
    sta SPRITE1_X
    sta SPRITE1_Y
ldy #0
loop2
ldx #0
loop1
inx
bne loop1
iny
bne loop2

    jmp moveSpriteLoop

SPRITE1_X	.byte $00
SPRITE1_Y	.byte $00
BUTTERFLY	.byte 2,0,64,49,0,140,120,129,30,252,66,63,254,36,127,255,24,255,255,153,255,255,219,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,219,255,127,153,254,63,24,252,30,24,120,12,24,48

