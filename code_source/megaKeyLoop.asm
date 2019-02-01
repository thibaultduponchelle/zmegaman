;########################################################
;# [megaKeyLoop.asm]
;#-------------------------------------------------------
;# ROUTINES CONTENUES:
;# AUCUNE !
;#------------------------------------------------------
;# On utilise le direct input ici
;# On n'accede pas ici par un call mais le code est inclus 
;# et exécuté là où il est inclus.
;# We use direct input here
;# No call to arrive here, simply the code is executed 
;# when included.
;#-------------------------------------------------------

; In freedom we trust 

keyCheck:
	; Initialiser les valeurs a 0
	xor a
	ld (playerMovement),a	;si on a poussé gauche/droite

;clear
	ld a,groupe2	; groupe 2 (clear)
	out (1),a		; porte 1: clavier
	push af
	pop af
	in a,(1)		; lire
		cp diClear
		jr nz,$+11
			in a,(1)		; lire
			cp diClear
		 jr z,$-4	;il faut relâcher clear, sinon on va quitter tout le programme !
	     jp reset	; si on appuie sur clear, quitter le programme

;2nd
	ld a,groupe7	; groupe 7 (2nd)
	out (1),a
	push af
	pop af
	in a,(1)
		cp diMode
		 call z,weaponMenu	;charger weaponMenu dans saferam
		cp di2nd
		 jr z,$+7
			ld hl,bulletDelay
			ld (hl),-1
		call z,playerTire
		cp diY
		 jr nz,$+8
			ld hl,HPTimer
			inc (hl)
			inc hl
			inc (hl)		;EPTimer
;clavier
	ld hl,slideFrames
	ld a,(hl)
	or a
	jr z,keyTest
;vérifier que nous ne somme pas dans un tunnel
		dec (hl)
		jr nz,skipKeyTest
		ld hl,(playerY)
		push hl
			call hitDetectY
		pop hl
		jr z,keyTest	;s'il n'y a rien au-dessus
		inc h
		inc h
		call hitDetectY
		jr z,keyTest	;s'il n'y a rien dessous
		ld hl,slideFrames
		ld (hl),1
		jr skipKeyTest		
keyTest:
	ld a,groupe1	
	out (1),a				; Ecouter le groupe 1 qui est les fleches (bas = 254, gauche = 253, droite = 251, haut = 247)
	push af
	pop af
	in a,(1)
	ld (keyPressSave),a		;il faut savoir quelles touches on a poussées pour l'arme de Metalman (pour viser)
							; et aussi pour savoir si on va glisser ou sauter avec Alpha
	rra						; Mettre le bit de poids faible dans la carry  
;	push af
;		call nc,playerSlide
;	pop af
	rra
	push af
		call nc,playerLeft	; Aller a gauche
	pop af
	rra
;	push af
		call nc,playerRight	; Aller a droite

;Alpha
	ld a,groupe6 ; groupe 6 (Alpha)
	out (1),A
	push af
	pop af
	in a,(1)
	cp diAlpha
	 jr z,$+6
		res upPressed,(iy+zFlags)
	 call z,playerUp ; Monter ou sauter

;	pop af
;	rra
;	 jr nc,$+6
;		res upPressed,(iy+zFlags)
;	 call nc,playerUp	; Monter ou sauter
	res onWall,(iy+zFlags)
skipKeyTest:
	call playerMomentum		; devoir venir d'abord parce que gravité remet la vélocité X à zéro
	call playerGravity		; Nul ne peut echapper a la gravite ... :D
	ret
