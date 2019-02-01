; Credit to Brian Coventry for this code
; Pour le moment, je n'arrive pas à l'utiliser correctement
; Car lorsqu'on sort du launcher, la calc est plantee...
; Mais c'est surement du a autre chose
;this disables TI's protection



;this disables TI's protection
disable_c000_protection:
    call unlockFlash
    xor a
    out ($25), a
    dec a
    out ($26), a
    ret

;this enables TI's protection

enable_c000_protection:
    call unlockFlash
    ld a, $10
    out ($25), a
    ld a, $20
    out ($26), a
    ret


unlockFlash:
;Unlocks Flash protection.
;Destroys: pagedCount                        
;          pagedGetPtr
;          arcInfo
;          iMathPtr5
;          pagedBuf
;          ramCode

    di
    in      a, (06)
    push    af

    ld      hl, returnPoint+$8214-$81E3
    ld      de, $8214
    ld      a, e
    ld      (arcInfo), a            ;should be 08-15
    ld      (pagedCount), a         ;just has to be over 2
    ld      bc, $8214-$8167
    lddr
    ld      (iMathPtr5), de         ;must be 8167
    ld      iy, 0056h-25h           ;permanent flags

    add     a, e
    ld      (pagedBuf), a           ;needs to be large, but under 80
    call    translatePage
    ld      hl, ($5092)
    ld      a, ($5094)
    call    translatePage
    ld      a, $10
    cpir
    jp      (hl)

returnPoint:
    ld      hl, $0018
    ld      (hl), $C3               ;dummy write
flashWait:
    ld      iy, flags
    djnz    flashWait               ;wait for write to finish
    add     hl, sp
    ld      sp, hl
    pop     af
translatePage:
    bcall(_NZIf83Plus)
    jr      z, not83
    and     1Fh
not83:
    out     (06), a
    ret
