.org $0801
;Tells BASIC to run SYS 2064 to start our program
;.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00
;
; - - Master Memory Layout - -
; $0400 - $07e8 screen memory, but we clear $0400 - $0800 for ease
; $0801 - $220c main game
; $3000 - $37FF Temp working sprite area, possibly?
; $3800 - $3FFF Character RAM
; $8000 - $8f36 SID
; $9000 - $9614 Game Data, worldmap, clearing sprite numbers, text (2540 bytes free)
; $a000 - $b000 Sprite data - original location
; $D000 - $DFFF VIC/SID/CIA/IO registers
;  $D800 - $DBFF Reserved Color ram

; $A000 - $BFFF BASIC ROM
; $E000 - $FFFF KERNEL ROM


; - - Monitor Help - -
; VICE Monitor Label File Loading: load_labels "/Users/Tony/Development/DrC64/labels.txt"
;  show_labels
;  m H .piece2 .piece2
;  m H .varrayindex .varrayindex
;  watch store .varrayindex
;  watch store .varrayindex .varrayindex
;  break .brkhere
;  d $0fdd $0fff
;  return

SCREENMEM       .equ $0400 ; Start of character screen map, color map is + $D400
COLORMEM        .equ $D800
VMEM            .equ $D000
SCREEN_BORDER   .equ VMEM + 32
SCREEN_BG_COLOR .equ VMEM + 33
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
VIRUS_ANI_DELAY .equ 7

; Some on screen character mappings
BACKGROUND_CHAR .equ 64

WALL_CHAR_TRT   .equ 107
WALL_CHAR_TLFT  .equ 106
WALL_CHAR_TOP   .equ 104
WALL_B          .equ 104
WALL_BL         .equ 103
WALL_BR         .equ 102
WALL_SIDES      .equ 105

VIRUS_ONE       .equ 75
VIRUS_TWO       .equ 79
VIRUS_THREE     .equ 83

PILL_CLEAR_1    .equ 87
PILL_CLEAR_2    .equ 90  ; Blink
PILL_CLEAR_3    .equ 89

PILL_LEFT       .equ 65
PILL_RIGHT      .equ 66
PILL_LEFT_D     .equ 67
PILL_RIGHT_D    .equ 68
PILL_TOP        .equ 69
PILL_BOTTOM     .equ 70
PILL_TOP_D      .equ 71
PILL_BOTTOM_D   .equ 72
PILL_SIDE       .equ 73 ; 'o'

CLEAR_CHAR      .equ 32 ; Space char

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
ORIENTATION .byte $00 ; 0 = 12, 1 = 1
                      ;             2
PRICOLOR    .byte $00
SECCOLOR    .byte $00
NextPriC    .byte $00
NextSecC    .byte $00
CMPCOLOR    .byte $00 ; tmp for comparing variable colors
CONNECTCNT  .byte $00
START_POS   .byte $0, $0 ; gets overwritten
LAST_MOMENT_MOVE    .byte $00

vOneCount   .byte $00
vTwoCount   .byte $00
vThreeCount .byte $00

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
DELAY       .byte 0
pSideTmp1   .byte $00
pSideTmp2   .byte $00
p1VirusCount    .byte $00
p1VirusClearedInOneTurn  .byte $00

p1VirusCountBinLast .byte $00
p1VirusCountBinNew  .byte $00

P1_SCORE    .byte 0,0,0,0,0,0,0,0,0,0 ; 
P1_SCORE_B  .byte $00, $00, $00, $00 ; Binary value of current score
VIRUS_MUL_1 .byte $64, $00 ; 100
VIRUS_CHAR_LIST .byte VIRUS_ONE, VIRUS_TWO, VIRUS_THREE
colors      .byte COLOR_CYAN, COLOR_L_BLUE, COLOR_YELLOW, COLOR_L_BLUE ; Get overwritten by changeColorSet if run
gameInPlay  .byte 0 ; Set to 1 if game is in play


init
    jsr initRefreshCounter
    jsr setUpVirusAnimationSequences ; This also sets VIC to know where custom char data is at
    jsr initPillStartLocation
    jsr initScorePopUpSprites
levelScreen
    ; Disable all sprites
    lda #0
    sta $d015
    ; Set screen color
    sta SCREEN_BG_COLOR
    sta SCREEN_BORDER

    jsr doTheChatRoom
    jsr printLevelSelectScreen
clears ; Run at beginning of new level/game
    inc gameInPlay ; set game in play mode by setting it to none 0
    ; Programatically create game layout
    lda #BACKGROUND_CHAR
    sta clearingChar ; Set clearing character
    jsr ClearScreen
    jsr DrawGameBorder
;    jsr changeColorSet
    jsr printSinglePlayerNextPieceBox
    jsr printSinglePlayerScoreBox
    jsr printSinglePlayerVirusCountBox
    jsr printSinglePlayerLevelBox
    jsr printVirusContainerBox
    jsr printPlayerContainerBox
    jsr putVirusesOnTheField
    jsr FieldSearch ; Tally up the virus count, so it can be printed, finish clearing
    jsr printCurrentScore

    lda p1VirusCountBinNew
    sta p1VirusCountBinLast

    ; Reset drop speed for the game, for this level
    lda #delay_slow
    sta DELAY
    lda #15
    sta SID_VOLUME
    lda #1
    sta playMusic
    lda #1 ; Play song 2
    jsr songStartAdress
    lda #15
    jsr songStartAdress+9
    jsr initZombieSprites
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
    jsr incrementPillUsedP1
firstPieceToDrop
    jsr FieldSearch
    jsr shouldWeDisableAFace
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
    sty refreshCount ; refreshCount is at an unknown # after the drops, reset it
    sty virusesClearedForPopUpScore ; reset this value to 0
    lda (piece1), y ; See if there is a piece in the way at the top
    cmp #CLEAR_CHAR
    beq notEndGame
    jmp EndGame
notEndGame
    lda (piece2), y ; See if there is a piece in the way at the top
    cmp #CLEAR_CHAR
    beq notEndGame2
    jmp EndGame
notEndGame2
    lda #PILL_LEFT
    sta (piece1), y ; print new pieces
    lda #PILL_RIGHT
    sta (piece2), y
    jsr NewColors ; Set their new random colors
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
    lda #0
    sta faceSpriteEnableMask ; Disable all virus sprite faces
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
holdTextOnScreen
    lda JOY2
    and #JOY_BIT_FIRE
    beq GotButtonPress2
    jmp holdTextOnScreen
GotButtonPress2
    jmp clears
EndGame
    lda #0
    sta faceSpriteEnableMask ; Disable all virus sprite faces
    sta gameInPlay
    sta SID_VOLUME
    jsr songStartAdress+9 ; turn volume to 0
    sta playMusic ; stop laying music
    jmp levelScreen


