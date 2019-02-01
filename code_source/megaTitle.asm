;########################################################
;# [megaTitle.asm]
;#-------------------------------------------------------
;# ROUTINES CONTENUES:
;#-------------------------------------------------------
;# title_print:
;#  Afficher le titre
;#  Print the title
;#-------------------------------------------------------
;# archive_game:
;#  Chercher s'il y a une sauvegarde
;#  Look for a save state
;#-------------------------------------------------------
;# textCopy:
;#  Si je me trompe pas, c'est pour afficher le texte sous 
;#  le titre
;#  IIRC, this print the text below the title
;#-------------------------------------------------------
;# clearBothGbufs:
;#  Effacer les gbufs
;#  Hmm, simply do what the title says
;#-------------------------------------------------------

; A nice game for cut people 

;;;;;;;;
; Afficher le joli ecran de titre au demarrage du programme 
;;;;;;;;
TEXT_X = 24 
TEXT_Y = 37
title_print:
	call clearBothGbufs
	ld	hl, title_picture
	ld	de, megaGbuf+(3*13)
	ld a,(title_picture_end - title_picture)/12
titleCopy:
	ld	bc,12
	ldir					;mettre écran en noir
	inc de
	dec a
	 jr nz,titleCopy

	ld hl,TEXT_Y*256+TEXT_X
	ld (penCol),hl
	set textWrite,(iy+sGrFlags)
	ld hl,press_any_key
	bcall(_VPutS)

	call checkSave			;le fichier de sauvegarde existe-t-il ?
	 jr c,noSavedGame
	dec b
	inc b					;si b = 0, le fichier est dans RAM
	 jr nz,pasDansRAM
	ld hl,(TEXT_Y+13)*256+TEXT_X-17
	ld (penCol),hl
	ld hl,RAMText
	bcall(_VPutS)			;RAM warning
	ld de,(TEXT_Y+19)*256+TEXT_X-12
	ld (penCol),de
	bcall(_VPutS)			;continuation du texte
pasDansRAM:
	ld hl,(TEXT_Y+7)*256+TEXT_X
	ld (penCol),hl
	ld hl,loadGameText
	bcall(_VPutS)			;afficher le texte "load game" s'il y a un fichier de sauvegarde
noSavedGame:
	ld hl,gbuf+(TEXT_Y*12)
	ld de,megaGbuf+(TEXT_Y*13)
	ld a,20
	call textCopyLoop		;copier text du gbuf dans notre megaGbuf
	call drawGbuf
	call waitKey2
	cp diClear
	 jp z,quitter
	cp diAlpha
	 jr z,archiveGame
	cp di2nd				;z armé pour charger un niveau, désarmé pour commencer une nouvelle partie
	ret

archiveGame:
	call checkSave			;le fichier de sauvegarde existe-t-il ?
	 ret c					;le fichier n'existe pas
	dec b
	inc b					;si b = 0, le fichier est dans RAM
	 ret nz
	bcall(_Arc_Unarc)
	di						;_Arc_Unarc active les interruptions
	jr title_print

textCopy:
	ld a,6
textCopyLoop:
	push af
		ld b,12
			ld a,(de)
			or (hl)
			ld (de),a
			inc hl
			inc de
		 djnz textCopyLoop+3	;sauter push af et ld b,12
	pop af
	inc de					;megaGbuf = 13 octets, pendant que gbuf = 12
	dec a
	jr nz,textCopyLoop
	ret

clearBothGbufs:
	ld hl,gbuf
	ld (hl),0
	ld de,gbuf+1
	ld bc,12*64
	ldir
clearGbuf:
	ld hl,megaGbuf
	ld (hl),0
	ld de,megaGbuf+1
	ld bc,13*72
	ldir
	ret
