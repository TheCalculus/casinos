.code16

.section .text

.global _start
jmp _start

.global diskread
.type diskread, @function
diskread:
    pusha
    movb $0x42, %ah
    lea dapack, %si
    movb $.drive, %dl
    int $0x13
    jc diskread.failed
    jmp diskread.done
diskread.failed:
    lea err_diskread, %si
    call print
diskread.done:
    popa
    ret

.global print
.type print, @function
print:
    pusha
    mov $0x0e, %ah
print.next:
    lodsb
    testb %al, %al
    je print.done
    int $0x10
    jmp print.next
print.done:
    popa
    ret

hexprint:
    pusha
    movw %ax, %bx
    movw $hex_buffer, %di
    movb $4, %cl
hexprint.next:
    rolw $4, %bx
    movb %bl, %al
    andb $0x0F, %al
    cmpb $10, %al
    jl hexprint.number
    addb $'A' - 10, %al
    jmp hexprint.done
hexprint.number:
    addb $'0', %al
hexprint.done:
    stosb
    decb %cl
    jnz hexprint.next
    movb $0, %al
    stosb
    lea hex_buffer, %si
    call print
    lea new_line, %si
    call print
    popa
    ret

_start:
    lea msg_hello, %si
    call print

    cmpb $0x80, %dl
    jge .dl80
.dl80:
    movb %dl, .drive
    movb $.drive, %dl

    lea msg_hdd, %si
    call print

    cli
    cld
    ljmp $0x0000, $.initcs
.initcs:
    xorw %si, %si
    movw %si, %di
    movw %si, %es
    movw %si, %ss
    movw $0x7c00, %sp
    sti

a20:
    mov $0x112345, %edi
    mov $0x012345, %esi
    mov (%esi), %esi
    mov (%edi), %edi
    cmpsl
    jne a20.set
    jmp a20.finish
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
    lea msg_a20, %si
    call print

e820:
    movl $.e820_map_addr, %ebx
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
e820.failed:
    hlt
e820.finish:
    lea msg_e820, %si
    call print

stage2:
    movb $0x41, %ah
    movw $0x55aa, %bx
    int $0x13
    jne stage2.no41
    call diskread
    jmp stage2.load
stage2.no41:
    lea err_no41, %si
    call print
stage2.load:
    call .stage2_load_addr
    hlt

.data

.set .drive,                0x80
.set .stage2_load_addr,     0x7e00
.set .multiboot_info_addr,  0x7000
.set .e820_map_addr,        .multiboot_info_addr + 52

.align 16
dapack:
    .byte 0x10
    .byte 0
.sectors:
    .short 1
.transfer:
    .word .stage2_load_addr
    .word 0
.lba:
    .long 1
    .long 0

.align 16
hex_buffer:   .space 5

msg_hello:    .asciz "casinoboot: gambling with your hardrive\n\r"
msg_hdd:      .asciz "booting from hard drive %dl > 80\n\r"
msg_a20:      .asciz "TODO: handle a20 success/error\n\r"
msg_e820:     .asciz "e820 memory map loaded\n\r"
new_line:     .asciz "\n\r"
// strerrors
err_diskread: .asciz "disk read failed\n\r"
err_no41:     .asciz "stage2 no 41\n\r"
