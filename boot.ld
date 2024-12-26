/* ENTRY(_start) */
TARGET(binary)
OUTPUT_FORMAT(elf32-i386)

SECTIONS
{
    . = 0x7c00;
    .boot : AT(0x7c00) SUBALIGN(4)
    {
        boot.o(.text)
        boot.o(.*)
    }
}
