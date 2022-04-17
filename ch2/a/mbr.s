.code16

.section .text

movw %cs, %ax
movw %ax, %ds
movw %ax, %es
movw %ax, %fs
movw %ax, %gs
movw $0x7c00, %sp

movw $0x600, %ax
movw $0x700, %bx
movw $0x0, %cx
movw $0x184f, %dx
int $0x10

movb $0x3, %ah
movb $0x0, %bh
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
MSG_LEN = . - message

.org 510
.word 0xaa55
