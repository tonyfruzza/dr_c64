
.org $0801
;Tells BASIC to run SYS 2064 to start our program
.byte $0C,$08,$0A,$00,$9E,' ','2','0','6','4',$00,$00,$00,$00,$00

CHROUT  .equ $FFD2
GETIN   .equ $FFE4
STOP    .equ $FFE1 ; Check for run stop, sets Z flag, then exit
SCREENMEM   .equ 1024
VMEM    .equ $D000

jmp init

; Some vars
FIRSTSET .byte $00
FIRST    .byte $00
SECOND   .byte $00
BEGINMSG .byte "ENTER TWO NUMBERS TO BE ADDED TOGETHER", $0d, 0
ENDMSG   .byte "END", $0d, 0
ORGBOARDER  .byte $00
ORGBGRND    .byte $00

init        JSR ClearScreen
lda VMEM + $21
sta ORGBOARDER
lda VMEM + $20
sta ORGBGRND
lda #$00
sta VMEM + $20
sta VMEM + $21
sta FIRSTSET ; init the value to 0 so it can be run again

PrintAdd    JSR GETIN ; Get a number
cmp #'0'     ; A >= $30 ?
bcc PrintAdd ; If not then go fetch another character
cmp #':'     ; Equal to $3A
bcs PrintAdd ; A < $3A

LDX FIRSTSET ; Should be 0
BEQ PrintPlus
BNE PrintSum

PrintPlus   jsr CHROUT ; Print out the first char
AND #$0F   ; Convert to bin
sta FIRST  ; Save the first value
inx
stx FIRSTSET ; Remember we did this part
lda #' '
jsr CHROUT
lda #'+'
jsr CHROUT
lda #' '
jsr CHROUT
jmp PrintAdd

PrintSum    JSR CHROUT ; print out the second char
AND #$0F   ; Convert to Binary from ASCII number
STA SECOND

lda #' '
JSR CHROUT
lda #'='
JSR CHROUT
lda #' '
JSR CHROUT

; Addition part
LDA FIRST
CLC
ADC SECOND
ORA #$30   ; mask to convert reg A from binary to ASCII
JSR CHROUT ; Print the sum
JSR PrintEND
SetColorsBack lda ORGBOARDER
sta VMEM + $21
lda ORGBGRND
sta VMEM + $20
RTS ; END PROGRAM TO BASIC

PrintEND    lda #$0d    ; CR
JSR CHROUT
LDX #$00    ; X Index offset of ENDMSG
PrintLoop   LDA ENDMSG, X
BEQ RETURN ; Should set Z to "ON" if last LDA was 0
jsr CHROUT
inx
BNE PrintLoop ;Repeat if index doesn't over flow to 0 
RETURN      RTS

ClearScreen LDX #$00
LDA #$60 ; Space
Clearing    STA SCREENMEM, X
STA SCREENMEM + $100, x
STA SCREENMEM + $200, x
STA SCREENMEM + $300, x
INX
BNE Clearing;
RTS
