print:
    pusha
    mov ah, 0x0e

print_loop:
    mov al, [bx]
    int 0x10

    add bx, 1
    cmp al, 0

    je end_print_loop
    jmp print_loop

end_print_loop:
    mov ah, 0x0e

    mov al, 0x0a
    int 0x10

    mov al, 0x0d
    int 0x10

    popa
    ret

print_hex:
    pusha

    mov bx, HEX
    add bx, 0x05

print_hex_loop:
    mov cl, dl
    cmp cl, 0
    
    je end_print_hex_loop

    and cl, 0x0f
    cmp cl, 0x0a

    jl print_hex_number
    jmp print_hex_letter

print_hex_number:
    add cl, 48
    jmp print_hex_end_cmp

print_hex_letter:
;   add cl, 55 ; uppercase hexadecimal values
    add cl, 87
    jmp print_hex_end_cmp

print_hex_end_cmp:
    mov [bx], cl

    sub bx, 1
    shr dx, 4

    jmp print_hex_loop

end_print_hex_loop:
    mov bx, HEX
    call print

    popa
    ret

HEX: db "0x0000", 0

PrintHex:
    pusha
    mov cx, 4
    mov bx, dx
    
PrintHexDigit:
    shl bx, 4
    mov al, bh 
    and al, 0Fh
    cmp al, 9
    jbe PrintDigit
    
    add al, 'A' - 10
    jmp Output
    
PrintDigit:
    add al, '0'
    
Output:
    mov ah, 0Eh
    int 10h
    
    loop PrintHexDigit
    call print

    popa
    ret
