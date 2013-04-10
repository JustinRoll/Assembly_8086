.model small
.stack 100h
	include macros.inc
.data
storedNum1 db 30h, 30h, 30h, 30h, 30h, 30h, '$'
message1 db "Number of Clicks",0dh,0ah, '$'
vmode db 0h
page db 0h
.code
main proc
mov ax,@data
mov ds,ax
;byte array for number of clicks
;display converted ascii array
;-------------
;|            |
;--------------
;left click in above box, increment mouse counter
;convert mouse position to cursor position
;pixel ranges divisible by 8
;0 to 79
;0 to 24 mouse clicks in 8x8 pixels
;so span a box in a certain range, then figure out if the mouse click is in that range
getVideoMode:
	mov ah,0Fh ;get video mode
	int 10h
	mov vmode,al
	mov page,bh
	mov ah,0
	mov al,12h
	int 10h
;span a box
;scan for mouse clicks
;using dimensions of box, measure clicks inside the box
;display # of clicks

scrollWindow:
	mov ax, 0600h ;violet background
	mov bh, 52h
	mov cx, 0505h ;start at row 05, column 05
	mov dx, 1032h ;end at row 10, column 50
	int 10h
	__moveCursor
;__setScreenMode
__setupMouse ;this displays the mouse cursor

watchMouseClicks:
	;call getMouseInfo
	;cmp ax,1
	call getMousePos
	cmp bx, 0
	JA checkClickInBox

checkEscape:
	mov ah,0 ;move 0 into ah for keypress check
	int 16h  ;check for keypress
    cmp al,27 ;check if escape key was pressed
    JE endProgram
    jmp watchMouseClicks

endProgram:
	mov ah,0
	mov al,vmode
	int 10h
	mov ah, 4ch
	int 21h ;return to dos, exit program

checkClickInBox:
	add storedNum1,1
	mov dx, offset storedNum1
	mov ah,09
	int 21h
	jmp watchMouseClicks
	;mechanism to check carry here
	;here we will check the coordinates of the mouse click
	;if it's in the range of cx = x coordinate, dx = vertical
main endp

getMousePos proc
	 mov bx,0
     mov ax,03h ;notice that I'm putting stuff into Ax
     int 33h ;now check AH for a left click
     ;bit 0--> left
;bit 1--> right
;bit 2--> center
;bx = 02 010
;bx = 04 center
;bx = 01 would be left
getMousePos endp ;cx gives you horizontal, dx gives you vertical
end main