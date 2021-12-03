.section .data 

// Command table to store at most 
// 10 command line arguments 

cmd_tbl: 
    .rept 10 
    .long 0 
    .endr 
    
.section .text 
.globl _start 
_start: 

// Set up the stack frame 
movl %esp, %ebp 

// Top of stack contains the 
// number of command line arguments. 
// The default value is 1 

movl (%ebp), %ecx 

// Exit if arguments are more than 10 

    cmpl $10, %ecx 
    jg _exit 

    movl $1, %esi 
    movl $0, %edi 

// Store the command line arguments 
// in the command table 

store_loop:
    movl (%ebp, %esi, 4), %eax 
    movl %eax, cmd_tbl( , %edi, 4) 
    incl %esi 
    incl %edi 
loop store_loop 

    movl %edi, %ecx 
    movl $0, %esi 
    
print_loop: 
    // Make some local space 
    subl $4, %esp 
    // puts functions corrupts ecx 
    movl %ecx, -4(%ebp) 
    movl cmd_tbl( , %esi, 4), %eax 
    pushl %eax 
    call puts 
    
    addl $4, %esp 
    movl -4(%ebp), %ecx 
    incl %esi 
    loop print_loop 
    
    jmp _exit 
_exit: 
    movl $1, %eax 
    movl $0, %ebx 
    int $0x80
