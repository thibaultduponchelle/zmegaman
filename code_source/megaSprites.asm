;########################################################
;# [megaSprites.asm]
;#-------------------------------------------------------
;# ROUTINES CONTENUES:
;# AUCUNE !
;#-------------------------------------------------------
;# DONNEES CONTENUES:
;#-------------------------------------------------------
;# Inclusion des sprites du joueur
;# The sprites for megaman 
;#-------------------------------------------------------


; Oh my god, they killed kenny ! o_O

; Ici on trouve les sprites du joueur 
; L'ordre tres important !
; Attention spasm ne lit pas n'importe quel format de bmp

playerSprite:
sprites_left:
megaman_regarde_gauche:
#include "zsprites/player/regardeGauche.bmp"
megaman_trebuche_gauche:
#include "zsprites/player/courtGauche1.bmp"
megaman_court_gauche:
#include "zsprites/player/courtGauche2.bmp"
megaman_court_fin_gauche:
#include "zsprites/player/courtGauche3.bmp"
megaman_tire_gauche:
#include "zsprites/player/tireGauche.bmp"
megaman_tombe_gauche:
#include "zsprites/player/tombeGauche.bmp"
megaman_saut_gauche:
#include "zsprites/player/sautGauche.bmp"
megaman_slide_gauche:
#include "zsprites/player/slideGauche.bmp"
megaman_mur_gauche:
#include "zsprites/player/murGauche.bmp"
megaman_grimpe:
#include "zsprites/player/grimpe1.bmp"
end_sprites_left:


megaman_regarde_droite:
#include "zsprites/player/regardeDroite.bmp"
megaman_trebuche_droite:
#include "zsprites/player/courtDroite1.bmp"
megaman_court_droite:
#include "zsprites/player/courtDroite2.bmp"
megaman_court_fin_droite:
#include "zsprites/player/courtDroite3.bmp"
megaman_tire_droite:
#include "zsprites/player/tireDroite.bmp"
#include "zsprites/player/tombeDroite.bmp"
#include "zsprites/player/sautDroite.bmp"
#include "zsprites/player/slideDroite.bmp"
#include "zsprites/player/murDroite.bmp"

megaman_mort:
#include "zsprites/player/mort.bmp"
