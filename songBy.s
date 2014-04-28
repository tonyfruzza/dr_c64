; Interrupt latch register $d019, who interrupted?
; bit 0 (RST) Raster IRQ set up using $d012 and bit 7 of $d011
; bit 1 (MBC) Sprite collision with background
; bit 2 (MMC) Sprite Collision w/Sprite
; bit 3 (LP) Used for Light Pen
; Set the lowest bit of $d01a to enable raster interupts

; bin in interrupt enable register $d01a

VIC_MEM         .equ 53248
SCREEN_BORDER   .equ VIC_MEM + 32
SCREEN_BG_COLOR .equ VIC_MEM + 33
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
SCREEN2         .equ $2000
SCREENMEM       .equ 1024 ; Start of character screen map, color map is + $D400
NEWCHARMAP      .equ 12288 ; $3000 new place for Charset
COLORMEM        .equ $D800
zpPtr1          .equ $ba
zpPtr2          .equ $bc
SONGBASE        .equ $8000
STATUS_PLACE    .equ 1984
STATUS_COLORPL  .equ $dbc0
STATUS_CHAR     .equ 161

.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00

entryPoint
    jsr ClearScreen
    jsr setupVideoMode
    jsr cycleStatusChar
    jsr int0
    lda #161
    sta STATUS_PLACE

    jsr loadInOutBreakLogo
    jsr setupLogo

    jsr loadInBy
    jsr setupBy


    jsr loadInSong
    jsr playSong
; set status char back to play
lda #165
sta STATUS_PLACE
lda #COLOR_WHITE
sta STATUS_COLORPL
loop
nop
jmp loop
    rts

.byte   activeDisk 8



playSong
    ; init song
    lda #0 ; set song
    jsr SONGBASE
    inc playSongBool
    rts

setupVideoMode
    lda #0
    sta SCREEN_BORDER
    sta SCREEN_BG_COLOR
    ; Set video to use char ram from different place, say at $3000
    lda $d018
    and #%11110001
    ora #%00001100
    sta $d018
    rts

; Setup Richard by characters loaded in at $3000 + 125 * 8 = $33E8
setupBy
lda #<BY_PLC
sta zpPtr1
lda #>BY_PLC
sta zpPtr1+1
ldx #0
by_loop
    ldy #0

    lda by_offset
    sta (zpPtr1), y
    inc by_offset
iny

lda by_offset
sta (zpPtr1), y
inc by_offset
iny

lda by_offset
sta (zpPtr1), y
inc by_offset
iny

lda by_offset
sta (zpPtr1), y
inc by_offset
iny

lda by_offset
sta (zpPtr1), y
inc by_offset
iny

lda by_offset
sta (zpPtr1), y
inc by_offset
iny

lda by_offset
sta (zpPtr1), y
inc by_offset
iny

lda by_offset
sta (zpPtr1), y
inc by_offset
iny

lda by_offset
sta (zpPtr1), y
inc by_offset

clc
lda zpPtr1
adc #40
sta zpPtr1
lda #0
adc zpPtr1+1
sta zpPtr1+1
inx
cpx #4
bne by_loop
    rts

BY_PLC      .equ 1024
by_offset   .byte 125


; Start painting at SCREENMEM + 35 I Think
setupLogo
    lda #<LOGO_PLC
    sta zpPtr1
    lda #>LOGO_PLC
    sta zpPtr1+1

    ldx #0
sl_loop
    ldy #0

    lda logo_offset
    sta (zpPtr1), y
    iny
    inc logo_offset

    lda logo_offset
    sta (zpPtr1), y
    iny
    inc logo_offset

    lda logo_offset
    sta (zpPtr1), y
    iny
    inc logo_offset

    lda logo_offset
    sta (zpPtr1), y
    iny
    inc logo_offset

    lda logo_offset
    sta (zpPtr1), y
    inc logo_offset

    clc
    lda zpPtr1
    adc #40
    sta zpPtr1
    lda #0
    adc zpPtr1+1
    sta zpPtr1+1
    inx
    cpx #25
    bne sl_loop
    rts
LOGO_LOC    .equ $3000
LOGO_PLC    .equ SCREENMEM + 35
;logo_offset .byte $00
logo_offset .byte 0
logo_tmp    .byte $00

loadInOutBreakLogo
    lda #1 ; file number
    ldx $BA ; device number last used usually 8
    stx activeDisk
    ldy #1 ; Use address stored in file
    jsr $ffba ; set LFS
    lda #OBLOGO_LEN ; name length
    ldx #<OBLOGO_NAM
    ldy #>OBLOGO_NAM
    jsr $ffbd
    lda #0
    sta $0a ; load/verify flag 0
    jsr $ffd5
    rts
OBLOGO_NAM .byte "logo"
OBLOGO_LEN .equ 4

loadInBy
    lda #1 ; file number
    ldx activeDisk
    ldy #1 ; Use address stored in file
    jsr $ffba ; set LFS
    lda #OBBY_LEN ; name length
    ldx #<OBBY_NAM
    ldy #>OBBY_NAM
    jsr $ffbd
    lda #0
    sta $0a ; load/verify flag 0
    jsr $ffd5
    rts
OBBY_NAM  .byte "by"
OBBY_LEN  .equ 2


loadInSong
    lda #1 ; file number
    ldx activeDisk
    ldy #1 ; use the address stored in program header
    jsr $ffba ; set LFS
    lda #SID_LEN ; name length
    ldx #<SID_NAM
    ldy #>SID_NAM
    jsr $ffbd
    lda #0
    sta $0a ; load/verify flag 0
    jsr $ffd5
    rts
SID_LEN  .equ 3
SID_NAM  .byte "sid"


ClearScreen ; void ()
; Lets make a 255 that is all 0's, 255 * 8 + NEWCHARMAP 
lda #0
sta NEWCHARMAP+2040
sta NEWCHARMAP+2041
sta NEWCHARMAP+2042
sta NEWCHARMAP+2043
sta NEWCHARMAP+2044
sta NEWCHARMAP+2045
sta NEWCHARMAP+2046
sta NEWCHARMAP+2047

LDX #$00
Clearing
lda #255
STA SCREENMEM, X
STA SCREENMEM + $100, x
STA SCREENMEM + $200, x
STA SCREENMEM + $300, x
lda #$01
sta COLORMEM, x
sta COLORMEM + $100, x
sta COLORMEM + $200, x
sta COLORMEM + $300, x
inx
BNE Clearing;
RTS



int0 ; This is where we're init'ing the irq
sei          ; turn off interrupts
lda #$7f
ldx #$01
sta $dc0d    ; Turn off CIA 1 interrupts
sta $dd0d    ; Turn off CIA 2 interrupts
stx $d01a    ; Turn on raster interrupts
lda $d011
ora $40
sta $d011 ; Turn on bit 7
sta $d011    ; Clear high bit of $d012, set text mode
lda #<int1    ; low part of address of interrupt handler code
ldx #>int1    ; high part of address of interrupt handler code
ldy firstRaster     ; line to trigger interrupt
sta $0314    ; store in interrupt vector
stx $0315
sty $d012

lda $dc0d    ; ACK CIA 1 interrupts
lda $dd0d    ; ACK CIA 2 interrupts
asl $d019    ; ACK VIC interrupts
cli          ; turn interrupts back on
rts

int1
    asl $d019
    lda playSongBool ; play song flag
    beq noPlay
    jsr SONGBASE+3
noPlay
lda STATUS_PLACE
cmp #165
beq noStatusChange
    ldx statusCharOffset
    lda statusCharList, x
    sta STATUS_PLACE
    lda statusCharCList, x
    sta STATUS_COLORPL
    inc statusCharOffset
    lda statusCharOffset
    cmp #4
    bne statusCharContinue
    lda #0
    sta statusCharOffset
    statusCharContinue
noStatusChange
    pla
    tay
    pla
    tax
    pla
    ;    cli ; Turn back on the interupt
    rti          ; return from interrupt
playSongBool    .byte 0
statusCharOffset    .byte 0

; Load this in at $3508
STATUS_ADDY .equ $3508 ; these are char pos 161, 162, 163, 164
cycleStatusChar
    ldx #0
    csc_loop
    lda status, x
    sta STATUS_ADDY, x
    inx
    cpx #40
    bne csc_loop
    rts
statusCharList  .byte 161, 162, 163, 164
statusCharCList .byte COLOR_CYAN, 14 , 4  , 6


status .byte 96, 240, 240, 96, 0, 0, 0, 0
status_1 .byte 6, 15, 15, 6, 0, 0, 0, 0
status_2 .byte 0, 0, 0, 0, 6, 15, 15, 6
status_3 .byte 0, 0, 0, 0, 96, 240, 240, 96
status_4 .byte 0, 64, 96, 112, 120, 112, 96, 64
