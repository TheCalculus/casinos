ENTRY(_start)
OUTPUT_FORMAT(binary)

SECTIONS
{
    . = 0x7c00;

    .boot :
    {
        _sboot = .;
        build/boot.o(.text)
        build/boot.o(.data)
        . = 510;
        SHORT(0xaa55)
        _eboot = .;
    } = 0

    . = 0x7e00;

    .stage2 :
    {
        _sboot2 = .;
        build/stage2.o(.text)
        build/stage2.o(.data)
        build/stage2.o(.rodata)
        _eboot2 = .;
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
