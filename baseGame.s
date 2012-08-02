
.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00

CHROUT  .equ $FFD2
GETIN   .equ $FFE4
STOP    .equ $FFE1 ; Check for run stop, sets Z flag, then exit
SCREENMEM   .equ 1024 ; Start of character screen map, color map is + $D400
VMEM    .equ $D000


VIC_MEM         .equ 53248
SCREEN_BOARDER  .equ VIC_MEM + 32
SCREEN_BG_COLOR .equ VIC_MEM + 33
SCREEN_CHAR     .equ 52224
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

; Zero Page Pointers for indirect indexing
zpPtr1          .equ $b0
zpPtr2          .equ $b2
piece2          .equ $b4


jmp init

; Some vars
ENDMSG      .byte "END", $0d, 0
ORGBOARDER  .byte $00
ORGBGRND    .byte $00
DRAWCOUNT   .byte $00 ; How many screen draws since last reset used as a timer
ORIENTATION .byte $00 ; 0 = 12, 1 = 1, 2 = 21, 3 = 2
                      ;             2              1

init
;jsr ClearScreen
            ldy #$00  ; set to 1024 our screen pos
sty VIC_MEM+33
            sty zpPtr1
            iny
            sty piece2
            lda #$04
            sta zpPtr1+1
            sta piece2+1

ldy #$00
lda #87 ; 'o'
sta (zpPtr1), y
sta (piece2), y


;the main game loop
;jsr printNumbersAlongTop
GameLoop
lda DRAWCOUNT
cmp #$10
BCS MoveDownJump

        JSR GETIN ; get a key input
        cmp #'d'
        beq MoveRightOne
        cmp #'a'
        beq MoveLeftOne
        cmp #'s'
        beq MoveDownJump
        cmp #'q'
        beq Return
;        cmp #' '
;        beq rotate
        MoveDone
        jsr WaitFrame
        jmp GameLoop

MoveDownJump jmp ZeroCountAndMoveDown
MoveDown     jmp MoveDownOne



WaitFrame   lda $d012
            cmp #$F8
            beq WaitFrame
            ;wait for the raster to reach line $f8 (should be closer to the start of this line this way)
WaitStep2   lda $d012
            cmp #$F8
            bne WaitStep2
            ;jmp MoveDownOne
            ldx DRAWCOUNT
            inx
            stx DRAWCOUNT
Return      rts



;rotate      lda ORIENTATION
;            jmp MoveDone



MoveRightOne
; Secondary piece
                ldy #$00 ; offset from current char pos
lda #' '
sta (piece2), y
clc
lda #$01
adc piece2
sta piece2
lda #$00 ; Add any roll over to the high byte
adc piece2+1
sta piece2+1
lda #87
sta (piece2), y


; clear pos

                lda #' '
                sta (zpPtr1), y
                ; increment the pointer value by one
                clc
                lda #$01
                adc zpPtr1
                sta zpPtr1
                lda #$00 ; Add any roll over to the high byte
                adc zpPtr1+1
                sta zpPtr1+1
                lda #87
                sta (zpPtr1), y

JSR ChangeColor
                jmp MoveDone





MoveLeftOne     ; Clear the current pos
                ldy #$00 ; offset from current char pos

; primary

                lda #' '
                sta (zpPtr1), y

                ; decrement the pointer value by one
                sec
                lda zpPtr1
                sbc #$01
                sta zpPtr1
                lda zpPtr1+1 ; subtract 0 and any borrow generated above
                sbc #$00
                sta zpPtr1+1
                lda #87
                sta (zpPtr1), y

; Second
lda #' '
sta (piece2), y

; decrement the pointer value by one
sec
lda piece2
sbc #$01
sta piece2
lda piece2+1 ; subtract 0 and any borrow generated above
sbc #$00
sta piece2+1
lda #87
sta (piece2), y

JSR ChangeColor
                jmp MoveDone







ZeroCountAndMoveDown
                lda #$00
                sta DRAWCOUNT
MoveDownOne     lda ORIENTATION
;                beq check2ndRight ; 1-2
;               cmp #1
;               beq check2ndAsBottom 
;               cmp #2
;               beq check2left ; 2-1
;               cmp #3
;               beq checkPrimaryBottom


;check2ndRight   ldy #$02 ; offset from current char pos
               ; See if we can move down, is something there already??
;               lda zpPtr1, y ; Make a copy of the current possition
;               sta zpPtr2, y
;               iny
;               lda zpPtr1, y
;               sta zpPtr2, y
;               dey ; back to 0
;
;               ; Look below to see what's there, is it a space?
;               clc
;               lda #40
;               adc zpPtr2
;               sta zpPtr2
;               lda #$00 ; Add any roll over to the high byte
;               adc zpPtr2+1
;               sta zpPtr2+1
;               lda (zpPtr2), y
;               cmp #' '
;               bne MoveDone



checkPrimaryBottom ldy #$00 ; offset from current char pos
                ; See if we can move down, is something there already??
                lda zpPtr1, y ; Make a copy of the current possition
                sta zpPtr2, y
                iny
                lda zpPtr1, y
                sta zpPtr2, y
                dey ; back to 0

                ; Look below to see what's there, is it a space?
                clc
                lda #40
                adc zpPtr2
                sta zpPtr2
                lda #$00 ; Add any roll over to the high byte
                adc zpPtr2+1
                sta zpPtr2+1
                lda (zpPtr2), y
                cmp #' '
                bne MoveComplete


                ; Moving piece down first clear value then add 40 to main piece

movePrimaryDown lda #' '
                sta (zpPtr1), y
                ; increment the pointer value by 40, we should check to see that it didn't go over 2024
                clc
                lda #40
                adc zpPtr1
                sta zpPtr1
                lda #$00 ; Add any roll over to the high byte
                adc zpPtr1+1
                sta zpPtr1+1
                lda #87
                sta (zpPtr1), y
moveSecondaryDown lda #' '
sta (piece2), y
clc
lda #40
adc piece2
sta piece2
lda #$00 ; Add any roll over to the high byte
adc piece2+1
sta piece2+1
lda #87
sta (piece2), y


; for fun set the color here
JSR ChangeColor

MoveComplete    jmp MoveDone

ChangeColor ; Messes with zpPtr2
            lda zpPtr1
            sta zpPtr2
            lda zpPtr1+1
            sta zpPtr2+1
            lda #$D4
            clc
            adc zpPtr2+1
            sta zpPtr2+1
            lda #COLOR_GREEN
            sta (zpPtr2), y
lda piece2
sta zpPtr2
lda piece2+1
sta zpPtr2+1
lda #$D4
clc
adc zpPtr2+1
sta zpPtr2+1
lda #COLOR_RED
sta (zpPtr2), y
            RTS





printNumbersAlongTop    ldx #$00
resetTo0                ldy #"0"
printNumsLoop           tya
                        cmp #':'
                        beq resetTo0
                        sta 1024, x
                        inx
                        iny
                        cpx #40
                        bne printNumsLoop
                        rts





ClearScreen LDX #$00
            LDA #' ' ; Space
Clearing    STA SCREENMEM, X
            STA SCREENMEM + $100, x
            STA SCREENMEM + $200, x
            STA SCREENMEM + $300, x
            INX
            BNE Clearing;
            RTS

; Print Message subrutine
printMsg        ldx #$00
printLoop       lda ENDMSG, x
beq printComplete
inx
jsr CHROUT 
jmp printLoop
printComplete   rts


; Draw game board
