segment .data
	tmr_pos		dw 0
	tmr_intv	dd 0
	tmr_count	db 0
	intv_flag	dw 0

segment .text

; params (pos, sec, delay):
;	[AX]: y, x.
;	[BX]: seconds amount.
;	[CX, DX]: microseconds (1000000 us = 1 sec.)
;
;	returns nothing.

timer_init:
	mov [tmr_pos], ax
	mov [tmr_count], bx
	mov [tmr_intv + 2], cx
	mov [tmr_intv], dx

	call timer_draw
	call timer_interval

	ret

timer_draw:
	push ax
	push dx
	
	mov dx, [tmr_pos]
	call bios_cursor_pos

	mov ah, 0x02				; display timer
	mov dl, [tmr_count]			; (0-9 seconds only).
	add dl, '0'
	int 0x21

	pop dx
	pop ax

	ret

timer_update:
	cmp word [intv_flag], 0x80
	jne .return

	dec byte [tmr_count]

	call timer_draw
	call timer_interval

.return:
	ret

timer_interval:
	push ax
	push bx
	push dx
	push cx

	mov word [intv_flag], 0		; Reset flag.
	mov ax, 0x8301				; Reset interval.
	int 0x15

	xor al, al					; Set interval.
	mov cx, [tmr_intv + 2]
	mov dx, [tmr_intv]
	mov bx, intv_flag			; If the flag is set to 0x80,
	int 0x15					; then the interval has expired.

	pop cx
	pop dx
	pop bx
	pop ax
	
	ret

; params (us):
;	[DX]: microseconds to subtract.
;	returns nothing.

timer_sub_interval:
	sub [tmr_intv], dx			; Reduce the timer interval.
	jnc .return					; If CF != 1.

	dec word [tmr_intv + 2]

.return:
	call timer_interval
	ret