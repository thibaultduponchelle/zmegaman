# Some things are unused here
# We didn't use the 8xk stuff which are probably not working
# zmegaman is full of smc, conert it to app var is hard
# Now type make, and don't worry about the warning (size, start adress)

all: clean AAA.8xp BBB.8xp CCC.8xp

AAA.8xp: 
	spasm main.asm AAA.8xp -A -T

BBB.8xp:
	spasm main2.asm BBB.8xp -A -T

CCC.8xp:
	spasm main3.asm CCC.8xp -A -T

clean:
	rm -f *.8xp
	rm -f *.8xk
	rm -f *.lst
	rm -f *.bin

.PHONY: all clean

