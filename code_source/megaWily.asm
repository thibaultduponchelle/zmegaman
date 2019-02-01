WILY_Y = 5			;y value of wily when touching ground
WILY_SPRITES = 5	;combien de sprites de Dr. Wily qu'il y a

chargerWily:
	ld a,8					;le niveau actuel (choisi dans le ménu des niveaux) pour choisir le boss correct
;	call chargerBossActionsSelonChoix	;on utilise directemment la liste d'actions de Wily
;	call chargerBossMapSelonChoix
	ld hl,bossSpritesWily	;[tilemap/megaSprites.inc]
	push hl
		ld de,bossSpritesFlipped
		ld bc,48*BOSS_W*WILY_SPRITES
		ldir
	pop hl
;maintenant flipper les sprites
	push de
	pop ix						;de = le premier octet des sprites flippé
	ld e,WILY_SPRITES
	ld bc,(BOSS_W*256)+48		;b = BOSS_W, c = BOSS_H
	xor a						;pas d'espace entre les sprites
	call flipSprites-3

	ld sp,(mainSP)				;effacer la pile

;charger le map
	ld b,10						;le map à charger
	call loadLevelFromArchive	;[megaLoadData.asm]

;initialiser les méchants
	ld hl,nombreMechants
	ld (hl),1
	ld hl,mechantArray
	ld (hl),$FF					;un méchant mort

;coordonnées
	ld hl,(WILY_Y+2)*256
	ld (bossY),hl
	ld h,8
	ld (bossX),hl				;x/y de Wily par défaut
	ld a,3
	ld (wilyRound),a			;3 = quand wily meurt il faut transformer en le hover mobile
								;0 = quand wily meurt on a gagné
	xor a
	ld (wilyFrame),a
	set bossBattle,(iy+zFlags)
	call bossVersMegaman		;faire que le boss faire face à Megaman

	call transformWily

wilyLoop:
	call desCarte				;dessiner la carte
	call desPersonnage			;dessiner le joueur
	call desBalles				;
	call wilyAction				;que va faire le boss ?
	call desMechants			;y a-t-il des méchants ?
	call desWily
	call desSlideParticles		;si quelque chose tombe du ciel
	call desParticles			;si quelque chose tombe du ciel
	call desBossHP
	call desBarreHP
	call drawGbuf
	ld hl,shock
	ld a,(hl)
	or a
	 jr z,$+7
		dec (hl)
		ld a,(hl)
	 	ld (slideFrames),a	;armer slide frames parce que Megaman a "tombé"
	or a
	call z,keyCheck

	ld a,(playerHP)
	or a
	 jp z,tu_as_perdu
	ld a,(bossHP)
	or a
	 jr nz,wilyLoop
wilyRound = $+1
		jr $+5
		jp tu_as_gagne
		xor a
		ld (wilyRound),a		;la prochaine fois qu'on tue Wily, on aura gagnÃ©
		call centrerEcranSurBoss
		ld bc,(bossX)
		inc b
		ld de,(bossY)
		inc d
		inc d
		call explodeBoss
		call transformWily
		call centrerEcranSurJoueur
		jp wilyLoop

transformWily:
	ld hl,$0200
	ld (hoverGrav),hl			;hGrav = 0, hVel = 2
	xor a
	ld (counter),a
	ld (numberBullets),a
	ld (bossDamage),a			;
	ld (bossVelX),a
	ld (bossVelY),a				;ne bouge pas !
	ld (nombreMechants),a
	ld a,MAX_BOSS_HP
	ld (bossHP),a				;HP du boss par défaut

	ld c,B_TRANSFORM
	call chargerAction			;
transformToWalker:
	call desCarte				;dessiner la carte
	call desPersonnage			;dessiner le joueur
	call wilyAction				;que va faire le boss ?
	call desWily
	call drawGbuf
	ld a,(actionEtat)
	cp B_TRANSFORM
	 jr z,transformToWalker
	ret

desParticles:
	ld hl,numParticles
	ld a,(hl)
	or a
	 ret z						;quitter s'il n'y a pas de particles
	cp 8
	 jr nz,$+11
		ld de,particles+15		;dernier particle
		ld a,(de)
		inc a
		 jr nz,startParticles
			ld (hl),a
			ret
	ld b,3
	call random
	or a
	 jr nz,startParticles
		inc (hl)				;numParticles+1
startParticles:
	ld b,(hl)
	ld hl,particles

		ld a,(xCoord)
		add a,a
		add a,a
		add a,a
		ld e,a
			ld a,(yCoord)
			add a,a
			add a,a
			add a,a				;x8
			ld d,a

dP_loop:
;d = mapY
;e = mapX
	push bc
	push de
		ld a,(hl)
		sub e					;coordX - mapX
		ex af,af'				;sauver a (coord x)
			inc hl
			ld a,(hl)			;coord Y du particle
			inc a				;si y = $FF
			 jr z,skipParticle	;ne pas afficher
			inc a
			inc a
			ld (hl),a
			sub d				;coordY - mapY
			 jr c,skipParticle	;hors d'écran
			ld e,a				;e = position Y
			ld a,e
			cp 80				;si la position Y = 80
			 jr c,$+4			; on est hors d'écran
				ld (hl),$FF		; ne l'afficher plus
			ld ix,gutsmanIcon
		ex af,af'
		push hl
			call drawSpriteOr
		pop hl
skipParticle:
		inc hl
	pop de
	pop bc
	djnz dP_loop		
	ret

wilyAction:
	call gravityWily	;la gravité sur vélocité y
	call movWilyY		;bouger boss en haut/bas
	call movWilyX		;bouger boss vers la gauche/droite
	call bossCollision
	call checkStomp
	jp callBossPenser

checkStomp:
	ld a,(wilyFrame)
	cp 2
	 ret nz
	ld a,(actionEtat)
	cp B_STOMP
	 ret z
	cp B_TRANSFORM
	 ret z
	ld hl,(playerX)
	ld de,(bossX)
	sbc hl,de
	add hl,hl
	add hl,hl
	add hl,hl
	ld a,h
	add a,24
	cp 56
	 ret nc
	jp setUpStomp

;;;;;;;
;; La gravité 
;;;;;;;
gravityWily:
	nop					;quand on est en train de transformer
	ld a,(wilyFrame)	;  le nop devient un ret (regarde "actionTransform" [megaBoss.asm])
	or a
	 jr nz,gravWilyCont	;la gravité n'affecte pas à la machine hover
	ld a,(hoverGrav)
	ld hl,hoverVel
	add a,(hl)
	ld (hoverGrav),a
	 jr nc,$+4
		neg
	cp 14
	 jr nz,$+6
		ld a,(hl)
		neg
		ld (hl),a
	ld hl,(bossY)
	ld de,(hoverGrav)
	call signExtendE
	add hl,de
	ld (bossY),hl
	ret
gravWilyCont:
	ld hl,bossVelY
	ld a,(hl)
	add a,10
	 jp m,gravWilyNeg
	cp $70
	 jr c,$+4
		ld a,$70
gravWilyNeg:
	ld (hl),a
	ret


;;;;;;
; Ajouter la vélocité X à bossX et enlever l'action si on touche un mur.
;;;;;;
movWilyX:
;mettre à jour la vélocité X
	ld a,(bossVelX)
	ld e,a
	call signExtendE	;si e est positif, d = 0, sinon d = $FF [megaMath.asm]
	ld hl,(bossX)
	add hl,de
	ld (bossX),hl	;sauver nouvelle position
	ld de,14*256	;ld d,14, e,0
	or a			;désarmer carry
	sbc hl,de
     jr nc,changerDeSensX_wily
    add hl,de
	ld d,1			;côté gauche du map
	or a
	sbc hl,de
	 ret nc
changerDeSensX_wily:
	ld (bossX),de
	ld hl,bossVelX
	ld (hl),0		;mettre vélocité X à zéro

	ld a,(bossVelY)
	or a
	 ret nz
	jp resetBossAction	;enlever l'action

;Ajouter la vélocité Y à bossY. Remettre à zéro si on est à terre
movWilyY:
	ld a,(bossVelY)		;vélocité Y du boss
	or a
	 ret z
	ld hl,(bossY)		;coord y
	ld e,a
	call signExtendE	;si e est positif, d = 0, sinon d = $FF [megaMath.asm]
	add hl,de			;bossY+velY
	ld (bossY),hl		;mettre à jour bossY
	ld e,0
	ld d,WILY_Y
	or a				;désarmer le carry
	sbc hl,de			;si on est sur terre
	 ret c
	ld hl,bossVelY
	ld (hl),0			;il faut mettre la vélocité Y à zéro
	ld hl,WILY_Y*256	;pour que le boss ne déscende pas trop
	ld (bossY),hl
	ret

;########################################################
;# DESWILY (desWily)
;#-------------------------------------------------------
;# afficher le sprite clippé du boss à l'écran.
;# paramètres:
;# 	aucun
;# sortie:
;#	rien
;########################################################
desWily:
	ld hl,bossDamage			;combien de frames
	ld a,(hl)
	or a
	 jr z,continueWily
	dec (hl)
	and $3
	cp 2
	 ret c
continueWily:
;## début calcule animation
	ld ix,bossSpritesFlipped	;nous avons sauvé les sprites du boss ici

	ld hl,wilySpriteSize
wilyFrame = $+1
	ld c,0
	ld b,0
	add hl,bc
	add hl,bc
	add hl,bc
	ld c,(hl)					;bc = combien d'octets il faut ajouter pour arriver au sprite
	inc hl
	ld b,(hl)
	add ix,bc
	inc hl
	ld a,(hl)					;a = la hauteur du sprite
	ld (yPixelsToDraw),a
	push af
		ld bc,48*BOSS_W*WILY_SPRITES
		ld a,(bossDir)
		or a
		 jr z,$+4					;si bossDir != 0, Wily regarde vers la gauche
			add ix,bc				; sinon, il regarde vers la droite et il faut changer le sprite
;## fin calcule animation
		ld hl,(bossY)				;la coordonnée y du boss
		add hl,hl
		add hl,hl
		add hl,hl					;h = coordonnée y en pixels
		ld a,(yCoord)
		add a,a
		add a,a
		add a,a						;map Y en pixels
		ld b,a
		ld a,h
		sub b
	pop bc
	ld e,a						;sauver coordonnée y
	or a
	 jp p,skipYClip
	add a,b
	 ret m
	 ret z
	ld (yPixelsToDraw),a
	ld a,e
	neg
	ld e,a
	ld d,$00
	add ix,de
	add ix,de
	add ix,de					;3 octets de largeur
	ld e,0
	jp bossX-3
