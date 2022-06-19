all: virus

virus: obj/virus.o
	gcc -m32 -Wall -g obj/virus.o -o bin/virus

obj/virus.o: src/skeleton.s
	nasm -f elf src/skeleton.s -o obj/virus.o

clean:
	rm -rf bin/* obj/* list/*
