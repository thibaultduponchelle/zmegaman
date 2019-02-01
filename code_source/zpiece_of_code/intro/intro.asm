#include "../includes/ti83plus.inc"
#include "../includes/ion.inc"

.org progstart-2
.db t2ByteTok, tasmCmp
#DEFINE 83P


start:
  bcall(_ClrLCDFull)
  bcall(_GetKey)
  call effacerEcran
  ld ix, intro  ; Le texte
  ld b, (ix)    ; Nombre de lignes
  inc ix
textLoop:
  push bc
  call afficherIntro
  call deroulerIntro
  pop bc
  djnz textLoop

  ret


effacerEcran:
  ld hl, plotSScreen
  ld (hl), 255
  ld de, plotSScreen + 1
  ld bc, 12 * 64
  ldir
  bcall(_GrBufCpy)
  ret

  

afficherIntro:
  set textWrite, (IY + sGrFlags)
  set textInverse, (IY + textFlags)

  ld e, (ix)
  inc ix
  ld d,(ix)
  inc ix
  push de
  pop hl
  ld a, 3
  ld (penCol), a
  ld a, 57
  ld (penRow), a
  bcall(_VPutS)
  bcall(_GrBufCpy)
  ret

wait:
  ld b, 40
wout:
  push bc
  ld b, 255
win:
  push bc
  ld e, b
  ld e, b
  ld e, b
  ld e, b
  pop bc
  djnz win
  pop bc
  djnz wout
  ret
  

deroulerIntro:
  ld b, 9
encore:
  push bc
  call scroll
  call wait
  pop bc
  djnz encore
  ret

scroll:
  ld hl, plotSScreen +12
  ld de, plotSScreen
  ld bc, 63 * 12
  ldir
  bcall(_GrBufCpy)
  ret


intro:
  .db 29
  .dw l1
  .dw l2
  .dw l3
  .dw l4
  .dw l5
  .dw l6
  .dw l7
  .dw l8
  .dw l9
  .dw l10
  .dw l11
  .dw l12
  .dw l13
  .dw l14
  .dw l15
  .dw l16
  .dw l17
  .dw l18
  .dw l19
  .dw l20
  .dw l21
  .dw l22
  .dw l23
  .dw l24
  .dw l25
  .dw l26
  .dw l27
  .dw l28
  .dw l29

l1:
  .db "The year is 2042", 0
l2:
  .db "Megaman has laid waste", 0 
l3:
  .db "to countless robots sent", 0
l4:
  .db "by Dr. Wily.", 0
l5:
  .db "Time and time again Rock", 0
l6:
  .db "has proven himself", 0 
l7:
  .db "and brought the world back", 0
l8:
  .db "from the brink", 0 
l9:
  .db "of destruction.", 0 
l10:
  .db "Dr. Light has long", 0
l11:
  .db "since passed.", 0
l12:
  .db "The world has found peace,", 0
l13:
  .db "and Dr. Wily", 0
l14:
  .db "has gone silent.",0 
l15:
  .db "Perhaps that last battle", 0
l16:
  .db "was the straw that broke", 0
l17:
  .db "the once vengeful", 0
l18:
  .db "doctors back.", 0 
l19:
  .db "Strange occurrences", 0 
l20:
  .db "with sightings", 0
l21:
  .db "of once long defeated", 0
l22:
  .db "foes now returning,", 0
l23:
  .db "have been popping up", 0
l24:
  .db "around the globe.", 0 
l25:
  .db "Will Rock don", 0
l26:
  .db "his iconic helmet", 0
l27:
  .db "and Mega Blaster",0
l28:
  .db "to save the world", 0
l29:
  .db "once again?", 0


