all: INTRO.8xp

INTRO.8xp: intro.asm
	spasm intro.asm INTRO.8xp -A -T

clean:
	rm -f *.8xp
	rm -f *.8xk
	rm -f *.lst
	rm -f *.bin

.PHONY: all clean

