; the casinos boot sector

[org 0x7c00]

call os_boot
call switch_pm

jmp $

%include "bs_print.s"
%include "bs_disk.s"
%include "bs_gdt.s"
%include "bs_enter32.s"
%include "bs_printpm.s"

[bits 16]

os_boot:
    mov bx, BOOT_MESSAGE
    call print
    call print_nl
 
    mov bx, ENTER_16RM
    call print
    call print_nl
   
    mov [BOOT_DRIVE], dl

    xor ax, ax
    mov es, ax
    mov ds, ax
    
    mov bp, 0x8000
    mov ss, ax
    mov sp, bp

;   mov bx, 0x9000
;   mov dh, 5
;   mov dl, [BOOT_DRIVE]
;
;   call disk_load

    ret

[bits 32]

BEGIN_PM:
    mov ebx, ENTER_32PM
    call print_pm

    jmp $

BOOT_MESSAGE: db "casinos: gamble with your hard drive!", 0
ENTER_16RM:   db "entered 16-bit real mode", 0
ENTER_32PM:   db "entered 32-bit protected mode", 0
BOOT_DRIVE:   db 0

times 510-($-$$) db 0
dw 0xaa55

; times 256 dw 0x1234
; times 256 dw 0x5678
