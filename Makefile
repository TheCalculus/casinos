STAGE2_CC_ARGS := -g -fno-pic -fno-builtin -nostdlib -ffreestanding -std=gnu99 -m16 -march=i386 -e stage2_main 
BOOT_OBJDUMP_ARGS := -b binary -Maddr16,data16 -m i386 
BUILD_DIR := build

default: $(BUILD_DIR) $(BUILD_DIR)/diskimage.dd

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

$(BUILD_DIR)/boot.o: boot.s
	as --32 $^ -o $@

$(BUILD_DIR)/stage2.o: stage2.c
	gcc $(STAGE2_CC_ARGS) -c $^ -o $@

$(BUILD_DIR)/debug2.o: stage2.c
	gcc $(STAGE2_CC_ARGS) -c $^ -o $@
	objdump $(BOOT_OBJDUMP_ARGS) -D $@

$(BUILD_DIR)/boot.bin: $(BUILD_DIR)/boot.o $(BUILD_DIR)/stage2.o
	ld -m elf_i386 -T boot.ld -o $@ $^

$(BUILD_DIR)/diskimage.dd: $(BUILD_DIR)/boot.bin
	dd if=/dev/zero of=$@ bs=1048576 count=16
	dd if=$^ of=$@ conv=notrunc bs=512 count=2

.PHONY: all clean run remote debug debug2.o dump

all: $(BUILD_DIR) $(BUILD_DIR)/diskimage.dd

run: $(BUILD_DIR)/diskimage.dd
	qemu-system-i386 -display curses -hda $^

remote: $(BUILD_DIR)/diskimage.dd
	qemu-system-i386 -s -S -display curses -hda $^ 

debug: $(BUILD_DIR)/diskimage.dd
	gdb -ex "target remote localhost:1234"

dump: $(BUILD_DIR)/diskimage.dd
	objdump $(BOOT_OBJDUMP_ARGS) -D $@

clean: $(BUILD_DIR)
	rm -rf $(BUILD_DIR)
