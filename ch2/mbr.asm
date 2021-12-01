.code16

movw %cs, %ax
movw %ax, %ds
movw %ax, %es
movw %ax, %ss
movw %ax, %fs
movw $0x7c00, %sp

/* IDT - 0x06
Parameters:
 AH = 0x06
 AL = 上卷行数(0表示全部)
 BH = 上卷行属性
 (CL,CH) = Window Left-Top(X,Y)
 (DL,DH) = Window Right-Bottom (X,Y)
  Return Value: none  
 */

 movw $0x600, %ax
 movw $0x700, %bx
 movw $0, %cx 
 movw $0x184f, %dx
 int $0x10 


movb $3, %ah 
movb $0, %bh
int $0x10


movw $message, %ax
movw %ax, %bp


movw $MSG_LEN, %cx
movw $0x1301, %ax
movw $0x2, %bx

int $0x10

jmp .

message:
    .ascii "1 MBR"
.equ MSG_LEN, .-message

.org 510
.word 0xaa55


