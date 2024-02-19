; params (cursor_size):
; 	[CX]: top, bottom.
;	returns nothing.

bios_cursor_type:
	push ax

	mov ah, 0x01
	int 0x10

	pop ax

	ret

; params (pos):
;	[DX]: y, x.
;	returns nothing.

bios_cursor_pos:
	push ax
	push bx

	mov ah, 0x02
	xor bx, bx
	int 0x10

	pop bx
	pop ax

	ret

; params (pos, color):
;	[DX]: y, x.
;	[BX]: page code, color code.
;
;	returns nothing.

bios_set_color:
	push ax
	push cx

	mov cx, 1
	call bios_cursor_pos

	mov ah, 0x08
	int 0x10
	mov ah, 0x09
	int 0x10

	pop cx
	pop ax

	ret

bios_clear_screen:
	push ax
	
	mov ax, 0x03	; 80x25 16 color text.
	int 0x10

	pop ax

	ret