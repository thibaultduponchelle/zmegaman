;########################################################
;# [megaLevels.asm]
;#-------------------------------------------------------
;# ROUTINES CONTENUES:
;# AUCUNE !
;#-------------------------------------------------------
;# DONNEES CONTENUES:
;#-------------------------------------------------------
;# table des niveaux :
;#  Emplacement de départ, addresse map
;#  Place where rock appears, map adress
;#-------------------------------------------------------
;# Inclusion des maps:
;#  Les maps en tant que tel (compressées en rle)
;#  Includes the maps (rle compressed)
;#-------------------------------------------------------
;# mechXXX:
;#  Les méchants de chaque map
;#  The ennemies of each level
;#-------------------------------------------------------
;# Puis inclusion megaText.inc 
;# Then includes megaText.inc 
;#-------------------------------------------------------


; Please respect my authority !

; Boum .org $0000
.org $0000

;table des niveaux \/checkpoint coordinées
;	mY,mX  pY,pX  mapChk plyChk
.dw $0000, $0303, $0319, $0720, map_ice_rle,		mechIceman		;1
.dw $0500, $0903, $2918, $2D1E, map_gut_rle-12,		mechGutman-12	;2
.dw $0100, $0502, $5C17, $611D, map_cut_rle-24,		mechCutman-24	;3
.dw $0101, $0202, $5C01, $6105, map_elec_rle-36,	mechElecman-36	;4
.dw $0000, $0201, $0333, $0737, map_dive_rle-48,	mechDiveman-48	;5
.dw $0100, $0505, $0317, $071D, map_fire_rle-60,	mechFireman-60	;6
.dw $0100, $0505, $0394, $079C, map_metal_rle-72,	mechMetalman-72	;7
.dw $0100, $0505, $0356, $075C, map_wood_rle-84,	mechWoodman-84	;8
.dw $0030, $0333, $0030, $0333, final_rle-96,		mechNone-96		;9
.dw $0300, $0801, $FFFF, $FFFF, map_boss-108,		mechNone-108	;10

;table des textes
.dw intro_text-121
.dw final_text-123
.dw wily_text-125

;début des sprites de boss
.dw boss_sprite_start-127

#include "ztilemap/map_ice_rle.inc"
#include "ztilemap/map_gut_rle.inc"
#include "ztilemap/map_cut_rle.inc"
#include "ztilemap/map_elec_rle.inc"
#include "ztilemap/map_dive_rle.inc"
#include "ztilemap/map_fire_rle.inc"
#include "ztilemap/map_metal_rle.inc"
#include "ztilemap/map_wood_rle.inc"
#include "ztilemap/final_rle.inc"

map_boss:
bossMapCutman:
bossMapElecman:
bossMapFireman:
bossMapIceman:
bossMapMetalman:
bossMapWoodman:
bossMapDiveman:
bossMapGutsman:
.db 11,18
.db 18,1	;0
.db 1,1,16,0,1,1	;1
.db 1,1,16,0,1,1	;2
.db 1,1,16,0,1,1	;3
.db 1,1,16,0,1,1	;4
.db 1,1,16,0,1,1	;5
.db 1,1,16,0,1,1	;6
.db 1,1,16,0,1,1	;7
.db 1,1,16,0,1,1	;8
.db 1,1,16,0,1,1	;9
.db 18,1	;10
.db 0

;il faut avoir une copie de ces defines dans [megaLevels.asm] aussi
TURRET_L	= 0	;shield
TURRET_R	= 1	;shield
OCTOPUS		= 2
BLADER		= 3
SCREW		  = 4
FLYING		= 5 ;shield
DIVE		  = 6	;l'arme de Diveman
EXPLOSION	= 7
FLEA		  = 8	;shield
MET			  = 9	;shield
SPINE		  = 10
END_MECHANTS = SPINE

ITEM_START	= END_MECHANTS+1
HEALTH_S	  = ITEM_START	;small
HEALTH_L	  = ITEM_START+1	;large
ENERGY_S	  = ITEM_START+2	;small
ENERGY_L	  = ITEM_START+3	;large
ENERGY_TANK	= ITEM_START+4	;tanque d'énergie
ONE_UP		  = ITEM_START+5	;extra vie
NOMBRE_ITEMS= ONE_UP-END_MECHANTS

;.db mechantID, mechantX, mechantXOff, mechantY, mechantYOff, xVel, yVel, HP, frame d'animation
;		ID			X	Y	YOf	XV	YV	HP
mechIceman:
	.db 23			 						;nombre de méchants
	.db	SPINE,		10,	95,	32,	32,	0,	1	;spine
	.db	TURRET_L,	35,	68,	0,	0,	0,	1
	.db	TURRET_L,	35,	70,	0,	0,	0,	1	
	.db	TURRET_L,	35,	72,	0,	0,	0,	1
	.db	TURRET_L,	16,	34,	0,	0,	0,	1
	.db	TURRET_L,	21,	6,	0,	0,	0,	1
	.db	OCTOPUS,	7,	1,	0,	0,	0,	5	;octopus
	.db	OCTOPUS,	33,	46,	0,	0,	0,	5	;octopus
	.db	OCTOPUS,	35,	85,	0,	0,	0,	5	;octopus
	.db	OCTOPUS,	31,	84,	0,	0,	0,	5	;octopus
	.db	OCTOPUS,	29,	70,	0,	0,	0,	5	;octopus
	.db	BLADER,		24,	90,	0,	0,	0,	1
	.db	BLADER,		22,	88,	0,	0,	0,	1
	.db	BLADER,		26,	13,	0,	0,	0,	1
	.db	BLADER,		23,	12,	0,	0,	0,	1
	.db	BLADER,		19,	13,	0,	0,	0,	1
	.db	BLADER,		13,	12,	0,	0,	0,	1
	.db	SCREW,		20,	29,	0,	0,	0,	1
	.db	SCREW,		26,	54,	0,	0,	0,	1
	.db	SCREW,		21,	54,	0,	0,	0,	1
	.db	FLEA,		5,	59,	0,	0,	0,	1
	.db	FLEA,		8,	59,	0,	0,	0,	1
	.db ENERGY_TANK,5,	63,	0,	0,	0,	-1

mechGutman:
	.db 43
;		ID			X	Y	YOf	XV	YV	HP
	.db	FLEA,		18,	9,	$80,0,	0,	1
	.db	FLEA,		14,	11,	$80,0,	0,	1
	.db	FLEA,		12,	10,	$80,0,	0,	1
	.db	FLEA,		2,	46,	$80,0,	0,	1
	.db	FLEA,		6,	46,	$80,0,	0,	1
	.db	FLEA,		10,	46,	$80,0,	0,	1
	.db	FLEA,		12,	47,	$80,0,	0,	1
	.db	FLEA,		13,	48,	$80,0,	0,	1
	.db	FLEA,		14,	49,	$80,0,	0,	1
	.db	FLEA,		15,	50,	$80,0,	0,	1
	.db MET,		20,	30,	0,	0,	0,	1
	.db MET,		15,	24,	0,	0,	0,	1
	.db MET,		6,	22,	0,	0,	0,	1
	.db MET,		32,	29,	0,	0,	0,	1
	.db MET,		32,	23,	0,	0,	0,	1
	.db MET,		10,	63,	0,	0,	0,	1
	.db MET,		13,	55,	0,	0,	0,	1
	.db MET,		34,	63,	0,	0,	0,	1
	.db MET,		9,	42,	0,	0,	0,	1
	.db MET,		13,	42,	0,	0,	0,	1
	.db MET,		17,	42,	0,	0,	0,	1
	.db FLYING,		23,	7,	0,	0,	0,	1
	.db FLYING,		13,	29,	0,	0,	0,	1
	.db FLYING,		24,	28,	0,	0,	0,	1
	.db FLYING,		30,	63,	0,	0,	0,	1
	.db SPINE,		1,	35,	32,	32,	0,	1
	.db SPINE,		18,	35,	32,	32,	0,	1
	.db TURRET_L,	25, 29,	0,	0,	0,	1	
	.db TURRET_L,	25, 31,	0,	0,	0,	1	
	.db TURRET_L,	25, 33,	0,	0,	0,	1	
	.db TURRET_L,	25, 35,	0,	0,	0,	1	
	.db TURRET_L,	38, 23,	0,	0,	0,	1	
	.db TURRET_L,	38, 25,	0,	0,	0,	1	
	.db TURRET_L,	34, 51,	0,	0,	0,	1	
	.db TURRET_L,	34,	52,	0,	0,	0,	1
	.db TURRET_L,	34,	53,	0,	0,	0,	1
	.db TURRET_L,	18,	47,	0,	0,	0,	1
	.db TURRET_L,	18,	45,	0,	0,	0,	1
	.db	SCREW,		7,	40,	0,	0,	0,	1
	.db	SCREW,		11,	40,	0,	0,	0,	1
	.db	SCREW,		15,	40,	0,	0,	0,	1
	.db	SCREW,		19,	40,	0,	0,	0,	1
	.db ONE_UP,		0,	49,	0,	0,	0,	-1

mechCutman:
	.db 41
;		ID			X	Y	YOf	XV	YV	HP
	.db TURRET_L,	35,	4,	0,	0,	0,	1
	.db TURRET_L,	35, 32,	0,	0,	0,	1
	.db TURRET_L,	35, 34,	0,	0,	0,	1
	.db TURRET_L,	35, 36,	0,	0,	0,	1
	.db TURRET_L,	32, 46,	0,	0,	0,	1
	.db TURRET_L,	35, 57,	0,	0,	0,	1
	.db TURRET_L,	35, 59,	0,	0,	0,	1
	.db TURRET_L,	35, 55,	0,	0,	0,	1
	.db TURRET_L,	13, 67,	0,	0,	0,	1
	.db TURRET_L,	13, 65,	0,	0,	0,	1
	.db TURRET_R,	1,	47,	0,	0,	0,	1
	.db TURRET_R,	1,	48,	0,	0,	0,	1
	.db TURRET_R,	1,	49,	0,	0,	0,	1
	.db TURRET_R,	15,	66,	0,	0,	0,	1
	.db TURRET_R,	1,	83,	0,	0,	0,	1
	.db BLADER,		9,	5,	0,	0,	0,	1
	.db BLADER,		12,	3,	0,	0,	0,	1
	.db BLADER,		25,	3,	0,	0,	0,	1
	.db BLADER,		24,	4,	0,	0,	0,	1
	.db BLADER,		24,	16,	0,	0,	0,	1
	.db BLADER,		13,	56,	0,	0,	0,	1
	.db BLADER,		11,	54,	0,	0,	0,	1
	.db BLADER,		9,	56,	0,	0,	0,	1
	.db BLADER,		8,	55,	0,	0,	0,	1
	.db BLADER,		22,	70,	0,	0,	0,	1
	.db SCREW,		25,	47,	0,	0,	0,	1
	.db SCREW,		26,	47,	0,	0,	0,	1
	.db SCREW,		27,	47,	0,	0,	0,	1
	.db SCREW,		28,	47,	0,	0,	0,	1
	.db SCREW,		6,	91,	0,	0,	0,	1
	.db SCREW,		10,	91,	0,	0,	0,	1
	.db SCREW,		14,	91,	0,	0,	0,	1
	.db SCREW,		18,	91,	0,	0,	0,	1
	.db SCREW,		17,	64,	0,	0,	0,	1
	.db SCREW,		20,	64,	0,	0,	0,	1
	.db FLYING,		32,	57,	0,	0,	0,	1
	.db FLYING,		21,	42,	0,	0,	0,	1
	.db SPINE,		18,	2,	32,	0,	0,	1
	.db SPINE,		22,	44,	32,	0,	0,	1
	.db SPINE,		3,	69,	32,	0,	0,	1
	.db ENERGY_TANK,18,	87,	0,	0,	0,	-1

mechElecman:
	.db 45
;		ID			X	Y	YOf	XV	YV	HP
	.db TURRET_R,	1,	29,	0,	0,	0,	1
	.db TURRET_R,	1,	31,	0,	0,	0,	1
	.db TURRET_R,	1,	33,	0,	0,	0,	1
	.db TURRET_R,	23,	67,	0,	0,	0,	1
	.db TURRET_R,	23,	68,	0,	0,	0,	1
	.db TURRET_R,	23,	69,	0,	0,	0,	1
	.db TURRET_L,	28,	18,	0,	0,	0,	1
	.db	TURRET_L,	28,	19,	0,	0,	0,	1
	.db	OCTOPUS,	10,	60,	0,	0,	0,	5
	.db	OCTOPUS,	4,	61,	0,	0,	0,	5
	.db	OCTOPUS,	6,	61,	0,	0,	0,	5
	.db	OCTOPUS,	31,	14,	0,	0,	0,	5
	.db	OCTOPUS,	22,	19,	0,	0,	0,	5
	.db	OCTOPUS,	28,	1,	0,	0,	0,	5
	.db SCREW,		32,	60,	0,	0,	0,	1
	.db SCREW,		33,	60,	0,	0,	0,	1
	.db SCREW,		34,	60,	0,	0,	0,	1
	.db SCREW,		35,	60,	0,	0,	0,	1
	.db SCREW,		16,	85,	0,	0,	0,	1
	.db SCREW,		19,	85,	0,	0,	0,	1
	.db SCREW,		23,	85,	0,	0,	0,	1
	.db	FLYING,		18,	46,	0,	0,	0,	1
	.db	FLYING,		27,	46,	0,	0,	0,	1
	.db	FLYING,		38,	46,	0,	0,	0,	1
	.db FLEA,		12,	69,	0,	0,	0,	1
	.db FLEA,		15,	69,	0,	0,	0,	1
	.db FLEA,		16,	69,	0,	0,	0,	1
	.db FLEA,		8,	63,	0,	0,	0,	1
	.db FLEA,		5,	63,	0,	0,	0,	1
	.db BLADER,		23,	10,	0,	0,	0,	1
	.db BLADER,		24,	8,	0,	0,	0,	1
	.db BLADER,		4,	28,	0,	0,	0,	1
	.db BLADER,		6,	30,	0,	0,	0,	1
	.db BLADER,		9,	28,	0,	0,	0,	1
	.db BLADER,		9,	30,	0,	0,	0,	1
	.db BLADER,		11,	29,	0,	0,	0,	1
	.db BLADER,		9,	10,	0,	0,	0,	1
	.db BLADER,		7,	10,	0,	0,	0,	1
	.db BLADER,		23,	10,	0,	0,	0,	1
	.db BLADER,		24,	79,	0,	0,	0,	1
	.db BLADER,		32,	80,	0,	0,	0,	1
	.db BLADER,		33,	82,	0,	0,	0,	1
	.db SPINE,		21,	82,	32,	0,	0,	1
	.db ENERGY_TANK,25,	41,	0,	0,	0,	-1
	.db ONE_UP,		35,	72,	0,	0,	0,	-1

mechDiveman:
	.db 17
;		ID			X	Y	YOf	XV	YV	HP
	.db BLADER,		8,	18,	0,	0,	0,	1
	.db BLADER,		30,	16,	0,	0,	0,	1
	.db BLADER,		31,	2,	0,	0,	0,	1
	.db BLADER,		47,	11,	0,	0,	0,	1
	.db BLADER,		46,	12,	0,	0,	0,	1
	.db MET,		32,	15,	0,	0,	0,	1
	.db MET,		11,	4,	0,	0,	0,	1
	.db MET,		76,	16,	0,	0,	0,	1
	.db MET,		98,	11,	0,	0,	0,	1
	.db MET,		97,	12,	0,	0,	0,	1
	.db SCREW,		27,	1,	0,	0,	0,	1
	.db SCREW,		28,	1,	0,	0,	0,	1
	.db SCREW,		29,	1,	0,	0,	0,	1
	.db FLYING,		17,	16,	0,	0,	0,	1
	.db FLYING,		60,	12,	0,	0,	0,	1
	.db FLYING,		91,	16,	0,	0,	0,	1
	.db ENERGY_TANK,76,	2,	0,	0,	0,	-1

mechFireman: ;plus de fleas !
	.db 19
	.db SPINE,		7,	92,	0, 32,	0,	1	
	.db MET,		27, 12,	0,	0,	0,	1
	.db TURRET_L,	35, 28,	0,	0,	0,	1	
	.db TURRET_L,	35, 13,	0,	0,	0,	1	
	.db FLEA,		17, 12,	0,	0,	0,	1
	.db BLADER,		5,	91,	0,	0,	0,	1
	.db BLADER,		15,	8,	0,	0,	0,	1
	.db BLADER,		9,	91,	0,	0,	0,	1
	.db BLADER,		14,	8,	0,	0,	0,	1
	.db BLADER,		9, 51,	0,	0,	0,	1
	.db BLADER,		14, 15,	0,	0,	0,	1
	.db BLADER,		15, 21,	0,	0,	0,	1
	.db BLADER,		31, 54,	0,	0,	0,	1
	.db BLADER,		28, 54,	0,	0,	0,	1
	.db SPINE,		19, 12,	0,	32,	0,	1
	.db FLEA,		16,  2,	0,	0,	0,	1
	.db FLEA,		16,  4,	0,	0,	0,	1
	.db ENERGY_TANK,10,	10,	0,	0,	0,	-1
	.db ONE_UP,	 	$23,92,	0,	0,	0,	-1 ; On ne le voit pas il est tout en bas a droite


mechMetalman:
	.db 20
	.db SPINE,	 	15, 10,	0, 32,	0,	1	
	.db TURRET_L,	23,	8,	0,	0,	0,	1	
	.db TURRET_L,	23,	6,	0,	0,	0,	1	
	.db SPINE,	 	56,	7,	0, 32,	0,	1	
	.db BLADER,	 	44,	5,	0,	0,	0,	1
	.db BLADER,	 	48,	4,	0,	0,	0,	1
	.db BLADER,	 	52,	6,	0,	0,	0,	1
	.db TURRET_L,	80,	9,	0,	0,	0,	1	
	.db TURRET_L,	82,	6,	0,	0,	0,	1	
	.db SCREW,		83,	1,	0,	0,	0,	1
	.db BLADER,		104,3,	0,	0,	0,	1
	.db BLADER,		111,8,	0,	0,	0,	1
	.db BLADER,		117,8,	0,	0,	0,	1
	.db MET, 		125,3,	0,	0,	0,	1
	.db MET, 		142,4,	0,	0,	0,	1
	.db FLEA,		147,13,	0,	0,	0,	1
	.db FLEA,		150,13,	0,	0,	0,	1
	.db FLEA,		153,13,	0,	0,	0,	1
	.db FLEA,		156,13,	0,	0,	0,	1
	.db ONE_UP,		160,13,	0,	0,	0,	-1 ; Cache ou tu me l'as montre

mechWoodman:
	.db 45
	.db	FLEA,		7,	28,	0,	0,	0,	1
	.db	FLEA,		6,	28,	0,	0,	0,	1
	.db	FLEA,		5,	28,	0,	0,	0,	1
	.db	FLEA,		57,	25,	0,	0,	0,	1
	.db	FLEA,		55,	25,	0,	0,	0,	1
	.db	FLEA,		53,	25,	0,	0,	0,	1
	.db	FLEA,		74,	9,	0,	0,	0,	1
	.db	FLEA,		75,	10,	0,	0,	0,	1
	.db	FLEA,		76,	11,	0,	0,	0,	1
	.db	FLEA,		77,	12,	0,	0,	0,	1
	.db	OCTOPUS,	60,	8,	0,	0,	0,	5
	.db	OCTOPUS,	61,	5,	0,	0,	0,	5
	.db	OCTOPUS,	12,	7,	0,	0,	0,	5
	.db	TURRET_R,	12,	2,	0,	0,	0,	1
	.db	TURRET_R,	12,	4,	0,	0,	0,	1
	.db	TURRET_R,	26,	21,	0,	0,	0,	1
	.db	TURRET_R,	72,	2,	0,	0,	0,	1
	.db	TURRET_R,	72,	4,	0,	0,	0,	1
	.db	TURRET_R,	72,	6,	0,	0,	0,	1
	.db	TURRET_L,	98,	20,	0,	0,	0,	1
	.db	TURRET_L,	73,	21,	0,	0,	0,	1
	.db	TURRET_L,	34,	23,	0,	0,	0,	1
	.db	BLADER,		7,	25,	0,	0,	0,	1
	.db	BLADER,		38,	19,	0,	0,	0,	1
	.db	BLADER,		56,	8,	0,	0,	0,	1
	.db	BLADER,		55,	9,	0,	0,	0,	1
	.db	BLADER,		57,	22,	0,	0,	0,	1
	.db	BLADER,		55,	23,	0,	0,	0,	1
	.db	SCREW,		64,	4,	0,	0,	0,	1
	.db	SCREW,		63,	5,	0,	0,	0,	1
	.db	SCREW,		62,	6,	0,	0,	0,	1
	.db	SCREW,		58,	10,	0,	0,	0,	1
	.db	SCREW,		57,	11,	0,	0,	0,	1
	.db	SCREW,		56,	12,	0,	0,	0,	1
	.db	SCREW,		79,	6,	0,	0,	0,	1
	.db	SCREW,		11,	8,	0,	0,	0,	1
	.db	FLYING,		49,	5,	0,	0,	0,	1
	.db	FLYING,		29,	18,	0,	0,	0,	1
	.db	FLYING,		86,	22,	0,	0,	0,	1
	.db	MET,		56,	10,	0,	0,	0,	1
	.db	MET,		58,	8,	0,	0,	0,	1
	.db	MET,		44,	7,	0,	0,	0,	1
	.db	SPINE,		51,	12,	0,	32,	0,	1
	.db	SPINE,		26,	8,	0,	32,	0,	1
	.db ENERGY_TANK,30,	25,	0,	0,	0,	-1

mechNone:
.db 0

#include "megaText.inc"

;boss sprites:
boss_sprite_start:
bossSpritesIceman:
#include "zsprites/boss/iceman1.bmp"	;normale
#include "zsprites/boss/iceman2.bmp"	;cour 1
#include "zsprites/boss/iceman3.bmp"	;cour 2
#include "zsprites/boss/iceman4.bmp"	;saut
#include "zsprites/boss/iceman5.bmp"	;pose
#include "zsprites/boss/iceman5.bmp"	;pose
boss_sprite_end:
bossSpritesGutsman:
#include "zsprites/boss/gutsman1.bmp"	;normale
#include "zsprites/boss/gutsman2.bmp"	;cour 1
#include "zsprites/boss/gutsman3.bmp"	;cour 2
#include "zsprites/boss/gutsman3.bmp"	;saut
#include "zsprites/boss/gutsman4.bmp"	;pose
#include "zsprites/boss/gutsman2.bmp"	;pose
bossSpritesCutman:
#include "zsprites/boss/cutman1.bmp"	;normale
#include "zsprites/boss/cutman2.bmp"	;cour 1
#include "zsprites/boss/cutman3.bmp"	;cour 2
#include "zsprites/boss/cutman4.bmp"	;saut
#include "zsprites/boss/cutman5.bmp"	;pose
#include "zsprites/boss/cutman6.bmp"	;tire
bossSpritesElecman:
#include "zsprites/boss/elecman1.bmp"	;normale
#include "zsprites/boss/elecman2.bmp"	;cour 1
#include "zsprites/boss/elecman3.bmp"	;cour 2
#include "zsprites/boss/elecman4.bmp"	;saut
#include "zsprites/boss/elecman5.bmp"	;pose
#include "zsprites/boss/elecman6.bmp"	;tire
bossSpritesDiveman:
#include "zsprites/boss/diveman1.bmp"	;normale
#include "zsprites/boss/diveman2.bmp"	;cour 1
#include "zsprites/boss/diveman3.bmp"	;cour 2
#include "zsprites/boss/diveman4.bmp"	;saut
#include "zsprites/boss/diveman5.bmp"	;pose
#include "zsprites/boss/diveman6.bmp"	;tire
bossSpritesFireman:
#include "zsprites/boss/fireman1.bmp"	;normale
#include "zsprites/boss/fireman2.bmp"	;cour 1
#include "zsprites/boss/fireman3.bmp"	;cour 2
#include "zsprites/boss/fireman4.bmp"	;saut
#include "zsprites/boss/fireman5.bmp"	;pose
#include "zsprites/boss/fireman5.bmp"	;TODO
bossSpritesMetalman:
#include "zsprites/boss/metalman1.bmp"	;normale
#include "zsprites/boss/metalman2.bmp"	;cour 1
#include "zsprites/boss/metalman3.bmp"	;cour 2
#include "zsprites/boss/metalman4.bmp"	;saut
#include "zsprites/boss/metalman5.bmp"	;pose
#include "zsprites/boss/metalman6.bmp"	;tire
bossSpritesWoodman:
#include "zsprites/boss/woodman1.bmp"	;normale
#include "zsprites/boss/woodman2.bmp"	;cour 1
#include "zsprites/boss/woodman3.bmp"	;cour 2
#include "zsprites/boss/woodman4.bmp"	;saut
#include "zsprites/boss/woodman5.bmp"	;pose
#include "zsprites/boss/woodman5.bmp"	;pose
bossSpritesWilyWheelchair:
#include "zsprites/drwily/wheelchair_right.bmp"	;pose
#include "zsprites/drwily/wheelchair_right2.bmp";pose
#include "zsprites/drwily/wheelchair_right.bmp"	;pose
