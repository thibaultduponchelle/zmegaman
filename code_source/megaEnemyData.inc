;########################################################
;# [megaEnemyData.inc]
;#-------------------------------------------------------
;# ROUTINES CONTENUES:
;# AUCUNE !
;#-------------------------------------------------------
;# DONNEES CONTENUES:
;#-------------------------------------------------------
;# Une tartine de defines pour les ennemis
;# A bunch of defines for enemies stuff
;#-------------------------------------------------------

; Vice is our enemy

;il faut avoir une copie de ces defines dans [megaLevels.asm] aussi
TURRET_L	= 0	;shield
TURRET_R	= 1	;shield
OCTOPUS		= 2
BLADER		= 3
SCREW		= 4
FLYING		= 5 ;shield
DIVE		= 6	;l'arme de Diveman
EXPLOSION	= 7
FLEA		= 8	;shield
MET			= 9	;shield
SPINE		= 10
END_MECHANTS = SPINE

ITEM_START	= END_MECHANTS+1
HEALTH_S	= ITEM_START	;small
HEALTH_L	= ITEM_START+1	;large
ENERGY_S	= ITEM_START+2	;small
ENERGY_L	= ITEM_START+3	;large
ENERGY_TANK	= ITEM_START+4	;tanque d'énergie
ONE_UP		= ITEM_START+5	;extra vie
NOMBRE_ITEMS	= ONE_UP-END_MECHANTS


;Chaque méchant du même type devrait avoir le même HP, on peut faire une table avec tout ça
;ENEMY EQUATES
MECHANT_SPRITE	= 0
MECHANT_X		= 1
MECHANT_XOFF	= 2
MECHANT_Y		= 3
MECHANT_YOFF	= 4
MECHANT_XVEL	= 5
MECHANT_YVEL	= 6
MECHANT_HP		= 7
MECHANT_AF		= 8		;compteur d'animation
MECHANT_FRAME	= 9		;quel frame d'animation
MECHANT_EXTRA	= 10	;information extra sur le méchant
MECHANT_SIZE	= 11	;chargerMechantsBoucle,
MECH_ENTRY_SIZE	= 7		;dans la liste de méchants, chaque méchant occupe 7 octets

enemyActions:
.dw beakShoot			;0 left
.dw beakShoot			;1 right
.dw octopusShoot		;2
.dw bladerShoot			;3
.dw screwShoot			;4
.dw flyingShoot			;5
.dw divemanShoot		;6
.dw animateExplosion	;7
.dw fleaShoot			;8
.dw metShoot			;9
.dw spineShoot			;10

itemTable:
.dw itemSmallHealth
.dw itemLargeHealth
.dw itemSmallEnergy
.dw itemLargeEnergy
.dw itemEnergyTank
.dw item1Up


;il faut que ces deux tables aillent ensemble
tableMechantInvincible:
.db $FF					;rien
.db SPINE
NOMBRE_INVINCIBLES = $-tableMechantInvincible

tableMechantArmeur:
.db TURRET_L
.db TURRET_L
.db FLYING
.db FLEA
.db MET
.db SCREW
NOMBRE_ARMEURS = $-tableMechantArmeur

;l	= 0
;ul = 1
;u	= 2
;ur	= 3
;r	= 4
;dr	= 5
;d	= 6
;dl	= 7
diveVelocity:
.db -48,0
.db -48,-48
.db 0,-48
.db 48,-48
.db 48,0
.db 48,48
.db 0,48
.db -48,48
