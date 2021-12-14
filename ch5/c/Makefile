CFLAGS=-m32 -c -o
CC=gcc

LDFLAGS=-T boot/mbr.lds -m elf_i386
ASFLAGS=--32 -I boot/include

kernel.bin: main.o
	@ld main.o -m elf_i386 -T kernel/kernel.lds -e main -o kernel.bin

main.o:	kernel/main.c
	@$(CC) $(CFLAGS) main.o kernel/main.c  

.PHONY: clean,mbr,loader

clean:
	@$(RM) -rf *.o kernel/*.bin  *.bin *.o kernel/*.o *.img *.ini *.txt *.lock

mbr:
	@as $(ASFLAGS) boot/mbr.asm -o mbr.o
	@ld $(LDFLAGS) mbr.o -o mbr.bin

loader:
	@as $(ASFLAGS) boot/loader.asm -o loader.o
	@ld -T boot/loader.lds -m elf_i386 loader.o -o loader.bin

all:
	@bximage -mode="create" -hd=60M -imgmode="flat" -sectsize=512 -q boot.img
	@dd if=mbr.bin of=boot.img conv=notrunc
	@dd if=loader.bin of=boot.img seek=2 bs=512 conv=notrunc
	@dd if=kernel.bin of=boot.img seek=9 bs=512 count=200 conv=notrunc
