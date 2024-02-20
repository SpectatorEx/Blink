cpu 8086
org 0x100

segment .data
	score				dw 0
	high_score 			dw 0
	color_code			db 0

	time_count			db 3
	timer_tick			dd 0xF4240

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
	call bios_clear_screen

	mov cx, 0x2000					; Disable cursor.
	call bios_cursor_type

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

	xor ax, ax						; Get system time.
	int 0x1A

	mov [rand_seed], dx

	cmp al, 0x1B					; If key == ESC.
	je .exit

.start:
	call bios_clear_screen

	mov cx, 0x2000
	call bios_cursor_type

	xor dx, dx
	mov cx, 0x50
	mov bx, 0x33
	call draw_line

	call display_score
	call display_timer
	
	call timer_start				; Start system timer.

	jmp .draw						; Draw rect and text.

.update:
	mov ah, 0x01					; Get key status.
	int 0x16
	jnz .key_pressed

.key_not_pressed:
	cmp byte [time_count], 0		; If time counter == 0.
	je .restart

	cmp word [timer_flag], 0x80		; If timer isn't completed.
	jne .update

	dec byte [time_count]

	call display_timer
	call timer_start				; Restart system timer.

	jmp .update

.key_pressed:
	mov ah, 0x08					; Wait keyboard input.
	int 0x21

	xor ah, ah
	sub al, '0'						; Convert to digit.
	dec al
	cmp al, 7
	jg .restart
	mov bx, colors
	xlat

	cmp al, [color_code]
	jne .restart

	inc word [score]				; Add points.
	call display_score
	
	cmp word [score], 1000			; If score == 1000.
	je .restart

	mov byte [time_count], 3		; Reset time counter.
	sub word [timer_tick], 750		; Increase timer speed.
	jnc .reset_timer				; If CF != 1.

	dec word [timer_tick + 2]

.reset_timer:
	call display_timer

	call timer_async_stop			; Stop system timer.
	call timer_start				; Restart system timer.

.draw:
	mov bx, 1						; Random rectangle bgcolor.
	mov cx, 7
	call xrandom_range

	mov bx, ax
	mov cl, 4
	rol bl, cl						; Rotate half a byte.
	mov cl, bl						; Save rectangle bgcolor.
	add bl, al

	mov dx, 0x061E					; Draw rect 20x14.
	mov ax, 0x1432
	call draw_color_area

.draw_string:
	mov bx, 8						; Get random string [0..7].
	xor dx, dx
	call xrandom
	div bx

	mov ax, dx						; Set index to search in array.
	mov bx, names_offset			; Set pointer to array.
	xlat							; Get value from array index to AL register.
	mov bx, ax
	mov di, color_names
	lea si, [bx + di]				; Get final string.

	mov bx, 8						; Get random array index.
	xor dx, dx
	call xrandom
	div bx

	mov ax, dx
	mov bx, colors
	xlat
	mov [color_code], al			; Save color code.
	xor bx, bx
	mov bl, cl						; Get rectangle bgcolor.
	add bl, al						; Set color with rectangle bgcolor.

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
	jl .reset

	mov [high_score], ax

.reset:
	mov byte [time_count], 3
	mov word [timer_tick], 0x4240
	mov word [timer_tick + 2], 0x0F

	call timer_async_stop

	mov dx, 0x1620
	mov si, restart_msg
	mov	bx,	0x07
	call draw_text	 

.wait_key:
	mov ah, 0x08					; Wait keyboard input.
	int 0x21

	cmp al, 'r'
	je .start
	cmp al, 0x1B
	je .exit

	jmp .wait_key

.exit:
	call bios_clear_screen

	mov ax, 0x4C00					; Terminate program.
	int 0x21

timer_start:
	push dx
	push cx

	mov cx, [timer_tick + 2]
	mov dx, [timer_tick]
	call timer_async

	pop cx
	pop dx

	ret

display_timer:
	push ax
	push dx

	mov dx, 0x0428
	call bios_cursor_pos

	mov ah, 0x02
	mov dl,	[time_count]
	add dl, '0'
	int 0x21

	pop dx
	pop ax

	ret

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
%include "system/bios.asm"
%include "system/graph.asm"
%include "system/timer.asm"
%include "system/random.asm"
%include "system/string.asm"