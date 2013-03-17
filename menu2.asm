.model small
.stack 100h
.data
fibnos dw 20 dup(0)
message1 db "Choice 1",0dh, 0ah, '$' 
message2 db "Choice 2",0dh, 0ah, '$' 
message3 db "Choice 3",0dh, 0ah, '$' 
message4 db "Choice 4",0dh, 0ah, '$' 

.code
main proc
mov ax,@data
mov ds,ax
scrollWindow:
	mov ax, 0600h ;violet background
	mov bh, 52h
	mov cx, 0505h ;start at row 05, column 05
	mov dx, 1032h ;end at row 10, column 50
	int 10h

moveCursor1:
	mov ah, 02h ;function number
	mov bh, 00h ;page number
	mov dl, 05 ;column position
	mov dh, 05 ;row position
	int 10h

displayMessage1:
	mov ah,9
	mov dx, offset message1
	int 21h

moveCursor2:
	mov ah, 02h ;function number
	mov bh, 00h ;page number
	mov dl, 15 ;column position
	mov dh, 05 ;row position
	int 10h

displayMessage2:
	mov ah,9
	mov dx, offset message2
	int 21h

moveCursor3:
	mov ah, 02h ;function number
	mov bh, 00h ;page number
	mov dl, 05 ;column position
	mov dh, 10 ;row position
	int 10h

displayMessage3:
	mov ah,9
	mov dx, offset message3
	int 21h

moveCursor4:
	mov ah, 02h ;function number
	mov bh, 00h ;page number
	mov dl, 15 ;column position
	mov dh, 10 ;row position
	int 10h

displayMessage4:
	mov ah,9
	mov dx, offset message4
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
    cmp al,27 ;check if escape key was pressed
    JE endProgram 

 moveMenu:
 	cmp ah,48h ;up arrow pressed
 	JE upArrow
 	cmp ah,4Bh ; left arrow pressed
 	JE leftArrow
 	cmp ah,50h ; down arrow pressed
 	JE downArrow
 	cmp ah,4dh ;right arrow pressed
 	JE rightArrow
 	mov ah, 02h ;function number
	mov bh, 00h ;page number
	mov dl, 05 ;column position
	mov dh, 05 ;row position
	int 10h
	jmp checkArrows

upArrow:
	cmp cx,3 ;move up if need be (if in one of the downward 2 spots)
	JE moveBack
	cmp cx,4
	JE moveMenu2
	jmp checkArrows

downArrow:
	cmp cx,1 	;move down if need be (if in one of the upward 2 spots)
	JE moveMenu3
	cmp cx,2
	JE moveMenu4
	jmp checkArrows

leftArrow: ;move left if in one of the rightmost spots
	cmp cx,2
	JE moveBack
	cmp cx,4
	JE moveMenu3
	jmp checkArrows

rightArrow:
	cmp cx,1
	JE moveMenu2
	cmp cx,3
	JE moveMenu4
	jmp checkArrows

 moveMenu2:
 	mov cx,2 ;set cursor position to 2
 	mov ah, 02h ;function number
	mov bh, 00h ;page number
	mov dl, 15 ;column position
	mov dh, 05 ;row position
	int 10h
	jmp checkArrows

 moveMenu3:
 	mov cx,3 ;set cursor position to 3
 	mov ah, 02h ;function number
	mov bh, 00h ;page number
	mov dl, 05 ;column position
	mov dh, 10 ;row position
	int 10h
	jmp checkArrows

 moveMenu4:
 	mov cx,4 ;set cursor position to 4
 	mov ah, 02h ;function number
	mov bh, 00h ;page number
	mov dl, 15 ;column position
	mov dh, 10 ;row position
	int 10h
	jmp checkArrows

endProgram:
	mov ah, 4ch
	int 21h ;return to dos, exit program

main endp
end main