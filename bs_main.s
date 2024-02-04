; the casinos boot sector

[org 0x7c00]

call os_boot
call switch_pm

%include "bs_print.s"
%include "bs_disk.s"
%include "bs_gdt.s"
%include "bs_enter32.s"
%include "bs_printpm.s"

[bits 16]

os_boot:
    mov bx, BOOT_MESSAGE
    call print_wnl
 
    mov bx, ENTER_16RM
    call print_wnl
   
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
    
; hexdump-style printing of loaded disk content
; see commit `c055e0d` (https://github.com/TheCalculus/casinos/commit/c055e0df80fd1ff1fd831f94c28961ab555bf329)
; %define DO_DISK_LOOP

    ret

mov bx, DEBUG
call print_wnl

[bits 32]

BEGIN_PM:
    mov ebx, ENTER_32PM
    call print_pm

    jmp $

BOOT_MESSAGE: db "casinos: gamble with your hard drive!", 0
ENTER_16RM:   db "entered 16-bit real mode", 0
LOAD_GDT:     db "loading the GDT", 0
ENTER_32PM:   db "entered 32-bit protected mode", 0
BOOT_DRIVE:   db 0
DEBUG: db "you shouldn't see this...", 0

times 510-($-$$) db 0
dw 0xaa55

; times 256 dw 0x1234
; times 256 dw 0x5678
