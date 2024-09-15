#include "type.h"
#include "library.h"

uint32 main(void){
	uint16* i = 0xb8000;
	uint32 c = return_parameter('C');
	for(;i < 0xbffff;i++){
		*i = 0x0a00 + c;
	}
	return 0;
}
