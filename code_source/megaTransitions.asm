;#-------------------------------------------------------
;# transitionBossMort:
;#  Afficher un texte après la mort d'un boss
;#  Print a text after boss's death

deathScreen:
	ld sp,(mainSP)
	ld hl,playerHP
	ld (hl),MAX_HP-1
	call rechargerArmes
	bit bossBattle,(iy+zFlags)
	push af
		call transitionSetup
		ld hl, presser_enter_pour_continuer
		call transitionMain
;recharger le niveau
		ld a,(selecteur)
		ld b,a
		inc b
		call loadLevelFromArchive
	pop af
	 jp z,main
cpMapX = $+1
	ld a,0
	ld (xCoord),a
cpMapY = $+1
	ld a,0
	ld (yCoord),a
cpPlayX = $+2
	ld bc,$0000
	ld (playerX),bc
cpPlayY = $+1
	ld b,0
	ld (playerY),bc
	
	ld a,(selecteur)
	cp 8
	ld hl,closeRoomNoRun	;le script que nous voulons faire exécuter
	call c,startScript
	jp main

;hl = text à afficher
transitionMain:
	ld bc,selectedWeapon
	ld a,(bc)				;sauver l'arme choisie
	push af
	push hl
		xor a
		ld (bc),a
		call transition_go
	pop hl
	pop af
	ld (bc),a
	ld a,$FF
	ld (bulletDelay),a
	ret

transition_go:
	set textWrite,(iy+sGrFlags)
	ld bc,2
	ld (penCol),bc
 	bcall(_VPutS)
	ld hl,gbuf
 	ld de,megaGbuf+(40*13)
	ld c,6
copyLoop:
 	ld b,12
copyInnerLoop:
 	ld a,(de)
 	xor (hl)
 	ld (de),a
 	inc hl
 	inc de
 	djnz copyInnerLoop
 	inc de				;megaGbuf = 13 octets, gbuf = 12 octets de largeur
 	dec c
 	 jr nz,copyLoop

;les coordonnées du joueur
	ld (playerY),bc
	ld b,5
	ld (playerX),bc
	ld hl,playerMovement
	inc (hl)
transition_loop:
;effacer partie en haut
	ld hl, megaGbuf
	ld (hl), 0
	ld de,megaGbuf+1
	ld bc,(16*13)-1
	ldir

	ld a,(playerLives)
	or a
	 jp z,sauterBalles

	ld hl,playerMovement
	inc (hl)

	ld b,65
	call random
	ld hl,counter
	or a
	 jr nz,$+8
	 	dec a
	 	ld (bulletDelay),a
		ld (hl),0
	inc (hl)
	ld a,(hl)
	cp 20
	 jr nc,$+9
		xor a
		ld (playerMovement),a
		call playerTire
sauterBalles:
	call desPersonnage
	call desBalles
	call drawGbuf
	call drawGbuf			;un délai
; Scanner pour savoir si on quitte
	xor a
	out (1), a
	in a,(1)
	inc a					; enter
	 jr z, transition_loop	; Sortir de la transition
	res	 textInverse, (iy + textFlags)
	jp waitKey_release

transitionSetup:
	xor a
	ld (yCoord),a
	ld (xCoord),a
	ld (yOff),a
	ld (xOff),a
	ld (velocityY),a
	ld (damageFrames),a
	ld (numberBullets),a
	ld (slideFrames),a
	res onWall,(iy+zFlags)
	call updateRotation

	ld hl,megaGbuf + 64*13
	ld (hl),11111111b
	ld de,megaGbuf+(64*13)-1
	ld b,48
pt_loop:
	push bc
	ld bc, 13
	lddr
	exx
		call drawGbuf
	exx
	pop bc
	djnz pt_loop

	ld a,$FF
	ld hl, megaGbuf+17*13
	ld (hl),b					;b sera toujours 0 après les ldir
	ld de, megaGbuf+(17*13)+1
	ld bc, 12
	ldir
	ld (hl),a
	ld bc, 26
	ldir
	ld (hl), b
	ld bc, 13
	ldir
	ld (hl),a
	bcall(_GrBufClr)
	ret

;;;;;;;;
; Afficher un petit message après la mort d'un boss
;;;;;;;;
;sprite déplacé dans [tilemap/megaSprites.inc]
transitionBossMort:
	call centrerEcranSurBoss
	ld a,15
	ld (flashSMC),a
	xor a
	ld b,150
flashLoop:
	inc a
flashSMC = $+1
	cp 15
	 jr nz,noFlash
		ld hl,flashSMC
		ld a,(hl)
		cp 2
		 jr z,$+3
			dec (hl)
		xor a
noFlash:
	push bc
	push af
	call nz,desBoss
	call desPersonnage
	call drawGbuf
	call desCarte
	pop af
	pop bc
	djnz flashLoop
exitFlash:
	call drawGbuf
	ld b,50
	ei
	halt
	djnz $-1
	di

	ld bc,(bossX)
	inc b
	ld de,(bossY)
	inc d
	call explodeBoss

	call transitionSetup

	ld a,24
	ld hl,megaman_sans_casque
	ld de,megaGbuf+30*13+9
sansCasqueBoucle:
	ldi
	ldi
	ldi
	ex de,hl
	ld bc,10
	add hl,bc
	ex de,hl
	dec a
	 jr nz,sansCasqueBoucle
	ld hl,le_boss_est_mort		;le texte à afficher
	jp transitionMain

;bc = x
;de = y
explodeBoss:
	ld a,BFIREMANFLAME
	ld hl,32*256+32
	call ajouterUne			;hl = velX(l)/velY(h), de = balleY, bc = balleX, a = type de balle [megaBullet.asm]
	ld l,0
	call ajouterUne			;hl = velX(l)/velY(h), de = balleY, bc = balleX, a = type de balle [megaBullet.asm]
	ld l,-32
	call ajouterUne			;hl = velX(l)/velY(h), de = balleY, bc = balleX, a = type de balle [megaBullet.asm]
	ld h,0
	call ajouterUne			;hl = velX(l)/velY(h), de = balleY, bc = balleX, a = type de balle [megaBullet.asm]
	ld l,0
	call ajouterUne			;hl = velX(l)/velY(h), de = balleY, bc = balleX, a = type de balle [megaBullet.asm]
	ld l,32
	call ajouterUne			;hl = velX(l)/velY(h), de = balleY, bc = balleX, a = type de balle [megaBullet.asm]
	ld h,-32
	call ajouterUne			;hl = velX(l)/velY(h), de = balleY, bc = balleX, a = type de balle [megaBullet.asm]
	ld l,0
	call ajouterUne			;hl = velX(l)/velY(h), de = balleY, bc = balleX, a = type de balle [megaBullet.asm]
	ld l,-32
	call ajouterUne			;hl = velX(l)/velY(h), de = balleY, bc = balleX, a = type de balle [megaBullet.asm]

	ld b,20
	ld hl,shockk
	ld (hl),b
explodeLoop:
	push bc
		call tremblerEcran
		call desCarte
		call desBalles
		call drawGbuf
	pop bc
	djnz explodeLoop
	ret

centrerEcranSurJoueur:
	ld bc,(playerX)
	jr $+5
centrerEcranSurBoss:
	ld bc,(bossX)
	ld hl,(xCoord-1)
	sbc hl,bc
	xor a
	ld (bossDamage),a
	ld (bossVelX),a
	ld (numberBullets),a
	ld a,h
	add a,5
	 ret z
	add a,a
	add a,a
	add a,a
	ld c,-1
	 jr nc,$+4
		ld c,1
	 jr nc,$+4
		neg
	ld b,a
focusLoop:
	push bc
		ld b,c
		inc c
		push af
			call z,mapLeft
		pop af
		call nz,mapRight
		call desCarte
		call desPersonnage
		ld a,(selecteur)
		cp 8
		push af
			call nz,desBoss
		pop af
		 call z,desWily
		call drawGbuf
	pop bc
	djnz focusLoop
	ret
