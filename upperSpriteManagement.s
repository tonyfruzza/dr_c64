
START_SPRITE_MEM    .equ $3000
SPRITE_BYTES        .equ 63 ; 3 * 21

copyDownSprite ; void copyDownSprite(spriteOffsetNum)
    pla
    sta RET1+1
    pla
    sta RET1
    rts