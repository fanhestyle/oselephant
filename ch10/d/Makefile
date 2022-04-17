LDFLAGS=-m elf_i386
ASFLAGS=--32 -Iinclude
CC=gcc
CFLAGS=-m32 -Iinclude  -fno-stack-protector -c -o

OBJS=main.o kernel.o interrupt.o init.o print.o timer.o debug.o string.o bitmap.o memory.o thread.o list.o switch.o sync.o console.o keyboard.o

kernel.bin:$(OBJS)
	@ld $(LDFLAGS) -T kernel/kernel.lds -e main -o $@ $^

main.o:	kernel/main.c
	@$(CC) $(CFLAGS) $@ $^

print.o: lib/print.s
	@as $(ASFLAGS) $^ -o $@

timer.o: lib/timer.c
	@$(CC) $(CFLAGS) $@ $^	

debug.o: lib/debug.c
	@$(CC) $(CFLAGS) $@ $^	

string.o: lib/string.c
	@$(CC) $(CFLAGS) $@ $^	

bitmap.o: lib/bitmap.c
	@$(CC) $(CFLAGS) $@ $^	

thread.o: lib/thread.c
	@$(CC) $(CFLAGS) $@ $^	

list.o: lib/list.c
	@$(CC) $(CFLAGS) $@ $^	

keyboard.o: lib/keyboard.c
	@$(CC) $(CFLAGS) $@ $^	

init.o: kernel/init.c
	@$(CC) $(CFLAGS) $@ $^

interrupt.o: kernel/interrupt.c
	@$(CC) $(CFLAGS) $@ $^

memory.o:	kernel/memory.c
	@$(CC) $(CFLAGS) $@ $^

sync.o:	lib/sync.c
	@$(CC) $(CFLAGS) $@ $^

console.o:	lib/console.c
	@$(CC) $(CFLAGS) $@ $^

kernel.o: kernel/kernel.s
	@as $(ASFLAGS) $^ -o $@

switch.o: kernel/switch.s
	@as $(ASFLAGS) $^ -o $@

.PHONY:clean,all,loader,mbr,test,min

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

min:
	make && make mbr && make loader && make all && bochs
