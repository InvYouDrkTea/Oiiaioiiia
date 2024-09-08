GCC_PARAMETERS = -c -m32 -fno-builtin -ggdb -gstabs+ -Wall -nostdinc -fno-stack-protector -I include
NASM_PARAMETERS = -f elf
LD_PARAMETERS = -e entry -Ttext 0x100000 -m elf_i386 -nostdlib

os: kernel disk clean

kernel: entry.o main.o
	ld $(LD_PARAMETERS) entry.o main.o -o kernel.elf

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
	qemu-system-x86_64 -hda 80m.img

entry.o: boot/entry.asm
	nasm $(NASM_PARAMETERS) boot/entry.asm -o entry.o

main.o: main.c
	gcc $(GCC_PARAMETERS) main.c -o main.o
