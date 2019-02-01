;########################################################
;# [megaBossData.asm]
;#-------------------------------------------------------
;# ROUTINES CONTENUES:
;# AUCUNE !
;#-------------------------------------------------------
;# DONNEES CONTENUES:
;#-------------------------------------------------------
;# bossJumpTable:
;#  Permet d'avoir des hauteurs de saut et des vitesses 
;#  différentes pour chaque boss.
;#  Allow a different jump and speed for each boss
;#-------------------------------------------------------
;# bossActions:
;#  Ce sera les actions du boss, au lancement du boss,
;#  nous remplissons ces valeurs.
;#  Here is the place where we copy the boss actions
;#-------------------------------------------------------
;# bossActionsXXX:
;#  Les actions de XXX
;#  Boss XXX's actions
;#-------------------------------------------------------
;# bossFaiblesses:
;#  Les armes qui peuvent blesser plus ou moins les boss.
;#  The boss's weakness (which weapons hurt more and which hurt less)
;#-------------------------------------------------------

; Enjoy this game 

bossJumpTable:		;vélocité Y initiale,vélocité X
.db -90,32			;ice
.db -90,32			;gut
.db -90,32			;cut
.db -90,32			;elec
.db -90,32			;dive
.db -90,32			;fire
.db -120,64			;metal
.db -60,32			;wood
.db -90,32			;wily

;si on va utiliser du SMC, il serait mieux de le mettre la table dans saferam
bossActions:
.db 6			;combien d'actions y a-t-il ?
.db B_WAIT		;placeholder
.db B_WAIT		;placeholder
.db B_WAIT		;placeholder
.db B_WAIT		;placeholder
.db B_WAIT		;placeholder
.db B_WAIT		;placeholder

;jeter un coup d'oueil aux equates, cette liste doit suivre le même ordre
listeActions:
.dw actionWait
.dw actionJump
.dw actionRun
.dw actionWalk
.dw actionChase
.dw actionShootCutter
.dw actionShootIce
.dw actionShootFire
.dw actionShootGuts
.dw actionJumpGuts
.dw actionShootElec
.dw actionShootWood
.dw actionShootMetal
.dw actionEvadeMetal
.dw actionShootDive
.dw actionDive
.dw actionShootWalker
.dw actionTransform
.dw actionJumpWily
.dw actionThrowSpine
.dw actionRise
.dw actionShootHover
.dw actionRunWily
.dw actionStomp			;on ne l'utilise que quand megaman s'approche trop de Wily

;equates dans [megaBoss.asm]
bossActionsStart:
bossActionsIceman:
	.db 6                 ; Nb actions
	.db B_SHOOT_ICE
	.db B_RUN
	.db B_JUMP
	.db B_WALK
	.db B_CHASE
	.db B_SHOOT_ICE
bossActionsGutsman:
	.db 2				; Nb actions
	.db B_SHOOT_GUTS
	.db B_JUMP_GUTS
bossActionsCutman:
	.db 6                 ; Nb actions
	.db B_RUN
	.db B_JUMP
	.db B_WALK
	.db B_CHASE
	.db B_SHOOT_CUT
	.db B_SHOOT_CUT
bossActionsElecman:
	.db 6				; Nb actions
	.db B_RUN
	.db B_JUMP
	.db B_WALK
	.db B_CHASE
	.db B_SHOOT_ELEC
	.db B_SHOOT_ELEC
bossActionsDiveman:
	.db 2                 ; Nb actions
	.db B_SHOOT_DIVE
	.db B_DIVE
bossActionsFireman:
	.db 6                 ; Nb actions
	.db B_RUN
	.db B_JUMP
	.db B_WALK
	.db B_CHASE
	.db B_SHOOT_FIRE
	.db B_SHOOT_FIRE
bossActionsMetalman:
	.db 3                 ; Nb actions
	.db B_SHOOT_METAL
	.db B_EVADE_METAL
	.db B_JUMP
bossActionsWoodman:
	.db 1                 ; Nb actions
	.db B_SHOOT_WOOD
bossActionsWilyWalker:
	.db 3
	.db B_SHOOT_WALKER
;	.db B_RUN_WILY
	.db B_CHASE
	.db B_JUMP_WILY
bossActionsWilyHover:
	.db 5
	.db B_RISE
	.db B_SHOOT_HOVER
	.db B_RUN
	.db B_CHASE
	.db B_THROW_SPINE


;-2	= remplir HP
;-1	= 0 HP			(pas effectif)
;0	= 1 HP			(faible)
;1	= normal
;2	= x2			(effectif)
;3	= x3			(très effectif)
bossFaiblesses:
;	B	I	G	C	E	D	F	M	W
.db	0,	0,	-1,	1,	1,	1,	2,	1,	1	;iceman
.db	0,	1,	-1,	1,	1,	1,	1,	1,	2	;gutsman
.db	0,	1,	-1,	1,	2,	1,	1,	1,	1	;cutman
.db	0,	1,	-1,	1,	-2,	1,	1,	2,	1	;elecman
.db	0,	1,	1,	1,	2,	1,	1,	1,	1	;diveman
.db	0,	1,	-1,	1,	1,	2,	-2,	1,	1	;fireman
.db	0,	1,	-1,	2,	1,	1,	1,	1,	1	;metalman
.db	0,	3,	-1,	1,	1,	1,	2,	1,	1	;woodman
.db	0,	1,	1,	1,	1,	1,	1,	1,	1	;wily
