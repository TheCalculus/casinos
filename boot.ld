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
        . = 0x1be;
        SHORT(0xaa55)
    } = 0

    .text :
    {
        stage2.o(.text)
        stage2.o(.data)
    } = 0
}
