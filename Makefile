compile: bin/ bin/bios.bin

bin/:
	mkdir -p bin

bin/bios.bin:
	cd bios; make

clean:
	rm -r bin
