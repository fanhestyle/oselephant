
kernel.bin: main.o print.o
	@ld main.o print.o -m elf_i386 -Ttext 0xc0001500 -e main -o kernel.bin

print.o: lib/kernel/print.S
	@nasm -f elf -o print.o lib/kernel/print.S

main.o: kernel/main.c
	gcc -m32 -c -o $@ $^

.PHONY:clean, mbr, loader, all, build

clean:
	rm -rf *.bin *.o *.txt *.lock *.ini *.img

mbr:
	nasm -f bin -I ./boot/include/ -o mbr.bin ./boot/mbr.S

loader:
	nasm -f bin -I ./boot/include/ -o loader.bin ./boot/loader.S

all:
	@bximage -mode="create" -hd=60M -imgmode="flat" -sectsize=512 -q boot.img
	@dd if=mbr.bin of=boot.img conv=notrunc
	@dd if=loader.bin of=boot.img seek=2 bs=512 conv=notrunc
	@dd if=kernel.bin of=boot.img seek=9 bs=512 count=200 conv=notrunc

build:
	make clean && make && make mbr && make loader && make all && bochs



