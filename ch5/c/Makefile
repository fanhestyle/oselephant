LDFLAGS=-T linker.lds -m elf_i386
ASFLAGS=--32 -I include
CC=gcc
CFLAGS=-m32 -c -o

kernel.bin:main.o
	@ld main.o -m elf_i386 -T kernel/kernel.lds -e main -o kernel.bin

main.o:	kernel/main.c
	@$(CC) $(CFLAGS) main.o kernel/main.c

mbr.bin: mbr.o
	@ld $(LDFLAGS) $^ -o $@

mbr.o: mbr.s
	@as $(ASFLAGS) $^ -o $@

.PHONY:clean,all,loader,mbr,test

mbr:
	@as $(ASFLAGS) mbr.s -o mbr.o
	@ld $(LDFLAGS) mbr.o -o mbr.bin

loader:
	@as $(ASFLAGS) loader.s -o loader.o
	@ld -T loaderlinker.lds -m elf_i386 loader.o -o loader.bin

all:
	@bximage -mode="create" -hd=60M -imgmode="flat" -sectsize=512 -q hd60M.img
	@dd if=mbr.bin of=hd60M.img conv=notrunc
	@dd if=loader.bin of=hd60M.img seek=2 bs=512 conv=notrunc
	@dd if=kernel.bin of=hd60M.img seek=9 bs=512 count=200 conv=notrunc

clean:
	@$(RM) -rf *.o *.bin *.img *.ini *.txt *.lock kernel/*.bin kernel/*.o

test:
	make clean && make && make mbr && make loader && make all && bochs