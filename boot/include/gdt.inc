; 用于Loader时期临时创建GDT的头文件

FL_32 equ 04h ; D/B位置为1

AC_DRW equ 92h ; 存在的可读可写数据段
AC_CRE equ 9ah ; 存在的可读可执行代码段

%macro descriptor 4 ; descriptor base, limit, access, flags
	dw %2 & 0ffffh
	dw %1 & 0ffffh
	db (%1 >> 16) & 0ffh
	db %3 & 0ffh
	db ((%2 >> 16) & 0fh) | ((%4 << 4) & 0f0h)
	db (%1 >> 24) & 0ffh
%endmacro