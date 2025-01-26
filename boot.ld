INPUT(boot.o stage2.o)
ENTRY(_start)
OUTPUT_FORMAT(binary)
OUTPUT(boot.bin)

SECTIONS
{
    . = 0x7c00;

    .boot :
    {
        _sboot = .;
        boot.o(.text)
        boot.o(.data)
        . = 510;
        SHORT(0xaa55)
        _eboot = .;
    } = 0

    . = 0x7e00;

    .stage2 :
    {
        _sboot2 = .;
        stage2.o(.text)
        stage2.o(.data)
        stage2.o(.rodata)
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
