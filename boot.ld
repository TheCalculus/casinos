ENTRY(_start)
OUTPUT_FORMAT(elf32-i386)
INPUT(boot.o)
OUTPUT(boot.elf)
TARGET(binary)

SECTIONS
{
    . = 0x7c00;

    .boot (READONLY) : ALIGN(510) {
        _BOOT_START_ = .;
        *(.text)
        _BOOT_END_ = .;
    }

     . += (0x7c00 + 510) - .;

    .magic : {
        SHORT(0xaa55)
    }
}
