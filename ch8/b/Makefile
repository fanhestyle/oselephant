OBJS=main.o kernel.o print.o timer.o debug.o init.o interrupt.o 

kernel.bin: $(OBJS)
	@ld $^  -m elf_i386 -Ttext 0xc0001500 -e main -o kernel.bin

print.o: lib/kernel/print.s
	@nasm -f elf -o print.o lib/kernel/print.s

kernel.o: kernel/kernel.s
	@nasm -f elf  -o kernel.o $^

timer.o: device/timer.c
	@gcc -m32 -Ilib/kernel $^ -c  -fno-stack-protector -o $@	

debug.o: kernel/debug.c
	@gcc -m32 -Ilib/kernel $^ -c -fno-stack-protector -o $@
init.o: kernel/init.c
	@gcc -m32 -Ilib/kernel kernel/init.c -c  -fno-stack-protector -o init.o

interrupt.o:  kernel/interrupt.c
	@gcc -m32 -Ilib/kernel kernel/interrupt.c -c -fno-stack-protector -o interrupt.o

main.o: kernel/main.c
	@gcc -m32 -Ilib/kernel -c -fno-stack-protector -o $@ $^

.PHONY:clean, mbr, loader, all, build

clean:
	@rm -rf *.bin *.o *.txt *.lock *.ini *.img

mbr:
	@nasm -f bin -I ./boot/include/ -o mbr.bin ./boot/mbr.s

loader:
	@nasm -f bin -I ./boot/include/ -o loader.bin ./boot/loader.s

all:
	@bximage -mode="create" -hd=60M -imgmode="flat" -sectsize=512 -q boot.img
	@dd if=mbr.bin of=boot.img conv=notrunc
	@dd if=loader.bin of=boot.img seek=2 bs=512 conv=notrunc
	@dd if=kernel.bin of=boot.img seek=9 bs=512 count=200 conv=notrunc

build:
	@make clean && make && make mbr && make loader && make all && bochs



