LDFLAGS=-T linker.lds -m elf_i386
ASFLAGS=--32 -I include

mbr.bin: mbr.o
	
.PHONY:clean,all,loader

loader:
	nasm -I include/ -o mbr.bin mbr.s 
	nasm -I include/ -o loader.bin loader.s

all:
	@bximage -mode="create" -hd=60M -imgmode="flat" -sectsize=512 -q boot.img
	@dd if=mbr.bin of=boot.img conv=notrunc
	@dd if=loader.bin of=boot.img seek=2 bs=512 conv=notrunc

clean:
	@$(RM) -rf *.o *.bin *.img *.ini *.txt
