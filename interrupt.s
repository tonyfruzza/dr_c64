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


.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00

    jmp entryPoint

    firstRaster     .byte 165 ; End of Blue, start of black
    secondRaster    .byte 168 ; End of black line
    thirdRaster     .byte 220 ; start of yellow
;    fifthRaster     .byte 235 ; start of black bottom
    sixthRaster     .byte 223 ; End of bottom black line
    seventhRaster   .byte 245 ;

entryPoint
    sei          ; turn off interrupts
    lda #$7f
    ldx #$01
    sta $dc0d    ; Turn off CIA 1 interrupts
    sta $dd0d    ; Turn off CIA 2 interrupts

;lda $d01a
;ora #1
;sta $d01a
    stx $d01a    ; Turn on raster interrupts

;    lda #$1b
;    ldx #$08
;    ldy #$14
lda $d011
ora $40
sta $d011 ; Turn on bit 7
    sta $d011    ; Clear high bit of $d012, set text mode
;    stx $d016    ; single-colour
;    sty $d018    ; screen at $0400, charset at $2000

    lda #<int2    ; low part of address of interrupt handler code
    ldx #>int2    ; high part of address of interrupt handler code
    ldy firstRaster     ; line to trigger interrupt
    sta $0314    ; store in interrupt vector
    stx $0315
    sty $d012

    lda $dc0d    ; ACK CIA 1 interrupts
    lda $dd0d    ; ACK CIA 2 interrupts
    asl $d019    ; ACK VIC interrupts
    cli          ; turn interrupts back on






loop
    ; Going to enable sprite that is loaded at $3000
    lda #$C0 ; $3000/$40 =  $C0
    sta $07f8
    lda #$C1
    sta $07f9
    lda #$C2
    sta $07fa
    ; Enable Sprite 0, 1, 2
    lda #7
    sta $d015

    ; Set colors to white
    lda #1
    sta VIC_MEM+39
    sta VIC_MEM+40
    sta VIC_MEM+41



    lda #$90 ; location
ldx #185
    sta $d000
    stx $d001
lda #$a5
    sta $d002
    stx $d003
lda #$ba
    sta $d004
    stx $d005

    jmp loop

bcolor       .byte $00
;                      O O,
rasters     .byte 167, 170, 220, 223, 0,0
colors      .byte COLOR_BLACK, COLOR_RED, COLOR_BLACK, COLOR_L_BLUE, COLOR_L_BLUE
bgcolors    .byte COLOR_BLACK, COLOR_RED, COLOR_BLACK, COLOR_BLUE, COLOR_BLUE
rasterIndex .byte $00
cRaster     .byte $00



; Interrupt area
int
    sei ; turn interupt off
    ldx rasters
    inx
noThereYet
    cpx $d012
    beq rasterFound
    jmp noThereYet
rasterFound
    sty SCREEN_BORDER
    sta SCREEN_BG_COLOR
    cli

; Set up next raster line
    ldx rasterIndex

    lda rasters, x
    bne rasterIndexContinue
    sta rasterIndex ; reset index to 0
    ldx rasterIndex
    lda rasters, x
rasterIndexContinue

    sei
    lda rasters
    sta $d012
    lda #<int2
    sta $0314
    lda #>int2
    sta $0315
    cli


pla
tay
pla
tax
pla
cli ; Turn back on the interupt
    asl $d019    ; ACK interrupt (to re-enable it)
rti          ; return from interrupt




int2 ; void (y, x, a)
    asl $d019    ; ACK interrupt (to re-enable it)
ldy #COLOR_BLUE
lda #COLOR_L_BLUE
ldx seventhRaster
inx
notRasterFound
cpx $d012
bne notRasterFound

    sta $d020
    sty $d021
    ; Set interup pointer on over to other interupt

    sei ; turn interupt off

    lda firstRaster
    sta $d012
    lda #<int3
    sta $0314
    lda #>int3
    sta $0315


    ; Restore values back from stack
    pla
    tay
    pla
    tax
    pla
    cli ; Turn back on the interupt
    rti          ; return from interrupt


int3 ; void (y, x, a)
asl $d019    ; ACK interrupt (to re-enable it)
ldy #COLOR_BLACK
ldx firstRaster
inx
notFirstRaster
    cpx $d012
    bne notFirstRaster

sty $d020
sty $d021
; Set interup pointer on over to other interupt

sei ; turn interupt off

lda secondRaster
sta $d012
lda #<int4
sta $0314
lda #>int4
sta $0315


; Restore values back from stack
pla
tay
pla
tax
pla
cli ; Turn back on the interupt
rti          ; return from interrupt

int4 ; void (y, x, a)
asl $d019    ; ACK interrupt (to re-enable it)
ldy #COLOR_RED
ldx secondRaster
inx
lookingSecond
    cpx $d012
    bne lookingSecond

sty $d020
sty $d021
; Set interup pointer on over to other interupt

sei ; turn interupt off

lda thirdRaster
sta $d012
lda #<int5
sta $0314
lda #>int5
sta $0315


; Restore values back from stack
pla
tay
pla
tax
pla
cli ; Turn back on the interupt
rti          ; return from interrupt


int5 ; void (y, x, a)
asl $d019    ; ACK interrupt (to re-enable it)
ldy #COLOR_BLACK
ldx thirdRaster
inx
lookingFifth
    cpx $d012
    bne lookingFifth
sty $d020
sty $d021
; Set interup pointer on over to other interupt

sei ; turn interupt off

lda sixthRaster
sta $d012
lda #<int6
sta $0314
lda #>int6
sta $0315


; Restore values back from stack
pla
tay
pla
tax
pla
cli ; Turn back on the interupt
rti          ; return from interrupt


int6 ; void (y, x, a)
asl $d019    ; ACK interrupt (to re-enable it)
ldy #COLOR_BLUE
lda #COLOR_L_BLUE
ldx sixthRaster
inx
lookingSixth
    cpx $d012
    bne lookingSixth

sta $d020
sty $d021
; Set interup pointer on over to other interupt

sei ; turn interupt off

lda seventhRaster
sta $d012
lda #<int2
sta $0314
lda #>int2
sta $0315


; Restore values back from stack
pla
tay
pla
tax
pla
cli ; Turn back on the interupt
rti          ; return from interrupt
