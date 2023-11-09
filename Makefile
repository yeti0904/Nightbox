compile: bin bin/bios.bin

bin:
	mkdir -p bin

bin/bios.bin:
	yeti-16 asm bios/bios.asm -o bin/bios.bin
