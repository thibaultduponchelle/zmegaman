;########################################################
;# [megaScript.asm]
;#-------------------------------------------------------
;# ROUTINES CONTENUES:
;#-------------------------------------------------------
;# prepareBossRoom:
;#  Mettre en place l'animation puis lancer le combat
;#  Set up scripts and launch battle
;#-------------------------------------------------------
;# scriptXXX:
;#  Les scripts (lorsque vous perdez le controle et que la
;#  camera ou megaman se deplace seul
;#  The scripts : when megaman does actions and camera moves alone
;#-------------------------------------------------------

; Don't tell me what to do 


prepareBossRoom:
	xor a
	ld (slideFrames),a
	ld (velocityX),a
	
	set bossBattle,(iy+zFlags)
	call getBrush
	inc hl						;sprite id
	inc hl						;script id
	ld e,(hl)
	ld d,0
	ld hl,scriptTable
	add hl,de
	add hl,de					;scriptTable contien des entrées de 2 octets
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
startScript:
	ld (scriptPointer),hl
	ld a,1
	ld (scriptTimer),a
	res upPressed,(iy+zFlags)
bossRoomLoop:
	call desCarte
	call desPersonnage
	call desBalles
;	call desMechants
	call verDesBoss
	call desBarreHP
	call drawGbuf
	call playerMomentum
	call playerGravity
;reinitialiser variables
	xor a
	ld (playerMovement),a	;si on a poussé gauche/droite
;vérifier si le compteur a fini
scriptTimer = $+1
	ld a,0
	dec a
	ld (scriptTimer),a
	 jr nz,runScripts		;si le compteur n'est pas 0, ne charger pas un nouveau script
	res upPressed,(iy+zFlags)
	res onWall,(iy+zFlags)
	res bossBattle,(iy+zFlags)	;activer scripts de nouveau (bossBattle est utilisé dans mapHurts
;charger le prochain script		;... pour que plus d'un script ne s'éxécute pas à la fois)
scriptPointer = $+1
	ld hl,0000					;l'addresse des datas du prochain script
	ld a,(hl)
	or a
	 ret z						;si l'action id = 0, on quitte la routine
	set bossBattle,(iy+zFlags)	;on va entrer dans un script
	add a,a
	ld c,a						;bc = action id
	ld b,0
	inc hl
	cp ONE_BYTE*2+1				;si le script occupe un octet
	 jr nc,loadNextPointer		; il n'a pas de paramètres
	cp TWO_BYTE*2+1				;si le script est deux octets ou trois
	ld a,(hl)					;nombre de frames
	 jr c,$+10					;si c'est une action de deux octets, charger le compteur
	 	ld e,(hl)
		inc hl					;les actions de trois octets n'ont pas de compteur de frames
		ld d,(hl)				;ld de,(hl)
		ld (scriptParameters),de	;charger les paramètres à passer à la routine
		xor a					;scriptTimer = 0 (aka 256)
	ld (scriptTimer),a
	inc hl
loadNextPointer:
	ld (scriptPointer),hl		;sauvegarder l'addresse du prochain script
	ld hl,scriptList-2			;**[megaScriptData.inc]**
	add hl,bc					;hl pointe sur l'addresse du script
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	ld (whereToJump),hl
runScripts:
	ld bc,bossRoomLoop
	push bc						;il faut retourner à bossRoomLoop après avoir éxécuté le script
whereToJump = $+1
	ld hl,0000
scriptParameters = $+1
	ld de,0000
	jp (hl)

;scriptList est dans [megaScriptData.inc]

scriptRunJump:
	call playerUp
scriptRun:
	xor a
	ld (slideFrames),a
	ld a,(playerDir)
	or a
	ld a,64
	 jr nz,$+4
		ld a,-64
_scriptRun:
	ld hl,velocityX
	ld (hl),a
	or a
	jp p,playerRight
	jp playerLeft
scriptWalk:
	ld a,(playerDir)
	or a
	ld a,16
	 jr nz,$+4
		ld a,-16
	jr _scriptRun

scriptWait:
	ret

scriptShootJump:
	call playerUp
scriptShoot:
	jp playerTire

scriptThrowLeft:
	call playerUp		;sauter
	ld a,-64
	call _scriptRun		;bouger joueur vers la gauche (vélocité négative)
	ld hl,playerDir		;mais on doit toujours regarder vers la droite
	ld (hl),2			;0 = regarde à gauche, 2 = droite
	ret
	
;paramètres:
;e = x
;d = y
scriptSealDoor:
	ld a,(scriptTimer)
	cp 230
	 jr nz,$+4
		ld a,1
	ld (scriptTimer),a
	and %00001100
	rra
	rra
	ld hl,yCoord
	add a,(hl)
	inc a
	call getYOffset
	ld b,1
	call checkLevel
	 jr nz,$+4				;si le joueur regarde vers la gauche ou la droite
		ld b,11				;si le joueur regarde vers la gauche, la porte est plus à droite
	ld a,(xCoord)
	add a,b
	ld e,a
	call addXOffset_skip
	ex de,hl
	ld hl,tilePieces
	ld bc,(selecteur)
	ld b,0
	add hl,bc
	ldi
	ret

tilePieces:
	.db $71					;map ice*
	.db $47					;map gut* *fix wall*
	.db $58					;map cut*
	.db $64					;map elec*
	.db $02					;map dive*
	.db $38					;map fire
	.db $12					;map metal*
	.db $22					;map wood

scriptOpenDoor:
	ld hl,scriptTimer
	ld a,(hl)
	dec a
	cp 220
	 jr nz,$+4
		ld (hl),1
	cp 235
	ld a,(playerY+1)
	sbc a,0
	inc a
	push de
		call getYOffset
	pop de
	call checkLevel
	ld b,-1
	 jr z,$+4
		ld b,3
	ld a,(playerX+1)
	add a,b
	ld e,a
	call addXOffset_skip
	ld (hl),$00
	ret

checkLevel:
	ld a,(selecteur)			;dive, elec
	cp 4						;dive
	 ret z
	cp 3						;niveau d'elecman
	ret

;########################################################
;# SCRIPTRETURNCAMERA (scriptReturnCamera:) /
;# SCRIPTMOVECAMERA (scriptMoveCamera:)
;#	scriptReturnCamera est le même que scriptMoveCamera
;# mais les paramètres sont les coordonnées où la carte
;# était avant de la bouger.
;# 
;# Entrée:
;#	de =  (scriptMoveCamera) combien de pixels (x et y) à
;#		  décaler l'écran. e = x, d = y
;########################################################
scriptReturnCamera:
	ld a,(scriptTimer)
	or a							;si c'est le premier frame, sauver les coordonnées initiales
	jr nz,skipCameraSetup
startingCoordinates = $+1
		ld de,0000
		ld (scriptParameters),de	;mettre à jour les nouveaux paramètres du script
		scf
;paramètres:
;e = x
;d = y
scriptMoveCamera:
	jr c,skipCameraSetup
	ld a,(scriptTimer)
	or a							;si c'est le premier frame, sauver les coordonnées initiales
	 jr nz,skipCameraSetup
		call checkLevel
		 jr nz,$+9
			ld a,e
			neg
			ld e,a
			ld (scriptParameters),a
		ld a,(mapHeight)
		ld hl,yCoord				;vérifier si nous sommes au dernier rang de la carte
		cp (hl)
		ld a,d
		jr nz,$+4
			add a,8
		ld (scriptParameters+1),a
		neg
		ld h,a
		ld a,e
		neg
		ld l,a						;invertir les coordonnées pour faire rentrer l'écran
		ld (startingCoordinates),hl	;sauver coordonnées de la carte
skipCameraSetup:
	ld hl,(scriptParameters)
	ld a,l
	cp h
	 jr nz,moveCameraNotDone
	 	inc a
		ld (scriptTimer),a
		ret
moveCameraNotDone:
	ld hl,scriptParameters
	ld a,(hl)
	or a
	push de
	 jr z,moveCameraY
	 jp m,notRight
		dec (hl)
		ld b,1
		call mapRight
		jr moveCameraY
notRight:
	inc (hl)
	ld b,-1
	call mapLeft
moveCameraY:
	pop de
	ld hl,scriptParameters+1
	ld a,(hl)
	or a
	 ret z
camYCont:
	 jp m,notDown
		dec (hl)
		ld b,1
		call mapDown
		ret
notDown:
	inc (hl)
	ld b,-1
	call mapUp
	ret

scriptOpenBossMap:
	ld hl,megaGbuf
	ld a,64+8				;nombre de rangs
	ld b,$37				;scf
	call blackOut
	xor a
	ld (yOff),a
	ld hl,megaGbuf+20*13
	ld a,24
	ld b,$B7				;or a
	call blackOut

	ld a,(selecteur)			;le niveau actuel (choisi dans le ménu des niveaux) pour choisir le boss correct
	push af
		call chargerBossActionsSelonChoix
		call chargerBossMapSelonChoix

		ld a,TERRE_Y-2
		ld (yCoord),a
		xor a
		ld (xCoord),a
		ld (xOff),a
		ld (bossDir),a
		ld (bossSpecial),a
		call updateRotation
		ld hl,(TERRE_Y*256)+$80
		ld (bossY),hl
		ld h,a
		ld (bossX),hl
		ld b,72
		ld hl,bossVelX
		ld (hl),16
	pop af
	push af
		dec a
		 jr nz,$+10
		 	ld hl,yCoord
		 	dec (hl)
		 	ld hl,bossY+1
		 	dec (hl)
		cp 3
		 jr nz,bossRunLoop
		ld (hl),32	
bossRunLoop:
		push bc
			call desBoss
			call drawGbuf
			ld hl,megaGbuf+20*13
			ld (hl),0
			ld de,megaGbuf+(20*13)+1
			ld bc,(24*13)-1
			ldir
			ld hl,(bossX)
			ld de,16
			add hl,de
			ld (bossX),hl
		pop bc
		djnz bossRunLoop

		ld ix,bossSpritesFlipped
		call bossY-1
		call drawGbuf
		call waitKey2

		ld b,10						;piece des bosses
		call loadLevelFromArchive	;[megaLoadData.asm]

	pop af

	ld sp,(mainSP)
	jp chargerBoss

blackOut:
	ld (blackColumns),a
	ld a,b
	ld (blackoutLoop),a
blackOutStart:
	ld a,13
blackoutOutLoop:
	ld c,8
blackoutMidLoop:
	ld de,13
blackColumns = $+1
	ld b,64+8
	push hl
blackoutLoop:
		scf
		rr (hl)
		add hl,de
		djnz blackoutLoop
	push bc
	push af
		call drawGbuf
	pop af
	pop bc
	pop hl
	dec c
	 jr nz,blackoutMidLoop
	inc hl
	dec a
	 jr nz,blackoutOutLoop
	ret

scriptKillEnemies:
	ld hl,nombreMechants
	ld (hl),0
	ld hl,scriptTimer
	ld (hl),1
	ret

scriptEnterWily:
	ld a,(scriptTimer)
	or a							;si c'est le premier frame, sauver les coordonnées initiales
	jr nz,skipWilySetup
		ld a,8
		call chargerBossMapSelonChoix
		ld hl,61*256
		ld (bossX),hl
		ld h,8
		ld (bossY),hl
		ld hl,bossDir
		ld (hl),0
skipWilySetup:
	ld hl,bossVelX
	ld (hl),0						;remettre vel x à zéro
	dec a							;si scriptTimer=1, afficher le texte
	 jr z,endWilySetup				;si a = 0, quitter la routine
	cp 185							;souviens-toi que l'on commence à 0, 0, 255, 254, etc.
	 jr nz,$+7
		ld a,30
		ld (scriptTimer),a			;attendre encore 30 frames
	 ret c
	ld (hl),-32						;vel X à -32
	ld de,-16
	ld hl,(bossX)
	add hl,de						;mouver boss 1/2 pixel vers la gauche
	ld (bossX),hl					;sauver nouvelle position
	ret
endWilySetup:
	ld b,2							;id de texte
	call loadText					;si a = 0, afficher le texte
	jp chargerWily

verDesBoss:							;doit-on afficher un boss ?
	ld a,(selecteur)
	cp 8							;le niveau de Wily
	 ret nz
	ld ix,bossSpritesFlipped
	jp verifCourir
