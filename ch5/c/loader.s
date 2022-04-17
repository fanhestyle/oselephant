.code16
.include "boot.inc"

.section .text
LOADER_STACK_TOP = LOADER_BASE_ADDR
PDE_PTE_FLAG = PG_US_U | PG_RW_W | PG_P


//GDT Descriptor
GDT_BASE:  
    .long 0x0
    .long 0x0

CODE_DESC:
    .long 0x0000FFFF
    .long DESC_CODE_HIGH4

DATA_STACK_DESC:
    .long 0x0000FFFF
    .long DESC_DATA_HIGH4

//显存段的段基址是0xb8000
//显存段的段界限是 0xbffff-0xb8000 = 0x7fff 粒度是4k
//所以计算出的低位数字是 0x7fff/4k = 7
VIDEO_DESC:
    .long 0x80000007
    .long DESC_VIDEO_HIGH4

GDT_SIZE = .-GDT_BASE
GDT_LIMIT = GDT_SIZE - 1

.fill 60, 8, 0

//定义3个选择子
//相当于(CODE_DESC - GDT_BASE)/8 + TI_GDT + RPL0
.equ SELECTOR_CODE, (0x0001 << 3) + TI_GDT + RPL0
.equ SELECTOR_DATA, (0x0002 << 3) + TI_GDT + RPL0
.equ SELECTOR_VIDEO, (0x0003 << 3) + TI_GDT + RPL0


/*
保存内存容量（字节为单位），它相对于文件头的偏移是0x200 字节
我们的loader.bin会被加载在内存中的 0x900处，因此这个
total_mem_bytes加载之后的内存地址是 0x900 + 0x200 = 0xb00
*/
total_mem_bytes:
    .long 0


gdt_ptr:
    .word GDT_LIMIT
    .long GDT_BASE


//用来存储 0x15号中断获取的内存地址信息（0x15中的E820号中断得到的结果是一个大的结构体）
//因此预留一定空间来存储（为什么留244？完全是强迫症为了凑整，让loader_start地址从一个整16倍数地址开始）
ards_buf:
    .fill 244

//保存0x15号中断E820号中断返回结构体的个数
ards_nr:
    .word 0


loader_start:
   xorl %ebx, %ebx
   movl $0x534d4150, %edx
   movw $ards_buf, %di

//调用中断0x15中e820号中断获取内存
e820_mem_get_loop:
    movl $0x0000e820, %eax
    movl $20, %ecx
    int $0x15
    jc e820_failed_so_try_e801

    addw %cx, %di
    incw ards_nr

    cmpl $0, %ebx
    jnz e820_mem_get_loop

    movw ards_nr, %cx
    movl $ards_buf, %ebx
    xorl %edx,%edx

find_max_mem_area:
    movl (%ebx), %eax
    addl 8(%ebx), %eax
    addl $20, %ebx
    cmpl %eax, %edx
    jge next_ards
    movl %eax, %edx
next_ards:
    loop find_max_mem_area
    jmp mem_get_ok

e820_failed_so_try_e801:
    movw $0xe801, %ax
    int $0x15
    jc e801_failed_so_try88

    movw $0x400, %cx
    mulw %cx
    shll $16, %edx
    andl $0x0000FFFF, %eax
    orl %eax, %edx
    addl $0x100000, %edx
    movl %edx, %esi

    xorl %eax, %eax
    movw %bx, %ax
    movl $0x10000, %ecx
    mull %ecx
    addl %eax, %esi
    movl %esi, %edx
    jmp mem_get_ok

e801_failed_so_try88:
    movb $0x88, %ah
    int $0x15
    jc err_hlt
    andl $0x0000FFFF, %eax

    movw $0x400, %cx
    mulw %cx
    shll $16, %edx
    orl %eax, %edx
    addl $0x100000, %edx

mem_get_ok:
    movl %edx, total_mem_bytes


//开启A20地址线

inb $0x92, %al
orb $0x2, %al
outb %al, $0x92

//加载GDT
lgdt gdt_ptr

//开启保护模式标记
movl %cr0, %eax
orl $0x1, %eax
movl %eax, %cr0

ljmp $SELECTOR_CODE, $p_mode_start

err_hlt:
    hlt

.code32

p_mode_start:
    movw $SELECTOR_DATA, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %ss
    movl $LOADER_STACK_TOP, %esp
    movw $SELECTOR_VIDEO, %ax
    movw %ax, %gs

/*
加载kernel
备注：kernel首先被加载到0x70000的地址处，之后
将真正的内核运行内容（从ELF文件中提取的Program段）拷贝到0x1500的地址处，
加载kernel发生在开启分页模式之前
（也可以放在开启页后加载），初始化内核的工作发生在开启分页之后，因此
虚拟地址是 0xc0001500
*/

//扇区9
movl $KERNEL_START_SECTOR, %eax
//拷贝的起始内存地址
movl $KERNEL_BIN_BASE_ADDR, %ebx

//kernel的总大小小于200个扇区，拷贝的时候把多余部分拷贝过去不影响
//我们kernel的功能，只要kernel拷全了就行，这里主要是防止以后经常
//修改这写代码而设置较大的值（随着开发进行内核会逐渐变大，但是最后的
//完整代码也不会超过200个扇区的大小）
movl $200, %ecx

//调用磁盘拷贝函数
call rd_disk_m_32


call setup_page

//从GDT寄存器把值写回gdt_ptr内存处，为了是修改它并重新加载
sgdt gdt_ptr

//修改gdt描述符中视频段描述符的段基址+0xc0000000
movl (gdt_ptr+2), %ebx
//视频段是第3个段描述符，每个描述符是8字节，故0x18
//段描述符的高4个字节的最高位是段基址的24~31位，因此
//[ebx+0x18+4]
orl $0xc0000000, 0x1c(%ebx)

//将gdt的基址加上0xc0000000
addl $0xc0000000, (gdt_ptr+2)

addl $0xc0000000, %esp

//设置页目录表到cr3寄存器
movl $PAGE_DIR_TABLE_POS, %eax
movl %eax, %cr3

movl %cr0, %eax
orl $0x80000000, %eax
movl %eax, %cr0

lgdt gdt_ptr

movb $'V', %gs:(160)
movb $'i', %gs:(162)
movb $'r', %gs:(164)
movb $'t', %gs:(166)
movb $'u', %gs:(168)
movb $'a', %gs:(170)
movb $'l', %gs:(172)

/*
此时不刷新流水线也没问题
由于一直处在32位下,原则上不需要强制刷新,经过实际测试没有以下这两句也没问题.
*/
ljmp $SELECTOR_CODE, $enter_kernel


enter_kernel:
    movb $'k', %gs:(320) 
    movb $'e', %gs:(322) 
    movb $'r', %gs:(324) 
    movb $'n', %gs:(326) 
    movb $'e', %gs:(328) 
    movb $'l', %gs:(330) 

    movb $'w', %gs:(480) 
    movb $'h', %gs:(482) 
    movb $'i', %gs:(484) 
    movb $'l', %gs:(486) 
    movb $'e', %gs:(488) 
    movb $'(', %gs:(490)  
    movb $'1', %gs:(492)  
    movb $')', %gs:(494)  
    movb $';', %gs:(496)


    //调用提取kernel的代码
    call kernel_init
    //初始化栈顶指针
    movl $0xc009f00, %esp
    //跳转到入口点
    jmp KERNEL_ENTRY_POINT


.type kernel_init, @function
kernel_init:
    xorl %eax,%eax
    xorl %ebx,%ebx
    xorl %ecx, %ecx
    xorl %edx,%edx

    movw KERNEL_BIN_BASE_ADDR + 42, %dx
    movl KERNEL_BIN_BASE_ADDR + 28, %ebx

    addl $KERNEL_BIN_BASE_ADDR, %ebx
    movw KERNEL_BIN_BASE_ADDR + 44, %cx

    //处理每一个段（因为段才是可以运行的程序或使用的数据）
    each_segment:
    cmpb $PT_NULL, (%ebx)
    je PTNULL

    pushw 16(%ebx)
    movl 4(%ebx), %eax
    add $KERNEL_BIN_BASE_ADDR, %eax
    pushl %eax
    pushw 8(%ebx)
    call mem_cpy
    add $12, %esp

PTNULL:
    add %edx, %ebx
    loop each_segment
    ret

.type mem_cpy, @function
mem_cpy:
    cld
    pushl %ebp
    movl %esp, %ebp
    pushl %ecx
    movl 8(%ebp), %edi
    movl 12(%ebp), %esi
    movl 16(%ebp), %ecx
    rep movsb

    pop %ecx
    pop %ebp
    ret


//创建页目录及页表
.type setup_page, @function
setup_page:

//页目录表设置的物理地址是 PAGE_DIR_TABLE_POS
//即 1M内存之后的下一个字节 0xFFFFF + 1
//清空页目录表

movl $4096, %ecx
movl $0, %esi

clear_page_dir_table:
    movb $0, PAGE_DIR_TABLE_POS(,%esi)
    incl %esi
    loop clear_page_dir_table

//创建PDE
//ebx初始化是供后续PTE使用
movl $PAGE_DIR_TABLE_POS, %eax
addl $0x1000, %eax
movl %eax, %ebx

orl $PDE_PTE_FLAG, %eax
movl %eax, (PAGE_DIR_TABLE_POS)
movl %eax, (PAGE_DIR_TABLE_POS+0xc00)

subl $0x1000, %eax
//让目录项的最后一个指向目录表自身
//这么做有特殊的用途
movl %eax, (PAGE_DIR_TABLE_POS+4092)


//创建PTE
    movl $256, %ecx
    movl $0, %esi
    movl $PDE_PTE_FLAG, %edx

create_pte:
    movl %edx, (%ebx,%esi,4)
    addl $4096, %edx
    incl %esi
    loop create_pte

//把剩下的操作系统页目录项填充满
    movl $PAGE_DIR_TABLE_POS, %eax
    addl $0x2000, %eax
    or $PDE_PTE_FLAG, %eax
    movl PAGE_DIR_TABLE_POS, %ebx
    movl $254, %ecx
    movl $769, %esi

create_kernel_pde:
    movl %eax, (%ebx,%esi,4)
    inc %esi
    addl $0x1000, %eax
    loop create_kernel_pde

    ret


.type rd_disk_m_32, @function
/*
rd_disk_m_32
读取硬盘n个扇区到指定的内存地址
eax = LBA扇区号
ebx = 将数据写入的内存地址
ecx = 读取的扇区数
*/

rd_disk_m_32:
    movl %eax, %esi
    movw %cx, %di

    //端口0x1f2 给出读取的扇区数

    movw $0x1f2, %dx
    movb %cl, %al
    out %al, %dx

    movl %esi, %eax

//0-7位写入0x1f3端口

    movw $0x1f3, %dx
    out %al, %dx
    
//8-15位写入0x1f4端口
    movb $8, %cl
    shr %cl, %eax
    movw $0x1f4, %dx
    out %al, %dx

// 16-23

    shr %cl, %eax
    movw $0x1f5, %dx
    outb %al, %dx


// 24-27

    shr %cl, %eax
    and $0x0f, %al
    or $0xe0, %al
    movw $0x1f6, %dx
    out %al, %dx

    movw $0x1f7, %dx
    movb $0x20, %al
    out %al, %dx

not_ready:
    nop
    in %dx, %al
    and $0x88, %al
    cmp $0x8, %al
    jnz not_ready

    movw %di, %ax
    movw $256, %dx
    mul %dx
    movw %ax, %cx

    movw $0x1f0, %dx

go_on_read:
    in %dx, %ax
    movw %ax, (%ebx)
    addl $2, %ebx
    loop go_on_read

    ret