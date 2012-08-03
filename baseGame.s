
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
zpPtr3          .equ $b6




jmp init

; Some vars
ENDMSG      .byte "END", $0d, 0
ORGBOARDER  .byte $00
ORGBGRND    .byte $00
DRAWCOUNT   .byte $00 ; How many screen draws since last reset used as a timer
ORIENTATION .byte $00 ; 0 = 12, 1 = 1, 2 = 21, 3 = 2
                      ;             2              1
PRICOLOR    .byte $00
SECCOLOR    .byte $00
colors      .byte COLOR_RED, COLOR_RED, COLOR_YELLOW, COLOR_BLUE

init
jsr ClearScreen
jsr DrawGameBoarder
            ldy #$00  ; set to 1024 our screen pos
            sty VIC_MEM+33

DropNew     ldy #$13 ; Offset low byte location
            sty zpPtr1
            iny
            sty piece2
            lda #$04 ; Offset high byte location
            sta zpPtr1+1
            sta piece2+1

ldy #$00
lda #87 ; 'o'
sta (zpPtr1), y
sta (piece2), y
jsr NewColors


;the main game loop
;jsr printNumbersAlongTop
GameLoop
lda DRAWCOUNT
cmp #$10
BCS MoveDownJump

        JSR GETIN ; get a key input
        cmp #'w'
        beq SwapColors
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
SwapColors   jsr ColorSwap
                jmp GameLoop



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
lda piece2
sta zpPtr2
lda piece2+1
sta zpPtr2+1

jsr CheckCollisionRight_zpPtr2
bne rightMoveDone

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
rightMoveDone   jmp MoveDone





MoveLeftOne
                lda zpPtr1
                sta zpPtr2
                lda zpPtr1+1
                sta zpPtr2+1
                jsr CheckCollisionLeft_zpPtr2
                bne leftMoveDone

                ; Clear the current pos
                ldy #$00 ; offset from current char pos
                lda #" "
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
lda #" "
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
leftMoveDone                jmp MoveDone







ZeroCountAndMoveDown
                lda #$00
                sta DRAWCOUNT
MoveDownOne     lda ORIENTATION

checkPrimaryBottom ldy #$00 ; offset from current char pos
                ; See if we can move down, is something there already??

                lda zpPtr1 ; Copy piece into zpPtr2 for checking
                sta zpPtr2
                iny
                lda zpPtr1+1
                sta zpPtr2+1
                jsr CheckCollisionBelow_zpPtr2
                bne DropNewPiece
                ; Moving piece down first clear value then add 40 to main piece

checkSecondaryBottom
                ldy #$00 ; offset from current char pos
                ; See if we can move down, is something there already??

                lda piece2, y ; Copy piece into zpPtr2 for checking
                sta zpPtr2, y
                iny
                lda piece2, y
                sta zpPtr2, y
                jsr CheckCollisionBelow_zpPtr2
                bne DropNewPiece
                ; Moving piece down first clear value then add 40 to main piece

movePrimaryDown lda #" "
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
moveSecondaryDown lda #" "
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
                JSR ChangeColor

MoveComplete    jmp MoveDone
DropNewPiece    jmp DropNew


CheckCollisionBelow_zpPtr2 ; Sets a = 1 if there will be collition below then rts
                lda zpPtr2 ; Make a copy of the current possition
                sta zpPtr3 ; into zpPtr3
                lda zpPtr2+1
                sta zpPtr3+1

                ; Look below to see what's there, is it a space?
                clc
                lda #40
                adc zpPtr3
                sta zpPtr3
                lda #$00 ; Add any roll over to the high byte
                adc zpPtr3+1
                sta zpPtr3+1
            
                ldy #$00
                lda (zpPtr3), y
                cmp #" "
                beq noCollitionDetected
                bne collitionDetected
collitionDetected
lda #"1"
sta 1024
                lda #$01
                rts
noCollitionDetected
lda #"0"
sta 1024
                lda #$00
                rts

; function CheckCollisionLeft_zpPtr2
CheckCollisionLeft_zpPtr2 ; Sets a = 1 if there will be collition below then rts
            lda zpPtr2 ; Make a copy of the current possition
            sta zpPtr3 ; into zpPtr3
            lda zpPtr2+1
            sta zpPtr3+1

            ; Look below to see what's there, is it a space?
            sec
            lda zpPtr3
            sbc #$01
            sta zpPtr3
            lda zpPtr3+1
            sbc #$00
            sta zpPtr3+1
            ldy #$00
            lda (zpPtr3), y
            cmp #" "
            beq noCollitionDetectedLeft
            bne collitionDetectedLeft
noCollitionDetectedLeft
            lda #"0"
            sta 1024
            lda #$00
            rts
collitionDetectedLeft
            lda #"1"
            sta 1024
            lda #$01
            rts

; function CheckCollisionLeft_zpPtr2
CheckCollisionRight_zpPtr2 ; Sets a = 1 if there will be collition below then rts
            ldy #$01
            lda (zpPtr2), y
            cmp #" "
            beq noCollitionDetectedRight
            bne collitionDetectedRight
noCollitionDetectedRight
            lda #"0"
            sta 1024
            lda #$00
            rts
collitionDetectedRight
            lda #"1"
            sta 1024
            lda #$01
            rts





NewColors
            jsr get_random_number
            and #3
            tay
            lda colors, y
            sta PRICOLOR
            jsr get_random_number
            and #3
            tay
            lda colors, y
            sta SECCOLOR
            ldy #00
ChangeColor ; Messes with zpPtr2
            lda zpPtr1
            sta zpPtr2
            lda zpPtr1+1
            sta zpPtr2+1
            lda #$D4
            clc
            adc zpPtr2+1
            sta zpPtr2+1

            lda PRICOLOR
            sta (zpPtr2), y
            lda piece2
            sta zpPtr2
            lda piece2+1
            sta zpPtr2+1
            lda #$D4
            clc
            adc zpPtr2+1
            sta zpPtr2+1
            lda SECCOLOR
            sta (zpPtr2), y
            RTS

ColorSwap   lda PRICOLOR
            ldx SECCOLOR
            sta SECCOLOR
            stx PRICOLOR
            jsr ChangeColor
            rts



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
            LDA #" " ; Space
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


; Draw game board using char $7E as the boarder
; We'll start at the top left +3, draw down 16, 8 accross
DrawGameBoarder
        ldx #$00 ; Our counter
        lda #$0F ; Low byte start location
        sta zpPtr2
        lda #$04 ; High byte start location
        sta zpPtr2+1
        lda #230
        ldy #$00
        sta (zpPtr2), y
        ldy #9
        sta (zpPtr2), y
dgbLoop ldy #00
        clc
        lda #40
        adc zpPtr2
        sta zpPtr2
        lda #$00
        adc zpPtr2+1
        sta zpPtr2+1
        lda #230
        sta (zpPtr2), y
        ldy #9
        sta (zpPtr2), y
        inx
        cpx #16
        bne dgbLoop
; then finish off the bottom line
ldy #1
DrawBottom
sta (zpPtr2), y
iny
cpy #9
bne DrawBottom
dgbDone rts


get_random_number
            lda $d012 ; load current screen raster value
            eor $dc04 ; xor against value in $dc04
            sbc $dc05 ; then subtract value in $dc05
            rts
