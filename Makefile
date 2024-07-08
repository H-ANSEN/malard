TOOLCHAIN = i686-elf
TOOLCHAIN_DIR = toolchain/$(TOOLCHAIN)/bin

CC = $(TOOLCHAIN_DIR)/$(TOOLCHAIN)-gcc
LD = $(TOOLCHAIN_DIR)/$(TOOLCHAIN)-ld
AS = nasm

SOURCE_DIR = kernel/
C_SOURCES = $(shell find $(SOURCE_DIR) -name '*.c')
HEADERS = $(shell find $(SOURCE_DIR) -name '*.h')
OBJ = ${C_SOURCES:.c=.o}

all: malard.iso

%.o: %.c 
	$(CC) -ffreestanding -Wall -Wextra -Werror -c $^ -o $@

%.o: %.asm
	$(AS) $^ -f elf -o $@

%.bin: %.asm
	$(AS) $^ -f bin -I 'boot' -o $@

kernel.bin: kernel/kentry.o ${OBJ}
	$(LD) -o $@ -Ttext 0x1000 $^ --oformat binary

boot.bin: boot/boot.asm
	$(AS) $^ -f bin -I 'boot' -o $@

malard.iso: boot.bin kernel.bin 
	cat $^ > malard.iso

clean:
	rm -rf *.bin *.o kernel/*.o src/*.bin malard.iso

run: malard.iso
	qemu-system-x86_64 -fda malard.iso
