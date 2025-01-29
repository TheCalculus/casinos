ENTRY(_start)
OUTPUT_FORMAT(binary)

SECTIONS
{
    . = 0x7c00;

    .boot : AT(0)
    {
        _sboot = .;
        build/boot.o(.text)
        build/boot.o(.data)
        . = 510;
        SHORT(0xaa55)
    } = 0

    . = 0x1000;

    .stage2 : AT(512)
    {
        _sboot2 = .;
        build/stage2.o(.text)
        build/stage2.o(.data)
        build/stage2.o(.rodata)
    } = 0

    /DISCARD/ :
    {
        *(.bss)
        *(.eh_frame)
        *(.rela.eh_frame)
        *(.comment)
        *(.note.gnu.property)
        *(.note.GNU-stack)
        *(.dynamic)
    }
}
