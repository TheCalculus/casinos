default: boot.bin

boot.o: boot.s
	as --32 boot.s -o boot.o

stage2.o: stage2.c
	gcc -O0 -w -fno-pic -fno-builtin -nostdlib -ffreestanding -std=gnu99 -m32 -e main -c stage2.c -o stage2.o

boot.bin: boot.ld boot.o stage2.o
	ld -m elf_i386 -T boot.ld

diskimage.dd: boot.bin
	dd if=/dev/zero of=diskimage.dd bs=1048576 count=16
	dd if=boot.bin of=diskimage.dd conv=notrunc bs=512 count=1

.PHONY: all clean run remote debug

all: boot.bin

run: boot.bin
	qemu-system-i386 -display curses -hda boot.bin 

remote: boot.bin
	qemu-system-i386 -s -S -display curses -hda boot.bin 

debug: boot.bin
	gdb -ex "target remote localhost:1234"

clean:
	rm -f *.o *.bin *.elf
