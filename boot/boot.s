[org 7c00h]
[bits 16]

start:
    cmp dl, 80h
    mov bx, dl_not_80h
    jne error

    mov [drive], dl

    mov ah, 41h                     ; check if EXT operations are supported
    mov bx, 55aah
    mov dl, 80h
    int 13h

    mov bx, ext_test_failed
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

    mov bx, disk_read_failed
    jc error

    ret

error:
    call print
    jmp $

%include "print.s"

dapack: ; lba packet
                    db 10h          ; size
                    db 0
sectors:            dw 4            ; number of sectors to transfer
transfer:           dw 0            ; transfer buffer offset
                    dw 0            ; transfer buffer segment
lba:                dd 1            ; lower 32-bits of 48-bit starting LBA
                    dd 0            ; upper 16-bits of 48-bit starting LBA

drive               db 0            ; drive number is here

dl_not_80h          db              "cmp dl, 80h", 0
ext_test_failed     db              "bios extensions not supported", 0
disk_read_failed    db              "disk read failed", 0
volume_not_ext2     db              "volume is not ext2", 0
stage_two_begin     db              "moving to stage2", 0
info_block_size_kwn db              "block size figured out", 0
read_bgd_table      db              "block group descriptor table loaded", 0

times 510-($-$$) db 0
dw 0xaa55

stage2:
    mov bx, stage_two_begin
    call print

    mov ax, [superblock + 56]       ; ext2 signature
    cmp ax, 0xef53                  ; check if volume is ext2
    mov bx, volume_not_ext2
    jne error

    mov ax, [superblock + 24]       ; the number to shift 1,024 to the left by to obtain the block size
    mov bx, 1024
    cmp ax, 0                       ; 1024 << 0 = 1024
    je block_size_1024              ; block size is 1024

    mov cl, al
    shl bx, cl                      ; 1024 << ax gives block size
    jmp block_size_ukwn             ; block size is not 1024

block_size_1024:
    mov bx, 1024

block_size_ukwn:
    mov ax, bx
    mov bx, info_block_size_kwn     ; we figured out block size
    call print

    xor dx, dx
    mov cx, 512                     ; assume sector size to be 512
    div cx                          ; ax / 512 gives sectors
    mov [lba], ax
    mov bx, 2                       ; read 2 sectors
    mov [sectors], bx
    mov ax, 1000h                   ; into 1000h
    mov [transfer], ax

    call read_disk                  ; read block group descriptor table
    mov bx, read_bgd_table
    call print

    ; inode 5 should be at 1288h?
    ; 0x1000 + 8 + 5 * 128
    ; (128 is sizeof(inode))
    mov ax, 1200h                   ; inode 5 is here
    mov cx, [1200h + 28]            ; count of disk sectors
    lea di, [1200h + 40]            ; direct block pointer 0


; iterate through block pointers in bootloader to get stage 2

begin_stage_two:
    mov ax, [di]                    ; load block pointer 0
    shl ax, 1                       ; double it

    mov [lba], ax                   ; block pointer 0
    mov bx, 5000h                   ; destination address
    mov [transfer], bx              ; load inode at 5000h

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
db 0x69
db 0x69
superblock:
; link with stage 2