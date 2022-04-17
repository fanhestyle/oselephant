LDFLAGS=-m elf_i386
ASFLAGS=--32 -I include
CC=gcc
CFLAGS=-m32 -I include -c -o

kernel.bin:main.o print.o
	@ld $(LDFLAGS) -T kernel/kernel.lds -e main -o kernel.bin main.o print.o

main.o:	kernel/main.c
	@$(CC) $(CFLAGS) main.o kernel/main.c

print.o: lib/print.s
	@as $(ASFLAGS) lib/print.s -o $@

.PHONY:clean,all,loader,mbr,test

mbr:
	@as $(ASFLAGS) boot/mbr.s -o mbr.o
	@ld $(LDFLAGS) -T boot/linker.lds mbr.o -o mbr.bin

loader:
	@as $(ASFLAGS) boot/loader.s -o loader.o
	@ld $(LDFLAGS) -T boot/loaderlinker.lds  loader.o -o loader.bin

all:
	@bximage -mode="create" -hd=60M -imgmode="flat" -sectsize=512 -q hd60M.img
	@dd if=mbr.bin of=hd60M.img conv=notrunc
	@dd if=loader.bin of=hd60M.img seek=2 bs=512 conv=notrunc
	@dd if=kernel.bin of=hd60M.img seek=9 bs=512 count=200 conv=notrunc

clean:
	@$(RM) -rf *.o *.bin *.img *.ini *.txt *.lock kernel/*.bin kernel/*.o

test:
	make clean && make && make mbr && make loader && make all && bochs