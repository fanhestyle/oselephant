CFLAGS=-m32 -c -o
CC=gcc

kernel.bin: kernel/main.o
	ld kernel/main.o -m elf_i386 -Ttext 0xc0001500 -e main -o kernel.bin

main.o:	main.c
	$(CC) $(CFLAGS) kernel/main.o  kernel/main.c  

.PHONY: clean

clean:
	$(RM) -rf *.o kernel/*.bin  *.bin *.o kernel/*.o
