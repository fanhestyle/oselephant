.code16
.section .text
START_OF_TEXT:
    movw $START_OF_TEXT, %ax
    movw %ax, %ds
    movw var, %ax
label:
    movw ., %ax
    jmp label

var:
.word 0x99

