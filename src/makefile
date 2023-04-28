makedisk:
	nasm -f bin hellombr.asm -o hellombr.bin
	dd if=hellombr.bin of=../bochs/disk1.img bs=512 count=1 conv=notrunc