print:
    pusha

start:
    mov al, [bx]
    cmp al, 0
    je done

    mov ah, 0x0e
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

    mov cx, 4

loop:
    dec cx

    mov bx, HEX
    add bx, 2
    add bx, cx

    mov ax, dx
    shr dx, 4
    and ax, 0x0f

    cmp ax, 0x0a
    
    jl letter
    add byte [bx], 7
    jl letter

letter:
    add byte [bx], al

    cmp cx, 0
    je end

    jmp loop

end:
    call print

    popa
    ret

HEX: db "0x0000", 0
