; Credit to Brian Coventry for this code
; Pour le moment, je n'arrive pas à l'utiliser correctement
; Car lorsqu'on sort du launcher, la calc est plantee...
; Mais c'est surement du a autre chose
;this disables TI's protection
disable_protection:
  call UnlockFlash
  xor a
  out ($25), a
  dec a
  out ($26), a
  ret

;this enables TI's protection
enable_protection:
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

UnlockFlash:
;Unlocks Flash protection.
;Destroys: appBackUpScreen
;          pagedCount
;          pagedGetPtr
;          arcInfo
;          iMathPtr5
;          pagedBuf
;          ramCode
        in a,(6)
        push af
        ld a,7Bh
        call translatePage
        out (6),a
        ld hl,5092h
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        ld a,(hl)
        call translatePage
        out (6),a
        ex de,hl
        ld a,0CCh
        ld bc,0FFFFh
        cpir
        ld e,(hl)
        inc hl
        ld d,(hl)
        push de
        pop ix
        ld hl,9898h
        ld (hl),0C3h
        inc hl
        ld (hl),returnPoint & 11111111b
        inc hl
        ld (hl),returnPoint >> 8
        ld hl,pagedBuf
        ld (hl),98h
        ld de,pagedBuf+1
        ld bc,49
        ldir
        ld (iMathPtr5),sp
        ld hl,(iMathPtr5)
        ld de,9A00h
        ld bc,50
        ldir   
        ld de,(iMathPtr5)
        ld hl,-12
        add hl,de
        ld (iMathPtr5),hl
        ld iy,0056h-25h
        ld a,50
        ld (pagedCount),a
        ld a,8
        ld (arcInfo),a
        jp (ix)
translatePage:
        ld b,a
        in a,(2)
        and 80h
        jr z,_is83P
        in a,(21h)
        and 3
        ld a,b
        ret nz
        and 3Fh
        ret
_is83P: ld a,b
        and 1Fh
        ret
returnPoint:
        ld iy,flags
        ld hl,(iMathPtr5)
        ld de,12
        add hl,de
        ld sp,hl
        ex de,hl
        ld hl,9A00h
        ld bc,50
        ldir
        pop af
        out (6),a
        ret
