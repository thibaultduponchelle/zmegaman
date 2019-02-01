# Some things are unused here
# We didn't use the 8xk stuff which are probably not working
# zmegaman is full of smc, conert it to app var is hard
# Now type make, and don't worry about the warning (size, start adress)

all: clean ZMEGAMAN.8xp ZMEGADAT.8xp LAUNCHER.8xp #MEGAMAN.8xk 

app: *.asm lib/*.asm tilemap/*.inc
	spasm megaMan.asm MEGAMAN.8xk

archive: ZMEGAMAN.8xp ZMEGADAT.8xp
	python archive.py

MEGAMAN.8xk: megaman.bin
	echo `bin2intelhex < megaman.bin` >>  megaman.hex
	rabbitsign -g -k 0104.key megaman.hex

ZMEGAMAN.8xp: LAUNCHER.8xp
	spasm megaMan.asm ZMEGAMAN.8xp -A -T

ZMEGADAT.8xp:
	spasm megaLevels.asm ZMEGADAT.8xp -A -T

LAUNCHER.8xp: 
	spasm launcher.asm LAUNCHER.8xp -A -T
	
megaman.bin: *.asm lib/*.asm tilemap/*.inc
	spasm megaMan.asm megaman.bin -T

clean:
	rm -f *.8xp
	rm -f *.8xk
	rm -f *.lst
	rm -f *.bin

.PHONY: all clean

