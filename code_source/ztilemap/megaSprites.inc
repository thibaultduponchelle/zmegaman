brushes:
.dw brSpace	;$00

; >>> DIVE
.dw brDive1	;$01
.dw brDive2	;$02
.dw brDive3	;$03
.dw brDive4	;$04
.dw brDive5	;$05
.dw brDive6	;$06
.dw brDive7	;$07
.dw brDive8	;$08
.dw brDive9	;$09
.dw brDiveA	;$0A
.dw brDiveB	;$0B
.dw brDiveC	;$0C
.dw brDiveD	;$0D
.dw brSpace	;$00
.dw brSpace	;$00
.dw brSpace	;$00

; >>> METAL
.dw brMetal1 ;$11
.dw brMetal2 ;$12
.dw brMetal3 ;$13
.dw brMetal4 ;$14
.dw brMetal5 ;$15
.dw brMetal6 ;$16
.dw brMetal7 ;$17
.dw brMetal8 ;$18
.dw brSpace	;$00
.dw brSpace	;$00
.dw brSpace	;$00
.dw brSpace	;$00
.dw brSpace	;$00
.dw brSpace	;$00
.dw brSpace	;$00
.dw brSpace	;$00

; >>> WOOD 
.dw brWood1 ;$21
.dw brWood2 ;$22
.dw brWood3 ;$23
.dw brWood4 ;$24
.dw brWood5 ;$25
.dw brWood6 ;$26
.dw brWood7 ;$27
.dw brWood8 ;$28
.dw brWood9	;$29
.dw brWoodA	;$2A
.dw brWoodB	;$2B
.dw brSpace	;$00
.dw brSpace	;$00
.dw brSpace	;$00
.dw brSpace	;$00
.dw brSpace	;$00

; >>> FIRE
.dw brFire1	;$31
.dw brFire2	;$32
.dw brFire3	;$33
.dw brFire4	;$34
.dw brFire5	;$35
.dw brFire6	;$36
.dw brFire7	;$37
.dw brFire8	;$38
.dw brFire9	;$39
.dw brFireA	;$3A
.dw brFireB	;$3B
.dw brFireC	;$3C
.dw brFireD	;$3D
.dw brSpace	;$00
.dw brSpace	;$00
.dw brSpace	;$00

; >>> GUT
.dw brGut1 ;$41
.dw brGut2 ;$42
.dw brGut3 ;$43
.dw brGut4 ;$44
.dw brGut5 ;$45
.dw brGut6 ;$46
.dw brGut7 ;$47
.dw brGut8 ;$48
.dw brGut9 ;$49
.dw brGutA ;$4A
.dw brGutB ;$4B
.dw brGutC ;$4C 
.dw brGutD ;$4D
.dw brSpace	;$00
.dw brSpace	;$00
.dw brSpace	;$00

; >>> CUT
.dw brCut1 ;$51
.dw brCut2 ;$52
.dw brCut3 ;$53
.dw brCut4 ;$54
.dw brCut5 ;$55
.dw brCut6 ;$56
.dw brCut7 ;$57
.dw brCut8 ;$58
.dw brCut9 ;$59
.dw brCutA ;$5A 
.dw brCutB ;$5B
.dw brCutC ;$5C
.dw brSpace	;$00
.dw brSpace	;$00
.dw brSpace	;$00
.dw brSpace	;$00
 
; >>> ELEC 
.dw brElec1 ;$61
.dw brElec2 ;$62
.dw brElec3 ;$63
.dw brElec4 ;$64
.dw brElec5 ;$65
.dw brElec6 ;$66
.dw brElec7 ;$67
.dw brElec8 ;$68
.dw brElec9 ;$69
.dw brElecA ;$6A
.dw brElecB ;$6B
.dw brElecC ;$6C
.dw brElecD ;$6D
.dw brElecE ;$6E
.dw brSpace	;$00
.dw brSpace	;$00

; >>> ICE
.dw brIce1 ;$71
.dw brIce2 ;$72
.dw brIce3 ;$73
.dw brIce4 ;$74
.dw brIce5 ;$75
.dw brIce6 ;$76
.dw brIce7 ;$77
.dw brIce8 ;$78
.dw brIce9 ;$79
.dw brIceA ;$7A 
.dw brSpace	;$00
.dw brSpace	;$00
.dw brSpace	;$00
.dw brSpace	;$00
.dw brSpace	;$00
.dw brSpace	;$00

;boss-related scripts
.dw goToBoss		;$81
.dw goToBossDoor	;$82
.dw goToDrWily		;$83

goToDrWily:
.db %10000000
.db $60
.db 2

goToBoss:
.db %10000000	;bit d'action
.db 0			;numéro de sprite
.db 0			;script id

goToBossDoor:
.db %10000001	;script
.db $60			;numéro de sprite
.db 1			;script id

;.db ACTION
;	bit 0: animé
;	bit 1: passable (armé si la tuile n'est pas passable)
;	bit 2: tuile peut être treppée 
;	bit 3: changer de map
;	bit 4: blesser joueur si l'on le touche
;	bit 7: initialiser entrée au boss room
;.db NUMERO DE SPRITE

brSpace
.db %00000000	;bit d'action
.db 0		;numéro de sprite

brDive1 ; dive_bloc0
.db %00000010
.db 1
brDive2 ; dive_bloc1
.db %00000010 ; 
.db 2
brDive3 ; dive_bloc2
.db %00000010
.db 3
brDive4 ; dive_eau1
.db %00011001
.db 4   
brDive5 ; dive_eau2
.db %00011001
.db 5   
brDive6 ; dive_eau3
.db %00011001
.db 6
brDive7 ; dive_cascade0
.db %00010011
.db 7
brDive8 ; dive_cascade1
.db %00010011
.db 8  
brDive9 ; dive_cascade2
.db %00000011
.db 9
brDiveA ; dive_tube0
.db %00000011
.db $0A
brDiveB ; dive_tube1
.db %00000011
.db $0B
brDiveC ; dive_tube2
.db %00000011
.db $0C
brDiveD ;dive_bloc4
.db %00000010
.db $0D

brMetal1 ; metal_bloc0
.db %00000010
.db $0E
brMetal2 ; metal_bloc1
.db %00000010
.db $0F
brMetal3 ; metal_bloc2
.db %00000010
.db $10
brMetal4 ; metal_bloc3
.db %00010010
.db $11
brMetal5 ; metal_bloc4
.db %00000010
.db $12
brMetal6 ; metal_anim0
.db %00010011
.db $13
brMetal7 ; metal_anim1
.db %00000010
.db $14
brMetal8 ; metal_anim2
.db %00000010
.db $15

brWood1 ; wood_bloc0 
.db %00000010
.db $16
brWood2 ; wood_bloc1
.db %00000010
.db $17
brWood3 ; wood_bloc2
.db %00000010
.db $18
brWood4 ; wood_tree0
.db %00000010
.db $19
brWood5 ; wood_tree1
.db %00000010
.db $1A
brWood6 ; wood_tree2 
.db %00000000
.db $1B
brWood7 ; wood_tree3
.db %00000010
.db $1C
brWood8 ; wood_tree4
.db %00000010
.db $1D
brWood9 ; wood_pic0
.db %00010001
.db $1E
brWoodA ; wood_pic1
.db %00010001
.db $1F
brWoodB ; wood_pic2
.db %00010001
.db $20

brFire1 ; fire_bloc0
.db %00000010
.db $21
brFire2 ; fire_bloc1
.db %00000010
.db $22
brFire3 ; fire_bloc2
.db %00000010
.db $23
brFire4 ; fire_bloc3
.db %00000010
.db $24
brFire5 ; fire_flam0
.db %00010001
.db $25
brFire6 ; fire_flam1
.db %00010011
.db $26
brFire7 ; fire_flam2
.db %00000010
.db $27
brFire8 ; fire_bloc_droite0
.db %00000011
.db $28
brFire9 ; fire_bloc_droite1
.db %00000010
.db $29
brFireA ; fire_bloc_droite2
.db %00000010
.db $2A
brFireB ; fire_bloc_gauche0
.db %00000011
.db $2B
brFireC ; fire_bloc_gauche1
.db %00000010
.db $2C
brFireD ; fire_bloc_gauche2
.db %00000010
.db $2D

brGut1 ; gut_rock0
.db %00000010
.db $2E
brGut2 ; gut_rock1
.db %00000010
.db $2F
brGut3 ; gut_rock2
.db %00000010
.db $30
brGut4 ; gut_rock3
.db %00000010
.db $31
brGut5 ; gut_plateforme0
.db %00000010
.db $32
brGut6 ; gut_mur_droite0
.db %00000010
.db $33
brGut7 ; gut_mur_gauche0
.db %00000010
.db $34
brGut8 ; gut_poutre0
.db %00000000
.db $35
brGut9 ; gut_block 
.db %00000010
.db $36
brGutA ; gut_poutre1
.db %00000000
.db $37
brGutB ; gut_pic0
.db %00010001
.db $38
brGutC ; gut_pic1
.db %00010001
.db $39
brGutD ; gut_pic2
.db %00010001
.db $3A

brCut1 ; cut_block0
.db %00000010
.db $3B
brCut2 ; cut_plateforme2
.db %00000010
.db $3C
brCut3 ; cut_mur_gauche0
.db %00000010
.db $3D
brCut4 ; cut_mur_droite0
.db %00000010
.db $3E
brCut5 ; cut_pointe0
.db %00010010
.db $3F
brCut6 ; cut_poutre0
.db %00000010
.db $40
brCut7 ; cut_plafond0
.db %00010010
.db $41
brCut8 ; cut_plateforme0
.db %00000010
.db $42
brCut9 ; cut_plafond1
.db %00000010
.db $43
brCutA ; cut_pic0
.db %00010001
.db $44
brCutB ; cut_pic1
.db %00010001
.db $45
brCutC ; cut_pic2
.db %00010001
.db $46

brElec1 ; elec_plateforme0
.db %00000010
.db $47
brElec2 ; elec_plateforme1
.db %00000010
.db $48
brElec3 ; elec_pointille0
.db %00000010
.db $49
brElec4 ; elec_reverse0
.db %00000010
.db $4A
brElec5 ; elec_plateforme2
.db %00000010
.db $4B
brElec6 ; elec_condensateur0 
.db %00000011
.db $4C
brElec7 ; elec_condensateur1
.db %00010011
.db $4D
brElec8 ; elec_condensateur2 
.db %00010011
.db $4E
brElec9 ; elec_veclair0
.db %00010011
.db $4F
brElecA ; elec_veclair1
.db %00010011
.db $50
brElecB ; elec_veclair2
.db %00010011
.db $51
brElecC ; elec_heclair0
.db %00010011
.db $52
brElecD ; elec_heclair1
.db %00010011
.db $53
brElecE ; elec_heclair2
.db %00010011
.db $54

brIce1 ; ice_bloc0
.db %00000010
.db $55
brIce2 ; ice_bloc1
.db %00000010
.db $56
brIce3 ; ice_bloc2
.db %00000010
.db $57
brIce4 ; ice_plafond0
.db %00010000
.db $58
brIce5 ; ice_sol_gauche0
.db %00000010
.db $59
brIce6 ; ice_sol_milieu0
.db %00000010
.db $5A
brIce7 ; ice_sol_milieur1
.db %00000010
.db $5B
brIce8 ; ice_sol_droite0
.db %00000010
.db $5C
brIce9 ; ice_pic0
.db %00010001
.db $5D
brIceA ; ice_pic1
.db %00010001
.db $5E
brIceB ; ice_pic2
.db %00010001
.db $5F

tileDataPlain:
tileData:
empty:
	.db 00000000b
	.db 00000000b
	.db 00000000b
	.db 00000000b
	.db 00000000b
	.db 00000000b
	.db 00000000b
	.db 00000000b

#include "ztilemap/all.inc"	;16 sprites/niveau

mechantsData:
;pas de gravité
.dw beakLeftSprites	;0
.dw beakRightSprites;1
.dw octopusSprites	;2
.dw bladerSprites	;3
.dw screwSprites	;4
.dw flyingSprites	;5
.dw diveSprites		;6
.dw explosionSprites
MECHANT_GRAVITE = $-mechantsData/2
;les méchants auxquels il faut ajouter de la gravité:
.dw fleaSprites		;7
.dw metSprites		;8
.dw spineSprites	;9
;début d'items
.dw healthSmall		;0
.dw healthLarge		;1
.dw energySmall		;2
.dw energyLarge		;3
.dw energyTank		;4
.dw oneUp			;5

beakLeftSprites:
;3 frames
.db 7
#include "zsprites/enemies/turretL1.bmp"
.db 7
#include "zsprites/enemies/turretL2.bmp"
.db 7
#include "zsprites/enemies/turretL3.bmp"

beakRightSprites:
;3 frames
.db 7
#include "zsprites/enemies/turretR1.bmp"
.db 7
#include "zsprites/enemies/turretR2.bmp"
.db 7
#include "zsprites/enemies/turretR3.bmp"

octopusSprites:
.db 8
#include "zsprites/enemies/octopus_battery1.bmp"
.db 8
#include "zsprites/enemies/octopus_battery2.bmp"
.db 8
#include "zsprites/enemies/octopus_battery3.bmp"

bladerSprites:
.db 12
#include "zsprites/enemies/blader1.bmp"
.db 12
#include "zsprites/enemies/blader2.bmp"

screwSprites:
.db 4
#include "zsprites/enemies/screw_bomber1.bmp"
.db 7
#include "zsprites/enemies/screw_bomber2.bmp"
.db 9
#include "zsprites/enemies/screw_bomber3.bmp"
.db 9
#include "zsprites/enemies/screw_bomber4.bmp"
.db 9
#include "zsprites/enemies/screw_bomber5.bmp"

flyingSprites:
.db 7
#include "zsprites/enemies/flying_shell1.bmp"
.db 10
#include "zsprites/enemies/flying_shell2.bmp"


fleaSprites:
.db 5
#include "zsprites/enemies/flea1.bmp"
.db 9
#include "zsprites/enemies/flea2.bmp"
.db 12
#include "zsprites/enemies/flea3.bmp"

metSprites:
.db 6
#include "zsprites/enemies/met1.bmp"
.db 8
#include "zsprites/enemies/met2.bmp"

spineSprites:
.db 6
#include "zsprites/enemies/spine1.bmp"
.db 6
#include "zsprites/enemies/spine2.bmp"

diveSprites:	;l'arme (missile) de Diveman
.db 7
#include "zsprites/boss/weaponDivemanL.bmp"
.db 8
divemanIcon:
#include "zsprites/boss/weaponDivemanUL.bmp"
.db 8
#include "zsprites/boss/weaponDivemanU.bmp"
.db 8
#include "zsprites/boss/weaponDivemanUR.bmp"
.db 7
#include "zsprites/boss/weaponDivemanR.bmp"
.db 8
#include "zsprites/boss/weaponDivemanDR.bmp"
.db 8
#include "zsprites/boss/weaponDivemanD.bmp"
.db 8
#include "zsprites/boss/weaponDivemanDL.bmp"

healthSmall:
.db 4
#include "zsprites/items/healthSmall1.bmp"
.db 4
#include "zsprites/items/healthSmall2.bmp"
healthLarge:
.db 8
#include "zsprites/items/healthLarge1.bmp"
.db 8
#include "zsprites/items/healthLarge2.bmp"
energySmall:
.db 5
#include "zsprites/items/energySmall1.bmp"
.db 5
#include "zsprites/items/energySmall2.bmp"
energyLarge:
.db 6
#include "zsprites/items/energyLarge1.bmp"
.db 6
#include "zsprites/items/energyLarge2.bmp"

energyTank:
.db 7
#include "zsprites/items/energyTank1.bmp"
.db 7
#include "zsprites/items/energyTank2.bmp"
oneUp:
.db 8
#include "zsprites/items/1up1.bmp"
.db 8
#include "zsprites/items/1up2.bmp"

explosionSprites:
.db 8
#include "zsprites/enemies/explosion1.bmp"
.db 8
#include "zsprites/enemies/explosion2.bmp"
.db 6
#include "zsprites/enemies/explosion3.bmp"

; h = 23, w = 3
megaman_sans_casque:
  .db 11111111b, 10001111b, 11111111b
  .db 11111000b, 00000000b, 01111111b
  .db 11110000b, 00000000b, 11111111b
  .db 11110000b, 00000000b, 00111111b
  .db 11100000b, 00000000b, 00011111b
  .db 11100001b, 00100010b, 00111111b
  .db 11110111b, 11110010b, 01111111b
  .db 11110101b, 00110010b, 01111111b
  .db 11110101b, 00111100b, 11111111b
  .db 11110111b, 11111100b, 11111111b
  .db 11100010b, 00001011b, 00111111b
  .db 11011101b, 11110111b, 11011111b
  .db 11011110b, 00001111b, 11011111b
  .db 10111101b, 11111101b, 11101111b
  .db 10110001b, 11111100b, 01101111b
  .db 10111001b, 11111100b, 11101111b
  .db 10111001b, 11111100b, 11101111b
  .db 11000101b, 11111101b, 00011111b
  .db 11111011b, 11111110b, 11111111b
  .db 11110111b, 11011111b, 01111111b
  .db 11100111b, 10101111b, 00111111b
  .db 10011111b, 01110111b, 11001111b
  .db 01111111b, 01110111b, 11110111b
  .db 00000000b, 01110000b, 00000111b
megaman_sans_casque_end:

bossWeapons:
#include "zsprites/boss/weaponCutman.inc"
weaponIcemanL:
.db 8			;hauteur de la balle
#include "zsprites/boss/weaponIcemanL1.bmp"	;anim 1
#include "zsprites/boss/weaponIcemanL2.bmp"	;anim 2
weaponIcemanR:
.db 8			;hauteur de la balle
#include "zsprites/boss/weaponIcemanR1.bmp"
#include "zsprites/boss/weaponIcemanR2.bmp"
weaponGutsmanL:
.db 14
#include "zsprites/boss/weaponGutsmanL.bmp"
weaponGutsmanR:
.db 14
#include "zsprites/boss/weaponGutsmanR.bmp"
weaponGutsmanBlock:
.db 7
#include "zsprites/boss/weaponGutsmanBlock.bmp"
weaponElecmanL:
.db 30
#include "zsprites/boss/weaponElecmanL1.bmp"
#include "zsprites/boss/weaponElecmanL2.bmp"
#include "zsprites/boss/weaponElecmanL3.bmp"
weaponElecmanR:
.db 30
#include "zsprites/boss/weaponElecmanR1.bmp"
#include "zsprites/boss/weaponElecmanR2.bmp"
#include "zsprites/boss/weaponElecmanR3.bmp"
weaponFiremanL:
.db 14			;hauteur de la balle
#include "zsprites/boss/weaponFiremanL1.bmp"
#include "zsprites/boss/weaponFiremanL2.bmp"
weaponFiremanR:
.db 14			;hauteur de la balle
#include "zsprites/boss/weaponFiremanR1.bmp"
#include "zsprites/boss/weaponFiremanR2.bmp"
weaponFiremanFlame:
.db 8
#include "zsprites/boss/weaponFiremanFlame1.bmp"
firemanIcon:
#include "zsprites/boss/weaponFiremanFlame2.bmp"
weaponMetalman:
.db 7
#include "zsprites/boss/weaponMetalman1.bmp"
#include "zsprites/boss/weaponMetalman2.bmp"
weaponWoodman:
.db 8
#include "zsprites/boss/weaponWoodman.bmp"
weaponDiveman:
.db 8
#include "zsprites/boss/weaponDivemanL8.bmp"
#include "zsprites/boss/weaponDivemanUL.bmp"
#include "zsprites/boss/weaponDivemanU.bmp"
#include "zsprites/boss/weaponDivemanUR.bmp"
#include "zsprites/boss/weaponDivemanR8.bmp"
#include "zsprites/boss/weaponDivemanDR.bmp"
#include "zsprites/boss/weaponDivemanD.bmp"
#include "zsprites/boss/weaponDivemanDL.bmp"
weaponElecmanSmall:
.db 16
#include "zsprites/boss/weaponElecmanSmall1.bmp"
#include "zsprites/boss/weaponElecmanSmall2.bmp"
#include "zsprites/boss/weaponElecmanSmall3.bmp"
weaponWalkerL:
.db 6
#include "zsprites/drwily/weaponWalkerL.bmp"
weaponWalkerR:
.db 6
#include "zsprites/drwily/weaponWalkerR.bmp"
weaponWalkerExplosionL:
.db 16
#include "zsprites/drwily/weaponWalkerExplosionL1.bmp"
#include "zsprites/drwily/weaponWalkerExplosionL2.bmp"
weaponWalkerExplosionR:
.db 16
#include "zsprites/drwily/weaponWalkerExplosionR1.bmp"
#include "zsprites/drwily/weaponWalkerExplosionR2.bmp"
weaponHoverChase:	;une bombe
.db 12
#include "zsprites/drwily/weaponHoverChase.bmp"
weaponMachineGun:
.db 1
.db %11000000

bossMugshots:
#include "zsprites/boss/mugshot_ice.bmp"
#include "zsprites/boss/mugshot_gut.bmp"
#include "zsprites/boss/mugshot_cut.bmp"
#include "zsprites/boss/mugshot_elec.bmp"
#include "zsprites/boss/mugshot_dive.bmp"
#include "zsprites/boss/mugshot_fire.bmp"
#include "zsprites/boss/mugshot_metal.bmp"
#include "zsprites/boss/mugshot_wood.bmp"
#include "zsprites/boss/mugshot_wily.bmp"

weaponIcons:
.dw weaponIcemanL+1+8	;1 = hauteur du sprite, 8 = première animation
.dw gutsmanIcon
.dw cutmanIcon
.dw elecmanIcon
.dw divemanIcon			;[tilemap/megaSprites.inc]
.dw firemanIcon			;[tilemap/megaSprites.inc]
.dw metalmanIcon
.dw weaponWoodman+1

gutsmanIcon:
#include "zsprites/icons/gutsmanIcon.bmp"
cutmanIcon:
#include "zsprites/icons/cutmanIcon.bmp"
elecmanIcon:
#include "zsprites/icons/elecmanIcon.bmp"
metalmanIcon:
#include "zsprites/icons/metalmanIcon.bmp"

;explosion pour quand on tire sur le boss
;bossHitSprite:
;#include "zsprites/boss/bossHitL.bmp"
;#include "zsprites/boss/bossHitR.bmp"

bossSpritesWily:
;hover1
.db $03,$1C,$00,$0C,$FA,$00,$04,$45,$00,$08,$D2,$00,$05,$5B
.db $00,$09,$00,$80,$10,$9E,$80,$0F,$8B,$00,$0B,$C5,$C0,$0F,$B1,$20
.db $08,$4E,$20,$0F,$B9,$20,$0F,$DF,$E0,$0F,$E7,$F8,$3F,$F8,$1C,$69
.db $7F,$EE,$7C,$FF,$EE,$69,$7F,$FC,$3F,$FF,$F0,$1F,$FF,$F0
;hover transform
 .db $03,$1C,$00,$0C,$FA,$00,$04,$45,$00,$08
 .db $D2,$00,$05,$5B,$00,$09,$00,$80,$10,$9E,$80,$0F,$8B,$00,$0B,$C5
 .db $C0,$0F,$B1,$20,$08,$4E,$20,$0F,$B9,$20,$0F,$DF,$E0,$0F,$E7,$F8
 .db $3F,$F8,$1C,$69,$7F,$EE,$7C,$FF,$EE,$69,$7F,$FC,$7F,$FF,$F0,$7F
 .db $FF,$F0,$52,$0A,$40,$3F,$87,$F0,$28,$45,$08,$74,$4E,$88,$77,$8E
 .db $F0,$2F,$85,$F0,$34,$46,$88,$23,$F4,$7E,$67,$CC,$F9,$FF,$FF,$FF
#include "zsprites/drwily/wily_1_24x40.bmp"		;walker
#include "zsprites/drwily/wily_3_24x40.bmp"		;leg raised
#include "zsprites/drwily/wily_2_24x41.bmp"		;stomp

W_HOVER	= 20
W_TRANS	= 30
W_WALKER= 40
W_LEG	= 40
W_STOMP	= 41

;offset size in bytes, sprite height
wilySpriteSize:
.dw 0 				\ .db	W_HOVER				;hover
.dw W_HOVER*3		\ .db	W_TRANS				;walker transformation
.dw (W_HOVER+W_TRANS)*3	\ .db W_WALKER			;walker
.dw (W_HOVER+W_TRANS+W_WALKER)*3 \ .db W_LEG	;raising leg to stomp/jump
.dw (W_HOVER+W_TRANS+W_WALKER+W_LEG)*3 \ .db W_STOMP	;stomped
