cpt:
  .db 2

PRINT_MENU:
	call	BUFCLR
  call  BLACK_SCREEN
  set   TextInverse, (iy + textflags)
  ;set   TextEraseBelow, (iy + textflags)
  set   TextWrite, (ix + sGrFlags)

  ld ix, sprite_start

	ld     a,57
	ld     (penrow),a   
	ld     a,27
	ld     (pencol),a   
	ld     hl, presser_del_pour_quitter
	call	_vputs

	ld     a,45
	ld     (penrow),a   
	ld     a,1
	ld     (pencol),a   
	ld     hl, choose_difficulty
	call	_vputs

	ld     a,30
	ld     (penrow),a   
	ld     a,1
	ld     (pencol),a   
	ld     hl, choose_keys
	call	_vputs
	
	

menu_loop:
                
	      ld      a, (mode)
        cp      0   
        jp      z, mode_easy
        cp      1
        jp      z, mode_medium
        cp      2
        jp      z, mode_hard

mode_easy:
        ld      hl, easy
        push    hl  
        jp      pm_print_type
mode_medium:
        ld      hl, medium
        push    hl  
        jp      pm_print_type
mode_hard:
        ld      hl, hard
        push    hl  
        jp      pm_print_type

pm_print_type:
        ld     a, 45
        ld     (penrow),a   
        ld     a, 50
        ld     (pencol),a   
        pop     hl  
        call    _vputs
        call    FASTCOPY



        ld      a, (keys)
        cp      0   
        jp      z, keys_alpha
        cp      1
        jp      z, keys_up
keys_alpha:
        ld      hl, alpha
        push    hl  
        jp      pm_print_keys
keys_up:
        ld      hl, up
        push    hl  
        jp      pm_print_keys
pm_print_keys:
        ld     a, 30
        ld     (penrow),a   
        ld     a, 30
        ld     (pencol),a   
        pop     hl  
        call    _vputs
        call	FASTCOPY
        call PUT_RUNNER
        
        ;call	_getkey
        ; Scanner pour savoir si on change les settings
        ld      a,$ff
        out     (1), a
        ld      a, $FE
        out     (1), a
        in      a,(1)

        cp      251       ; ->
        jp      z, inc_mode
        cp      253       ; <-
        jp      z, dec_mode	
        cp      247       ; ^
        jp      z, inc_keys
        cp      254       ; 
        jp      z, dec_keys	


        ; Scanner pour savoir si on quitte
        ld      a,$ff
        out     (1), a
        ld      a, $FD
        out     (1), a
        in      a,(1)

        cp	5	; enter
        ret	z	; Sortir du menu
        cp	10
        ret z 
        
        jp	menu_loop

inc_mode:
        ld      a, (mode)
        cp      2
        jp      p, nodecnoinc
        ld      hl, mode
        inc     (hl)
        jp      menu_loop

dec_mode:
        ld      a, (mode)
        cp      1
        jp      m, nodecnoinc
        ld      hl, mode
        dec     (hl)
        jp      menu_loop

inc_keys:
        ld      a, (keys)
        cp      1
        jp      p, nodecnoinc
        ld      hl, keys
        inc     (hl)
        jp      menu_loop

dec_keys:
        ld      a, (keys)
        cp      1
        jp      m, nodecnoinc
        ld      hl, keys
        dec     (hl)
        jp      menu_loop

nodecnoinc:
	jp	menu_loop
	
	
	call	WAITKEY
	ret


BLACK_SCREEN:
  ld hl, PLOTSSCREEN + 228
  ld a, 11111111b
  ld (hl), a
  push hl
  pop de
  inc de
  ld bc, 12
  ldir
  ld a, 00000000b
  ld (hl), a
  ld bc, 12
  ldir
  ld a, 11111111b
  ld (hl), a
  ld bc, 24
  ldir
  ld a, 00000000b
  ld (hl), a
  ld bc, 12
  ldir
  ld a, 11111111b
  ld (hl), a
  ld bc, 768 - 228 - 12 - 24 - 12 - 12
  ldir
  call FASTCOPY
  ret

alpha:
	.db $cf, "     Jump = alpha ", $05, 0
up:
	.db $cf, "     Jump = up           ", $05, 0

easy:
	.db $cf, "     Easy         ", $05, 0
medium:
	.db $cf, "   Medium   ", $05, 0
hard:
	.db $cf, "     Hard        ", $05, 0

keys:
  .db 0

mode:
  .db 0


choose_keys:
	.db "Keys :", 0

choose_difficulty:
	.db "Difficulty :", 0

presser_del_pour_quitter:
	.db "(del = exit)", 0

; NORMAL
; ix = le sprite a afficher
; a = x
; e = y
draw_sprite_16x16:

  ; y * 12
  ld  hl, 0
  ld  d, 0
  add hl, de  ; 1
  add hl, de  ; 2
  add hl, de  ; 3
  add hl, hl  ; 6
  add hl, hl  ; 12
 
  ; x / 8
  ld  d, 0
  ld  e, a
  srl e ; / 2
  srl e ; / 4
  srl e ; / 8
  add hl, de

  ; a present on a le decalage dans hl
  ld  de, PLOTSSCREEN ; prendre le debut du graphbuffer
  add hl, de    ; puis ajouter le decalage

  ld      b,00000111b     ; le reste 
  and     b
  ld  c, a    ; sauver dans c
  cp      0               ; tester l'alignement en x 
  jp      z,ds16_aligne
  jp  ds16_non_aligne

 
ds16_aligne:
  ld  b, 16 ; sprite 8 de hauteur
ds16_aligne_loop:
  push  bc
  ld  a, (ix)
  ;and (hl)
  ld  (hl), a
  inc hl
  inc ix
  ld  a, (ix)
  ;and (hl)
  ld  (hl), a
  inc ix
  ld  de, 11
  add hl, de
  pop bc
  djnz  ds16_aligne_loop

  jp  ds16_fin

; c= decalage
ds16_non_aligne:
  ld  b, 16
ds16_non_aligne_loop:
  push  bc
  ld  b, c  ; on va utiliser le nombre de rotations comme compteur
  ld  a, (ix) ; l'octet qu'il faut decaler 
  inc ix
  ld  e, (ix)
  inc ix
  ld  d, 0

ds16_shift_loop:
  push  bc  ; ici on sauve en meme temps le compteur b et le decalage c
  srl a ; decaler a vers la droite et ce qui sort va en carry
  rr  e ; injecter la carry dans e
  rr  d
  pop bc
  djnz  ds16_shift_loop

  and (hl)
  ld  (hl), a ; ecrire le premier octet
  inc hl  ; avancer d'un cran
  ld  a, e
  and (hl)
  ld  (hl), a ; ecrire le second octet
  inc hl  ; avancer d'un cran
  ld  a, d
  and (hl)
  ld  (hl), a ; ecrire le troisieme octet

  ld  de, 10
  add hl, de

  pop bc
  djnz  ds16_non_aligne_loop

ds16_fin:
  ret

PUT_RUNNER:
        ld hl, slow
        dec (hl)
        ret nz
        ld a, 5
        ld (hl), a

        ld a, 40
        ld e, 0
        call draw_sprite_16x16
        call FASTCOPY 
        ld hl, cpt
        dec (hl)
        jp p, do_not_reset_cpt
        ld ix, sprite_start
        ld a, 2
        ld (hl), a
do_not_reset_cpt:
        ret

slow:
  .db 5

sprite_black:
  .db 11111111b,11111111b
  .db 11111111b,11111111b
  .db 11111111b,11111111b
  .db 11111111b,11111111b
  .db 11111111b,11111111b
  .db 11111111b,11111111b
  .db 11111111b,11111111b
  .db 11111111b,11111111b
  .db 11111111b,11111111b
  .db 11111111b,11111111b
  .db 11111111b,11111111b
  .db 11111111b,11111111b
  .db 11111111b,11111111b
  .db 11111111b,11111111b
  .db 11111111b,11111111b
  .db 11111111b,11111111b

sprite_test:
  .db 00000000b,00000000b
  .db 00000000b,00000000b
  .db 00000000b,00000000b
  .db 00000000b,00000000b
  .db 00000000b,00000000b
  .db 00000000b,00000000b
  .db 00000000b,00000000b
  .db 00000000b,00000000b
  .db 00000000b,00000000b
  .db 00000000b,00000000b
  .db 00000000b,00000000b
  .db 00000000b,00000000b
  .db 00000000b,00000000b
  .db 00000000b,00000000b
  .db 00000000b,00000000b
  .db 00000000b,00000000b

sprite_start:
#include "sprites/courtDroite1.bmp"
#include "sprites/courtDroite2.bmp"
#include "sprites/courtDroite3.bmp"
sprite_end:

