.nolist
#define EQU .equ 
#include "ti83asm.inc"
#include "tokens.inc"
.list

.org 9327h

START:
	call	_CLRLCDFULL
	call	BUFCLR
	call	FASTCOPY
	call	RINDOFF
	set 	textWrite, (iy + sGrFlags)

menu:
	call	PRINT_MENU
	
	.end
end

#include "menu.asm"
#include "drwspr.asm"
