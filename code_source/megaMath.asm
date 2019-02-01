;########################################################
;# [megaMath.asm]
;#-------------------------------------------------------
;# ROUTINES CONTENUES:
;#-------------------------------------------------------
;# multEHSigned:
;#  multiplier e * h et mettre le resultat dans hl
;#-------------------------------------------------------
;# divHLD:
;#  diviser hl par d et mettre le resultat dans a et l
;#-------------------------------------------------------
;# random:
;#  mettre un numéro "aléatoire" dans a et b (le même numéro).
;#  La valeur de b s'utilise comme la valeur max du numéro
;#  aléatoire, donc le numéro dans a/b sera entre 0 et b
;#  (inclusives).
;#-------------------------------------------------------

; Do you want a free beer? 

;hl=e*h
multEHSigned:
	ld a,h
	or a
	jp p,multEH
	neg
	ld h,a
	call multEH
	ld a,l
	cpl
	ld l,a
	ld a,h
	cpl
	ld h,a
	inc hl
	ret

multEH:
	ld l,0
	ld d,l
	ld b,8
mEH_boucle:		;hl=e*h
	add hl,hl
	jr nc,mEH_noAdd
	add hl,de
mEH_noAdd:
	djnz mEH_boucle
	ret

;si e est positif, d = 0, sinon d = $FF
signExtendE:
	bit 7,e
	ld d,0
	 ret z
	dec d
	ret

;a & l = hl/d
divHLD:
	ld a,h
	or a
	 jp p,startDivision		;si d est négatif il faut le gérer différemment
;gérer les numéros négatifs
	cpl
	ld h,a
	ld a,l
	cpl
	ld l,a
	inc hl
	call startDivision
	neg
	ld l,a
	ret
startDivision:
	xor a					;on va utiliser a pour faire nos soustractions
	ld b,16					;il y a 8 bits
divHDBoucle:
	add hl,hl				;prochain bit de HL dans le carry, décaler l à gauche
	rla						;h décalé dans a
	cp d					;d > a ?
	jp c,dHD_skip			;si oui, il faut décaler encore une fois (mettre un zéro dans l)
	sub d					;soustraire diviseur de a
	inc l					;mettre bit 0 à un
dHD_skip:
	djnz divHDBoucle
	ld a,l
	ret

;########################################################
;# RANDOM (random)
;#-------------------------------------------------------
;# Mettre un numéro aléatoire dans a, 0-b
;# Paramètres:
;#  b = max numéro
;# Sortie:
;#  a & b = numéro entre 0-b
;########################################################
random:
  push hl
  inc b
  ld a,r
randomSeed = $+1
  ld hl,0000
  adc a,l
  ld h,a
  ld a,(hl)
  xor l
  ld e,a
  sbc hl,hl
  ld d,h
randomBoucle:
  add hl,de     ;essentiellement nous décalons le numéro dans e dans h
  djnz randomBoucle ;b*e (e = 0/256 - 255/256)
  ld b,h
  ld a,b
  ld (randomSeed),hl
  pop hl
  ret 
