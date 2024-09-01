; 用于创建主分区表的头文件

BOOT_ENABLE equ 80h ; 分区状态是否可引导
BOOT_DISABLE equ 0

TYPE_FAT equ 01h

%macro partition 10 ; partition state, type, startTrack, startHead, startSector, endTrack, endHead, endSector, startLBA, length
	db %1 & 0ffh
	db %4 & 0ffh
	db (%5 & 00111111b) | (%3 & 11000000b)
	db %3 & 0ffh 
	db %2 & 0ffh
	db %7 & 0ffh
	db (%8 & 00111111b) | (%6 & 11000000b)
	db %6 & 0ffh
	dd %9 & 0ffffffffh
	dd %10 & 0ffffffffh
%endmacro