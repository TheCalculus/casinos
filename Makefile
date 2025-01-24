default: diskimage.dd

STAGE2_CC_ARGS := -g -fno-pic -fno-builtin -nostdlib -ffreestanding -std=gnu99 -m16 -march=i386 -e stage2_main 
BOOT_OBJDUMP_ARGS := -b binary -Maddr16,data16 -m i386 

boot.o: boot.s
	as --32 boot.s -o boot.o

stage2.o: stage2.c
	gcc $(STAGE2_CC_ARGS) -c stage2.c -o stage2.o

debug2.o: stage2.c
	gcc $(STAGE2_CC_ARGS) -c stage2.c -o debug2.o
	objdump $(BOOT_OBJDUMP_ARGS) -D debug2.o

boot.bin: boot.ld boot.o stage2.o
	ld -m elf_i386 -T boot.ld

diskimage.dd: boot.bin
	dd if=/dev/zero of=diskimage.dd bs=1048576 count=16
	dd if=boot.bin of=diskimage.dd conv=notrunc bs=512 count=2

dump: diskimage.dd
	objdump $(BOOT_OBJDUMP_ARGS) -D diskimage.dd

.PHONY: all clean run remote debug debug2.o dump

all: diskimage.dd

run: diskimage.dd
	qemu-system-i386 -display curses -hda diskimage.dd 

remote: diskimage.dd
	qemu-system-i386 -s -S -display curses -hda diskimage.dd 

debug: diskimage.dd
	gdb -ex "target remote localhost:1234"

clean:
	rm -f *.o *.bin *.elf *.dd
