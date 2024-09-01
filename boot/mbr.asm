; 开发者使用512MB硬盘映像 引导将仅考虑本映像情况
; 对于此映像:
; 此操作系统的逻辑CHS=65/256/63 
; Bochs中驱动器的CHS=1040/16/63
; 为了兼容不同版本的BIOS程序会在运行时询问BIOS的逻辑CHS
	org 07c00h
	
	BaseOfStack equ 07c00h
	BaseOfDBR equ 0
	OffsetOfDBR equ 08200h
	
	%include "include/dpt.inc"

; 引导程序部分	
ENTRY:
	mov ax, cs ; 0帧起手初始化
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, BaseOfStack
	
	mov ax, 0600h ; 清屏操作
	mov cx, 0
	mov dx, 0ffffh
	mov bh, 07h ; 黑底白字
	int 10h
	
	mov ah, 0
	mov dl, 80h
	int 13h ; 磁盘系统复位
	
	mov cx, I_START_BOOTING_Length
	mov bp, I_START_BOOTING
	mov dx, 0
	mov bl, 07h ; 黑底白字
	call Prints

CHECK_DISK_DATA:
	mov dl, 80h
	mov ah, 08h ; 读取驱动器参数
	int 13h
	jc DISK_READ_FAILED
	mov al, cl ; 这里不写注释了反正各个寄存器的值能查到
	shr cl, 6
	xchg ch, cl
	shl al, 2
	shr al, 2
	mov word [NumberOfTrack], cx
	mov byte [NumberOfHead], dh
	mov byte [SectorPerTrack], al

CHECK_DPT:
	mov di, P0 ; 检查分区可引导性
	mov al, [di]
	cmp al, 80h
	je FIND_BOOTABLE_PART
	mov bp, E_NO_BOOTABLE_PART
	mov cx, E_NO_BOOTABLE_PART_Length
	mov bl, 0ch ; 黑底红字
	mov dx, 100h
	call Prints
	jmp FINAL

FIND_BOOTABLE_PART:
	mov dx, 100h ; 找到了可引导分区 准备加载DBR
	mov cx, I_FIND_BOOTABLE_PART_Length
	mov bl, 07h ; 黑底白字
	mov bp, I_FIND_BOOTABLE_PART
	call Prints

LOAD_DBR: ; 加载DBR
	mov di, P0
	add di, 8
	mov eax, [di]
	call LBAToCHS
	
	mov al, 1
	mov bx, OffsetOfDBR	
	call ReadDisk
	cmp ah, 0
	je JUMP_DBR
	
DISK_READ_FAILED:
	mov cx, E_READ_FAILED_Length ; 寄了没成功
	mov dx, 200h ; 第1行 第0列
	mov bl, 0ch ; 黑底红字
	mov bp, E_READ_FAILED
	call Prints
	jmp FINAL

JUMP_DBR:
	mov ax, Prints ; 已写函数的偏移地址
	mov word [FunctionPrints], ax
	mov ax, ReadDisk
	mov word [FunctionReadDisk], ax
	mov ax, LBAToCHS
	mov word [FunctionLBAToCHS], ax
	mov ax, FUNCTION_ADDRESS_TABLE
	mov bx, DISK_DATA_TABLE ; 磁盘数据表的地址放在了BX 一起传给DBR
	jmp BaseOfDBR:OffsetOfDBR
	
FINAL:
	hlt
	jmp FINAL ; 发生错误停在这里

; 众数据在此
I_START_BOOTING: db "The quick brown fox jumps over a lazy dog. Oiiaioiiia start booting.", 0ah, 0dh
E_NO_BOOTABLE_PART: db "No active partition.", 0ah, 0dh
I_FIND_BOOTABLE_PART: db "Find active partition.", 0ah, 0dh
E_READ_FAILED: db "Disk read failed.", 0ah, 0dh
	I_START_BOOTING_Length equ E_NO_BOOTABLE_PART - I_START_BOOTING
	E_NO_BOOTABLE_PART_Length equ I_FIND_BOOTABLE_PART - E_NO_BOOTABLE_PART
	I_FIND_BOOTABLE_PART_Length equ E_READ_FAILED - I_FIND_BOOTABLE_PART
	E_READ_FAILED_Length equ $ - E_READ_FAILED

DISK_DATA_TABLE:
	NumberOfTrack dw 0
	NumberOfHead dw 0
	SectorPerTrack dw 0

FUNCTION_ADDRESS_TABLE:
	FunctionPrints dw 0
	FunctionReadDisk dw 0
	FunctionLBAToCHS dw 0

Prints: ; 函数Prints 输入(cx=字符串长度 dh=显示行 dl=显示列 bl=属性 es:bp=字符串地址)
	mov al, bl ; 调用BIOS中断显示字符串
	xor bx, bx
	mov bl, al
	mov ax, 1301h
	int 10h
	ret

ReadDisk: ; 函数ReadDisk 输入(al=扇区数 ch=磁道号 cl=扇区号 dh=磁头号 es:bx=缓冲区地址) 输出(ah=0 操作成功)
	mov ah, 02h ; 调用BIOS中断读取磁盘
	mov dl, 80h
	int 13h
	ret

LBAToCHS: ; 函数LBAToCHS 输入(eax=扇区LBA) 输出(ch=磁道号 cl=扇区号 dh=磁头号)
	mov edx, eax ; 将扇区LBA编号转换为CHS(皆为8位 只在实模式下的临时计算)
	shr edx, 16 ; 磁道计算 LBA/(SPT*HPC)
	mov di, ax
	mov si, dx
	mov bx, [SectorPerTrack]
	div bx
	mov bl, [NumberOfHead]
	div bl
	mov ch, al
	
	mov ax, di ; 扇区计算 LBA%SPT + 1
	mov dx, si
	mov bx, [SectorPerTrack]
	div bx
	mov cl, dl
	inc cl
	
	mov ax, di ; 磁头计算 (LBA/SPT)%HPC
	mov dx, si
	mov bx, [SectorPerTrack]
	div bx
	mov bl, [NumberOfHead]
	div bl
	mov dh, ah
	
	ret

	times 446 - ($ - $$) db 0

; DPT部分 使用操作系统的逻辑CHS
P0: partition BOOT_ENABLE, TYPE_FAT, 0, 0, 2, 65, 0, 1, 1, 1048320 ; 分区1 活动分区 大小512MB
P1: partition 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 分区需要四个 未使用的用0填充
P2: partition 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
P3: partition 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

; 引导区标记部分	
	db 55h, 0aah