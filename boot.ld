INPUT(boot.o stage2.o)
OUTPUT(boot.bin)
OUTPUT_FORMAT(binary)
ENTRY(_start)

SECTIONS
{
    . = 0x7c00;

    .boot (READONLY) : ALIGN(510) {
        _BOOT_START_ = .;
        *(.text)
        *(.data)
        _BOOT_END_ = .;
    }

     . += (0x7c00 + 510) - .;

    .magic : {
        SHORT(0xaa55)
    }

    . += (0x7c00 + 512) - .;

    .stage2 (READONLY) : {
        _STAGE2_START_ = .;
        *(.text)
        *(.data)
        _STAGE2_END_ = .;
    }
}
