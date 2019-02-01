;########################
;#MAP MOVEMENT ROUTINES
;# displace the map
;########################

;;
; Deplacer la map vers la droite
;;
mapRight:
    ; Commencer par tester si on peut avancer vers la droite (donc si on est pas au bout de la map)
    ld hl,updateRotation
    push hl
    ld hl,xCoord
    ld a,(mapWidth)
    sub 12
    cp (hl)
    ret z

    ; Augmenter le decalage au sein de la map
	ld de,xOff
	ld a,(de)
	add a,b	;b=nombre de pixels à décaler
	ld (de),a
	cp 8	; Tester si on doit faire une rotation ou non
	ret c	;if we have no overflow, we're all good.

	inc (hl)
	and $07
	ld (de),a
;vérifier de nouveau si nous avons atteint la fin de la carte (à cause du "inc (hl)")
	ld a,(mapWidth)
	sub 12
	cp (hl)
	ret nz				;pas atteint, pas de problème
		xor a
		ld (de),a		;sinon, remettre yOff à zéro
		ret

;;
; Deplacer la map vers la gauche
;;
mapLeft:
    ; Tester si on peut aller a gauche...
    ld hl,xCoord
    ld de,xOff
    ld a,(de)
    or (hl)				;si xCoord = 0 & xOff = 0: on est au bord de la carte
    ret z
	ld a,(de)
	add a,b
	jp p,$+10			;3 octets	si xOff<0 (p=positive) soustraire un de xOff
		dec (hl)		;1o
		ld b,(hl)		;1o
		inc b			;10
		jr nz,$+4		;2o 		éviter dépasser fin de l'écran
		inc (hl)		;1o
		xor a			;1o
	and $07
	ld (de),a			;xoff
	jp updateRotation

;;
; Deplacer la map vers le haut
; b=nombre de pixels à sauter
;;
mapUp:
    ld de,yOff
    ld a,(de)
    add a,b				;b=nombre de pixels à sauter
    ld (de),a			;sauvegarder
	ret p				;si yOff >= 0

    ld hl,yCoord
	ld c,(hl)
	dec c
	jp p,mU_continue	;si yCoord > 0, aller à mU_continue
		xor a
		ld (de),a
    	ret
mU_continue:
	dec (hl)
    and $07
    ld (de),a
    ret

;;
; Deplacer la map vers le bas
;;
mapDown:
; vérifier si nous avons atteint la fin de la carte
    ld hl,yCoord
mapHeight = $+1
    ld a,$00
    cp (hl)
	ret z

    ld de,yOff			;map y offset
    ld a,(de)
    add a,b				;ajouter nombre de pixels à déplacer l'écran
	ld (de),a
    cp 8
    ret c				;si yOff < 8, il ne faut pas aller à la prochaine tuile

mD_continue:
	inc (hl)
    and $07
    ld (de),a
;vérifier de nouveau si nous avons atteint la fin de la carte (regarder le "inc (hl)")
	ld a,(mapHeight)
	cp (hl)
	ret nz				;pas atteint, pas de problème
		xor a
		ld (de),a		;sinon, remettre yOff à zéro
		ret

;##########################
;# UPDATEROTATION
;# After changing the x offset
;#	of the map, we need to update
;#	the rotation in the fastcopy
;#	routine.
;##########################
updateRotation:
    ld a,(xOff)         ;what is the xOffset?
    ld hl,gbufMask
    ld e,a
    ld d,0
    add hl,de           ;pointer to the rotation mask
    ex af, af'
		ld a,(hl)
		ld hl,maskLeft
		ld (hl),a
		ld hl,maskRight
		cpl                 ;xor $FF
		ld (hl),a
	ex af, af'

    ld hl,rotateRight
    cp 4
    jr nc,rotarDer
    ld hl,rotateLeft
rotarDer:
    and %00000011
    ld e,a
    ld d,0
    add hl,de
    push hl
    ld de,rotLeft
    ldi
    ldi
    ldi
    ldi
    pop hl
    ld de,rotRight
    ldi
    ldi
    ldi
    ldi
    ret

rotateRight:       ;if offset greater than or equal to 4, rotate the gbuf right up to four times
    rrca
    rrca
    rrca
    rrca
rotateLeft:       ;the nops keep it smoother (same delay as rlca)
    nop          ; so whether we shift or not, it will take the same amount of cycles
    nop
    nop
    nop
    rlca
    rlca
    rlca
    rlca