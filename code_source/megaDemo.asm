;########################################################
;# [megaDemo.asm]
;#-------------------------------------------------------
;# ROUTINES CONTENUES:
;#-------------------------------------------------------
;# tremblerEcran:
;#  Faire un effet de tremblement (moins de 8 pixels)
;#  Ca rend bien j'adore cet effet :)
;#  Do a nice shocking effect
;#-------------------------------------------------------
;# loadText:
;#  Charger le texte a afficher puis l'afficher
;#  Load the text to print then print it
;#-------------------------------------------------------


; zmegaman is a crazy demonstration of what we could do on TI calc platform !


shockk:
  .db 0

; Mettre shockk > 0 pour dire combien de secousses il faut, cette fonction n'est pas blocante elle s'execute dans desCarte
tremblerEcran:
	ld a,(shockk)
	or a
	 ret z
	ld b,7
	call random
	ld (xOff),a
	ld b,7
	call random
	ld (yOff),a
	ld hl, shockk
	dec (hl)
	jp nz,updateRotation
	xor a
	ld (xOff),a
	ld (yOff),a
	jp updateRotation

;b = texte à charger
loadText:
	call openDataFile	;[megaLoadData.asm]
	ld de,120-2+12		;sauter la table de niveaux. -2 parce que chaque entrée occupe deux octets, +8 parce que
						; l'on soustrait 8 dans openDataFile (voir: "ld de,20-12")
	add hl,de
	ld e,2
	 add hl,de
	 djnz $-1
	call checkOverflow	;vérfier que l'on n'est pas sorti de $7FFF
	ld e,(hl)
	call loadNextHL
	ld d,(hl)
	add hl,de			;ajouter l'offset
;maintenant copier
	ld de,map			;on va copier le texte ici
copyText:
	call checkOverflow
	ld a,(hl)			;
	ld (de),a
	inc hl
	inc de
	inc a
	 jr nz,copyText
	call closeDataFile
	ld hl,map
	ld (textPosition),hl
	set textWrite,(iy+sGrFlags)
	call clearBothGbufs
	ld hl,megaGbuf
	ld (hl),$FF
	ld de,megaGbuf+1
	ld bc,(71*13)-1
	ldir
	xor a
	ld (xOff),a
	ld (yOff),a
	call updateRotation
scrollLoop
;delai
	ld b,16
	xor a				;n'importe laquelle touche
	out (1),a			;lire toutes les touches
scrollDelai:
	in a,(1)
	cp di2nd
	 jp z,waitKey_release	;quitter !
	inc a
	 jr nz,sauterDelai	;si on a appuyé sur une touche, sauter le delai
	ei
	halt
	di
	djnz scrollDelai
sauterDelai:
	call drawGbuf
;décaler l'écran
	ld hl,megaGbuf+(1*13)
	ld de,megaGbuf
	ld bc,71*13
	ldir
;effacer le gbuf (on n'a pas besoin de vitesse ici)
	ld hl,gbuf
	ld (hl),0
	ld de,gbuf+1
	ld bc,12*7
	ldir

	ld hl,counter
	ld a,(hl)
	inc a
	cp 7
	 jr c,$+3
		xor a
	ld (hl),a
	jr nz,scrollLoop
loadLine:
textPosition = $+1
	ld hl,0000
	ld a,(hl)
	inc a
	 ret z
	push hl
;centrer le string
		ld de,gbuf+200
		push de
		bcall(_StrCopy)			;il faut calculer la largeur du string
		pop hl					; donc on va copier le string dans RAM
		bcall(_StrLength)		; pour vérifier sa largeur avec _SStringLength
		dec hl
		ld (hl),c				;c = largeur (nombre de caractères)
		bcall(_SStringLength)
		srl b					;b = largeur (nombre de pixels)
		ld a,96/2
		sub b
		ld d,0
		ld e,a
		ld (penCol),de
	pop hl						;le string original
	bcall(_VPutS)				;afficher le sprite à la partie haute du gbuf
	ld (textPosition),hl

	ld hl,megaGbuf+(64*13)
	ld (hl),0
	ld de,megaGbuf+(64*13)+1
	ld bc,6*13-1
	ldir

	ld hl,gbuf					;charger le string dans megaGbuf
	ld de,megaGbuf+(64*13)
	call textCopy				;copier text dans gbuf à notre megaGbuf

	ld hl,megaGbuf+(64*13)
	ld b,13*7
invertLoop:
	ld a,(hl)
	cpl
	ld (hl),a
	inc hl
	djnz invertLoop
	ld b,7
	jp scrollLoop+2		;moins de délai si on a affiché de nouveau texte
