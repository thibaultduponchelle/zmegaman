all: OUTRO.8xp

OUTRO.8xp: outro.asm text.asm img.asm
	spasm outro.asm OUTRO.8xp -A -T

clean:
	rm -f *.8xp
	rm -f *.8xk
	rm -f *.lst
	rm -f *.bin

.PHONY: all clean

