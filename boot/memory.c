#include "type.h"
#include "multiboot.h"

bool memory_check(uint32* system_table_ptr){
	uint32 memory_size = ((struct multiboot_system_table*)system_table_ptr) -> memory_upper;
	if(memory_size < 131072){
		return false;
	}
	else{
		return true;
	}
}