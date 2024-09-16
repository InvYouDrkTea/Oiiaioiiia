	global io_in, io_out

[bits 64]
io_in:
	mov edx, [esp + 4]
	xor eax, eax
	in ax, dx
	ret

io_out:
	mov edx, [esp + 4]
	mov eax, [esp + 8]
	out dx, ax
	ret
