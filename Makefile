compile: bin/ bin/bios.bin

bin/:
	mkdir -p bin

bin/bios.bin: bios/bios.asm
	cd bios; make

clean:
	rm -r bin
