;define constants here
VIC_MEM         .equ 53248
SCREEN_BOARDER  .equ VIC_MEM + 32
SCREEN_BG_COLOR .equ VIC_MEM + 33
SCREEN_CHAR     .equ 52224
COLOR_BLACK     .equ $00
COLOR_WHITE     .equ $01
COLOR_RED       .equ $02
COLOR_CYAN      .equ $03
COLOR_MAGENTA   .equ $04
COLOR_GREEN     .equ $05
COLOR_BLUE      .equ $06
COLOR_YELLOW    .equ $07
COLOR_ORANGE    .equ $08
COLOR_BROWN     .equ $09
COLOR_PINK      .equ $0a
COLOR_DARK_GREY .equ $0b
COLOR_GREY      .equ $0c
COLOR_L_GREEN   .equ $0d
COLOR_L_BLUE    .equ $0e
COLOR_L_GREY    .equ $0f

.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,$20,$32,$30,$36,$34,$00,$00,$00,$00,$00

ldx #COLOR_PINK

GameLoop
stx SCREEN_BOARDER
stx SCREEN_BG_COLOR
inx
jmp GameLoop

brk

;init sprite registers
;no visible sprites
lda #0
sta VIC_MEM + 21

;set charset
lda #$3c
sta 53272

;VIC bank
lda 56576
and #$fc
sta 56576
;jmp SwitchToHighRes

;the main game loop
GameLoop  
;border flashing
lda #COLOR_YELLOW
sta SCREEN_BG_COLOR
sta SCREEN_BOARDER

;top left char
;inc SCREEN_CHAR
jsr WaitFrame
;jsr WaitFrame2
jmp GameLoop

WaitFrame 
lda $d012
cmp #$F8
beq WaitFrame

;wait for the raster to reach line $f8 (should be closer to the start of this line this way)
WaitStep2
lda $d012
cmp #$F8
bne WaitStep2
rts




WaitFrame2
;inc SCREEN_BOARDER
lda $d012
cmp #$10
beq WaitFrame2
WaitStep3
lda $d012
cmp #$10
bne WaitStep3
ldx #COLOR_CYAN
stx SCREEN_BOARDER
stx SCREEN_BG_COLOR

rts

