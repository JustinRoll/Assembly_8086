.model small
.stack 100h
include macros.inc
.data
storedNum1 db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, '$'
message1 db "Number of Clicks", '$'
origVideo db ?
maxEntries db 5
.code
main proc
	mov ax,@data
	mov ds,ax
initCounter:
	mov si,5
	mov ah,0fh
	int 10h
	mov origVideo,al

	mov ah,0
	mov al,12h
	int 10h
	cursor 0,0
	fill 150,250,250,350,4
	cursor 7,30
	display storedNum1

	call checkMouseInstall
	call showCursor
mouseLoop:
	CALL getMousePos
	;ax = 1 if down, 0 if up
	;keep button press info in di
	;on button press, load up di with 1.
	;on button release, clear di
	cmp ax,1h
	JE mousePressed
backClick:
	JB checkClickInBox ;check on release
	JA endProgram
	mov ah,1 ;move 0 into ah for keypress check
	int 16h  ;check for keypress
	JNZ endProgram
	jmp mouseLoop

checkClickInBox:
	cmp di,1 ;there wasn't a previous mouse press
	jne mouseLoop
	mov di,0
	cmp cx,250
	jb mouseLoop
	cmp cx, 350
	ja mouseLoop
	cmp dx, 150
	jb mouseLoop
	cmp dx, 250
	ja mouseLoop
	jmp addNums

addNums:
	mov ah,0FFh
	cmp storedNum1[si],ah ; check for null value, null is FFh
	JE zeroDigit
	mov ah,38h
	cmp storedNum1[si],ah
	JA addCarryStart
	add storedNum1[si],1
	cursor  7,30
	display storedNum1
	jmp mouseLoop

addCarryStart:
	mov ax,00h
	mov al, maxEntries
	mov si,ax

addCarry:
	cmp storedNum1[si],0FFh
	JE zeroDigitCarryFF
	cmp storedNum1[si],38h ;if we have a number that is too big, we want to zero out the least digits and add 1 to the most recent
	JA zeroDigitAndMoveNext
	add storedNum1[si],1
	mov ax,00h
	mov al,maxEntries
	mov si,ax
	cursor 7,30
	display storedNum1
	jmp mouseLoop


mousePressed:
	mov di,1
	jmp backClick

zeroDigit:
	mov ah,30h
	mov storedNum1[si],ah
	jmp addNums

zeroDigitAndMoveNext:
	mov ah,30h
	mov storedNum1[si],ah
	dec si
	jmp addCarry

zeroDigitCarryFF:
	mov ah,30h
	mov storedNum1[si],ah
	jmp addCarry

endProgram:
	display storedNum1
	mov ah,0
	mov al,origVideo
	int 10h
	mov ah,4Ch
	int 21h
main endp

getMousePos proc
	mov bx,0
    mov ax,06h ;notice that I'm putting stuff into Ax
    int 33h ;now check AH for a left click
    ret
getMousePos endp

showCursor proc
	mov ax,1h
	int 33h
	ret
showCursor endp

checkMouseInstall proc
	mov ax,0h
	int 33h
	ret
checkMouseInstall endp

convertDigit proc
	sub al,30h
	ret ; exit out of procedure
convertDigit endp

convertAscii proc
	add al,30h
	ret
convertAscii endp
end main