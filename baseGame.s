.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00
;
; - - Master Memory Layout - -
; $0801 - $5200 main game ; Bitmap starts at $229b - ~$49aB
; $3000 - $3800 Custom Character RAM ?????? OVERLAPPING
; $4000 - $4200 Sprite data
; $5C00 - $5FFF Screen ram
; $6000 - $7F3F Bitmap
; $8000 - $876b SID
; $D800 - $DBFF Color ram
; Need 512bytes free which is $200


SCREENMEM   .equ 1024 ; Start of character screen map, color map is + $D400
COLORMEM    .equ $D800
VMEM        .equ $D000

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
SCREEN_BORDER   .equ VIC_MEM + 32
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
delay_slow      .equ 37

WALL_B          .equ 68
WALL_BL         .equ 74
WALL_BR         .equ 75
PILL_SIDE       .equ 81 ; 'o'
VIRUS_ONE       .equ 83
VIRUS_TWO       .equ 84
VIRUS_THREE     .equ 85
PILL_CLEAR_1    .equ 86
PILL_CLEAR_2    .equ 90
PILL_CLEAR_3    .equ 91
WALL_SIDES      .equ 102
PILL_LEFT       .equ 107
PILL_LEFT_D     .equ 108
PILL_TOP_D      .equ 111
PILL_BOTTOM     .equ 113
PILL_TOP        .equ 114
PILL_RIGHT      .equ 115
PILL_RIGHT_D    .equ 116
PILL_BOTTOM_D   .equ 117

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

zpPtr5          .equ $c0


jmp init

; Some global vars
ENDMSG      .byte 5,14,4,0
MSG_NEXT    .byte 14,5,24,20,0
MSG_VIRUS   .byte 22,9,18,21,19,0
MSG_SCORE   .byte 19, 3, 15, 18, 5, 0
MSG_LEVEL   .byte 12,5,22,5,12,0
MSG_CLEAR   .byte 3,12,5,1,18,33,0
ORIENTATION .byte $00 ; 0 = 12, 1 = 1
                      ;             2
PRICOLOR    .byte $00
SECCOLOR    .byte $00
NextPriC    .byte $00
NextSecC    .byte $00
CMPCOLOR    .byte $00 ; tmp for comparing variable colors
CONNECTCNT  .byte $00
;colors      .byte COLOR_RED, COLOR_BLUE, COLOR_YELLOW, COLOR_BLUE
colors      .byte COLOR_CYAN, COLOR_MAGENTA, COLOR_YELLOW, COLOR_MAGENTA

START_POS   .byte $13, $04 ; gets overwritten
LAST_MOMENT_MOVE    .byte $00
VIRUS_CHAR_LIST .byte VIRUS_ONE, VIRUS_TWO, VIRUS_THREE
vOneCount   .byte $00
vTwoCount   .byte $00
vThreeCount .byte $00

varray      .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
varrayIndex .byte $00
harray      .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
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

P1_SCORE    .byte 0,0,0,0,0,0,0,0,0,0 ; 
P1_SCORE_B  .byte $00, $00, $00, $00 ; Binary value of current score
VIRUS_MUL_1 .byte $64, $00 ; 100



init

    jsr setupScreenForSpashScreen
    jsr startHSpriteScroller
    ; Look for button press
    jsr MoveCharMap
    jsr init_irq
splashLoop
    ; H MSG Movement
    jsr copySpriteDataIn
    jsr moveSpritesLeft
    inc msgOffset
    ; End H MSG
    lda JOY1
    and #16
    beq GotButtonPress
    jmp splashLoop
GotButtonPress
; disable all of the sprites
lda #0
sta $d015
sta SPRITE_DB_H

; Taking too many joystick button inputs turn it off for a moment
    lda #1
    sta turnInputOff

    jsr returnScreenBackFromSpash

    jsr MoveCharMap
    jsr initRefreshCounter
    ; Init START_POS for where pill drops from, 4 to the right of left border
    clc
    lda #OnePGameFieldLocLow
    adc #4
    sta START_POS
    lda #OnePGameFieldLocHigh
    adc #0
    sta START_POS+1

    ldy #0
    sty SCREEN_BG_COLOR
    sty SCREEN_BORDER
    ; init the pop over sprite. Initially clear the whole sprite, after that we only use the first 5 lines
    lda #63
    sta bytesToClearForSprite
    jsr clearScoreSprite
    lda #15 ; 5 * 3 bytes only need to be cleared
    sta bytesToClearForSprite
levelScreen
;jsr printLevelSelectScreen
lda #0
sta currentLvl
clears
    ; Programatically create game layout
    jsr ClearScreen
    jsr DrawGameBorder
    jsr changeColorSet
    jsr printSinglePlayerNextPieceBox
    jsr printSinglePlayerScoreBox
    jsr printSinglePlayerVirusCountBox
    jsr printSinglePlayerLevelBox
    jsr printQuickZombieInBox
    jsr putVirusesOnTheField
    jsr FieldSearch ; Tally up the virus count, so it can be printed, finish clearing
    jsr printCurrentScore


    lda p1VirusCountBinNew
    sta p1VirusCountBinLast

    ; Reset drop speed for the game, or this level
    lda #delay_slow
    sta DELAY
    lda #15
    sta SID_VOLUME
    lda #1
    sta playMusic
    lda #0
    jsr songStartAdress
    lda #15
    jsr songStartAdress+9
    jmp firstPieceToDrop
DropNew
    ; Loop through every piece to see if they can be cleared
    jsr lookForAnyConnect4s
    jsr FieldSearch
    jsr ClearTopLine
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
    sty virusesClearedForPopUpScore ; reset this value to 0
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
    inc currentLvl ; Twice ?
    lda #<MSG_CLEAR
    pha
    lda #>MSG_CLEAR
    pha

    lda #$51
    pha
    lda #$05
    pha
    jsr printMsgSub
    ; Stop playing music
    lda #0
sta SID_VOLUME
    sta playMusic
    jsr songStartAdress+9 ; set volume 0
    jsr hideTopSprites
    jsr vScrollScreenOff
    jsr WaitEventFrame
    jsr WaitEventFrame
    jsr WaitEventFrame
    jsr WaitEventFrame
    jsr WaitEventFrame
    jsr WaitEventFrame
    jsr WaitEventFrame
    jsr WaitEventFrame
    jsr WaitEventFrame
    jsr WaitEventFrame

    jmp clears

EndGame
    lda #0
    sta SID_VOLUME
    jsr songStartAdress+9 ; turn volume to 0
    sta playMusic ; stop laying music

; Debug
    sta P1_SCORE_B
lda #19
    sta P1_SCORE_B+1
lda #0
    sta P1_SCORE_B+2
    sta P1_SCORE_B+3
;    lda #21 ; testing
;    sta currentLvl
    jmp printMsg









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
            jsr hideTopSprites
            jmp levelScreen






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

    ; Look for viruses for total Vertical
    lda (zpPtr4), y
    cmp #VIRUS_ONE
    beq cl_itIsAVirus
    cmp #VIRUS_TWO
    beq cl_itIsAVirus
    cmp #VIRUS_THREE
    bne cl_storeValue ; not a virus
cl_itIsAVirus
    inc flashTimes
stx posOffsetXY
sty posOffsetXY+1
; Play noise
lda #<SOUND_CLEAR
ldy #>SOUND_CLEAR
ldx #14 ; channel 3
jsr songStartAdress+6
ldx posOffsetXY
ldy posOffsetXY+1

    inc virusesClearedForPopUpScore
    lda zpPtr4
    sta placeScoreHere
    lda zpPtr4+1
    sta placeScoreHere+1
    jsr SetSpriteBasedOnCharPos
cl_storeValue
    lda #PILL_CLEAR_1
    sta (zpPtr4), y
    dey ; set it back to 0
    lda tmp
    cmp varrayIndex
    beq cl_noclearingLoop
    jmp clearingLoop
cl_noclearingLoop
finishedClearingV
            jmp ClearH
ClearHFinished ; another exit because our previous branch was too far
            rts
ClearH
            ;
            ; Clear H array if we need to
            lda harrayIndex
            cmp #04
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
; Clearing a piece for this pill drop
lda (zpPtr4), y
cmp #VIRUS_ONE
beq cl_itIsAVirus_2
cmp #VIRUS_TWO
beq cl_itIsAVirus_2
cmp #VIRUS_THREE
bne cl_storeValue_2 ; not a virus
cl_itIsAVirus_2
inc flashTimes

stx posOffsetXY
sty posOffsetXY+1
; Play noise
lda #<SOUND_CLEAR
ldy #>SOUND_CLEAR
ldx #14 ; channel 3
jsr songStartAdress+6
ldx posOffsetXY
ldy posOffsetXY+1


inc virusesClearedForPopUpScore
lda zpPtr4
sta placeScoreHere
lda zpPtr4+1
sta placeScoreHere+1
jsr SetSpriteBasedOnCharPos
cl_storeValue_2
;

    lda #PILL_CLEAR_1
    sta (zpPtr4), y
    lda tmp
    cmp harrayIndex
    beq finishedClearingH
    jmp hclearingLoop
finishedClearingH
            rts
posOffsetXY .byte $00, $00





; Zeros out the vertical clear array
initClearArrays
            ldx #21 ; 10 x 2 bytes is how large it can be
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



