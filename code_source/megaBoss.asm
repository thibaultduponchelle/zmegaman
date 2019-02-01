;Nous pouvons donner une hauteur max pour les sauts de chaque méchant

;Tiles 21-23 are Diveman's missiles.
;Tiles 24 & 25 are metalman's sawblade

;########################################################
;# [megaBoss.asm]
;#-------------------------------------------------------
;#	***********************************************
;#	*** Les equates des balles des bosses sont	***
;#	*** définis dans [megaMan.asm]				***
;#	***********************************************
;#-------------------------------------------------------
;# ROUTINES CONTENUES:
;#-------------------------------------------------------
;# chargerBoss:
;#	routine qui flippe les sprites du boss et puis exécute
;#	tous les routines nécessaires pendant les batailles 
;#	contre les boss
;#-------------------------------------------------------
;# bossAction:
;#	s'occupe de toutes les routines spécifiques au boss
;#-------------------------------------------------------
;# bossPenser:
;#	routine basique de l'IA du boss. S'il n'y a pas d'action
;#	elle en choisit une et l'installe
;#-------------------------------------------------------
;# isCounterZero:
;#	simplement désarme le drapeau z si le compteur == zéro,
;#	nz si non.
;#-------------------------------------------------------
;# actionXXX:
;#	toutes les actions possibles des bosses
;#-------------------------------------------------------
;# random: <-- devrait-elle être dans [megaMath.asm] ?
;#	mettre un numéro "aléatoire" dans a et b (le même numéro).
;#	La valeur de b s'utilise comme la valeur max du numéro
;#	aléatoire, donc le numéro dans a/b sera entre 0 et b
;#	(inclusives).
;#-------------------------------------------------------
;# gravité:
;#	incrémente la vélocité Y, un genre de gravité simple.
;#-------------------------------------------------------
;# movBossX/movBossY:
;#	ils ajoutent les vélocités aux positions X/Y et
;#	enlevent l'action actuelle si on a touché un mur/le
;#	sol
;#-------------------------------------------------------
;# bossCollision:
;#	cherche une collision entre le boss et Megaman, jeter
;#	Megaman s'il y en a (une collision) et lui fait dégât
;#-------------------------------------------------------
;# desBoss:
;#	afficher le boss à l'écran !
;########################################################

;EQUATES:
TERRE_Y = 7				;valeur Y quand le boss est sur terre
BOSS_W = 3
BOSS_H = 24
BOSS_JUMP = (BOSS_W*BOSS_H)*2*3	;offset à ajouter pour trouver le sprite de sauter
BOSS_POSE = BOSS_JUMP+(BOSS_W*BOSS_H*2)
BOSS_SHOOT = BOSS_POSE+(BOSS_W*BOSS_H*2)

;Etats
B_WAIT	= 0		;attendre dans là où il est
B_JUMP	= 1		;sauter
B_RUN	= 2		;courir d'un côté à l'autre
B_WALK	= 3
B_CHASE	= 4		;poursuivre le joueur
B_SHOOT_CUT		= 5
B_SHOOT_ICE		= 6
B_SHOOT_FIRE	= 7
B_SHOOT_GUTS	= 8
B_JUMP_GUTS		= 9
B_SHOOT_ELEC	= 10
B_SHOOT_WOOD	= 11
B_SHOOT_METAL	= 12
B_EVADE_METAL	= 13
B_SHOOT_DIVE	= 14
B_DIVE			= 15
B_SHOOT_WALKER 	= 16
B_TRANSFORM		= 17
B_JUMP_WILY		= 18
B_THROW_SPINE	= 19
B_RISE			= 20
B_SHOOT_HOVER	= 21
B_RUN_WILY		= 22
B_STOMP			= 23

;;;;;
; A partir du level actuel, charger les bonnes actions dans le template rempli d'emplacements B_WAIT
; Input a = choix
;;;;;
chargerBossActionsSelonChoix:
	push af
		ld hl,bossActionsStart
		or a
		jr z,sauverBossActions
		ld b,a
		ld d,0
changerBossActions:
		ld e,(hl)			;nombre d'actions
		inc e
		add hl,de
		djnz changerBossActions
sauverBossActions:
		ld b,d			;bc = nombre d'actions à charger
		ld c,(hl)
		inc c				;inc bc parce que nous voulons charger aussi le nombre d'actions qu'il y a
		ld de,bossActions
		ldir
	pop af
	ret

; input a = choix
chargerBossMapSelonChoix:
	push af
		call openDataFile
		ld de,120+12+6		;sauter la table de niveaux. +12 parce que l'on soustrait 12 dans openDataFile
							; (c'est pour charger les niveaux), +6 pour sauter la table de textes
		add hl,de
		call checkOverflow
		ld e,(hl)
		call loadNextHL
		ld d,(hl)
		add hl,de
	pop af
	or a
	 jr z,sauverBossSprite
	ld b,a
	ld de,24*3*6			;hauteur = 24, largeur = 3 octets, chaque boss a 6 sprites
changerBossSprites:
	add hl,de
	call checkOverflow
	djnz changerBossSprites
sauverBossSprite:
;########### START FLIP SPRITES ###################
;#	D'abord, nous copions tous les sprites, avec une
;#  espace de boss height*boss width octets pour y
;#  mettre les sprites flippé.
;#	Puis, nous flippons l'un après l'autre les sprites, mais
;#  parce que l'octet de gauche de l'original correspond
;#  à l'octet de droite du flippé, il faut decrémenter ix
;#  (aller de droite à gauche).
;#	Quand nous avons flippé/sauvegardé tout le sprite,
;#  il faut ajouter BOSS_H*BOSS_W à ix pour sauter le
;#  sprite original.
;#	Dans la mémoire, on aura:
;#  [sprite normal]	= 24*3 octets
;#  [sprite flippé]	= 24*3 octets
;#  [sprite normal]	= 24*3 octets
;#  [sprite flippé]	= 24*3 octets
;#  etc.
	ld bc,24*3*6			;hauteur = 24, largeur = 3 octets, chaque boss a 6 sprites
	call flashToBuffer		;charger (hl) dans gbuf
	ld hl,gbuf
flipBossSprites:
	push hl
		ld a,6						;il y a 6 sprites à copier
		ld de,bossSpritesFlipped
		ld bc,BOSS_H*BOSS_W
copierBossSprites:
		ldir
		ex de,hl
		 ld c,BOSS_H*BOSS_W
		 add hl,bc					;laisser de l'espace pour le sprite flippé
		ex de,hl
		dec a
		jr nz,copierBossSprites
	pop hl
	ld ix,bossSpritesFlipped+(BOSS_H*BOSS_W)
	ld e,6
	ld bc,(BOSS_W*256)+BOSS_H		;b = BOSS_W, c = BOSS_H
	ld a,BOSS_W*BOSS_H
	ld (bossSpriteSize),a
;(bossSpriteSize) = size in bytes of each sprite
;e = # of sprites
;b = width
;c = height
;ix = start of second sprite in buffer
;hl = start of sprite data to flip
flipSprites:
	push de							;e contient notre compteur
	push bc
flipMiddleLoop:
		push bc
			ld a,(hl)
			ld b,8					;il y a 8 bits dans un octet
flipInnerLoop:
			rra
			rl e					;reverser les bits !
			djnz flipInnerLoop
			ld (ix+BOSS_W-1),e
			dec ix
			inc hl
		pop bc
		djnz flipMiddleLoop
		ld de,BOSS_W*2				;nous allons de droite à gauche, donc quand nous terminons
		add ix,de					; il faut ajouter BOSS_W*2
		ld b,BOSS_W
		dec c
		jr nz,flipMiddleLoop
bossSpriteSize = $+1
		ld e,BOSS_W*BOSS_H
		add ix,de
	pop bc
	pop de
	dec e
	jr nz,flipSprites
	ret

chargerBoss:
;	ld a,(selecteur)			;le niveau actuel (choisi dans le ménu des niveaux) pour choisir le boss correct
;	push af
;		call chargerBossActionsSelonChoix
;		call chargerBossMapSelonChoix
;		ld b,10						;piece des bosses
;		call loadLevelFromArchive	;[megaLoadData.asm]
;	pop af
	cp 2						;est-ce le niveau de cutman ?
	jr nz,$+6
		set weaponHead,(iy+zFlags)
	cp 4						;diveman
	 jr nz,$+19
		ld b,10
		ld hl,nombreMechants	;le niveau de diveman peut avoir jusqu'à 10 méchants
		ld (hl),b				; chaque balle qu'il tire est gérée comme un méchant
		ld de,MECHANT_SIZE
		ld hl,mechantArray
		ld (hl),$FF				;méchant mort
		add hl,de
		djnz $-3
	ld a,$FF
	ld (wilyFrame),a
	ld hl,TERRE_Y*256
	ld (bossY),hl
	ld h,8
	ld (bossX),hl
	call resetBossValues
	ld hl,nombreMechants
	ld (hl),0
	set bossBattle,(iy+zFlags)
	call bossVersMegaman;faire que le boss faire face à Megaman
	ld a,2
	ld (playerDir),a
bossLoop:
	call desCarte		;dessiner la carte
	call desPersonnage	;dessiner le joueur
	call desBalles		;
	call bossAction		;que va faire le boss ?
	call desMechants	;y a-t-il des méchants ?
	call desBoss
;	call desBossHit		;si une balle a touché le boss, montrer un sprite
	call desBossHP
	call desBarreHP
	call drawGbuf
	ld hl,shock
	ld a,(hl)
	or a
	 jr z,$+7
		dec (hl)
		ld a,(hl)
	 	ld (slideFrames),a	;armer slide frames parce que Megaman a "tombé"
	or a
	call z,keyCheck

	ld a,(playerHP)
	or a
	 jp z,tu_as_perdu
	ld a,(bossHP)
	or a
	 jr nz,bossLoop
		call resetBossValues
		ld a,(selecteur)
		inc a
		ld b,a
		xor a
		scf
		 rla
		 djnz $-1
		ld hl,bossesBeat
		or (hl)
		ld (hl),a
		jp transitionBossMort	;[megaTitle.asm]

bossAction:
	call gravityBoss	;la gravité sur vélocité y
	call movBossX		;bouger boss vers la gauche/droite
	call movBossY		;bouger boss en haut/bas
	call bossCollision
callBossPenser:
	call bossPenser
counterUpdate:
	ld hl,counter
	dec (hl)
	 ret nz
resetBossAction:
	call bossVersMegaman
	xor a
	ld (counter),a
	ld (bossSpecial),a	;remmetre à zéro counter et le flag de sprite spécial
	ld (bossVelX),a
	dec a
	ld (actionEtat),a	;enlever l'action (y mettre $FF)
	jr callBossPenser

bossVersMegaman:
	ld a,(bossX+1)
	ld hl,playerX+1
	cp (hl)
	ld a,1
	 jr nc,$+3
		xor a
	ld (bossDir),a		;boss regarde vers megaman
	ret

;On va choisir une action de la liste d'actions
;On va la mettre dans actionEtat
bossPenser:
	ld a,(selecteur)
	cp 8
	 jr nz,normalBoss
		ld a,(wilyFrame)
		or a
		ld hl,bossActionsWilyHover
		 jr z,$+5
			ld hl,bossActionsWilyWalker
		ld b,(hl)			;b = nombre d'actions que le boss possède
		jr bP_start			;finir la routine
normalBoss:
	ld hl,bossActions
	ld b,(hl)			;b = nombre d'actions que le boss possède
bP_start:
	ld a,(actionEtat)	;si actionEtat == $FF, il faut charger une nouvelle action
	ld c,a				;c = l'action actuelle
	inc a
	jr nz,chargerAction	;si nous déjà avons une action, aller la charger
		inc hl
		dec b			;numéro d'action -1 parce que nous commençons par 0, pas 1
		call random		;un numéro "aléatoire" dans a, 0-b
		or a
		jr z,$+5
		 inc hl
		 djnz $-1
		ld c,(hl)
chargerAction:
	ld a,c
	ld (actionEtat),a
	add a,a
	ld b,0
	ld c,a
	ld hl,listeActions	;**[megaBossData.inc]**
	add hl,bc			;listeActions + numéro d'action (x2)
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a				;ld hl,(hl)
	jp (hl)				;installer action

;maintenant listeActions est dans [megaBossData.inc]

;########################################################
;# ISCOUNTERZERO (isCounterZero)
;#-------------------------------------------------------
;# vérfier la valeur de "counter"
;# paramètres:
;# 	aucun
;# sortie:
;#  z = counter is zero
;#	hl = pointeur à counter
;########################################################
isCounterZero:
	ld hl,counter
	ld a,(hl)
	or a
	ret

actionWait:
	call isCounterZero
	 ret nz
	ld (hl),25		;attendre 25 frames
	ret

;check which way the boss is looking
;if looking right, positive x velocity
;if left, negative
actionRun:
	call isCounterZero
	 ret nz
	ld hl,bossDir
	ld a,(hl)
	or a
	ld a,64
	jr z,$+4
	 ld a,-64
	ld (bossVelX),a
	ret

actionWalk:
	call isCounterZero
	 ret nz
	ld hl,bossDir
	ld a,(hl)
	or a
	ld a,48
	jr z,$+4
	 ld a,-48
	ld (bossVelX),a
	ret

actionJumpGuts:
	call isCounterZero
	 jr nz,skipInitJump
setupJumpTremble:
		call gutsJump
		ld b,1
		call random
		or a
		 jr z,skipInitJump		;parfois sauter vers le joueur
setupJumpNormal:
		ld a,(bossDir)
		or a
		ld a,48
		 jr z,$+4
			ld a,-48
		ld (bossVelX),a
		ret
skipInitJump:
	ex af,af'
		ld a,(bossY+1)
		cp TERRE_Y
		 ret nz
	ex af,af'
	ld hl,bossVelX
	ld (hl),0
	cp 128
	 jr c,$+7
		ld a,128
		ld (counter),a
	cp 110
	 jp nc,tremble
	cp 109
	 jp z,restaurerOffset
	cp 100
	 ret nc
	ld a,1
	ld (counter),a
	ret

actionJump:
	call isCounterZero
	 jr nz,endJump
	ld a,(selecteur)
	add a,a
	ld c,a
	ld b,0
	ld hl,bossJumpTable
	add hl,bc
	ld b,(hl)		;vélocité y
	inc hl
	ld c,(hl)		;vélocité x
	ld hl,bossVelY
	ld (hl),b		;charger la vélocité y
	ld a,(bossDir)
	or a
	ld a,c
	 jr z,$+4
		neg
	ld (bossVelX),a
	ret
endJump:
	ld hl,bossVelY
	ld a,(hl)
	sub 4				;il déscend plus rapide qu'il ascend
	ret p
	ld (hl),a
	jp verifTerre

actionChase:
	call isCounterZero
	jr nz,$+4
		ld (hl),50		;timeur = 50 frames
chaseSkip:
	ld a,(bossX+1)		;x aligné
	ld hl,playerX+1		;x aligné
	cp (hl)				;si playerX > ou = ou < bossX
	ld hl,bossVelX		;... si ==, mettre bossVelX à zéro (ne bouger pas)
	ld (hl),0			;
	 ret z
	ld a,0				;(on peut pas changer les drapeaux, donc pas de "xor a")
	ld (bossDir),a		;... si pX > bX, aller vers le droît (3 unités, ou 1.5 pixels, à la fois) pour le rattraper
	ld (hl),48			;... 32 = un pixel chaque frame, 48 = 1.5 pixels
	 ret c
	inc a				;Et finalement, si pX < bX, il faut aller vers la gauche
	ld (bossDir),a		;... et lui dire au boss de regarder vers la gauche !
	ld (hl),-48			;... 1.5 pixels vers la gauche chaque frame
	ret

actionShootCutter:
	call isCounterZero
	jr nz,$+5
	 ld a,40
	 ld (hl),40	;fixer la duration de l'action
	dec a
	jr nz,$+7
	 set weaponHead,(iy+zFlags)
	 ret
;cette partie-ci et l'animation de tirer
	cp 33
	ld hl,bossSpecial
	ld (hl),1
	 ret nc
	res weaponHead,(iy+zFlags)
	ld (hl),2

	and $1F
	or a
	 ret nz		;quitter (ne pas tirer) si ce n'est pas un multiple de 16 (and $0F)
	ld a,BCUTMAN
aimAtPlayer:
	push af
		ld hl,(playerY)
		ld bc,$0100				;viser la poitrine de megman
		add hl,bc
		ld bc,(bossY)			;pX-bX
		sbc hl,bc
		add hl,hl
		add hl,hl
		add hl,hl				;h = pX-bX
		ex de,hl				;sauver dY*BULLET_SPEED dans de
			ld hl,(playerX)
			ld bc,(bossX)
			sbc hl,bc			;pX-bX
			add hl,hl
			add hl,hl
			add hl,hl			;de = (playerY-bossY)*BULLET_SPEED, h = playerX-bossX
		ex de,hl
		call aimBullet			;h = dY, d = dX [megaBullet.asm]
		ld e,a					;... a = velY, l = velX
		ld l,-BULLET_SPEED
	
		ld a,(bossDir)	;0 = regarde droite, 1 = gauche
		or a
		ld bc,(bossX)
		 jr nz,$+10
			ld hl,$0280	;16+4 pixels
			add hl,bc
			ld c,l
			ld b,h
			ld l,BULLET_SPEED
		ld h,e					;h = velY
		ld de,(bossY)
		inc d
	pop af
	jp ajouterBalle				;hl = velX/velY, de = balleY, bc = balleX, a = type de balle [megaBullet.asm]


actionShootIce:
	ld a,(counter)
	dec a					;premier frame = 0
	cp -15
	 jr c,iceSkipJump
		ld hl,bossVelY
		ld (hl),-64			;en donnant une valeur négative, le boss sautera.
		ret
iceSkipJump:
	ld hl,bossVelY
	ld (hl),12
	cp -16
	 jr z,iceShoot
	cp -34
	 jr z,iceShoot
	cp -52
	 jr z,iceShoot
	cp -90
	 jr z,iceShoot
	 ret nc
	ld (hl),-32
	cp -108
	 jr z,iceShoot
	cp -126
	 jr z,iceShoot
	ret nc
	ld (hl),64
	jp verifTerre
iceShoot:
	ld l,-(BULLET_SPEED/2)	;vel x = 1 pixel par frame
	ld a,(bossDir)			;0 = *DROITE*, 1 = *GAUCHE*
	or a
	ld bc,(bossX)
	ld a,BICEMANL
	 jr nz,$+11
	 	inc a				;vers la droite
		ld hl,$0280			;16+4 pixels
		add hl,bc
		ld c,l
		ld b,h
		ld l,BULLET_SPEED/2
	ld h,0
	ld de,(bossY)
	inc d					;baisser la balle 8 pixels
	jp ajouterBalle			;hl = velX/velY, de = balleY, bc = balleX, a = type de balle [megaBullet.asm]

actionShootFire:
	call isCounterZero
	 jr z,fireShoot
	cp -35
	 ret nc
	ld (hl),1				;hl = counter, mettre counter à zéro
	ret
fireShoot:
	ld de,(bossY)
	ld hl,$0080				;4 pixels
	add hl,de
	ld e,l
	ld d,h

	ld l,-((BULLET_SPEED*2)/3)		;vel x = 1 pixel par frame
	ld a,(bossDir)			;0 = *DROITE*, 1 = *GAUCHE*
	or a
	ld bc,(bossX)
	ld a,BFIREMANL
	 jr nz,$+11
	 	inc a				;vers la droite
		ld hl,$0280			;16+4 pixels
		add hl,bc
		ld c,l
		ld b,h
		ld l,(BULLET_SPEED*2)/3
	ld h,0
	jp ajouterBalle			;hl = velX/velY, de = balleY, bc = balleX, a = type de balle [megaBullet.asm]


actionShootGuts:
	call isCounterZero
	 jr nz,skipGuts
gutsJump:
	 	ld hl,bossVelY
		ld (hl),-90			;en donnant une valeur négative, le boss sautera.		
		ret
skipGuts:
	ex af,af'
		ld a,(bossY+1)
		cp TERRE_Y
		 ret nz
	ex af,af'
	cp 128
	 jr nc,callBoulder
	cp 110
	 jr nc,tremble
	ld hl,bossSpecial
	ld (hl),1
	cp 109
	 jr z,restaurerOffset
	cp 100
	 ret nc
	ld (hl),2
	cp 80
	 ret nc
	ld a,1
	ld (counter),a
	ret
callBoulder:
	ld a,128
	ld (counter),a
	ld hl,$4000
	ld de,$0100
	ld bc,(bossX)
	ld a,BGUTSMANL
twoPieceBullet:
;hl = velX(l)/velY(h), de = balleY, bc = balleX, a = type de balle [megaBullet.asm]
	call ajouterUne				;ajouterBalle avec des push/pops[megaBullet.asm]
	inc b
	inc a						;prochain sprite = BGUTSMANR
	jp ajouterBalle
restaurerOffset:
	ld hl,yCoord				;parfois quand on mouve pendant que l'écran se change
	ld a,(hl)					;on peut voir un autre rang sous la carte
	cp 3
	 jr nz,$+6
	 	xor a
	 	ld (yOff),a
	ret
tremble:
	ld a,(playerY+1)
	cp 8
	 jr c,trembleSinistres
		ld hl,shock
		ld (hl),10
trembleSinistres:
	ld b,7
	call random
	ld (xOff),a
	ld b,7
	call random
	ld (yOff),a
	jp updateRotation

verifTerre:
	ld a,(selecteur)
	ld b,a
	ld c,TERRE_Y
	cp 8
	 jr nz,$+4
		ld c,WILY_Y
	ld a,(bossY+1)
	cp c
	 ret nz
	ld hl,counter
	ld (hl),1
	ld a,(selecteur)
	cp 7				;woodman
	 ret nz
	xor a
	ld (hl),a
	ld c,a	;0 = wait
	ld (bossVelX),a
	jp chargerAction

actionShootElec:
	call isCounterZero
	 jr z,elecShoot
	cp -30
	 ret nc
	ld (hl),1
	ret
elecShoot:
	ld l,-BULLET_SPEED	;vel x = 1 pixel par frame
	ld a,(bossDir)			;0 = *DROITE*, 1 = *GAUCHE*
	ld bc,(bossX)
	dec b
	or a
	 jr nz,$+10				;si on regarde vers la droite, il faut changer la position x ou le boss va tirer la balle
		ld hl,$0380			;24+4 pixels
		add hl,bc
		ld c,l
		ld b,h
		ld l,BULLET_SPEED
	ld h,0
	ld de,(bossY)
	dec d					;baisser la balle 8 pixels
	ld a,BELECMANL
;hl = velX/velY, de = balleY, bc = balleX, a = type de balle [megaBullet.asm]
	jp twoPieceBullet		;afficher une balle avec deux parties

actionShootWood:
	call isCounterZero
	 jr z,woodShoot
	cp -9
	 jr z,woodShoot
	cp -18
	 jr z,woodShoot
	cp -27
	 jr z,woodShoot

	cp -40
	 jr z,woodShootUp
	cp -50
	 jr z,woodShootUp
	cp -60
	 jr z,woodShootUp
	cp -70
	 jr z,woodShootUp
	
	cp -90
	 jr z,woodFallDown
	cp -100
	 jr z,woodTurnOffShield
	cp -128
	 ret nc
	ld (hl),0
	ld c,B_JUMP
	jp chargerAction
woodTurnOffShield:
	ld hl,bossShield
	ld (hl),0
	ret
woodFallDown:
	ld bc,$0300
	ld de,$0100
	ld a,BWOODMANFALL
	ld hl,$1020
	call ajouterUne
	ld b,6
	call ajouterUne
	ld b,9
	call ajouterUne
	ld b,12
	jp ajouterBalle			;hl = velX(l)/velY(h), de = balleY, bc = balleX, a = type de balle [megaBullet.asm]
woodShootUp:				;non, Woodman n'est pas un junkie !
	ld bc,(bossX)
	inc b
	ld hl,$A000				;h = -BULLET_SPEED, l = 0
	ld de,(bossY)
	ld a,BWOODMAN
	jp ajouterBalle			;hl = velX/velY, de = balleY, bc = balleX, a = type de balle [megaBullet.asm]
woodShoot:
	ld hl,bossShield
	inc (hl)
	ld bc,(bossX)
	ld hl,$0180
	add hl,bc
	ld c,l
	ld b,h
	ld de,(bossY)
	ld hl,$FF80
	add hl,de
	ld e,l
	ld d,h
	ld a,BWOODMAN
	ld h,0
	ld l,-80
	jp ajouterBalle

actionShootMetal:
	call isCounterZero
	ld hl,bossVelY
	 jr nz,metalNoJump
		ld b,4
		call random
		add a,8
		ld b,a
		add a,a
		add a,a
		add a,b
		add a,a
		neg
		ld (hl),a
		ret
metalNoJump:
	ld a,(hl)
	cp -5
	 jr z,metalShoot
	cp -60
	 jr z,metalShoot
	 jp c,verifTerre
	sub 5
	ld (hl),a
	jp verifTerre	
metalShoot:
	ld a,BMETALMAN
	jp aimAtPlayer			;reutiliser le code de actionShootCutter

actionEvadeMetal:
	ld a,(counter)
	cp -10
	 ret nc
	cp -20
	 jr z,metalShoot
	cp -40
	 jr z,metalShoot
	cp -60
	 jr z,metalShoot
	cp -70
	 jr z,returnToShoot
	ld hl,(playerX)
	ld de,(bossX)
	sbc hl,de
	ld a,h
	add a,4
	cp 9
	 ret nc
	xor a
	ld (counter),a
	ld c,B_JUMP
	jp chargerAction			
returnToShoot:
	xor a
	ld (counter),a
	ld c,B_SHOOT_METAL
	jp chargerAction

;;;;;
; Diveman qui shoot
;;;;;
actionShootDive:
	call isCounterZero
	 ret z
	ld hl,bossSpecial
	ld (hl),1
	ld b,a
	and $F
	cp 5
	 jr c,$+4
		ld (hl),2
	ld a,b	
	cp -16
	 jr z,diveShoot
	cp -32
	 jr z,diveShoot
	cp -48
	 jr z,diveShoot
	 ret nc
	ld hl,counter
	ld (hl),1
	ret
diveShoot:
;a' = frame d'animation
;a = type de méchant
;d = x
;e = x off
;b = y
;c = y off
;h = vel x
;l = vel y
	ld a,(bossDir)
	ld b,a						;garder a
	or a
	ld a,0
	 jr nz,$+4
		ld a,4
	ex af,af'
	ld de,(bossX)
	ld hl,(256-64)<<8
	ld a,b						;a = bossDir
	or a
	 jr nz,$+6
	 	ld h,64
		inc d
		inc d					;si Diveman regarde vers la droite il faut changer les coordonnées de la balle
	ld bc,(bossY)
	set 7,c
	inc b
	ld a,DIVE					;id du méchant
	call findEmptyMechant		;chercher la liste de méchants pour un espace vide
	 ret nz						;si rien trouvé, il y a trop de balles
	ret


actionDive:
	call isCounterZero
	 ret z
	ld hl,bossSpecial
	ld (hl),1
	cp -15
	 ret nc
	ld (hl),0
	cp -20
	 jr nc,diveFrame1
	cp -21
	 jr z,diveStart
diveFrames = $+1
	cp 0
	 ret nc
	ld hl,counter
	ld (hl),1
	ret
diveStart:
	ld a,(bossDir)
	ld b,a
	or a
	ld a,-128
	 jr nz,$+4
		ld a,127
	ld (bossVelX),a
setUpDive:
	ld a,b
	or a
	ld b,-20-1
	 jr nz,$+4
		ld b,-20-3-1
	ld hl,(playerX)
	ld de,(bossX)
	sbc hl,de
	ld a,h
	bit 7,a
	 jr z,$+4
		neg
	add a,a
	neg
	add a,b
	ld (diveFrames),a
	ret	
diveFrame1:
	ld hl,$06FF
	ld (bossY),hl
	ret

actionShootWalker:
	call isCounterZero
	 ret nz
	ld a,40
	ld (hl),40	;fixer la duration de l'action
;cette partie-ci et l'animation de tirer
	ld a,BWALKERR
	ld hl,(playerX)
	ld bc,$0100
	add hl,bc
	ld de,(bossX)
	sbc hl,de
	sbc a,c					;a-1 (BWALKERL) si le boss est à la gauche de Megaman
	jp aimAtPlayer

;wily
actionTransform:
	call isCounterZero
	 jr nz,finishTransforming
		ld (hl),60			;counter = 60
		ld a,(wilyFrame)	;nous nous transformons en walker ou en hover mobile
		or a
		ld a,transformDown-transformUp
		 jr nz,$+3
			xor a
		ld (transformUp-1),a
		ld hl,gravityWily
		ld (hl),$C9			;$C9 = ret
		ret
finishTransforming:
	cp 1
	 jr nz,skipHoverVel
		ld hl,gravityWily
		ld (hl),$00			;enlever le ret
		ld hl,$0200
		ld (hoverGrav),hl	;hGrav = 0, hVel = 2
		ret
skipHoverVel:
	ld hl,(bossY)
	push hl
		add hl,hl
		add hl,hl
		add hl,hl			;x8
		ld b,h				;b = bossY en pixels
	pop hl
	ld de,32/4				;bouger 1/4 pixel chaque frame
	jr transformUp			;du smc va modifier le saut
transformUp:
	cp 40
	 jr c,startWalkerUp
	 	ld a,b
		cp 7*8+4
		 ret nc
		add hl,de
		ld (bossY),hl
		ld hl,counter
		ld (hl),45
		ret
startWalkerUp:
	ld hl,wilyFrame
	cp 20
	 jr nz,finishWalkerUp
	 	inc (hl)		;prochaine frame
		ld hl,$0640		;parce que chaque sprite a une taille différente
		ld (bossY),hl	; il faut modifier bossY
finishWalkerUp:
	cp 10
	 ret nz
	 	inc (hl)
		ld hl,$0500
		ld (bossY),hl
		ret	
transformDown:
	and $7
	 ret nz
	ld hl,wilyFrame
 	ld a,(hl)
 	or a
 	 ret z
	dec (hl)
	ret

actionJumpWily:
	call isCounterZero
	 jr nz,wilyJumped
	 	ld hl,wilyFrame
	 	ld (hl),3				;saut
	 	ld hl,bossVelY
		ld (hl),-120			;en donnant une valeur négative, le boss sautera.		
		jp setupJumpTremble+3
wilyJumped:
	ex af,af'
		ld a,(bossY+1)
		cp WILY_Y
		 ret nz
	ex af,af'
	ld hl,bossVelX
	ld (hl),0
 	ld hl,wilyFrame
 	ld (hl),4					;stomping sprite
	cp 50
	 jr c,$+8
		ld a,50
		ld (counter),a
		ret
	cp 42
	 jr z,ceilingFall
	 jp nc,tremble
	ld (hl),2					;debout
	jp restaurerOffset

actionThrowSpine:
	call isCounterZero
	 jr nz,continueThrowing
	 	dec a
		ld hl,mechantArray		;vérifier si l'on a déjà mis un spine
		cp (hl)
		 ret z
		ld hl,counter
		ld (hl),2				;s'il y a déjà un spine, éxécuter une autre action
		ret
continueThrowing:
	cp $E0
	 jr z,throwSpine
	 ret c
	 	ld ix,spineSprites+1	;sauter l'octet de hauteur
	 	ld b,6
		jp drawBossHat+6
throwSpine:
	ld (hl),10
	xor a					;a = frame d'animation = 0
	ex af,af'
	ld de,(bossX)
	inc d					;bossX+8
	ld bc,(bossY)
	dec b					;bossY-8
	ld a,(bossDir)
	or a
	ld h,-64
	 jr nz,$+4
		ld h,64				;si z armé, le boss regarde vers la droite, vélocité positive
	ld l,-32
	ld a,SPINE
;a' = frame d'animation
;a = type de méchant
;d = x
;e = x off
;b = y
;c = y off
;h = vel x
;l = vel y
findEmptyMechant:
	exx					;sauver hl/bc
		ld e,a			;sauver a
		ld hl,mechantArray
		ld a,$FF
		ld bc,MECHANT_SIZE*10
		cpir
		 ret nz			;si rien trouvé, il y a trop de méchants
		ld a,e
	push hl
	exx
	pop ix
	ld (ix-1),a			;ajouter un méchant de type "a"
	ld (ix),d			;x
	ld (ix+1),e			;x off
	ld (ix+2),b			;y
	ld (ix+3),c			;y off
	ld (ix+4),h			;velX
	ld (ix+5),l			;velY
	ld (ix+6),1			;HP
	ld (ix+7),0
	ex af,af'
	ld (ix+8),a			;frame d'animation
	ld hl,nombreMechants
	inc (hl)
	ret

;16 possible values
ceilingFall:
	ld hl,particles
	ld b,8
cF_loop:
	exx
		ld b,15
		call random
	exx
	inc a
	add a,a
	add a,a
	add a,a			;x8 position x réelle
	ld (hl),a
	inc hl
	ld (hl),0		;starting y position
	inc hl
	djnz cF_loop
	ld hl,numParticles
	ld (hl),1
	ret

actionRise:
	call isCounterZero
rise_or_fall = $+2
	 jr nz,letsRise
	 	ld (hl),40
		ld a,(bossY+1)
		cp 5					;doit-on aller vers le haut ou vers le bas ?
		ld a,letsRise-rise_or_fall
		 jr nc,$+4
			ld a,letsFall-rise_or_fall
		ld (rise_or_fall-1),a	;SMC le jr
		ret
letsRise:
	ld a,(bossY+1)
	cp 4
	 ret c
	ld bc,2*256+256-32
	jr letsGo
letsFall:
	ld a,(bossY+1)
	cp 6
	 ret nc
	ld bc,(-2*256)+32
letsGo:
	ld (hoverGrav),bc
	ret

actionShootHover:
	call isCounterZero
	 jr nz,skipHoverSetup
	 	ld (hl),60
		ret
skipHoverSetup:
	ld de,(bossY)
	ld a,d
	cp 5
	 jr nc,shootHoverGround
	push de
		call chaseSkip
	pop de
	ld hl,counter
	ld a,(hl)
	and $F					;chaque 16 frames laisser tomber une bombe
	 ret nz
	ld hl,$0280				;bossY + 16+4 pixels
	add hl,de
	ld e,l
	ld d,h					;de = balleY
	ld bc,(bossX)
	ld hl,$0180				;8+4 pixels
	add hl,bc
	ld c,l
	ld b,h					;bc = balleX
	ld l,0					;vel x = 0 pixels par frame
	ld h,16
	ld a,BHOVERCHASE
	jp ajouterBalle			;hl = velX (l)/velY (h), de = balleY, bc = balleX, a = type de balle [megaBullet.asm]
shootHoverGround:
;machine Gun
	ld hl,counter
	ld a,(hl)
	and $3
	 ret nz
	ld de,(bossY)
	ld hl,$0180				;bossY + 8+4 pixels
	add hl,de
	ld e,l
	ld d,h					;de = balleY

	ld l,-((BULLET_SPEED*2)/3)		;vel x = 1 pixel par frame
	ld a,(bossDir)			;0 = *DROITE*, 1 = *GAUCHE*
	or a
	ld bc,(bossX)
	 jr nz,$+10
		ld hl,$0280			;16+4 pixels
		add hl,bc
		ld c,l
		ld b,h
		ld l,(BULLET_SPEED*2)/3
	exx
		ld b,30
		call random
		sub 15
	exx
	ld h,a
	ld a,BMACHINEGUN
	jp ajouterBalle			;hl = velX (l)/velY (h), de = balleY, bc = balleX, a = type de balle [megaBullet.asm]

actionRunWily:
	call isCounterZero
 	ld hl,wilyFrame
	and $F
	 jr nz,checkGround
 	ld (hl),3				;saut
 	ld hl,bossVelY
	ld (hl),-60			;en donnant une valeur négative, le boss sautera.		
	jp setupJumpNormal
checkGround:
	ld a,(bossY+1)
	cp WILY_Y
	 ret nz
	ld (hl),2
	ld hl,bossVelX
	ld (hl),0

	ld a,(bossX+1)
	cp 1
	 jp z,resetBossAction
	cp 14
	 jp z,resetBossAction
	ret

setUpStomp:
	call bossVersMegaman
	ld hl,bossVelX
	ld (hl),0
	ld hl,counter
	ld (hl),20
	ld hl,actionEtat
	ld (hl),B_STOMP
	ld hl,wilyFrame
	ld (hl),3
	ret
actionStomp:
	ld a,(counter)
	cp 10
	 ret nz
	ld hl,wilyFrame
	dec (hl)
;si counter = 10
	ld a,(bossDir)
	or a
	ld de,-(12*32)
	 jr nz,$+5
		ld de,12*32
	ld hl,(bossX)
	add hl,de
	ld a,h
	cp 14
	 ret nc
	cp 1
	 ret c
	ld (bossX),hl
	ret

;;;;;;;
;; La gravité 
;;;;;;;
gravityBoss:
	ld hl,bossVelY
	ld a,(hl)			;si la vélocité Y est 0, il faut savoir si on est à terre ou en train de sauter
	or a				;a = 0?
	 jr nz,gravContinue	;si a != 0, on a besoin d'un peu de gravité :)
	ld a,(bossY+1)		;MSB: Y alignée
	cp TERRE_Y			;si le boss est sur terre
	 ret nc				;pas de gravité
gravContinue:
	ld a,(hl)
	add a,10
	 jp m,gravNegative
	cp $70
	 jr c,$+4
		ld a,$70
gravNegative:
	ld (hl),a
	ret


;;;;;;
; Ajouter la vélocité X à bossX et enlever l'action si on touche un mur.
;;;;;;
movBossX:
;mettre à jour la vélocité X
	ld a,(bossVelX)
	or a
	 ret z			;on ne fait rien si la vélocité X = 0
	ld e,a
	call signExtendE	;si e est positif, d = 0, sinon d = $FF [megaMath.asm]
	ld hl,(bossX)
	add hl,de
	ld (bossX),hl	;sauver nouvelle position
	ld de,14*256	;ld d,14, e,0
	or a			;désarmer carry
	sbc hl,de
     jr nc,changerDeSensX
    add hl,de
	ld d,1			;côté gauche du map
	or a
	sbc hl,de
	 ret nc
changerDeSensX:
	ld (bossX),de
	ld hl,bossVelX
	ld (hl),0		;mettre vélocité X à zéro
	ld a,(bossVelY)
	or a
	 ret nz
	jp resetBossAction	;enlever l'action

;Ajouter la vélocité Y à bossY. Remettre à zéro si on est à terre
movBossY:
	ld a,(bossVelY)		;vélocité Y du boss
	or a
	 ret z
	ld hl,(bossY)		;coord y
	ld e,a
	call signExtendE	;si e est positif, d = 0, sinon d = $FF [megaMath.asm]
	add hl,de			;bossY+velY
	ld (bossY),hl		;mettre à jour bossY
	ld e,0
	ld d,TERRE_Y
	or a				;désarmer le carry
	sbc hl,de			;si on est sur terre
	 ret c
	ld hl,bossVelY
	ld (hl),0			;il faut mettre la vélocité Y à zéro
	ld hl,TERRE_Y*256	;pour que le boss ne trop déscende
	ld (bossY),hl
	ret

bossCollision:
	xor a
	ld hl,pushPlayer	;il faut armé pushPlayer si le boss va pousser megaman
	ld (hl),a
;megaman peut être 12 pixels à la gauche du boss ou 20 pixels à sa droite.
	ld de,(playerX)
	ld hl,(bossX)
	sbc hl,de
	add hl,hl
	add hl,hl
	add hl,hl			;x8, tout est dans h (maintenant l ne contient rien d'importance)
	ld a,h
	add a,16+6
	cp 40-6				;24=boss, 16=Megaman
	 ret nc
;collisions Y
	ld c,a
	ld a,(wilyFrame)
	ld b,24-2			;collisions pour les bosses normales
	inc a
	 jr z,$+4
		ld b,20-2		;collisions de Wily
	ld hl,(bossY)
	ld de,(playerY)
	ld a,(slideFrames)
	or a
	 jr z,$+3
		inc d			;ajuster calculation si megaman glisse
	sbc hl,de
	add hl,hl
	add hl,hl
	add hl,hl
	ld a,h
	add a,24			;hauteur du boss
	cp 40-8				;24=boss, 16 = Megaman
	 ret nc
;si megaman est invincible
	ld a,(damageFrames)
	or a
	 ret nz
;vélocité X
	ld a,c				;c = la différence de bossX-playerX que nous avions sauvé
	ld b,54
	cp 20
	 jr c,$+4
		ld b,-54
	ld a,b
	ld (velocityX),a
	ld b,2				;soustraire 2 points de vie
	call playerDamage	;lui faire dommage
	ld hl,pushPlayer	;il faut armé pushPlayer si le boss va pousser megaman
	inc (hl)
	ret

;input = valeur à soustraire
;output = h = valeur absolue (en pixels) de HL - mapX/Y
;		= c armé = hors d'écran
subMapYHL:
	ld a,(yCoord)
	jr subMapHL
subMapXHL:
	ld a,(xCoord)
subMapHL:
	push de
		ld d,a
		ld e,0
		or a
		sbc hl,de
		 jr c,endSubMap
		ld a,h
		cp 16			;16*8 = 128, hors d'écran (plus grand est on va entrer dans des numéros négatifs)
		 jr c,$+8		;si le numéro < 16, sauter
			cp -5		;-16*5 = -40, éviter que les numéros débordent
			 jr nc,$+4	;si le numéro < -16, sauter
				ld h,16	;
		add hl,hl
		add hl,hl
		add hl,hl
endSubMap:
	pop de
	ret

drawBossHat:
	ld ix,cutmanHat
	ld b,7
	ld hl,(bossY)
	call subMapYHL		;HL - mapY: h = coordonnée en pixels
	 ret c
	ld a,-6
	add a,h				;sprite = 7 pixels, l'afficher un peu plus au-dessus du boss
	ld e,a				;
;end y
	ld hl,(bossX)
	call subMapXHL		;HL - mapX: h = coordonnée x en pixels
	 ret c
	ld a,8				;afficher-le 8 pixels à droite
	add a,h
	jp drawSpriteOr_var	;a=x, e=y, ix=sprite, b=hauteur


;########################################################
;# DESBOSS (desBoss)
;#-------------------------------------------------------
;# afficher le sprite clippé du boss à l'écran.
;# paramètres:
;# 	aucun
;# sortie:
;#	rien
;########################################################
desBoss:
;est-ce le niveau final ?
	ld a,(selecteur)
	cp 8
	 jp z,desWily				;dessiner Wily
;c'est pas le Dr. Wily
	ld hl,bossDamage			;combien de frames
	ld a,(hl)
	or a
	 jr z,continueBoss
	dec (hl)
	and $3
	cp 2
	 ret c
continueBoss:
	ld a,BOSS_H
	ld (yPixelsToDraw),a
	bit weaponHead,(iy+zFlags)
		call nz,drawBossHat
;## début calcule animation
	ld ix,bossSpritesFlipped	;nous avons sauvé les sprites du boss ici
bossSpecial = $+1
	ld a,0
	or a
	 jr z,verifSauter
	ld ix,bossSpritesFlipped+BOSS_SHOOT
	dec a
	 jr nz,dB_normalStance
		ld ix,bossSpritesFlipped+BOSS_POSE	;si le sprite spécial n'est pas boss_shoot, il doit être boss_pose
verifSauter:
	ld a,(bossY+1)
	cp TERRE_Y
	jr z,verifCourir
		ld ix,bossSpritesFlipped+BOSS_JUMP
		jr dB_normalStance
verifCourir:
;maintenant, on va voir si le boss marche ou non
	ld hl,bossAnimCounter
	ld a,(bossVelX)
	or a
	jr nz,$+3
		ld (hl),a				;remettre à zéro compteur
	jp p,$+5
		neg
	rrca
	rrca
	rrca
	rrca
	and $F
	add a,(hl)
	ld (hl),a
	jr z,dB_normalStance
		ld de,BOSS_H*BOSS_W*2
		add ix,de
		and $1F
		cp 16
		jr c,dB_normalStance
		 add ix,de
dB_normalStance:
	ld de,BOSS_H*BOSS_W			;chaque sprite a 24 pixels de hauteur, 3 octets (24 pixels) de largeur
bossDir = $+1
	ld a,0						;boss direction: où regarde-t-il ? gauche (1) / droite (0)
	or a
	jr nz,$+4					;si bossDir != 0, il regarde vers la gauche
		add ix,de				; sinon, il regarde vers la droite et il faut changer le sprite
;## fin calcule animation
bossY = $+1
	ld hl,TERRE_Y*256			;la coordonnée y du boss
	add hl,hl
	add hl,hl
	add hl,hl					;h = coordonnée y en pixels
	ld a,(yCoord)
	add a,a
	add a,a
	add a,a						;map Y en pixels
	ld b,a
	ld a,h
	sub b
	ld e,a						;sauver coordonnée y
	or a
	 jp p,skipYClip
	add a,24
	 ret m
	 ret z
	ld (yPixelsToDraw),a
	ld a,e
	neg
	ld e,a
	ld d,$00
	add ix,de
	add ix,de
	add ix,de					;3 octets de largeur
	ld e,0
skipYClip:
	cp 64						;plus de 8 et le boss est hors d'écran
	 ret nc
	ld b,0						;plus tard nous chargeons b dans d. $00 pour des numéros (16bit) positifs
bossX = $+1
	ld hl,$0400
	ld a,l
	rlca
	rlca
	rlca
	and $7						;a = xOff
	ld c,a						;sauver xOff dans c
	ld a,h
	ld hl,xCoord
	sub (hl)					;bossX-mapX
	 jr nc,xNotNegative
;pour une explication, voir dessous
	 ld d,a					;sauver a dans d. a = combien d'octets (pas de pixels!) on est de le bout gauche de l'écran
	 	add a,BOSS_W
		 ret m				; ... le sprite est hors d'écran
		ld b,a				;
		add a,a				;*2
		add a,b				;*3 (parce que chaque ld (xxx),a occupe trois octets)
		ld (clipLeft),a		;SMC: changer où va sauter le jr
		xor a				;valeur qui va remplacer spriteByteX
		ld b,$FF			;plus tard nous chargeons b dans d. $FF est parce que c'est un numéro (16bit) négatif
clipLeft = $+1
		jr $				;avec du SMC on va sauter
		ld (spriteByte3),a	;SMC: change the ld (hl),a to a nop (HEX $00)
		ld (spriteByte2),a	;
		ld (spriteByte1),a	;
	 ld a,d
	 ld d,0
	 jr noWorkToDo
xNotNegative:
	cp 13					;s'il est complètement hors d'écran, quitter
	 ret nc
	cp 10					;s'il est partiellement hors d'écran, clipper
	 jr c,noWorkToDo
	push af
;###########################
;# je vais expliquer cette partie-ci parce qu'elle m'a vraiment frustré
;#  cette partie s'occupe du "clippage" des sprites hors d'écran
;#  si le sprite va pour s'afficher dès la 11ème colonne (ou la 10ème commençant de zéro)
;#  une partie va être hors d'écran. il faut la clipper.
;# si le sprite s'affiche dans la 10ème colonne, il y a un octet qui ne s'affichera pas
;#  la 11ème, il y'en aura 2, et la 12ème, 3.
;# regarder la liste au-dessous du "jr $". si nous voulons effacer le dernier octet du sprite
;#  il nous faut sauter "ld (spriteByte2),a" et "ld (spriteByte3),a". donc, on nécessite savoir 12-a
;#  puis, nous multiplions ça par 3 (chaque instruction occupe 3 octets) et changer où "jr" va sauter.
		ld b,a
		ld a,12
		sub b				;essentiellement, a=12-a
		ld b,a
		add a,a
		add a,b				;a*3 (parce que chaque ld (xxx),a occupe trois octets)
		ld (clipRight),a	;SMC: changer le jr
		xor a				;valeur qui va remplacer spriteByteX
		ld b,a
clipRight = $+1
		jr $
		ld (spriteByte2),a	;SMC: change the ld (hl),a to a nop (HEX $00)
		ld (spriteByte3),a	;
		ld (spriteByte4),a	;
	pop af
noWorkToDo:
	ld d,0
	ld l,e
	ld h,d
	add hl,hl		;y*2
	add hl,de		;y*3
	add hl,hl		;y*6
	add hl,hl		;y*12
	add hl,de		;y*13
	ld de,megaGbuf+BOSS_W	;86EC+2 (nous dessinons de droite à gauche, les sprites des boss occupent 2 octets, 16 pixels)
	add hl,de
	ld e,a			;a = x
	ld d,b
	add hl,de	
	ld a,c
	ld b,a
yPixelsToDraw = $+1
	ld c,BOSS_H
desBossBoucle:
	push bc
	ld d,(ix)      ;sprite
	ld e,(ix+1)
	ld c,(ix+2)
	xor a
	cp b	;si b = 0
	jp z,spriteAligne
	srl d \ rr e \ rr c \ rra \ djnz $-7   ;rotate sprite
spriteAligne:
	or (hl)				;HL = endroit dans gbuf
spriteByte4 = $
	ld (hl),a			;charger a
	dec hl
	ld a,(hl)
	or c
spriteByte3 = $
	ld (hl),a			;charger c
	dec hl
	ld a,(hl)
	or e
spriteByte2 = $
	ld (hl),a			;charger e
	dec hl
	ld a,(hl)
	or d
spriteByte1 = $
	ld (hl),a			;charger d
	inc ix
	inc ix
	inc ix
	ld de,13+BOSS_W
	add hl,de
	pop bc
	dec c
	jp nz,desBossBoucle
	ld a,LDHLA
	ld (spriteByte4),a
	ld (spriteByte3),a
	ld (spriteByte2),a
	ld (spriteByte1),a
	ret

#comment
desBossHit:
	ld hl,bossDamage
	ld a,(hl)
	or a
	 ret z
	ld hl,(bossX)
	call subMapXHL
	ret c
	ld a,h
	add a,4
	ld hl,(bossY)
	ex af,af'
	call subMapYHL
	ret c
	ex af,af'
	ld e,h
	ld b,16
	ld ix,bossHitSprite
	push af
	push de
		call drawSpriteOr_var
	pop de
	pop af
	add a,8
	ld b,16
	ld ix,bossHitSprite+16
	jp drawSpriteOr_var
#endcomment

desBossHP:
	ld hl,BHPTimer		;boss HP timer
	ld a,(hl)
	or a
	 ret z
	dec (hl)
	ld a,(bossHP)
	rra
	inc a
	ld bc,megaGbuf+(13*6)+11
	ld d,MAX_BOSS_HP/2+1
	jp desBarre

resetBossValues:
	xor a
	ld (bossVelX),a
	ld (bossVelY),a
	ld (bossSpecial),a
	ld a,MAX_BOSS_HP
	ld (bossHP),a				;HP du boss par défaut
	ret

LDHLA = $77		;$77 est le "opcode" de "ld (hl),a"
