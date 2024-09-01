mbr.bin: mbr.asm
	nasm mbr.asm -o mbr.bin

dbr.bin: dbr.asm
	nasm dbr.asm -o dbr.bin