[org 0x7c00]
    mov bx, BOOT_MESSAGE

    call print
    
    mov [BOOT_DRIVE], dl

    mov bp, 0x8000
    mov sp, bp

    mov bx, 0x9000
    mov dh, 5
    mov dl, [BOOT_DRIVE]
    
    call disk_load

    mov cx, 512
    mov dx, cx

    call print_hex
    call print_nl

disk_loop:
    cmp cx, 0
    je end_disk_loop

    mov si, cx
    shl si, 1
    mov dx, [0x9000 + si]

    call print_hex

    dec cx
    jmp disk_loop

end_disk_loop:
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
