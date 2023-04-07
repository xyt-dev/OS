nasm -f bin mbr.asm -o mbr.bin
dd if=mbr.bin of=../bochs/disk1.img bs=512 count=1 conv=notrunc