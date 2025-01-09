default: boot.bin

boot.o: boot.s
	as boot.s -o boot.o

boot.elf: boot.ld boot.o
	ld -T boot.ld

boot.bin: boot.elf
	objcopy -O binary boot.elf boot.bin

.PHONY: all clean run

all: boot.bin

run: boot.bin
	qemu-system-i386 -display curses -hda boot.bin 

clean:
	rm -f *.o *.bin *.elf
