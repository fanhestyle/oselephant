LDFLAGS= -m elf_i386 -lc --dynamic-linker /lib/ld-linux.so.2 

.PHONY: gas, nasm, clean

nasm:
	nasm -f elf nasm_src.asm
	ld $(LDFLAGS) nasm_src.o -o a.out

gas:
	as --32 gas_src.asm -o gas-src.o
	ld $(LDFLAGS) gas-src.o -o b.out

clean:
	$(RM) -rf *.out *.o