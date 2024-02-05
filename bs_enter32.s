; %include "bs_gdt.s"
; start 32 bit protected mode

[bits 16]

switch_pm:
    mov bx, LOAD_GDT
    call print

    cli
    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 0x01
    mov cr0, eax
  
    jmp CODE_SEG:start_pm

[bits 32]

start_pm:
    mov ax, DATA_SEG

    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000
    mov esp, ebp

    call BEGIN_PM

LOAD_GDT: db "loading the GDT", 0
