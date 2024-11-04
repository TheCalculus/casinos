# qemu might require -display curses instead of -curses
DISPLAY_CURSES := -display curses 
CC_COMPILE_FLAGS := -w -fno-pic -fno-builtin -nostdlib -ffreestanding -std=gnu99 -m32 -c

boot2: disk.img
	gcc $(CC_COMPILE_FLAGS) *.c -o boot2.o
	ld -m elf_i386 -N -e main -Ttext 0x00050000 -o boot2 boot2.o --oformat binary
	dd if=boot2 of=disk.img conv=notrunc

boot: boot.s disk.img
	nasm boot.s -o boot
	dd if=boot of=disk.img conv=notrunc

disk.img:
	dd if=/dev/zero of=disk.img bs=1k count=16k
	sudo mke2fs disk.img

run: boot disk.img
	qemu-system-i386 $(DISPLAY_CURSES) -hda disk.img

runss: boot disk.img
	qemu-system-i386 -s -S -$(DISPLAY_CURSES) -hda disk.img

debug: disk.img
	gdb -ex "target remote localhost:1234"

reset:
	rm boot
	rm disk.img

clean:
	rm boot
