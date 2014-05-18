.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00


lda #0
sta $d0

    lda #$1f
    sta $d018

    ldx #0
Loop
    lda #73
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x
    inx
    bne Loop

    looper
    jmp looper
