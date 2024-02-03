print:
    pusha
    mov ah, 0x0e

start:
    mov al, [bx]
    cmp al, 0
    je done

    int 0x10
    inc bx
    jmp start

done:
    popa
    ret

print_nl:
    pusha
    
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

loop:
    mov cl, dl
    cmp cl, 0
    je end_loop

    and cl, 0x0f
    cmp al, 0x0a
    jle number
    jmp letter

number:
    add cl, 48
    jmp end_cmp

letter:
    add cl, 86
    jmp end_cmp

end_cmp:
    mov [bx], cl
    
    sub bx, 1
    shr dx, 4

    jmp loop
    
end_loop:
    mov bx, HEX

    call print

    popa
    ret

HEX: db "0x0000", 0
