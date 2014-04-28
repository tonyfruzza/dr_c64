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


.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00

jmp entryPoint

firstRaster     .byte 165 ; End of Blue, start of black
secondRaster    .byte 168 ; End of black line
thirdRaster     .byte 220 ; start of yellow
sixthRaster     .byte 223 ; End of bottom black line
seventhRaster   .byte 245 ;

rasters     .byte         125,       128,         180,          183,          225
colors      .byte COLOR_BLACK, COLOR_RED, COLOR_BLACK, COLOR_L_BLUE, COLOR_L_BLUE

bgcolors    .byte COLOR_BLACK, COLOR_RED, COLOR_BLACK, COLOR_BLUE  , COLOR_BLUE

cRaster     .byte $00
tmpColor    .byte $00





entryPoint
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



jsr clearScreen2


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
jsr WaitFrame
jsr nextStep
    jmp loop


clearScreen2
    ldx #0
    lda #1
cs2_loop
    sta SCREEN2, x
    sta SCREEN2+$100, x
    sta SCREEN2+$200, x
    sta SCREEN2+$300, x
    inx
    bne cs2_loop
    rts


WaitFrame
lda $d012
cmp #0
beq WaitFrame
;wait for the raster to reach line $f8 (should be closer to the start of this line this way)
WaitStep2   lda $d012
cmp #0
bne WaitStep2
Return
rts

nextStep
    inc rasters
    inc rasters+1
    inc rasters+2
    inc rasters+3
    inc rasters+4
    rts


int2 ; void (y, x, a)
    asl $d019    ; ACK interrupt (to re-enable it)
    ldy cRaster
; If cRaster is 0 then set video mode to other screen addy
    bne keepVideoMode
    lda $d018
    and #%00001111
    ora #%10000000
    sta $d018 ; startin at $2000
keepVideoMode
    cpy #3
    bne stillKeepVideoMode
    ; Set video back to how it was
    lda $d018
    and #%00001111
    ora #%00010000
    sta $d018 ; startin at $2000

stillKeepVideoMode
    lda colors, y
    sta tmpColor
    lda bgcolors, y

    ldx rasters, y

    inx
    inx
    ldy tmpColor ; load in border color to y
notRasterFound
    cpx $d012
    bne notRasterFound
    sty SCREEN_BORDER
    sta SCREEN_BG_COLOR

    ; Set interup pointer on over to other interupt
;    sei ; turn interupt off
    lda cRaster
    cmp #4
bne continueIncrementing
    lda #0 ; reset counter
    sta cRaster
    jmp noIncrementingRasterCounters
continueIncrementing
    inc cRaster
noIncrementingRasterCounters
    ldy cRaster
    lda rasters, y
;    lda firstRaster
    sta $d012
    ; Restore values back from stack
    pla
    tay
    pla
    tax
    pla
;    cli ; Turn back on the interupt
    rti          ; return from interrupt
