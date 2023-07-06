default: compile_x86gcc link_elf
compile_x86gcc:
	x86gcc -c -o main.o main.c -m32
link_elf:
	x86ld main.o -Ttext 0xc0001500 -e main -o kernel.bin -m elf_i386

#link_lld:
#	ld -no_pie -segalign 1 main.o -arch i386 -segaddr __TEXT 0xc0001300 -e _main -o kernel.bin -static 
#compile_clang:
	# clang -c main.c -o main.o -arch i386
