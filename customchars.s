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
    PILL_L_DEF  .byte 126, 194, 190, 254, 254, 254, 126, 0
    PILL_R_DEF  .byte 252, 134, 254, 254, 254, 254, 252, 0
    PILL_T_DEF  .byte 124, 222, 190, 190, 190, 190, 254, 0
    PILL_B_DEF  .byte 254, 190, 190, 190, 190, 254, 124, 0
    PILL_S_DEF  .byte 124, 198, 190, 254, 254, 254, 124, 0

    LEFT_WALL   .byte 66, 66, 66, 66, 66, 66, 66, 66
    WALL_BOTTOM .byte 255, 0 , 0, 0, 0, 255, 0, 0
    WALL_BLFT   .byte 67, 64, 64, 64, 32, 31, 0, 0
    WALL_BRT    .byte 194, 2, 2, 2, 4, 248, 0 , 0
    WALL_TLFT   .byte 0, 0, 127, 96, 80, 72, 68, 67
    WALL_TRT    .byte 0, 0, 254, 6, 10, 18, 34, 194
    WALL_TOP    .byte 0, 0, 255, 0, 0, 0, 255, 0
    CLEAR_ONE   .byte 124, 254, 238, 198, 238, 254, 124, 0
    CLEAR_TWO   .byte 124, 198, 130, 130, 130, 198, 124, 0

BKGRD_CHAR .byte 0, 0, 60, 36, 36, 60, 0, 0
;    BKGRD_CHAR  .byte 240, 240, 240, 240, 15, 15, 15, 15
;    BKGRD_CHAR  .byte 0, 0, 0, 0, 0, 0, 0, 0
    BKGRD_CHAR2 .byte 135, 120, 120, 120, 120, 135, 135, 135
    BKGRD_CHAR3 .byte 195, 195, 60, 60, 60, 60, 195, 195
    BKGRD_CHAR4 .byte 225, 225, 225, 30, 30, 30, 30, 225



    V1_AN1      .byte 68, 56, 214, 146, 254, 214, 68, 0
    V1_AN2      .byte 198, 56, 214, 146, 254, 214, 130, 0
    V1_AN3      .byte 130, 124, 146, 186, 254, 214, 68, 0

    V2_AN1      .byte 170, 124, 68, 238, 186, 198, 124, 0
    V2_AN2      .byte 170, 124, 68, 238, 254, 130, 124, 0
    V2_AN3      .byte 170, 124, 68, 238, 254, 198, 186, 0


    V3_AN1      .byte 68, 56, 124, 238, 254, 198, 56, 0
    V3_AN2      .byte 136, 56, 124, 222, 254, 198, 56, 0
    V3_AN3      .byte 34, 56, 124, 246, 254, 198, 56, 0
; Some numbers I generated from photoshop:
CUST_CHAR_0 .byte 24, 36, 36, 36, 36, 36, 24, 0
CUST_CHAR_1 .byte 16, 48, 16, 16, 16, 16, 56, 0
CUST_CHAR_2 .byte 56, 68, 68, 8, 16, 36, 124, 0
CUST_CHAR_3 .byte 56, 68, 4, 24, 4, 68, 56, 0
CUST_CHAR_4 .byte 8, 24, 40, 72, 124, 8, 28, 0
CUST_CHAR_5 .byte 124, 64, 120, 4, 4, 68, 56, 0
CUST_CHAR_6 .byte 24, 32, 64, 120, 68, 68, 56, 0
CUST_CHAR_7 .byte 62, 34, 2, 4, 4, 8, 8, 0
CUST_CHAR_8 .byte 28, 34, 34, 28, 34, 34, 28, 0
CUST_CHAR_9 .byte 28, 34, 34, 30, 2, 4, 24, 0

    ; End of custom character data

    PILL_STATE  .byte $00
    BKGRD_STATE .byte $00

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
    ; For the numbers:
    lda CUST_CHAR_0, x
    sta NEWCHARMAP+384, x
    lda CUST_CHAR_1, x
    sta NEWCHARMAP+392, x
    lda CUST_CHAR_2, x
    sta NEWCHARMAP+400, x
    lda CUST_CHAR_3, x
    sta NEWCHARMAP+408, x
    lda CUST_CHAR_4, x
    sta NEWCHARMAP+416, x
    lda CUST_CHAR_5, x
    sta NEWCHARMAP+424, x
    lda CUST_CHAR_6, x
    sta NEWCHARMAP+432, x
    lda CUST_CHAR_7, x
    sta NEWCHARMAP+440, x
    lda CUST_CHAR_8, x
    sta NEWCHARMAP+448, x
    lda CUST_CHAR_9, x
    sta NEWCHARMAP+456, x
    ; End of the numbers


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

    lda WALL_TRT, x
    sta NEWCHARMAP+584, x ; 8 * 73

    lda WALL_TLFT, x
    sta NEWCHARMAP+880, x ; 8 * 110

    lda WALL_TOP, x
    sta NEWCHARMAP+896, x ; 8 * 112

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




    lda V1_AN1, x
    sta NEWCHARMAP+664,x ; 8 * 83

    lda V2_AN1, x
    sta NEWCHARMAP+672,x ; 8 * 84

    lda V3_AN1, x
    sta NEWCHARMAP+680,x ; 8 * 85





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



cycleBackgroundAnimation
    ldx #0
    lda BKGRD_STATE
    cmp #0
    beq bg_state1_loop
    cmp #1
    beq bg_state2_loop
    cmp #2
    beq bg_state3_loop
    cmp #3
    beq bg_state4_loop


bg_state1_loop
    lda BKGRD_CHAR, x
    sta NEWCHARMAP+1016, x
    inx
    cpx #8
    bne bg_state1_loop
    jmp cba_done

bg_state2_loop
    lda BKGRD_CHAR2, x
    sta NEWCHARMAP+1016, x
    inx
    cpx #8
    bne bg_state2_loop
    jmp cba_done


bg_state3_loop
    lda BKGRD_CHAR3, x
    sta NEWCHARMAP+1016, x
    inx
    cpx #8
    bne bg_state3_loop
    jmp cba_done


bg_state4_loop
    lda #$ff
    sta BKGRD_STATE ; last cycle, so have it overflow back to 0 after this
    lda BKGRD_CHAR4, x
    sta NEWCHARMAP+1016, x
    inx
    cpx #8
    bne bg_state4_loop
    jmp cba_done


cba_done
    inc BKGRD_STATE
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
    lda V1_AN1, x
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
    lda V1_AN2, x
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
    lda V1_AN3, x
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
