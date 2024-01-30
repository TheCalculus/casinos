[org 0x7c00]
    mov bx, MESSAGE

    call print
    call print_nl

    mov dx, 0xABCD
    
    call print_hex
    call print_nl

    jmp $

%include "bs_print.s"

MESSAGE:
    db "casinos: gamble with your hard drive!", 0

times 510-($-$$) db 0
dw 0xaa55
