
copyImage
; Bitmap data is loaded in at $6000 - $7F3F which is 7,999 bytes, or 31 * 256
; Load background color and set it
; $8710 - $6000 = 2710
lda dylan1+$2710
sta $d021
sta $d020

; Loop to 256 31 times here

ldx #0
loadccimage
; BITMAP
lda dylan1,x
sta $6000,x
lda dylan1+$100,x
sta $6100,x
lda dylan1+$200,x
sta $6200,x
lda dylan1+$300,x
sta $6300,x
lda dylan1+$400,x
sta $6400,x
lda dylan1+$500,x
sta $6500,x
lda dylan1+$600,x
sta $6600,x
lda dylan1+$700,x
sta $6700,x
lda dylan1+$800,x
sta $6800,x
lda dylan1+$900,x
sta $6900,x
lda dylan1+$A00,x
sta $6A00,x
lda dylan1+$B00,x
sta $6B00,x
lda dylan1+$C00,x
sta $6C00,x
lda dylan1+$D00,x
sta $6D00,x
lda dylan1+$E00,x
sta $6E00,x
lda dylan1+$F00,x
sta $6F00,x
lda dylan1+$1000,x
sta $7000,x
lda dylan1+$1100,x
sta $7100,x
lda dylan1+$1200,x
sta $7200,x
lda dylan1+$1300,x
sta $7300,x
lda dylan1+$1400,x
sta $7400,x
lda dylan1+$1500,x
sta $7500,x
lda dylan1+$1600,x
sta $7600,x
lda dylan1+$1700,x
sta $7700,x
lda dylan1+$1800,x
sta $7800,x
lda dylan1+$1900,x
sta $7900,x
lda dylan1+$1A00,x
sta $7A00,x
lda dylan1+$1B00,x
sta $7B00,x
lda dylan1+$1C00,x
sta $7C00,x
lda dylan1+$1D00,x
sta $7D00,x
lda dylan1+$1E00,x
sta $7E00,x
lda dylan1+$1F00,x
sta $7F00,x


; SCREEN RAM
; $7F40 - $6000 =
lda dylan1+$1f40,x
;    LDA $7F40,X
STA $5C00,X
lda dylan1+$2040,x
;    LDA $8040,X
STA $5D00,X
lda dylan1+$2140,x
;    LDA $8140,X
STA $5E00,X
lda dylan1+$2240,x
;    LDA $8240,X
STA $5F00,X

; COLOR RAM
; $8328 - $6000 = $2328
; $7C00 more than screen mem??
bitmapColorCopy
lda dylan1+$2328,x
STA $D800,X
lda dylan1+$2428,x
STA $D900,X
lda dylan1+$2528,x
STA $DA00,X
lda dylan1+$2628,x
STA $DB00,X


inx
beq ci_done
jmp loadccimage
ci_done
rts


setupScreenForSpashScreen
    jsr copyImage
reShowImage
    jsr backUpCurrentVideoSettings


    lda #$02 ; bank #1 index 0 $4000-$7FFF + $2000 = $6000, default is 3 which is bank #0
    sta $DD00
    lda #$3B
    sta $d011
    lda #$D8
    sta $d016
    lda $d018
    and #%00000001
    ora #%01111100
    sta $d018
    rts

backUpCurrentVideoSettings
    lda $DD00
    sta old_DD00
    lda $d011
    sta old_D011
    lda $d016
    sta old_d016
    lda $d018
    sta old_D018
    rts

returnScreenBackFromSpash
    lda old_DD00
    sta $DD00
    lda old_D011
    sta $d011
    lda old_d016
    sta $d016
    lda old_D018
    sta $d018
    rts
old_DD00    .byte $00
old_D011    .byte $00
old_d016    .byte $00
old_D018    .byte $00
