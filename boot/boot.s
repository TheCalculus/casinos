[org 7c00h]
[bits 16]

call start

; TODO: boot status codes

; %define STATUS_NONE                   0     ; default

; %define ERROR_DL_NOT_80h              42    ; cmp dl, 80h
; %define ERROR_BIOS_EXT_NOT_SUPPORTED  43    ; bios extensions not supported
; %define ERROR_BIOS_EXT_DISK_READ_FAIL 44    ; bios extended disk read failed
; %define ERROR_VOLUME_NOT_EXT2         45    ; volume is not ext2

; %define INFO_STAGE2_INIT              52    ; moving to stage 2
; %define INFO_BLOCK_SIZE               53    ; block size figured out
; %define INFO_BGD_TABLE_LOADED         54    ; block group descriptor table loaded

; %define SUCCESS_BOOT                  69    ; boot was successful

ERROR_DL_NOT_80h                      db    "cmp dl, 80h", 0
ERROR_BIOS_EXT_NOT_SUPPORTED          db    "bios extensions not supported", 0
ERROR_BIOS_EXT_DISK_READ_FAIL         db    "bios extended disk read failed", 0
ERROR_VOLUME_NOT_EXT2                 db    "volume is not ext2", 0

INFO_STAGE2_INIT                      db    "moving to stage2", 0
INFO_BLOCK_SIZE                       db    "block size figured out", 0
INFO_BGD_TABLE_LOADED                 db    "block group descriptor table loaded", 0

SUCCESS_BOOT                          db    "boot was successful", 0

start:
    cmp dl, 80h
    mov bx, ERROR_DL_NOT_80h
    jne error

    mov [drive], dl

    mov ah, 41h                             ; check if EXT operations are supported
    mov bx, 55aah
    mov dl, 80h
    int 13h

    mov bx, ERROR_BIOS_EXT_NOT_SUPPORTED
    jc error

    mov bx, stage2
    mov [transfer], bx
    call read_disk

    jmp stage2

read_disk:
    mov si, dapack
    mov ah, 42h
    mov dl, [drive]
    int 13h

    mov bx, ERROR_BIOS_EXT_DISK_READ_FAIL
    jc error

    ret

error:
    call print
    jmp $

%include "print.s"

dapack:                                     ; lba packet
                    db 10h                  ; size
                    db 0
sectors:            dw 2                    ; number of sectors to transfer
transfer:           dw 0                    ; transfer buffer offset
                    dw 0                    ; transfer buffer segment
lba:                dd 1                    ; lower 32-bits of 48-bit starting LBA
                    dd 0                    ; upper 16-bits of 48-bit starting LBA

drive               db 0                    ; drive number is here

times 510-($-$$) db 0
dw 0xaa55

stage2:
    mov bx, INFO_STAGE2_INIT
    call print

    mov ax, [superblock + 56]               ; ext2 signature
    cmp ax, 0xef53                          ; check if volume is ext2
    mov bx, ERROR_VOLUME_NOT_EXT2
    jne error

ext2_block_size: dw 0
ext2_blgrp_table: dw 0

    mov ax, [superblock + 24]               ; the number to shift 1,024 to the left by to obtain the block size
    mov bx, 1024                            ; bx will have block size
    cmp ax, 0                               ; 1024 << 0 = 1024
    je block_size_1024                      ; block size is 1024

    mov cl, al
    shl bx, cl                              ; 1024 << ax gives block size
    mov [ext2_block_size], bx               ; get block size in bx
    mov ax, 1                               ; move value for ext2_blgrp_table into ax
    jmp done

block_size_1024:
    mov ax, 2

done:
    mov [ext2_blgrp_table], ax
    mov bx, INFO_BLOCK_SIZE                 ; we figured out block size
    call print

    mov ax, [ext2_blgrp_table]              ; ax = ext2_blgrp_table = ax (FIXME)
    mov [lba], ax                           ; lba of block group descriptor table
    mov ax, 2                               ; read 1 sector (512 bytes)
    mov bx, 1000h                           ; into 1000h

    mov [sectors], ax
    mov [transfer], bx
    call read_disk                          ; read block group descriptor table

    mov bx, INFO_BGD_TABLE_LOADED
    call print

    mov cx, [1200h + 28]                    ; 1288h is starting block address of inode table
    lea di, [1200h + 40]

begin_stage_two:
    ; iterate block pointers to get stage 2

    mov ax, [di]                            ; load block pointer 0
    mov [lba], ax                           ; block pointer 0
    mov bx, 5000h                           ; destination address
    mov [transfer], bx                      ; load inode at 5000h

    call read_disk

    add bx, 400h
	add di, 4h
	sub cx, 2h
	
    jnz begin_stage_two

enable_a20:
    mov ax, 2401h
    int 15h

load_gdt:
    cli
    xor ax, ax
    mov ds, ax
    lgdt [gdt_descriptor]
    
    mov eax, cr0
    or eax, 01h
    mov cr0, eax

[bits 32]
    jmp 08h:reload_cs
reload_cs:
    mov ax, 08h
    mov ds, ax
    mov ss, ax

    mov esp, 090000h
    mov eax, 5000h
    lea ebx, [eax]
    call ebx
    jmp $

%include "gdt.s"
block_size          db  0
inode_table         dd  0

times 1022-($-$$) db 0
dw 0x6969
superblock:
; link with stage 2
