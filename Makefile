CFLAGS=-c -ffreestanding -m32 -fno-pie
LDFLAGS=-melf_i386 -Ttext 0x1000 --oformat binary

all: os-image

# qemu -i386?
run: os-image
	qemu-system-x86_64 -fda os-image

os-image: boot_sect.bin kernel.bin
	cat $^ > $@

boot_sect.bin: bs_main.s
	nasm -fbin $^ -o $@

kernel.bin: enter_kernel.o $(wildcard *.o)
	ld $(LDFLAGS) -o $@ $^

enter_kernel.o: enter_kernel.s
	nasm -felf $^ -o $@

%.o: %.c
	gcc $(CFLAGS) $< -o $@

clean:
	rm -rf *.o *.bin os-image
