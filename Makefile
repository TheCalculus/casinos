default: boot.bin

boot.o: boot.s
	as boot.s -o boot.o

boot.elf: boot.ld boot.o
	ld -T boot.ld

boot.bin: boot.elf
	objcopy -O binary boot.elf boot.bin

.PHONY: all clean run remote debug

all: boot.bin

run: boot.bin
	qemu-system-i386 -display curses -hda boot.bin 

remote: boot.bin
	qemu-system-i386 -s -S -display curses -hda boot.bin 

debug: boot.bin
	gdb -ex "target remote localhost:1234; file ./boot.elf; break _start; continue"

clean:
	rm -f *.o *.bin *.elf
