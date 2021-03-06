;################ ZMEGAMAN #################
;###########################################
;#      M   M
;# zzzz MM MM  eee  ggg  aaa mm m   aaa nnn
;#   z  M M M e e  g  g a  a m m m a  a n  n
;#  z   M   M ee   g  g a  a m m m a  a n  n
;# zzzz M   M  eee  ggg  aaa m m m  aaa n  n
;#                    g
;#                  gg
;########### A game by and for #############
;########### the TI community! #############

.old $C001

start:
	ld a,(table_of_contents)
	cp 1
	 jr z,INTRODUCTION
	cp 2
	 jr z,HOW_TO_RUN
	cp 3
	 jr z,HOW_TO_PLAY
	cp 4
	 jr z,CONTROLS
	cp 5
	 jr z,REPORTING_BUGS
	cp 6
	 jr z,FINAL_NOTE
	jr EXIT

;#############################################################################################
INTRODUCTION:
#comment
 _____________________
[-- 1. INTRODUCTION --]

		Welcome to zMegaman! zMegaman is a game based off the classic Megaman series, written
	in z80 assembly for the 83+ and above calculators. Unfortunately due to the size of the
	program, it's currently --LIMITED TO THE 83+SE AND ABOVE--, but we're working on trying to
	get around this limitation and add 83+ support.

		We had two main motives for starting this project, the first being our wish to give
	something special (to us, at least!) back to the community, something people can enjoy,
	learn from, and use without any of the silly limitations you see people place on their projects.
	The second and most important motive is simply that coding in assembly is something we
	really enjoy and is something we feel really passionate about.

		This is a gift to you, the community! A gift to the community, from the community. And,
	as we'd like to include ourselves in that "community", this is at the same time a gift to
	ourselves! Therefore, we'd like to detach our names from this project and simply release it
	under the name "community". We hope you enjoy it and look forward to seeing any other uses
	you might find for it! Remember, this program is yours, everyone's, no one's!
#endcomment
	jr start

;#############################################################################################
HOW_TO_RUN:
#comment
 ___________________
[-- 2. HOW TO RUN --]

	WARNING: This program will currently not run on the regular 83+ due to its size. Once we
			 figure out a way around this we'll release an update. If you can help, please get
			 in touch ([z.oldsc001@gmail.com])!

	1.	Send ZMEGAMAN.8xp and ZMEGADAT.8xp to your calc. They should automatically get sent to
		archive. ZMEGADAT.8xp MUST be in archive. We'd recommend you keep ZMEGAMAN.8xp in archive,
		too, just in case of a crash.
	2.	Load up your favorite shell. Any shell that supports ion should work. Note however that
		zMegaman uses up a lot of the calculator's safeRAM and certain shells (like MirageOS) might
		be affected. If your shell experiences any problems, try quitting the shell and reloading.
	3.	Find zMegaman and run it. Because of zMegaman's large size it might take a few seconds for
		it to load. This is normal!
	4.	That's it, enjoy!
#endcomment
	jr start

;#############################################################################################
HOW_TO_PLAY:
#comment
 ____________________
[-- 3. HOW TO PLAY --]

		When you load the game the title screen will pop up. If you have a saved game, you'll
	be asked if you want to load it. Press [2nd] to load it or any other key to start a new game.
	Starting a new game won't erase a previous game save unless you save over it in the new game.

		After starting a new game or loading a saved game, the boss selection screen will show up.
	Use the arrows to select the boss level you want to play through and press [2nd]. There's no
	specific order to the levels, you'll find some are easier and some are more difficult. Also,
	don't forget that bosses have weaknesses (and strengths), if you're having trouble with a boss
	you might want to try coming back later with new weapons.

		Once you've chosen a level you'll be taken to that boss's stage. If you have any special
	weapons or energy tanks, you can press [Mode] to access the in-game menu to change your weapon
	or use an energy tank. You can also see the available energy left in all your weapons.

		Enjoy! :)
#endcomment
	jr start

;#############################################################################################
CONTROLS:
#comment
 _________________
[-- 4. CONTROLS --]

__Texts__
	[2nd] = Skip the text
	Any other key = Scroll through text more quickly

__Menu__
	Use arrows and [2nd] to choose a level.

__In Game__
	[<-] = Move left
	[->] = Move right
	[Alpha] = Jump (in weapon's menu it saves the game)
	[2nd] = Shoot
	[Mode] = Enter/exit weapon's menu
	[Y=] = Print life bar and weapon energy bar (if a special weapon is selected)
	[Alpha] + [Down] = slide

__Quitting__
	Pressing [Clear] in-game or at the stage select will exit (without saving) to the
	title screen. Press [Clear] again to exit the game. As the game is rather large,
	it may take a little while for the shell to copy the program back to memory. Turning
	off program writeback should make this process quicker.

__Other__
	Use walls to slow your fall!
	Jump off walls to reach otherwise unreachable places (have fun in fireman's stage)
#endcomment
	jr start

;#############################################################################################
REPORTING_BUGS:
#comment
 _______________________
[-- 5. REPORTING BUGS --]

		There are most certainly bugs left in this program, if you find any we'd appreciate it
	if you let us know. You can write us at [z.oldsc001@gmail.com]. If you can figure out a
	way to consistently trigger the bug, we'd appreciate it if you explained how to trigger it.
#endcomment
	jr start

;#############################################################################################
FINAL_NOTE:
#comment
 ___________________
[-- 6. FINAL NOTE --]

	Putting zMegaman together took a good deal of work, but we'd like to differentiate here between
	work and a job. Unlike a job, which is forced and inspired by economic (and other) reasons and
	tends to erase passions, our work on zMegaman was 100% inspired by love and passion. This is why
	zMegaman is free and open source: you don't put chains around that which you love. Let it live
	and grow freely (with or without you)!

	zMegaman, made with love,
	2012-2013

	Ignore copyright, ideas are free!
#endcomment
	jr start

;#############################################################################################
EXIT:
; ___________________
;[-- X. EXIT --]
;	If you want to get in touch with us for whatever reason (bugs, ideas/suggestions, questions about
;	the source, etc.):
;		z.oldsc001@gmail.com
	ret
