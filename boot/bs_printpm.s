[bits 32]

VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f

print_pm:
    pusha

    mov edx, VIDEO_MEMORY
    mov ah, WHITE_ON_BLACK

print_pm_loop:
    mov al, [ebx]

    cmp al, 0
    je end_print_pm_loop

    mov [edx], ax

    add ebx, 1
    add edx, 2

    jmp print_pm_loop

end_print_pm_loop:
    popa
    ret
