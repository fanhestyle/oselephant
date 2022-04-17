mbr.bin: mbr.o
	@ld -T mbr.lds -m elf_i386 mbr.o -o mbr.bin

mbr.o: mbr.s
	@as --32 mbr.s -o mbr.o

.PHONY:clean,all

all:
	@bximage -mode="create" -hd=60M -imgmode="flat" -sectsize=512 -q hd60M.img
	@dd if=mbr.bin of=hd60M.img conv=notrunc

clean:
	@$(RM) -rf *.o *.bin *.img *.txt