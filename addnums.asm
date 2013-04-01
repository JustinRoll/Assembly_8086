.model small
.stack 100h
.data
storedNum1 db 15 dup(0FFh)
storedNum2 db 15 dup(0FFh)
finalNum db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,'$'
message1 db "Input your first number",0dh,0ah, '$'
message2 db 0dh, 0ah,"Input your second number",0dh,0ah, '$'
messageContinue db "Do you wish to continue?",0dh,0ah, '$'
messageYes db "Yes",0dh, 0ah, '$' ;0dh and 0ah are carriage return and lineFeed chars.
messageNo db "No",0dh, 0ah, '$' 
.code
main proc
	mov ax,@data
	mov ds,ax

	;stuff to fix: carry when addition goes over
	;adding null values together
	clearScreen1:
		mov AX, 0600h ;clear the screen
		mov BH, 07
		mov DX, 184Fh  ; (24d, 79d)
		mov CX, 0000
		int 10h

	prompt1:
		mov dx, offset message1
		mov bx, offset storedNum1
		mov ah,09
		int 21h
		mov cx,15
	getNum1:
		;we will need to jump to the next num once we have enough digits
		;keep a counter of cx, then move to the next label
		mov ah,1
		int 21h
		call getNumber ;
		jnz prompt2 ;if this is a number, don't compute it and skip it in the array
		mov byte ptr [bx], al ;move digit into the array
		inc bx
		loop getNum1

	prompt2:
		mov dx, offset message2
		mov bx, offset storedNum2
		mov ah,09
		int 21h
		mov cx,15
	getNum2:
		mov ah,1
		int 21h
		call getNumber ;
		jnz initRegisters ;if this is a number, don't compute it and skip it in the array
		mov byte ptr [bx], al ;move digit into the array
		inc bx
		loop getNum2

	initRegisters:
		mov bx,15
		mov dx,0h
	startAdds:
		mov cx,15

	findLSB1:
		push bx
		mov bx,cx
		dec bx
		;find the least significant byte of first array
		cmp storedNum1[bx],0FFh ;FFh is a dummy value. It is being used to symbolize null in this program
		je loopLSB1
		jne endLoopLSB1

	loopLSB1:
		mov di, bx ;keep track of our index in di
		pop bx
		loop findLSB1
		jmp startAdds2
	endLoopLSB1:
		mov di, bx ;keep track of our index in di
		pop bx

	startAdds2:
		mov cx, 15

	findLSB2:
		push bx ;bx is our global counter for what digit we are on
		mov bx, cx
		dec bx
		cmp storedNum2[bx],0FFh
		je loopLSB2
		jne endLoopLSB2

	loopLSB2:
		mov si, bx	  ;keep track of this LSB index in SI
		pop bx
		loop findLSB2 ;make this find
		jmp addNums
		;cmp storedNum2 

	endLoopLSB2:
		mov si, bx ;keep track of our index in di
		pop bx

	addNums: ;as we move thru the array, set each value to NULL or 0FFh
		push ax
		mov ah, storedNum1[di] ;number from first array
		cmp ah,0FFh ;check for null
		je zeroAH
	addNum2:
		mov al, storedNum2[si] ;number from second array
		cmp al,0FFh ;zero AL if null
		je zeroAL
	AddNumCleanup:
		mov storedNum1[di],0FFh ;null out this entry
		mov storednum2[si],0FFH ; null out this entry
		add ah, al ;add them together
		cmp dx,1
		je addCarry
	checkCarry:
		cmp ah,9
		ja carryNum

	moveFinalNumToArray:
		add ah,30h
		mov finalNum[bx],ah
		pop ax
		dec bx
		cmp bx,0FFFFh ;0 -1 will result in 0FFh
		jne startAdds

clearScreen2:
	mov AX, 0600h
	mov BH, 07
	mov DX, 184Fh  ; (24d, 79d)
	mov CX, 0000
	int 10h

displaySum:
	push dx
	mov dx, offset finalNum
	mov ah, 9
	int 21h
	pop dx

moveCursorCont:
	mov ah, 02h ;function number
	mov bh, 00h ;page number
	mov dl, 05 ;column position
	mov dh, 00 ;row position
	int 10h

displayContMessage:
	mov ah,9
	mov dx, offset messageContinue
	int 21h

moveCursor1:
	mov ah, 02h ;function number
	mov bh, 00h ;page number
	mov dl, 05 ;column position
	mov dh, 05 ;row position
	int 10h

displayMessage1:
	mov ah,9
	mov dx, offset messageYes
	int 21h

moveCursor2:
	mov ah, 02h ;function number
	mov bh, 00h ;page number
	mov dl, 05 ;column position
	mov dh, 06 ;row position
	int 10h

displayMessage2:
	mov ah,9
	mov dx, offset messageNo
	int 21h

moveBack:
	mov ah, 02h ;function number
	mov bh, 00h ;page number
	mov dl, 05 ;column position
	mov dh, 05 ;row position
	int 10h

resetMenu:
	mov cx,1 ;use cx register to keep track of the cursor position

checkArrows:
	mov ah,0 ;move 0 into ah for keypress check
	int 16h  ;check for keypress
    mov bx,ax
    cmp al,0 ;the cmp with ascii code 0 (al register has ascii code) shows that a special char was pressed
    JE moveMenu
    cmp ah,1Ch ;check if enter key was pressed
    JE checkContinue

 moveMenu:
 	cmp ah,48h ;up arrow pressed
 	JE upArrow
 	cmp ah,50h ; down arrow pressed
 	JE downArrow
	jmp checkArrows

upArrow:
	cmp cx,2 ;move up if need be (if in one of the downward 2 spots)
	JE moveBack
	jmp checkArrows

downArrow:
	cmp cx,1 	;move down if need be (if in one of the upward 2 spots)
	JE moveMenu2
	jmp checkArrows


 moveMenu2:
 	mov cx,2 ;set cursor position to 3
 	mov ah, 02h ;function number
	mov bh, 00h ;page number
	mov dl, 05 ;column position
	mov dh, 06 ;row position
	int 10h
	jmp checkArrows

checkContinue:
	cmp cx,2
	JE endProgram ;end if we are in the no position
	jmp clearScreen1

endProgram:
	mov ah, 4ch
	int 21h ;return to dos, exit program

carryNum:
	sub ah,10
	;set a carry flag or increment a register here
	mov dx,01
	jmp moveFinalNumToArray
addCarry:
	add ah,1
	;set a carry flag or increment a register here
	mov dx,0
	jmp checkCarry
zeroAH:
	mov ah,00h
	jmp addNum2
zeroAL:
	mov al,00h
	jmp AddNumCleanup
main endp ;main endp is main way to end function

getNumber proc
	getDigits:
		cmp al,'0' ;if its below 0 and above 9, we dont care
		jb exitProc
		cmp al,'9'
		ja exitProc
		call convertDigit
		test ax,0 ;set the zero flag if we got a number we like
		je exitProc
	exitProc:
		ret
getNumber endp

convertDigit proc
	sub al,30h
	ret ; exit out of procedure
convertDigit endp

convertAscii proc
	add al,30h
	ret
convertAscii endp
end main