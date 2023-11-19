compile: bin/ tools/bin/ bin/bios.bin tools/bin/fs
bios:    bin/ bin/bios.bin
tools:   tools/bin/ tools/bin/fs

bin/:
	mkdir -p bin

tools/bin/:
	mkdir -p tools/bin

bin/bios.bin: bios/bios.asm
	cd bios; make

tools/bin/fs: tools/fs/source/main.c
	cd tools/fs; make

clean:
	rm -r bin
