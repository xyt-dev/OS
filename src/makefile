makedisk_bochs:
	nasm -I include -f bin MBR.asm -o MBR.bin
	nasm -I include -f bin loader.asm -o loader.bin
	dd if=MBR.bin of=../bochs/disk1.img bs=512 count=1 conv=notrunc
	dd if=loader.bin of=../bochs/disk1.img bs=512 count=4 seek=2 conv=notrunc
	#kernel:
	x86gcc -c -o kernel/main.o kernel/main.c -m32
	x86ld kernel/main.o -Ttext 0xc0001500 -e main -o kernel/kernel.bin -m elf_i386
	dd if=kernel/kernel.bin of=../bochs/disk1.img bs=512 count=200 seek=9 conv=notrunc
run: 
	bochs -f ../bochs/bochs_mac.disk

##############################################################################

makedisk_hellombr:
	nasm -f bin hellombr.asm -o hellombr.bin
	dd if=hellombr.bin of=../bochs/disk1.img bs=512 count=1 conv=notrunc

##############################################################################

makedisk_qemu:
	nasm -I include -f bin MBR.asm -o MBR.bin
	nasm -I include -f bin loader.asm -o loader.bin
	dd if=MBR.bin of=../qemu/xy6.img bs=512 count=1 conv=notrunc
	dd if=loader.bin of=../qemu/xy6.img bs=512 count=4 seek=2 conv=notrunc
	#kernel:
	x86gcc -c -o kernel/main.o kernel/main.c -m32
	x86ld kernel/main.o -Ttext 0xc0001500 -e main -o kernel/kernel.bin -m elf_i386
	dd if=kernel/kernel.bin of=../qemu/xy6.img bs=512 count=200 seek=9 conv=notrunc
run_qemu:
	qemu-i386 -m 32 -vga cirrus -drive file=../qemu/xy6.img,format=raw,index=0 -d int -no-reboot
