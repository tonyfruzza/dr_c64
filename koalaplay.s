SCREENMEM       .equ 1024 ; Start of character screen map, color map is + $D400
NEWCHARMAP      .equ 12288 ; $3000 new place for Charset
VIC_MEM         .equ 53248
SCREEN_BOARDER  .equ VIC_MEM + 32
SCREEN_BG_COLOR .equ VIC_MEM + 33
COLORMEM        .equ $D800
RASTER_TO_COUNT_AT  .equ 80
songStartAdress     .equ $2300
zpPtr1          .equ $ba
zpPtr2          .equ $bc
KOALASR         .equ $8328
KOALACR         .equ $8710
SPRITE_LOC      .equ 100
SPRITE_LOC_Y    .equ 100

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
SPRITE0_POINTER .equ $57f8


.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00


main
    jsr init
    jsr copyImage
;    jsr showASprite
    jmp gameloop



showASprite
    lda #$01
    sta $d015 ; enable sprite 1
    sta VIC_MEM+39 ; Set color for sprite one
    lda #240 ; Location X
    ldx #150 ; Location Y
    sta $d000 ; 
    stx $d001

    lda #50
    sta $5ff8
    rts

copyImage
    ; Bitmap data is loaded in at $6000 - $7F3F which is 7,999 bytes, or 31 * 256
    ; Load background color and set it
; $8710 - $6000 = 2710
    lda dna4+$2710
;lda #0
    sta $d020
    sta $d021
; Loop to 256 31 times here

    ldx #0
loadccimage
; BITMAP
    lda dna4,x
    sta $6000,x
    lda dna4+$100,x
    sta $6100,x
    lda dna4+$200,x
    sta $6200,x
    lda dna4+$300,x
    sta $6300,x
    lda dna4+$400,x
    sta $6400,x
    lda dna4+$500,x
    sta $6500,x
    lda dna4+$600,x
    sta $6600,x
    lda dna4+$700,x
    sta $6700,x
    lda dna4+$800,x
    sta $6800,x
    lda dna4+$900,x
    sta $6900,x
    lda dna4+$A00,x
    sta $6A00,x
    lda dna4+$B00,x
    sta $6B00,x
    lda dna4+$C00,x
    sta $6C00,x
    lda dna4+$D00,x
    sta $6D00,x
    lda dna4+$E00,x
    sta $6E00,x
    lda dna4+$F00,x
    sta $6F00,x
    lda dna4+$1000,x
    sta $7000,x
    lda dna4+$1100,x
    sta $7100,x
    lda dna4+$1200,x
    sta $7200,x
    lda dna4+$1300,x
    sta $7300,x
    lda dna4+$1400,x
    sta $7400,x
    lda dna4+$1500,x
    sta $7500,x
    lda dna4+$1600,x
    sta $7600,x
    lda dna4+$1700,x
    sta $7700,x
    lda dna4+$1800,x
    sta $7800,x
    lda dna4+$1900,x
    sta $7900,x
    lda dna4+$1A00,x
    sta $7A00,x
    lda dna4+$1B00,x
    sta $7B00,x
    lda dna4+$1C00,x
    sta $7C00,x
    lda dna4+$1D00,x
    sta $7D00,x
    lda dna4+$1E00,x
    sta $7E00,x
    lda dna4+$1F00,x
    sta $7F00,x


    ; SCREEN RAM
    ; $7F40 - $6000 =
    lda dna4+$1f40,x
    ;    LDA $7F40,X
    STA $5C00,X
    lda dna4+$2040,x
    ;    LDA $8040,X
    STA $5D00,X
    lda dna4+$2140,x
    ;    LDA $8140,X
    STA $5E00,X
    lda dna4+$2240,x
    ;    LDA $8240,X
    STA $5F00,X

; COLOR RAM
; $8328 - $6000 = $2328
; $7C00 more than screen mem??
    lda dna4+$2328,x
;    LDA $8328,X
    STA $D800,X
    lda dna4+$2428,x
;    LDA $8428,X
    STA $D900,X
    lda dna4+$2528,x
;    LDA $8528,X
    STA $DA00,X
    lda dna4+$2628,x
;    LDA $8628,X
    STA $DB00,X



;   jsr WaitFrame
;   jsr WaitFrame
;    jsr WaitFrame
;jsr WaitFrame

    inx
    beq ci_done
    jmp loadccimage
ci_done
    rts








copyImage2
; Bitmap data is loaded in at $6000 - $7F3F which is 7,999 bytes, or 31 * 256
; Load background color and set it
; $8710 - $6000 = 2710
;    lda dna4+$2710
lda #0
sta $d020
sta $d021
; Loop to 256 31 times here

ldx #0
loadccimage2
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
lda dylan1+$2328,x
;    LDA $8328,X
STA $D800,X
lda dylan1+$2428,x
;    LDA $8428,X
STA $D900,X
lda dylan1+$2528,x
;    LDA $8528,X
STA $DA00,X
lda dylan1+$2628,x
;    LDA $8628,X
STA $DB00,X



;jsr WaitFrame
;jsr WaitFrame
;jsr WaitFrame
;jsr WaitFrame

inx
beq ci_done2
jmp loadccimage2
ci_done2
rts











WaitFrame
    lda $d012
    cmp #0
    beq WaitFrame
    ;wait for the raster to reach line $f8 (should be closer to the start of this line this way)
WaitStep2
    lda $d012
    cmp #0
    bne WaitStep2
Return
    rts



init
    ; Configure VIC2 memory layout
    ; This is % 0111 _101_1
    ; _101_ 4: $2000-$3FFF, 8192-16383

    ; Default is xxxx 010x which sets to ROM charset since we are in VIC bank #0
    ; Default is 0001 xxxx which sets screen memory to $0400 (1024)
    ;
    lda #$02 ; bank #1 index 0 $4000-$7FFF + $2000 = $6000, default is 3 which is bank #0
    sta $DD00

    ; Set video mode
    ; 0-2 : Veritcal raster scroll
    ;   3 : screen height 0 = 24, 1 = 25
    ;   4 : 0 screen off
    ;   5 : 0 = text mode, 1 = bitmap mode
    ;   6 : extended background mode on
    ;   7 : read/set current raster line/interrupt
    ;
    ;  7654 3210
    ; %0011 1011 = screen on, 25 rows : this is default
    lda #$3B
    sta $d011

    ; 0-2 : Horizontal raster scroll
    ;   3 : Screen width 0 = 38, 1 = 40
    ;   4 : Multicolor mode on
    ; I'm seeing 6 and 7 set to 11
    ; %1101 1000 = 40 columns, multicolor mode
    lda #$D8
    sta $d016

    ; Ends up being a value of $7d or %0111 1101
    ; Character mem at $70000, Screen memory at $5c00, Sprite 0 pointer $5ff8 ?
    lda $d018
    and #%00000001
    ora #%01111100
    sta $d018
    rts

gameloop
    ldx #0
delayLoop
    jsr WaitFrame
    inx
    bne delayLoop

    jsr copyImage2

    ldx #0
delayLoop1
    jsr WaitFrame
    inx
    bne delayLoop1
   jsr copyImage

jmp gameloop
