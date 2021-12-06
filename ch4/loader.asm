.code16

.include "boot.inc"

.section .text

LOADER_STACK_TOP = LOADER_BASE_ADDR

jmp loader_start

//GTD Descriptor

GDT_BASE:  
    .long 0x0
    .long 0x0

CODE_DESC:
    .long 0x0000FFFF
    .long DESC_CODE_HIGH4

DATA_STACK_DESC:
    .long 0x0000FFFF
    .long DESC_DATA_HIGH4

VIDEO_DESC:
    .long 0x80000007
    .long DESC_VIDEO_HIGH4

.equ GDT_SIZE, .-GDT_BASE
.equ GDT_LIMIT, GDT_SIZE - 1

.fill 60, 8, 0

.equ SELECTOR_CODE, (0x0001 << 3) + TI_GDT + RPL0
.equ SELECTOR_DATA, (0x0002 << 3) + TI_GDT + RPL0
.equ SELECTOR_VIDEO, (0x0003 << 3) + TI_GDT + RPL0

gdt_ptr:
    .word GDT_LIMIT
    .long GDT_BASE

loadermsg:
    .ascii "2 loader in real."
.equ MSG_SIZE, .-loadermsg


loader_start:

//调用BIOS打印字符串例程 INT 0x10, 功能号 0x13

movw $LOADER_BASE_ADDR, %sp  
movw $loadermsg, %bp
movw $MSG_SIZE , %cx
movw $0x1301, %ax
movw $0x001f, %bx
movw $0x1800, %dx
int $0x10

//准备进入保护模式
//步骤：
//  1. 打开A20
//  2. 加载gdt
//  3. cr0寄存器第1位置为1

inb $0x92, %al
orb $0x2, %al
outb %al, $0x92

lgdt gdt_ptr

movl %cr0, %eax
or $0x1, %eax
movl %eax, %cr0

ljmp $SELECTOR_CODE, $p_mode_start

.code32
p_mode_start:
    movw $SELECTOR_DATA, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %ss
    movl $LOADER_STACK_TOP, %esp
    movw $SELECTOR_VIDEO, %ax
    movw %ax, %gs

    movb $'P', %gs:160

    jmp .







