all: clean skel

obj/skel.o: src/skel.s
	nasm -f elf32 -g src/skel.s -o obj/skel.o

skel: obj/skel.o
	ld -m elf_i386 obj/skel.o -o bin/virus

.PHONY: clean
clean:
	rm -rf obj/* bin/* list/*


#all: clean virus run
#
#virus: obj/virus.o
#	ld -m elf_i386 obj/virus.o -o bin/virus
#	gcc -m32 -Wall -g obj/virus.o -o bin/virus
#
#obj/virus.o: src/skeleton.s
#	nasm -f elf -g src/skeleton.s -o obj/virus.o

#run:
#	./bin/virus
#
#clean:
#	rm -rf bin/* obj/* list/*
