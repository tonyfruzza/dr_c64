JOY2            .equ 56320
VIC_MEM         .equ 53248
SCREEN_BACKGRND .equ VIC_MEM + 33
SCREEN_BORDER   .equ VIC_MEM + 32
SCREENMEM       .equ 1024
SPRITE_DATA_LOC .equ $3000
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
GAME_STATE_PLAY .equ 0
GAME_STATE_NEW  .equ 1
GAME_STATE_END  .equ 2
PUCK_START_X    .equ 135
PUCK_START_Y    .equ 140
TRAJ_RIGHT      .equ $01
TRAJ_DOWN       .equ $02
TRAJ_LEFT       .equ $04
TRAJ_UP         .equ $08
TRAJ_DR         .equ $10
TRAJ_DL         .equ $20
TRAJ_UL         .equ $40
TRAJ_UR         .equ $80

.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00

init
    lda #COLOR_DARK_GREY
    sta SCREEN_BACKGRND
    lda #COLOR_BLACK
    sta SCREEN_BORDER
    ; Reset sprite collision tracking (BLACK is 0)
    sta $D01E
    sta $d01F

    jsr ClearScreen
    jsr copySpriteDataIn
; Let VIC know where sprite 0 data is located
    lda #$C0 ; $3000/$40 =  $C0
    sta $07f8 ; paddle
    sta $07f9 ; paddle
    sta $07fa ; paddle
    sta $07fb ; puck

    ; Set Sprite colors
    lda #COLOR_WHITE
    sta VIC_MEM+39
    sta VIC_MEM+40
    sta VIC_MEM+41
    lda #COLOR_RED
    sta VIC_MEM+42
    ; Enable Sprite 1, 2, 3, 4
    lda #%00001111
    sta $d015

; Set  Init location of puck
    jsr initPuckLocation
    jsr initInterupt
    jsr resetAndPrintScore

mainGameLoop
    ; All is done in the V blank :-)
    jmp mainGameLoop

copySpriteDataIn
    ldx #63
csdi_loop
    dex
    lda CUST_SPRITE_0, x
    sta SPRITE_DATA_LOC, x
    txa
    bne csdi_loop
    rts

moveSpriteAround
    ldx paddlePos
mspa_loop
    lda xlist, x
    cmp #$ff ; back end
    bne loadWithoutReset0
    ldx #1 ; xlist data starts at 1
    lda xlist, x
loadWithoutReset0
    cmp #$fe ; front end
    bne loadWithoutFrontReset0
    ldx xlist_count
    lda xlist, x
loadWithoutFrontReset0
    ; Set location of sprite 0
    sta $d000
    lda ylist, x
    sta $d001
	; Set location of sprite 1
    txa
    tay
    iny
    lda xlist, y
    cmp #$ff
    bne loadWithoutReset1
    ldy #1
    lda xlist, y
loadWithoutReset1
    cmp #$fe ; front end
    bne loadWithoutFrontReset1
    ldy xlist_count
    lda xlist, y
loadWithoutFrontReset1
    sta $d002
    lda ylist, y
    sta $d003
    ; Set location of sprite 2
    iny
    lda xlist, y
    cmp #$ff
    bne loadWithoutReset2
    ldy #1
    lda xlist, y
loadWithoutReset2
    cmp #$fe ; front end
    bne loadWithoutFrontReset2
    ldy xlist_count
    lda xlist, y
loadWithoutFrontReset2
    sta $d004
    lda ylist, y
    sta $d005
    stx paddlePos ; Save pos
    rts
paddlePos       .byte $01


int1
    jsr checkBoundsOfPuck
    ; Read sprite collision for #4 and then reset it
    lda $D01E
    and #%00001000
    beq screen_int
    ; Sprite to sprite collision occured, figure out what
    jsr setTrajectoryBasedOnPaddle
    lda #COLOR_BLACK
    sta $d01e ; Clear collision data so that we can read it again, BLACK is 0
    sta VIC_MEM+42
    sta puckColor
screen_int
    jsr updateJoyPos
    jsr moveSpriteAround
    jsr movePuckInTraj
    lda puckColor
    cmp #COLOR_BLACK
    bne noColorChangeNeeded0
    lda #COLOR_WHITE
    sta VIC_MEM+42
    sta puckColor
    jmp noColorChangeNeeded2
noColorChangeNeeded0
    cmp #COLOR_WHITE
    bne noColorChangeNeeded1
    lda #COLOR_YELLOW
    sta VIC_MEM+42
    sta puckColor
    jmp noColorChangeNeeded2
noColorChangeNeeded1
    cmp #COLOR_YELLOW
    bne noColorChangeNeeded2
    lda #COLOR_RED
    sta VIC_MEM+42
    sta puckColor
    jsr incScoreAndPrint
noColorChangeNeeded2
    ; Restore values back from stack
    asl $d019    ; ACK interrupt (to re-enable it)
    pla
    tay
    pla
    tax
    pla
    cli ; Turn back on the interupt
    rti          ; return from interrupt
;jmp $ea31

initInterupt
    sei          ; turn off interrupts
    lda #$7f
    ldx #%00000001
    sta $dc0d    ; Turn off CIA 1 interrupts
    sta $dd0d    ; Turn off CIA 2 interrupts
    stx $d01a    ; Turn on raster interrupts, and sprite to sprite ints
    lda $d011
    ora $40
    sta $d011     ; Turn on bit 7
    sta $d011     ; Clear high bit of $d012, set text mode
    lda #<int1    ; low part of address of interrupt handler code
    ldx #>int1    ; high part of address of interrupt handler code
    ldy #0        ; raster line to trigger interrupt
    sta $0314     ; store in interrupt vector
    stx $0315
    sty $d012

    lda $dc0d    ; ACK CIA 1 interrupts
    lda $dd0d    ; ACK CIA 2 interrupts
    lda #0
    sta $d019
    ;asl $d019    ; ACK VIC interrupts
    cli          ; turn interrupts back on
    rts

; Manipulate paddlePos directly
updateJoyPos
    ldx JOY2 ; cache JOY2 value in x
    ; #1 is UP
    ; #2 is DOWN
nextJoy2 ; Left
    txa
    and #4
    bne nextJoy3
    dec paddlePos
nextJoy3 ; Right
    txa
    and #8
    bne nextJoy4
    inc paddlePos
nextJoy4
    txa
    and #16 ; Button push
    bne ButtonNotPressed
    lda gameState ; If gameState != then we're paused and take action
    beq ButtonNotPressed ; game wasn't paused, ignored
    jsr resetAndPrintScore
    lda #$ff
    sta randomMovementMask ; set random movment to any possible movement
    jsr set_random_movement
    lda #0
    sta gameState
ButtonNotPressed
    rts

; Map puckTrajectory to a movement subroutine
movePuckInTraj
    lda gameState
    beq gameNotPaused
    rts ; game is paused, we're not moving
gameNotPaused
    lda puckTrajectory
    cmp #TRAJ_RIGHT
    bne moveNext0
    jsr movePuckRight
    rts
moveNext0
    cmp #TRAJ_DOWN
    bne moveNext1
    jsr movePuckDown
    rts
moveNext1
    cmp #TRAJ_LEFT
    bne moveNext2
    jsr movePuckLeft
    rts
moveNext2
    cmp #TRAJ_UP
    bne moveNext3
    jsr movePuckUp
    rts
moveNext3
    cmp #TRAJ_DR
    bne moveNext4
    jsr movePuckDownRight
    rts
moveNext4
    cmp #TRAJ_DL
    bne moveNext5
    jsr movePuckDownLeft
    rts
moveNext5
    cmp #TRAJ_UL
    bne moveNext6
    jsr movePuckUpLeft
    rts
moveNext6 ; Last possible move type
    jsr movePuckUpRight
    rts

movePuckRight       ; $00
    inc $d006
    inc $d006
    rts
movePuckDown        ; $01
    inc $d007
    inc $d007
    rts
movePuckLeft        ; $02
    dec $d006
    dec $d006
    rts
movePuckUp          ; $04
    dec $d007
    dec $d007
    rts
movePuckDownRight   ; $08
    jsr movePuckDown
    jsr movePuckRight
    rts
movePuckDownLeft    ; $10
    jsr movePuckDown
    jsr movePuckLeft
    rts
movePuckUpLeft      ; $20
    jsr movePuckUp
    jsr movePuckLeft
    rts
movePuckUpRight     ; $40
    jsr movePuckUp
    jsr movePuckRight
    rts


;    7
;  6/-\8
; 5|   |1
;  4\_/2
;    3
;
; 1 can LEFT, UP, UL [$02 | $04 | $20]
; 2 can left, up, ul [$02 | $04 | $20]
; 3 can up, ur [$04 | $40]
; 4 can right, ur [ $00 |
; 5 can right, dr
; 6 can down, right, dr
; 7 can down, dl
; 8 can dl, down, left

; 1-64 possible spots where paddlePos will be
; break up into 8 areas and randomize direction based on rules
setTrajectoryBasedOnPaddle
    lda paddlePos
    cmp #7
    bcs trajectory0 ; Jump if it was greater
    ; Area 1
    lda #TRAJ_LEFT
    ora #TRAJ_UP
    ora #TRAJ_UL
    sta randomMovementMask
    jsr set_random_movement
    rts
trajectory0
    cmp #16
    bcs trajectory1 ; Jump if it was greater
    ; Area 2
    lda #TRAJ_LEFT
    ora #TRAJ_UP
    ora #TRAJ_UL
    sta randomMovementMask
    jsr set_random_movement
    rts
trajectory1
    cmp #24
    bcs trajectory2 ; Jump if it was greater
    ; Area 3
    lda #TRAJ_UP
    ora #TRAJ_UR
    sta randomMovementMask
    jsr set_random_movement
    rts
trajectory2
    cmp #30
    bcs trajectory3 ; Jump if it was greater
    ; Area 4
    lda #TRAJ_RIGHT
    ora #TRAJ_UR
    sta randomMovementMask
    jsr set_random_movement
    rts
trajectory3
    cmp #39
    bcs trajectory4 ; Jump if it was greater
    ; Area 5
    lda #TRAJ_RIGHT
    ora #TRAJ_DR
    sta randomMovementMask
    jsr set_random_movement
    rts
trajectory4
    cmp #47
    bcs trajectory5 ; Jump if it was greater
    ; Area 6
    lda #TRAJ_DOWN
    ora #TRAJ_RIGHT
    ora #TRAJ_DR
    sta randomMovementMask
    jsr set_random_movement
    rts
trajectory5
    cmp #55
    bcs trajectory6 ; Jump if it was greater
    ; Area 7
    lda #TRAJ_DOWN
    ora #TRAJ_DL
    sta randomMovementMask
    jsr set_random_movement
    rts
trajectory6
    ; Area 8
    lda #TRAJ_DL
    ora #TRAJ_DOWN
    ora #TRAJ_LEFT
    sta randomMovementMask
    jsr set_random_movement
    rts

ClearScreen ; void ()
    lda #32
    ldx #0
Clearing
    sta SCREENMEM, x
    sta SCREENMEM + $100, x
    sta SCREENMEM + $200, x
    sta SCREENMEM + $300, x
    inx
    bne Clearing;
    rts

get_random_number ; reg a ()
    lda $d012 ; load current screen raster value
    eor $dc04 ; xor against value in $dc04 timer
    sbc $dc05 ; then subtract value in $dc05 timer
    rts

set_random_movement ; sets puckTrajectory with either 0, 1, 2, 4, 8, $10, $20, $40
    jsr get_random_number ; first random number
    and randomMovementMask
    jmp startLookingForMovementNumber
andAnotherRandom
    sta swapInNewRandom
    jsr get_random_number
    and swapInNewRandom
startLookingForMovementNumber
    beq set_random_movement ; it's 0 start over
    cmp #TRAJ_RIGHT
    beq gotMovement
    cmp #TRAJ_DOWN
    beq gotMovement
    cmp #TRAJ_LEFT
    beq gotMovement
    cmp #TRAJ_UP
    beq gotMovement
    cmp #TRAJ_DR
    beq gotMovement
    cmp #TRAJ_DL
    beq gotMovement
    cmp #TRAJ_UL
    beq gotMovement
    cmp #TRAJ_UR
    beq gotMovement
    jmp andAnotherRandom ; wasn't a valid movement, try again
gotMovement
    sta puckTrajectory
    rts
randomMovementMask  .byte $00 ; set this before calling set_random_movement to include movements you want
swapInNewRandom     .byte $00


checkBoundsOfPuck
    lda $d007
    beq setGameOver
    cmp #1
    beq setGameOver
    lda $d006
    beq setGameOver
    cmp #1
    beq setGameOver
    rts
setGameOver
    lda #GAME_STATE_END
    sta gameState
initPuckLocation
    lda #PUCK_START_X
    sta $d006
    lda #PUCK_START_Y
    sta $d007
    rts

printScore
    lda scoreDigits
    and #$0f
    ora #$30
    sta SCREENMEM+1
    ; Load 3rd digit
    lda scoreDigits
    and #$f0
    lsr
    lsr
    lsr
    lsr
    ora #$30
    sta SCREENMEM+0
    rts

incScoreAndPrint
    lda gameState
bne its_late
    sed ; decimal mode math
    clc
    lda #1
    adc scoreDigits
    sta scoreDigits
its_late
    jsr printScore
    rts

resetAndPrintScore
    lda #0
    sta scoreDigits
    jsr printScore
    rts

; Globals
scoreDigits     .byte 0
gameState       .byte 1 ; 0 = game in play, 1 = fresh game paused, 2 = game over
puckTrajectory  .byte 1 ; There are 8 possible direction
puckColor       .byte 0 ; Not sure why I can't read the sprite color directly
