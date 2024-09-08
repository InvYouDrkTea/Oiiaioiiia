#include "type.h"

uint32 main(void){
	uint16* i = 0xb8000;
	for(;i < 0xbffff;i++){
		*i = 0x0a4b;
	}
	return 0;
}
