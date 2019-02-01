
; Mettre dans ix l'adresse du texte a ecrire 
dialog:
  ld b, (ix)    ; Nombre de lignes
  inc ix
dialogLoop:
  push bc
  call afficherDialog
  pop bc
  djnz dialogLoop
  ret

afficherDialog:
  set textWrite, (IY + sGrFlags)
  res textInverse, (IY + textFlags)

  ld e, (ix)
  inc ix
  ld d,(ix)
  inc ix
  push de
  pop hl
  ld a, 1
  ld (penCol), a
  ld a, 28
  ld (penRow), a
  bcall(_VPutS)
  bcall(_GrBufCpy)
  ret


dialog1:
  .db 1
  .dw d1

d1:
  .db "ah ah ah ...", 0

dialog2:
  .db 1
  .dw d2

d2:
  .db "Come to me !", 0







; Mettre dans ix l'adresse du texte a ecrire 
effetTexte:
  ld b, (ix)    ; Nombre de lignes
  inc ix
textLoop:
  push bc
  call afficherIntro
  call deroulerIntro
  pop bc
  djnz textLoop

  ld b, 7
textLoopFin:
  push bc
  call deroulerIntro
  pop bc
  djnz textLoopFin
  ret

effacerEcran:
  ld hl, plotSScreen
  ld (hl), 255
  ld de, plotSScreen + 1
  ld bc, 12 * 64
  ldir
  bcall(_GrBufCpy)
  ret

effacerEcranBlanc:
  ld hl, plotSScreen
  ld (hl), 0
  ld de, plotSScreen + 1
  ld bc, 12 * 64
  ldir
  bcall(_GrBufCpy)
  ret



  

afficherIntro:
  set textWrite, (IY + sGrFlags)

  ld e, (ix)
  inc ix
  ld d,(ix)
  inc ix
  push de
  pop hl
  ld a, 1
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
  ld a, (isDialog)
  or a
  call nz, afficherWily
  bcall(_GrBufCpy)
  ret


outro:
  .db 2
  .dw a1
  .dw a2


a1:
  .db "Come to me", 0
a2:
  .db "I wait you ...", 0

finalOutro:
  .db 9
  .dw o1
  .dw o2
  .dw o3
  .dw o4
  .dw o5
  .dw o6
  .dw o7
  .dw o8
  .dw o9

o1:
  .db "You finally beat my robots", 0
o2:
  .db "Congratulation rock,", 0 
o3:
  .db "but now you will die", 0
o4:
  .db "I'm currently destroying", 0
o5:
  .db "the entire planet earth.", 0
o6:
  .db "You can't simply save", 0 
o7:
  .db "the people you like.", 0
o8:
  .db "Come to me my son.", 0 
o9:
  .db "This is our final battle...", 0 


