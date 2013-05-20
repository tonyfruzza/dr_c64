
; currentLvl 0 - 20
; Based on level have some presets
; Colors have to be 0-7
;COLOR_BLACK     .equ $00
;COLOR_WHITE     .equ $01
;COLOR_RED       .equ $02
;COLOR_CYAN      .equ $03
;COLOR_MAGENTA   .equ $04
;COLOR_GREEN     .equ $05
;COLOR_BLUE      .equ $06
;COLOR_YELLOW    .equ $07

changeColorSet
lda currentLvl
cmp #6
bcc FIRST_COLOR_SET ; ? <= 6
cmp #20
bcc SECOND_COLOR_SET
;cmp #20
;bcc THIRD_COLOR_SET

rts


FIRST_COLOR_SET
lda #COLOR_CYAN
sta colors
lda #COLOR_MAGENTA
sta colors+1
lda #COLOR_YELLOW
sta colors+2
lda #COLOR_MAGENTA
sta colors+3
rts

SECOND_COLOR_SET
lda #COLOR_RED
sta colors
lda #COLOR_BLUE
sta colors+1
lda #COLOR_YELLOW
sta colors+2
lda #COLOR_BLUE
sta colors+3
rts

THIRD_COLOR_SET
lda #COLOR_RED
sta colors
lda #COLOR_BLUE
sta colors+1
lda #COLOR_WHITE
sta colors+2
lda #COLOR_BLUE
sta colors+3
rts

