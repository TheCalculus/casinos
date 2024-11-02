# qemu might require -display curses instead of -curses
DISPLAY_CURSES := -display curses 

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
