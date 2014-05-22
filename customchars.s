NEWCHARMAP      .equ $3800

V1_AN2          .equ NEWCHARMAP+608 ; 8 * 76 + 3000
V1_AN3          .equ NEWCHARMAP+616 ; 8 * 77 + 3000
V1_AN4          .equ NEWCHARMAP+624 ; 8 * 78 + 3000

V2_AN2          .equ NEWCHARMAP+640 ; 8 * 80 + 3000
V2_AN3          .equ NEWCHARMAP+648 ; 8 * 81 + 3000
V2_AN4          .equ NEWCHARMAP+656 ; 8 * 82 + 3000

V3_AN2          .equ NEWCHARMAP+672 ; 8 * 84 + 3000
V3_AN3          .equ NEWCHARMAP+680 ; 8 * 85 + 3000
V3_AN4          .equ NEWCHARMAP+688 ; 8 * 86 + 3000


setUpVirusAnimationSequences
    ldx #00
PillMakerLoop
    ; Make a copy of the original and store in temp place
    lda NEWCHARMAP+600, x ; 8 * ?
    sta V1_ORG_COPY, x

    lda NEWCHARMAP+632, x ; 8 * ?
    sta V2_ORG_COPY, x

    lda NEWCHARMAP+664, x ; 8 * ?
    sta V3_ORG_COPY, x

    inx
    cpx #8
    bne PillMakerLoop
; Configure screen memory
    lda #%00011111 ; Screen mem = $0400, and Charmap starts at $3800
    sta $d018
    rts


; Animates the viruses in the field by cycling through
; their 3 animation states
cycleAnimatedViruses
    lda refreshTimer4
    cmp #VIRUS_ANI_DELAY
    beq doCycleAni
    inc refreshTimer4
    rts
doCycleAni
; Testing
    jsr incFrameForOverFace
    ldx #0 ; Init our x index
    lda PILL_STATE
    cmp #0
    beq newPillLoop1
    cmp #1
    beq newPillLoop2
    cmp #2
    beq newPillLoop3
;    cmp #3
    jmp newPillLoop2AndReset

newPillLoop1
    lda V1_ORG_COPY, x
    sta NEWCHARMAP+600, x ; 8 * 75
    lda V2_ORG_COPY, x
    sta NEWCHARMAP+632, x ; 8 * 79
    lda V3_ORG_COPY, x
    sta NEWCHARMAP+664, x ; 8 * 83
    inx
    cpx #8
    bne newPillLoop1
    jmp cav_done

newPillLoop2
    lda V1_AN2, x
    sta NEWCHARMAP+600, x ; 8 * 70
    lda V2_AN2, x
    sta NEWCHARMAP+632, x ; 8 * 84
    lda V3_AN2, x
    sta NEWCHARMAP+664, x ; 8 * 85

    inx
    cpx #8
    bne newPillLoop2
    jmp cav_done

newPillLoop3
    lda V1_AN3, x
    sta NEWCHARMAP+600, x ; 8 * 70
    lda V2_AN3, x
    sta NEWCHARMAP+632, x ; 8 * 84
    lda V3_AN3, x
    sta NEWCHARMAP+664, x ; 8 * 85

    inx
    cpx #8
    bne newPillLoop3
    jmp cav_done

newPillLoop2AndReset
    lda V1_AN4, x
    sta NEWCHARMAP+600, x ; 8 * 70
    lda V2_AN4, x
    sta NEWCHARMAP+632, x ; 8 * 84
    lda V3_AN4, x
    sta NEWCHARMAP+664, x ; 8 * 85

    inx
    cpx #8
    bne newPillLoop2AndReset

    lda #0 ; Reset PILL_STATE as it will roll over to 0 at the end
    sta PILL_STATE
    rts
cav_done
    lda #0
    sta refreshTimer4
    inc PILL_STATE
    rts

PILL_STATE  .byte 0
V1_ORG_COPY .byte 0, 0, 0, 0, 0, 0, 0, 0
V2_ORG_COPY .byte 0, 0, 0, 0, 0, 0, 0, 0
V3_ORG_COPY .byte 0, 0, 0, 0, 0, 0, 0, 0


