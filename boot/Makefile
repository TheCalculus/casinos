QEMU := qemu-system-i386
DISPLAY_CURSES := -display curses
CC := gcc
NASM := nasm
GDB := gdb

CC_COMPILE_FLAGS := -w -fno-pic -fno-builtin -nostdlib -ffreestanding -std=gnu99 -m32 -c
NASM_FLAGS := -f bin

BOOT_BIN := boot
STAGE2_BIN := stage2
DISK_IMG := disk.img

.PHONY: all clean reset run debug

all: $(DISK_IMG)

$(STAGE2_BIN): stage2.s
	$(NASM) $(NASM_FLAGS) stage2.s -o $(STAGE2_BIN)

$(BOOT_BIN): boot.s
	$(NASM) $(NASM_FLAGS) boot.s -o $(BOOT_BIN)

$(DISK_IMG): $(BOOT_BIN) $(STAGE2_BIN)
	dd if=/dev/zero of=$(DISK_IMG) bs=1k count=16k
	sudo mke2fs $(DISK_IMG)
	dd if=$(BOOT_BIN) of=$(DISK_IMG) conv=notrunc
	dd if=$(STAGE2_BIN) of=$(DISK_IMG) seek=2 conv=notrunc

run: $(DISK_IMG)
	$(QEMU) $(DISPLAY_CURSES) -hda $(DISK_IMG)

runss: $(DISK_IMG)
	$(QEMU) -s -S $(DISPLAY_CURSES) -hda $(DISK_IMG)

debug: $(DISK_IMG)
	$(GDB) -ex "target remote localhost:1234"

clean:
	rm -f $(BOOT_BIN) $(STAGE2_BIN)

reset: clean
	rm -f $(DISK_IMG)

