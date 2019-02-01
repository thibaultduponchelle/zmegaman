;########################################
;#			MEGAMAN 83
;# 	Please use whatever you want of this code for whatever you want as if it were
;# your own (consider it yours). The code is here to help you learn, fix my
;# mistakes, play with, add new features, use in your own programs, etc. If you
;# have any questions about anything, please contact me.
;# 	This code has no copyright (yuck) and belongs to no one. Or if you prefer, it belongs to everyone.
;# 	Enjoy!
;#
;#  Ce code est à tout le monde et pour tout le monde !
;#
;#	Este programa es tuyo, haz con el lo que te de la gana!
;########################################

;################## QUELQUES IDEES ##################
;1.	dans map_get, il y a une tuile qui te fait mal. il y a 4 pixels qui forme un bloc, et 4 un pic
;	quand on tombe là-dessus, je veux que le personnage soit sur le bloc (4 pixels en haut) et pas
;	sur la terre

;########### IL FAUT CREER DE L'ESPACE POUR MAP (OU NOUS METTONS LES MAPS DECOMPRIMES) #################
;pour le moment, j'ai ajouté 4000 octets à la fin du programme pour éviter des plantages après avoir
; quitté le jeu



;########################################################
;# [megaMan.asm]
;#-------------------------------------------------------
;# ROUTINES CONTENUES:
;#-------------------------------------------------------
;# initialiser:
;#  Init the game
;#-------------------------------------------------------
;# drawGbuf:
;#  Dessiner le gbuf
;#  Draws the gbuf
;#-------------------------------------------------------
;# main:
;#  Le main banane
;#  The main 
;#-------------------------------------------------------
;# tu_as_perdu:
;#  La methode appelée quand on perd
;#  The method called when you lose
;#-------------------------------------------------------
;#  Puis des includes, des constantes et tout le toutim
;#  Then includes consts and more
;#-------------------------------------------------------

; There are only two types of people in the world, those that understand binary 
;	and those that don't...
; La vida no debe de ser vista, debe ser vivida, exprimida, rebañada como un plato
;	de comida racionada, que cuando se te acabe el tiempo no te falte nada

#include "zincludes/ti83plus.inc"
#include "zincludes/ion.inc"

.org progstart-2
.db t2ByteTok, tasmCmp

#DEFINE 83P

_FillBasePageTable	= $5011	;used to clean up saferam used
_GrReset			= $4831
_ZeroFinanceVars	= $512B
_NZIf83Plus   		= $50E0

;##### CONSTANTS #####
BULLET_SPEED = 32*3		;vitesse des balles
MAX_HP		= 13		;max hp du joueur
HP_TIMER	= 40		;combien de frames à afficher la barre d'HP
EP_TIMER	= HP_TIMER	;combien de frames à afficher la barre d'énergie quand on tire avec une arme spéciale
BHP_TIMER	= HP_TIMER	;boss HP
MAX_EP		= 15
MAX_BOSS_HP	= 26
STARTING_LIVES	= 3		;avec combien de vies va-t-on commencer ?

;balle CONSTANTS
BALLE_XOFF	= 0		;(ix+BALLE_XOFF) etc.
BALLE_X		= 1
BALLE_YOFF	= 2
BALLE_Y		= 3
BALLE_TYPE	= 4
BALLE_VELX	= 5		;+ vers la droite, - vers la gauche
BALLE_VELY	= 6
BALLE_AC	= 7		;animation counter
BALLE_AF	= 8		;animation frame
BALLE_EXTRA	= 9
;bullet types:
BMEGAMAN		= 0
BMEGAICEL		= 1	;une vers la gauche, une vers la droite
BMEGAICER		= 2
BMEGAGUTS		= 3
BMEGACUT		= 4
BMEGAELEC		= 5
BMEGADIVE		= 6
BMEGAFIRE		= 7	;la balle que l'on tire
BMEGAFIRESHIELD	= 8	;les balles de feu qui entourent Megaman
BMEGAMETAL		= 9
BMEGAWOOD		= 10
BMECHANT		= BMEGAWOOD+1
BOSS_BULLETS	= BMECHANT+1	;starting id of boss bullets
BCUTMAN			= BOSS_BULLETS
BICEMANL		= BOSS_BULLETS+1	;left
BICEMANR		= BOSS_BULLETS+2	;right
BGUTSMANL		= BOSS_BULLETS+3
BGUTSMANR		= BOSS_BULLETS+4
BGUTSMANBLOCK	= BOSS_BULLETS+5
BELECMANL		= BOSS_BULLETS+6
BELECMANR		= BOSS_BULLETS+7
;BDIVEMAN		;la balle de Diveman c'est en réalité un méchant
BFIREMANL		= BOSS_BULLETS+8
BFIREMANR		= BOSS_BULLETS+9
BFIREMANFLAME	= BOSS_BULLETS+10
BMETALMAN		= BOSS_BULLETS+11
BWOODMAN		= BOSS_BULLETS+12
BWOODMANFALL	= BOSS_BULLETS+13
BWALKERL		= BOSS_BULLETS+14
BWALKERR		= BOSS_BULLETS+15
BWALKEREXPL		= BOSS_BULLETS+16
BWALKEREXPR		= BOSS_BULLETS+17
BHOVERCHASE		= BOSS_BULLETS+18
BMACHINEGUN		= BOSS_BULLETS+19

SLIDE_SKIP 		= 80	;nombre de pixels à sauter ("vitesse" du slide) (80/32 = 2.5 pixels à la fois)
SLIDE_DISTANCE	= 16	;combien de distance Megaman glisse
DAMAGE_INV		= $38	;nombre de frames pendant lesquels Megaman est invincible après avoir se fait mal
ACCELERATION	= 8		;combien incrémenter la vélocité X chaque frame qu'on appuie sur une touche. 32 = avancer un pixel
GRAVITY			= 10	;
JUMP_VEL		= 105
MAX_SPEED		= 64	;vélocité max
BOSS_DMG_FRAMES = 10

;flags
zFlags		= asm_Flag1
jumpStart	= 0		;si on saute ou non
runSuccess	= 1		;si le joueur a poussé [<-] ou [->]
onGround	= 2		;si on a sur terre
onWall		= 3		;si on glisse ou non
upPressed	= 4		;si la touche up est apuyé (désarmé quand on relâche la touche)
bossBattle	= 5		;on est dans une bataille de boss ou dans un script
weaponHead	= 6		;quelques bosses ont une arme sur la tête

;saferam1		=$86EC	;saveSScreen=768 array de méchants
;saferam2		=$8A3A	;statVars=531 boss et balles
;saferam3		=$8508	;textShadow=128 datas sur joueur
;saferam4		=$8478	;OPs=66
;saferam5		=$84D3	;iMathPtrs=10
;saferamp		=$9872	;appBackUpScreen=768	saferamroutines
;saferamp2		=$8251	;bootTemp=52	XXXX utilisé dans gbuf
;gbuf			=$9340	;768 DISPONIBLE (après title screen)
;graphVariables =$8E67	;1179 : 494+126(financeVars)+108(smallEditRAM)+157(plus de graphs)+294(tableStuff)

;##### VARIABLES #####
megaGbuf = appData	;$8000 13*72 = 936 octets

;playerY [megaPlayer.asm]		;2 octets: premier octet est aligné à la carte (8 pixels), 2ème
;playerX						; contient 3 bits pour l'offset X/Y et 5 bits de "fractions"
								; %XXXXXXXX,%XXX.XXXXX

;**Pas de _PutS parce que ce bcall effacera nos datas dans textShadow**
initSP			= saferam3			;2 octets, sauver valeur de la pile pour quitter facilement
mainSP			= initSP+2			;position du SP dans la boucle main
velocityY		= mainSP+2			;saferam3 = 128 bytes (textShadow) $8478
velocityX		= velocityY+1		;la valeur que nous ajoutons pour faire avancer le joueur
slideFrames		= velocityX+1
damageFrames	= slideFrames+1		;nombre de frames à "flasher" le sprite du personnage quand il reçoit du dommage
playerAnimation = damageFrames+1	;frame d'animation
animCounter		= playerAnimation+1	;animation des tuiles
pushPlayer		= animCounter+1		;il faut armé pushPlayer si le boss va pousser megaman
spriteHeight_ptr	= pushPlayer+1	;sauvegarder le pointeur au sprite actuel d'un méchant
prevSpriteHeight	= spriteHeight_ptr+2	;hauteur du sprite antérieur (pour faire des calculs)
nombreMechants	= prevSpriteHeight+1		;combien de méchants une carte contient
actionEtat		= nombreMechants+1	;l'action actuelle du boss: $FF = pas d'action
bulletHeight	= actionEtat+1
shock			= bulletHeight+1	;pour Gutsman, si tu es sur le sol quand la pièce tremble
bossShield		= shock+1			;si le boss est en train de se proteger
keyPressSave	= bossShield+1		;garder les touches poussées pour utiliser pour l'arme de Metalman
HPTimer			= keyPressSave+1	;combien de frames à afficher la barre d'HP
EPTimer			= HPTimer+1			;combien de frames à afficher la barre d'énergie
BHPTimer		= EPTimer+1			;timer (chronomètre) pour l'HP du boss
weaponDelay		= BHPTimer+1		;le délai entre une balle et une autre
weaponEnergy	= weaponDelay+1
iceEnergy		= weaponEnergy
gutsEnergy		= weaponEnergy+1
cutEnergy		= weaponEnergy+2
elecEnergy		= weaponEnergy+3
diveEnergy		= weaponEnergy+4
fireEnergy		= weaponEnergy+5
metalEnergy		= weaponEnergy+6
woodEnergy		= weaponEnergy+7
slideParticles	= woodEnergy+1		;pour quand on glisse sous un mur
numSlideParticles = slideParticles+35
particles		= numSlideParticles+1	;pour l'attaque du Dr. Wily
numParticles	= particles+16
itemsFound		= numParticles+1	;2 octets chaque niveau, premier octet pour une énergie, le deuxième pour un one-up

;saferam5 a 10 octets $84D3
playerHP		= saferam5			;1 HP du joueur
bossesBeat		= playerHP+1		;bit 0 = map 1, bit 1 = map 2, etc. Si tu as gagné les niveaux 1 5 et 6: %00110001
selectedWeapon	= bossesBeat+1		;l'arme actuelle de Megaman
energyTanks		= selectedWeapon+1	;combien de tanques d'énergie Megaman a
playerLives		= energyTanks+1

;boss equates saferam 2 (statVars 500+ octets) 
bossInfo		= saferam2
bossVelX		= bossInfo			;velX du boss, velX = 32 bougera le boss un pixel par frame. vX = 48 le bougera 3 pixels chaque 2 frames
bossVelY		= bossVelX+1		;velY
bossHP			= bossVelY+1
hoverGrav		= bossHP+1			;gravité du Dr. Wily
hoverVel		= hoverGrav+1		;autre variable de gravité pour Wily
bossAnimCounter = hoverVel+1		;le compteur pour l'animation du boss
counter			= bossAnimCounter+1	;pour les evenements, un compteur qui dit combien de frames le boss va faire une action
bossDamage		= counter+1			;combien de frames le boss reste invincible après le faire dommage
numberBullets	= bossDamage+1		;combien de balles on a tiré
bulletArray		= numberBullets+1	;bulletArray a besoin d'au moins 100 octets
									;chaque balle: mapX,mapXOffset,mapY,mapYOffset,velX,velY
;méchants
mechantArray	= saferam1			;chaque méchant occupe 11 octets

saferamRoutines	= appBackUpScreen	;on garde quelques routines ici pour gagner de l'espace
saferamRoutines2= $8E67				;graphvars, etc. 1179 octets

;direct input equates:
groupe1 = $FE				;arrow keys

groupe2 = $FD
diClear	= 191

groupe6 = $DF
diAlpha	= 127

groupe7 = $BF
diY		= 239
di2nd	= 223
diMode	= 191

	xor a
	jr nc,start1
.db "zMegaman",0
start1:
	call disable_c000_protection
	ld hl,initSP
	ld (hl),0
	ld de,initSP+1
	ld bc,127
	ldir
	ld (initSP),sp			;sauver la pile

	ld hl,4000
	bcall(_EnoughMem)
	 jp c,notEnoughMem
	ex de,hl
	ld de,map
	bcall(_InsertMem)
start:
	bcall(_RunIndicOff)
	di
;charger quelques routines dans saferam pour ouvrir de l'espace
	ld hl,saferam_start
	ld de,saferamRoutines
	ld bc,768
	ldir
	call initialiser
	call title_print
	 jp z,loadGame
startGame:
	ld b,1
	call loadText		;[megaDemo.asm]
	xor a
	ld (bossesBeat),a			;aucun boss gagné (pas encore !)
	ld (selecteur),a
	ld (selectedWeapon),a		;le buster = 0
	ld (energyTanks),a

	ld hl,playerLives
	ld (hl),STARTING_LIVES		;on commence avec 3 vies
;#########################################
;	ld a,$FF
;	ld (bossesBeat),a
;#########################################
	jp bossSelect

initialiser:
	ld hl,velocityY
	ld (hl),0
	ld de,velocityY+1
	ld bc,(weaponEnergy-velocityY)-1
	ldir					;mettre à zéro toutes les valeurs entre velocityY et weaponEnergy-1 (BHPTimer)
	ld hl,bossInfo
	ld de,bossInfo+1
	ld (hl),0
	ld bc,500
	ldir					;mettre à zéro toutes les valeurs dans saferam4
	ld (iy+zFlags),0		;reset flags
	xor a
	ld (xOff),a
	ld (yOff),a
	ld (damageFrames),a
	dec a
	ld (actionEtat),a
;les timers
	ld hl,(EP_TIMER*256)+HP_TIMER
	ld (HPTimer),hl
	ld a,BHP_TIMER
	ld (BHPTimer),a
	jp updateRotation	;quand on change les x/y offsets, il faut appeler cette routine qui met à jour la routine de fastcopy

main:
	; Si hp == 0 alors game over
	ld (mainSP),sp
	ld hl,playerHP
	ld a,(hl)
	or a
	jr z,tu_as_perdu

	call desCarte
	call desPersonnage
	call desSlideParticles
	call desBalles
	call desMechants
	call desBarreHP
	call drawGbuf
	call keyCheck
	jp main

;2nd
waitKey:
	call waitKey_release
waitKey2:
	di
	ld a,$FF			;effacer le port
	out (1),a
	xor a				;n'importe laquelle touche
	out (1),a
;il faut relâcher les touches d'abord
	in a,(1)			; lire
	inc a				;si on n'a rien touché, a = $FF
	 jr nz,$-3			;$FF+1 = .. 0 !
	in a,(1)			;une autre lecture
	inc a
	 jr z,$-3
waitKey_release:
	 	dec a		;pour le "inc a"
		ld b,a		;sauver la touche poussée
		in a,(1)	;maintenant il faut relâcher la touche
		inc a		;sinon, il est probable que la prochaine routine l'utilise
		ld a,b		;a = la touche poussée
		 ret z		;
		jr $-5		;répéter jusqu'à ce que l'on a relâcher la touche

tu_as_perdu:
	call desBarreHP

	ld b,30
	ei
	halt
	di
	djnz $-3
	ld bc,(playerX)
	inc b
	ld de,(playerY)
	inc d
	ld a,BMEGAMAN
	call explodeBoss+2

	ld hl,playerLives
	dec (hl)
	 jp nz,deathScreen
	call transitionSetup
	ld hl,perduTexte
	call transitionMain
	ld hl,itemsFound
	ld (hl),0
	ld de,itemsFound+1
	ld bc,15
	ldir
	ld hl,energyTanks
	ld (hl),c					;remettre à zéro nombre de tanques d'énergies
	inc hl						;playerLives
	ld (hl),STARTING_LIVES		;on commence avec 3 vies
	ld sp,(initSP)
	jp bossSelect

tu_as_gagne:
	call centrerEcranSurBoss
	ld b,200
	ld hl,shockk
	inc (hl)
gagneLoop:
	push bc
		ld a,b
		and $15
		cp 4
		 jr nc,$+9
			ld hl,shockk
			inc (hl)
			call tremblerEcran
		call drawGbuf
	pop bc
	djnz gagneLoop

	ld b,3
	call loadText
	call waitKey
	call transitionSetup
	ld hl,gameFinished
	call transitionMain
	jp start

reset:
	ld sp,(initSP)
	jp start

notEnoughMem:
	ld sp,(initSP)
	bcall(_ClrLCDFull)
	bcall(_HomeUp)
	ld hl,notEnoughMem_txt
	bcall(_PutS)
	call waitKey2
	jr $+5					;_PutS utilise textShadow (ou initSP est sauvé)
quitter:
	ld sp,(initSP)
;	bcall(_FillBasePageTable)
	bcall(_ClrTxtShd)
	ld de,4000
	ld hl,map
	bcall(_DelMem)
	jp enable_c000_protection


drawGbuf:
    ld a,$80
    out ($10),a     ;fixer rang ($80: 0, to $BF:63)
    ld hl,megaGbuf-13+(13*64)-13
xOff = $+1
    ld a,0
yOff = $+1
    ld b,0
    inc b
    ld de,13
    add hl,de
    djnz $-4
    ld a,$20        ;$20: col 0, $2E: col 14
    ld c,a
    ld b,64         ;64 filas
fastCopyAgain:
    inc c           ;avanzar a proxima fila
    push bc
    ld de,-(13*64)
    out ($10),a     ;actualizar columna
    add hl,de
    ld de,12
    inc hl
fastCopyLoop:
    add hl,de
    ld a,(hl)       ;cargar valor en gbuf a a
rotLeft:
 .db 0,0,0,0            ;rotate the values we need
maskLeft = $+1
    and $FF         ;necesitamos los valores de la izquierda
    ld c,a
    inc hl
    ld a,(hl)       ;el proximo byte que llena el resto del primero
rotRight:
 .db 0,0,0,0
maskRight = $+1
    and 0
    or c
    out ($11),a
    djnz fastCopyLoop
    pop bc
    ld a,c
    cp $2B+1
    jr nz,fastCopyAgain
    ret

#include "megaHack.asm"				;merci à Brian Coventry/thepenguin77

;#include "megaKeyLoop.asm"
#include "megaMapMovement.asm"
#include "megaPlayer.asm"
#include "megaPlayerMovement.asm"
#include "megaBullet.asm"
#include "megaMath.asm"
;#include "megaTileMap.asm"			;dans [megaSaferamRoutines.inc]
#include "megaEnnemies.asm"
;#include "megaSpriteRoutines.asm"	;dans [megaSaferamRoutines.inc]
#include "megaBoss.asm"
#include "megaBossSelect.asm"
#include "megaScript.asm"
#include "megaItems.asm"
#include "megaTitle.asm"
;#include "megaSaveData.asm"		;dans [megaSaferamRoutines.inc]
;#include "megaLoadData.asm"		;dans [megaSaferamRoutines.inc]
#include "megaDemo.asm"
#include "megaMenu.asm"
#include "megaWily.asm"				;quelques routines pour la bataille finale
#include "megaTransitions.asm"

.echo "Mémoire restante: ",$C000-$

#include "megaTitlePicture.inc"
#include "ztilemap/megaSprites.inc"
#include "megaSprites.asm"
#include "megaEnemyData.inc"
#include "megaScriptData.inc"
#include "megaBossData.inc"
#include "megaSaferamRoutines.inc"

bulletPathTable:
.dw pathMegaCut
.dw pathElecman
.dw pathMegaDive
.dw pathMegaFire
.dw pathMegaFireShield
.dw retJump
.dw pathMegaWood
.dw retJump			;méchant
.dw pathCutman
.dw pathIceman		;left
.dw pathIceman		;right
.dw pathGutsman		;left
.dw pathGutsman		;right
.dw retJump			;gutsmanblock
.dw pathElecman		;left
.dw pathElecman		;right
.dw pathFireman		;left
.dw pathFireman		;right
.dw pathFiremanFlame
.dw pathMetalman
.dw pathWoodman
.dw pathWoodmanFall
.dw pathWalker		;left
.dw pathWalker		;right
.dw pathWalkerExplosion		;la balle occupe deux sprites
.dw pathWalkerExplosion
.dw pathHoverChase	;la bombe après persuivre megaman
.dw pathMachineGun

bulletSprites:				;tous dans [tilemap/megaSprites.inc]
.dw bullet					;type 0: megaman's normal bullet
.dw weaponIcemanL			;type 1: iceman left
.dw weaponIcemanR			;type 2: iceman right
.dw weaponGutsmanBlock		;type 3: broken boulder pieces
.dw weaponCutman			;type 4: cutman
.dw weaponElecmanSmall		;type 5: left part of bolt
.dw weaponDiveman			;type 6:
.dw weaponFiremanFlame		;type 7:
.dw weaponFiremanFlame		;type 8:
.dw weaponMetalman			;type 9:
.dw weaponWoodman			;type 10:
.dw bullet					;type 11: balle normale des méchants
.dw weaponCutman			;type 12: cutman
.dw weaponIcemanL			;type 13: iceman left
.dw weaponIcemanR			;type 14: iceman right
.dw weaponGutsmanL			;type 15: left side of boulder
.dw weaponGutsmanR			;type 16: right side of boulder
.dw weaponGutsmanBlock		;type 17: broken boulder pieces
.dw weaponElecmanL			;type 18: left part of bolt
.dw weaponElecmanR			;type 19: right part of bolt
;.dw dive					;la balle de Diveman est un méchant, pas une balle ;)
.dw weaponFiremanL			;type 20: fireman vers la gauche
.dw weaponFiremanR			;type 21:
.dw weaponFiremanFlame		;type 22: apparaît dessous
.dw weaponMetalman			;type 23:
.dw weaponWoodman			;type 24: le cercle
.dw weaponWoodman			;type 25: les feuilles qui tombent du ciel
.dw weaponWalkerL			;type 26: missiles du walker de Wily
.dw weaponWalkerR			;type 27:
.dw weaponWalkerExplosionL	;type 28: l'explosion quand un missile touche quelque chose
.dw weaponWalkerExplosionR	;type 29: 
.dw weaponHoverChase		;type 30: l'arme quand Wily te persuit
.dw weaponMachineGun		;type 31:

bullet:
.db 4						;hauteur de balle
.db 01100000b
.db 10010000b
.db 10010000b
.db 01100000b


press_any_key:
.db "Press any key...",0
loadGameText:
.db "2nd: load game", 0
RAMText:
.db "Warning: savegame in RAM",0
.db "Press Alpha to archive",0
le_boss_est_mort:
.db "Stage completed...", 0
perduTexte:
.db "Can it really be?",0
presser_enter_pour_continuer:
.db "Don't give up! Press any key...", 0
gameFinished:
.db "Wow... is it really over?",0
saveText:
.db "Alpha: save game",0
saveFile:
.db AppVarObj,"zMegaman",0
megaData_txt:
.db ProgObj,"ZMEGADAT",0
notEnoughMem_txt:
.db "Not enough mem, "
.db "need 4kb free   "
.db "RAM",0

gbufMask:
.db %11111111   ;0 display all of the first byte, none of the second
.db %11111110   ;1 after rotating left once, we only want the 7 leftmost bits of byte 1, and rightmost bit of byte 2
.db %11111100   ;2
.db %11111000   ;3
.db %11110000   ;4
.db %11100000   ;5
.db %11000000   ;6
.db %10000000   ;7

map:
;.fill 4000,0
bossSpritesFlipped = map+2500

