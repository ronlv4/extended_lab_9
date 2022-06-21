all: virus

virus: obj/virus.o
	ld  -g -m elf_i386 -g obj/virus.o -o bin/virus

obj/virus.o: src/virus.s
	nasm -g -f elf32 -w+all -o obj/virus.o src/virus.s
	nasm -g -f elf32 -l list/virus.l src/virus.s

.PHONY: clean
clean:
	rm -rf bin/* list/* obj/*