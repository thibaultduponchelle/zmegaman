#include "../includes/ti83plus.inc"
#include "../includes/ion.inc"

.org progstart-2
.db t2ByteTok, tasmCmp
#DEFINE 83P


start:
  ld a, 1
  ld (isDialog), a
  call effacerEcranBlanc
  call afficherWily
  ld ix, dialog1
  call dialog
  call inverserEcran
  bcall(_GrBufCpy)

  call clignoterEcran
  call clignoterEcran
  call clignoterEcran
  call clignoterEcran
  call clignoterEcran
  call effacerEcranBlanc
  call afficherWily
  bcall(_GrBufCpy)
  ld ix, outro
  call effetTexte
  ld ix, dialog2
  call dialog
  bcall(_GrBufCpy)
  call wait 
  call wait 
  call wait 
  call wait 
  call clignoterEcran
  call clignoterEcran
  call clignoterEcran
  call clignoterEcran
  call clignoterEcran
  call clignoterEcran
  call effacerEcranBlanc
  bcall(_GrBufCpy)
  ld a, 0
  ld (isDialog), a
  ld ix, finalOutro
  call effetTexte
  call SCROLL_BYTE_EFFECT_BLACK_THEN_WHITE

  ret


clignoterEcran:
  call inverserEcran
  bcall(_GrBufCpy)
  call wait
  call inverserEcran
  bcall(_GrBufCpy)
  call wait
  call inverserEcran
  bcall(_GrBufCpy)
  call wait
  ret

  

isDialog:
  .db 0
#include "text.asm"
#include "img.asm"
#include "graphix.effects.asm"
wily:
#include "pixs/wily1.bmp"

