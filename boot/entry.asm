	MultibootMagic equ 1badb002h ; Multiboot魔数
	MultibootFlags equ 00000111b ; 表示 所有引导模块按页边界对齐 & 返回可用内存信息 & VBE信息
	MultibootChecksum equ - MultibootMagic - MultibootFlags ; 校验和 MultibootMagic + MultibootFlags + MultibootChecksum = 0
	VBEModeType equ 0 ; VBE信息 0表示线性图形模式
	VBEWidth equ 1280 ; 以下是显示长宽高和色深
	VBEHeight equ 720
	VBEDepth equ 32
	
	global entry
	extern boot

[bits 32]
[section .text]
	jmp entry	
	
	align 4
	dd MultibootMagic
	dd MultibootFlags
	dd MultibootChecksum
	
	times 20 db 0 ; 除VBE以外的信息因为是ELF所以不用管
	
	dd VBEModeType
	dd VBEWidth
	dd VBEHeight
	dd VBEDepth

entry:
	cli
	
	mov esp, bss_bottom ; 装载栈基址
	and esp, 0fffffff0h ; 栈基址按16字节对齐
	mov ebp, esp
	push ebx ; GRUB引导完成时EBX为信息结构指针
	call boot ; 执行C语言代码

final:
	hlt
	jmp final

[section .bss]
bss_top: ; 内核用栈 32KB
	resb 32768

bss_bottom:
