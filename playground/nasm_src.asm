section .data 
; Command table to store at most 
; 10 command line arguments 

cmd_tbl: 
%rep 10 
    dd 0 
%endrep 

section .text 
global _start 
_start: 
; Set up the stack frame 

mov ebp, esp 
; Top of stack contains the 
; number of command line arguments. 
; The default value is 1 
mov ecx, [ebp] 

; Exit if arguments are more than 10 
cmp ecx, 10 
jg _exit 

mov esi, 1 
mov edi, 0 
; Store the command line arguments 
; in the command table 

store_loop: 
    mov eax, [ebp + esi * 4] 
    mov [cmd_tbl + edi * 4], eax 
    inc esi 
    inc edi 
    loop store_loop 
    
    mov ecx, edi 
    mov esi, 0 
    extern puts

print_loop: 
; Make some local space 
    sub esp, 4 
; puts function corrupts ecx 
    mov [ebp - 4], ecx 
    mov eax, [cmd_tbl + esi * 4] 
    push eax 
    call puts 
    
    add esp, 4 
    mov ecx, [ebp - 4] 
    inc esi 
    loop print_loop 
    
    jmp _exit 
    
_exit: 
    mov eax, 1 
    mov ebx, 0 
    int 80h
