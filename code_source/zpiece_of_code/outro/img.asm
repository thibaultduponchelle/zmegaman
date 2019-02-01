
afficherWily:
  ld hl, wily
  ld de, plotSScreen
  ld b, 64
afficherLoop:
  push bc
  ld bc, 5
  push hl
  ld h, d
  ld l, e
  add hl, bc
  ld d, h
  ld e, l
  pop hl
  ld bc, 7
  ldir
  pop bc
  djnz afficherLoop
  ret


inverserEcran:
  ld hl, plotSScreen
  ld b, 64
iEloop1:
  push bc
  ld b, 12
iEloop2:
  push bc
  ld a, (hl)
  neg 
  dec a
  ld (hl), a
  inc hl
  pop bc
  djnz iEloop2
  pop bc
  djnz iEloop1
  ret




  
