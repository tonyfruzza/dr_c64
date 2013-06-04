; 4 possible video memory locations, switchable by the first 2
; bits of 56576 (CIA) (0, 1, 2, 3). The other bits are for something else, so keep those

; 648 has the upper eight bits of 16 bit value to where the "screen editor" is located


;PILL_LEFT   .equ 107
;PILL_RIGHT  .equ 115
;PILL_TOP    .equ 114
;PILL_BOTTOM .equ 113

ROMCHARBITMAP   .equ 53248 ; - 57343 from ROM
NEWCHARMAP      .equ 12288 ; $3000 new place for Charset

MoveCharMap
    ; Entry point
    jmp mcm_start
    ; Define some custom character data
    V2_AN1      .byte 170, 124, 68, 238, 186, 198, 124, 0
    V2_AN2      .byte 170, 124, 68, 238, 254, 130, 124, 0
    V2_AN3      .byte 170, 124, 68, 238, 254, 198, 186, 0

    V3_AN1      .byte 68, 56, 124, 238, 254, 198, 56, 0
    V3_AN2      .byte 136, 56, 124, 222, 254, 198, 56, 0
    V3_AN3      .byte 34, 56, 124, 246, 254, 198, 56, 0

    ; End of custom character data

    PILL_STATE  .byte $00

mcm_start

; 8 bytes to each char
; To modify A which = 1
; 1*8 + 53248


; turn keyboard scanning OFF
    lda 56334
    and #254
    sta 56334

; Switch in ROM characters into RAM
    lda 1
    and #251
    sta 1

CharCopyInit
    ldx #00
    ldy #00
CharCopyLoop
    lda ROMCHARBITMAP,x
    sta NEWCHARMAP,x
    inx
    bne CharCopyLoop
CharCopyLoop2
    lda ROMCHARBITMAP+256,x
    sta NEWCHARMAP+256,x
    inx
    bne CharCopyLoop2

; Switch i/o
    lda 1
    ora #4
    sta 1

; Turn keyboard scanning back ON
    lda 56334
    ora #1
    sta 56334


; Do Pill parts
    ldx #00
PillMakerLoop
    ; For the numbers
    lda NUMS, x
    sta NEWCHARMAP+384, x
    lda NUMS+8, x
    sta NEWCHARMAP+392, x
    lda NUMS+16, x
    sta NEWCHARMAP+400, x
    lda NUMS+24, x
    sta NEWCHARMAP+408, x
    lda NUMS+32, x
    sta NEWCHARMAP+416, x
    lda NUMS+40, x
    sta NEWCHARMAP+424, x
    lda NUMS+48, x
    sta NEWCHARMAP+432, x
    lda NUMS+56, x
    sta NEWCHARMAP+440, x
    lda NUMS+64, x
    sta NEWCHARMAP+448, x
    lda NUMS+72, x
    sta NEWCHARMAP+456, x
    ; End of the numbers


    lda PILL_H, x
    sta NEWCHARMAP+856, x; 8 * 107

    lda PILL_H + 8, x
    sta NEWCHARMAP+920, x; 8 * 115

    lda PILL_V, x
    sta NEWCHARMAP+912, x ; 8 * 114

    lda PILL_V + 8, x
    sta NEWCHARMAP+904, x ; 8 * 113

    lda PILL_HLF2, x
    sta NEWCHARMAP+648, x ; 8 * 81

    lda CLEAR_PIECE, x
    sta NEWCHARMAP+688, x ; 8 * 86
    lda CLEAR_PIECE_1, x
    sta NEWCHARMAP+720, x ; 8 * 90
    lda CLEAR_PIECE_2, x
    sta NEWCHARMAP+728, x; 8 * 91

    lda GAME_BORDER_4, x ; background
    sta NEWCHARMAP+1016, x ; 8 * 127

    lda GAME_BORDER_3,x
    sta NEWCHARMAP+816, x ; 8 * 102

    lda GAME_BORDER_2, x
    sta NEWCHARMAP+584, x ; 8 * 73

    lda GAME_BORDER, x
    sta NEWCHARMAP+880, x ; 8 * 110

    lda GAME_BORDER_1, x
    sta NEWCHARMAP+896, x ; 8 * 112

    lda GAME_BORDER_7, x
    sta NEWCHARMAP+544, x ; 8 * 68

    lda GAME_BORDER_6, x
    sta NEWCHARMAP+592, x; 8 * 74

    lda GAME_BORDER_8, x
    sta NEWCHARMAP+600, x; 8 * 75

    lda V1_AN, x
    sta NEWCHARMAP+664,x ; 8 * 83

    lda V2_AN1, x
    sta NEWCHARMAP+672,x ; 8 * 84

    lda V3_AN1, x
    sta NEWCHARMAP+680,x ; 8 * 85

    lda PILL_HD, x
    sta NEWCHARMAP+864,x ; 8 * 108

    lda PILL_HD+8, x
    sta NEWCHARMAP+928,x ; 8 * 116

    lda PILL_VD, x
    sta NEWCHARMAP+888,x ; 8 * 111
    lda PILL_VD+8, x
    sta NEWCHARMAP+936,x ; 8 * 117

; Zombie Dude is 15 chars total 3x5 starting at character 128
; 128, 129, 130
; 131, 132, 133
; 134, 135, 136
; 137, 138, 139
; 140, 141, 142

lda zombie, x
sta NEWCHARMAP+1024,x ; 8 * 128
lda zombie_1, x
sta NEWCHARMAP+1032,x
lda zombie_2, x
sta NEWCHARMAP+1040,x
lda zombie_3, x
sta NEWCHARMAP+1048,x
lda zombie_4, x
sta NEWCHARMAP+1056,x
lda zombie_5, x
sta NEWCHARMAP+1064,x
lda zombie_6, x
sta NEWCHARMAP+1072,x
lda zombie_7, x
sta NEWCHARMAP+1080,x
lda zombie_8, x
sta NEWCHARMAP+1088,x
lda zombie_9, x
sta NEWCHARMAP+1096,x
lda zombie_10, x
sta NEWCHARMAP+1104,x
lda zombie_11, x
sta NEWCHARMAP+1112,x
lda zombie_12, x
sta NEWCHARMAP+1120,x
lda zombie_13, x
sta NEWCHARMAP+1128,x
lda zombie_14, x
sta NEWCHARMAP+1136,x ; 8 * 142


; 5 chars tall
lda vdemo, x
sta NEWCHARMAP+1144,x ; 8 * 143
lda vdemo_1, x
sta NEWCHARMAP+1152,x
lda vdemo_2, x
sta NEWCHARMAP+1160,x
lda vdemo_3, x
sta NEWCHARMAP+1168,x
lda vdemo_4, x
sta NEWCHARMAP+1176,x ; 8 * 147








    inx
    cpx #8

    beq charMakerComplete
    jmp PillMakerLoop
charMakerComplete

    ; Tell VIC where to get charmap from
    lda 53272
    and #240
    clc
    adc #12
    sta 53272

    rts


; Animates the viruses in the field by cycling through
; their 3 animation states
cycleAnimatedViruses

    ldx #0 ; Init our x index
    lda PILL_STATE
    cmp #0
    beq newPillLoop1
    cmp #1
    beq newPillLoop2
    cmp #2
    beq newPillLoop3
    cmp #3
    beq newPillLoop2AndReset


    newPillLoop2AndReset
    lda #$FF ; Reset PILL_STATE as it will roll over to 0 at the end
    sta PILL_STATE
    jmp newPillLoop2

newPillLoop1
    lda V1_AN, x
    sta NEWCHARMAP+664, x ; 8 * 83
    lda V2_AN1, x
    sta NEWCHARMAP+672, x ; 8 * 84
    lda V3_AN1, x
    sta NEWCHARMAP+680, x ; 8 * 85
    inx
    cpx #8
    bne newPillLoop1
    jmp cav_done

newPillLoop2
    lda V1_AN + 8, x
    sta NEWCHARMAP+664, x ; 8 * 83
    lda V2_AN2, x
    sta NEWCHARMAP+672, x ; 8 * 84
    lda V3_AN2, x
    sta NEWCHARMAP+680, x ; 8 * 85

    inx
    cpx #8
    bne newPillLoop2
    jmp cav_done

newPillLoop3
    lda V1_AN + 16, x
    sta NEWCHARMAP+664, x ; 8 * 83
    lda V2_AN3, x
    sta NEWCHARMAP+672, x ; 8 * 84
    lda V3_AN3, x
    sta NEWCHARMAP+680, x ; 8 * 85

    inx
    cpx #8
    bne newPillLoop3
cav_done
    inc PILL_STATE
    rts
