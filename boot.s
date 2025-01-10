.set multiboot_info, 0x7000
.set e820_map, multiboot_info + 52

.code16
.global _start
_start:
    testb $0x80, %dl

    xorw %ax, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %ss

a20:
    mov $0x696969, %edi
    mov $0x096969, %esi
    mov (%esi), %esi
    mov (%edi), %edi
    cmpsl
    jne a20.set
    jmp e820
a20.set:
    inb $0x92, %al
    testb $02, %al
    jnz a20.no92
    orb $2, %al
    andb $0xfe, %al
    outb %al, $0x92
    jmp a20.finish
a20.no92:
    movw $0x2401, %ax
    int $0x15
a20.finish:

e820:
    movl $e820_map, %ebx
    movl %ebx, %edi
    xor %ebx, %ebx
    xor %bp, %bp
    movl $0x534D4150, %edx
    movl $0xe820, %eax
    movl 24, %ecx
    int $0x15
    jc e820.failed
    movl $0x0534D4150, %edx
    cmpl %eax, %edx
    jne e820.failed
    test %ebx, %ebx
    je e820.failed
e820.iter:
    movl $0xe820, %eax
    movl $24, %ecx
    addl $24, %edi
    int $0x15
    test %ebx, %ebx
    jne e820.iter
    jmp e820.finish
e820.failed:
e820.finish:

stage2:
    movb $0x41, %ah
    movw $0x55aa, %bx
    movb $0x80, %dl
    int $0x13
    jne stage2.no41

    ; TODO: dapack

stage2.no41

.code32
