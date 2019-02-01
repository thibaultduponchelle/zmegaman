;########################################################
;# [megaItems.asm]
;#-------------------------------------------------------
;# ROUTINES CONTENUES:
;# AUCUNE !
;#-------------------------------------------------------
;# Code execute lors de son inclusion
;# code executed when included 
;#-------------------------------------------------------
;# Ce code sert pour les bonus qui tombent lorsqu'on tue 
;# un ennemi
;# This code is for bonus dropped by enemies
;#-------------------------------------------------------

; Hey, I'm not a number, I'm a free man

;itemTable dans [megaEnemyData.inc]

;faire l'effet d'un item
;entrée:
; ix = pointeur à l'item
; a = numéro d'item
itemEffect:
	ld (ix+MECHANT_SPRITE),$FF
	ld hl,itemTable-(ITEM_START*2)
	add a,a
	ld c,a
	ld b,0
	add hl,bc
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	jp (hl)

itemSmallHealth:
	ld b,2
	jr itemHealth2
itemLargeHealth:
	ld b,5
itemHealth:
itemHealth2:
	ld hl,HPTimer
	ld (hl),HP_TIMER
	ld hl,playerHP
	ld a,(hl)
	add a,b
	ld (hl),a
	cp MAX_HP
	 ret c
	ld (hl),MAX_HP-1
	ret

itemSmallEnergy:
	ld d,2
	jr itemEnergy2
itemLargeEnergy:
	ld d,5
itemEnergy:
itemEnergy2:
	ld hl,EPTimer
	ld (hl),EP_TIMER
	call getWeaponPointer	;a = énergie d'arme actuelle, hl = pointer aux datas
	 ret z
	add a,d
	ld (hl),a
	cp MAX_EP
	 ret c
	ld (hl),MAX_EP
	ret

itemEnergyTank:
	ld c,0
	call iF_offset			;c = 0 : energy tank, c = 1 : one-up
	inc (hl)				;

	ld hl,energyTanks
check9:
	ld a,(hl)
	inc a
	cp 10
	 ret nc					;on ne peut avoir que 9 tanques d'énergie
	ld (hl),a
	ret

item1Up:
	ld c,1
	call iF_offset			;c = 0 : energy tank, c = 1 : one-up
	inc (hl)

	ld hl,playerLives
	jr check9
