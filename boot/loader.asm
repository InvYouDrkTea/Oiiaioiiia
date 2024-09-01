	org 200h
	
	BaseOfStack equ 200h
	
	%include "include/gdt.inc"
	
	jmp short ENTRY
	
D_GDT: descriptor 0, 0, 0, 0 ; 保留描述符
D_CODE: descriptor 0, CodeLength, AC_CRE, FL_32 ; 代码段描述符
D_DATA: descriptor 0, DataLength, AC_DRW, FL_32 ; 数据段描述符
D_VIDEO: descriptor 0b8000h, 0bfffh, AC_DRW, FL_32 ; 显存段描述符

	GdtLength equ $ - D_GDT ; 计算GDT界限
	GdtPtr dw GdtLength
		dd 0 ; 基址预留

	CodeSelector equ D_CODE - D_GDT ; 各个段的选择子
	DataSelector equ D_DATA - D_GDT
	VideoSelector equ D_VIDEO - D_GDT

[bits 16]
ENTRY:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, BaseOfStack
	
	call CalculateBase ; 完善GDT
	
	xor eax, eax ; 计算GDT基址
	mov ax, ds
	shl ax, 4 ; 相当于ax*10h 是实模式寻址的步骤
	add eax, D_GDT ; 基址的数值已经准备好
	mov dword [GdtPtr + 2], eax ; 写入GdtPtr数据结构
	
	lgdt [GdtPtr]
	
	cli ; IDT此时尚未建立
	
	in al, 92h ; 打开A20地址线
	or al, 00000010b
	out 92h, al
	
	mov eax, cr0 ; 置PE位 打开保护模式
	or eax, 1
	mov cr0, eax
	
	jmp dword CodeSelector:0

CalculateBase:
	xor eax, eax ; 刚刚基址没有实际写入 所以现在来计算数据
	mov ax, cs
	shl ax, 4
	add eax, CODE32
	mov di, D_CODE
	call WriteDescriptor
	
	xor eax, eax
	mov ax, cs
	shl ax, 4
	add eax, DATA32
	mov di, D_DATA

WriteDescriptor:
	mov word [di + 2], ax ; 将基址低16位的数值写入段描述符低位基址
	shr eax, 16 ; 对齐还未写入的数值
	mov byte [di + 4], al ; 同理写入剩余数值
	mov byte [di + 7], ah
	ret
	
[bits 32]
CODE32:
	mov ax, VideoSelector ; 装在显存段选择子
	mov gs, ax
	mov esi, 0a0h
	
	mov ax, DataSelector ; 装在数据段选择子
	mov ds, ax
	mov edi, 0
	
	mov ecx, DataLength ; 计数器
	.loop:
		mov al, ds:[edi]
		mov ah, 0ah ; 黑底绿字
		mov word gs:[esi], ax ; 操作显存显示文字
		add esi, 2
		inc edi
		loop .loop
	
FINAL:
	hlt
	jmp FINAL
	
	CodeLength equ $ - CODE32 ; 计算代码段界限

DATA32:
	db "Hello, world"
	DataLength equ $ - DATA32 ; 计算数据段界限
	
	times 510 - ($ - $$) db 0
	db 55h, 0aah