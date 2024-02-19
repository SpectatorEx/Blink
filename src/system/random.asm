segment .data
	rand_seed dw 1

segment .text

; Xorshift algorithm.
; returns random number to AX register.

xrandom:
	push dx
	push cx

	mov ax, [rand_seed]
	mov dx, ax

	mov cl, 7	; 7 or 4.
	shl ax, cl
	xor dx, ax
	mov ax, dx

	mov cl, 9	; 9 or 3.
	shr ax, cl
	xor dx, ax
	mov ax, dx

	mov cl, 8 	; 8 or 7.
	shl ax, cl
	xor dx, ax
	mov ax, dx

	mov [rand_seed], ax

	pop cx
	pop dx

	ret

; params (min, max):
;	[BX]: min.
;	[CX]: max.
;
;	returns random number to AX register.

xrandom_range:
	push dx
	push cx

	sub cx, bx
	inc cx

	call xrandom

	xor dx, dx
	div cx
	add dx, bx
	mov ax, dx

	pop cx
	pop dx
	
	ret