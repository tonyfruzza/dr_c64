.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00

SCREEN_LOC  .equ $0400
VMEM        .equ $D000
SCREEN_C    .equ $0400
NEW_CHARMEM .equ $2000
VIC_MEM         .equ 53248
SCREEN_BOARDER  .equ VIC_MEM + 32
SCREEN_BG0      .equ VIC_MEM + 33
SCREEN_BG1      .equ VIC_MEM + 34
SCREEN_BG2      .equ VIC_MEM + 35
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

    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame

    jsr configureScreen
    lda #2
    sta looped
scrollOuterOuterLoop
    lda #00
    sta offset
    lda #34
    sta times
scrollOuterLoop
    ldx #38
    ldy #0
scroll
    ; Copy character from left to right
    lda SCREEN_LOC+1, y
    sta SCREEN_LOC+0, y

    lda SCREEN_LOC+41,y
    sta SCREEN_LOC+40,y

    lda SCREEN_LOC+81,y
    sta SCREEN_LOC+80,y

    lda SCREEN_LOC+121,y
    sta SCREEN_LOC+120,y

    lda SCREEN_LOC+161,y
    sta SCREEN_LOC+160,y

    lda SCREEN_LOC+201,y
    sta SCREEN_LOC+200,y

    lda SCREEN_LOC+241,y
    sta SCREEN_LOC+240,y

    lda SCREEN_LOC+281,y
    sta SCREEN_LOC+280,y



    iny
    dex ; 38 times only
    bpl scroll ; While positive copy a character to the left
    ; Pause between
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame
    jsr WaitFrame

    ; Add new character in
    lda offset
    and #1
    beq useEvenChar
    ; Odd char
    lda #67 ; -
    jmp useChar
useEvenChar
    lda #31 ; <
useChar

;    ldy offset
;    lda newchar, y
    sta SCREEN_LOC+39 ; (8 + 39)
    sta SCREEN_LOC+79 ; (40 + 39)
    sta SCREEN_LOC+119 ; (80 + 39)
    sta SCREEN_LOC+159 ; (120 + 39)
    inc offset
    dec times
    bne scrollOuterLoop

    dec looped
    bne scrollOuterOuterLoop

    rts

offset  .byte $00
newchar .byte 17, 21, 9, 20, 32, 32, 32, 32, 32, 32, 18, 5, 20, 21, 18, 14, 32, 32, 32, 32, 32, 32, 32
        .byte 18, 5, 19, 20, 1, 18, 20, 32, 32, 32, 32
dnaTop  .byte 

times   .byte 40
looped  .byte 0

printHelix
    ldx #0 ; 0 - 9
ph_loop
    txa
    sta SCREEN_LOC+0, x
    sta SCREEN_LOC+10, x
    sta SCREEN_LOC+20, x
    sta SCREEN_LOC+30, x
    inx
    cpx #10
    bne ph_loop
    ldy #0
ph_loop2 ; 10 - 19
    txa
    sta SCREEN_LOC+40, y
    sta SCREEN_LOC+50, y
    sta SCREEN_LOC+60, y
    sta SCREEN_LOC+70, y
    iny
    inx
    cpx #20
    bne ph_loop2
    ldy #0
ph_loop3 ; 20 - 29
    txa
    sta SCREEN_LOC+80, y
    sta SCREEN_LOC+90, y
    sta SCREEN_LOC+100, y
    sta SCREEN_LOC+110, y
    iny
    inx
    cpx #30
    bne ph_loop3

    ldy #0
ph_loop4 ; 30 - 39
    txa
    sta SCREEN_LOC+120, y
    sta SCREEN_LOC+130, y
    sta SCREEN_LOC+140, y
    sta SCREEN_LOC+150, y
    iny
    inx
    cpx #40
    bne ph_loop4

    ldy #0
ph_loop5 ; 40 - 59
    txa
    sta SCREEN_LOC+160, y
    sta SCREEN_LOC+170, y
    sta SCREEN_LOC+180, y
    sta SCREEN_LOC+190, y
    iny
    inx
    cpx #50
    bne ph_loop5

    ldy #0
ph_loop6 ; 60 - 69
    txa
    sta SCREEN_LOC+200, y
    sta SCREEN_LOC+210, y
    sta SCREEN_LOC+220, y
    sta SCREEN_LOC+230, y
    iny
    inx
    cpx #60
    bne ph_loop6

    ldy #0
ph_loop7 ; 60 - 69
    txa
    sta SCREEN_LOC+240, y
    sta SCREEN_LOC+250, y
    sta SCREEN_LOC+260, y
    sta SCREEN_LOC+270, y
    iny
    inx
    cpx #70
    bne ph_loop7

    ldy #0
ph_loop8 ; 70 - 79
    txa
    sta SCREEN_LOC+280, y
    sta SCREEN_LOC+290, y
    sta SCREEN_LOC+300, y
    sta SCREEN_LOC+310, y
    iny
    inx
    cpx #80
    bne ph_loop8
rts



WaitFrame
    lda $d012
    cmp #0
    beq WaitFrame
    ;wait for the raster to reach line $f8 (should be closer to the start of this line this way)
WaitStep2   lda $d012
    cmp #0
    bne WaitStep2
Return
    rts

configureScreen
jsr copyCustomCharSetIn
    lda #%11011000 ; multicolor mode
    sta $d016
    lda #%00011000
    sta $D018 ; set Char mem location to $2000 for custom char set
    lda #COLOR_BLACK
    sta SCREEN_BG0
    lda #COLOR_WHITE
    sta SCREEN_BG2
    lda #COLOR_GREY
    sta SCREEN_BG1
jsr printHelix
    rts

; 640 bytes
copyCustomCharSetIn
    ldx #0
cccsi_loop ; first 512bytes
    lda DNA, x
    sta NEW_CHARMEM, x
    lda DNA + $100, x
    sta NEW_CHARMEM + $100, x
    lda DNA + $200, x
    sta NEW_CHARMEM + $200, x
    inx
    bne cccsi_loop
rts



; tools/bitmapReader -t DNA -cf outbreak_assets/dna.raw -w 40 -h 64 -m 0,1,3
DNA .byte 170, 170, 170, 10, 80, 85, 85, 85
DNA_1 .byte 170, 170, 170, 170, 170, 10, 66, 80
DNA_2 .byte 170, 170, 170, 170, 170, 170, 170, 170
DNA_3 .byte 170, 170, 170, 170, 170, 168, 168, 168
DNA_4 .byte 170, 170, 170, 168, 3, 61, 245, 247
DNA_5 .byte 170, 170, 170, 2, 252, 127, 255, 255
DNA_6 .byte 170, 170, 170, 170, 42, 202, 202, 242
DNA_7 .byte 170, 170, 170, 170, 170, 170, 170, 170
DNA_8 .byte 170, 170, 170, 170, 170, 168, 161, 133
DNA_9 .byte 170, 170, 170, 128, 21, 93, 125, 245
DNA_10 .byte 85, 5, 161, 160, 168, 168, 170, 170
DNA_11 .byte 84, 84, 85, 85, 85, 21, 21, 21
DNA_12 .byte 170, 42, 42, 42, 10, 74, 66, 82
DNA_13 .byte 160, 163, 131, 143, 143, 143, 143, 15
DNA_14 .byte 255, 255, 252, 240, 194, 202, 202, 202
DNA_15 .byte 255, 255, 3, 163, 168, 168, 170, 170
DNA_16 .byte 242, 252, 252, 255, 255, 255, 63, 63
DNA_17 .byte 170, 170, 42, 42, 42, 10, 202, 194
DNA_18 .byte 133, 133, 133, 5, 21, 21, 21, 21
DNA_19 .byte 85, 84, 80, 82, 82, 74, 74, 74
DNA_20 .byte 170, 170, 170, 170, 170, 170, 170, 170
DNA_21 .byte 5, 133, 133, 129, 161, 161, 161, 168
DNA_22 .byte 82, 80, 84, 84, 84, 85, 85, 85
DNA_23 .byte 63, 63, 63, 255, 63, 63, 60, 60
DNA_24 .byte 202, 10, 42, 42, 42, 42, 170, 170
DNA_25 .byte 170, 170, 170, 170, 170, 170, 170, 170
DNA_26 .byte 143, 143, 131, 163, 163, 163, 163, 168
DNA_27 .byte 240, 240, 252, 252, 252, 252, 252, 252
DNA_28 .byte 85, 85, 85, 85, 85, 85, 85, 20
DNA_29 .byte 10, 42, 42, 42, 42, 42, 42, 170
DNA_30 .byte 170, 170, 170, 170, 170, 170, 170, 170
DNA_31 .byte 168, 168, 170, 170, 170, 170, 170, 170
DNA_32 .byte 85, 21, 21, 21, 21, 21, 5, 5
DNA_33 .byte 60, 12, 76, 76, 76, 80, 82, 82
DNA_34 .byte 170, 170, 170, 170, 170, 170, 170, 170
DNA_35 .byte 170, 170, 170, 170, 170, 170, 170, 170
DNA_36 .byte 168, 168, 168, 168, 168, 168, 168, 168
DNA_37 .byte 255, 255, 255, 255, 255, 63, 63, 79
DNA_38 .byte 20, 20, 20, 4, 192, 194, 202, 194
DNA_39 .byte 170, 170, 170, 170, 170, 170, 170, 170
DNA_40 .byte 170, 170, 170, 170, 170, 170, 170, 170
DNA_41 .byte 168, 168, 168, 168, 163, 163, 163, 163
DNA_42 .byte 197, 197, 193, 241, 241, 241, 252, 252
DNA_43 .byte 80, 84, 84, 84, 85, 85, 85, 85
DNA_44 .byte 170, 170, 170, 42, 42, 42, 42, 42
DNA_45 .byte 170, 170, 170, 170, 170, 170, 170, 170
DNA_46 .byte 168, 168, 161, 161, 161, 161, 161, 129
DNA_47 .byte 79, 79, 67, 83, 83, 83, 83, 83
DNA_48 .byte 242, 242, 242, 242, 252, 252, 252, 252
DNA_49 .byte 170, 170, 170, 170, 170, 170, 170, 170
DNA_50 .byte 170, 170, 170, 170, 170, 170, 170, 170
DNA_51 .byte 143, 143, 143, 143, 15, 63, 63, 63
DNA_52 .byte 240, 240, 240, 242, 202, 202, 10, 42
DNA_53 .byte 85, 85, 21, 21, 21, 21, 21, 21
DNA_54 .byte 42, 42, 10, 74, 74, 74, 74, 66
DNA_55 .byte 170, 170, 170, 170, 170, 170, 168, 168
DNA_56 .byte 133, 133, 5, 21, 21, 21, 21, 84
DNA_57 .byte 83, 80, 64, 72, 8, 42, 42, 42
DNA_58 .byte 252, 255, 255, 255, 63, 63, 63, 63
DNA_59 .byte 42, 42, 42, 10, 202, 202, 202, 194
DNA_60 .byte 170, 168, 160, 131, 15, 255, 255, 255
DNA_61 .byte 63, 252, 252, 240, 242, 242, 194, 202
DNA_62 .byte 42, 170, 170, 170, 170, 170, 170, 170
DNA_63 .byte 5, 133, 133, 133, 129, 161, 160, 168
DNA_64 .byte 82, 82, 82, 82, 84, 84, 87, 85
DNA_65 .byte 168, 168, 161, 161, 161, 5, 213, 213
DNA_66 .byte 84, 84, 80, 82, 66, 74, 74, 74
DNA_67 .byte 170, 170, 170, 170, 170, 170, 170, 170
DNA_68 .byte 15, 143, 143, 131, 163, 163, 160, 168
DNA_69 .byte 242, 240, 252, 252, 255, 255, 255, 255
DNA_70 .byte 255, 252, 242, 10, 170, 170, 170, 170
DNA_71 .byte 42, 170, 170, 170, 170, 170, 170, 170
DNA_72 .byte 170, 170, 170, 170, 170, 170, 170, 170
DNA_73 .byte 168, 168, 170, 170, 170, 170, 170, 170
DNA_74 .byte 85, 21, 21, 5, 128, 170, 170, 170
DNA_75 .byte 245, 117, 85, 84, 0, 170, 170, 170
DNA_76 .byte 74, 42, 42, 42, 170, 170, 170, 170
DNA_77 .byte 170, 170, 170, 170, 170, 170, 170, 170
DNA_78 .byte 168, 168, 170, 170, 170, 170, 170, 170
DNA_79 .byte 255, 63, 3, 160, 170, 170, 170, 170