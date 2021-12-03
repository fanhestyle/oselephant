.code16

movw %cs, %ax
movw %ax, %ds
movw %ax, %es
movw %ax, %ss
movw %ax, %fs

movw $0x7c00, %sp
movw $0xb800, %ax

//video memory section
movw %ax, %gs       

//清屏(上卷所有行)
movw $0x600, %ax
movw $0x700, %bx
movw $0, %cx
movw $0x184f, %dx
int $0x10

movb $'1', %gs:0x0
movb $0xA4, %gs:0x1
movb $' ', %gs:0x2
movb $0xA4, %gs:0x3
movb $'M', %gs:0x4
movb $0xA4, %gs:0x5
movb $'B', %gs:0x6
movb $0xA4, %gs:0x7
movb $'R', %gs:0x8
movb $0xA4, %gs:0x9

jmp .

.org 510
.word 0xaa55

