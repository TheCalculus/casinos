INPUT(boot.o stage2.o)
OUTPUT(boot.bin)
OUTPUT_FORMAT(binary)
ENTRY(_start)

SECTIONS
{
    . = 0x7c00;

    .text :
    {
        boot.o(.text)
        boot.o(.data)
        . = 510;
        SHORT(0xaa55)
        . = 512;
        stage2.o(.text)
        stage2.o(.data)
    } = 0

    /DISCARD/ :
    {
        *(.bss)
        *(.rodata)
        *(.eh_frame)
        *(.rela.eh_frame)
        *(.comment)
        *(.note.gnu.property)
        *(.note.GNU-stack)
        *(.dynamic)
    }
}
