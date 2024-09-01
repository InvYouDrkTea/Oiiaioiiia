; 分区大小512MB
	org 08200h
	
	BaseOfStack equ 8200h
	BaseOfLoader equ 1000h
	OffsetOfLoader equ 200h
	OffsetOfRootDirBuffer equ 8400h
	
	OffsetOfFunctionReadDisk equ 2
	OffsetOfFunctionLBAToCHS equ 4
	OffsetOfNumberOfHead equ 2
	OffsetOfSectorPerTrack equ 4
	
; BPB部分	
	jmp short ENTRY
	nop
	db "Oiia 1.0" ; OEM代号
BPB_BytPerSec dw 512 ; 每扇区字节数
BPB_SecPerClu db 8 ; 每簇扇区数
BPB_ResSec dw 32 ; 保留扇区数
BPB_NumOfFAT db 2 ; FAT表个数
BPB_NumRooEnt dw 0 ; 根目录项数(FAT32不使用)
BPB_NumOfSec16 dw 0 ; 扇区总数(FAT32不使用)
BPB_MedDes db 0f8h ; 介质描述符
BPB_SecPerFAT dw 0 ; FAT表占用扇区数(FAT32不使用)
BPB_SecPerTra dw 63 ; 每磁道扇区数
BPB_NumOfHea dw 255 ; 磁头数
BPB_NumOfHidSec dd 1 ; 隐藏扇区数
BPB_NumOfSec32 dd 1048320 ; 扇区总数
FAT32_SecPerFAT dd 1024 ; FAT表占用扇区数(FAT32特有)
FAT32_ExtFla dw 0 ; 标志
FAT32_Ver dw 0 ; 版本
FAT32_RooEntClu dd 2 ; 根目录的起始簇号
FAT32_InfSec dw 1 ; 文件系统信息扇区
FAT32_BacBooSec dw 6 ; 引导扇区备份扇区
FAT32_Res times 12 db 0 ; 保留
ExBPB_DriNum db 80h ; BIOS中断驱动器号
ExBPB_Res db 0 ; 保留
ExBPB_ExtBooSig db 29h ; 扩展引导标志
ExBPB_VolNum dd 0 ; 卷序列号
ExBPB_VolLab db "NO NAME    " ; 卷标(FAT32不使用)
ExBPB_FilSys db "FAT32   " ; 文件系统类型

; 引导程序部分
ENTRY:
	mov word [DiskDataTable], bx ; 接受MBR传来的指针
	mov word [FunctionAddressTable], ax
	mov sp, BaseOfStack ; 更换栈指针
	
CALCULATE_ROOT_DIR: ; 计算根目录 分区起始扇区+保留扇区数+FAT表占用扇区数*FAT表个数
	xor eax, eax
	xor bx, bx
	mov ax, [FAT32_SecPerFAT]
	mov bl, [BPB_NumOfFAT]
	mul bx
	mov bx, [BPB_ResSec]
	add ax, bx
	mov bx, [BPB_NumOfHidSec]
	add ax, bx
	
	mov di, [FunctionAddressTable]
	call [di + OffsetOfFunctionLBAToCHS]
	mov bx, OffsetOfRootDirBuffer
	mov al, 1
	mov di, [FunctionAddressTable]
	call [di + OffsetOfFunctionReadDisk]
	
FINAL:
	hlt
	jmp FINAL

; 众数据在此
	DiskDataTable dw 0
	FunctionAddressTable dw 0

; 引导区标记部分
	times 510 - ($ - $$) db 0
	db 55h, 0aah