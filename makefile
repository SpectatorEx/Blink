RELEASE := bin/blink.com

compile:
	mkdir -p bin
	nasm -f bin src/main.asm -Isrc -o $(RELEASE)