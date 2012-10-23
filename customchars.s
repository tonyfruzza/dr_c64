;.org $0801
;Tells BASIC to run SYS 2064 to start our program
;.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00

; 4 possible video memory locations, switchable by the first 2
; bits of 56576 (CIA) (0, 1, 2, 3). The other bits are for something else, so keep those

; 648 has the upper eight bits of 16 bit value to where the "screen editor" is located


;PILL_LEFT   .equ 107
;PILL_RIGHT  .equ 115
;PILL_TOP    .equ 114
;PILL_BOTTOM .equ 113

CHARBITMAP  .equ 53248 ; - 57343 from ROM
NEWCHARMAP  .equ 12288 ; $3000 new place for Charset

MoveCharMap
    ; Entry point
    jmp mcm_start
    PILL_L_DEF  .byte 126, 194, 190, 254, 254, 254, 126, 0
    PILL_R_DEF  .byte 252, 134, 254, 254, 254, 254, 252, 0
    PILL_T_DEF  .byte 124, 222, 190, 190, 190, 190, 254, 0
    PILL_B_DEF  .byte 254, 190, 190, 190, 190, 254, 124, 0
    PILL_S_DEF  .byte 124, 198, 190, 254, 254, 254, 124, 0
    LEFT_WALL   .byte 66, 66, 66, 66, 66, 66, 66, 66
    WALL_BOTTOM .byte 255, 0 , 0, 0, 0, 255, 0, 0
    WALL_BLFT   .byte 67, 64, 64, 64, 32, 31, 0, 0
    WALL_BRT    .byte 194, 2, 2, 2, 4, 248, 0 , 0
    CLEAR_ONE   .byte 124, 254, 238, 198, 238, 254, 124, 0
    CLEAR_TWO   .byte 124, 198, 130, 130, 130, 198, 124, 0
    BKGRD_CHAR  .byte 240, 240, 240, 240, 15, 15, 15, 15
    V1_AN1      .byte 68, 56, 214, 146, 254, 214, 68, 0
    V2_AN1      .byte 170, 124, 68, 238, 186, 198, 124, 0

    V3_AN1      .byte 68, 56, 124, 238, 254, 198, 56, 0
    V3_AN2      .byte 136, 56, 124, 222, 254, 198, 56, 0
    V3_AN3      .byte 34, 56, 124, 246, 254, 198, 56, 0

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
    lda CHARBITMAP,x
    sta NEWCHARMAP,x
    inx
    bne CharCopyLoop
CharCopyLoop2
    lda CHARBITMAP+256,x
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

; Tell VIC where to get charmap from
lda 53272
and #240
clc
adc #12
sta 53272


; Do Pill parts
    ldx #00
PillMakerLoop
    lda PILL_L_DEF, x
    sta NEWCHARMAP+856, x; 8 * 107

    lda PILL_R_DEF, x
    sta NEWCHARMAP+920, x; 8 * 115

    lda PILL_T_DEF, x
    sta NEWCHARMAP+912, x ; 8 * 114

    lda PILL_B_DEF, x
    sta NEWCHARMAP+904, x ; 8 * 113

    lda PILL_S_DEF, x
    sta NEWCHARMAP+648, x ; 8 * 81

    lda LEFT_WALL, x
    sta NEWCHARMAP+816, x ; 8 * 102

    lda CLEAR_ONE, x
    sta NEWCHARMAP+688, x ; 8 * 86

    lda CLEAR_TWO, x
    sta NEWCHARMAP+720, x ; 8 * 90

    lda BKGRD_CHAR, x
    sta NEWCHARMAP+1016, x ; 8 * 127

    lda WALL_BOTTOM, x
    sta NEWCHARMAP+544, x ; 8 * 68

lda WALL_BLFT, x
sta NEWCHARMAP+592, x; 8 * 74

lda WALL_BRT, x
sta NEWCHARMAP+600, x; 8 * 75

;lda V1_AN1, x
;sta NEWCHARMAP+664,x ; 8 * 83

lda V2_AN1, x
sta NEWCHARMAP+664,x ; 8 * 83


;lda V2_AN1, x
;sta NEWCHARMAP+672,x ; 8 * 84



    inx
    cpx #8
    bne PillMakerLoop

    rts



cycleAnimatedViruses
    ldx #0

    lda PILL_STATE
    bne cav_next2
newPillLoop1
    lda V3_AN1, x
    sta NEWCHARMAP+664, x
    inx
    cpx #8
    bne newPillLoop1
    jmp cav_done

cav_next2
    lda PILL_STATE
    cmp #1
    bne cav_next3
newPillLoop2
    lda V3_AN2, x
    sta NEWCHARMAP+664, x
    inx
    cpx #8
    bne newPillLoop2
    jmp cav_done
cav_next3
    lda #0
    sta PILL_STATE
newPillLoop3
    lda V3_AN3, x
    sta NEWCHARMAP+664, x
    inx
    cpx #8
    bne newPillLoop3
cav_done
    inc PILL_STATE
    rts