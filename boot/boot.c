#include "type.h"
#include "multiboot.h"
#include "library.h"

extern bool memory_check(uint32* system_table_ptr); // 内存容量检查

uint32 boot(uint32* system_table){
	if(!memory_check(system_table)){ // 如果检查未通过就会返回false 而!false就是true则会触发if
		ia_32_halt();
	}
	
	uint32* vbe_mode_information_ptr = ((struct multiboot_system_table*)system_table) -> vbe_mode_information;
	uint32* graphic_buffer = vbe_mode_information_ptr + 40; // 偏移40处存放四字节缓冲区线性地址
	
	uint32 i = 1280 * 720; // 屏幕分辨率
	for(; i > 0; i --){
		*graphic_buffer = 0x000000ff;
		graphic_buffer ++;
	}
	
	for(;;){
		ia_32_halt();
	}
	
	return 0;
}
