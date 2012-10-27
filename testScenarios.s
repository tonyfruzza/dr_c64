;PILL_SIDE       .equ 81 ; 'o'
;VIRUS_ONE       .equ 83
;VIRUS_TWO       .equ 84
;PILL_LEFT       .equ 107
;PILL_RIGHT      .equ 115
;PILL_TOP        .equ 114
;PILL_BOTTOM     .equ 113

;lda #$0F ; Low byte start location
;lda #$04 ; High byte start location


test1 ; Test to see that horizontal drops are joined together
    ldy #$00
    lda #$10
    sta zpPtr2
    lda #$04
    sta zpPtr2+1

ldy #6
    lda #PILL_LEFT
    sta (zpPtr2),y
    lda #PILL_RIGHT
    iny
    sta (zpPtr2),y

    ldy #46
    lda #PILL_LEFT
    sta (zpPtr2), y
    iny
    lda #PILL_RIGHT
    sta (zpPtr2),y

    ldy #86
    lda #PILL_SIDE
    sta (zpPtr2),y
    iny
    sta (zpPtr2),y
    ldy #166
    sta (zpPtr2),y
    iny
    sta (zpPtr2),y

    rts

test2 ; Test to see that two veritically stacked pieces will drop okay together
    ldy #$00
    lda #$10
    sta zpPtr2
    lda #$04
    sta zpPtr2+1

    ldy #7
    lda #PILL_TOP
    sta (zpPtr2),y
    ldy #47
    lda #PILL_BOTTOM
    sta (zpPtr2),y

    ldy #127
    lda #PILL_TOP
    sta (zpPtr2), y
    ldy #167
    lda #PILL_BOTTOM
    sta (zpPtr2),y

    ldy #207
    lda #PILL_SIDE
    sta (zpPtr2),y
    rts

