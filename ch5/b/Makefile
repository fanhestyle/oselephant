LDFLAGS=-T linker.lds -m elf_i386
ASFLAGS=--32 -I include

mbr.bin: mbr.o
	@ld $(LDFLAGS) $^ -o $@

mbr.o: mbr.asm
	@as $(ASFLAGS) $^ -o $@

.PHONY:clean,all,loader

loader:
	@as $(ASFLAGS) loader.asm -o loader.o
	@ld -T loaderlinker.lds -m elf_i386 loader.o -o loader.bin

all:
	@bximage -mode="create" -hd=60M -imgmode="flat" -sectsize=512 -q boot.img
	@dd if=mbr.bin of=boot.img conv=notrunc
	@dd if=loader.bin of=boot.img seek=2 bs=512 conv=notrunc

clean:
	@$(RM) -rf *.o *.bin *.img *.ini *.txt *.lock
