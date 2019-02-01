all: MAIN

MAIN: main.bin
	bin2var main.bin MAIN.83p

main.bin: *.asm 
	spasm main.asm main.bin
clean:
	rm -f *.83p
	rm -f *.lst
	rm -f *.bin

.PHONY: all clean

