CFLAGS=-c -ffreestanding -m32 -fno-pie
LDFLAGS=-melf_i386 -Ttext 0x1000 --oformat binary

BOOTDIR=boot/
KERNDIR=kernel/
BUILDDIR=build/

all: os-image

# qemu -i386?
run: os-image
	qemu-system-x86_64 -fda os-image

os-image: $(BUILDDIR)boot_sect.bin $(BUILDDIR)kernel.bin
	cat $^ > $@

$(BUILDDIR)boot_sect.bin: $(BOOTDIR)bs_main.s
	nasm -i./$(BOOTDIR)/ -fbin $^ -o $@

$(BUILDDIR)enter_kernel.o: $(KERNDIR)enter_kernel.s
	nasm -i./$(KERNDIR)/ -felf $^ -o $@

$(BUILDDIR)%.o: $(KERNDIR)%.c
	gcc $(CFLAGS) $< -o $@

$(BUILDDIR)kernel.bin: $(BUILDDIR)enter_kernel.o $(patsubst $(KERNDIR)%.c, $(BUILDDIR)%.o, $(wildcard $(KERNDIR)*.c))
	ld $(LDFLAGS) -o $@ $^

clean:
	rm -rf $(BUILDDIR)*.o $(BUILDDIR)*.bin $(BUILDDIR)os-image
