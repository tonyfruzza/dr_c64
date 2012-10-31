
.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00

CHROUT  .equ $FFD2
GETIN   .equ $FFE4
STOP    .equ $FFE1 ; Check for run stop, sets Z flag, then exit
SCREENMEM   .equ 1024 ; Start of character screen map, color map is + $D400
VMEM    .equ $D000

; VICE Monitor Label File Loading: load_labels "/Users/Tony/Development/DrC64/labels.txt"
; Quick VICE monitor notes:
; show_labels
; m H .piece2 .piece2
; m H .varrayindex .varrayindex
; watch store .varrayindex
; watch store .varrayindex .varrayindex
; break .brkhere
; d $0fdd $0fff
; return

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
;DELAY           .equ 37
delay_slow      .equ 37
PILL_SIDE       .equ 81 ; 'o'
VIRUS_ONE       .equ 83
VIRUS_TWO       .equ 84
VIRUS_THREE     .equ 85


PILL_LEFT       .equ 107
PILL_RIGHT      .equ 115
PILL_TOP        .equ 114
PILL_BOTTOM     .equ 113
WALL_SIDES      .equ 102
WALL_B          .equ 68
WALL_BL         .equ 74
WALL_BR         .equ 75
PILL_CLEAR_1    .equ 86
PILL_CLEAR_2    .equ 90

OnePGameFieldLocLow   .equ $D7
OnePGameFieldLocHigh  .equ $04


; Zero Page Pointers for indirect indexing
piece1          .equ $b0
piece2          .equ $b2

zpPtr1          .equ $ba
zpPtr2          .equ $b4
zpPtr3          .equ $b6
zpPtr4          .equ $b8

piece1_next     .equ $bc
piece2_next     .equ $be


jmp init

; Some global vars
ENDMSG      .byte 5,14,4,0
MSG_NEXT    .byte 14,5,24,20,0
MSG_VIRUS   .byte 22,9,18,21,19,0
MSG_SCORE   .byte 19, 3, 15, 18, 5, 0
MSG_LEVEL   .byte 12,5,22,5,12,0
ORGBOARDER  .byte $00
ORGBGRND    .byte $00
ORIENTATION .byte $00 ; 0 = 12, 1 = 1
                      ;             2
PRICOLOR    .byte $00
SECCOLOR    .byte $00
NextPriC    .byte $00
NextSecC    .byte $00

CMPCOLOR    .byte $00 ; tmp for comparing variable colors
CONNECTCNT  .byte $00
colors      .byte COLOR_RED, COLOR_BLUE, COLOR_YELLOW, COLOR_BLUE

START_POS   .byte $13, $04 ; gets overwritten
LAST_MOMENT_MOVE    .byte $00
VIRUS_CHAR_LIST .byte VIRUS_ONE, VIRUS_TWO, VIRUS_THREE
vOneCount   .byte $00
vTwoCount   .byte $00
vThreeCount .byte $00

varray      .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
varrayIndex .byte $00
harray      .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
harrayIndex .byte $00

RET1        .byte $00, $00
RET2        .byte $00, $00
RETX        .byte $00
RETY        .byte $00
TMP         .byte $00, $00
TMP1        .byte $00
TMP2        .byte $00
TMP3        .byte $00
TMP4        .byte $00
currentLvl  .byte 0
p1PiecesDroppedThisLvl  .byte 0
DELAY       .byte 37
pSideTmp1   .byte $00
pSideTmp2   .byte $00
p1VirusCount    .byte $00
p1VirusClearedInOneTurn  .byte $00

p1VirusCountBinLast .byte $00
p1VirusCountBinNew  .byte $00

;P1_SCORE    .byte $00, $00, $00, $00
P1_SCORE    .byte 0,0,0,0,0,0,0,0,0,0 ; 
P1_SCORE_B  .byte $00, $00, $00, $00 ; Binary value of current score
VIRUS_MUL_1 .byte $64, $00 ; 100

init


    jsr MoveCharMap
    jsr initRefreshCounter
    ; Init START_POS for where pill drops from, 4 to the right of left boarder
    clc
    lda #OnePGameFieldLocLow
    adc #4
    sta START_POS
    lda #OnePGameFieldLocHigh
    adc #0
    sta START_POS+1

clears
    ; Programatically create game layout
    jsr ClearScreen
;jsr colorScreenWithCheckers
    jsr DrawGameBoarder
    jsr printSinglePlayerNextPieceBox
    jsr printSinglePlayerScoreBox
    jsr printSinglePlayerVirusCountBox
    jsr printSinglePlayerLevelBox
    jsr putVirusesOnTheField


    ldy #$00
    sty SCREEN_BG_COLOR
    lda COLOR_DARK_GREY
    sta SCREEN_BOARDER
;jsr test1
;jsr test2
;jsr test3
;jsr test4
;jsr test6

    jsr FieldSearch ; Tally up the virus count, so it can be printed
    jsr printCurrentScore
    jsr printCurrentScore

    lda p1VirusCountBinNew
    sta p1VirusCountBinLast

    ; Reset drop speed for the game, or this level
    lda #delay_slow
    sta DELAY
    jmp firstPieceToDrop
DropNew
    ; Loop through every piece to see if they can be cleared
    jsr lookForAnyConnect4s
    jsr FieldSearch
    jsr UpdateVirusCount
    lda p1VirusCount
    beq NextLevel ; disable for debugging
    jsr doDrop
    bne DropNew ; A is set to count of how many dropped, loop until no drops

    ; Look to see if we should make the pieces drop quicker
    inc p1PiecesDroppedThisLvl
    lda p1PiecesDroppedThisLvl
    cmp #10
    bne firstPieceToDrop
    dec DELAY
    lda #0
    sta p1PiecesDroppedThisLvl

firstPieceToDrop
    jsr FieldSearch
    jsr UpdateVirusCount

    jsr updateScore
    ldy START_POS ; Start Offset low byte location
    sty piece1
    iny
    sty piece2
    lda START_POS+1 ; Start Offset high byte location
    sta piece1+1
    sta piece2+1

    ldy #$00
    sty ORIENTATION ; reset to 0
    sty CONNECTCNT ; reset to 0
    lda (piece1), y ; See if there is a piece in the way at the top
    cmp #" "
    bne EndGame
    lda (piece2), y ; See if there is a piece in the way at the top
    cmp #" "
    bne EndGame
    lda #PILL_LEFT ; 'o'
    sta (piece1), y ; print new pieces
    lda #PILL_RIGHT
    sta (piece2), y
    jsr NewColors ; Set their new random colors

    lda #00
    sta refreshCount ; refreshCount is at an unknown # after the drops, reset it
    jsr resetInputMovement


;the main game loop
GameLoop
    lda refreshCount
    cmp DELAY
    bcs MoveDownForced
    jsr updateJoyPos
    jmp GameLoop


MoveDownForced
    jsr ZeroCountAndMoveDown
    jmp GameLoop
NextLevel
    jsr updateScore
    inc currentLvl
    jmp printMsg
EndGame
    lda #0
    sta P1_SCORE_B
    sta P1_SCORE_B+1
    sta P1_SCORE_B+2
    sta P1_SCORE_B+3
;    lda #21 ; testing
    sta currentLvl
    jmp printMsg






rotate
        ; Cleared printed pill first
        ldy #$00
        lda #" "
        sta (piece1), y
        sta (piece2), y
        lda ORIENTATION
        beq rotateUnder
        jmp rotateToLeft
rotateUnder
        ; put piece1 where piece2 was, then move piece 1 down one row
        ; Pieces will be vertical after this move

; Is there something above that would get in the way of this rotate?
; If there is nothing below then we can rotate it down, rather than up as usual
; but we have to manually move it down
    sec
    lda piece1
    sbc #40
    sta zpPtr2
    lda piece1+1
    sbc #0
    sta zpPtr2+1
    lda (zpPtr2), y
    cmp #' '
    beq rotateHasRoom
    ; Okay, no room above, but what's below?
    clc
    lda piece1
    adc #40
    sta zpPtr2
    lda piece1+1
    adc #0
    sta zpPtr2+1
    lda (zpPtr2),y
    cmp #' '
    bne RotateFinished ; No room above or below, eject!
    ; put the piece2 under piece1 and inc ORIENTATION
    clc
    lda piece1
    adc #40
    sta piece2
    lda piece1+1
    adc #0
    sta piece2+1
    inc ORIENTATION
    jmp RotateFinished

; Clear to rotate
rotateHasRoom
        inc ORIENTATION
        lda piece1
        sta piece2
        sec
        sbc #40
        sta piece1
        lda piece1+1
        sta piece2+1
        sbc #00
        sta piece1+1
        jmp RotateFinished
rotateToLeft
; Just put them back horizontally and swap the colors
; piece one is on top, return it to the bottom, and move
; piece2 to the right
; Piece2 is currently where we want 1 at
; We'll have to see if this is possible though since there needs to be space to the right of current piece2

; If there is collision to right, but none to left then shift to the left
        ldy #1
        lda (piece2), y
        ldy #0
        cmp #' '
        beq commitRotateToHorizontal ; We're okay just rotate as normal
; There is something on the right !

; What's to the left of the bottom?
        lda piece2
        pha
        lda piece2+1
        pha
        jsr CheckCollisionLeft ; Is there room to the left?
        bne RotateFinished ; there was no room
; Nothing to the left of the bottom, but what about the top?
; Well there could be something to the top, which would fail a move left
; in which case we have to manually rotate and move left so as to not
; clear out the piece to the right
; 1 converted to: <- 1 2
; 2
        lda #' '
        sta (piece1),y
        lda piece2
        sec
        sbc #1
        sta piece1
        lda piece2+1
        sbc #0
        sta piece1+1
        jsr ColorSwap
        lda #00
        sta ORIENTATION
        jmp RotateFinished
commitRotateToHorizontal
        clc
        lda piece2
        sta piece1
        adc #$01
        sta piece2
        lda piece2+1
        sta piece1+1
        adc #$00
        sta piece2+1
        jsr ColorSwap
        lda #$00
        sta ORIENTATION
RotateFinished
        jsr RepaintCurrentColor
        ; print the result
        ldy #$00
lda ORIENTATION
        beq RotateEndHorizontal
        lda #PILL_TOP
        sta (piece1),y
        lda #PILL_BOTTOM
        sta (piece2),y
        rts

RotateEndHorizontal
        lda #PILL_LEFT
        sta (piece1),y
        lda #PILL_RIGHT
        sta (piece2),y
        rts



MoveRightOne
        ldy #$00 ; offset from current char pos
        lda (piece1),y
        sta pSideTmp1
        lda (piece2),y
        sta pSideTmp2
        lda ORIENTATION
        beq MoveRightHorizontalOnly
        lda piece1
        pha
        lda piece1+1
        pha
        jsr CheckCollisionRight
        bne rightMoveDone
MoveRightHorizontalOnly
        lda piece2
        pha
        lda piece2+1
        pha
        jsr CheckCollisionRight
        bne rightMoveDone

; Secondary piece
        ldy #$00
        lda #' '
        sta (piece2), y
        clc
        lda #$01
        adc piece2
        sta piece2
        lda #$00 ; Add any roll over to the high byte
        adc piece2+1
        sta piece2+1
        lda pSideTmp2
        sta (piece2), y
        ; clear pos
        lda #' '
        sta (piece1), y
        ; increment the pointer value by one
        clc
        lda #$01
        adc piece1
        sta piece1
        lda #$00 ; Add any roll over to the high byte
        adc piece1+1
        sta piece1+1
        lda pSideTmp1
        sta (piece1), y
        JSR RepaintCurrentColor
rightMoveDone
        rts






MoveLeftOne
        ldy #$00
        lda (piece1),y
        sta pSideTmp1
        lda (Piece2),y
        sta pSideTmp2
        lda ORIENTATION
        beq MoveLeftHorizontalOnly
        lda piece2
        pha
        lda piece2+1
        pha
        jsr CheckCollisionLeft
        bne leftMoveDone
MoveLeftHorizontalOnly
        lda piece1
        pha
        lda piece1+1
        pha
        jsr CheckCollisionLeft
        bne leftMoveDone ; ? 1

        ; Clear the current pos
        lda #" "
        sta (piece1), y

        ; decrement the pointer value by one
        sec
        lda piece1
        sbc #$01
        sta piece1
        lda piece1+1 ; subtract 0 and any borrow generated above
        sbc #$00
        sta piece1+1
        lda pSideTmp1
        sta (piece1), y
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
        lda pSideTmp2
        sta (piece2), y

        JSR RepaintCurrentColor
leftMoveDone
        rts





ZeroCountAndMoveDown
            ldy #$00
            sty refreshCount
MoveDownOne
            ldy #$00
            lda (piece1),y ; load and store the pill piece types
            sta pSideTmp1
            lda (piece2),y
            sta pSideTmp2
            ; Clear
            lda #" "
            sta (piece1), y
            sta (piece2), y
            lda ORIENTATION
            cmp #$01
            beq checkSecondaryBottom

checkPrimaryBottom
            ; See if we can move down, is something there already??
            lda piece1 ; Copy piece into zpPtr2 for checking
            sta zpPtr2
            pha
            lda piece1+1
            pha
            sta zpPtr2+1

            jsr CheckCollisionBelow
            bne DropNewPiece
            ; Moving piece down first clear value then add 40 to main piece
checkSecondaryBottom
            ; See if we can move down, is something there already??
            lda piece2 ; Copy piece into zpPtr2 for checking
            pha
            lda piece2+1
            pha
            jsr CheckCollisionBelow
            bne DropNewPiece
            ; Moving piece down first clear value then add 40 to main piece
movePrimaryDown ; increment the pointer value by 40, we should check to see that it didn't go over 2024
            clc
            lda #40
            adc piece1
            sta piece1
            lda #$00 ; Add any roll over to the high byte
            adc piece1+1
            sta piece1+1
moveSecondaryDown
            clc
            lda #40
            adc piece2
            sta piece2
            lda #$00 ; Add any roll over to the high byte
            adc piece2+1
            sta piece2+1
            JSR RepaintCurrentColor
MoveComplete
            lda pSideTmp1
            sta (piece1), y
            lda pSideTmp2
            sta (piece2), y
            rts
DropNewPiece
            lda pSideTmp1
            sta (piece1), y
            lda pSideTmp2
            sta (piece2), y
            ; We're not returning, we're just jumping out of here
            ; So remove the return pointer from the stack
            pla
            pla
;

            lda LAST_MOMENT_MOVE
            cmp #0
            beq LastMoveBeforeCommit ; if it's set to zero then do a drop with delay
            ; LAST_MOVE was set to 1
            lda #0
            sta LAST_MOMENT_MOVE
            jmp DropNew
LastMoveBeforeCommit
            lda #1
            sta LAST_MOMENT_MOVE
            jmp GameLoop


CheckCollisionBelow ; Sets a = (ret1>, ret1<, pos>, pos<)
            pla
            sta ret1+1
            pla
            sta ret1
            pla
            sta zpPtr3+1
            pla
            clc
            adc #40
            sta zpPtr3
            lda ret1
            pha
            lda ret1+1
            pha
            ; Look below to see what's there, is it a space?
            lda #$00 ; Add any roll over to the high byte
            tay
            adc zpPtr3+1
            sta zpPtr3+1
            lda (zpPtr3), y
            cmp #" "
            beq noCollitionDetected
            bne collitionDetected
collitionDetected
            lda #$01
            rts
noCollitionDetected
            lda #$00
            rts

CheckCollisionLeft ; a = (ret1>, ret1<, pos>, pos<)
            pla
            sta ret1+1
            pla
            sta ret1

            pla
            sta zpPtr3+1
            pla
            sta zpPtr3

            sec
            lda zpPtr3
            sbc #$01
            sta zpPtr3
            lda zpPtr3+1
            sbc #$00
            sta zpPtr3+1
; Push back return onto stack
            lda ret1
            pha
            lda ret1+1
            pha
            ldy #$00
            lda (zpPtr3), y
;            sta tmp4 ; what, why did I have this here?
            cmp #' '
            beq noCollitionDetectedLeft
collitionDetectedLeft
            lda #$01
            rts
noCollitionDetectedLeft
            lda #$00
            rts


CheckCollisionRight ; a = (ret1>, ret1<, pos>, pos<)
            jmp ccr_start
            ccr_rety    .byte $00
ccr_start
            pla
            sta ret1+1
            pla
            sta ret1
            pla
            sta zpPtr3+1
            pla
            sta zpPtr3
            lda ret1
            pha
            lda ret1+1
            pha
            ldy #1
            lda (zpPtr3), y
            cmp #' '
            beq noCollitionDetectedRight
collitionDetectedRight
            ldy ccr_rety
            lda #$01
            rts
noCollitionDetectedRight
            ldy ccr_rety
            lda #$00
            rts



NewColors
jmp nc_start
    theNewColor1    .byte $00
    theNewColor2    .byte $00
nc_start
    jsr get_random_number
    and #3
    tay
    lda colors, y
    sta theNewColor1
    jsr get_random_number
    and #3
    tay
    beq dontDecY
    dey
    dontDecY
    lda colors, y
    sta theNewColor2
ChangeColor
    ldy #00
    lda piece1_next
    sta zpPtr2
    lda piece1_next+1
    sta zpPtr2+1
    lda #$D4
    clc
    adc zpPtr2+1
    sta zpPtr2+1

    ; Cache current color
    lda (zpPtr2),y
    and #$0f
    sta NextPriC

    lda theNewColor1
    sta (zpPtr2), y
    lda piece2_next
    sta zpPtr2
    lda piece2_next+1
    sta zpPtr2+1
    lda #$D4
    clc
    adc zpPtr2+1
    sta zpPtr2+1
    ; cahce current color
    lda (zpPtr2),y
    and #$0f
    sta NextSecC
    lda theNewColor2
    sta (zpPtr2), y
SwapInOldColor
    lda piece1
    sta zpPtr2
    lda piece1+1
    clc
    adc #$D4
    sta zpPtr2+1

    lda NextPriC
    sta (zpPtr2),y
    sta PRICOLOR

    lda piece2
    sta zpPtr2
    lda piece2+1
    clc
    adc #$D4
    sta zpPtr2+1
    lda NextSecC
    sta (zpPtr2),y
    sta SECCOLOR
    rts

RepaintCurrentColor
    ldy #00
    lda piece1
    sta zpPtr2
    lda piece1+1
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
    rts

;


ColorSwap   lda PRICOLOR
            ldx SECCOLOR
            sta SECCOLOR
            stx PRICOLOR
            jsr RepaintCurrentColor
            rts

; Print Message subrutine
printMsg    lda #$53   ; low byte character location
            STA zpPtr2 ; low byte
            STA zpPtr3 ; temp low byte of color
            lda #$05   ; high byte offset
            sta zpPtr2+1 ; Temp character location
            sta zpPtr3+1 ; Temp color location
            lda #$D4
            clc
            adc zpPtr3+1 ; add to high byte of color to get location
            sta zpPtr3+1

            ldy #$00
printLoop   lda ENDMSG, y
            beq printComplete
            sta (zpPtr2), y
            lda #COLOR_WHITE
            sta (zpPtr3), y
            iny
            jmp printLoop
printComplete
; Pause between end of game and restart
            jsr WaitEventFrame
            jsr WaitEventFrame
            jsr WaitEventFrame
            jsr WaitEventFrame
            jsr WaitEventFrame
            jsr WaitEventFrame
            jsr WaitEventFrame
            jsr WaitEventFrame
RestartGame
            jmp clears




lookForConnect4c ; varray (return>, return<, piece>, piece<)
jmp lfc4_start
            lfc4_ret    .byte $00, $00
            lfc4_y      .byte $00
lfc4_start
            sty lfc4_y
            pla
            sta lfc4_ret+1
            pla
            sta lfc4_ret
            pla
            sta tmp+1 ; piece >
            pla
            sta tmp   ; piece <
            jsr initClearArrays

; Get color of this possition and store it CMPCOLOR
            clc
            lda tmp+1
            adc #$D4
            sta zpPtr3+1
            lda tmp
            sta zpPtr3
            ldy #$00
            lda(zpPtr3),y
            and #$0f
            sta CMPCOLOR


; Look for horizontal block to clear
lookLeft
            sec ; set carry for subtraction
            lda tmp ; piece <
            sbc #$01 ; look to the left
            sta zpPtr2
            lda tmp+1
            sbc #$00 ; piece >
            sta zpPtr2+1
            ldy #$00 ; zp index offset
            lda (zpPtr2), y
            cmp #PILL_SIDE
            beq ll_piece
            cmp #PILL_LEFT
            beq ll_piece
            cmp #PILL_RIGHT
            beq ll_piece
            cmp #PILL_TOP
            beq ll_piece
            cmp #PILL_BOTTOM
            beq ll_piece
            cmp #VIRUS_ONE
            beq ll_piece
            cmp #VIRUS_TWO
            beq ll_piece
            cmp #VIRUS_THREE
            beq ll_piece
            cmp #PILL_CLEAR_1
            beq ll_piece
            jmp lookLeftComplete
            ll_piece
            clc
            lda zpPtr2 ; get color of piece to left to see if it matches
            sta zpPtr3
            lda #$D4
            adc zpPtr2+1
            sta zpPtr3+1
            lda (zpPtr3),y
            and #$0f
            cmp CMPCOLOR
            bne lookLeftComplete
            ; Piece to left is the same color and type
            lda zpPtr2
            sta tmp
            lda zpPtr2+1
            sta tmp+1
            jmp lookLeft
lookLeftComplete
            lda tmp
            sta zpPtr2
            pha
            lda tmp+1
            sta zpPtr2+1
            pha
            jsr pushOntoHarray
lookRight
            clc
            lda #$01
            adc zpPtr2
            sta zpPtr2
            lda #$00
            tay ; init y index to 0
            adc zpPtr2+1
            sta zpPtr2+1
            lda (zpPtr2), y
            cmp #PILL_SIDE
            beq lr_piece
            cmp #PILL_LEFT
            beq lr_piece
            cmp #PILL_RIGHT
            beq lr_piece
            cmp #PILL_TOP
            beq lr_piece
            cmp #PILL_BOTTOM
            beq lr_piece
            cmp #VIRUS_ONE
            beq lr_piece
            cmp #VIRUS_TWO
            beq lr_piece
            cmp #VIRUS_THREE
            beq lr_piece
            cmp #PILL_CLEAR_1
            beq lr_piece


            jmp lookRightDone
            lr_piece
            clc
            lda zpPtr2
            sta zpPtr3
            lda #$D4
            adc zpPtr2+1
            sta zpPtr3+1
            lda (zpPtr3),y
            and #$0f
            cmp CMPCOLOR
            bne lookRightDone
            lda zpPtr2
            pha
            lda zpPtr2+1
            pha
            jsr pushOntoHarray ; void (ret2, ret1, addy2, addy1)
            inc CONNECTCNT
            jmp lookRight ; loop until we've counted them all
lookRightDone


; Look for vertical blocks to clear
lookUp ; start at the top and work my way down
            sec
            lda tmp ; piece
            sbc #40
            sta zpPtr2
            lda tmp+1
            sbc #$00
            sta zpPtr2+1
            ldy #$00 ; index offset for zp load
            lda (zpPtr2),y
            cmp #PILL_SIDE
            beq lu_piece
            cmp #PILL_LEFT
            beq lu_piece
            cmp #PILL_RIGHT
            beq lu_piece
            cmp #PILL_TOP
            beq lu_piece
            cmp #PILL_BOTTOM
            beq lu_piece
            cmp #VIRUS_ONE
            beq lu_piece
            cmp #VIRUS_TWO
            beq lu_piece
            cmp #VIRUS_THREE
            beq lu_piece
            cmp #PILL_CLEAR_1
            beq lu_piece


            jmp lookUpComplete
            lu_piece
            clc
            lda zpPtr2 ; load back in low byte
            sta zpPtr3 ; and copy it over to the color place
            lda #$D4
            adc zpPtr2+1
            sta zpPtr3+1
            lda (zpPtr3),y
            and #$0f
            cmp CMPCOLOR
            bne lookUpComplete
            ; Piece is the same color, and type
            lda zpPtr2
            sta tmp ; make it the active top piece
            lda zpPtr2+1
            sta tmp+1
            jmp lookUp
lookUpComplete
            lda tmp
            sta zpPtr2
            pha
            lda tmp+1
            sta zpPtr2+1
            pha
            jsr pushOntoVarray

lookDown
    clc ; Look for a piece below
    lda #40
    adc zpPtr2
    sta zpPtr2
    lda #$00
    adc zpPtr2+1
    sta zpPtr2+1
    ldy #$00
    lda (zpPtr2), y

    cmp #PILL_SIDE
    beq ld_piece
    cmp #PILL_LEFT
    beq ld_piece
    cmp #PILL_RIGHT
    beq ld_piece
    cmp #PILL_TOP
    beq ld_piece
    cmp #PILL_BOTTOM
    beq ld_piece
    cmp #VIRUS_ONE
    beq ld_piece
    cmp #VIRUS_TWO
    beq ld_piece
    cmp #VIRUS_THREE
    beq ld_piece
    cmp #PILL_CLEAR_1
    beq ld_piece


    jmp lookDownDone
ld_piece
    clc ; Now look for color
    lda zpPtr2
    sta zpPtr3
    lda #$D4
    adc zpPtr2+1
    sta zpPtr3+1
    lda (zpPtr3), y
    and #$0f ; mask out the top part of the byte, it could be garbage
    cmp CMPCOLOR
    bne lookDownDone
    ; put this piece onto the array
    lda zpPtr2 ; Store away low byte
    pha
    lda zpPtr2+1 ; Store away high byte onto stack
    pha
    jsr pushOntoVarray ; void (ret2, ret1, addy2, addy1)
    inc CONNECTCNT
    jmp lookDown ; loop until we've counted them all
lookDownDone
    jsr clearPiecesInArray
    ; put back return address onto stack
    ldy lfc4_y
    lda lfc4_ret
    pha
    lda lfc4_ret+1
    pha
    rts


; Push 16 bit value onto varray
pushOntoVarray ; void (ret2, ret1, addy2, addy1)
    lda varrayIndex
    asl ; multiply * 2
    tax ; copy to x
    pla
    sta ret1+1
    pla
    sta ret1
    pla
    sta varray+1, x
    pla
    sta varray, x
    inc varrayIndex
    ; Return to where we came from
    lda ret1
    pha
    lda ret1+1
    pha
    rts

pushOntoHarray ; void (ret2, ret1, addy2, addy1)
    lda harrayIndex
    asl ; multiply * 2
    tax ; copy to x
    pla
    sta ret1+1
    pla
    sta ret1
    pla
    sta harray+1, x
    pla
    sta harray, x
    inc harrayIndex
    ; Return to where we came from
    lda ret1
    pha
    lda ret1+1
    pha
    rts

finishedClearingVJmp ; closer jump to the bcc right below
    jmp finishedClearingV
; Clears both vertical and horizontal entries in their respecitve
; arrays if there are more than 4 entries in one of them.
clearPiecesInArray ; void ()
            jmp cpia_start
            cpia_pieceTmp   .byte $00, $00
cpia_start
            ; see if there are more than 3 values in here
            lda varrayIndex
            cmp #04
            bcc finishedClearingVJmp ; >= 4
            ldx #$00 ; varray indexing * 2
            stx tmp
clearingLoop
            lda varray, x
            sta zpPtr4
            sta cpia_pieceTmp
            lda varray+1, x
            sta zpPtr4+1
            sta cpia_pieceTmp+1
            inx
            inx
            inc tmp

; Look around to convert surounding pieces to independent cells if we can
cl_whatsToTheRight
            ldy #$01
            lda (zpPtr4),y
            cmp #PILL_RIGHT
            bne cl_whatsOnBottom
            lda #PILL_SIDE
            sta (zpPtr4),y
cl_whatsOnBottom
            ; What's below, y = 40
            ldy #40
            lda (zpPtr4),y
            cmp #PILL_BOTTOM
            bne cl_whatsOnTop
            lda #PILL_SIDE
            sta (zpPtr4),y
cl_whatsOnTop
            ldy #00
            sec
            lda zpPtr4
            sbc #40
            sta zpPtr4
            lda zpPtr4+1
            sbc #00
            sta zpPtr4+1
            lda (zpPtr4),y
            cmp #PILL_TOP
            bne cl_whatsToTheLeft
            lda #PILL_SIDE
            sta (zpPtr4),y
cl_whatsToTheLeft
            ; we are now on top of the original piece, and want to look
            ; to the bottom one and to the left, so +39 y offset will do
            ldy #39
            lda (zpPtr4),y
            cmp #PILL_LEFT
            bne cl_SideManipulationComplete
            ; It was a left piece, let's convert it to a PILL_SIDE
            lda #PILL_SIDE
            sta (zpPtr4),y
; Finished looking around
cl_SideManipulationComplete
            ldy #$00
            ; restore zpPtr4
            lda cpia_pieceTmp
            sta zpPtr4
            lda cpia_pieceTmp+1
            sta zpPtr4+1

            ; Animation for clearning of pieces, one piece at a time
            lda #PILL_CLEAR_1
            sta (zpPtr4), y
            dey ; set it back to 0
            lda tmp
            cmp varrayIndex
            bne clearingLoop
finishedClearingV
            jmp ClearH
ClearHFinished ; another exit because our previous branch was too far
            rts
ClearH
            ;
            ; Clear H array if we need to
            lda harrayIndex
            cmp #04
;            bcc finishedClearingH
            bcc ClearHFinished
            ldx #$00 ; h array indexing * 2
            ldy #$00 ; zero page indexing, leave as 0
            sty tmp  ; h array indexing by 1
hclearingLoop
            lda harray, x
            sta zpPtr4
            sta cpia_pieceTmp
            lda harray+1, x
            sta zpPtr4+1
            sta cpia_pieceTmp+1
            inx
            inx
            inc tmp

; Look all around to see if we need to convert
; some sides into cell pieces while doing our Horizontal clearing
clh_whatsToTheRight
            ldy #$01
            lda (zpPtr4),y
            cmp #PILL_RIGHT
            bne clh_whatsOnBottom
            lda #PILL_SIDE
            sta (zpPtr4),y
clh_whatsOnBottom
            ; What's below, y = 40
            ldy #40
            lda (zpPtr4),y
            cmp #PILL_BOTTOM
            bne clh_whatsOnTop
            lda #PILL_SIDE
            sta (zpPtr4),y
clh_whatsOnTop
            ldy #00
            sec
            lda zpPtr4
            sbc #40
            sta zpPtr4
            lda zpPtr4+1
            sbc #00
            sta zpPtr4+1
            lda (zpPtr4),y
            cmp #PILL_TOP
            bne clh_whatsToTheLeft
            lda #PILL_SIDE
            sta (zpPtr4),y
clh_whatsToTheLeft
            ; we are now on top of the original piece, and want to look
            ; to the bottom one and to the left, so +39 y offset will do
            ldy #39
            lda (zpPtr4),y
            cmp #PILL_LEFT
            bne clh_SideManipulationComplete
            ; It was a left piece, let's convert it to a PILL_SIDE
            lda #PILL_SIDE
            sta (zpPtr4),y

; Finished looking around
clh_SideManipulationComplete
            ldy #$00
            lda cpia_pieceTmp
            sta zpPtr4
            lda cpia_pieceTmp+1
            sta zpPtr4+1
            lda #PILL_CLEAR_1
            sta (zpPtr4), y
            lda tmp
            cmp harrayIndex
            bne hclearingLoop
finishedClearingH
            rts





; Zeros out the vertical clear array
initClearArrays
            ldx #17 ; 8 x 2 bytes is how large it can be
            lda #$00
            sta varrayIndex
            sta harrayIndex
initClearArrayLoop
            sta varray, x
            sta harray, x
            dex
            beq clearArraysDone ; check for x != 0
            jmp initClearArrayLoop
clearArraysDone
            rts



;
; Loop through the entire playing field and find connect 4's
;
lookForAnyConnect4s
        ldy #$00
        sty TMP1 ; used as a screen y offset, 0 - 15
        sty tmp2 ; used as a screen x offset, 0 - 7
        lda #OnePGameFieldLocLow ; start <
;        lda #$0f
        sta zpPtr1
        lda #OnePGameFieldLocHigh ; start >
;        lda #$04
        sta zpPtr1+1
connectsOuterLoop
        lda tmp2 ; what's the current x offset?
        cmp #8
        beq anyConnectDone
        clc
        lda zpPtr1
        adc #$01
        sta zpPtr1
        sta zpPtr4
        lda #$00
        sta tmp1 ; reset inner loop
        adc zpPtr1+1
        sta zpPtr1+1
        sta zpPtr4+1
anyConnectInnerLoop
        lda tmp1  ; y offset
        cmp #16
        beq anyConnectInnerLoopDone
        lda (zpPtr4),y
        ; Tried writing this as a subroutine, it's corrupting the stack though :-(
        cmp #VIRUS_ONE
        beq lfac4_piece
        cmp #VIRUS_TWO
        beq lfac4_piece
        cmp #VIRUS_THREE
        beq lfac4_piece
        cmp #PILL_SIDE
        beq lfac4_piece
        cmp #PILL_LEFT
        beq lfac4_piece
        cmp #PILL_RIGHT
        beq lfac4_piece
        cmp #PILL_TOP
        beq lfac4_piece
        cmp #PILL_BOTTOM
        beq lfac4_piece
        cmp #PILL_CLEAR_1
        beq lfac4_piece
        jmp nextConnectAnyRow
lfac4_piece
        lda zpPtr4
        pha
        lda zpPtr4+1
        pha
        jsr lookForConnect4c
nextConnectAnyRow
        inc tmp1
        clc
        lda zpPtr4
        adc #40
        sta zpPtr4
        lda #$00
        adc zpPtr4+1
        sta zpPtr4+1
        jmp anyConnectInnerLoop
anyConnectInnerLoopDone
        inc tmp2
        jmp connectsOuterLoop
anyConnectDone
        rts


FieldSearch
    jmp fs_start
    fs_outLoopIdx   .byte $00
    fs_innerLoopIdx .byte $0f
    fs_didWorkThisLoop  .byte $00
    fs_didWorkReturn    .byte $00
fs_start
    lda #$00
    sta fs_didWorkReturn ; to be returned as the count of drops that occured
fs_Continue ; a = void()
    lda #$10 ; #0f wasn't enough
    sta fs_innerLoopIdx  ; used as screen y offset, 0 - 15
    ldy #$00
    sty fs_didWorkThisLoop      ; used to keep track if anything dropped, shared with dropDownIfYouCan
    sty fs_outLoopIdx   ; used as screen x index 0 - 7
    sty p1VirusCount ; reset our virus count for player one
    sty p1VirusCountBinNew


; Bottom left pos is +$0280 from top left game field
; In bottom left wall corner
clc
lda #OnePGameFieldLocLow
adc #$80
sta zpPtr1
lda #OnePGameFieldLocHigh
adc #$02
sta zpPtr1+1

fs_dropOuterLoop
    lda fs_outLoopIdx
    cmp #8
    beq fs_done

    ; Move one right
    clc
    lda zpPtr1
    adc #$01
    sta zpPtr1
    sta zpPtr2
    lda #$00
    adc zpPtr1+1
    sta zpPtr1+1
    sta zpPtr2+1
    lda #$11 ; $0f wasn't enough
    sta fs_innerLoopIdx ; reset inner loop index

fs_dropInnerLoop
    lda fs_innerLoopIdx
    beq fs_dropInnerLoopComplete
    sec
    lda zpPtr2
    sbc #40
    sta zpPtr2
    lda zpPtr2+1
    sbc #$00
    sta zpPtr2+1
    lda (zpPtr2),y

    ; Look for viruses for total
    cmp #VIRUS_ONE
    beq itIsAVirus
    cmp #VIRUS_TWO
    beq itIsAVirus
    cmp #VIRUS_THREE
    bne notAVirus
itIsAVirus
    ; It is a virus
    sed ; go into decimal mode
    clc
    lda #1
    adc p1VirusCount
    sta p1VirusCount
    cld ; back to binary math
    inc p1VirusCountBinNew
    lda (zpPtr2),y ; reload in what we are comparing
notAVirus
    cmp #PILL_CLEAR_1
    bne fs_nextCharType
    inc fs_didWorkThisLoop
; This is where we'd sleep before
    lda #PILL_CLEAR_2
    sta (zpPtr2),y
    jmp fs_nextRow

fs_nextCharType
    cmp #PILL_CLEAR_2
    bne fs_nextRow
    inc fs_didWorkReturn
    lda #' '
    sta (zpPtr2),y
fs_nextRow
    dec fs_innerLoopIdx
    jmp fs_dropInnerLoop
fs_dropInnerLoopComplete
    inc fs_outLoopIdx
    jmp fs_dropOuterLoop
fs_done
    lda fs_didWorkThisLoop
    beq fs_reallyDone
fs_doMoreWork
    jsr WaitEventFrame ; Wait between clearing animation
    jmp fs_Continue ; if there were any dropped this last time, see if there were any left
fs_reallyDone
    lda fs_didWorkReturn
rts

UpdateVirusCount
    ldy #0
    lda #$6f
    sta zpPtr2
    lda #$05
    sta zpPtr2+1
    ldx p1VirusCount
    txa
    and #$f0
    lsr ; Shift over 4 times
    lsr
    lsr
    lsr
    ora #$30
    sta (zpPtr2),y
    iny
    txa
    and #$0f
    ora #$30
    sta (zpPtr2),y
    rts


; score is made up of 4 bytes of decimal numbers
updateScore
    ; See if there is any difference between the last virus count and the new one
    lda p1VirusCountBinLast
    cmp p1VirusCountBinNew
    bne us_continue ; There was something cleared
;    ldx #1
;    lda #0
;    tax
;    sta scoreMultiplierTmp
;    sta scoreMultiplierTmp+1
;    sta scoreMultiplierTmp+2
;    sta scoreMultiplierTmp+3
    jmp printCurrentScoreWithNoChange
us_continue
    sec
    sbc p1VirusCountBinNew
    tax ; x contains the difference

    ; Make the new count the current one now
    lda p1VirusCountBinNew
    sta p1VirusCountBinLast

    ; Add the points up
scoreLoop
    lda VIRUS_MUL_1
    sta scoreMultiplierTmp
    lda VIRUS_MUL_1+1
    sta scoreMultiplierTmp+1
    lda #0
    sta scoreMultiplierTmp+2
    sta scoreMultiplierTmp+3
    stx tmp ; store how many times to shift to the left

multiplierLoop
    dec tmp
    beq multiplierDone

lda #0
sta carryWasSet
    clc
    asl scoreMultiplierTmp
    bcc firstNoCarry
    lda #1
    sta carryWasSet
firstNoCarry
    clc
    asl scoreMultiplierTmp+1
    lda carryWasSet
    ora scoreMultiplierTmp+1
    sta scoreMultiplierTmp+1
    lda #0
    sta carryWasSet
    bcc secondNoCarry
    lda #1
    sta carryWasSet
secondNoCarry
    clc
    asl scoreMultiplierTmp+2
    lda carryWasSet
    ora scoreMultiplierTmp+2
    sta scoreMultiplierTmp+2
    lda #0
    sta carryWasSet
    bcc thirdNoCarry
    lda #1
    sta carryWasSet
thirdNoCarry
    clc
    asl scoreMultiplierTmp+2
    lda carryWasSet
    ora scoreMultiplierTmp+2
    sta scoreMultiplierTmp+2

    jmp multiplierLoop


multiplierDone
    clc
    lda P1_SCORE_B
    adc scoreMultiplierTmp
    sta P1_SCORE_B
    sta P1_SCORE_B_COPY

    lda P1_SCORE_B+1
    adc scoreMultiplierTmp+1
    sta P1_SCORE_B+1
    sta P1_SCORE_B_COPY+1

    lda P1_SCORE_B+2
    adc scoreMultiplierTmp+2
    sta P1_SCORE_B+2
    sta P1_SCORE_B_COPY+2

    lda P1_SCORE_B+3
    adc scoreMultiplierTmp+3
    sta P1_SCORE_B+3
    sta P1_SCORE_B_COPY+3

    dex
    beq printCurrentScore
    jmp scoreLoop


printCurrentScoreWithNoChange
    lda P1_SCORE_B
    sta P1_SCORE_B_COPY
    lda P1_SCORE_B+1
    sta P1_SCORE_B_COPY+1
    lda P1_SCORE_B+2
    sta P1_SCORE_B_COPY+2
    lda P1_SCORE_B+3
    sta P1_SCORE_B_COPY+3
printCurrentScore
    jsr convertP1ScoreToDecimal
    ldy #$00
    lda #$94
    sta zpPtr2
    lda #$04
    sta zpPtr2+1

    ldx #8
l2
    lda P1_SCORE,x
    ora #$30
    sta (zpPtr2),y
    iny
    dex
    bpl l2
scoreUpdateComplete
    rts

scoreMultiplierTmp .byte $00, $00, $00, $00
carryWasSet            .byte $00


