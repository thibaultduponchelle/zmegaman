;########################################################
;# [megaLoadData.asm]
;#-------------------------------------------------------
;# ROUTINES CONTENUES:
;#-------------------------------------------------------
;# loadLevelFromArchive:
;#  Charger la bonne carte selon la valeur de b
;#  Load the right map depending on the value of b
;#-------------------------------------------------------
;# openDataFile:
;#  Lire le contenu de la sauvegarde
;#  Read the content of the save state
;#-------------------------------------------------------


; Separate hard tasks, keep it simple silly


; A partir d'un nombre, on va choisir quelle carte il faut, quels emplacements de depart etc...
; b = id de carte à charger
loadLevelFromArchive:
	ld a,b
	ld (mapID),a

	call openDataFile	;ouvrir MEGADATA.8xp pour en lire
loadLevel:
;début du data
	ld e,12				;taille de chaque entrée
	 add hl,de
	 djnz $-1
; Aller prendre les informations dans les infos et mettre dans hl, de bc avant de lancer chargerCarte
	call checkOverflow	;vérfier que l'on n'est pas sorti de $7FFF
	ld a,(hl)			;mapX
	ld (xCoord),a
	call loadNextHL		;inc hl et vérifier que l'on n'est pas sorti de $7FFF
	ld a,(hl)			;mapY
	ld (yCoord),a
	call loadNextHL		;inc hl
	ld b,(hl)			;playerX
	ld c,0
	ld (playerX),bc		;premier octet = xOffset, deuxième = x
	call loadNextHL		;inc hl
	ld b,(hl)			;playerY
	ld (playerY),bc
	call loadNextHL		;inc hl
	ld a,(hl)			;checkpoint map x
	ld (cpMapX),a
	call loadNextHL		;inc hl
	ld a,(hl)			;checkpoint map y
	ld (cpMapY),a
	call loadNextHL		;inc hl
	ld a,(hl)			;checkpoint player x
	ld (cpPlayX),a
	call loadNextHL		;inc hl
	ld a,(hl)			;checkpoint player y
	ld (cpPlayY),a
	call loadNextHL		;inc hl
	
	ld e,(hl)
	call loadNextHL		;inc hl
	ld d,(hl)			;de = offset à ajouter

	in a,(6)			;il faut sauvegarder la page FLASH actuelle
	push af
	push hl
		add hl,de
		ld de,-9
		add hl,de			;il y avait 9 "inc hl"
		call checkOverflow
		ld a,(hl)		;mapHeight
		sub 8			;il y a 8 tuiles (verticalement) dans l'écran
		ld (mapHeight),a
		call loadNextHL		;inc hl
		ld a,(hl)
		ld (mapWidth),a
		call loadNextHL		;inc hl
		;; Decompresser hl vers map
		ld de, map
		call rleDecompress
		call initialiser	;remettre à zéro x/yOff et les vélocités du joueur
	pop hl
	pop af
	out (6),a
	call loadNextHL		;inc hl
	ld e,(hl)
	call loadNextHL		;inc hl
	ld d,(hl)
	add hl,de
	ld de,-11			;11 "inc hl"s
	add hl,de
	call checkOverflow
mapID = $+1
	ld a,0
	cp 10						;la pièce de boss n'a pas de méchants
	 call nz,chargerMechants	;[megaEnnemies.asm]
closeDataFile:
savePort = $+1
	ld a,0
	out (6),a
	ret

;N'OUBLIE PAS DE FAIRE UN APPEL A closeDataFile !
openDataFile:
	push bc
		ld hl,megaData_txt
		rst	20h				;9 octets à (hl) dans OP1
		bcall(_ChkFindSym)	;chercher le programme dans OP1
		 ret c				;hl = VAT, de = addresse du data
							;c armé si pas encontré
		in a,(6)			;il faut sauvegarder la page FLASH actuelle
		ld (savePort),a
		ld a,b				;b = 0 si le fichier est dans RAM
		or a
		 ret z				;si pas dans le RAM, b = la page FLASH
		out (6),a			;a = la page FLASH où est notre fichier
		ex de,hl
		ld de,20-12			;-12 parce que b=1 est la première carte, on va ajouter 12
		add hl,de			;il y a 20 octets avant le début du data, le nom du program, sa taille, addresse, page de FLASH, etc.
	pop bc
	ret

loadGame:
	call checkSave			;existe-t-il un fichier de sauvegarde ?
	 jp c,startGame
	dec b
	inc b
	 jr z,loadFromRAM
	in a,(6)				;il faut sauvegarder la page FLASH actuelle
	ld (savePort),a
	ld a,b					;si pas dans le RAM, b = la page FLASH
	out (6),a				;a = la page FLASH où est notre fichier
							;on va la mettre dans le bank $4000-$7FFF
	ld hl,20				;il y a 20 octets avant le début du data:
	add hl,de				; le nom du variable, sa taille, addresse, page de FLASH, etc.
	call checkOverflow		;vérfier que l'on n'est pas sorti de $7FFF
	ld bc,SAVE_SIZE
	call flashToBuffer		;charger hl dans gbuf

	ld a,(savePort)
	out (6),a				;il faut reinitialiser le port

	ld de,gbuf-2
;et maintenant on peut charger le sauvegarde de RAM
loadFromRAM:
	inc de
	inc de
	ex de,hl
	ld de,playerHP
	ld bc,5
	ldir
	ld de,itemsFound
	ld bc,16					;il y a 8 niveaux, chaque niveau a des slots pour items spéciales
	ldir
	jp bossSelect

;hl = position dans FLASH
;bc = combien d'octets à charger
;gbuf utilisé comme buffer
flashToBuffer:
	ld de,gbuf
flashToBufferLoop:
	ldi
	 ret po
	call checkOverflow
	jr flashToBufferLoop
