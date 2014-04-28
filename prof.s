; Sample ASM Sprite Program
.org $0801
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00
; Line 20 constant variable V
V               .equ 53248
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
;JOY         .equ 56321 ; Joystick flag byte
JOY         .equ 56320 ; Joy 2


init
;    lda #147 ; clear screen char
;    jsr $FFD2 ; CHROUT kernel routine
    lda #%00000111
    sta V+21 ; Enable first 6 sprites
    lda #193 ; Set Sprite pointer
    sta $7f8 ; For sprite 1 (outline)
    lda #192
    sta $7f9 ; For sprite2 (coloring)
    lda #194
    sta $7fa ; For sprite2 (feet)
    ; Diana Sprite
    lda #198 ; body outline
    sta $7fb
    lda #197 ; Body color
    sta $7fc
    lda #199
    sta $7fd ; Diana's feet


    ; Colors
    ; Set Second sprite to be multi color, and sprite
    lda #%00010010
    sta V+28
    lda #COLOR_WHITE
    sta V+37 ; first shared sprite color
    lda #COLOR_PINK
    sta V+38 ; Second shared sprite color
    lda #COLOR_BROWN
    sta V+40 ; Sprite 2
    lda #COLOR_BLACK
    sta V+39 ; Sprite 1 Color
    sta V+41 ; Sprite 3
    sta V+42 ; Sprite 4
    sta V+44 ; Sprite 6 shoes
    lda #COLOR_MAGENTA
    sta V+43 ; Sprite 5 Diana body


    ldx #50
    stx SPRITE1_X
    stx V+0
    stx V+2
    stx V+4
    lda #224
    sta SPRITE1_Y
    sta V+1
    sta V+3
    lda #245
    sta V+5
; Diana Sprite

lda #100
sta V+6
sta V+8
sta V+10
lda #226
sta V+7
sta V+9
lda #247
sta V+11


aniLoop
;    jsr updateJoyPos
    lda JOY
    and #8
    beq gotAMove
    jsr FaceFoward
    jmp aniLoop
gotAMove
    jsr swapAnimationLoop
    jmp aniLoop
rts

moveProfRight
    inc V+0
    inc V+2
    inc V+4
    rts

swapAnimationLoop
    lda AniStep
    bne notFirstStep
    lda #201 ; Set Sprite pointer
    sta $7f8 ; For sprite 1 (outline)
    lda #200
    sta $7f9 ; For sprite2 (coloring)
    lda #202
    sta $7fa ; For sprite2 (feet)
    ;jsr waitTime
    jsr waitTimeWithoutWalk
    inc AniStep
    rts
notFirstStep
    lda #198 ; Set Sprite pointer
    sta $7f8 ; For sprite 1 (outline)
    lda #197
    sta $7f9 ; For sprite2 (coloring)
    lda #199
    sta $7fa ; For sprite2 (feet)

    jsr waitTime
    lda #0
    sta AniStep
    rts


FaceFoward
    lda #193 ; Set Sprite pointer
    sta $7f8 ; For sprite 1 (outline)
    lda #192
    sta $7f9 ; For sprite2 (coloring)
    lda #194
    sta $7fa ; For sprite2 (feet)
    rts

waitTime
    jsr WaitFrame
    jsr WaitFrame
jsr moveProfRight
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
jsr moveProfRight
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
jsr moveProfRight
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
;jsr profMoveRight
rts

waitTimeWithoutWalk
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
    jsr moveProfRight
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame

rts

profMoveRight
    inc V+0
    inc V+2
    inc V+4
    rts


; subrutines below here.....

updateJoyPos
    ldx JOY
    txa
    and #8
    rts

WaitFrame
    lda $d012
    cmp #0
    beq WaitFrame
    ;wait for the raster to reach line $f8 (should be closer to the start of this line this way)
WaitStep2   lda $d012
    cmp #0
    bne WaitStep2
    rts

SPRITE1_X   .byte $00
SPRITE1_Y   .byte $00
AniStep     .byte $00