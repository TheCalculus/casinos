[org 0x7c00]
    mov bx, BOOT_MESSAGE

    call print
    call print_nl
    
    mov [BOOT_DRIVE], dl

    mov bp, 0x8000
    mov sp, bp

    mov bx, 0x9000
    mov dh, 5
    mov dl, [BOOT_DRIVE]
    
    call disk_load

    mov cx, 511
    mov bx, 0

; hexdump-style printing of loaded disk content
; %define DO_DISK_LOOP

%ifdef DO_DISK_LOOP

disk_loop:
    cmp cx, 0
    jl end_disk_loop

    cmp bx, 8
    jge sixteenth_row
    jmp intermediate_row

sixteenth_row:
    mov bx, 0
    call print_nl

intermediate_row:
    mov si, cx
    shl si, 1
    mov dx, [0x9000 + si]

    call print_hex
    call print__

    dec cx
    inc bx
    jmp disk_loop

end_disk_loop:

%endif
    call print_nl
    call print_nl

    jmp $

%include "bs_print.s"
%include "bs_disk.s"

BOOT_MESSAGE:
    db "casinos: gamble with your hard drive!", 0

BOOT_DRIVE: db 0

times 510-($-$$) db 0
dw 0xaa55

times 256 dw 0x1234
times 256 dw 0x5678
