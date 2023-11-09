compile: bin bin/bios.bin

bin:
	mkdir -p bin

bin/bios.bin: bios/bios.asm
	yeti-16 asm bios/bios.asm -o bin/bios.bin

clean:
	rm -r bin
