;This is my tigersuit 'cuz i'm a fucking lamb

;si tu ajoutes une nouvelle variable: changer la multiplication dans ajouterBalle et initialiser la nouvelle variable
BULLET_SIZE = 10
;bulletArray:
;mapX			2
;mapY			2
;type			1
;velocityX		1
;velocityY		1
;animationCounter 1
;animationFrame	1
;extra			1
;----------------
;total ======== 10

desBalles:
	ld hl,weaponDelay
	ld a,(hl)
	or a
	 jr z,$+3
		dec (hl)
	ld ix,bulletArray
	; Si aucune balle alors ne rien faire 
	ld a,(numberBullets)
	or a
	 ret z
	; Sinon on itere sur chaque balle
	ld b,a
dB_boucle:
; Tester si la balle est dans l'écran
	push bc
		inc (ix+BALLE_AC)		;incrémenter compteur d'animation
;y
		ld l,(ix+BALLE_YOFF)	;balleY LSB
		ld h,(ix+BALLE_Y)		;balleY MSB
		ld e,(ix+BALLE_VELY)
		call signExtendE
		add hl,de				;ajouter vélocité Y aux coordonnées actuelles
		ld (ix+BALLE_YOFF),l
		ld (ix+BALLE_Y),h		;sauvegarder les nouvelles coordonnées
		call subMapYHL			;[megaBoss.asm]
		ld a,h
		or a
		 jp p,$+13
			cp -4
			 jr nc,$+4
				ld h,-4
			add hl,hl
			add hl,hl
			add hl,hl
			ld a,h
		cp -20
		 jr nc,balleXCheck
		cp 64+8
		 jr c,balleXCheck		;hors d'écran
		 	cp -24
		 	 jr nc,$+7
				cp 88
				 jp nc,removeBullet
			ld a,$FF				;si le sprite est hors d'écran, mettre e à $FF
balleXCheck:
		ld e,a					;e = coordonnée y (drawSpriteOr_var)
;x
		ld l,(ix+BALLE_XOFF)	;balleX LSB (offset)
		ld h,(ix+BALLE_X)		;balleX MSB (aligné)
		ld c,(ix+BALLE_VELX)
		bit 7,c					;vel X est-elle négative ?
		ld b,0					;b = 0
		 jr z,$+3
			dec b				;si oui, sign extend b ($00-$01 = $FF)
		add hl,bc				;vélocité X + balle X

		ld a,(mapWidth)			;si la balle X >= la largeur de la carte, la balle est hors de la carte
		cp h					; la balleX est: 1. négative, 2. plus que mapWidth
		 jr c,removeBullet
		
		ld (ix+BALLE_XOFF),l
		ld (ix+BALLE_X),h		;sauvegarder les nouvelles coordonnées

		ld a,e
		inc a
		jr z,dB_B_nextIter		;après avoir mis à jour balleX, quitter si balleY est hors de l'écran
		
		ld a,(xCoord)
		ld c,0					;ld c,0
		ld b,a					;bc = xCoord (de la carte)
		sbc hl,bc				;balleX - xCoord
		ld a,h
		add a,7					;la balle s'enlevera quand elle est cinq tuiles hors d'écran
		cp 19+5
		 jr nc,removeBullet		;si la balle est quelques tuiles hors d'écran, enlever-la
		add hl,hl
		add hl,hl
		add hl,hl
		ld a,h					;a = x valeur absolue dans l'écran
		cp 96
		 jr nc,dB_B_nextIter	;x < 0 ou x > 96
		push ix
			ld c,(ix+BALLE_TYPE)
			ld b,0
			res 7,c				;on utilise bit 7 comme drapeau
			ld hl,bulletSprites
			add hl,bc
			add hl,bc			;chaque entrée occupe 2 octets
			ld c,(hl)
			inc hl
			ld h,(hl)
			ld l,c

			push de
				ex af,af'
					ld a,(hl)
					ld e,a
					ld (bulletHeight),a
				ex af,af'
				ld d,0
				ld b,(ix+BALLE_AF)	;frame actuel de la balle
				dec b \ inc b
				 jr z,$+5
					add hl,de
					djnz $-1
			ld b,e				;hauteur
			pop de
			inc hl				;sauter octet de la hauteur
			push hl
			pop ix
			call drawSpriteOr_var	;a=x, e=y, ix=sprite, b=hauteur [megaSpriteRoutines.asm]
		pop ix
	call checkPlayerHit
dB_B_nextIter:
	call bulletPath				;bulletPath s'occupe de la trajectoire des balles et leur animation
	call checkMechantsHit
	call checkBossHit
removeReturn:
	pop bc
	ld de,BULLET_SIZE
	add ix,de
	dec b
	jp nz,dB_boucle
retJump:
	ret

removeBullet:
	call enleverBalle		; hors d'écran, enlever balle
	jr removeReturn

;bulletPath s'occupe de la trajectoire des balles et leur animation
bulletPath:
	ld a,(ix+BALLE_TYPE)
	and %01111111
	 ret z
	sub BMEGACUT			;les premières quatre balles n'ont pas de trajectoire
	 ret c
	add a,a
	ld hl,bulletPathTable	;[megaMan.asm]
	ld e,a
	ld d,0
	add hl,de
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	jp (hl)

;bulletPathTable est dans [megaMan.asm]
WOOD_START = 7
pathMegaWood:
	ld a,(ix+BALLE_AC)
	cp WOOD_START
	ld e,(ix+BALLE_EXTRA)	;vers quelle direction va la balle : 0 = vers la droite, $FF = vers la gauche
	 jr nc,woodStart
		ld a,(ix+BALLE_VELX)	;si l'on va vers la droite, quitter
		cp $80
		ld a,$FF
		adc a,0
		ld (ix+BALLE_EXTRA),a	;sinon, on va vers la gauche
		ret
woodStart:
	ld bc,0
	cp 48+WOOD_START
	 jr nc,woodUpdate
	inc e
	 jr z,woodLeft
	ld bc,$F8E0			;vel x -= 8, vel y = -32
	cp 24+WOOD_START
	 jr c,woodUpdate
	ld bc,$0820			;vel x += 8, vel y = 32
	jr woodUpdate
woodLeft:
	ld bc,$08E0			;vel x -= 8, vel y = -32
	cp 24+WOOD_START
	 jr c,woodUpdate
	ld bc,$F820			;vel x -= 8, vel y = 32
woodUpdate:
	ld (ix+BALLE_VELY),c
	ld a,(ix+BALLE_VELX)
	add a,b
	ld (ix+BALLE_VELX),a
	ret

pathMegaDive:
	ld a,(ix+BALLE_EXTRA)
	inc a
	 jr z,initialiserDive
	ld a,(ix+BALLE_AC)
	and $3
	 ret nz
	ld b,(ix+BALLE_EXTRA)
	inc b
	ld de,MECHANT_SIZE
	ld hl,mechantArray-MECHANT_SIZE
		add hl,de
	 djnz $-1
	ld a,(hl)
	inc a
	 jp z,enleverBalle
	inc hl
	ld d,(hl)			;méchant X
	inc hl				;sauter méchant x off
	inc hl
	ld e,(hl)			;méchant Y
	dec e
	ld l,(ix+BALLE_Y)
	ld h,(ix+BALLE_X)
	ld a,(ix+BALLE_AF)
	call divePath
	 ret z
	ld (ix+BALLE_AF),a
	ld (ix+BALLE_VELX),c
	ld (ix+BALLE_VELY),b
	ret

initialiserDive:
	ex af,af'
		ld a,$FF
		ld (lowestValue),a		;initialiser
	ex af,af'
	ld hl,mechantArray
	ld a,(nombreMechants)
	ld b,a
	ld de,(playerX+1)
	ld a,(playerY+1)
	ld d,a
;d = playerY
;e = playerX
chercherMechantBoucle:
	ld a,(hl)
	cp ITEM_START
	 jr nc,sauterMechant		;on ne va pas tuer un item !
	push hl
		inc hl					;méchantX
		ld a,(hl)
		sub e					;-playerX
		 jr nc,$+4
			neg
		ld c,a
		inc hl
		inc hl					;méchantY
		ld a,(hl)
	pop hl
	sub d					;-playerY
	 jr nc,$+4				;si la valeur est négative, changer-la à une valeur positive
		neg
	add a,c
lowestValue = $+1
	cp $00
	 jr nc,sauterMechant
	ld (lowestValue),a
	ex af,af'
		ld a,(nombreMechants)
		sub b				;méchant plus proche dans a'
	ex af,af'
sauterMechant:
	push de
		ld de,MECHANT_SIZE
		add hl,de
	pop de
	djnz chercherMechantBoucle
	ex af,af'				;a = méchant le plus proche
		ld (ix+BALLE_EXTRA),a
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
divePath:
	ex af,af'
	ld a,d
	cp h
	 jr c,objetGauche		;si balle X > objet X, l'objet est à gauche
	 jr z,objetAligne
;droite
	ld b,4					;right
	ld a,e					;objetY
	cp l					;balleY
	 jr z,calculeDirection	;si objet Y = balle Y, aller vers la droite
		ld b,3				;up right
	 jr c,$+4				;bY > oY, m en bas
		ld b,5				;down right
	jr calculeDirection
objetAligne:
	ld b,2					;up
	ld a,e					;objetY
	cp l					;balleY
	 jr c,calculeDirection	;si objet Y = balle Y, aller vers la droite
		ld b,6				;down
		jr calculeDirection
objetGauche:
	ld b,0					;b = animation
	ld a,e					;objetY
	cp l					;balleY
	 jr z,calculeDirection	;objet en haut
		ld b,1
	 jr c,$+4				;mY > pY, m en bas
		ld b,7
calculeDirection:
	ex af,af'				;a = frame d'animation
	ld c,a
	add a,8
	sub b
	and $7
	 ret z					;= 0 si la balle déjà va dans le bon sens
	cp 4
	ld b,-1
	 jr c,$+4
		ld b,1
	ld a,c
	add a,b
	and $7					;a = frame d'animation
	ld c,a
	ld b,0
	ld hl,diveVelocity		;[megaEnemyData.inc]
	add hl,bc
	add hl,bc
	ld c,(hl)
	inc hl
	ld b,(hl)
	sbc hl,bc				;armer nz
	ret

pathMegaFire:
	ld c,1						;la balle ne s'enlevera jamais si on peut pas divider c par 4
	call fireAnimation
	ret

pathMegaFireShield:
	ld c,32						;faut pouvoir le divider par quatre
	call fireAnimation
	 ret z						;si z est armé, la balle a été enlevée
	ld hl,velocityY
	ld e,(hl)
	ld d,$FF					;on va mettre la vélocité y dans e, mettre d = $FF (negative sign-extended)
								; si on est on train de sauter le numéro doit être positif, inc d et d = 0
	bit jumpStart,(iy+zFlags)	;est-on en train de sauter ?
	 jr nz,$+3
		inc d					;de = positif (d=00)

	ld l,(ix+BALLE_YOFF)
	ld h,(ix+BALLE_Y)
	add hl,de				;ajouter playerY += velocityY
	ld (ix+BALLE_YOFF),l
	ld (ix+BALLE_Y),h
	ld a,(velocityX)
	ld (ix+BALLE_VELX),a
	ret

pathMegaCut:
;la prochaine animation
	ld a,(ix+BALLE_AF)
	inc a
	and $3
	ld (ix+BALLE_AF),a

	bit 7,(ix+BALLE_TYPE)
	 jr z,dontReturn			;bit 7 est utilisé comme un drapeau
	ld hl,(playerY)
	call subBulYHL				;bossY - balleY
	ld a,h
	add a,6						;la balle doit aller vers ses bras
	push af
		ld hl,(playerX)
		inc h					;vers son corps
		call subBulXHL
	pop de
	ex de,hl
	call aimBullet				;h = dY, d = dX
	ld (ix+BALLE_VELY),a
	ld (ix+BALLE_VELX),l
	ret
dontReturn:
	ld a,(ix+BALLE_VELX)
	bit 7,a
	ld b,3
	 jr nz,$+4
		ld b,-3
	add a,b
	ld (ix+BALLE_VELX),a
	
	ld a,(ix+BALLE_VELY)
	add a,10
	ld (ix+BALLE_VELY),a
	cp 120
	 ret nz
	set 7,(ix+BALLE_TYPE)
	ret		
pathMetalman:
	ld a,(ix+BALLE_AC)
	and $3
	 ret nz
	ld a,(ix+BALLE_AF)
	xor 1
	ld (ix+BALLE_AF),a
	ret

pathWoodmanFall:
	ld a,(ix+BALLE_AC)
	and $F
	 ret nz
	ld a,(ix+BALLE_VELX)
	neg
	ld (ix+BALLE_VELX),a
	ret

pathWoodman:
	ld a,(ix+BALLE_VELY)
	cp -BULLET_SPEED
	 ret z
	ld a,(bossShield)
	or a
	 jr nz,dontShootShield
		ld a,(bossDir)
		or a				;0 = droite, 1 = gauche
		ld a,BULLET_SPEED
		 jr z,$+4
			ld a,-BULLET_SPEED
		ld (ix+BALLE_VELX),a
		ld (ix+BALLE_VELY),0
		ret
dontShootShield:
	bit 7,(ix+BALLE_TYPE)
	ld a,10
	 jr nz,$+4
		ld a,-10
	add a,(ix+BALLE_VELX)
	ld (ix+BALLE_VELX),a
	cp 90
	 jr nz,$+6
		res 7,(ix+BALLE_TYPE)
	cp -90
	 jr nz,$+6
		set 7,(ix+BALLE_TYPE)
;ajuster la vélocité Y selon la vélocité X pour qu'il faisse un cercle
	or a
	 jp p,woodPositive
		add a,90
		bit 7,(ix+BALLE_TYPE)
		 jr nz,$+4
			neg
		ld (ix+BALLE_VELY),a
		ret
woodPositive:
	sub 90
	bit 7,(ix+BALLE_TYPE)
	 jr z,$+4
		neg
	ld (ix+BALLE_VELY),a
	ret

pathElecman:
	ld a,(ix+BALLE_AC)
	and $3
	 ret nz
	ld a,(ix+BALLE_AF)		;compteur d'animation
	inc a
	cp 3
	 jr c,$+3
		xor a
	ld (ix+BALLE_AF),a
	ret

pathGutsman:
	ld a,(ix+BALLE_VELX)
	or a
	 jr nz,checkHitGround
	ld hl,(bossY)
	ld b,(ix+BALLE_Y)
	ld c,(ix+BALLE_YOFF)
	sbc hl,bc
	add hl,hl
	add hl,hl
	ld a,h
	cp 8
	 ret nc
	ld (ix+BALLE_VELY),0
	ld a,(bossSpecial)
	cp 2
	 ret nz					;il faut attendre le signal (bossSpecial = 2 signifie qu'il va jeter le bloc)
	ld hl,(playerY)
	inc h
	inc h					;jeter le bloc vers les pieds de Megaman (chaque inc h = playerY+8)
	ld bc,(bossY)			;pX-bX
	sbc hl,bc
	add hl,hl
	add hl,hl
	add hl,hl				;h = pX-bX
	ex de,hl			;sauver dY*BULLET_SPEED dans de
		ld hl,(playerX)
		ld bc,(bossX)
		sbc hl,bc			;pX-bX
		add hl,hl
		add hl,hl
		add hl,hl			;de = (playerY-bossY)*BULLET_SPEED, h = playerX-bossX
	ex de,hl
	call aimBullet			;h = dY, d = dX [megaBullet.asm]
	ld (ix+BALLE_VELX),l
	ld (ix+BALLE_VELY),a
	ret
checkHitGround:
	ld l,(ix+BALLE_YOFF)
	ld h,(ix+BALLE_Y)
	ld de,8*256+(2*32)
	sbc hl,de
	 ret c
	ld a,(ix+BALLE_TYPE)
	cp BGUTSMANR
	 jp z,enleverBalle

;hl = velX/velY, de = balleY, bc = balleX, a = type de balle [megaBullet.asm]
	ld c,(ix+BALLE_XOFF)
	ld b,(ix+BALLE_X)
	ld e,(ix+BALLE_YOFF)
	ld d,(ix+BALLE_Y)
	ld l,(ix+BALLE_VELX)
	ld h,0
	ld a,BGUTSMANBLOCK
	call ajouterUne

	ld h,-96
	call ajouterUne

	inc b
	inc d
	call ajouterUne

	ld h,0
	call ajouterUne
	jp enleverBalle

ajouterUne:
	push bc
	push de
	push hl
	push af
		call ajouterBalle
	pop af
	pop hl
	pop de
	pop bc
	ret

pathFiremanFlame:
	ld c,12
fireAnimation:
	ld a,(ix+BALLE_AC)
	ld b,a
	and 3
	 ret nz
	ld a,(ix+BALLE_AF)		;frame d'animation
	xor 1
	ld (ix+BALLE_AF),a
	ld a,b
	cp c
	 ret nz					;si le compteur = c, enlever la balle
	call enleverBalle
	or a
	ret

pathFireman:
	bit 7,(ix+BALLE_TYPE)
	 jr nz,pF_animate		;si on a déjà laissé une flamme, sauter
	ld a,(playerX+1)
	inc a
	cp (ix+BALLE_X)
	 jr nz,pF_animate
	set 7,(ix+BALLE_TYPE)
	ld hl,0
	ld e,%00100000
	ld d,TERRE_Y+2
	ld c,(ix+BALLE_XOFF)
	ld b,(ix+BALLE_X)
	ld a,BFIREMANFLAME		;type de balle
	call ajouterBalle		;hl = velX/velY, de = balleY, bc = balleX, a = type de balle [megaBullet.asm]
pF_animate:
	ld a,(ix+BALLE_AC)		;compteur d'animation
	cp 10
	 ret nz
	inc (ix+BALLE_AF)
	ret

pathCutman:
;1 = cutman
	bit 7,(ix+BALLE_TYPE)
	 jr z,balleVa				;bit 7 est utilisé comme un drapeau, ici pour savoir si la balle va ou retourne vers le boss
;si la balle a touche un mur et rentre vers le boss
	ld hl,(bossY)
	call subBulYHL				;bossY - balleY
	ld a,h
	add a,6						;la balle doit aller vers ses bras
	push af
		ld hl,(bossX)
		inc h					;vers son corps
		call subBulXHL
	pop de
	ex de,hl
	call aimBullet				;h = dY, d = dX
	ld (ix+BALLE_VELY),a
	ld (ix+BALLE_VELX),l
	ret

pathIceman:
	ld a,(ix+BALLE_AC)		;compteur d'animation
	and $3
	ld (ix+BALLE_AC),a
	 ret nz
	ld a,(ix+BALLE_AF)		;compteur d'animation
	xor 1
	ld (ix+BALLE_AF),a
	ret

pathWalker:
;vérifier pour des chocs avec le map
	ld a,(ix+BALLE_X)
	dec a					;if a=0 or mapWidth-1
	cp 15					;mapwidth-3 (à cause du dec a, les coordonnées commence de 0,
	 jr nc,walkerHit		;  et chaque balle a 8 pixels de largeur)
	ld a,(ix+BALLE_Y)
	dec a
	cp 8					;mapHeight-2
	 ret c
walkerHit:
	ld (ix+BALLE_AC),0	;mettre compteur à zéro
	ld (ix+BALLE_TYPE),BWALKEREXPL
	ld l,10
	bit 7,(ix+BALLE_VELX)
	 jr z,$+4
		ld l,-10
	ld h,10
	bit 7,(ix+BALLE_VELY)
	 jr z,$+4
		ld h,-10
	ld (ix+BALLE_VELX),l
	ld (ix+BALLE_VELY),h
	ld e,(ix+BALLE_YOFF)
	ld d,(ix+BALLE_Y)
	ld c,(ix+BALLE_XOFF)
	ld b,(ix+BALLE_X)
	inc b				;8 pixels à droite
	ld a,BWALKEREXPR	;type de balle
	jp ajouterBalle		;hl = velX/velY, de = balleY, bc = balleX, a = type de balle

balleVa:
	ld a,(ix+BALLE_X)
	dec a
	 jr z,balleBord
	cp 16-1				;bossroom width-1 (à cause du dec a)
	 jr nc,balleBord
	ld a,(ix+BALLE_Y)
	dec a
	 jr z,balleBord
	cp 9-1				;hauteur du bossroom
	 ret c
balleBord:
	ld a,(ix+BALLE_VELX)
	neg
	ld (ix+BALLE_VELX),a
	set 7,(ix+BALLE_TYPE)
	ret

pathWalkerExplosion:
	ld a,(ix+BALLE_AC)
	cp 16
	 jp z,enleverBalle
	cp 4
	 ret nz
	inc (ix+BALLE_AF)
	ret

pathHoverChase:
	ld a,(ix+BALLE_VELY)
	add a,8
	ld (ix+BALLE_VELY),a
	ld a,(ix+BALLE_Y)
	cp 8
	 jp z,walkerHit
pathMachineGun:
	ret

checkMechantsHit:
	ld a,(ix+BALLE_TYPE)
	cp BMECHANT
	 ret z
	ld a,(nombreMechants)
	or a
	 ret z
	ld b,a
	ld hl,mechantArray
cMH_boucle:
	ld a,(hl)
	ld (spriteNum),a
	cp ITEM_START				;sauter si c'est un item
	 jr nc,nextEnemy
	push bc
	push hl
	inc hl
		ld a,(hl)				;méchantX
		inc hl
		push hl
			ld l,(hl)			;méchantXOff
			ld h,a
			call subBulXHL		;méchantX - balleX
			ld a,h
		pop hl
		add a,8					;mouver la zone de collision
		cp 8+6
		 jr nc,skipKillEnemy
		inc hl
		ld a,(hl)				;méchantY
		inc hl
		push hl
			ld l,(hl)			;mechant Y offset
			ld h,a
			call subBulYHL		;
			ld a,h
		pop hl
		inc hl					;xVel
		inc hl					;yVel
		inc hl					;HP !
		push hl					;vérifer si le méchant a une armeur
			ex af,af'
				inc hl				;compteur d'animation
				inc hl				;frame d'animation
				ld a,(hl)
				ld (spriteFrame),a
spriteNum = $+1
				ld l,0
					call getSpriteHeight
			ex af,af'
		ld e,(hl)				;e = hauteur du méchant
		pop hl
	 	ld c,a					;c = méchantY-balleY
	 	ld a,(bulletHeight)
		add a,e					;hauteur de la balle + hauteur du méchant
		ld d,a
		ld a,e
		add a,c					;(méchantY + méchantHauteur) - mapY
		cp d					;hauteur de la balle
		 jr nc,skipKillEnemy	;si (méchY+méchH)-mapY > (balleH+méchH), pas de collision
								;... on ajoute la hauteur du méchant pour n'avoir pas à gérer les numéros négatifs
		push hl
			ld a,(spriteNum)
			ld hl,tableMechantInvincible
			ld bc,NOMBRE_INVINCIBLES
			cpir
			 jr z,armor
;			ld hl,tableMechantArmeur	;voir note dessous
			ld c,NOMBRE_ARMEURS
			cpir						;cpir incrémente hl, tableMechantArmeur suit tableMechantInvincible dans la mémoire
			 jr nz,noArmor
spriteFrame = $+1
			ld a,0
			or a
			 jr z,armor
noArmor:
			call bulletRemovable
			 call z,enleverBalle		;si la balle a touché quelque chose, il faut l'enlever
		pop hl
		dec (hl)
		 jr nz,skipKillEnemy
			ld bc,7
			or a
			sbc hl,bc					;méchant ID
			ld a,(hl)
			cp DIVE
			ld (hl),$FF
			 call nz,resetVel
skipKillEnemy:
	pop hl
	pop bc
nextEnemy:
	ld de,MECHANT_SIZE
	add hl,de
	djnz cMH_boucle
	ret

bulletRemovable:
	ld a,(spriteNum)
	cp ITEM_START
	 jr c,$+4
		inc a			;desarmer drapeau z
		ret
	ld a,(ix+BALLE_TYPE)
	or a
	 ret z
	cp BMEGADIVE
	 ret z
	ret

resetVel:
	ld (hl),EXPLOSION	;EXPLOSION = animation avant de tuer méchant
	ld de,MECHANT_XVEL
	add hl,de
	ld (hl),0
	add hl,de
	dec hl
	ld (hl),0			;animation frame
	dec hl
	ld (hl),0			;animation counter
	ret

armor:
	ld a,(ix+BALLE_TYPE)
	dec a
	cp BMECHANT-1		;seulement la balle normale de megaman peut être bloquée
	 jr c,noArmor
armorStart:
 	pop hl
 	 jr z,skipKillEnemy
 	ld a,(ix+BALLE_VELX)
 	neg
 	ld (ix+BALLE_VELX),a
 	ld (ix+BALLE_VELY),-32*3
 	ld (ix+BALLE_TYPE),BMECHANT
	jr skipKillEnemy

checkBossHit:
;bossX + 7 <= balleX <= bossX + (bossW*8 - 6)
	bit bossBattle,(iy+zFlags)	;faut pas chercher une collision s'il n'y a pas de boss
	 ret z
	ld a,(ix+BALLE_TYPE)
	res 7,a
	cp BCUTMAN+1				;première balle de boss
	 ret nc
	ld hl,(bossX)
	call subBulXHL				;bossX - balleX
	ld a,h
	add a,BOSS_W*8-4			;mouver la zone de collision 4 pixels à gauche
	cp BOSS_W*8-8
	 ret nc
;bossY <= balleY <= bossY+bossH
	ld hl,(bossY)
	call subBulYHL				;bossY - balleY
	ld a,h
	cp -BOSS_H					;vérifier si la balle touche le boss
	 ret c						;on cherche un numéro négatif parce que balleY doit être plus grand que bossY
bossHit:						;... pour lui faire dommage
	ld a,(bossShield)
	or a
	 jr z,skipBossArmor			;si le boss est en train de se protéger, on ne peut pas lui faire mal
	 	ld a,(ix+BALLE_VELX)
	 	neg
	 	ld (ix+BALLE_VELX),a
	 	ld (ix+BALLE_VELY),-32*3
	 	ld (ix+BALLE_TYPE),BMECHANT
	 	ret
skipBossArmor:
	ld a,(ix+BALLE_TYPE)		;les balles du boss ne peuvent lui faire dommage !
	res 7,a
	push af
		cp BCUTMAN					;si c'est le cutter de cutman, il faut le mettre sur sa tête
		 jr nz,$+9
			set weaponHead,(iy+zFlags)
		 	call resetBossAction
	pop af
	cp BOSS_BULLETS
	 jp nc,enleverBalle

	ld a,(playerHP)
	or a
	 ret z

	ld hl,BHPTimer
	ld (hl),BHP_TIMER
	ld hl,bossDamage
	ld a,(hl)
	or a
	 jp nz,enleverBalle			;si le boss est invincible, ne lui faire pas dommage
	ld (hl),BOSS_DMG_FRAMES
;ici il faut calculer le dommage fait au boss
	ld a,(selectedWeapon)
	call doBossDamage
	jp enleverBalle				;si la balle a touché quelque chose, il faut l'enlever

;a = type de balle
doBossDamage:
	ld hl,(selecteur)
	ld h,0
	ld e,l
	ld d,h
	add hl,hl
	add hl,hl
	add hl,hl					;x8
	add hl,de					;x9
	ld de,bossFaiblesses
	add hl,de
	ld e,a						;de = type de balle
	ld d,0
	add hl,de
;ici charger pouvoir du tire
	ld c,2						;pouvoir basique
	ld b,(hl)
	bit 7,b
	 jr nz,noBossDamage			;si b est négatif
	ld a,1						;si b = 0, ne faire qu'un dommage
	dec b
	inc b
	 jr z,subtractHealth		;si b = 0
	dec a
	add a,c
	djnz $-1
;a = combien de dommage à faire
subtractHealth:
	neg
	ld hl,bossHP
	add a,(hl)					;bossHP - dommage
	ld (hl),a					;si son HP est plus de zéro, quitter
	 ret p
	ld (hl),0					;sinon (elle est négative), mettre-la à zéro
	ret
noBossDamage:
	inc b
	 ret z						;b = -1, ne faire dommage pas
	ld hl,bossHP
	ld a,(hl)
	add a,2
	ld (hl),a
	cp MAX_BOSS_HP
	 ret c
	ld (hl),MAX_BOSS_HP
	ret

checkPlayerHit:
	ld a,(ix+BALLE_TYPE)
	cp BMEGACUT+$80		;+$80 parce qu'il faut que le "drapeau" (bit 7) soit armé
	 jr z,$+7
		and $7F				;dernier bit utilisé comme drapeau
		cp BMECHANT
		 ret c				;megaman ne peut pas se tirer une balle à lui même !
	ld hl,(playerX)
	ld b,16-6
	cp BOSS_BULLETS
	 jr c,$+4
		ld b,16			;les balles des bosses ont une largeur de 8 pixels, pas 4
	call subBulXHL		;h = playerX-balleX
	ld a,h
	add a,16-5			;playerWidth - 5
	cp b
	 ret nc
	ld hl,(playerY)
	call subBulYHL		;playerY-balleY
	ld a,(bulletHeight)
	add a,16
	ld b,a
	ld a,h
	add a,16			;add a,playerHeight
	cp b
	 ret nc
	ld a,(ix+BALLE_TYPE)
	sub BWALKERL
	cp 2				;si a = BWALKERL ou BWALKERR
	 jp c,walkerHit		;si le missile du walker a touché Megaman
	jp playerHit		;faire du dommage à Megaman [megaEnnemies.asm]

playerTire:
	ld hl,bulletDelay
	inc (hl)
bulletDelay = $+1
	ld a,-1
	and $07					;si on pousse 2nd sans le relâcher, une balle chaque 8 frames
	 ret nz

	ld a,(weaponDelay)		;un délai pour les armes spéciales
	or a
	 ret nz

	ld hl,EPTimer
	ld (hl),EP_TIMER
	call getWeaponPointer
	 jr z,skipSpecial
	ld a,(hl)
	or a					;hl = énergie restante de la balle
	 ret z
	dec (hl)				;decrémenter énergie par un
skipSpecial:	
;**on va sauter à ajouterBalle**
	ld hl,ajouterBalle
	push hl					;il faut aller à ajouterBalle après avoir exécuté cette routine

;calculer balleY
	ld hl,(playerY)			;e = y offset, d = y
	ld de,$B0				;+6
	add hl,de				;playerY+6
	ex de,hl				;de = balleY
;calculer balleX
	ld l,-BULLET_SPEED		;l = -BULLET_SPEED (velX)
	ld bc,(playerX)
	ld a,(playerDir)
	bit onWall,(iy+zFlags)	;si on glisse sous un mur
	 jr z,$+4				;...
		xor 2				;il faut invertir la direction du joueur
	or a
	 jr z,$+10				;si regarde vers la gauche, sauter
		ld hl,$0180			;+12 ($01 = 8, $80 = 4)
		add hl,bc			;playerX+12
		ld c,l
		ld b,h				;ld bc,hl
		ld l,BULLET_SPEED	;si le joueur regarde vers la gauche, il faut soustraire le BULLET_SPEED en lieu de l'ajouter

	ld h,0					;velY = 0
;h = velY, l = velX, de = balleY, bc = balleX, a = type de balle [megaBullet.asm]
	ld a,(selectedWeapon)
	or a					;buster
	 ret z					;sauter à ajouterBalle envoyant type de balle 0 (parce que a = 0)
	dec a
	 jr z,megaIceTire
	dec a
	 jr z,megaGutsTire
	dec a
	 jr z,megaCutTire
	dec a
	 jr z,megaElecTire
	dec a
	 jr z,megaDiveTire
	dec a
	 jr z,megaFireTire
	dec a
	 jr z,megaMetalTire
;	dec a
;	 jr z,megaWoodTire

; ATTENTION : tous les ret ici vont dans ajouterBall car on a fait ld hl, ajouterBalle\push hl un peu plus haut, joliment obfusqué ah ah !
megaWoodTire:
	ld a,BMEGAWOOD		;type de balle
	ret

megaIceTire:
	ld a,BMEGAICEL
	bit 7,l
	 ret nz
	inc a
	ret

megaGutsTire:
	pop hl				;enlever "ajouterBalle" de la pile
	ld a, 10
	ld (shockk), a
	ret

megaCutTire:
	ld a,BMEGACUT
	call verBalleExiste	;c = il n'y a pas de ce type de balle dans bulletArray
	ld h,-90
	 ret c
	jp noShoot

megaElecTire:
	ld a,8
	ld (weaponDelay),a	;combien de frames qu'il faut attendre pour pouvoir tirer une autre balle
megaElecTireHoriz:
	dec d				;la balle vers le haut un peu (8 pixels)
	ld a,BMEGAELEC
	call ajouterUne		;ajouterUne conserve tous les registres
megaElecTireHaut:
	bit 7,l
	ld hl,32*4
	 jr nz,$+5
		ld hl,-32*7
	add hl,bc
	ld c,l
	ld b,h
	ld l,0				;velX
	ld h,-BULLET_SPEED
	call ajouterUne
megaElecTireBas:
	ld h,BULLET_SPEED	;velY
	ret

megaDiveTire:
;chercher le méchant le plus proche
	ld a,BMEGADIVE
	call ajouterBalle
	dec hl					;changer frame d'animation
	ld a,(playerDir)		;0 = gauche, 2 = droite
	or a					;a = 0: gauche
	 jr z,$+4
		ld a,4				;a = 4: droite
	ld (hl),a
	pop hl
	ret

megaMetalTire:
	ld a,(keyPressSave)
	cp $FF
	 jr z,metalTire			;si pas de touche poussée, utiliser les valeurs par défaut
	ld hl,$0000
	rra
	 jr c,$+4				;bas
		ld h,BULLET_SPEED
	rra
	 jr c,$+4				;gauche
		ld l,-BULLET_SPEED
	rra
	 jr c,$+4				;droite
		ld l,BULLET_SPEED
	rra
	 jr c,$+4				;haut
		ld h,-BULLET_SPEED
metalTire:
	ld a,BMEGAMETAL
	ret				;il nous faut un "ret" ici pour le "push hl" dessus

megaFireTire:
	ld a,BMEGAFIRESHIELD
	call verBalleExiste
	 jr nc,noShoot
	dec a				;BMEGAFIRE
	call ajouterUne
	ld hl,0
	inc a				;BMEGAFIRESHIELD
	ld bc,(playerX)
	dec b
	call ajouterUne
	ld hl,32*12
	add hl,bc
	ld c,l
	ld b,h
	ld hl,32*12
	add hl,de
	ld e,l
	ld d,h
	ld hl,0
	call ajouterUne
	ld hl,32*12
	add hl,bc
	ld c,l
	ld b,h
	ld hl,-32*12
	add hl,de
	ld e,l
	ld d,h
	ld hl,0
	call ajouterUne
	ld hl,-32*12
	add hl,bc
	ld c,l
	ld b,h
	ld hl,-32*12
	add hl,de
	ld e,l
	ld d,h
	ld hl,0
	ret

noShoot:
	call getWeaponPointer
	inc (hl)			;on avait soustrait un de l'énergie de l'arme, mais si on ne tire pas on devrait pas consommer de l'énergie
energyEmpty:			;pas d'énergie, ne rien faire
	pop hl				;on avait poussé ajouterBalle sur la pile
	ret

verBalleExiste:
	exx
		ld c,a
		ld a,(numberBullets)
		or a
		ld b,a
		ld a,c
		 jr z,sauterCutCheck
		ld de,BULLET_SIZE
		ld hl,(bulletArray - BULLET_SIZE) + BALLE_TYPE
		add hl,de
		ld c,(hl)
		res 7,c
		cp c
		 ret z
		djnz $-6
sauterCutCheck:
	exx
	scf
	ret

;a = type balle
;hl = vélocitéX (l), vélocité y (h)
;de = y coord
;bc = x coord
ajouterBalle:
	push hl
	ex af,af'
		ld hl,numberBullets
		ld a,(hl)
		cp 15
		 jr nc,tropDeBalles
		push de
			add a,a				;x2
			add a,a				;x4
			add a,(hl)			;x5
			add a,a				;x10
			inc (hl)			;incrémenter numberBullets
			ld e,a
			ld d,0
			inc hl				;ld hl,bulletArray, bulletArray est le prochain octet dans la mémoire
			add hl,de
		pop de
		ld (hl),c				;X LSB (offset)
		inc hl
		ld (hl),b				;X MSB
		inc hl
		ld (hl),e				;Y LSB (offset)
		inc hl
		ld (hl),d				;Y MSB
	pop de						;du "push hl": velX/Y
	ex af,af'					;type de balle
	inc hl					;balle type
	ld (hl),a
	inc hl					;vélocité X
	ld (hl),e
	inc hl
	ld (hl),d				;vélocité Y
	xor a
	inc hl
	ld (hl),a				;animation counter
	inc hl
	ld (hl),a				;animation frame
	inc hl
	dec a
	ld (hl),a				;extra data ($FF)
	ret
tropDeBalles:
	pop hl
	ret	

;########################################################
;# SUBBULXHL/YHL (subBulXHL/subBulYHL)
;#-------------------------------------------------------
;# Soustraire la balle X/Y de la valeur contenue dans hl
;# Paramètres:
;#	ix = pointeur vers la balle
;# Sortie:
;#	h = différence X (en pixels) entre la balle et HL
;########################################################
subBulYHL:
	ld e,(ix+BALLE_YOFF)
	ld d,(ix+BALLE_Y)
	jr subBulHL
subBulXHL:
	ld e,(ix+BALLE_XOFF)
	ld d,(ix+BALLE_X)
subBulHL:
	or a
	sbc hl,de
	ld a,h
	or a
	 jp p,$+5
		neg
	cp 16			;si le numéro est plus grand, limiter-le
	 jr c,$+4		; à 16. Sinon il est possible qu'il entre
		ld h,16		; dans des numéros négatifs
	add hl,hl
	add hl,hl
	add hl,hl
	ret

;########################################################
;# GETBULLETY (getBulletY)
;#-------------------------------------------------------
;# Retourne la valeur Y absolue dans la carte d'une balle
;# Paramètres:
;#	ix = pointeur vers la balle
;# Sortie:
;#	hl = valeur Y (en pixels) de la balle dans la carte
;########################################################
; Unused !
getBulletY:
	ld l,(ix+BALLE_YOFF)
	ld h,(ix+BALLE_Y)
	ret

;ix = l'addresse de la balle à enlever
enleverBalle:
	ld hl,numberBullets
	ld a,(hl)
	or a
	 ret z
	dec (hl)
	 ret z
	push ix
	
	ld hl,bulletArray
	ld bc,BULLET_SIZE
		add hl,bc
		dec a
	 jr nz,$-2
		
	pop de

	sbc hl,de			;combien d'octets il faut copier
	ld c,l
	ld b,h
	push bc
		ld l,e
		ld h,d
		ld bc,-BULLET_SIZE
		sbc hl,bc
		add ix,bc
	pop bc
	ldir
	ret

;h = dY (obj1Y en pixels - obj2Y en pixels)
;d = dX (obj1X en pixels - obj2X en pixels)
;sortie:
;a = velY
;l = velX
;vX = (pX-bX)*BULLET_SPEED/(pY-bY)
aimBullet:
	ld a,d
	add a,8
	cp 16
	 jr nc,realAim
	 	sub 8
		ld d,32
		 jp p,$+5
			ld d,-32
realAim:
	push de					;dX
		ld a,d
		or a
		jp p,$+5
		 neg
		ex af,af'
			ld e,BULLET_SPEED
			call multEHSigned
		ex af,af'
		ld d,a
		call divHLD		;hl = dY*BULLET_SPEED, d = dX
		ld h,a					;h = velY, l = velX
	pop de
	ld l,BULLET_SPEED
	bit 7,d
	 ret z
	ld l,-BULLET_SPEED
	ret

getWeaponPointer:
	ld a,(selectedWeapon)
	or a
	 ret z
	push de
		ld hl,weaponEnergy-1	;n'oublie pas que l'on commence par 0 (le buster) qui n'est pas une arme spéciale
		ld e,a
		ld d,0
		add hl,de
		ld a,(hl)
	pop de
	ret

rechargerArmes:
;recharger armes
	ld hl,weaponEnergy
	ld b,8
		ld (hl),15
		inc hl
	 djnz $-3
	ret
