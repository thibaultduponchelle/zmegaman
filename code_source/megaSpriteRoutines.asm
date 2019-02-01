;########################################################
;# [megaSpriteRoutines.asm]
;#-------------------------------------------------------
;# ROUTINES CONTENUES:
;#-------------------------------------------------------
;# drawSpriteOr:
;#  Ecrire un sprite avec le masque OR
;#  Draw a sprite using or mask
;#-------------------------------------------------------
;# drawSpriteOr:
;#  Ecrire un sprite avec le masque OR
;#  Draw a sprite using or mask
;#-------------------------------------------------------

; Need something? 
; Simply Do It Yourself :D

; a = x
; e = y
; ix = sprite
; (b = hauteur du sprite)
drawSpriteOr:
	ld	b, 8	; Sprite 8 de hauteur
drawSpriteOr_var:
	cp 96
	 ret nc		;ret X >= 96 ou X < 0
	ld h,0
	ld d,h		;d & h = 0
;clipping Y
	ex af,af'
		ld a,b	;hauteur du sprite
		add a,e	;hauteur + coordonnée Y
		 ret m	;si le résultat est négatif, le sprite va être complètement hors d'écran
		 ret z
		 jr nc,$+11	;nc signifie que la position Y du sprite est positive
			ld b,a	;b = combien de rangs du sprite il faudra afficher
			ld a,e
			neg
			ld e,a
			add ix,de
			xor a
			ld e,a	;nouvelle coordonnée Y
		cp 72
		 jr c,$+8
			ld a,72
			sub e
			 ret c
			 ret z
			ld b,a
	ex af,af'
		
; y * 13
	ld l,e
	add	hl, hl	; 2
	add	hl, de	; 3
	add	hl, hl	; 6
	add	hl, hl	; 12
	add	hl, de	; 13

; x / 8
	ld	e, a
	srl e
	srl e
	srl e
	add	hl,de		; A present on a le decalage dans hl
	ld de,megaGbuf	; Prendre le debut du graphbuffer
	add	hl,de		; Puis ajouter le decalage

	and $07		; %0000111 pour en tirer l'offset x
	ld c,a		; Sauver dans c
	or a            ; aligné ?
	jr nz,dso_non_aligne
	
dso_aligne:
	ld de,13
dso_aligne_loop:
	ld a,(ix)
	or (hl)		;hl = octet dans gbuf
	ld (hl),a		;écrire le nouvel octet !
	inc	ix			;prochain octet du sprite
	add	hl,de 		;prochain rang dans gbuf
	djnz dso_aligne_loop
	ret

; a= decalage
dso_non_aligne:
	ld de,12
dso_non_aligne_loop:
	push	bc
	ld	b, c	; On va utiliser le nombre de rotations comme compteur
	ld	a, (ix)	; L'octet qu'il faut decaler 
	inc	ix
	ld	c, d	; mettre c à 0
dso_shift_loop:
; carry = 0 (regarder le inc ix)
	 rra		; Decaler a vers la droite et ce qui sort va en carry
	 rr	c		; Injecter la carry dans c
	 djnz	dso_shift_loop
	or	(hl)
	ld	(hl), a	; Ecrire le premier octet
	inc	hl		; Avancer d'un cran
	ld	a, c
	or	(hl)
	ld	(hl), a ; Ecrire le second octet
	add	hl, de 	; prochain rang du gbuf
	pop	bc
	djnz	dso_non_aligne_loop
	ret
