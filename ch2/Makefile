mbr.bin: mbr.o
	@ld -T linker.lds -m elf_i386 mbr.o -o mbr.bin

mbr.o: mbr.asm
	@as --32 mbr.asm -o mbr.o

.PHONY:clean,all

all:
	@bximage -mode="create" -hd=60M -imgmode="flat" -sectsize=512 -q boot.img
	@dd if=mbr.bin of=boot.img conv=notrunc

clean:
	@$(RM) -rf *.o *.bin *.img *.ini *.txt
