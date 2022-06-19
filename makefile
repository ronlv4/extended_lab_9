all: virus

obj/skeleton2.o: src/skeleton2.s
	nasm -f elf32 src/skeleton2.s -o obj/skeleton2.o

virus: obj/skeleton2.o
	ld -m elf_i386 obj/skeleton2.o -o bin/virus

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
