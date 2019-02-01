;########################################################
;# [megaMath.asm]
;#-------------------------------------------------------
;# ROUTINES CONTENUES:
;# AUCUNE !
;#-------------------------------------------------------
;#  Fichier d'inclusion. Ce fichier sert pour repartir
;#  le code dans saferam
;#  This file is here to move some code in saferam 
;#-------------------------------------------------------

; Et si le luxe, c'était l'espace?


saferam_start:
.org saferamRoutines
safe_start
;Ces routines vont être copiées dans saferam pour libérer de l'espace
#include "megaKeyLoop.asm"
#include "megaTileMap.asm"
#include "megaSpriteRoutines.asm"
#include "megaSaveData.asm"
#include "megaLoadData.asm"
saferam_end:
SAFE_TOTAL = saferam_end - safe_start
.echo "Mémoire dans saferam1: ", SAFE_TOTAL
.org saferam_start+SAFE_TOTAL
