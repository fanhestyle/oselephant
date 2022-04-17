LDFLAGS=-T linker.lds -m elf_i386
ASFLAGS=--32 -I include


mbr.bin: mbr.o
	@ld $(LDFLAGS) $^ -o $@

mbr.o: mbr.s
	@as $(ASFLAGS) $^ -o $@

.PHONY:clean,all, loader

all:
	@bximage -mode="create" -hd=60M -imgmode="flat" -sectsize=512 -q hd60M.img
	@dd if=mbr.bin of=hd60M.img conv=notrunc
	@dd if=loader.bin of=hd60M.img seek=2 bs=512 conv=notrunc

loader:
	@as $(ASFLAGS) loader.s -o loader.o
	@ld -T loaderlinker.lds -m elf_i386 loader.o -o loader.bin

clean:
	@$(RM) -rf *.o *.bin *.img *.txt *.ini