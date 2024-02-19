; params (pos, width, color):
;	[DX]: y, x.
;	[CX]: width.
;	[BX]: page code, color code.
;
;	returns nothing.

draw_line:
	push ax
	call bios_cursor_pos

.draw:
	mov ah, 0x09
	mov al, '#'
	int 0x10

	pop ax

	ret

; params (pos, text, color):
;	[DX]: y, x.
;	[SI]: pointer to string.
;	[BX]: page code, color code.
;
;	returns nothing.

draw_text:
	push ax
	push dx
	push cx
	push si

	mov cx, 1

.draw:
	call bios_cursor_pos

	mov ah, 0x09
	mov al, [si]
	int 0x10

	inc dl
	inc si

	cmp byte [si], '$'
	jne .draw

	pop si
	pop cx
	pop dx
	pop ax

	ret

; params (pos, size, color):
;	[DX]: y, x.
;	[AX]: height, width.
;	[BX]: page code, color code.
;
;	returns nothing.

draw_color_area:
	push dx
	push cx

	mov cx, dx

.draw:
	call bios_set_color

	inc dl
	cmp dl, al
	jl .draw

	mov dl, cl
	inc dh
	cmp dh, ah
	jl .draw

	pop cx
	pop dx

	ret