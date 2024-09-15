# Oiiaioiiiai - This is an operating system
> Program has initiated on 3rd Nov 2023
> Copyright InvYouDrkTea All rights reserved.

***

## Target architecture
Oiiaioiiiai最终的运行环境是x86_64, 因此请确认处理器支持**AMD64**或**IA-32e**运行模式

Please ensure the processor supported **AMD64** or **IA-32e** mode because Oiiaioiiiai finally run in x86_64 environment.

## System booting
项目使用 GRand Unified Bootloader 引导, 支持Multiboot 2标准, **安装Oiiaioiiiai的磁盘需要具有GRUB**

Program use GRand Unified Bootloader booting, supported standard Multiboot 2, **the disk should be had GRUB which was installed Oiiaioiiiai**.

### Make GRUB disk
以下命令可以在Linux及其发行版操作系统中制作一份80MB的安装了GRUB的硬盘映像(命令来自Ubuntu)

Thos commands can make a disk image size of 80MB that already installed GRUB in Linux and its distribution operating system. (Commands from Ubuntu)

```shell
dd if=/dev/zero of=80m.img bs=512 count=163840
fdisk 80m.img
    -o
    -n
        -p
        -
        -
        -
    -w
sudo losetup /dev/loop16 80m.img
sudo kpartx -av /dev/loop16
sudo mkfs.vfat -F 32 /dev/mapper/loop16p1
sudo mkdir -p /mnt/80m
sudo mount /dev/mapper/loop16p1 /mnt/80m
sudo grub-install --root-directory=/mnt/80m /dev/loop16 --target=i386-pc
echo "Now add Oiiaioiiiai menu entry to /mnt/80m/boot/grub/grub.cfg. (Reference boot/grub.cfg)"
sudo umount /dev/mapper/loop16p1
sudo kpartx -dv /dev/loop16
sudo losetup -d /dev/loop16
```

## System compiling
编译Oiiaioiiiai需要以下几个工具: **GNU Compiler Collection(Gcc)**, **Netwide Assembler(Nasm)**, **GNU Make(Make)** 以及如果你需要执行 *Makefile* 中的脚本 *make qemu*, 你还需要 **Quick Emulator(Qemu)**

To compile Oiiaioiiiai, you need thos tools: **GNU Compiler Collection(Gcc)**, **Netwide Assembler(Nasm)**, **GNU Make(Make)** and if you need script *make qemu* in *Makefile*, you also need **Quick Emulator(Qemu)**

当一切准备就绪后, 在项目根目录下键入 *make all* 即可顺序进行编译和写入磁盘映像的工作, 需要测试运行时键入 *make qemu* 等待虚拟机启动, 需要清理编译输出文件时键入 *make clear*

Please goto program rood directory type *make all* to work for compiling and writting when all tools ready, type *make qemu* when need to test and run, type *make clear* when need to clean compiling output files.