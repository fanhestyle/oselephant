[bits 16]

section code:

mov ax, $$
mov ax, section.data.start   ;section.code.start
mov ax, [var1]
mov ax, [var2]
label:jmp label

section data:

var1 dd 0x4
var2 dw 0x99