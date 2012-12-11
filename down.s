
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
    beq LastMoveBeforeCommit ; if it's set to zero then do a drop with delay
    ; LAST_MOVE was set to 1
    lda #0
    sta LAST_MOMENT_MOVE
    lda #<SOUND_BOTTOM
    ldy #>SOUND_BOTTOM
    ldx #14
    jsr songStartAdress+6
    pla
    pla
    jmp DropNew
LastMoveBeforeCommit
    lda #1
    sta LAST_MOMENT_MOVE
    jmp GameLoop
