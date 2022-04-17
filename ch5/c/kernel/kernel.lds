SECTIONS
{
    . = 0xc001500;
    .text : {*(.text)}
}

OUTPUT_FORMAT(elf32-i386)