GCC_PARAMETERS = -c -m32 -fno-builtin -ggdb -gstabs+ -Wall -nostdinc -fno-stack-protector -I include
NASM_PARAMETERS = -f elf
LD_PARAMETERS = -e entry -Ttext 0x100000 -m elf_i386 -nostdlib

all: kernel disk clear

kernel: io.o entry.o boot.o other.o ia_32.o memory.o
	ld $(LD_PARAMETERS) entry.o boot.o io.o ia_32.o memory.o other.o -o kernel.elf

disk: kernel 80m.img
	sudo losetup /dev/loop16 80m.img
	sudo kpartx -av /dev/loop16
	sudo mkdir -p /mnt/80m
	sudo mount /dev/mapper/loop16p1 /mnt/80m
	sudo mkdir -p /mnt/80m/Oiiaioiiiai
	sudo cp -f kernel.elf /mnt/80m/Oiiaioiiiai
	sudo umount /dev/mapper/loop16p1
	sudo kpartx -dv /dev/loop16
	sudo losetup -d /dev/loop16
	sudo rm -rf /mnt/80m

.PHONY:clear
clear:
	rm -f *.o
	rm -f *.elf

.PHONY:qemu
qemu:
	qemu-system-x86_64 -m 400M -hda 80m.img

entry.o: boot/entry.asm
	nasm $(NASM_PARAMETERS) boot/entry.asm -o entry.o

boot.o: boot/boot.c
	gcc $(GCC_PARAMETERS) boot/boot.c -o boot.o

memory.o: boot/memory.c
	gcc $(GCC_PARAMETERS) boot/memory.c -o memory.o

io.o: library/io.asm
	nasm $(NASM_PARAMETERS) library/io.asm -o io.o

other.o: library/other.asm
	nasm $(NASM_PARAMETERS) library/other.asm -o other.o

ia_32.o: library/ia_32.asm
	nasm $(NASM_PARAMETERS) library/ia_32.asm -o ia_32.o
