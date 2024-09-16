	global return_parameter

[bits 32]
return_parameter:
	mov eax, [esp + 4]
	ret