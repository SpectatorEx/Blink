segment .data
	timer_flag dw 0

segment .text

; params (us):
;	[CX:DX]: microseconds (1000000 us = 1 sec.)
;
;	returns the timer flag. 
;
;	if the timer flag value is 0x80, 
;	then the timer has ended.

timer_async:
	push ax
	push bx

	mov word [timer_flag], 0

	mov ax, 0x8300
	mov bx, timer_flag
	int 0x15

	pop bx
	pop ax
	
	ret

timer_async_stop:
	push ax

	mov ax, 0x8301
	int 0x15

	pop ax

	ret