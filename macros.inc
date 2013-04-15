__moveCursor macro
	push ax
	push bx
	push dx
	mov ah, 02h
	mov bh, 00h
	mov dl, 05
	mov dh, 05
	int 10h
	pop dx
	pop bx
	pop ax
endm

__setScreenMode macro
    mov ah,00     
    mov al,13h
    int 10h
 endm

 __setupMouse macro
 	push ax
	mov ax,0000  
    int 33h
    mov ax,0001   
    int 33h
    pop ax
 endm

 __printString macro string:REQ
	push ax
	push dx
	mov dx, offset string
	mov ah, 9
	int 21h
	pop dx
	pop ax
 endm

__drawBox macro
	mov ax, 0600h
	mov bh, 52h
	mov cx, 0505h
	mov dx, 1032h
	int 10h
endm

cursor macro row, column
		mov ah,02
		mov bh,00
		mov dh, row
		mov dl, column
		int 10h
endm

display macro dumstring
	mov ah,09
	mov dx, offset dumstring
	int 21h
endm

fill macro row_start, col_start, row_end, col_end, color
	local start, again
	mov dx, row_start

	start:
		mov cx, col_start
	again:
		mov ah,0ch
		mov al, color
		int 10h
		inc cx
		cmp cx, col_end
		jne again
		inc dx
		cmp dx, row_end
		jne start
endm

clearScreen macro
	mov AX, 0600h
	mov BH, 07
	mov DX, 184Fh
	mov CX, 0000
	int 10h
endm

setVideo macro
	mov ah,0
	mov al,12h
	int 10h
endm