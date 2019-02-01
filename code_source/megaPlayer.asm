;########################################################
;# [megaPlayer.asm]
;#-------------------------------------------------------
;# ROUTINES CONTENUES:
;#-------------------------------------------------------
;# desPersonnage:
;#Â  routine qui affiche le personnage en fonction de ce
;#  que fait le personnage
;#Â  prints the player depending what he does
;#-------------------------------------------------------
;# desBarreHP:
;#  dessine la barre de vie du joueur 
;#Â  draws the life bar of the player
;#-------------------------------------------------------
;# desBarre:
;#  dessine une barre de vie/energie mais je sais plus vraiment
;#Â  draws the life bar or energy bar but I can't remember exactly
;#-------------------------------------------------------

; Don't copyright my code (or better yet, don't copyright yours!)


;;;;;;;;
; Dessiner personnage dans le gbuf
;;;;;;;;
;playerDir:
;0: gauche
;2: droite
;;
desPersonnage:
	ld ix,megaman_mort
	ld a,(playerLives)
	or a
	 jr z,startDrawing
	ld hl,damageFrames
	ld a,(hl)
	or a
	jr z,$+3
		dec (hl)
	bit 2,a
		ret nz
	ld hl,playerAnimation
	ld de,32		;taille des sprites
	ld ix,playerSprite
playerMovement = $+1
	ld a,0			;si on a appuyÃ© sur gauche/droite, playerMovement sera Ã  1
	or a			  ;vÃ©rifier si les touches gauche/droite ont Ã©tÃ© poussÃ©es
	jr nz,$+3		;si on n'a pas poussÃ© gauche/droite, il faut...
		ld (hl),a	; ...remettre Ã  zÃ©ro playerAnimation
	jr z,$+4		;si on a poussÃ© gauche/droite, il faut...
		add ix,de	; ...sauter le premier sprite (du joueur debout, qui ne fait que regarder)
	inc (hl)		;augmenter le compteur
	ld a,(hl)
;a=%00000000		;afficher court1
;a=%00001000		;afficher court2
;a=%00010000		;afficher court1
;a=%00011000		;afficher court3
	bit 3,a			;si a=%00010000	ou %00000000 nous afficherons court1	
	jr z,$+10
		add ix,de
		bit 4,a			;si a=%00001000, nous afficherons court2. si a=%00011000, nous afficherons court3 
		jr z,$+4
			add ix,de
	ld a,(velocityY)
	or a
	jr z,$+16
		bit jumpStart,(iy+zFlags)
		ld ix,megaman_saut_gauche	;vÃ©locitÃ© negative = saut
		jr nz,$+6
		ld ix,megaman_tombe_gauche	;vÃ©locitÃ© positive = tombe
	ld a,(bulletDelay)
	inc a
	jr z,dP_slide
		ld a,(playerMovement)
		or a
		 jr nz,$+6
			ld ix,megaman_tire_gauche
dP_slide:
	bit onWall,(iy+zFlags)
	jr z,$+6
		ld ix,megaman_mur_gauche
	ld a,(slideFrames)
	or a
	jr z,$+6
		ld ix,megaman_slide_gauche
playerDir = $+1
	ld a,0			; Ici on fait ld a, (playerDir) mais on gagne 1 octet grace a smc
	ld de,end_sprites_left-sprites_left		; il y a huit sprites de gauche et huit de droites
	or a
	; Changer le sprite ici !
	jr z,$+4		;2 octets playerDir = 0 = gauche
		add ix,de	;2 octets
	ld b,0
startDrawing:
	ld a,(yCoord)
	ld d,a			;d = y coord, e = 0
	ld e,b
playerY = $+1
	ld hl,0000		;h = Y selon les tuiles du map (1 = 8 pixels, 2 = 16, 3 = 24, etc.)
					;l = Y offset (3 bits: %XXX-----) et la fraction de l'offset (5 bits: %---XXXXX)
;assure-toi que le carry n'est pas armÃ© !
	sbc hl,de		;il faut soustraire la position actuelle de la carte pour savoir oÃ¹ afficher le sprite du joueur
	 ret c
	push hl
	ld de,$0700
	sbc hl,de		;si Megaman est hors d'Ã©cran
	pop hl
	 ret nc
	add hl,hl		;x8 pour trouver sa valeur en pixels
	add hl,hl		; add hl,hl est essentiellement sll hl, comme les 3 bits dans l se dÃ©placent vers h on peut dÃ©carter l
	add hl,hl		; h = la valeur Y en pixels dans l'Ã©cran
	ld l,h			;hl = position y dans l'Ã©cran
	ld h,b
	ld e,l
	ld d,h			;ld de,hl
	add hl,hl
	add hl,de
	add hl,hl
	add hl,hl
	add hl,de			;x13 (13 colonnes)
	ld de,megaGbuf+2	;86EC+2, nous dessinons de droite Ã  gauche. l'octet de droite se dessine premiÃ¨rement, puis ce de gauche.
						; donc il faut commencer Ã  megaGbuf+2
	add hl,de

	ld a,(xCoord)
	neg					;cpl \ inc a
playerX = $+1
	ld de,0000
	add a,d				;playerX-mapX
	ret m
	cp 11
	 ret nc				;est-on hors d'Ã©cran ?
	ld c,a				;charger le rÃ©sultat dans bc
	add hl,bc			;ajouter les coordonnÃ©es X
	ld a,e				;l'offset X occupe les trois derniers bits: %XXX-----
	rlca				;%XX-----X
	rlca				;%X-----XX
	rlca				;%-----XXX
	and $7				;Ã©ffacer les autres bits: %00000XXX
	ld b,a
	ld c,16
drawPlayerLoop:
	push bc
	ld d,(ix)      ;sprite
	ld e,(ix+1)
	xor a
	cp b
	jp z,skipSpriteClip
	srl d \ rr e \ rra \ djnz $-5   ;rotate sprite
skipSpriteClip:
	or (hl)
	ld (hl),a
	dec hl
	ld a,(hl)
	or e
	ld (hl),a
	dec hl
	ld a,(hl)
	or d
	ld (hl),a
	inc ix
	inc ix
	ld de,15
	add hl,de
	pop bc
	dec c
	jp nz, drawPlayerLoop
	ret

desBarreHP:
;maintenant afficher barre d'Ã©nergie
	ld hl,EPTimer
	ld a,(hl)
	or a
	 jr z,barreHP
	dec (hl)
	ld bc,megaGbuf+(13*6)+1
	call getWeaponPointer	;a = Ã©nergie d'arme actuelle, hl = pointer aux datas
	 jr z,barreHP			;z armÃ© si on utilise le megabuster
	ld d,16
	call desBarre
barreHP:
	ld hl,HPTimer
	ld a,(hl)
	or a
	 ret z
	dec (hl)
	ld bc,megaGbuf+(13*6)
	ld a,(playerHP)
	ld d,MAX_HP
;a = HP/Ã©nergie
;bc = location dans gbuf
;d = max HP/Ã©nergie
desBarre:
	push de
	ex af,af'
	push bc
		ld de,12		;nous incrÃ©mentons hl, donc c'est 12 pas 13 (la largeur du gbuf)
		ld a,(yOff)
		ld c,a
		add a,a			;x2
		add a,c			;x3
		add a,a			;x6
		add a,a			;x12
		add a,c			;x13
		ld l,a
		ld h,d			;hl=offsetY*13
	pop bc
	ex af,af'
	add hl,bc		;ajouter offset Y
	pop bc			;b = max HP/Ã©nergie
;hl pointe sur l'endroit dans le gbuf ou nous voulons afficher la barre de HP
	or a
;	ret z			;quitter si le joueur est mort !
fillBar:
	push bc
		ld b,%10000001		;un rang vide
		call loadSlot		;every other row is empty
	pop bc
	push bc
		cp b					;playerHP - b si joueur a 10 hp et il reste 13 rangs Ã  afficher
		ld b,%10100101			; 10 -13 = c armÃ©: alors ne pas encore afficher barre de HP
		jr c,$+4
		 ld b,%11011011			;on a du HP a montrer !
		call loadSlot
	pop bc
	djnz fillBar
	ld b,%10000001
	call loadSlot
	ld b,%11111111
	call loadSlot
	ret

;b = bit Ã  dÃ©caler
loadSlot:
	ex af,af'
		ld a,(xOff)
		ld c,d			;mettre c Ã  zÃ©ro
		or a			;remettre le drapeau carry aussi
		ld d,$FF
		 jr z,lS_noRotate
		 	rr d
		 	or a
		 	rr b
			rr c
			dec a
		 	jr nz,$-8
lS_noRotate:
		ld a,d
		cpl
		and (hl)		;left mask
		or b			;rotated left byte
		ld (hl),a		;sauver l'octet
		inc hl
		ld a,(hl)
		and d			;apply mask
		or c			;load rotated right byte
		ld (hl),a
		ld d,0
		add hl,de
	ex af,af'
	ret

desSlideParticles:
	ld a,(numSlideParticles)
	or a					;quitter s'il n'y a pas de particles Ã  afficher
	 ret z
	ld b,a					;nombre de particles dans b
	ld ix,slideParticles	;dÃ©but de la table
slideParticlesLoop:
	dec (ix+6)				;decrÃ©menter compteur
	 jr nz,skippySkip		;si le compteur = 0, il faut enlever le particle
	 	exx
			ld hl,slideParticles+7
			ld de,slideParticles
			ld bc,35-7
			ldir			;enlever le particle	
			ld hl,numSlideParticles
			dec (hl)
		exx
		dec b				;on va processer un particle moins
		 ret z				;quitter s'il n'y avait qu'un particle
skippySkip:
	ld l,(ix+2)				;X LSB
	ld h,(ix+3)				;X MSB
	ld e,(ix)				;vel X
	call signExtendE
	add hl,de
	ld (ix+2),l				;X LSB
	ld (ix+3),h				;X MSB
	call subMapXHL
	 jr c,skipSlideParticle
	ld c,a
	ld a,h
	ex af,af'
		ld l,(ix+4)				;Y LSB
		ld h,(ix+5)				;Y MSB
		ld e,(ix+1)				;vel Y
		ld d,0
		sbc hl,de
		ld (ix+4),l				;Y LSB
		ld (ix+5),h				;Y MSB
		call subMapYHL
		 jr c,skipSlideParticle
		ld l,h
		ld h,0
		ld e,l
		ld d,h
		add hl,hl
		add hl,de
		add hl,hl
		add hl,hl
		add hl,de				;x13 (valeur Y)
		ld e,c					;ajouter X
		add hl,de
		ld de,megaGbuf
		add hl,de
	ex af,af'
	and $7
	ld e,a
	ld a,%10000000
	 jr z,$+6
		rra
		dec e
		jr nz,$-2
	or (hl)
	ld (hl),a
skipSlideParticle:
	ld de,7
	add ix,de
	djnz slideParticlesLoop
	ret

