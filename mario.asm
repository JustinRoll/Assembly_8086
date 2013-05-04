.model small
.stack 100h
include macros.inc
.data
origVideo db ?
row_start dw 370
row_end dw 380
col_start dw 200
col_end dw 220

pipeRowStart dw 400
pipeRowEnd dw 450
pipeColStart dw 400
pipeColEnd dw 450
.code
main proc
	mov ax,@data
	mov ds,ax
	;fill macro row_start, col_start, row_end, col_end, color
	clearScreen
	setVideo
	cursor 0,0
	fill 450,0,600,640,6 ;draw the ground
	fill 400,400,450,450,2 ;draw a box for the pipe
	fill 390,390,400,460,2 ;draw rim of pipe
	mov bl,12
	call drawManB
	

checkArrows:
	mov ah,0 ;move 0 into ah for keypress check
	int 16h  ;check for keypress
    cmp al,27 ;check if escape key was pressed
    JE endProgram
    cmp al,73h ;right arrow pressed
 	JE ctrlLeft 
    cmp al,64h ;right arrow pressed
 	JE ctrlRight
    cmp al,0 ;the cmp with ascii code 0 (al register has ascii code) shows that a special char was pressed
    JE moveMan

 moveMan:
 	cmp ah,48h ;up arrow pressed
 	JE upArrow
 	cmp ah,4Bh ; left arrow pressed
 	JE leftArrow
 	cmp ah,50h ; down arrow pressed
 	JE downArrow
 	cmp ah,4dh ;right arrow pressed
 	JE rightArrow
	jmp checkArrows

upArrow:
	call jumpMan
	jmp checkArrows

downArrow:
	jmp checkArrows

leftArrow: ;move left if in one of the rightmost spots
	call goLeft
	jmp checkArrows

rightArrow:
	call goRight
	jmp checkArrows

ctrlRight:
	call jumpRight
	jmp checkArrows

ctrlLeft:
	call jumpLeft
	jmp checkArrows

endProgram:
	mov ah,4Ch
	int 21h
main endp

checkPipe proc
	;here we will check if our man is within the bounds
	;di=1 a collision occurs! else 0
	;si=1 a successful jump occurs!
	checkGoingRight:
		mov si, pipeColStart ;if we are within 50
		sub si, col_end
		cmp si, 50
		jb collision
		jmp noCollision
	
	collision:
		mov di,1
		mov si,row_start
		sub si,pipeRowStart
		jnc moveOnTop
		jc exitProc
		moveOnTop:
			;move man on top of pipe
			mov si,1
			mov cx,pipeRowStart
			mov row_end,cx
			mov pipeRowStart,cx
			sub cx,110
			mov row_start,cx
			;mov bx, row_end
			;sub bx, row_start ;get the length of our man
			;mov cx, pipeRowStart
			;mov row_end,cx
			;sub cx,bx
			;mov row_Start,cx 
			jmp exitProc
	noCollision:
		mov di,0
		mov si,0
		ret
	exitProc:
		ret
checkPipe endp

checkLanding proc
	;here we will check if our man is within the bounds
	;di=1 a collision occurs! else 0
	;si=1 a successful jump occurs!
	checkLand:
		mov si, pipeColStart ;if we are within 30 pixels of pipe
		sub si, col_end
		cmp si, 50
		jb cCollision
		mov si, col_end
		sub si, pipeColStart
		cmp si, 90
		jb cCollision
		jmp cNoCollision
	
	ccollision:

		;move top of pipe into si
		;if man's feet are higher than the top of the pipe AND the man's feet are within 10 of the top of the pipe, stop the movement
		mov di,1
		mov si,pipeRowStart ;these coordinates indicate the top of the pipe
		mov ax,row_start
		add ax,80
		sub si,ax
		cmp si,10
		jbe landMan
		;ja landMan
		jmp cNoLanding
		landMan:
			;move man on top of pipe
			mov si,1
			;mov cx,pipeRowStart ;move top of pipe into cx
			;mov row_end,cx      ;set our man's feet at the top of the pipe (good)
			;sub cx,110 
			;mov row_start,cx
			;mov bx, row_end
			;sub bx, row_start ;get the length of our man
			;mov cx, pipeRowStart
			;mov row_end,cx
			;sub cx,bx
			;mov row_Start,cx 
			jmp cExitProc
	cNoCollision:
		mov di,0
	cNoLanding:
		mov si,0
	cExitProc:
		ret
checkLanding endp

fillB proc 
	push ax
	push bx
	push cx
	push dx
	mov si,row_end
	mov di,col_end

	mov dx, row_start

	@@start:
		mov cx, col_start
	@@again:
		mov ah,0ch
		mov al, bl
		int 10h
		inc cx
		cmp cx, di
		jne @@again
		inc dx
		cmp dx, si
		jne @@start
	pop dx
	pop cx
	pop bx
	pop ax
	ret
fillB endp

drawManB proc
	push row_start
	push col_start
	push row_end
	push col_end
	call fillB
	mov si, row_start
	add si, 10
	mov row_start,si
	mov si,col_start
	sub si,30
	mov col_start,si
	mov si,row_end
	add si,20
	mov row_end,si
	mov si,col_end
	add si,30
	mov col_end,si
	call fillB
	mov si,row_start
	add si,20
	mov row_start,si
	mov si,col_start
	add si,25
	mov col_start,si
	mov si, row_end
	add si,30
	mov row_end,si
	mov si,col_end
	sub si,25
	mov col_end,si
	call fillB
	mov si,row_start
	add si,30
	mov row_start,si
	mov si,col_start
	sub si,10
	mov col_start,si
	mov si,row_end
	add si,20
	mov row_end,si
	mov si, col_end
	sub si,25
	mov col_end,si
	call fillB
	;don't mocol_startfy col_end
	mov si,col_start
	add si,35
	mov col_start,si
	mov si, col_end
	add si,35
	mov col_end,si
	call fillB

	pop col_end
	pop row_end
	pop col_start
	pop row_start
	ret
drawManB endp

jumpMan proc
	call goUp
	call goUp
	call goUp
	call goUp
	call goUp
	call goDown
	call goDown
	call goDown
	call goDown
	call goDown
	ret
jumpMan endp

goUp proc

	moveUp:
		mov bl,0
		call drawManB
		mov si, row_start
		sub si,20
		mov row_start,si

		mov si,row_end
		sub si,20
		mov row_end,si
		mov bl,12
		call drawManB
	exitGoUp:
		ret
goUp endp

goRight proc
	call checkPipe
	cmp di,0
	je moveRight
	cmp si,1 ; si = 1 = move man on top of pipe
	je moveRight ;move right and up
	;jmp exitProcedure
	 moveRight:
		mov bl,0
		call drawManB ;clear out man
		mov si, col_start
		add si,20
		mov col_start,si

		mov si,col_end
		add si,20
		mov col_end,si
		mov bl,12
		call drawManB
	exitProcedure:
		ret
goRight endp

goLeft proc
	mov bx,0
	call drawManB
	mov si, col_start
	sub si,20
	mov col_start,si

	mov si,col_end
	sub si,20
	mov col_end,si
	mov bl,12
	call drawManB
	ret
goLeft endp


goDown proc
	mov bl,0
	call drawManB
	mov si, row_start
	add si,20
	mov row_start,si
	mov si,row_end
	add si,20
	mov row_end,si
	mov bl,12
	call drawManB
	ret
goDown endp

jumpRight proc
	call goUp ;1
	call goRight 
	call goUp ;2
	call goRight
	call goUp ;3
	call goRight
	call goUp ;4
	call goRight
	call goUp ;5
	call goRight
	
	mov cx,5
	descend:
		call checkLanding
		cmp si,1
		je landJump
		call goDown
		call goRight
		loop descend
	landJump:
		ret
jumpRight endp

jumpLeft proc
	call goUp
	call goLeft
	call goUp
	call goLeft
	call goUp
	call goLeft

	call goDown
	call goLeft
	call goDown
	call goLeft
	call goDown
	ret
jumpLeft endp
end main