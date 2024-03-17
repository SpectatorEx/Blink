cpu 8086
org 0x100

%define HW_INTV			0x0F		; Total amount:
%define LW_INTV			0x4240		; 1 sec.

segment .data
	score				dw 0
	high_score 			dw 0
	color_code			db 0

	high_score_msg		db "HI SCORE:",	'$'
	score_msg			db "SCORE:",	'$'

	color_names			db "BLACK",		'$'
						db "BLUE",		'$'
						db "GREEN",		'$'
						db "CYAN",		'$'
						db "RED",		'$'
						db "MAGENTA",	'$'
						db "YELLOW",	'$'
						db "WHITE",		'$'

	names_offset		db 0, 6, 11, 17, 22, 26, 34, 41
	colors				db 0, 9, 10, 11, 12, 13, 14, 15

segment .bss
	output_score 		resb 5
	output_high_score 	resb 5

segment .text

main:
	call clear_screen_ex			; Clear screen and cursor.

	mov ah, 0x09					; Print	intro.
	mov dx, info_msg
	int 0x21

	mov dx, 0x1800
	mov cx, 0x50
	mov bx, 0x33
	call draw_line

	mov dx, 0x181D
	mov si, start_msg
	mov bx, 0xB0
	call draw_text

	mov ah, 0x08					; Wait keyboard input.
	int 0x21

	cmp al, 0x1B					; If key == ESC.
	je .exit

	call clear_screen_ex

	xor ax, ax						; Get system time.
	int 0x1A

	mov [rand_seed], dx				; Set random seed.

.start:
	xor dx, dx
	mov cx, 0x50
	mov bx, 0x33
	call draw_line

	call display_score

	mov ax, 0x0428
	mov bx, 3
	mov cx, HW_INTV
	mov dx, LW_INTV
	call timer_init					; Init and start timer.

	jmp .draw						; Draw rect and text.

.update:
	mov ah, 0x01					; Get key status.
	int 0x16
	jnz .key_pressed

.key_not_pressed:
	call timer_update
	
	cmp byte [tmr_count], 0			; If timer counter == 0
	je .restart						; restart game.

	jmp .update

.key_pressed:
	mov ah, 0x08					; Wait keyboard input.
	int 0x21

	xor ah, ah
	sub al, '0'						; Convert to digit.
	cmp al, 8
	jg .restart

	dec al							; Get color code from array.
	mov bx, colors
	xlat
	cmp al, [color_code]
	jne .restart

	inc word [score]				; Add point.
	call display_score

	cmp word [score], 1000			; If score == 1000.
	je .restart

	mov dx, 750
	mov byte [tmr_count], 3
	call timer_draw
	call timer_sub_interval

.draw:
	mov bx, 1						; Random rect bgcolor.
	mov cx, 7
	call xrandom_range

	mov bx, ax						; Copy random color.
	mov cl, 4						; Set the shift value.
	rol bl, cl						; Set rect bgcolor.
	mov cl, bl						; Save rect bgcolor.
	add bl, al

	mov dx, 0x061E					; Draw rect 20x14.
	mov ax, 0x1432
	call draw_color_area

.draw_string:
	mov bx, 8						; Get random index [0..7].
	xor dx, dx
	call xrandom
	div bx

	mov ax, dx						; Set index to search in array.
	mov bx, colors					; Set pointer to array.
	xlat							; Get value from array to AL register.
	mov [color_code], al			; Save color code.

	mov ax, dx
	mov bx, names_offset
	xlat
	mov bx, ax						; Copy this value.
	mov di, color_names				; Set pointer to first string.
	lea si, [bx + di]				; Get final string.

	mov bx, 8
	xor dx, dx
	call xrandom
	div bx

	mov ax, dx
	mov bx, colors
	xlat
	xor bx, bx
	mov bl, cl						; Get saved rect bgcolor.
	add bl, al						; Set text fgcolor with rect bgcolor.

	call string_length

	mov dx, 0x0C28					; String position.
	shr ax, 1						; Center alignment.
	sub dl, al
	call draw_text

	jmp .update

.restart:
	mov ax, [score]
	mov word [score], 0

	cmp ax, [high_score]			; If score < high score.
	jl .continue

	mov [high_score], ax

.continue:
	mov dx, 0x1620
	mov si, restart_msg
	mov	bx, 0x07
	call draw_text

.wait_key:
	mov ah, 0x08					; Wait keyboard input.
	int 0x21

	cmp al, 'r'
	jne .next_key

	mov cx, 16
	call clear_text

	jmp .start

.next_key:
	cmp al, 0x1B					; If key == ESC.
	jne .wait_key

.exit:
	call clear_screen

	mov ax, 0x4C00					; Terminate program.
	int 0x21

display_score:
	push ax
	push bx
	push dx
	push si

.high_score:
	mov dx, 1
	mov si, high_score_msg
	mov bx, 0x30
	call draw_text

	mov di, output_high_score
	mov ax, [high_score]
	call string_conv_word

	mov dx, 0x0B
	mov si, di
	call draw_text

.score:
	mov dx, 0x10
	mov si, score_msg
	call draw_text

	mov di, output_score
	mov ax, [score]
	call string_conv_word

	mov dx, 0x17
	mov si, di
	call draw_text

	pop si
	pop dx
	pop bx
	pop ax

	ret

%include "info.asm"
%include "system/graph.asm"
%include "system/timer.asm"
%include "system/random.asm"
%include "system/string.asm"