.code16

.section  .text

START_OF_CODE_SECTION: 
    movw $START_OF_CODE_SECTION, %ax

    movw $.mydata, %ax
    movw var1, %ax
    movw var2, %ax

label:
    jmp label


.section .data

//START_OF_DATA_SECTION:
    var1:
        .long 0x4
    var2:
        .word 0x99

