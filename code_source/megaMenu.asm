;########################################################
;# [megaWeapon.asm]
;#-------------------------------------------------------
;# ROUTINES CONTENUES:
;#-------------------------------------------------------
;# weaponMenu:
;#  Menu des armes
;#  Weapon menu
;#-------------------------------------------------------
;# choisirArme:
;#  Choisir une arme
;#  Select a weapon
;#-------------------------------------------------------
;# drawWeaponsCursor:
;#  Dessiner le cadre pour selectionner une arme
;#  Draws the cursor to select a weapon
;#-------------------------------------------------------
;# buildEnergyBar:
;#  Dessiner la barre d'energie de chaque arme
;#  Draw energy bar of each weapon
;#-------------------------------------------------------

; No weapon could ever steal our freedom

weaponMenu:
	call waitKey_release
	call clearBothGbufs
	ld hl,megaGbuf
	call vertBar
	ld hl,megaGbuf+(13*2)
	call vertBar
	inc hl
	ld a,%10100000
	ld de,11
	ld b,58
weaponMenuLoop:
	ld (hl),a
	add hl,de
	rlca
	rlca
	rlca
	ld (hl),a
	rrca
	rrca
	rrca
	inc hl
	inc hl
	djnz weaponMenuLoop

	call vertBar
	ld hl,megaGbuf+(63*13)
	call vertBar		

	ld a,40+2
	ld e,9
	ld ix,bullet+1
	ld b,4						;hauteur du sprite
	call drawSpriteOr_var		;a = x, e = y

	ld a,(bossesBeat)
	ld b,8
weaponIconLoop:
	rla
	push af
	 jr nc,skipIcon
	push bc
	 	ld a,b
	 	ld c,b
	 	cp 5
	 	ld d,24
	 	 jr c,$+6
	 	 	sub 4
	 		ld d,56
	 	ld b,a
	 	add a,a					;x2
	 	add a,a					;x4
		add a,b					;x5
		add a,a					;x10 on aura donc 10 pixels entre la partie haute de chaque sprite
	 	add a,5
	 	ld e,a
	 	ld a,d
	 	ld b,0
	 	ld hl,weaponIcons-2
	 	add hl,bc
	 	add hl,bc
	 	ld c,(hl)
	 	inc hl
	 	ld h,(hl)
	 	ld l,c
	 	push hl
	 	pop ix
		call drawSpriteOr		;e = y, a = x
	pop bc
	call buildEnergyBar
skipIcon:
	pop af
	djnz weaponIconLoop
	ld hl,xOff
	ld (hl),0
	ld hl,yOff
	ld (hl),0
	call updateRotation

	ld hl,7*256+82
	ld (penCol),hl
	ld a,(energyTanks)
	bcall(_SetXXOP1)
	ld a,1
	bcall(_DispOP1A)

	ld a,16
	ld (penCol),a
	ld a,(playerLives)
	bcall(_SetXXOP1)
	ld a,1
	bcall(_DispOP1A)

	ld hl,gbuf+(7*12)
	ld de,megaGbuf+(7*13)
	call textCopy			;copier text dans gbuf à notre megaGbuf

	ld a,72
	ld e,7
	ld ix,energyTank+1
	ld b,7						;hauteur du sprite
	call drawSpriteOr_var		;a = x, e = y

	ld a,5
	ld e,7
	ld ix,oneUp+1
	call drawSpriteOr			;a = x, e = y

	ld hl,54*256+18
	ld (penCol),hl
	ld hl,saveText
	bcall(_VPutS)
	ld hl,gbuf+(54*12)
	ld de,megaGbuf+(54*13)
	call textCopy			;copier text dans gbuf à notre megaGbuf
	call drawSelectedWeapon
menuLoop:
	call drawWeaponsCursor
	call drawGbuf
	call drawWeaponsCursor
;touches
	call delai

;Alpha
	ld a,groupe6	; groupe 6 (Alpha)
    out (1),A
    in a,(1)
	cp diAlpha
	 jr nz,$+11
		in a,(1)		; lire
		cp diAlpha
		jr z,$-4	;il faut relâcher clear, sinon on va quitter tout le programme !
		jp saveGame

;2nd / Mode
	ld a,groupe7		; groupe 7 (2nd)
	out (1),a
	in a,(1)
	 cp di2nd
		jr z,choisirArme
	 cp diMode
		jp z,waitKey_release

;Fleches
	ld a,groupe1
	out (1),a			; Ecouter le groupe 1 qui est les fleches (bas = 254, gauche = 253, droite = 251, haut = 247)
	in a,(1)

	ld hl,selTimeur		;utilisé pour avoir un petit délai
	ld (hl),a
	
	ld hl,menuLoop
	push hl
	
	ld hl,weaponSelect
	rra					;down
	 jr nc,cursorDown
	rra					;left
	 jr nc,cursorLeft
	rra					;right
	 jr nc,cursorRight
	rra					;left
	 jr nc,cursorUp
	ret
	ld a,(hl)
	or a
	 jp p,$+6
	 	xor a
		ld (hl),0
	cp 9
	 jr c,$+4
		ld (hl),8
	jr menuLoop

choisirArme:
	ld a,(weaponSelect)
	cp 9
	 jr z,fillHP				;[megaItems.asm] les tanques de HP ne sont pas des armes !
	push af
		call drawSelectedWeapon
	pop af
	ld (selectedWeapon),a
	call drawSelectedWeapon
	jr menuLoop

fillHP:
	ld hl,energyTanks
	ld a,(hl)
	or a
	 jr z,menuLoop
	dec (hl)	
	ld b,MAX_HP
	call itemHealth2
	jp weaponMenu

cursorDown:
	ld b,(hl)
	ld a,b
	cp 9
	 jr c,$+4
		ld b,4
cD_loop:
	ld a,b
	cp 9
	 ret nc
	inc b
	call isLevelBeaten
	jr nc,cD_loop
	ld (hl),b
	ret

cursorLeft:
	ld a,(hl)
	or a
	 jr nz,$+5
	 	inc a
	 	jr cD_loop
	cp 5						;si < 5 nous sommes au côté gauche
	 ret c
	cp 9
	 jr c,$+5
		ld (hl),0
		ret
	sub 4
	ld b,a
	call isLevelBeaten
	 ret nc
	ld (hl),b
	ret

cursorRight:
	ld a,(hl)
	cp 5
	 ret nc
	or a
	 jr nz,$+5
		ld (hl),9				;si nous sommes à la première selection, aller à la première arme à droite
		ret
	add a,4
	ld b,a
	call isLevelBeaten
	 ret nc
	ld (hl),b
	ret

cursorUp:
	ld b,(hl)
cU_loop:
	ld a,b
	or a
	 ret z
	ld (hl),0
	cp 5
	 ret z
	dec a
	 jr nz,$+4
		ld (hl),a
		ret
	dec b
	call isLevelBeaten
	 jr nc,cU_loop
	ld (hl),b
	ret	

;b = premier numéro duquel chercher
isLevelBeaten:
	push bc
		dec b
		ld a,b
		or a
		ld a,(bossesBeat)
		 jr z,endRotate
beatLoop:
		rra
		djnz beatLoop
endRotate:
	pop bc
	rra
	ret

drawSelectedWeapon:
	ld a,(selectedWeapon)
	ld c,%11111111
	jr $+6
drawWeaponsCursor:
weaponSelect = $+1
	ld a,0
	ld c,0
	push bc
		call calculerCursOff
		call drawWeaponsHoriz
	pop bc
	inc hl
	ld b,8
	ld de,11
	add hl,de
drawWeaponsLoop:
	ld a,(hl)
	xor %00000001
	ld (hl),a
	inc hl
	ld a,(hl)
	xor c
	ld (hl),a
	inc hl
	ld a,(hl)
	xor %10000000
	ld (hl),a
	add hl,de
	djnz drawWeaponsLoop
	inc hl
drawWeaponsHoriz:
	ld a,(hl)
	xor $FF
	ld (hl),a
	ret

calculerCursOff:
	ld de,megaGbuf+(13*6)+5
	or a
	 jr z,skipCursorOffset
	dec a
	cp 8
	 jr nz,$+8
	 	xor a
		ld de,megaGbuf+(13*6)+9
		jr skipCursorOffset
	ld de,megaGbuf+(13*14)+3
	cp 4				;où sommes nous, premier ou deuxième rang?
	 jr c,$+7
		sub 4
		ld de,megaGbuf+(13*14)+7
skipCursorOffset:
 	ld b,a
	add a,a					;x2
	add a,a					;x4
	add a,b					;x5
	add a,a					;x10
	ld l,a
	ld c,a
	ld h,0
	ld b,h
	add hl,hl
	add hl,bc
	add hl,hl
	add hl,hl
	add hl,bc			;x13
	add hl,de
	ret

vertBar:
	ld (hl),$FF
	ld e,l
	ld d,h
	inc de
	ld bc,12
	ldir
	ret

;input hl  = endroit dans gbuf (de drawSpriteOr_var)
buildEnergyBar:
	push bc
	dec hl
	ex de,hl					;maintenant de = endroit dans gbuf
		ld hl,weaponEnergy-1	;début de data
		ld c,b
		ld b,0
		add hl,bc
		ld a,(hl)
		rra					;/2
		or a
		 jr z,quitBar
		ld b,a
		ld a,%00011000
	ex de,hl			;hl = endroit dans gbuf où afficher la barre
	ld de,-13
		add hl,de
		ld (hl),a
	 djnz $-2
quitBar:
	pop bc
	ret
