# Oiiaioiiiai - This is an operating system
> Program has initiated on 3rd Nov 2023, 
> Copyright InvYouDrkTea All rights reserved.

## Target architecture - 目的架构
Oiiaioiiiai 最终的运行环境是x86_64, 因此请确认处理器支持 **AMD64** 或 **IA-32e** 运行模式

Please ensure the processor supported **AMD64** or **IA-32e** mode because Oiiaioiiiai finally run in x86_64 environment.

## System booting - 系统引导
项目使用 *GRand Unified Bootloader* 引导, 支持 Multiboot 标准, **安装 Oiiaioiiiai 的磁盘需要具有GRUB**

Program use *GRand Unified Bootloader* booting, supported standard Multiboot, **the disk should be had GRUB which was installed Oiiaioiiiai**.

### Install GRUB - 安装 GRUB
以下命令可以在Linux及其发行版操作系统中制作一份同时安装了 *GRUB i386-pc* 的硬盘映像(*loop16* 仅是开发者设备上合适的回环设备, 你的 *loop16* 可能正在使用)

Thos commands can make a disk image that installed *GRUB x86_64-EFI* in Linux and its distribution operating system. (*loop16* is only appropriate at developer, yours maybe buzy)

```bash
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
<<<<<<< HEAD
sudo cp -f boot/grub.cfg /mnt/80m/boot/grub
sudo umount /dev/mapper/loop16p1
sudo kpartx -dv /dev/loop16
sudo losetup -d /dev/loop16
```

如果将在非硬盘映像上安装 GRUB 需注意不执行硬盘映像相关操作, 从 *KPARTX* 操作开始即可

If you won't install it in disk image, you should not do any image operation, just start at *KPARTX* operation.

## System compiling
编译 Oiiaioiiiai 需要以下几个工具: **GNU Compiler Collection(GCC)**, **Netwide Assembler(NASM)**, **GNU Make(Make)** 以及如果你需要执行 *Makefile* 中的脚本 *make qemu*, 你还需要 **Quick Emulator(QEMU)**

To compile Oiiaioiiiai, you need thos tools: **GNU Compiler Collection(GCC)**, **Netwide Assembler(NASM)**, **GNU Make(Make)** and if you need script *make qemu* in *Makefile*, you also need **Quick Emulator(QEMU)**

当一切准备就绪后, 在项目根目录下键入 *make all* 即可顺序进行编译和写入磁盘映像的工作, 需要测试运行时键入 *make qemu* 等待虚拟机启动, 需要清理编译输出文件时键入 *make clear*

Please goto program rood directory type *make all* to work for compiling and writting when all tools ready, type *make qemu* when need to test and run, type *make clear* when need to clean compiling output files.
