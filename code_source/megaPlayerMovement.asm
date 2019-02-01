;########################################################
;# [megaPlayerMovement.asm]
;#-------------------------------------------------------
;# ROUTINES CONTENUES:
;#-------------------------------------------------------
;# playerRight:
;#	Ajuster la vélocité X quand on appuie sur la touche
;#	[->]. Seulement appelée quand on appuie sur la flèche
;#	droite.
;#-------------------------------------------------------
;# playerGoRight:
;#	Cette routine est appelée quand la vélocité X est >0.
;#	Il est possible de pousser la flèche gauche et que
;#	cette routine s'éxécute si la vélocité X est encore
;#	positive après l'ajout de l'acceleration.
;#-------------------------------------------------------
;# checkWallSlide:
;#	Cette routine est partie de playerGoRight mais est
;#	utilisée par playerGoLeft aussi. Ici on ne fait pas
;#	seulement un test pour voir s'il faut glisser ou non
;#	sous le mur, on remet la vélocité X et l'offset X du
;#	joueur à zéro parce qu'on à couru contre un mur.
;#-------------------------------------------------------
;# playerLeft:
;#	Même chose que playerRight, seulement pour la flèche
;#	gauche.
;#-------------------------------------------------------
;# playerGoLeft:
;#	Même que playerGoRight, mais pour les vélocitées
;#	négatives. Ce n'est pas certain que cette routine
;#	s'exécutera quand on appuie sur la flèche gauche si
;#	la vélocité n'est pas négative.
;#-------------------------------------------------------
;# playerUp:
;#	Comme playerRight/Left, changer la vélocité Y pour
;#	sauter. Il faut faire deux choses avant de pouvoir
;#	éxécuter cette routine (sauter) de nouveau:
;#	1.	atérrir
;#	2.	relâcher la flèche haut [/|\]
;#-------------------------------------------------------
;# playerGravity:
;#-------------------------------------------------------
;# playerSlide:
;#-------------------------------------------------------
;# playerMomentum:
;#-------------------------------------------------------
;# mapHurts:
;#-------------------------------------------------------
;# getYOffset:
;#-------------------------------------------------------
;# addXOffset:
;# addXOffset_skip:
;#	Utilisé dans la routine des méchants (pour le moment)
;#	pour détecter des collisions.
;#-------------------------------------------------------
;# hitDetectX;
;#-------------------------------------------------------
;# hitDetectY:
;########################################################

; Pinky: "Gee, Brain, what do you want to do tonight?"
; The Brain: "The same thing we do every night, Pinky—try to take over the world!"

;########################################################
;# PLAYERRIGHT (playerRight:)
;# Ajuster la vélocité X du joueur pour le déplacer vers
;# la droite. Ici on ne fait qu'ajuster la vélocité.
;########################################################
playerRight:
	ld hl,playerMovement
	inc (hl)
;vélocité = 32 = avancer un pixel
	set runSuccess,(iy+zFlags)
	ld a,2
	ld (playerDir),a		;playerDir=2 (regarder à droite)
	ld hl,velocityX
	ld a,ACCELERATION
	add a,(hl)
	jp m,updateRightQuit	;si la vélocité est toujours négative, mettre-la à jour et quitter.
	cp MAX_SPEED			; si non, le numéro négatif (bit 7 armé) sera plus grand que MAX_SPEED
	jr c,$+4				; et on changera la vélocité à MAX_SPEED.
		ld a,MAX_SPEED		;si on va dépasser la vélocité max, limiter-la à la max vélocité permise
updateRightQuit:
	ld (hl),a
	ret


;########################################################
;# PLAYERGORIGHT (playerGoRight:)
;#	Si nous avons une vélocité X positive, cette routine
;# est appelée. Mouver le joueur vers la droite.
;#	checkWallSlide est partagé avec playerGoLeft (elles
;# utilisent la même routine pour les wallslides)
;# Entrée:
;#	de = vélocité X que l'on va ajouter à playerX
;########################################################
playerGoRight:
	ld hl,(playerX)
	add hl,de
	push hl
		inc h
		inc h			;Megaman est 16x16, nous voulons chercher à sa droite (donc sauter 2 octets)
		call hitDetectX
	pop hl
	jr z,tilePassRight
		ld a,h
		ld (playerX+1),a	;playerX est la partie alignée avec la carte
;va-t-on glisser sous le mur ?
checkWallSlide:
		xor a
		ld (playerX),a
		ld (velocityX),a
		bit jumpStart,(iy+zFlags)
		 ret nz
		bit onGround,(iy+zFlags)	;on ne peut pas glisser si on est on train de sauter ou sur le sol
		 ret nz
		ld a,(pushPlayer)
		or a
		 ret nz						;quitter si le boss a poussé Megaman
;vérifier les particles
		ld b,a
		ld hl,numSlideParticles
		ld a,(hl)
		cp 5
		 jr nc,particlesFull		;sauter s'il y a déjà 5 ou plus
;ajouter un particle
			inc (hl)
			ld c,a
			add a,a					;x2
			add a,c					;x3
			add a,a					;x6
			add a,c					;x7, taille de chaque entrée
			ld c,a
			ld hl,slideParticles
			add hl,bc
			ld b,4
			call random
			rlca
			rlca
			rlca
			ld (hl),a				;vélocité X
			ld a,(playerDir)
			or a
			 jr z,$+6
				ld a,(hl)
				neg
				ld (hl),a			
			inc hl
			ld b,3
			call random
			inc a
			rlca
			rlca
			rlca
			ld (hl),a
			inc hl
			ld a,(playerDir)
			or a
			 jr nz,particleRight
				ex de,hl
				ld hl,playerX
				ldi						;playerX->particleX
				ldi
				jr endParticleAdd
particleRight:
			ld de,(playerX)
			inc d
			inc d
			ld (hl),e
			inc hl
			ld (hl),d
			inc hl
			ex de,hl
endParticleAdd:
			ld hl,playerY
			ldi
			ldi
			ex de,hl
			ld (hl),5
particlesFull:
		ld a,$18
		ld (velocityY),a		;velocity Y = 15, velocityX = 0
		set onWall,(iy+zFlags)	;armé le drapeau (utilisé seulement pour afficher le sprite du glissage)
		ret


tilePassRight:
	ld (playerX),hl		;sauver les nouvelles coordonnées
;faut-il décaler la carte vers la droite ?
	ld a,h				;a = playerX
	ld b,l				;b = playerX offset
	ld hl,xCoord		;playerX - mapX
	sub (hl)
	sub 6				;s'il y a plus de 6 tuiles de différence entre la position du joueur et la caméra, il faut décaler la carte
	 ret c
	rra					;si a = 1 (c'est à dire: playerX-mapX = 7) armer le drapeau carry
	ld a,b				;b = player X offset
	rla					;décaler le carry: %XX-----? +X dans le carry
	rla					;%X-----?X +X dans le carry
	rla					;%-----?XX +X dans le carry
	rla					;%----?XXX
	and $F				;%0000?XXX nous avons l'x offset, plus 8 si playerX-mapX = 7, plus 0 sinon
	ld hl,xOff
	sub (hl)			;l'x offset du joueur - mapX offset = combien de pixels il faut décaler
	 ret c				;si mapX off > playerX off, faut pas encore décaler
	ld b,a				;b = combien de pixels à décaler la carte
	jp mapRight

playerLeft:
	ld hl,playerMovement
	inc (hl)
;vélocité = -32 = avancer un pixel
	set runSuccess,(iy+zFlags)	;une touche de flèche a été poussé
	xor a
	ld (playerDir),a		;playerdir=0 (regarder à droite)
	ld hl,velocityX
	ld a,-ACCELERATION		;les valeurs négatives signifient que l'on va vers la gauche
	add a,(hl)				;velocityX - acceleration
	jp p,updateLeftQuit
	cp -MAX_SPEED
	jr nc,$+4
		ld a,-MAX_SPEED		;si on va dépasser la vélocité max, limiter-la
updateLeftQuit:
	ld (hl),a
	ret

;entrée:
;	de = vélocité
playerGoLeft:
	ld hl,(playerX)
	add hl,de
	push hl
		call hitDetectX
	pop hl
	jp nz,checkWallSlide
tilePassLeft:
	ld (playerX),hl
;décaler la carte vers la gauche
	ld a,h				;a = playerX
	ld b,l				;b = playerX offset
	ld hl,xCoord		;playerX - mapX
	sub (hl)
	sub 5				;s'il y a moins de 5 tuiles de différence entre la position du joueur et la caméra, il faut décaler la carte
	ret nc
	inc a				;s'il y a quatre tuiles, a = 0. s'il y a 3, a = -1
	add a,a
	add a,a
	add a,a				;a = 0 (0*8) ou -8 (-1*8)
	ld c,a
	ld a,b				;b = player X offset
	rlca				;
	rlca				;
	rlca				;
	and $7				;
	add a,c				;s'il 4 tuiles entre nous et le bord de l'écran, c = 0.
						; s'il y'en a 3, c = -8
	ld hl,xOff
	sub (hl)			;l'x offset du joueur - mapX offset = combien de pixels il faut décaler
	ret p				;si le résultat est positif, faut pas décaler parce qu'on n'est pas encore suffisamment proche du bord
	ld b,a				;b = combien de pixels à décaler la carte
	jp mapLeft

;;
; Deplacer le joueur vers le haut
;;
playerUp:
	ld a,(keyPressSave)
	rra
	 jp nc,playerSlide ;glisser si on appuie sur la fleche bas
	bit upPressed,(iy+zFlags)
	 ret nz						;si up n'a pas encore été relâché, quitter
	ld hl,velocityY
	bit onWall,(iy+zFlags)
	 jr nz,wallJump
	bit onGround,(iy+zFlags)	;quitter si on n'est pas sur terre (si onGround est désarmé)
	 ret z
	set upPressed,(iy+zFlags)	
	set jumpStart,(iy+zFlags)	;on saute
	res onGround,(iy+zFlags)
	ld (hl),JUMP_VEL
	ret
wallJump:
	set upPressed,(iy+zFlags)	
	res onWall,(iy+zFlags)
	set jumpStart,(iy+zFlags)
	ld (hl),JUMP_VEL
	ld a,(playerDir)
	or a
	ld a,68
	jr z,$+4
	ld a,-68
	ld (velocityX),a
	ret	

;;
; Deplacer le joueur vers le bas	
;;
playerGravity:
;ajouter vélocité à playerY
	ld hl,velocityY
	ld a,(hl)
	add a,GRAVITY
	ld d,$FF					;on va mettre la vélocité y dans e, mettre d = $FF (negative sign-extended)
								; si le numéro est positif, inc d et d = 0
	bit jumpStart,(iy+zFlags)	;est-on en train de sauter ?
	 jr z,noJump				;si non, vérifier que ne dépasse pas la vitesse maxe
	 	bit upPressed,(iy+zFlags)
		 jr nz,$+7
		 	res jumpStart,(iy+zFlags)	;si on relâche [UP] on ne saute plus
	 		xor a
		cp GRAVITY				;si la vélocité est toujours négative
		jr nc,endJumpTest		; on est toujours en train de sauter
		res jumpStart,(iy+zFlags)	;si la vélocité maintenant est positive, le saut a terminé
noJump:
	inc d						;de = numéro positif (d=00)
	cp 220
	 jr c,$+4
		ld a,220
endJumpTest:
	ld (hl),a
	ld hl,(playerY)
	ld e,a
	add hl,de				;ajouter playerY += velocityY
	push hl
		inc h				;voir si Megaman est debout sur un pic ou quelque chose
		call hitDetectY		; qui lui va faire du mal
	pop hl
	push hl
		bit jumpStart,(iy+zFlags)
		jr nz,$+4			;si on est en train de sauter, chercher au-dessus de Megaman
			inc h			;... sinon, chercher sous ses pieds
			inc h			;Megaman a 16 pixels d'hauteur
		call hitDetectY
	pop hl
	jr z,tilePassGravity
		xor a
		ld l,a
		ld (playerY),hl		;playerY == .db xOff,playerX ("little-endian")
		ld (velocityY),a
		bit jumpStart,(iy+zFlags)
		jr z,$+11
			ld hl,playerY+1
			inc (hl)
			res jumpStart,(iy+zFlags)	;on ne saute plus
			ret
		set onGround,(iy+zFlags)
		ret
tilePassGravity:
	res onGround,(iy+zFlags)

	ld (playerY),hl
	ld a,h				;a = playerY
	ld b,l				;b = playerY offset
	ld hl,yCoord		;playerX - mapX
	bit jumpStart,(iy+zFlags)
	 jr nz,tilePassUp
;vérifier en bas
	sub (hl)
	sub 4				;s'il y a plus de 3 tuiles de différence entre la position du joueur et la caméra, il faut décaler la carte
	ret c
	rra					;si a = 1 (c'est à dire: playerX-mapX = 7) armer le drapeau carry
	ld a,b				;b = player X offset
	rla					;décaler le carry: %XX-----? +X dans le carry
	rla					;%X-----?X +X dans le carry
	rla					;%-----?XX +X dans le carry
	rla					;%----?XXX
	and $F				;%0000?XXX nous avons l'x offset, plus 8 si playerX-mapX = 7, plus 0 sinon
	ld hl,yOff
	sub (hl)			;l'x offset du joueur - mapX offset = combien de pixels il faut décaler
	ret c				;si mapX off > playerX off, faut pas encore décaler
	ld b,a				;b = combien de pixels à décaler la carte
	jp mapDown
tilePassUp:
;vérifier en haut
	sub (hl)
	sub 3				;s'il y a plus de 3 tuiles de différence entre la position du joueur et la caméra, il faut décaler la carte
	ret nc
	inc a				;s'il y a quatre tuiles, a = 0. s'il y a 3, a = -1
	add a,a
	add a,a
	add a,a				;a = 0 (0*8) ou -8 (-1*8)
	ld c,a
	ld a,b				;b = player X offset
	rlca				;
	rlca				;
	rlca				;
	and $7				;
	add a,c				;s'il 4 tuiles entre nous et le bord de l'écran, c = 0.
						; s'il y'en a 3, c = -8
	ld hl,yOff
	sub (hl)			;l'x offset du joueur - mapX offset = combien de pixels il faut décaler
	ret p				;si le résultat est positif, faut pas décaler parce qu'on n'est pas encore suffisamment proche du bord
	ld b,a				;b = combien de pixels à décaler la carte
	jp mapUp

playerSlide:
	ld hl,slideFrames
	ld a,(hl)
	or a
	ret nz
;initialiser slide
		bit jumpStart,(iy+zFlags)
		 ret nz
		ld a,(velocityY)
		or a
		 ret nz					;si on saute ou on tombe, pas permis de glisser
		ld (hl),16				;COMPTEUR DE SLIDEFRAMES
		ret
																			
playerMomentum:
	ld d,0						;on garde vélocité dans 'de' pour l'ajouter à playerX dans les routines de mouvement
	ld a,(slideFrames)
	or a
	jr z,noSlide
		ld a,(playerDir)
		or a					;où regarde-t-on ?
		jr nz,$+8				;si bit 7 est désarmé, on va vers la droite
			dec d				;sign extend d
			ld e,-SLIDE_SKIP	;slide_skip négatif = vers la gauche. de = -SLIDE_SKIP
			jp playerGoLeft		;aller à gauche
		ld e,SLIDE_SKIP			;de = vélocité à ajouter
		jp playerGoRight		;à droite
noSlide:
	ld hl,velocityX
	ld a,(pushPlayer)
	or a
	 jr z,noPush
	 	dec a
	 	ld (pushPlayer),a
		ld a,(hl)
		bit 7,a
		ld a,64
		 jr z,$+4
			ld a,-64
		ld (hl),a
		jr keyPressed+1
noPush:
	ld a,(playerMovement)
	or a
	 jr nz,keyPressed
		ld a,(selecteur)
		or a
		 jr z,keyPressed
		xor a
		ld (hl),a
keyPressed:
	ld a,(hl)
	ld e,a					;de = vélocité X (utilisée dans playerGoLeft/Right)
	or a
	 ret z					;pas de vélocité, pas de mouvement
	jp p,pM_right			;vélocité positive signifie que l'on va vers la droite
;vers la gauche
	dec d					;sign-extend d (d=$FF)
	add a,ACCELERATION/3*2
	jr nc,$+3
		xor a
	ld (hl),a
	jp playerGoLeft
pM_right:					;vers la droite
	sub ACCELERATION/3*2
	jr nc,$+3
		xor a
	ld (hl),a
	jp playerGoRight

; A propos de la détection de collision 
; Dans hitDetectX et hitDetectY on teste si on peu bouger
; Si on bloque on fait un ret et on ne bouge pas les coordonnées
; Avant de faire un ret on teste si le tile est blessant ou pas (mapHurts)
; Si ça blesse, on perd de la vie


; Lorsqu'on entre dans cette fonction, on ne sait pas encore si on se blesse ou pas !!
; Verifier que ce qui nous bloque n'est pas un tile qui blesse
; Les tiles qui blessent sont ceux avec les valeurs grandes (pour l'instant supérieurs à $10
; entrée : 
; a = le numero de tile comme dans la tilemap
; action :
; baisser la vie si sprite blessant
; sortie:
; rien d'utilisable
mapHurts:
	rra					;bit 0: animation
	rra					;bit 1: nonpassable
	jr nc,mH_testLadder
		inc d				;d>0 si on ne peut pas y passer
		bit 2,a
		jr nz,mH_testLadder
			ld e,10		;e = un grand numéro pour signaler qu'il ne faut vraiment pas lui faire dommage
mH_testLadder:
	rra					;bit 2: ladder
	jr nc,mH_testMap
mH_testMap:
	rra					;bit 3: changer de map
mH_testBlesser:
	rra					;bit 4: blesser
	jr nc,mH_testBoss
	push af
		ld a,(velocityY)
		rla
		jr c,$+10		;si vel y est négative, faire dommage
		ld a,(playerY)
		cp $70			;yOff = 3
		 jr c,$+3
			dec e		;ne lui faire mal au moins que Megaman soit très proche du pic
	pop af
	inc e
mH_testBoss:
	rra					;bit 5: 
	rra					;bit 6: 
	rra					;bit 7: scripts
	ret nc
	bit bossBattle,(iy+zFlags)
	 ret nz
	ld sp,(mainSP)		;la pile a beaucoup de valeurs poussées, charger la valeur de la pile que l'on avait dans la boucle main
	dec sp				;sp-2 mettra la pile au dernier appel dans main (ici call playerGravity)
	dec sp				; donc on retournera à l'instruction après l'appel (c'est "jp main")
	jp prepareBossRoom

;entrée:
;a = offset à ajouter à playerY (+2,+3,0,-1)
;sortie
;hl = player offset
getYOffset:
;	ld hl,playerY+1	;aligné aux tuiles
;	add a,(hl)		;a+playerY
getYOffset_skip:	;pour les routines des méchants
	ld h,a
	ld l,0
	ld a,(mapWidth)
	ld e,a
	ld d,l
	ld b,8
hDY_multBoucle:		;hl=e*h
	add hl,hl
	jr nc,noAdd
	add hl,de
noAdd:
	djnz hDY_multBoucle
	ret

;entrée
;b = offset à ajouter à playerX
addXOffset:
	ld e,b
addXOffset_skip:	;pour les routines des méchants
	ld d,0			;peut-être que ce n'est pas nécéssaire
	add hl,de
	ld de,map
	add hl,de		;hl=où le joueur veut allez dans la carte
	ret

;entrée:
;	h = player X (l = player X offset)
hitDetectX:
	push hl
		ld a,(playerY+1)
		call getYOffset	;a = y position de la tuile à chercher
	pop bc				;b = player X
	call addXOffset		;b = combien d'octets à droit (+)/ à gauche (-) qu'il faut chercher
	ld de,0
	ld a,(mapWidth)
	ld c,a
	ld b,d
	ld a,(slideFrames)
	or a
	jr nz,hDX_skipTunnel	;si on est en train de faire un slide, sauter le premier teste.
	push bc					;bc = mapWidth
		push hl
			call getBrush
			ld a,(hl)			;maptile: le plus à gauche
		pop hl
		call mapHurts	;si nous ne pouvons pas passer, vérifier si la tuile nous blessera
	pop bc
hDX_skipTunnel:
	add hl,bc
	push bc
		push hl
			call getBrush
			ld a,(hl)
		pop hl
		call mapHurts
	pop bc
	ld a,(playerY)		;si l'y offset n'est pas zéro (premier octet de playerY est l'offset, deuxième est aligné avec la carte)
	and %11100000		; le joueur occupe trois tiles, pas deux
	jr z,hDX_checkHurt	; alors en vérifier un troisième
		add hl,bc
		push hl
			call getBrush
			ld a,(hl)
		pop hl
		call mapHurts
hDX_checkHurt:
	dec e				;si e était = à 0, maintenant sera $FF
	ld a,e
	cp 3				;$FF-10 = nc, 0->2 = c, 3+ = nc
	ld b,3				;soustraire 3 points de vie
	 call c,playerDamage;seulement lui faire mal si e est entre 0-2
	xor a
	cp d				;cp d,0
	ret					;d = 0 on peut y passer									

;vérifier qu'il n'y a rien qui nous bloque
;entrée:
;h = valeur y
;sortie
;z = on peut y passer, nz = bloqué
hitDetectY:
	ld a,h
	call getYOffset
	ld a,(playerX+1)
	ld b,a
	call addXOffset
	ld de,0000				;des drapeaux: si d=0 on peut passer, si e=0 la tuile ne blesse pas Megaman
	push hl
		call getBrush
		ld a,(hl)			;maptile: le plus à gauche
	pop hl
	call mapHurts	;si nous ne pouvons pas passer, vérifier si la tuile nous blessera
	inc hl				;vérifier prochain tile
	push hl
		call getBrush	;[megaTileMap.asm]
		ld a,(hl)
	pop hl
	call mapHurts
	ld a,(playerX)		;si l'x offset n'est pas zéro
	or a				; le joueur occupe trois tiles, pas deux
	jr z,hDX_checkHurt	; alors en vérifier un troisième
		inc hl
		push hl
			call getBrush
			ld a,(hl)
		pop hl
		call mapHurts
		jr hDX_checkHurt
