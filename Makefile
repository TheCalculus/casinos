default: boot.bin

boot.o: boot.s
	as boot.s -o boot.o

boot.elf: boot.o
	ld -T boot.ld -o boot.elf boot.o

boot.bin: boot.elf
	objcopy -O binary boot.elf boot.bin

.PHONY: clean
clean:
	rm -f *.o *.bin *.elf
