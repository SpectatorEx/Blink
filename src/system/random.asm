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

	mov cl, 7
	shl ax, cl
	xor dx, ax
	mov ax, dx

	mov cl, 9
	shr ax, cl
	xor dx, ax
	mov ax, dx

	mov cl, 8
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