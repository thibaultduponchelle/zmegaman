all: clean MENU.83p

MENU.83p: main.bin
	bin2bin83 main.bin
	bin2var output.bin MAIN.83p
	
main.bin: main.asm
	spasm -T main.asm main.bin
	
clean:
	rm -f *.bin
	rm -f *.83p

.PHONY: all clean

