; Faire une crolling vertical de en utilisant le byte en argument (registre a)
; Cela permet de faire un effet de style 
; Input : a (l'octet a copier sur l'ecran)
; Detruit bc, hl et les trucs detruits par FASTCOPY
SCROLL_BYTE_EFFECT:
	ld	b, 64 
	ld	hl, plotSScreen

sbe_loop:
	push	bc
	ld	b, 12

sbe_loop2:
	ld	(hl), a
	inc 	hl
	djnz	sbe_loop2

	push	af
	push	hl
	bcall(_GrBufCpy)
	pop	hl
	pop	af
	pop	bc
	djnz	sbe_loop

	ret

PUT_BYTE:
	ld	hl, plotSScreen
	ld	(hl), 11001111b
	
	ret

; Remplir tout l'ecran avec le byte du registre a
; Cela peut permettre de faire un effet de clignotement (en fait pas sur)
; Input : a (l'octet a copier sur l'ecran)
; Detruit bc, hl et les trucs detruits par FASTCOPY
FILL_BYTE_EFFECT:
	ld	b, 64 
	ld	hl, plotSScreen

fbe_loop:
	push	bc
	ld	b, 12

fbe_loop2:
	ld	(hl), a
	inc 	hl
	djnz	fbe_loop2

	pop	bc
	djnz	fbe_loop

	bcall(_GrBufCpy)
	ret


SCROLL_BYTE_EFFECT_BLACK: 
	ld	a,11111111b
	call	SCROLL_BYTE_EFFECT
	ret


SCROLL_BYTE_EFFECT_WHITE: 
	ld	a,00000000b
	call	SCROLL_BYTE_EFFECT
	ret

SCROLL_BYTE_EFFECT_BLACK_THEN_WHITE:
	call	SCROLL_BYTE_EFFECT_BLACK
	call	SCROLL_BYTE_EFFECT_WHITE
	ret

