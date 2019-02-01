;########################################################
;# [megaScriptData.asm]
;#-------------------------------------------------------
;# ROUTINES CONTENUES:
;# AUCUNE !
;#-------------------------------------------------------
;# DONNEES CONTENUES:
;#-------------------------------------------------------
;#  Des données, constantes etc... pour les scripts
;#-------------------------------------------------------

; Never give up ...


END			= 0				;0
RUN			= END+1			;1
WALK		= RUN+1			;2
RUN_JUMP	= WALK+1		;3
WAIT		= RUN_JUMP+1	;4
SHOOT		= WAIT+1		;5
SHOOT_JUMP	= SHOOT+1		;6
THROW_LEFT	= SHOOT_JUMP+1	;7
TWO_BYTE	= THROW_LEFT	;
;début de 3 octets
MOVE_CAMERA	= TWO_BYTE+1	;8 0A
ONE_BYTE	= MOVE_CAMERA			;
;début d'un octet
OPEN_DOOR	= ONE_BYTE+1	;9	0B
SEAL_DOOR	= OPEN_DOOR+1	;10 0C
RET_CAMERA	= SEAL_DOOR+1	;11 0D
OPEN_MAP	= RET_CAMERA+1	;12 0E
ENTER_WILY	= OPEN_MAP+1	;13
KILL_ENEMIES= ENTER_WILY+1	;14

#define exit()				.db END
;2 octets
#define runForward(frames)	.db RUN,frames
#define walk(frames)		.db WALK,frames
#define runJump(frames)		.db RUN_JUMP,frames
#define wait(frames)		.db WAIT,frames
#define shoot(frames)		.db SHOOT,frames
#define shootJump(frames)	.db SHOOT_JUMP,frames
#define throwLeft(frames)	.db THROW_LEFT,frames
;3 octets
#define moveCamera(x,y)		.db MOVE_CAMERA,x,y		;combien de pixels à décaler l'écran
;1 octet
#define openDoor()			.db OPEN_DOOR
#define sealDoor()			.db SEAL_DOOR
#define returnCamera()		.db RET_CAMERA			;la caméra reviendra où elle était avant de se déplacer
#define openBossMap()		.db OPEN_MAP			;charger la carte du boss
#define enterWily()			.db ENTER_WILY
#define	killEnemies()		.db KILL_ENEMIES
scriptList:
.dw scriptRun			;1
.dw scriptWalk			;2
.dw scriptRunJump		;3
.dw scriptWait			;4
.dw scriptShoot			;5
.dw scriptShootJump		;6
.dw scriptThrowLeft		;7
;3 octets
.dw scriptMoveCamera	;8
;1 octet
.dw scriptOpenDoor		;9
.dw scriptSealDoor		;10
.dw scriptReturnCamera	;11
.dw scriptOpenBossMap	;12
.dw scriptEnterWily		;13
.dw scriptKillEnemies	;14

scriptTable:
.dw closeRoom			;0
.dw goToBossBattle		;1
.dw drWily				;2

closeRoom:
	killEnemies()		;1 octet
	runForward(20)		;2 octets
	runJump(24)			;2 octets
	wait(15)			;2 octets
closeRoomNoRun:
	killEnemies()		;1 octet
	moveCamera(-31,-20)	;3 octets en pixels (-4 * 8)
	wait(15)			;2 octets
	sealDoor()			;1 octet
	wait(30)			;2 octets
	returnCamera()		;1 octet
	exit()				;1 octet

goToBossBattle:
	openDoor()
	walk(12)
	openBossMap()
	exit()
drWily:
	openDoor()
	throwLeft(20)
	enterWily()
	wait(30)
;	openBossMap()
	exit()
