
#include "ti83plus.inc"
#include "ion.inc"
_NZIf83Plus   = $50E0

.org progstart - 2
.db t2ByteTok, tasmCmp

    call disable_c000_protection    
    ret
    ld hl, $C000
    ld a, $C9
    ld (hl), a
    jp $C000

#include "hack.asm"
