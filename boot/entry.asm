	MultibootMagic equ 1badb002h ; Multiboot魔数
	MultibootFlags equ 00000011b ; 表示 所有引导模块按页边界对齐 & mem_*域包括可用内存信息
	MultibootChecksum equ - MultibootMagic - MultibootFlags ; 校验和 MultibootMagic + MultibootFlags + MultibootChecksum = 0
	
	global entry, multiboot_info_ptr
	extern main

[bits 32]
[section .text]
	dd MultibootMagic
	dd MultibootFlags
	dd MultibootChecksum

entry:
	cli ; GRUB引导完成时IDT尚未建立 中断应当被禁止
	
	mov esp, BaseOfStack ; 装载栈基址
	xor ebp, ebp
	and esp, 0fffffff0h ; 栈基址按字对齐
	mov [multiboot_info_ptr], ebx ; GRUB引导完成时EBX为信息结构指针 将其写入变量multiboot_info_ptr
	call main ; 执行C语言代码

final:
	hlt
	jmp final

[section .bss]
stack: ; 内核用栈 32KB
	resb 32768

multiboot_info_ptr:
	resb 4

	BaseOfStack equ $ - stack - 1
