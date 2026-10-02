TARGET := i686-elf
CC := $(TARGET)-gcc
AS := $(TARGET)-as
GRUB_FILE := grub-file
GRUB_MKRESCUE := grub-mkrescue
QEMU := qemu-system-i386
CFLAGS := -std=gnu11 -ffreestanding -O2 -Wall -Wextra -m32 -fno-pie -fno-stack-protector
BUILD := build

.PHONY: all clean check iso run
all: $(BUILD)/tinyos.iso
$(BUILD):
	mkdir -p $(BUILD)
$(BUILD)/boot.o: boot.s | $(BUILD)
	$(AS) --32 $< -o $@
$(BUILD)/kernel.o: kernel.c | $(BUILD)
	$(CC) $(CFLAGS) -c $< -o $@
$(BUILD)/kernel.bin: $(BUILD)/boot.o $(BUILD)/kernel.o linker.ld
	$(CC) -T linker.ld -o $@ -ffreestanding -nostdlib $(BUILD)/boot.o $(BUILD)/kernel.o -lgcc
$(BUILD)/iso/boot/grub/grub.cfg: grub.cfg | $(BUILD)
	mkdir -p $(BUILD)/iso/boot/grub
	cp grub.cfg $@
$(BUILD)/tinyos.iso: $(BUILD)/kernel.bin $(BUILD)/iso/boot/grub/grub.cfg
	cp $(BUILD)/kernel.bin $(BUILD)/iso/boot/kernel.bin
	$(GRUB_MKRESCUE) -o $@ $(BUILD)/iso
check: $(BUILD)/kernel.bin
	$(GRUB_FILE) --is-x86-multiboot $(BUILD)/kernel.bin
iso: $(BUILD)/tinyos.iso
run: $(BUILD)/tinyos.iso
	$(QEMU) -cdrom $(BUILD)/tinyos.iso -display curses
clean:
	rm -rf $(BUILD)
