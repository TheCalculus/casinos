; the casinos boot sector
[org 0x7c00]
KERNEL_OFFSET equ 0x1000
    mov bp, 0x9000
    mov sp, bp

    mov bx, BOOT_MESSAGE
    call print_wnl
     
    mov bx, ENTER_16RM
    call print_wnl
     
    call os_boot
    call switch_pm

    jmp $ ; should never be here

%include "bs_print.s"
%include "bs_disk.s"
%include "bs_gdt.s"
%include "bs_enter32.s"
%include "bs_printpm.s"

[bits 16]

os_boot:
    mov [BOOT_DRIVE], dl

    ; kernel

    mov bx, KERNEL_OFFSET
    mov dh, 15
    mov dl, [BOOT_DRIVE]
 
    call disk_load

    xor ax, ax
    mov es, ax
    mov ds, ax

    ret

[bits 32]

BEGIN_PM:
    mov ebx, ENTER_32PM
    call print_pm

    call KERNEL_OFFSET

    jmp $

BOOT_MESSAGE: db "casinos: gamble with your hard drive!", 0
ENTER_16RM:   db "entered 16-bit real mode", 0
ENTER_32PM:   db "entered 32-bit protected mode", 0
BOOT_DRIVE:   db 0

times 510-($-$$) db 0
dw 0xaa55
