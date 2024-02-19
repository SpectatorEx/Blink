; params (buffer, value):
;	[DI]: pointer to buffer.
;	[AX]: value (word) for convert to string.
;
;	returns filled buffer (string).

string_conv_word:
	push ax
	push bx
	push dx
	push cx
	push di

	mov bx, 10
	xor cx, cx

.convert:
	xor dx, dx
	div bx
	add dx, '0'
	push dx
	inc cx

	cmp ax, 0
	jne .convert

.write:
	pop dx
	mov [di], dx
	inc di
	loop .write

	mov byte [di], '$'

	pop di
	pop cx
	pop dx
	pop bx
	pop ax

	ret

; params (str):
;	[SI]: pointer to string.
;	returns string length to AX register.

string_length:
	push si
	xor ax, ax

.read:
	inc ax
	inc si

	cmp byte [si], '$' 
	jne .read
	dec ax

	pop si

	ret