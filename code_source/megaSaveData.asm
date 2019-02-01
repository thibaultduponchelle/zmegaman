;########################################################
;# [megaSaveData.asm]
;#-------------------------------------------------------
;# ROUTINES CONTENUES:
;#-------------------------------------------------------
;# createSaveFile:
;#  Creer le fichier de sauvegarde dans la memoire ram
;#  create the file into the ram memory
;#-------------------------------------------------------
;# archiveSave:
;#  Deplacer la sauvegarde dans la memoire archive
;#  Move the save state into arc memory
;#-------------------------------------------------------
;# checkSave:
;#  Verifier l'existance de la sauvegarde
;#  Check if save state exists
;#-------------------------------------------------------

; We should never forget our past


;le format du fichier de sauvegarde:
;0	: playerHP
;1  : bossesBeat
;2  : selectedWeapon
;3	: energyTanks
;4	: playerLives
;5-12: énergie des armes

SAVE_SIZE = 5+16

;HL = size of var to create, NewVarName contains name
createSaveFile:
	ld hl,SAVE_SIZE
	bcall(_EnoughMem)		;avons-nous assez d'espace pour garder le variable ?
	 ret c
	push de					;_EnoughMem donne de = taille du variable
	ld hl,saveFile			;pointeur au nom de notre AppVar
	rst 20h					;_Mov9ToOP1, copier 9 octets de (hl) à OP1
	pop hl					;hl = taille de l'AppVar
	bcall(_CreateAppVar)	;OP1 = nom, hl = taille de l'AppVar
	or a					;désarmer carry
	jr archiveSave			;DE = début des datas de l'AppVar, HL = entrée dans la VAT

saveGame:
	call checkSave
	 jp c,createSaveFile	;si l'archive n'existe pas, le créer
	dec b
	inc b
	 jr z,$+16				;si c'est dans RAM, saveToRAM
		bcall(_Arc_Unarc)
archiveSave:
		call saveToRAM
		call checkSave		;trouver l'AppVar dans RAM
		bcall(_Arc_Unarc)	;... et le rearchiver
		di
		ret
saveToRAM:
	inc de
	inc de					;deux octets de taille
	ld hl,playerHP
	ld c,5					;playerHP - playerLives
	ldir
	ld hl,itemsFound
	ld c,16
	ldir
	ret

;le fichier existe-t-il ?
checkSave:
	ld hl,saveFile			;nom de l'AppVar
	rst 20h					;_Mov9ToOP1 : copier le nom dans OP1
	bcall(_ChkFindSym)		;chercher la VAT
	ret
