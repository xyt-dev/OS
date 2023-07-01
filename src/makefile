makedisk_MBR:
	nasm -I include -f bin MBR.asm -o MBR.bin
	nasm -I include -f bin loader.asm -o loader.bin
	dd if=MBR.bin of=../bochs/disk1.img bs=512 count=1 conv=notrunc
	dd if=loader.bin of=../bochs/disk1.img bs=512 count=4 seek=2 conv=notrunc
makedisk_hellombr:
	nasm -f bin hellombr.asm -o hellombr.bin
	dd if=hellombr.bin of=../bochs/disk1.img bs=512 count=1 conv=notrunc
run: 
	bochs -f ../bochs/bochs_mac.disk
