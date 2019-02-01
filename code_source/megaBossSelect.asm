;########################################################
;# [megaBossSelect.asm]
;#-------------------------------------------------------
;# ROUTINES CONTENUES:
;#-------------------------------------------------------
;# bossSelect:
;#  Au debut du jeu et entre chaque boss on tombe ici
;#  At start and between each boss we must choose a boss
;#-------------------------------------------------------
;# ouvirNiveau:
;#  Ouvrir le niveau
;#  Open the level
;#-------------------------------------------------------
;# desboss:
;#  Dessiner le boss
;#  Draws the boss
;#-------------------------------------------------------

; You always have a choice

;;;;;;
; Boss selection window
;;;;;;
bossSelect:
	call initialiser	;remettre à zéro x/yOff et les vélocités du joueur
	ld hl,playerHP
	ld (hl),MAX_HP-1	;donner du HP au joueur quand on retourne à la selection des bosses
	call rechargerArmes
;keyloop
selectionBoucle:
	call delai

;clear
	ld a,groupe2	; groupe 2 (clear)
	out (1),a		; porte 1: clavier
	in a,(1)		; lire
		cp diClear
		jp z,quitter

;2nd
	ld a,groupe7		; groupe 7 (2nd)
	out (1),a
	in a,(1)
	 cp di2nd
		jp z,ouvrirNiveau
	ld a,groupe1
	out (1),a			; Ecouter le groupe 1 qui est les fleches (bas = 254, gauche = 253, droite = 251, haut = 247)
	in a,(1)

	ld hl,selTimeur		;utilisé pour avoir un petit délai
	ld (hl),a

	ld hl,selecteur
	rra					; Mettre le bit de poids faible dans la carry 
	jr c,sB_sauterBas
;vers le bas
		ex af,af'
			ld a,(hl)
			add a,4
			call allLevelsCompleted
			 jr z,wilyBas
			cp 8
			 jr nc,finBas
			ld (hl),a
			jr finBas
wilyBas:
			add a,4		;4+4 = +8
			cp 12
			 jr c,$+4
				sub 12
			ld (hl),a
finBas:
		ex af,af'
sB_sauterBas:
	rra
	jr c,sB_sauterGauche
;vers la gauche
		ex af,af'
			ld a,(hl)
			cp 8
			 jr nc,$+6
				or a
				jr z,$+3
				 dec (hl)
		ex af,af'
sB_sauterGauche:
	rra
	jr c,sB_sauterDroite
;vers la droite
		ex af,af'
			ld a,(hl)
			sub 8
			 jr nc,$+6
				inc a
				jr z,$+3
				 inc (hl)
		ex af,af'
sB_sauterDroite:
	rra
	jr c,sB_sauterHaut
		ld a,(hl)
		call allLevelsCompleted
		 jr z,wilyHaut
		sub 4
		 jr c,sB_sauterHaut
		ld (hl),a
		jr sB_sauterHaut
wilyHaut:
		sub 8
		 jr nc,$+4
			add a,12
		ld (hl),a
sB_sauterHaut:
	call desBosses
	call desSelecteur
	call drawGbuf
	jp selectionBoucle

;b = 4 (bas) ou -4 (haut)
;de = les cps
wilyCheck:
	add a,b
	call allLevelsCompleted
	 jr z,wilyAvailable
	cp e
	 ret nc
	ld (hl),a
	ret
wilyAvailable:
	add a,b		;4+4 = +8
	cp d
	 jr c,$+4
		sub b
		sub b
		sub b	;-12
	ld (hl),a
	ret			

allLevelsCompleted:
	ld b,a
	ld a,(bossesBeat)
	inc a
	ld a,b
	ret

desSelecteur:
	ld de,megaGbuf
selecteur = $+1
	ld a,0
	cp 4				;où sommes nous, premier ou deuxième rang?
	ld b,22
	 jr c,$+5
		ld de,megaGbuf+(13*40)-12
	cp 8
	 jr c,$+8
	 	xor a
		ld b,14
		ld de,megaGbuf+(13*24)+4
	push bc
		ld l,a
		ld h,0
		ld c,l
		ld b,h				;ld bc,hl
		add hl,hl			;x2
		add hl,bc			;x3
		add hl,de
		call dS_horizontal
	pop bc
	ld de,11
	add hl,de
dS_boucle:
	ld a,(hl)
	and %01111111
	ld (hl),a
	inc hl
	inc hl
	ld a,(hl)
	and %11111110
	ld (hl),a
	add hl,de
	djnz dS_boucle
dS_horizontal:
	ld a,(hl)
	and $00
	ld (hl),a
	inc hl
	ld (hl),a
	inc hl
	ld (hl),a
	ret


desBosses:
	ld hl,megaGbuf
	ld (hl),$FF
	ld de,megaGbuf+1
	ld bc,13*72
	ldir					;mettre écran en noir
	
	ld hl,bossMugshots
	ld de,megaGbuf+13		;copier sprites des boss au gbuf, commençant par le deuxième rang de gbuf
;premier rang
	ld a,2
bS_desRang:
	ld b,4
bS_dR_boucle:
	call dessinerBossSprite
	inc de
	inc de
	inc de
	djnz bS_dR_boucle
;deuxième rang
	ld de,megaGbuf+(13*41)
	dec a
	jr nz,bS_desRang
;on a affiché tous les boss :)
;dessiner un symbole sur les boss que l'on a tué
	ld b,8
	ld a,(bossesBeat)
	ld c,a
	 rra
		call c,bossKilled
	 djnz $-4
	inc c					;bossesBeat = $FF si tous les bosses ont été tués
	 ret nz
	ld hl,bossMugshots+(3*22*8)
	ld de,megaGbuf+(13*25)+4
	push de
	push bc
	ex af,af'
	ld a,14				;chaque sprite a une hauteur de 22 pixels
	jp des_boucle

dessinerBossSprite:
	push de
	push bc
	ex af,af'
	ld a,22				;chaque sprite a une hauteur de 22 pixels
des_boucle:
	ldi
	ldi
	ldi					;chaque sprite est trois octets large
	ld bc,10
	ex de,hl			;maintenant hl=gbuf, de=sprite
	add hl,bc			;sauter au prochain rang dans gbuf
	ex de,hl			;hl=sprite, de=gbuf
	dec a				;compteur
	jr nz,des_boucle
	ex af,af'
	pop bc
	pop de
	ret
												

bossKilled:
	ex af,af'
	push bc
		ld hl,megaGbuf+(13*41)+(3*4)
		ld a,b
		cp 5
		 jr c,$+8
			sub 4
			ld b,a
			ld hl,megaGbuf+(13)+(3*4)			;gbuf a 13 colonnes, chaque boss en occupe trois, il y a quatre bosses
		ld de,-3
		 add hl,de
		 djnz $-1
;invertir le boss/apliquer un effet pour savoir que le boss a été battu
		ld e,%01010000
		ld a,%10001111
		ld c,22
beatBossLoop:
		ld b,3
			push af
				and (hl)
				or e
				ld (hl),a
			pop af
			inc hl
			djnz $-6
			rrca
			ld d,a
				ld a,e
				rrca
				ld e,a
			ld a,d
			push de
				ld de,10
				add hl,de
			pop de
			dec c
			jr nz,beatBossLoop
	pop bc
	ex af,af'
	ret

;;;;;
; Get the selector and open the right level
;;;;;
ouvrirNiveau:
	call waitKey_release
	ld a,(selecteur)
	cp 8
	 jr c,$+7
	ld a,8
	ld (selecteur),a
	ld b,a
	inc b
	call loadLevelFromArchive
	ld a,1
	ld (playerDir),a
	call main
	call initialiser ;remettre à zéro x/yOff et les vélocités du joueur
	jp bossSelect

delai:
selTimeur = $+1
	ld a,0
	inc a
	 ret z
	ld bc,100
delai_boucle:
	in a,(1)
	cp $FF
	 ret z
	djnz delai_boucle
	dec c
	jr nz,delai_boucle
	ret
