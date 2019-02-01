; Credit to brian coventry !


#include "ti83plus.inc"
#include "ion.inc"

#define b_(bit)   bit&7
#define f_(flag)  flag/$10

#define bit_(flag)  bit b_(flag), (ix + f_(flag))
#define set_(flag)  set b_(flag), (ix + f_(flag))
#define res_(flag)  res b_(flag), (ix + f_(flag))

#macro toggle_(flag)  
  ld  a, (ix + f_(flag))  
  xor   1 << b_(flag)
  ld  (ix + f_(flag)), a
#endmacro



avFlagSize    equ 2

avContrast    equ avFlagSize+1  ;1
avDelay     equ avContrast+1  ;1
avOmniData    equ avDelay+1 ;3
avPicName   equ avOmniData+3  ;7
avFontName    equ avPicName+7 ;7
avShell     equ avFontName+7  ;6
avRCProg    equ avShell+6 ;7
avOnProg    equ avRCProg+7  ;7
avHotKeys   equ avOnProg+7  ;63
avAxeMode   equ avHotKeys+63  ;1
avPicContrast   equ avAxeMode+1 ;1
avRefresh   equ avPicContrast+1 ;1
avZStartProg    equ avRefresh+1 ;7
avParserName    equ avZStartProg+7  ;6
avParserOffset    equ avParserName+6  ;2

avSize      equ avParserOffset+2

selected  equ appBackUpScreen ;1
leftMask  equ selected+1  ;1
rightMask equ leftMask+1  ;1
swapSectorPage  equ rightMask+1 ;1
pageA   equ swapSectorPage+1;1
pageB   equ pageA+1   ;1
saveA   equ pageB+1   ;1
saveHL    equ saveA+1   ;2
erase   equ saveHL+2  ;1
itemsFound  equ erase+1   ;1
scrolled  equ itemsFound+1  ;1
buttonPressed equ scrolled+1  ;1
tempBuf   equ buttonPressed+1 ;8
tagPtr    equ tempBuf+8 ;2
tempBuf2  equ tagPtr+2  ;8
saveDE    equ tempBuf2+8  ;2
tempPage  equ saveDE+2  ;1
tempAddr  equ tempPage+1  ;2
tempGood  equ tempAddr+2  ;1
cursX   equ tempGood+1  ;1
cursY   equ cursX+1   ;1   
increment equ cursY+1   ;2   
saveSP    equ increment+2 ;2
contrastSave  equ saveSP+2  ;1
realShadow  equ contrastSave+1  ;2
avShadow  equ realShadow+2  ;avSize
avDirty   equ avShadow+avSize ;1
refresh   equ avDirty+1 ;1
menuId    equ refresh+1 ;1
avbParser    equ $26

.org progstart - 2 
.db t2ByteTok, tasmCmp

;toggleParserHook:
  toggle_(avbParser)
  bit_(avbParser)
  ;jr  nz, makeAvDirty
  xor a
  ld  (avShadow+avParserName), a
  ret

makeAvDirty:
  ld  a, 1
  ld  (avDirty), a
  ret

