chargerMechants:
	ld a,(hl)					;premier octet = nombre de méchants
	ld (nombreMechants),a
	or a
	 ret z
	push hl
		ld e,(hl)
		ld h,MECH_ENTRY_SIZE
		call multEH
		ld c,l
		ld b,h
		inc bc
	pop hl
	call flashToBuffer
	ld hl,gbuf
	ld b,(hl)					;b = nombre de méchants
	inc hl
	ld de,mechantArray
chargerMechantsBoucle:
	push bc
	ld a,(hl)
	ldi							;id
	call checkItemUsed
	xor a
	ldi							;x
	ld (de),a					;x off = 0
	inc de
	ldi							;y
	ldi							;y off
	ldi							;velX
	ldi							;velY
	ldi							;HP
	ld (de),a					;compteur d'animation
	inc de
	ld (de),a					;frame d'animation
	inc de						;sauter information additionnelle
	inc de
	pop bc
	djnz chargerMechantsBoucle
	ret

checkItemUsed:
	sub ENERGY_TANK
	 ret c
	push hl
		ld c,a						;c = 0 : energy tank, c = 1 : one-up
		call iF_offset
		ld a,(hl)
		or a
	pop hl
	 ret z
	dec de
	ld a,$FF						;$FF = méchant mort
	ld (de),a
	inc de
	ret

;c = 0 : energy tank, c = 1 : one-up
iF_offset:
	ld a,(selecteur)
;	add a,a
;	add a,a
;	add a,a
	add a,a						;x2, 8 niveaux, chaque niveau a deux slots
	add a,c
	ld c,a
	ld b,0
	ld hl,itemsFound
	add hl,bc
	ret

;l = sprite #
;a = sprite frame
;sortie:
;(hl) = hauteur de sprite
getSpriteHeight:
	ld h,0
	add hl,hl					;x2
	ld de,mechantsData
	add hl,de
	ld e,(hl)
	inc hl
	ld h,(hl)
	ld l,e
	ld b,a
	or a
	 jr z,skipSpriteAdd
	ld d,0
	 ld e,(hl)
	 inc hl						;sauter octet de la hauteur
	 add hl,de
	djnz $-3
skipSpriteAdd:
;	ld e,(hl)
	ret

effacerMechantSiSecousses:
; >>> Ici on verifie si megaman utilise l'arme guts qui efface tout les mechants de l'écran
	ld a, (shockk)
	cp 1
	 ret m
	ld a,(ix+MECHANT_SPRITE)
	cp ITEM_START
	 ret nc
	xor a
	ld (ix+MECHANT_SPRITE),EXPLOSION
	ld (ix+MECHANT_AF),a
	ld (ix+MECHANT_FRAME),a
	ld (ix+MECHANT_XVEL),a
	ret



desMechants:
	ld hl,nombreMechants	;combien de méchants à afficher
	ld a,(hl)
	or a
	 ret z
	ld b,a
	ld ix,mechantArray
dM_boucle:
	push bc
		ld a,(ix+MECHANT_SPRITE)
		inc a				;si mechant_sprite = $FF, le méchant est mort
		 jp z,dM_B_nextIter	;ennemi mort
		ld l,(ix+MECHANT_YOFF)
		ld h,(ix+MECHANT_Y)
		ld a,h
		cp $F0
		 jr c,$+8
			ld (ix+MECHANT_SPRITE),$FF
			jr dM_B_nextIter
		call subMapYHL		;h = (hl - yCoord)*8 [megaBoss.asm]
		ld a,h
		 jr c,offScreenY
		ld e,h
		cp 72
		 jr c,mechXCheck	;l'ennemi est hors de l'écran
offScreenY:
			ld c,$FF
			cp 88			;64+24, 3 tuiles hors d'écran
			 jr c,mechXCheck
			cp -3
		 	 jr c,dM_B_nextIter
mechXCheck:
		ld l,(ix+MECHANT_XOFF)
		ld h,(ix+MECHANT_X)
		ld a,h
		cp $F0
		 jr c,$+8
			ld (ix+MECHANT_SPRITE),$FF
			jr dM_B_nextIter
		call subMapXHL
		ld a,h
		 jr c,offScreenX
		inc c
		 jr z,offScreenX	;si c = $FF, la valeur Y était hors de l'écran
		cp 96
		 jr c,mechContinue	;si l'ennemi est hors de l'écran
offScreenX:
			bit bossBattle,(iy+zFlags)
			 jr z,dM_B_nextIter
			cp 96+(8*7)
			 jr c,skipDrawMech
			cp -6
		 	 jr c,dM_B_nextIter
		 	jr skipDrawMech
mechContinue:
		push ix
		push af
		push de							;a = x, e = y
			ld l,(ix+MECHANT_SPRITE)	;numéro de sprite
			ld a,(ix+MECHANT_FRAME)
			call getSpriteHeight
skipFrame:
			ld a,e
			ld (prevSpriteHeight),a
			ld (spriteHeight_ptr),hl
			ld b,(hl)
			inc hl
			push hl
			pop ix				;ld ix,hl
		pop de
		pop af				;a/e = x/y
		call drawSpriteOr_var	;a=x, e=y, ix=sprite
		pop ix
		call effacerMechantSiSecousses
skipDrawMech:
		call mechantGravite
		call mechantBougeY
		call mechantBougeX
		call mechantTire
dM_B_nextIter:
	pop bc
	ld de,MECHANT_SIZE	;un constant
	add ix,de
	dec b
	 jp nz,dM_boucle
	ret

playerHit:
	call playerRemoveBullet
	call z,enleverBalle
	ld a,(ix+BALLE_TYPE)
	cp BMEGACUT+$80			;+$80 parce qu'il faut que le "drapeau" (bit 7) soit armé
	 ret z					;si c'est son boomerang, enlever-le mais ne lui faire pas dommage

	ld a,(ix+BALLE_TYPE)
	ld b,1					;combien de dommage à faire
	cp BMACHINEGUN
	 jr z,playerDamage
	cp BOSS_BULLETS
	 jr c,$+4
		ld b,2				;les balles des bosses font plus de dommage
;b = combien de dommage à faire
playerDamage:
	ld hl,HPTimer
	ld (hl),HP_TIMER
	
	ld hl,damageFrames
	ld a,(hl)
	or a
	 ret nz
	ld (hl),DAMAGE_INV		;combien de temps Megaman est invincible après recevoir des dégâts

	ld hl,playerHP
	ld a,(hl)
	sub b
	 jr nc,$+3
		xor a
	ld (hl),a
	ret

;z armé s'il faut enlever la balle
playerRemoveBullet:			;s'il faut enlever la balle ou non
	ld a,(ix+BALLE_TYPE)
	or a
	 ret z
	cp BMEGACUT+$80			;+$80 parce qu'il faut que le "drapeau" (bit 7) soit armé
	ret

;pour passer à ajouterBalle:
;a = type balle
;hl = vélocitéX (l), vélocitéY (h)
;de = y coord
;bc = x coord
mechantTire:
;mettre à jour le compteur d'animation
	ld a,(ix+MECHANT_AF)	;animation de frame
	cp $80					;si bit 7 est armé, il faut décrementer le compteur d'animation
	 jr nz,$+4
		res 7,a				;si a = $80 (%10000000) il faut recommencer à incrémenter le compteur
	or a
	ld b,1					;on ajoute 1 si positif
	 jp p,$+5				;...
		ld b,-1				;et soustrait 1 si négatif
	add a,b
	ld (ix+MECHANT_AF),a	;sauver la nouvelle valeur
;chercher l'action du méchant
	ld d,a
	ld a,(ix+MECHANT_SPRITE)
	ld e,a
	cp ITEM_START
	ld a,d
	 jr nc,animateItem
	ld d,0
	ld hl,enemyActions
	add hl,de
	add hl,de
	ld e,(hl)
	inc hl
	ld h,(hl)
	ld l,e
	jp (hl)					;a = compteur de l'animation du mechant, b = 1 si le compteur incrémente ou -1 s'il décrémente

animateItem:
	res 7,a
	cp 15
	 call z,nextAnimation
	cp 20
	 ret c
	set 7,(ix+MECHANT_AF)
	ret

;enemyActions est dans [megaEnemyData.inc]

animateExplosion:
	cp 3
	 call z,nextAnimation
	cp 6
	 call z,nextAnimation
	cp 9
	 ret nz
	ld (ix+MECHANT_SPRITE),$FF
dropItem:
	ld b,100
	call random
	cp ONE_UP
	 jr z,insertItem
	ld b,NOMBRE_ITEMS*2
	call random
	cp NOMBRE_ITEMS*2
	 jr nz,$+4
		ld a,HEALTH_S				;extra oportunité pour en recevoir
	cp NOMBRE_ITEMS
	 jr nz,$+4
		ld a,ENERGY_S
	cp NOMBRE_ITEMS-2
	 ret nc
	add a,ITEM_START
insertItem:
	ld (ix+MECHANT_SPRITE),a
	ld (ix+MECHANT_XVEL),0
	ld (ix+MECHANT_FRAME),0			;animation frame
	ld (ix+MECHANT_AF),0			;animation counter
	ret

divemanShoot:
	res 7,a
	and $3
	 ret nz
	ld de,(playerX)
	ld a,(playerY+1)
	ld e,a
	ld l,(ix+MECHANT_Y)
	ld h,(ix+MECHANT_X)
	ld a,(ix+MECHANT_FRAME)
	call divePath
	 ret z
	ld (ix+MECHANT_FRAME),a
	ld (ix+MECHANT_XVEL),c
	ld (ix+MECHANT_YVEL),b
	ret

;entrée
;	a = frame d'animation
;	h = balle X
;	l = balle Y
;	d = objet X
;	e = objet Y
;sortie:
;	a = nouveau frame d'animation
;	c = velX de la balle
;	b = velY de la balle
	
newCheck:
	ld a,(playerX+1)
	cp (ix+MECHANT_X)
	 jr c,diveLeft
;right
	ld b,4
	ld a,(playerY+1)
	cp (ix+MECHANT_Y)
	 jr z,diveCalcule				;m en haut
		ld b,3
	 jr c,$+4				;mY > pY, m en bas
		ld b,5
	jr diveCalcule
diveLeft:
	ld b,0					;b = animation
	ld a,(playerY+1)
	inc a
	cp (ix+MECHANT_Y)
	 jr z,$+4				;m en haut
		ld b,1
	 jr c,$+4				;mY > pY, m en bas
		ld b,7
diveCalcule:
	ld a,(ix+MECHANT_FRAME)
	add a,8
	sub b
	and $7
	 ret z
	cp 4
	ld b,-1
	 jr c,$+4
		ld b,1
	ld a,(ix+MECHANT_FRAME)
	add a,b
	and $7
	ld (ix+MECHANT_FRAME),a
	ld c,a
	ld b,0
	ld hl,diveVelocity		;dans [megaEnemyData.inc]
	add hl,bc
	add hl,bc
	ld a,(hl)
	ld (ix+MECHANT_XVEL),a
	inc hl
	ld a,(hl)
	ld (ix+MECHANT_YVEL),a
	ret
	
metShoot:
	res 7,a
	cp 20
	 call z,nextAnimation
	cp 40
	 ret nz
		set 7,(ix+MECHANT_AF)
metMove:
	ld a,-3*32
	ld b,3
metBalleBoucle:
	push bc
	push af
		ld h,a
		ld l,-BULLET_SPEED
		ld c,32*7				;xOff = 7 pixels
		ld b,(ix+MECHANT_X)
		dec b
		ld e,32*2
		ld d,(ix+MECHANT_Y)
		ld a,BMECHANT			;balle normale
		call ajouterBalle		;[megaBullet.asm]
	pop af
	pop bc
	add a,32*3
	 djnz metBalleBoucle
	ret
  

beakShoot:
	and $3F					;63 (enlever bit 7 s'il est armé)
	cp 20
	 ret c
	 call z,nextAnimation
	cp 26
	 call z,nextAnimation
	cp 40
	 jr z,mTire
	cp 63
	 ret nz
		set 7,(ix+MECHANT_AF)
mTire:
	ld b,2
	call random				;[megaBoss.asm]
	dec a
	rrca
	rrca					;décaler numéro aléatoire dans les derniers deux bits
	and %11000000
	ld h,a
	ld l,BULLET_SPEED
	ld c,32*7
	ld b,(ix+MECHANT_X)
	ld a,(ix+MECHANT_SPRITE)
	cp TURRET_R
	 jr z,$+5				;si le turret va tirer vers la droite ou la gauche
		ld l,-BULLET_SPEED
		dec b
	ld e,32*2
	ld d,(ix+MECHANT_Y)
	ld a,BMECHANT			;balle normale
	jp ajouterBalle			;[megaBullet.asm]

octopusShoot:
	res 7,a
	cp 20
	 call z,nextAnimation
	cp 30
	 call z,nextAnimation
	cp 50
	 ret c
	ld (ix+MECHANT_AF),50
	cp 51						;si mechant_af = 50, il faut initialiser la vélocité
	 jr nz,octoInit
		ld a,(ix+MECHANT_YVEL)	;si mechant_af != 50, il faut vérifier que l'octopus n'a pas touché un mur
		or a
		 ret nz
		ld (ix+MECHANT_AF),31+128	;+128 arme bit 7 (128 = %10000000) qui va faire que l'on soustraite un du compteur
		ret
octoInit:
	ld h,(ix+MECHANT_Y)
	push hl
		inc h					;h = coordonnée Y où chercher une collision
		call mechantYCheck		;la coordonnée y au-dessous
	pop hl
	jr z,octopusUp
	 	ld (ix+MECHANT_YVEL),-32
		ret
octopusUp:
	dec h
	call mechantYCheck			;au-dessus
	 ret z
	 	ld (ix+MECHANT_YVEL),32
		ret

bladerShoot:
	and 1
	 call z,nextAnimation
	 jr nz,$+6
		set 7,(ix+MECHANT_AF)
	ld a,(ix+MECHANT_YVEL)
	or a
	 jr nz,bladerReturn
	ld a,(ix+MECHANT_X)
	ld hl,playerX+1
	sub (hl)
	 jr z,bladerAttack
	ld a,24
	 jr c,$+4
		ld a,-24
	ld (ix+MECHANT_XVEL),a
	ret
bladerAttack:
	ld a,(ix+MECHANT_Y)
	ld (ix+MECHANT_YVEL),96
	ld (ix+MECHANT_EXTRA),a	;où rentrer après avoir baissé
	ret
bladerReturn:
	ld a,(ix+MECHANT_Y)
	dec a
	ld hl,playerY+1
	cp (hl)
	 jr c,$+6
		ld (ix+MECHANT_YVEL),-96
	ld a,(ix+MECHANT_EXTRA)
	cp (ix+MECHANT_Y)
	 ret c
	ld a,(ix+MECHANT_YOFF)
	or a
	 ret nz
	ld (ix+MECHANT_YVEL),0
	ret

screwShoot:
	ex af,af'
		ld a,(ix+MECHANT_X)
		ld hl,playerX+1
		sub (hl)
		add a,2
		cp 6
		 jr c,screwExtend
			set 7,(ix+MECHANT_AF)
screwExtend:
	ex af,af'
	res 7,a
	cp 2*5
	 jr c,$+7
	 	sub 2*3
		ld (ix+MECHANT_AF),a
	srl a		;/2
	ld (ix+MECHANT_FRAME),a
	cp 2
	ld a,(ix+MECHANT_EXTRA)
	ld (ix+MECHANT_EXTRA),0
	 ret c
	inc a
	ld (ix+MECHANT_EXTRA),a
	and $1F
	 ret nz
circleShoot:
	ld hl,BULLET_SPEED
	ld c,(ix+MECHANT_XOFF)
	ld b,(ix+MECHANT_X)
	ld e,(ix+MECHANT_YOFF)
	ld d,(ix+MECHANT_Y)
	inc b						;coord X (X+1)
	call tirerBalle				;--- tirer
	ld h,BULLET_SPEED			;vel Y
	inc d						;coord Y (Y+1)
	call tirerBalle				;--- tirer
	dec b						;coord X (X)
	ld l,0						;vel X
	call tirerBalle				;--- tirer
	dec b						;coord X (X-1)
	ld l,-BULLET_SPEED			;vel X
	call tirerBalle				;--- tirer
	ld h,0						;vel Y
	dec d						;coord Y (Y)
tirerBalle:
	push bc
	push hl
	push de
		ld a,BMECHANT			;balle normale
		call ajouterBalle		;[megaBullet.asm]
	pop de
	pop hl
	pop bc
	ret

;peut-être l'enlever quand il sort de l'écran/la carte ?
flyingShoot:
	ld (ix+MECHANT_XVEL),-32
	res 7,a
	cp 20
	 call z,nextAnimation
	 ret c
	ld (ix+MECHANT_XVEL),0
	cp 40
	 ret nz
	set 7,(ix+MECHANT_AF)
	call circleShoot			;tirer 5 balles autour du méchant
	ld h,-BULLET_SPEED			;vel Y (left)
	dec d						;coord Y (Y-1)
	call tirerBalle
	ld l,0						;vel X (up)
	inc b						;coord X (X)
	call tirerBalle
	ld l,BULLET_SPEED			;vel X (right)
	inc b						;coord X (X)
	jr tirerBalle


fleaShoot:
	res 7,a
	cp 13
	 call z,nextAnimation
	cp 14
	 call z,nextAnimation
	cp 15					;les animations occurent une après l'autre
	 ret c
fleaJump:
	jr z,fleaStartJump
		ld a,(ix+MECHANT_YVEL)
		or a
		jr nz,$+11
			ld (ix+MECHANT_XVEL),0
			ld (ix+MECHANT_AF),$8F
			ret
		sub 5
		ld (ix+MECHANT_YVEL),a
		ld (ix+MECHANT_AF),16
		ret
		cp 30
		 ret nz
		set 7,(ix+MECHANT_AF)
fleaStartJump:
	ld a,(playerX+1)			;x alignée
	cp (ix+MECHANT_X)
	ld a,26
	 jr nc,$+4
		ld a,-26
	ld (ix+MECHANT_XVEL),a
	ld (ix+MECHANT_YVEL),-81
	ret

spineShoot:
	res 7,a
	cp 5
	call z,nextAnimation
	cp 10
	 jr nz,spineVelocity
		set 7,(ix+MECHANT_AF)
spineVelocity:
	ld b,(ix+MECHANT_X)
	ld h,(ix+MECHANT_Y)
	inc h

	ld a,(ix+MECHANT_XVEL)
	rla							;si velX est positive
	 jr c,$+3
		inc b					;ajouter un à la coordonnée X
;vérifier qu'il est à terre
	ld a,(ix+MECHANT_YVEL)		;seulement pour le niveau de Wily
	or a
	 ret nz
	call mechantHitY
	 call z,inverseXVel
;et maintenant la vélocité
	ld c,16
	ld a,(playerY+1)
	inc a
	cp (ix+MECHANT_Y)
	 jr nz,spineSlow
	ld a,(playerY)				;y offset du joueur
	or a
	 jr nz,spineSlow
	ld c,64
spineSlow:
	ld a,(ix+MECHANT_XVEL)
	bit 7,a
	ld a,c
	 jr z,$+4
		neg
	ld (ix+MECHANT_XVEL),a
	ret

nextAnimation:
	push af
		ld a,(ix+MECHANT_FRAME)
		add a,b
		ld (ix+MECHANT_FRAME),a
		ld a,(prevSpriteHeight)
		ld e,a
		ld hl,(spriteHeight_ptr)
		ld c,(hl)				;la hauteur du sprite actuel
		 jr nc,$+4
			ld a,c				;hauteur de [frame+1] - hauter du frame actuel
			ld c,e
		 jr c,$+8
		 	ld b,0				;bc = hauteur du sprite actuel
			inc hl
			add hl,bc
			ld a,c
			ld c,(hl)			;hauteur de [frame] - [frame+1]
		sub c
		ld e,a
		call signExtendE		;il faut sign extend maintenant parce que plus tôt toutes les valeurs vont paraitre négatives
		rrca
		rrca
		rrca
		and %11100000
		ld e,a
		ld l,(ix+MECHANT_YOFF)
		ld h,(ix+MECHANT_Y)
		add hl,de
		ld (ix+MECHANT_YOFF),l
		ld (ix+MECHANT_Y),h
	pop af
	ret

mechantGravite:
	ld a,(ix+MECHANT_SPRITE)
	cp MECHANT_GRAVITE		;faut-il ajouter de la gravité ?
	 ret c
	xor a
	ld hl,$0940
	ld e,(ix+MECHANT_YOFF)
	ld d,(ix+MECHANT_Y)
	sbc hl,de
	 jr z,storeMechGrav
	ld a,(ix+MECHANT_YVEL)
	add a,GRAVITY
	bit 7,a
	 jr nz,$+8
		cp 127-GRAVITY
		 jr c,$+4
		 	ld a,127-GRAVITY
storeMechGrav:
	ld (ix+MECHANT_YVEL),a
	ret

mechantBougeY:
	ld l,(ix+MECHANT_YOFF)
	ld h,(ix+MECHANT_Y)
	ld e,(ix+MECHANT_YVEL)
	call signExtendE
	add hl,de
	ld (ix+MECHANT_YOFF),l
	ld (ix+MECHANT_Y),h
;méchant qui peut passer partout
	ld a,(ix+MECHANT_SPRITE)
	cp BLADER
	 ret z
	bit 7,e							;si bit 7 est armé, la vélocité est négative
	 jr z,mechBougeBasY
;en haut: faire quoi ?
	ld h,(ix+MECHANT_Y)
	call mechantYCheck				;vérifier s'il y a eu des collisions: h=valeur Y à vérifier
	 ret z
	ld a,(ix+MECHANT_Y)
	inc a
	ld (ix+MECHANT_Y),a
	xor a
	ld (ix+MECHANT_YVEL),a
	ld (ix+MECHANT_YOFF),a
	ret
mechBougeBasY:
;détecter collisions avec la carte, etc.
;il faut ajouter la hauteur du sprite à la coordonnée y de Megaman
	push hl							;méchant Y
		ld hl,(spriteHeight_ptr)	;addresse de l'octet de la hauteur du sprite actuel
		ld e,(hl)					;taille du sprite
		ld d,0
		ld a,e
		ex af,af'
		ex de,hl
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl					;décaler taille 5 bits vers la gauche
		add hl,hl					;parce que l'offset X commence dans bit 5
	pop de							;méchantY
	add hl,de						;mechantY + hauteur de sprite
	call mechantYCheck				;vérifier s'il y a eu des collisions
	 ret z							;quitter si pas de collision
	ld (ix+MECHANT_YVEL),0			;mettre vélocité à zéro
	ex af,af'						;a = taille du sprite
;établir l'offsetY: 8-spriteHeight ou 16-spriteheight, selon la taille du sprite
	ld b,a							;b = hauteur du sprite
	ld a,8
	sub b							;8 - hauteur du sprite pour obtenir l'offset Y
	 jr nc,$+4
		add a,8						;s'il y a un carry, il faut ajouter 8 (on peut pas avoir un offset Y négatif !)
	rrca
	rrca
	rrca							;l'offset commence dans les trois derniers bits (les premiers bits sont des décimals)
	and %11100000					;est-ce nécéssaire ?
	ld (ix+MECHANT_YOFF),a
	ret

;h = valeur Y à vérifier
;nz = pas passable
mechantYCheck:
	ld a,(ix+MECHANT_SPRITE)
	cp DIVE
	 ret z
;premier x
	ld b,(ix+MECHANT_X)
	call mechantHitY
	 ret nz
	ld a,(ix+MECHANT_XOFF)
	and $C0
	 ret z							;ret si XOFF = 0
	inc b
;deuxième x
;	jr mechantHitY

;h = y
;b = x
mechantHitY:
	push hl
	push bc
		ld a,h
		call getYOffset
	pop bc
	push bc
		call addXOffset
		call getBrush
		ld a,(hl)						;maptile: le plus à gauche
		bit 1,a
	pop bc
	pop hl
	ret

mechantBougeX:
	ld l,(ix+MECHANT_XOFF)
	ld h,(ix+MECHANT_X)
	ld e,(ix+MECHANT_XVEL)
	call signExtendE
	add hl,de
	ld (ix+MECHANT_XOFF),l
	ld (ix+MECHANT_X),h

;chercher une collision avec Megaman
;hl = méchant x
;méchant X - player X	> 0, mechant à droite
;						< 0, méchant à gauche
;collision: (méchant X) - (playerX) + méchantLargeur <= méchantLargeur + playerLargeur
	push hl
	push de
		ld de,%11000000			;+6 (un méchant a 6 pixels de largeur)
		add hl,de				;diminuer boîte de collision
		ld de,(playerX)
		sbc hl,de
		ld a,h
		cp -2
		 jr nc,$+5
			jp m,noCollisionMechant
		add hl,hl
		 jr c,noCollisionMechant
		add hl,hl
		 jr c,noCollisionMechant
		add hl,hl
		 jr c,noCollisionMechant
		ld a,h
		cp 16+6-2				;+6 pour le +6, et -2 pour les collisions de gauche
		 jr nc,noCollisionMechant
		ld c,a
;méchant X - player X	> 0, mechant à droite
;						< 0, méchant à gauche
;collision: (méchant Y) - (playerY) + méchantHauteur <= méchantHauteur+playerHauteur

		ld hl,(spriteHeight_ptr)
		ld a,(hl)
		sub 2						;diminuer la boîte de collision un peu
		ld l,a
		ld h,0
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl					;décaler hauteur 5 bits vers la gauche
		add hl,hl					;parce que l'offset commence dans bit 5
		ld e,(ix+MECHANT_YOFF)
		ld d,(ix+MECHANT_Y)
		add hl,de
		ld de,(playerY)
		sbc hl,de
		add hl,hl
		add hl,hl
		add hl,hl
		add a,14					;hauteur de Megaman
		cp h
		 jr c,noCollisionMechant
			ld de,noCollisionMechant
			push de					;où retourner
			ld a,(ix+MECHANT_SPRITE)
			cp ITEM_START
			 jp nc,itemEffect		;[megaItems.asm]
			ld a,(damageFrames)
			or a
			 jp nz,playerDamage
			ld hl,pushPlayer
			ld (hl),5
			ld a,c
			cp 12
			ld a,64
			 jr c,$+4
				ld a,-64
			ld (velocityX),a
			ld b,1
			jp playerDamage
noCollisionMechant:
	pop de					;x vel
	pop hl					;méchant X
	ld a,(ix+MECHANT_SPRITE)
	cp BLADER				;blader peut passer à travers les murs
	 ret z
	cp FLYING				;flying shell aussi
	 ret z
	ld a,e
	or a
	 ret z					;s'il n'y a pas de vélocité X quitter
	bit 7,e
	 jr nz,mechBougeNegX
;bougeDroite
	ld a,(ix+MECHANT_Y)
	ld b,h
	inc b
	call mechantXCheck
	 ret z
mB_hitPosX:
	ld (ix+MECHANT_XOFF),0
	call inverseXVel
	ret
mechBougeNegX:
	ld b,h
	call mechantXCheck
	 ret z
mB_hitNegX:
	ld a,(ix+MECHANT_X)
	inc a
	ld (ix+MECHANT_X),a
	ld (ix+MECHANT_XOFF),0
	call inverseXVel
	ret

;b = valeur X à chercher
mechantXCheck:
	ld a,(ix+MECHANT_SPRITE)
	cp DIVE
	 ret z
;premier Y
	ld a,(ix+MECHANT_Y)
	call mechantHitX
	 ret nz
;deuxième Y
	ld a,(ix+MECHANT_YOFF)
	rlca
	rlca
	rlca
	ld hl,(spriteHeight_ptr)
	add a,(hl)				;la hauteur du sprite actuel
	and $7					;si mechantYOff + hauteur du sprite est un multiple de huit
	 ret z					;... le sprite est aligné
	ld a,(ix+MECHANT_Y)
	inc a
	jr mechantHitX

inverseXVel:
  push af
  ld a, (ix + MECHANT_XVEL)
  neg 
  ld (ix + MECHANT_XVEL), a
  pop af
  ret

mechantHitX:
	push bc
	push bc
		call getYOffset	;a = y position de la tuile à chercher
	pop bc				;b = player X
	call addXOffset		;b = combien d'octets à droit (+)/ à gauche (-) qu'il faut chercher
	call getBrush
	ld a,(hl)			;maptile: le plus à gauche
	bit 1,a
	pop bc
	ret
