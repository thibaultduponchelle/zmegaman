.nolist
#define EQU .equ 
#include "includes/ti83asm.inc"
#include "includes/tokens.inc"
#define warrior_x 8265h
#define warrior_y 8266h
.list

.org 9327h

; Header pour ION
        xor     a       ; xor car on n'utilise pas les libs              
        jr      nc,start     
.db   "Main",0

start:

        call _CLRLCDFULL
        call _runIndicOff
        call BUFCLR
        call BUFCOPY
	call _puts
	call _getkey
	call title_print
	call trailer
	call menu_print
	

	ret

hello:
	.db "Hello world", 0


#include "title.asm"
#include "menu.asm"



