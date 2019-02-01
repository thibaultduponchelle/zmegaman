;ÃœÃ›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›ÃŸ DRWSPR ÃŸÃ›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›
;ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
;Â³ Draw 8x8 sprite Ã¾ a=x, e=y, hl=sprite address                              Â³
;Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
DRWSPR:
        push    hl              ; Save sprite address

;Ã›Ã›Ã›Ã›   Calculate the address in graphbuf   Ã›Ã›Ã›Ã›

        ld      hl,0            ; Do y*12
        ld      d,0
        add     hl,de
        add     hl,de
        add     hl,de
        add     hl,hl
        add     hl,hl

        ld      d,0             ; Do x/8
        ld      e,a
        srl     e
        srl     e
        srl     e
        add     hl,de

        ld      de,8e29h
        add     hl,de           ; Add address to graphbuf

        ld      b,00000111b     ; Get the remainder of x/8
        and     b
        cp      0               ; Is this sprite aligned to 8*n,y?
        jp      z,ALIGN


;Ã›Ã›Ã›Ã›   Non aligned sprite blit starts here   Ã›Ã›Ã›Ã›

        pop     ix              ; ix->sprite
        ld      d,a             ; d=how many bits to shift each line

        ld      e,8             ; Line loop
LILOP:  ld      b,(ix+0)        ; Get sprite data

        ld      c,0             ; Shift loop
        push    de
SHLOP:  srl     b
        rr      c
        dec     d
        jp      nz,SHLOP
        pop     de

        ld      a,b             ; Write line to graphbuf
        or      (hl)
        ld      (hl),a
        inc     hl
        ld      a,c
        or      (hl)
        ld      (hl),a

        ld      bc,11           ; Calculate next line address
        add     hl,bc
        inc     ix              ; Inc spritepointer

        dec     e
        jp      nz,LILOP        ; Next line

        jp      DONE1


;Ã›Ã›Ã›Ã›   Aligned sprite blit starts here   Ã›Ã›Ã›Ã›

ALIGN:                          ; Blit an aligned sprite to graphbuf
        pop     de              ; de->sprite
        ld      b,8
ALOP1:  ld      a,(de)
        or      (hl)            ; xor=erase/blit
        ld      (hl),a
        inc     de
        push    bc
        ld      bc,12
        add     hl,bc
        pop     bc
        djnz    ALOP1

DONE1:
        ret




;ÜÛÛÛÛÛÛÛÛÛÛÛÛß CLRSPR ßÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Clear 8x8 sprite þ a=x, e=y, hl=sprite address                             ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CLRSPR:
        push    hl              ; Save sprite address

;ÛÛÛÛ   Calculate the address in graphbuf   ÛÛÛÛ

        ld      hl,0            ; Do y*12
        ld      d,0
        add     hl,de
        add     hl,de
        add     hl,de
        add     hl,hl
        add     hl,hl

        ld      d,0             ; Do x/8
        ld      e,a
        srl     e
        srl     e
        srl     e
        add     hl,de

        ld      de,8e29h
        add     hl,de           ; Add address to graphbuf

        ld      b,00000111b     ; Get the remainder of x/8
        and     b
        cp      0               ; Is this sprite aligned to 8*n,y?
        jp      z,ALIGN2


;ÛÛÛÛ   Non aligned sprite erase starts here   ÛÛÛÛ

        pop     ix              ; ix->sprite
        ld      d,a             ; d=how many bits to shift each line

        ld      e,8             ; Line loop
LILOP2: ld      b,(ix+0)        ; Get sprite data

        ld      c,0             ; Shift loop
        push    de
SHLOP2: srl     b
        rr      c
        dec     d
        jp      nz,SHLOP2
        pop     de

        ld      a,b             ; Write line to graphbuf
        cpl
        and     (hl)
        ld      (hl),a
        inc     hl
        ld      a,c
        cpl
        and     (hl)
        ld      (hl),a

        ld      bc,11           ; Calculate next line address
        add     hl,bc
        inc     ix              ; Inc spritepointer

        dec     e
        jp      nz,LILOP2       ; Next line

        jp      DONE5


;ÛÛÛÛ   Aligned sprite erase starts here   ÛÛÛÛ

ALIGN2:                         ; Erase an aligned sprite in graphbuf
        pop     de              ; de->sprite
        ld      b,8
ALOP2:  ld      a,(de)
        cpl
        and     (hl)
        ld      (hl),a
        inc     de
        push    bc
        ld      bc,12
        add     hl,bc
        pop     bc
        djnz    ALOP2

DONE5:
        ret










	
;ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã‚Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã‚Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã‚Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã‚Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
;Â³Ã›Ã›Ã›Ã›Ã› Z80 Ã›Ã›Ã›Ã›Ã›Ã›Â³     EQUALS     Â³Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Â³ movax Â³Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Ã›Â³
;Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„ÃÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„ÃÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„ÃÃ„Ã„Ã„Ã„Ã„Ã„Ã„ÃÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™

; ### unused ###
; Only put  repeat sprite on the screen
DRWBG:
	ld	hl, 8e29h
	;ld	c, (sprite_to_repeat) ; le sprite a repeter sur tout l'ecran	
	
	ld	b, 12
boucle1:
	ld 	a, 64
boucle2:	
	inc	hl
	ld	(hl), c
	dec	a
	cp 	0
	jp  	nz,boucle2
	
	djnz	boucle1

	ret

; Fast copy routine from joewing 
; Thanks to him !!!
FASTCOPY: 
	di 
	ld a,$80 
	out ($10),a 
	ld hl,PLOTSSCREEN-12-(-(12*64)+1)  ;changer ici 
	ld a,$20 
	ld c,a 
	inc hl  ;filler 
	dec hl ;filler 
fastCopyAgain: 
	ld b,64   ;et ici 
	inc c 
	ld de,-(12*64)+1 
	out ($10),a 
	add hl,de 
	ld de,10 
fastCopyLoop: 
	add hl,de 
	inc hl  ;filler 
	inc hl  ;filler 
	inc de ;filler 
	ld a,(hl) 
	out ($11),a 
	dec de ;filler 
	djnz fastCopyLoop 
	ld a,c 
	cp $2B+1 
	jr nz,fastCopyAgain 
	ret

