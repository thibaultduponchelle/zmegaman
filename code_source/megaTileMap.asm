;########################################################
;# [megaTilemap.asm]
;#-------------------------------------------------------
;# ROUTINES CONTENUES:
;#-------------------------------------------------------
;# rleDecompress:
;#  Decompresser une map 
;#  Decompress a map
;#-------------------------------------------------------
;# desCarte:
;#  Dessiner la tilemap
;#  Draws the tilemap
;#-------------------------------------------------------
;# getBrush:
;#  TODO : je sais pas trop ce que ca fait
;#-------------------------------------------------------


; This is a penguin's kingdom


;merci à thepenguin77 de m'avoir aidé avec ce code-ci
;vérifier que l'on ne va pas lire hors de $4000-$7FFF
;si hl = $8000, il faut le remettre à $4000 est incrémenter la page d'où nous lisons
loadNextHL:
	inc hl
checkOverflow:
	ld a,h
	res 7,h			;bit 7 = $8000+
	set 6,h			;bit 6 = $4000+
	cp h
	 ret z
		in a,(6)	;charger la prochaine page de FLASH
		inc a
		out (6),a
		ret

; hl = map to decompress
; de = destination
; Decompress a rle map into map
rleDecompress:
rleRepeterPourTous:
	; 1 Lire le nombre de fois que sera repete la valeur
	ld b, (hl)

	ld a, b
	or a	; si 0
	 ret z	; fin du traitement
    ; 2 Lire la valeur a repeter
	call loadNextHL
	ld a, (hl)

rleRepeterPourUn:
	ld (de), a
	inc de
	djnz rleRepeterPourUn
 
	; 3 Passer au suivant
	call loadNextHL
	jr  rleRepeterPourTous
;; Pas besoin de ret il est plus haut :)

desCarte:
	ld hl,animCounter	;update animation counter (les tuiles animées)
	ld a,(hl)
	inc a
	cp 24
	jr c,$+3
		xor a
	ld (hl),a

yCoord = $+1
	ld h,$00		;SMC
mapWidth = $+1
    ld e,$00		;SMC!
    call multEH		;hl=yCoord*mapWidth
	ld de,map		;les cartes sont décomprimées ici
	add hl,de		;mapPopinter+yCoord*mapWidth
xCoord = $+1		;charger coordonnées (grâce à SMC)
    ld de,$0000
	add hl,de			;ajouter x coord
	exx
		ld hl,megaGbuf
		ld de,13		;nombre de colonnes qu'a notre gbuf 
		ld bc,$0D09		;dessiner 13 colonnes y 9 rangs de sprites (il n'y a de place dans l'écran que pour 12x8) . Pourquoi pas 14 au fait (une rangée a droite une autre à gauche?)
dibFila:
		push hl			;sauvegarder pointeur au gbuf
	exx
	push hl				;sauvegarder carte loc 

	call getBrush
	ld b,(hl)			;octet d'actions
	inc hl
	ld a,(hl) 			;sprite #
	ld l,a
	ld h,d				;d = 0 à cause du ld de,(xCoord)
	add hl,hl
	add hl,hl
	add hl,hl			;hl * 8
	rr b				;si le premier bit de l'octet d'actions = 1, c'est animé
	 jr nc,dS_nonAnime	;si c'est pas armé, c'est pas animé
;animation
	ld a,(animCounter)
	and %00011000		;+0,+8,+16,+24 selon animCounter
	ld e,a				;d = 0
	add hl,de 
dS_nonAnime:
	ld bc,tileData
	add hl,bc		;premier octet du sprite 

	ld b,8			;8 rangs à dessiner
desSprite: 
	ld a,(hl)		;octet du sprite à dessiner 
	inc hl			;prochain octet 
	exx				;changer aux registres cachés
		ld (hl),a
		add hl,de	;prochain rang du gbuf
	exx
	djnz desSprite

	pop hl			;position dans la carte 
	inc hl 
	exx 
		pop hl		;gbuf antérieur
		inc hl
		djnz dibFila 
	 
	exx
	ld a,(mapWidth)
	sub 13
	ld e,a
	add hl,de
	exx
		ld e,13*7	;13 colonnes, 7 rangs à baisser
		add hl,de 
		ld e,13		;rendre les valeurs à e/b
		ld b,13
		dec c		;c=nombre de rangs du tilemap d'afficher
		jr nz,dibFila
	jp tremblerEcran ; Ne fait rien si megaGutsTire n'a pas active un compteur de secousses

;quel brush nous voulons, du numéro du brush en tirer son adresse
getBrush:
	ld a,(hl)		;numéro de brush
	ld l,a
	ld h,0
	add hl,hl		;x2
	ld bc,brushes
	add hl,bc
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	ret
