.code16
.global _start
_start:
    movw $1, %es:(%di)
    xor %ebx, %ebx
    movl $0x534D4150, %edx
    movl $0xe820, %eax
    movl 24, %ecx
    int $0x15

#   movw $0x7c00, %bp
#   movw $0x7c00, %sp

.code32
test_a20:
    pushal
    mov $0x696969, %edi
    mov $0x420420, %esi
    mov (%esi), %esi
    mov (%edi), %edi
    cmpsl
    popal
    jne set_a20
    ret

set_a20:
    movw $0x2401, %ax
    int $0x15
    hlt

.fill 510-(.-_start), 1, 0
.word 0xaa55
