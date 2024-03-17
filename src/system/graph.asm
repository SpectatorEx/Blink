; params (pos):
;	[DX]: y, x.
;	returns nothing.

cursor_pos:
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

set_color:
	push ax
	push cx

	call cursor_pos

	mov ah, 0x08
	int 0x10

	mov ah, 0x09
	mov cx, 1
	int 0x10

	pop cx
	pop ax

	ret

; params (pos, length, color):
;	[DX]: y, x.
;	[CX]: length.
;	[BX]: page code, color code.
;
;	returns nothing.

draw_line:
	push ax

	call cursor_pos

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
	call cursor_pos

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

; params (pos, length)
;	[DX]: y, x.
;	[CX]: string length.
;
;	returns nothing.

clear_text:
	push ax
	push bx

	call cursor_pos
	
	mov ax, 0x0920
	xor bx, bx
	int 0x10

	pop bx
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
	call set_color

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

clear_screen:
	push ax

	mov ax, 0x03		; 80x25 16 color text.
	int 0x10			; Reset text mode.

	pop ax

	ret

clear_screen_ex:
	push ax
	push cx

	mov ax, 0x03		; 80x25 16 color text.
	int 0x10			; Reset text mode.

	mov ah, 0x01		; Disable cursor.
	mov cx, 0x2000
	int 0x10

	pop cx
	pop ax

	ret